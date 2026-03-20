#!/usr/bin/env python3

import json
import sys
from collections import defaultdict


class DafnyASTAnalyzer:
    def __init__(self, json_data):
        self.data = json_data
        self.callables = json_data.get("Callables", [])
        self.summary = json_data.get("Summary", {})
        self.direct_recursive = json_data.get("DirectRecursive", [])
        self.mutual_recursive = json_data.get("MutualRecursiveGroups", [])
        self.ghost_decls = json_data.get("GhostDeclarations", [])

        # Build lookup
        self.callable_map = {
            c["QualifiedName"]: c for c in self.callables
        }

        self.call_graph = {
            c["QualifiedName"]: set(c.get("Calls", []))
            for c in self.callables
        }

    # --------------------------------------------------
    # Pretty report
    # --------------------------------------------------

    def generate_report(self):
        report = []
        report.append("=" * 70)
        report.append("DAFNY AST ANALYSIS REPORT")
        report.append("=" * 70)
        report.append("")

        self._add_callable_summary(report)
        self._add_recursion(report)
        self._add_call_graph(report)
        self._add_ghost_summary(report)
        self._add_invariant_summary(report)

        report.append("=" * 70)
        return "\n".join(report)

    # --------------------------------------------------
    # Sections
    # --------------------------------------------------

    def _add_callable_summary(self, report):
        report.append("CALLABLE SUMMARY:")
        report.append("-" * 70)

        type_counts = defaultdict(int)
        for c in self.callables:
            type_counts[c["Kind"]] += 1

        for t, count in sorted(type_counts.items()):
            report.append(f"  {t}s: {count}")

        report.append(f"  Total: {len(self.callables)}")
        report.append("")

    def _add_recursion(self, report):
        report.append("RECURSION ANALYSIS:")
        report.append("-" * 70)

        total_recursive = len(self.direct_recursive) + sum(len(g) for g in self.mutual_recursive)

        if total_recursive == 0:
            report.append("✓ NO RECURSION DETECTED\n")
            return

        report.append("✗ RECURSION DETECTED\n")

        if self.direct_recursive:
            report.append(f"Direct Recursion ({len(self.direct_recursive)}):")
            for f in sorted(self.direct_recursive):
                report.append(f"  • {f} → {f}")
            report.append("")

        if self.mutual_recursive:
            report.append(f"Mutual Recursion ({len(self.mutual_recursive)} group(s)):")
            for i, group in enumerate(self.mutual_recursive, 1):
                report.append(f"  Group {i}: {' ↔ '.join(group)}")
            report.append("")

    def _add_call_graph(self, report):
        report.append("CALL GRAPH:")
        report.append("-" * 70)

        for name in sorted(self.call_graph):
            callees = self.call_graph[name]
            if callees:
                report.append(f"  {name} → {', '.join(sorted(callees))}")
            else:
                report.append(f"  {name} → ∅")

        report.append("")

    def _add_ghost_summary(self, report):
        report.append("GHOST DECLARATIONS:")
        report.append("-" * 70)

        ghost_vars = self.summary.get("GhostVariables", 0)
        ghost_consts = self.summary.get("GhostConstants", 0)

        report.append(f"  ghost variables: {ghost_vars}")
        report.append(f"  ghost constants: {ghost_consts}")
        report.append("")

        # Optional: detailed list
        if self.ghost_decls:
            report.append("  Detailed:")
            for g in self.ghost_decls:
                ctx = g.get("QualifiedContext") or "<global>"
                name = g.get("Name")
                kind = g.get("Kind")
                report.append(f"    • [{kind}] {ctx}.{name}")
            report.append("")

    def _add_invariant_summary(self, report):
        report.append("LOOP INVARIANTS:")
        report.append("-" * 70)

        inv = self.summary.get("LoopInvariantClauses", 0)
        report.append(f"  Total loop invariant clauses: {inv}")
        report.append("")


# --------------------------------------------------
# Main
# --------------------------------------------------

def main():
    if len(sys.argv) < 2:
        print("Usage: python analyze_dafny_ast.py <json_file>")
        sys.exit(1)

    filename = sys.argv[1]

    try:
        with open(filename, "r") as f:
            data = json.load(f)

        analyzer = DafnyASTAnalyzer(data)
        print(analyzer.generate_report())

    except FileNotFoundError:
        print(f"Error: file '{filename}' not found")
    except json.JSONDecodeError:
        print("Error: invalid JSON file")
    except Exception as e:
        print(f"Error: {e}")

def extract_reward_features(json_data, filename):
    analyzer = DafnyASTAnalyzer(json_data)
    json_path= "/mnt/shared/gpfs/home/manvij2/journal_phase/ast_json/dafny-ast-output.json"
    recursion_count = len(analyzer.direct_recursive) + sum(
        len(group) for group in analyzer.mutual_recursive
    )
    #chnage the name of Json_path to the new one
    json_path = json_path.replace("dafny-ast-output.json", filename + ".json")

    return {
        "lemma_count": sum(
            1 for c in analyzer.callables if c.get("Kind", "").lower() == "lemma"
        ),
        "recursion_count": recursion_count,
        "invariant_count": analyzer.summary.get("LoopInvariantClauses", 0),
        "ghost_var_count": analyzer.summary.get("GhostVariables", 0),
    }

if __name__ == "__main__":
    main()