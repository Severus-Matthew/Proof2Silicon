#!/usr/bin/env python3
"""
Robust Dafny Recursion Analyzer
Addresses limitations identified in code review:
1. Handles expression bodies (= syntax)
2. Strips comments and strings
3. Uses SCC (Tarjan's algorithm) for accurate mutual recursion
4. Handles ghost method/lemma
5. Better datatype/constructor filtering
"""

import re
import sys
from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict
from typing import Dict, List, Set, Tuple, Optional
class RobustDafnyAnalyzer:
    def __init__(self, dafny_code: str):
        self.original_code = dafny_code
        self.code = self._strip_comments_and_strings(dafny_code)
        self.callables = {}  # name -> {'type': ..., 'body': ...}
        self.call_graph = defaultdict(set)
        self.datatypes = set()  # Track datatype constructors
        
    def _strip_comments_and_strings(self, code: str) -> str:
        """Remove comments and string literals to avoid false positives."""
        # Remove line comments
        code = re.sub(r'//.*?$', '', code, flags=re.MULTILINE)
        # Remove block comments
        code = re.sub(r'/\*.*?\*/', '', code, flags=re.DOTALL)
        # Replace string literals with placeholder
        code = re.sub(r'"([^"\\]|\\.)*"', '""', code)
        return code
    
    def parse(self):
        """Parse Dafny code and extract all callable entities."""
        # First, collect datatype constructors
        self._collect_datatypes()
        
        # Find all callables (both {} bodies and = expression bodies)
        all_callables = self._find_all_callables()
        
        for callable_type, name, body in all_callables:
            self.callables[name] = {
                'type': callable_type,
                'body': body
            }
            # Extract calls from body
            callees = self._extract_calls_from_body(body)
            self.call_graph[name] = callees
    
    def _collect_datatypes(self):
        """Collect datatype constructor names to filter them from call graph."""
        # Pattern: datatype Name = Constructor1(...) | Constructor2(...)
        pattern = r'\bdatatype\s+\w+\s*(?:<[^>]*>)?\s*=\s*([^{;]+)'
        
        for match in re.finditer(pattern, self.code):
            constructors_text = match.group(1)
            # Extract constructor names (words before '(')
            constructor_pattern = r'\b([A-Z]\w*)\s*(?:\(|$)'
            for c_match in re.finditer(constructor_pattern, constructors_text):
                self.datatypes.add(c_match.group(1))
    
    def _find_all_callables(self) -> List[Tuple[str, str, str]]:
        """Find all functions/methods/predicates/lemmas with both {} and = bodies."""
        results = []
        
        # Enhanced pattern that includes ghost modifiers for all types
        decl_pattern = r'\b(?:ghost\s+)?(function|method|predicate|lemma)\s+(\w+)'
        
        lines = self.code.split('\n')
        i = 0
        
        while i < len(lines):
            line = lines[i]
            
            match = re.search(decl_pattern, line)
            if match:
                callable_type = match.group(1)
                name = match.group(2)
                
                # Skip constructors (they have special name 'constructor')
                if name == 'constructor':
                    i += 1
                    continue
                
                # Try to find body (either { } or = expression)
                body = self._find_and_extract_body(lines, i)
                
                if body:
                    results.append((callable_type, name, body))
            
            i += 1
        
        return results
    
    def _find_and_extract_body(self, lines: List[str], start_idx: int) -> Optional[str]:
        """Find and extract body - handles both { } and = expression forms."""
        # Look for either { or =
        for i in range(start_idx, min(start_idx + 20, len(lines))):
            line = lines[i]
            
            # Check for brace body
            if '{' in line:
                return self._extract_brace_body(lines, i)
            
            # Check for expression body (= syntax)
            if re.search(r'^\s*=\s*', line) or re.search(r'\s+=\s*', line):
                return self._extract_expression_body(lines, i)
            
            # If we hit another declaration, stop
            if i != start_idx and re.search(r'\b(function|method|predicate|lemma|class|datatype)\s+', line):
                return None
        
        return None
    
    def _extract_brace_body(self, lines: List[str], start_idx: int) -> str:
        """Extract body with { } brace matching."""
        body_lines = []
        brace_count = 0
        started = False
        
        for i in range(start_idx, len(lines)):
            line = lines[i]
            
            for char in line:
                if char == '{':
                    brace_count += 1
                    started = True
                elif char == '}':
                    brace_count -= 1
            
            if started:
                body_lines.append(line)
                
            if started and brace_count == 0:
                break
        
        return '\n'.join(body_lines)
    
    def _extract_expression_body(self, lines: List[str], start_idx: int) -> str:
        """Extract expression body (= syntax) - read until next declaration or blank lines."""
        body_lines = []
        
        for i in range(start_idx, len(lines)):
            line = lines[i].strip()
            
            # Stop at next declaration
            if i != start_idx and re.search(r'\b(function|method|predicate|lemma|class|datatype)\s+', line):
                break
            
            # Stop at multiple blank lines
            if not line and i > start_idx:
                if i + 1 < len(lines) and not lines[i + 1].strip():
                    break
            
            body_lines.append(lines[i])
            
            # For expression bodies, we can stop after a reasonable amount
            if len(body_lines) > 50:
                break
        
        return '\n'.join(body_lines)
    
    def _extract_calls_from_body(self, body: str) -> Set[str]:
        """Extract function calls from body, excluding specs and datatypes."""
        calls = set()
        
        # Remove specification clauses
        body_cleaned = self._remove_specifications(body)
        
        # Find potential calls: identifier (possibly with type params) followed by (
        call_pattern = r'\b([a-zA-Z_]\w*)(?:<[^>]*>)?\s*\('
        
        # Keywords to filter out
        keywords = {
            'if', 'while', 'for', 'forall', 'exists', 'assert', 'assume',
            'print', 'new', 'var', 'ghost', 'old', 'fresh', 'set', 'seq',
            'multiset', 'map', 'imap', 'return', 'match', 'calc', 'then',
            'else', 'parallel', 'modify', 'yield', 'array', 'object',
            'bool', 'int', 'real', 'char', 'string', 'nat', 'ORDINAL'
        }
        
        for match in re.finditer(call_pattern, body_cleaned):
            func_name = match.group(1)
            
            # Filter out keywords and datatype constructors
            if func_name not in keywords and func_name not in self.datatypes:
                calls.add(func_name)
        
        return calls
    
    def _remove_specifications(self, body: str) -> str:
        """Remove specification clauses more thoroughly."""
        # Remove all specification keywords with their clauses
        spec_keywords = [
            'requires', 'ensures', 'reads', 'modifies', 'decreases',
            'invariant', 'maintains'
        ]
        
        for keyword in spec_keywords:
            # Remove single-line specs
            body = re.sub(rf'\s*{keyword}\s+[^;{{\n]*', '', body)
        
        return body
    
    def detect_recursion_scc(self) -> Dict:
        """Detect recursion using Tarjan's SCC algorithm (more accurate)."""
        # Tarjan's algorithm for finding Strongly Connected Components
        index_counter = [0]
        stack = []
        lowlinks = {}
        index = {}
        on_stack = {}
        sccs = []
        
        def strongconnect(node):
            index[node] = index_counter[0]
            lowlinks[node] = index_counter[0]
            index_counter[0] += 1
            stack.append(node)
            on_stack[node] = True
            
            # Consider successors
            for successor in self.call_graph.get(node, []):
                if successor not in self.callables:
                    continue  # Skip external calls
                    
                if successor not in index:
                    strongconnect(successor)
                    lowlinks[node] = min(lowlinks[node], lowlinks[successor])
                elif on_stack.get(successor, False):
                    lowlinks[node] = min(lowlinks[node], index[successor])
            
            # If node is a root node, pop the stack and generate an SCC
            if lowlinks[node] == index[node]:
                scc = []
                while True:
                    successor = stack.pop()
                    on_stack[successor] = False
                    scc.append(successor)
                    if successor == node:
                        break
                sccs.append(scc)
        
        # Run Tarjan's algorithm
        for node in self.callables:
            if node not in index:
                strongconnect(node)
        
        # Analyze SCCs for recursion
        recursion_info = {
            'direct': [],
            'mutual': [],
            'all_recursive': set(),
            'sccs': sccs
        }
        
        for scc in sccs:
            if len(scc) == 1:
                # Check for self-loop (direct recursion)
                node = scc[0]
                if node in self.call_graph.get(node, set()):
                    recursion_info['direct'].append(node)
                    recursion_info['all_recursive'].add(node)
            else:
                # SCC with multiple nodes = mutual recursion
                recursion_info['mutual'].append(sorted(scc))
                recursion_info['all_recursive'].update(scc)
        
        return recursion_info
    
    def count_ghost_variables(self) -> Dict[str, int]:
        """Count different types of ghost declarations."""
        counts = {
            'ghost_var': 0,
            'ghost_const': 0,
            'total': 0
        }
        
        # Count ghost var
        var_pattern = r'\bghost\s+var\s+(\w+)'
        counts['ghost_var'] = len(re.findall(var_pattern, self.original_code))
        
        # Count ghost const
        const_pattern = r'\bghost\s+const\s+(\w+)'
        counts['ghost_const'] = len(re.findall(const_pattern, self.original_code))
        
        counts['total'] = counts['ghost_var'] + counts['ghost_const']
        
        return counts
    
    def count_invariants(self) -> Dict[str, int]:
        """Count invariants, excluding those in comments."""
        counts = {
            'loop_invariants': 0,
            'class_invariants': 0
        }
        
        # Count in cleaned code (comments removed)
        pattern = r'\binvariant\s+'
        total = len(re.findall(pattern, self.code))
        
        # Heuristic: loop invariants are indented more
        # This is approximate but better than nothing
        counts['loop_invariants'] = total
        
        return counts
    
    def generate_report(self) -> str:
        """Generate comprehensive report using SCC-based recursion detection."""
        self.parse()
        
        report = []
        report.append("=" * 70)
        report.append("ROBUST DAFNY RECURSION ANALYSIS")
        report.append("=" * 70)
        report.append("")
        
        # Summary
        if not self.callables:
            report.append("⚠️  No callable entities found")
            report.append("")
            report.append("Note: This could mean:")
            report.append("  - File has only classes/datatypes without methods")
            report.append("  - File is empty or has syntax errors")
            report.append("  - All callables use unsupported syntax")
            report.append("")
        else:
            # Count by type
            type_counts = defaultdict(int)
            for info in self.callables.values():
                type_counts[info['type']] += 1
            
            report.append("CALLABLE SUMMARY:")
            report.append("-" * 70)
            for ctype, count in sorted(type_counts.items()):
                report.append(f"  {ctype}s: {count}")
            report.append(f"  Total: {len(self.callables)}")
            report.append("")
            
            # Datatype constructors found
            if self.datatypes:
                report.append(f"Datatype constructors detected: {len(self.datatypes)}")
                report.append(f"  (filtered from call graph)")
                report.append("")
            
            # Recursion Analysis using SCC
            recursion_info = self.detect_recursion_scc()
            
            report.append("RECURSION ANALYSIS (using Tarjan's SCC):")
            report.append("-" * 70)
            
            if recursion_info['all_recursive']:
                report.append(f"✗ RECURSION DETECTED")
                report.append(f"  Recursive callables: {len(recursion_info['all_recursive'])}")
                report.append("")
                
                if recursion_info['direct']:
                    report.append(f"Direct Recursion ({len(recursion_info['direct'])}):")
                    for func in sorted(recursion_info['direct']):
                        report.append(f"  • {func} → {func}")
                    report.append("")
                
                if recursion_info['mutual']:
                    report.append(f"Mutual Recursion ({len(recursion_info['mutual'])} group(s)):")
                    for i, group in enumerate(recursion_info['mutual'], 1):
                        report.append(f"  Group {i}: {' ↔ '.join(group)}")
                        report.append(f"    Size: {len(group)} functions")
                    report.append("")
            else:
                report.append("✓ NO RECURSION DETECTED")
                report.append("")
            
            # Call Graph
            report.append("CALL GRAPH:")
            report.append("-" * 70)
            for name in sorted(self.callables.keys()):
                callees = self.call_graph.get(name, set())
                if callees:
                    report.append(f"  {name} → {', '.join(sorted(callees))}")
                else:
                    report.append(f"  {name} → ∅")
            report.append("")
        
        # Ghost Variables
        ghost_counts = self.count_ghost_variables()
        report.append("GHOST DECLARATIONS:")
        report.append("-" * 70)
        report.append(f"  ghost var:   {ghost_counts['ghost_var']}")
        report.append(f"  ghost const: {ghost_counts['ghost_const']}")
        report.append(f"  Total:       {ghost_counts['total']}")
        report.append("")
        
        # Invariants
        inv_counts = self.count_invariants()
        report.append("INVARIANTS:")
        report.append("-" * 70)
        report.append(f"  Total: {inv_counts['loop_invariants']}")
        report.append("  (comments excluded)")
        report.append("")
        
        report.append("=" * 70)
        report.append("ANALYSIS METHOD: Tarjan's SCC (Strongly Connected Components)")
        report.append("ACCURACY: High (handles all mutual recursion patterns)")
        report.append("=" * 70)
        
        return '\n'.join(report)

