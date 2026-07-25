#!/usr/bin/env python3
"""Corpus compiler for Dafny-generated Python -> native clean Python.

This revision fixes two correctness bugs in the first compiler:
1. it never removes parentheses globally (the old rule changed ``def f(x):``
   into invalid ``def fx:``);
2. it rejects empty outputs instead of treating a header-only file as success.

The implementation is Python 3.6 compatible because DeltaAI currently uses
Python 3.6 for this pipeline.
"""
from __future__ import print_function

import argparse
import ast
import csv
import hashlib
import json
import keyword
import py_compile
import re
import shutil
import sys
import textwrap
from collections import Counter, defaultdict
from pathlib import Path

MODULE_MARKER_RE = re.compile(r"^# Module:\s*([^\s]+)\s*$", re.MULTILINE)
GENERATED_LOCAL_RE = re.compile(r"\bd_\d+_([A-Za-z_]\w*?)_\b")
UNSUPPORTED_RUNTIME_RE = re.compile(r"\b(?:_dafny|System_)\.[A-Za-z_]\w*")


def safe_identifier(name):
    name = re.sub(r"\W+", "_", name)
    name = re.sub(r"_+", "_", name).strip("_") or "value"
    if name[0].isdigit():
        name = "v_" + name
    if keyword.iskeyword(name):
        name += "_"
    return name


def snake_case(name):
    name = re.sub(r"(.)([A-Z][a-z]+)", r"\1_\2", name)
    name = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", name)
    return safe_identifier(name.lower())


def sha256_text(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def split_module_sections(source):
    matches = list(MODULE_MARKER_RE.finditer(source))
    sections = []
    for i, match in enumerate(matches):
        start = match.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(source)
        sections.append((match.group(1), source[start:end]))
    return sections


def parse_default_class(section):
    tree = ast.parse(section)
    for node in tree.body:
        if isinstance(node, ast.ClassDef) and node.name == "default__":
            return node
    return None


def block_for_method(section, class_node, method_index, method_nodes):
    """Extract one complete method without relying on end_lineno.

    Python 3.6 AST nodes do not carry end_lineno.  The next method/class child
    gives a reliable upper boundary; for the final method we scan until the
    indentation leaves the generated class.
    """
    lines = section.splitlines(True)
    node = method_nodes[method_index]

    start_line = node.lineno
    if getattr(node, "decorator_list", None):
        start_line = min([d.lineno for d in node.decorator_list] + [start_line])

    if method_index + 1 < len(method_nodes):
        end_line = method_nodes[method_index + 1].lineno - 1
        next_node = method_nodes[method_index + 1]
        if getattr(next_node, "decorator_list", None):
            end_line = min(d.lineno for d in next_node.decorator_list) - 1
    else:
        end_line = len(lines)
        class_indent = class_node.col_offset
        for idx in range(node.lineno, len(lines)):
            line = lines[idx]
            stripped = line.lstrip()
            if not stripped:
                continue
            indent = len(line) - len(stripped)
            if indent <= class_indent:
                end_line = idx
                break

    block = "".join(lines[start_line - 1:end_line])
    block = textwrap.dedent(block).rstrip() + "\n"
    block = re.sub(r"^\s*@staticmethod\s*\n", "", block, flags=re.MULTILINE)
    return block


def extract_methods(module_name, section):
    class_node = parse_default_class(section)
    if class_node is None:
        return [], {}

    methods = [
        child for child in class_node.body
        if isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef))
        and child.name != "__init__"
    ]

    lifted = []
    mapping = {}
    seen = Counter()

    for index, node in enumerate(methods):
        block = block_for_method(section, class_node, index, methods)
        original = node.name
        base = snake_case(original)
        if module_name != "module_":
            base = "{}_{}".format(snake_case(module_name), base)
        seen[base] += 1
        clean_name = base if seen[base] == 1 else "{}_{}".format(base, seen[base])

        block = re.sub(
            r"^(\s*(?:async\s+)?def\s+){}\b".format(re.escape(original)),
            r"\1{}".format(clean_name),
            block,
            count=1,
            flags=re.MULTILINE,
        )
        lifted.append(block)
        mapping[original] = clean_name

    return lifted, mapping


