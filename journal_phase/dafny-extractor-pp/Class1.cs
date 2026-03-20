using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Dafny;
using Microsoft.Dafny.Plugins;

namespace DafnyAstExtractor;

public class AstExtractorConfiguration : PluginConfiguration {
  private string outputPath = "/mnt/shared/gpfs/home/manvij2/journal_phase/ast_json/dafny-ast-output.json";

  public override void ParseArguments(string[] args) {
    if (args.Length >= 1 && !string.IsNullOrWhiteSpace(args[0])) {
      outputPath = args[0];
    }
  }

  public override Rewriter[] GetRewriters(ErrorReporter errorReporter) {
    return new Rewriter[] { new AstExtractorRewriter(errorReporter, outputPath) };
  }
}

public class AstExtractorRewriter : Rewriter {
  private readonly string outputPath;

  public AstExtractorRewriter(ErrorReporter reporter, string outputPath) : base(reporter) {
    this.outputPath = outputPath;
  }

  public override void PostResolve(Program program) {
    var extractor = new Extractor();
    var result = extractor.Extract(program);

    var jsonOptions = new JsonSerializerOptions {
      WriteIndented = true,
      DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
    };

    var json = JsonSerializer.Serialize(result, jsonOptions);
    File.WriteAllText(outputPath, json);
  }
}

internal sealed class Extractor {
  public AstExtractionResult Extract(Program program) {
    var allNodes = Traverse(program).ToList();

    var callableRecords = new List<CallableRecord>();
    var callableByNode = new Dictionary<object, CallableRecord>(ReferenceEqualityComparer.Instance);

    var ghostDeclarations = new List<GhostDeclarationRecord>();
    var seenGhostDeclKeys = new HashSet<string>();

    // -----------------------------
    // Pass 1: collect callables
    // -----------------------------
    foreach (var node in allNodes) {
      if (node is Function f) {
        var rec = MakeFunctionRecord(f);
        callableRecords.Add(rec);
        callableByNode[f] = rec;
      } else if (node is Method m) {
        var rec = MakeMethodRecord(m);
        callableRecords.Add(rec);
        callableByNode[m] = rec;
      }
    }

    var callableByQualifiedName = callableRecords.ToDictionary(c => c.QualifiedName, c => c);

    // -----------------------------
    // Pass 2: collect call edges
    // -----------------------------
    foreach (var node in allNodes) {
      if (node is Function f && callableByNode.TryGetValue(f, out var caller)) {
        foreach (var calleeName in ExtractFunctionCalls(f)) {
          caller.Calls.Add(calleeName);
        }
      }
    }

    foreach (var node in allNodes) {
      if (node is Method m && callableByNode.TryGetValue(m, out var caller)) {
        foreach (var calleeName in ExtractMethodCalls(m)) {
          caller.Calls.Add(calleeName);
        }
      }
    }

    // Keep only internal callables and sort/dedup
    foreach (var c in callableRecords) {
      c.Calls = c.Calls
        .Where(name => callableByQualifiedName.ContainsKey(name))
        .Distinct()
        .OrderBy(x => x)
        .ToList();
    }

    // -----------------------------
    // Pass 3: collect ghost decls
    // -----------------------------
    foreach (var node in allNodes) {
      if (TryMakeGhostDeclarationRecord(node, out var rec)) {
        var key = $"{rec.Kind}|{rec.QualifiedContext}|{rec.Name}|{rec.SourceLine}|{rec.SourceColumn}";
        if (seenGhostDeclKeys.Add(key)) {
          ghostDeclarations.Add(rec);
        }
      }
    }

    // -----------------------------
    // Pass 4: count invariants
    // -----------------------------
    var invariantCount = CountInvariantClauses(program);

    // -----------------------------
    // Pass 5: SCC recursion
    // -----------------------------
    var sccs = Tarjan(callableRecords);

    var directRecursive = new List<string>();
    var mutualRecursiveGroups = new List<List<string>>();

    foreach (var scc in sccs) {
      if (scc.Count == 1) {
        var only = scc[0];
        var rec = callableByQualifiedName[only];
        if (rec.Calls.Contains(only)) {
          directRecursive.Add(only);
        }
      } else {
        mutualRecursiveGroups.Add(scc.OrderBy(x => x).ToList());
      }
    }

    // -----------------------------
    // Pass 6: keep Dafny's own resolved recursion flags
    // -----------------------------
    foreach (var node in allNodes) {
      if (node is Function f && callableByNode.TryGetValue(f, out var fr)) {
        fr.DafnyResolvedIsRecursive = f.IsRecursive;
      } else if (node is Method m && callableByNode.TryGetValue(m, out var mr)) {
        mr.DafnyResolvedIsRecursive = m.IsRecursive;
      }
    }

    return new AstExtractionResult {
      DafnyVersionNote = "Built against Dafny 4.11.x assemblies (DafnyCore/DafnyDriver); report is fully AST-based.",
      TotalCallables = callableRecords.Count,
      Callables = callableRecords
        .OrderBy(c => c.Kind)
        .ThenBy(c => c.QualifiedName)
        .ToList(),
      DirectRecursive = directRecursive.OrderBy(x => x).ToList(),
      MutualRecursiveGroups = mutualRecursiveGroups
        .OrderBy(g => g.Count)
        .ThenBy(g => string.Join("|", g))
        .ToList(),
      Summary = new AstSummary {
        GhostVariables = ghostDeclarations.Count(g => g.Kind == "variable"),
        GhostConstants = ghostDeclarations.Count(g => g.Kind == "constant"),
        LoopInvariantClauses = invariantCount
      },
      GhostDeclarations = ghostDeclarations
        .OrderBy(g => g.Kind)
        .ThenBy(g => g.QualifiedContext)
        .ThenBy(g => g.Name)
        .ToList()
    };
  }
  private string? TryGetFieldBackedName(object node) {
    var name = TryGetName(node);
    if (!string.IsNullOrWhiteSpace(name)) {
      return name;
    }

    // Some declaration nodes store a wrapped variable/name field
    var variable = TryGetPropertyOrField(node, "Var") ?? TryGetPropertyOrField(node, "Lhs");
    if (variable != null) {
      var nestedName = TryGetName(variable);
      if (!string.IsNullOrWhiteSpace(nestedName)) {
        return nestedName;
      }
    }

    return null;
  }