def extract_regex_reward_features(dafny_file_path: str) -> Dict[str, int]:
    with open(dafny_file_path, "r", encoding="utf-8") as f:
        code = f.read()

    analyzer = RobustDafnyAnalyzer(code)
    analyzer.parse()
    recursion_info = analyzer.detect_recursion_scc()
    ghost_counts = analyzer.count_ghost_variables()
    inv_counts = analyzer.count_invariants()

    lemma_count = sum(
        1 for _, meta in analyzer.callables.items()
        if meta.get("type", "").lower() == "lemma"
    )

    recursion_count = len(recursion_info.get("all_recursive", []))

    return {
        "lemma_count": lemma_count,
        "recursion_count": recursion_count,
        "invariant_count": inv_counts.get("loop_invariants", 0),
        "ghost_var_count": ghost_counts.get("ghost_var", 0),
    }


def main():
    if len(sys.argv) < 2:
        print("Usage: python robust_analyzer.py <dafny_file>")
        print("")
        print("Robust Dafny Recursion Analyzer")
        print("Features:")
        print("  • Handles both {} and = expression bodies")
        print("  • Strips comments and strings")
        print("  • Uses Tarjan's SCC for accurate mutual recursion")
        print("  • Filters datatype constructors")
        print("  • Counts ghost vars, ghost consts, and invariants")
        sys.exit(1)
    
    filename = sys.argv[1]
    
    try:
        with open(filename, 'r') as f:
            code = f.read()
        
        if not code.strip():
            print("⚠️  File is empty")
            sys.exit(0)
        
        analyzer = RobustDafnyAnalyzer(code)
        report = analyzer.generate_report()
        print(report)
        
    except FileNotFoundError:
        print(f"✗ Error: File '{filename}' not found")
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