def build_maps(sections):
    maps = {}
    lifted = {}
    unqualified = defaultdict(list)
    for module_name, section in sections:
        methods, mapping = extract_methods(module_name, section)
        maps[module_name] = mapping
        lifted[module_name] = methods
        for old, new in mapping.items():
            unqualified[old].append(new)
    unique = dict((old, names[0]) for old, names in unqualified.items() if len(names) == 1)
    return maps, unique, lifted


def rewrite_calls(text, module_maps, unique):
    for module_name, mapping in module_maps.items():
        for old, new in mapping.items():
            text = re.sub(
                r"\b{}\.default__\.{}\b".format(re.escape(module_name), re.escape(old)),
                new,
                text,
            )
    for old, new in unique.items():
        text = re.sub(r"\bdefault__\.{}\b".format(re.escape(old)), new, text)
    return text


def rewrite_locals(text):
    replacements = {}
    used = Counter()

    def replace(match):
        original = match.group(0)
        if original in replacements:
            return replacements[original]
        base = safe_identifier(match.group(1))
        used[base] += 1
        clean = base if used[base] == 1 else "{}_{}".format(base, used[base])
        replacements[original] = clean
        return clean

    return GENERATED_LOCAL_RE.sub(replace, text), replacements


def remove_local_annotations(text):
    text = re.sub(
        r"^(\s+)([A-Za-z_]\w*)\s*:\s*[^=\n]+$",
        r"\1\2 = None",
        text,
        flags=re.MULTILINE,
    )
    text = re.sub(
        r"^(\s+)([A-Za-z_]\w*)\s*:\s*[^=\n]+\s*=",
        r"\1\2 =",
        text,
        flags=re.MULTILINE,
    )
    return text


def rewrite_runtime(text):
    # Array lengths.  Keep this deliberately narrow and syntax-safe.
    text = re.sub(r"\(([^()\n]+)\)\.length\(0\)", r"len(\1)", text)
    text = re.sub(r"\b([A-Za-z_]\w*)\.length\(0\)", r"len(\1)", text)

    replacements = [
        (r"\b_dafny\.euclidian_division\(([^,]+),\s*([^\)]+)\)", r"(\1 // \2)"),
        (r"\b_dafny\.euclidian_modulus\(([^,]+),\s*([^\)]+)\)", r"(\1 % \2)"),
        (r"\b_dafny\.SeqWithoutIsStrInference\(([^\)]*)\)", r"list(\1)"),
        (r"\b_dafny\.Seq\(([^\)]*)\)", r"list(\1)"),
        (r"\b_dafny\.Set\(([^\)]*)\)", r"set(\1)"),
        (r"\b_dafny\.Map\(([^\)]*)\)", r"dict(\1)"),
        (r"\bint\(0\)", "0"),
        (r"\bbool\(False\)", "False"),
        (r"\bbool\(True\)", "True"),
        (r"\bstr\(\"\"\)", '\"\"'),
    ]
    for pattern, replacement in replacements:
        text = re.sub(pattern, replacement, text)

    text = re.sub(r"^(\s*)elif\s+True\s*:", r"\1else:", text, flags=re.MULTILINE)
    return text