  private string? TryGetBetterQualifiedContext(object node) {
    var owner = TryGetPropertyOrField(node, "EnclosingMember");
    if (owner is Function f) {
      return BuildQualifiedName(f);
    }
    if (owner is MethodOrConstructor m) {
      return BuildQualifiedName(m);
    }

    var enclosingClass = TryGetPropertyOrField(node, "EnclosingClass");
    if (enclosingClass != null) {
      var className = TryGetName(enclosingClass);
      var mod = TryGetPropertyOrField(enclosingClass, "EnclosingModuleDefinition");
      if (mod is ModuleDefinition md1) {
        var modName = GetModuleName(md1);
        if (!string.IsNullOrWhiteSpace(modName) && !string.IsNullOrWhiteSpace(className)) {
          return $"{modName}.{className}";
        }
      }
      if (!string.IsNullOrWhiteSpace(className)) {
        return className;
      }
    }

    var enclosingModule = TryGetPropertyOrField(node, "EnclosingModuleDefinition");
    if (enclosingModule is ModuleDefinition md2) {
      return GetModuleName(md2);
    }

    return null;
  }

  // ============================================================
  // Callable records
  // ============================================================

  private CallableRecord MakeFunctionRecord(Function f) {
    return new CallableRecord {
      Kind = NormalizeFunctionKind(f),
      Name = f.Name,
      QualifiedName = BuildQualifiedName(f),
      ModuleName = GetModuleName(f.EnclosingClass?.EnclosingModuleDefinition),
      EnclosingClass = IsDefaultClass(f.EnclosingClass) ? null : f.EnclosingClass?.Name,
      IsGhost = f.IsGhost,
      SourceLine = TryGetLine(f),
      SourceColumn = TryGetCol(f),
      Calls = new List<string>()
    };
  }

  private CallableRecord MakeMethodRecord(Method m) {
    return new CallableRecord {
      Kind = NormalizeMethodKind(m),
      Name = m.Name,
      QualifiedName = BuildQualifiedName(m),
      ModuleName = GetModuleName(m.EnclosingClass?.EnclosingModuleDefinition),
      EnclosingClass = IsDefaultClass(m.EnclosingClass) ? null : m.EnclosingClass?.Name,
      IsGhost = m.IsGhost,
      SourceLine = TryGetLine(m),
      SourceColumn = TryGetCol(m),
      Calls = new List<string>()
    };
  }

  private string NormalizeFunctionKind(Function f) {
    var t = f.GetType().Name;
    if (t.Contains("Predicate", StringComparison.OrdinalIgnoreCase)) {
      return "predicate";
    }
    return "function";
  }

  private string NormalizeMethodKind(Method m) {
    var t = m.GetType().Name;
    if (t.Contains("Lemma", StringComparison.OrdinalIgnoreCase)) {
      return "lemma";
    }
    return "method";
  }

  // ============================================================
  // Call extraction
  // ============================================================

  private IEnumerable<string> ExtractFunctionCalls(Function f) {
    var seen = new HashSet<string>();

    foreach (var callObj in f.AllCalls ?? new List<FunctionCallExpr>()) {
      if (callObj?.Function == null) {
        continue;
      }
      var qn = BuildQualifiedName(callObj.Function);
      if (seen.Add(qn)) {
        yield return qn;
      }
    }

    foreach (var node in Traverse(f)) {
      if (node is FunctionCallExpr fc && fc.Function != null) {
        var qn = BuildQualifiedName(fc.Function);
        if (seen.Add(qn)) {
          yield return qn;
        }
      }
    }
  }

  private IEnumerable<string> ExtractMethodCalls(Method m) {
    var seen = new HashSet<string>();

    foreach (var node in Traverse(m)) {
      if (node is CallStmt cs && cs.Method != null) {
        var qn = BuildQualifiedName(cs.Method);
        if (seen.Add(qn)) {
          yield return qn;
        }
      }

      if (node is ApplySuffix app && app.MethodCallInfo != null) {
        var methodObj = TryGetPropertyOrField(app.MethodCallInfo, "Method");
        if (methodObj is MethodOrConstructor moc) {
          var qn = BuildQualifiedName(moc);
          if (seen.Add(qn)) {
            yield return qn;
          }
        }
      }
    }
  }

  // ============================================================
  // Ghost declarations
  // ============================================================
  private bool TryMakeGhostDeclarationRecord(object node, out GhostDeclarationRecord record) {
    record = null!;

    if (LooksLikeGhostConstantNode(node)) {
      record = new GhostDeclarationRecord {
        Kind = "constant",
        Name = TryGetFieldBackedName(node) ?? "<anonymous>",
        QualifiedContext = TryGetBetterQualifiedContext(node),
        SourceLine = TryGetLine(node),
        SourceColumn = TryGetCol(node)
      };
      return true;
    }

    if (LooksLikeGhostVariableNode(node)) {
      record = new GhostDeclarationRecord {
        Kind = "variable",
        Name = TryGetFieldBackedName(node) ?? "<anonymous>",
        QualifiedContext = TryGetBetterQualifiedContext(node),
        SourceLine = TryGetLine(node),
        SourceColumn = TryGetCol(node)
      };
      return true;
    }

    return false;
  }

  private bool HasTruthyPropertyOrField(object obj, string name) {
    var val = TryGetPropertyOrField(obj, name);
    return val is bool b && b;
  }

  private string TypeName(object obj) {
    return obj.GetType().Name;
  }

  private bool LooksLikeGhostVariableNode(object node) {
    var t = TypeName(node);

    // Keep this conservative:
    // - include local/field-like declarations
    // - exclude Formals and BoundVars to avoid overcounting
    if (t.Contains("LocalVariable", StringComparison.OrdinalIgnoreCase) ||
        t.Contains("Field", StringComparison.OrdinalIgnoreCase) ||
        t.Contains("VarDeclStmt", StringComparison.OrdinalIgnoreCase) ||
        t.Equals("VarDecl", StringComparison.OrdinalIgnoreCase)) {
      return HasTruthyPropertyOrField(node, "IsGhost");
    }

    return false;
  }

  private bool LooksLikeGhostConstantNode(object node) {
    var t = TypeName(node);

    // Constants are not always ghost in Dafny 4, so do not assume they are.
    // Only count constants that the AST itself marks as ghost.
    if (t.Contains("ConstantField", StringComparison.OrdinalIgnoreCase) ||
        t.Equals("Constant", StringComparison.OrdinalIgnoreCase) ||
        t.Contains("Const", StringComparison.OrdinalIgnoreCase)) {
      return HasTruthyPropertyOrField(node, "IsGhost");
    }

    return false;
  }