def compile_source(source, source_name="<memory>"):
    sections = split_module_sections(source)
    if not sections:
        raise ValueError("No '# Module:' sections found")

    module_maps, unique, lifted = build_maps(sections)
    algorithm_count = sum(len(items) for items in lifted.values())
    if algorithm_count == 0:
        raise ValueError("No executable methods found in generated default__ classes")

    chunks = [
        '\"\"\"Clean Python generated deterministically from Dafny Python.\"\"\"',
        "",
        "from math import floor",
        "",
    ]
    for module_name, _section in sections:
        methods = lifted.get(module_name, [])
        if methods:
            chunks.append("# Dafny module: {}".format(module_name))
            chunks.extend(methods)
            chunks.append("")

    clean = "\n".join(chunks)
    clean = rewrite_calls(clean, module_maps, unique)
    clean, local_map = rewrite_locals(clean)
    clean = remove_local_annotations(clean)
    clean = rewrite_runtime(clean)
    clean = re.sub(r"\n{3,}", "\n\n", clean).strip() + "\n"

    unsupported = sorted(set(UNSUPPORTED_RUNTIME_RE.findall(clean)))
    ast.parse(clean, filename=source_name)

    return clean, {
        "modules": [name for name, _ in sections],
        "module_method_map": module_maps,
        "generated_local_map": local_map,
        "unsupported_runtime_symbols": unsupported,
        "algorithm_count": algorithm_count,
        "source_sha256": sha256_text(source),
        "output_sha256": sha256_text(clean),
    }


def compile_file(source_path, output_path):
    source = source_path.read_text(encoding="utf-8", errors="replace")
    clean, metadata = compile_source(source, str(source_path))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(clean, encoding="utf-8")
    py_compile.compile(str(output_path), doraise=True)
    cache = output_path.parent / "__pycache__"
    if cache.exists():
        shutil.rmtree(str(cache))
    return metadata


def compile_tree(input_root, output_root, manifest_json, manifest_csv, strict=False):
    if output_root.exists():
        shutil.rmtree(str(output_root))
    output_root.mkdir(parents=True, exist_ok=True)

    records = []
    counts = Counter()
    for source in sorted(input_root.rglob("*.py")):
        relative = source.relative_to(input_root)
        output = output_root / relative
        record = {"source": str(source), "output": str(output)}
        try:
            metadata = compile_file(source, output)
            record.update(metadata)
            if metadata["unsupported_runtime_symbols"]:
                record["status"] = "needs_review"
                if strict:
                    output.unlink()
            else:
                record["status"] = "success"
            record["error"] = None
        except Exception as exc:
            record["status"] = "failed"
            record["error"] = "{}: {}".format(type(exc).__name__, exc)
            record["unsupported_runtime_symbols"] = []
            if output.exists():
                output.unlink()
        counts[record["status"]] += 1
        records.append(record)

    report = {
        "input_root": str(input_root),
        "output_root": str(output_root),
        "total": len(records),
        "status_counts": dict(counts),
        "records": records,
    }
    manifest_json.parent.mkdir(parents=True, exist_ok=True)
    manifest_json.write_text(json.dumps(report, indent=2), encoding="utf-8")

    fields = ["source", "output", "status", "error", "algorithm_count", "unsupported_runtime_symbols", "modules"]
    with manifest_csv.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for record in records:
            row = dict((field, record.get(field)) for field in fields)
            row["unsupported_runtime_symbols"] = ";".join(record.get("unsupported_runtime_symbols", []))
            row["modules"] = ";".join(record.get("modules", []))
            writer.writerow(row)
    return report


def main():
    here = Path(__file__).resolve()
    pipeline = here.parents[1]
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, default=pipeline / "generated_python")
    parser.add_argument("--output", type=Path, default=pipeline / "clean_python")
    parser.add_argument("--manifest-json", type=Path, default=pipeline / "manifests" / "dafny_python_cleaner_v2.json")
    parser.add_argument("--manifest-csv", type=Path, default=pipeline / "manifests" / "dafny_python_cleaner_v2.csv")
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()

    report = compile_tree(args.input, args.output, args.manifest_json, args.manifest_csv, args.strict)
    print("Total:", report["total"])
    print("Status counts:", report["status_counts"])
    print("JSON manifest:", args.manifest_json)
    print("CSV manifest:", args.manifest_csv)
    return 0 if report["status_counts"].get("failed", 0) == 0 else 2


if __name__ == "__main__":
    sys.exit(main())