  private string? TryGetQualifiedContext(object node) {
    // Try callable-like enclosing context first
    var enclosingClass = TryGetPropertyOrField(node, "EnclosingClass");
    if (enclosingClass != null) {
      var className = TryGetName(enclosingClass);
      var mod = TryGetPropertyOrField(enclosingClass, "EnclosingModuleDefinition");
      if (mod is ModuleDefinition md1) {
        var modName = GetModuleName(md1);
        if (!string.IsNullOrWhiteSpace(modName) && !string.IsNullOrWhiteSpace(className)) {
          return $"{modName}.{className}";
        }
      }
      if (!string.IsNullOrWhiteSpace(className)) {
        return className;
      }
    }

    var enclosingModule = TryGetPropertyOrField(node, "EnclosingModuleDefinition");
    if (enclosingModule is ModuleDefinition md2) {
      return GetModuleName(md2);
    }

    // Some nodes may have an enclosing method/function owner through another field
    var owner = TryGetPropertyOrField(node, "EnclosingMember");
    if (owner is Function f) {
      return BuildQualifiedName(f);
    }
    if (owner is MethodOrConstructor m) {
      return BuildQualifiedName(m);
    }

    return null;
  }

  private string? TryGetName(object node) {
    var val = TryGetPropertyOrField(node, "Name");
    if (val is string s) {
      return s;
    }
    return null;
  }

  // ============================================================
  // Invariants
  // ============================================================

  private int CountInvariantClauses(object root) {
    int count = 0;

    foreach (var node in Traverse(root)) {
      var t = TypeName(node);

      // Count loop invariant clauses only
      if (t.Contains("WhileStmt", StringComparison.OrdinalIgnoreCase) ||
          t.Contains("AlternativeLoopStmt", StringComparison.OrdinalIgnoreCase) ||
          t.Contains("LoopStmt", StringComparison.OrdinalIgnoreCase)) {
        var invs = TryGetPropertyOrField(node, "Invariants");
        if (invs is IEnumerable enumerable) {
          foreach (var _ in enumerable) {
            count++;
          }
        }
      }
    }

    return count;
  }

  // ============================================================
  // Generic AST traversal helpers
  // ============================================================

  private IEnumerable<object> Traverse(object? root) {
    if (root == null) {
      yield break;
    }

    var seen = new HashSet<object>(ReferenceEqualityComparer.Instance);
    var stack = new Stack<object>();
    stack.Push(root);

    while (stack.Count > 0) {
      var cur = stack.Pop();
      if (!seen.Add(cur)) {
        continue;
      }

      yield return cur;

      foreach (var child in GetChildren(cur)) {
        if (child != null) {
          stack.Push(child);
        }
      }
    }
  }

  private IEnumerable<object> GetChildren(object node) {
    var childrenObj = TryGetPropertyOrField(node, "Children");
    if (childrenObj is IEnumerable enumerable && childrenObj is not string) {
      foreach (var item in enumerable) {
        if (item != null) {
          yield return item;
        }
      }
    }
  }

  private object? TryGetPropertyOrField(object obj, string name) {
    var t = obj.GetType();

    var prop = t.GetProperty(name);
    if (prop != null) {
      return prop.GetValue(obj);
    }

    var field = t.GetField(name);
    if (field != null) {
      return field.GetValue(obj);
    }

    return null;
  }

  // ============================================================
  // Qualified naming
  // ============================================================

  private string BuildQualifiedName(Function f) {
    var parts = new List<string>();
    var module = GetModuleName(f.EnclosingClass?.EnclosingModuleDefinition);
    if (!string.IsNullOrWhiteSpace(module)) {
      parts.Add(module);
    }
    if (!IsDefaultClass(f.EnclosingClass) && f.EnclosingClass != null) {
      parts.Add(f.EnclosingClass.Name);
    }
    parts.Add(f.Name);
    return string.Join(".", parts);
  }

  private string BuildQualifiedName(MethodOrConstructor m) {
    var parts = new List<string>();
    var module = GetModuleName(m.EnclosingClass?.EnclosingModuleDefinition);
    if (!string.IsNullOrWhiteSpace(module)) {
      parts.Add(module);
    }
    if (!IsDefaultClass(m.EnclosingClass) && m.EnclosingClass != null) {
      parts.Add(m.EnclosingClass.Name);
    }
    parts.Add(m.Name);
    return string.Join(".", parts);
  }

  private string? GetModuleName(ModuleDefinition? md) {
    if (md == null) {
      return null;
    }

    var p1 = md.GetType().GetProperty("Name");
    if (p1?.GetValue(md) is string s1 && !string.IsNullOrWhiteSpace(s1)) {
      return s1;
    }

    var p2 = md.GetType().GetProperty("DafnyName");
    if (p2?.GetValue(md) is string s2 && !string.IsNullOrWhiteSpace(s2)) {
      return s2;
    }

    return md.ToString();
  }

  private bool IsDefaultClass(TopLevelDecl? decl) {
    return decl != null && decl.GetType().Name == "DefaultClassDecl";
  }

  // ============================================================
  // Source location
  // ============================================================

  private int? TryGetLine(object node) {
    var tok = TryGetPropertyOrField(node, "StartToken");
    if (tok == null) {
      return null;
    }
    var line = TryGetPropertyOrField(tok, "line");
    if (line is int i) {
      return i;
    }
    return null;
  }

  private int? TryGetCol(object node) {
    var tok = TryGetPropertyOrField(node, "StartToken");
    if (tok == null) {
      return null;
    }
    var col = TryGetPropertyOrField(tok, "col");
    if (col is int i) {
      return i;
    }
    return null;
  }

  // ============================================================
  // Tarjan SCC
  // ============================================================

  private List<List<string>> Tarjan(List<CallableRecord> callables) {
    var byName = callables.ToDictionary(c => c.QualifiedName, c => c);

    var index = 0;
    var stack = new Stack<string>();
    var onStack = new HashSet<string>();
    var indices = new Dictionary<string, int>();
    var lowlink = new Dictionary<string, int>();
    var sccs = new List<List<string>>();

    void StrongConnect(string v) {
      indices[v] = index;
      lowlink[v] = index;
      index++;
      stack.Push(v);
      onStack.Add(v);

      foreach (var w in byName[v].Calls) {
        if (!indices.ContainsKey(w)) {
          StrongConnect(w);
          lowlink[v] = Math.Min(lowlink[v], lowlink[w]);
        } else if (onStack.Contains(w)) {
          lowlink[v] = Math.Min(lowlink[v], indices[w]);
        }
      }

      if (lowlink[v] == indices[v]) {
        var component = new List<string>();
        while (true) {
          var w = stack.Pop();
          onStack.Remove(w);
          component.Add(w);
          if (w == v) {
            break;
          }
        }
        sccs.Add(component);
      }
    }

    foreach (var c in callables.Select(c => c.QualifiedName)) {
      if (!indices.ContainsKey(c)) {
        StrongConnect(c);
      }
    }

    return sccs;
  }
}

// ============================================================
// JSON output records
// ============================================================

public sealed class AstExtractionResult {
  public string? DafnyVersionNote { get; set; }
  public int TotalCallables { get; set; }
  public List<CallableRecord> Callables { get; set; } = new();
  public List<string> DirectRecursive { get; set; } = new();
  public List<List<string>> MutualRecursiveGroups { get; set; } = new();
  public AstSummary Summary { get; set; } = new();
  public List<GhostDeclarationRecord> GhostDeclarations { get; set; } = new();
}

public sealed class AstSummary {
  public int GhostVariables { get; set; }
  public int GhostConstants { get; set; }
  public int LoopInvariantClauses { get; set; }
}

public sealed class CallableRecord {
  public string Kind { get; set; } = "";
  public string Name { get; set; } = "";
  public string QualifiedName { get; set; } = "";
  public string? ModuleName { get; set; }
  public string? EnclosingClass { get; set; }
  public bool IsGhost { get; set; }
  public int? SourceLine { get; set; }
  public int? SourceColumn { get; set; }
  public bool DafnyResolvedIsRecursive { get; set; }
  public List<string> Calls { get; set; } = new();
}

public sealed class GhostDeclarationRecord {
  public string Kind { get; set; } = "";
  public string Name { get; set; } = "";
  public string? QualifiedContext { get; set; }
  public int? SourceLine { get; set; }
  public int? SourceColumn { get; set; }
}

public sealed class ReferenceEqualityComparer : IEqualityComparer<object> {
  public static readonly ReferenceEqualityComparer Instance = new();
  public new bool Equals(object? x, object? y) => ReferenceEquals(x, y);
  public int GetHashCode(object obj) => System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(obj);
}