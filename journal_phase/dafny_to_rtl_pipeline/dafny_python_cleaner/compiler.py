#!/usr/bin/env python3
"""Deterministic Dafny-Python -> clean Python source-to-source compiler.

The Dafny Python backend emits a predictable runtime-oriented dialect:
  * imports of _dafny, System_, module_, and generated modules
  * one ``default__`` class per Dafny module
  * static methods that are the actual user algorithms
  * ``x.length(0)`` for array length
  * qualified calls such as ``Foo.default__.Bar(...)``
  * generated local names such as ``d_0_i_``

This compiler discovers every ``# Module: NAME`` section, lifts static methods
from ``default__`` to top-level functions, rewrites calls between generated
modules, removes Dafny runtime scaffolding where a native Python equivalent is
known, and validates every emitted file with ``ast.parse`` and ``py_compile``.

It intentionally fails closed: unsupported runtime symbols are reported in the
manifest instead of being silently translated incorrectly.
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
from collections import Counter, defaultdict
from pathlib import Path


MODULE_MARKER_RE = re.compile(r"^# Module:\s*([^\s]+)\s*$", re.MULTILINE)
APPENDED_HEADER_RE = re.compile(
    r"^# =+\n# Appended from Dafny-generated file: .*?\n# =+\n",
    re.MULTILINE,
)

RUNTIME_IMPORT_RE = re.compile(
    r"^(?:import|from)\s+(?:_dafny|System_|module_)(?:\s|\.|$).*?$",
    re.MULTILINE,
)
GENERATED_IMPORT_RE = re.compile(
    r"^import\s+([A-Za-z_]\w*)\s+as\s+\1\s*$",
    re.MULTILINE,
)

# Known, semantics-preserving runtime rewrites.
SIMPLE_REWRITES = [
    (re.compile(r"\(([^()\n]+)\)\.length\(0\)"), r"len(\1)"),
    (re.compile(r"\b([A-Za-z_]\w*)\.length\(0\)"), r"len(\1)"),
    (re.compile(r"\b_dafny\.euclidian_division\(([^,]+),\s*([^\)]+)\)"), r"(\1 // \2)"),
    (re.compile(r"\b_dafny\.euclidian_modulus\(([^,]+),\s*([^\)]+)\)"), r"(\1 % \2)"),
    (re.compile(r"\b_dafny\.SeqWithoutIsStrInference\(([^\)]*)\)"), r"list(\1)"),
    (re.compile(r"\b_dafny\.Seq\(([^\)]*)\)"), r"list(\1)"),
    (re.compile(r"\b_dafny\.Set\(([^\)]*)\)"), r"set(\1)"),
    (re.compile(r"\b_dafny\.Map\(([^\)]*)\)"), r"dict(\1)"),
    (re.compile(r"\bint\(0\)"), "0"),
    (re.compile(r"\bbool\(False\)"), "False"),
    (re.compile(r"\bbool\(True\)"), "True"),
    (re.compile(r"\bstr\(\"\"\)"), '""'),
]

UNSUPPORTED_RUNTIME_RE = re.compile(r"\b(?:_dafny|System_)\.[A-Za-z_]\w*")
GENERATED_LOCAL_RE = re.compile(r"\bd_\d+_([A-Za-z_]\w*?)_\b")


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
    """Return ordered ``(module_name, source_section)`` pairs."""
    matches = list(MODULE_MARKER_RE.finditer(source))
    sections = []
    for index, match in enumerate(matches):
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(source)
        name = match.group(1)
        section = source[start:end]
        section = APPENDED_HEADER_RE.sub("", section)
        sections.append((name, section))
    return sections


def class_default_static_methods(section):
    """Find static methods inside generated ``class default__`` using AST."""
    try:
        tree = ast.parse(section)
    except SyntaxError:
        return [], None

    methods = []
    default_class = None
    for node in tree.body:
        if isinstance(node, ast.ClassDef) and node.name == "default__":
            default_class = node
            for child in node.body:
                if isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    methods.append(child)
            break
    return methods, default_class


def line_offsets(text):
    offsets = [0]
    for match in re.finditer("\n", text):
        offsets.append(match.end())
    return offsets


def node_span(text, node):
    """Return character offsets for an AST node (Python 3.6 compatible)."""
    offsets = line_offsets(text)
    start = offsets[node.lineno - 1] + node.col_offset
    end_lineno = getattr(node, "end_lineno", None)
    end_col = getattr(node, "end_col_offset", None)
    if end_lineno is not None and end_col is not None:
        end = offsets[end_lineno - 1] + end_col
        return start, end

    # Python 3.6 fallback: scan until indentation returns to class level.
    lines = text.splitlines(True)
    base = node.col_offset
    end_line = node.lineno
    for index in range(node.lineno, len(lines)):
        line = lines[index]
        stripped = line.lstrip()
        if not stripped:
            end_line = index + 1
            continue
        indent = len(line) - len(stripped)
        if indent <= base and not stripped.startswith(("@", "#")):
            break
        end_line = index + 1
    end = sum(len(line) for line in lines[:end_line])
    return start, end


def dedent_block(block, spaces=4):
    output = []
    for line in block.splitlines():
        if line.startswith(" " * spaces):
            line = line[spaces:]
        output.append(line.rstrip())
    return "\n".join(output).rstrip() + "\n"


def extract_lifted_methods(module_name, section):
    methods, _ = class_default_static_methods(section)
    if not methods:
        return [], {}

    lifted = []
    mapping = {}
    seen_names = Counter()

    for node in methods:
        start, end = node_span(section, node)
        block = section[start:end]

        # Include decorators immediately above the function when present.
        lines = section[:start].splitlines(True)
        while lines and lines[-1].strip().startswith("@"):
            decorator = lines.pop()
            start -= len(decorator)
            block = decorator + block

        block = dedent_block(block)
        block = re.sub(r"^\s*@staticmethod\s*\n", "", block, flags=re.MULTILINE)

        original = node.name
        base = snake_case(original)
        seen_names[base] += 1
        clean = base if seen_names[base] == 1 else "{}_{}".format(base, seen_names[base])

        # module_ is the ordinary top-level Dafny module. Named modules receive
        # a prefix only when needed to prevent collisions during flattening.
        if module_name != "module_":
            clean = "{}_{}".format(snake_case(module_name), clean)

        block = re.sub(
            r"^(\s*(?:async\s+)?def\s+){}\b".format(re.escape(original)),
            r"\1{}".format(clean),
            block,
            count=1,
            flags=re.MULTILINE,
        )
        mapping[original] = clean
        lifted.append(block)

    return lifted, mapping


def build_global_method_map(sections):
    module_maps = {}
    all_unqualified = defaultdict(list)
    lifted_by_module = {}

    for module_name, section in sections:
        lifted, mapping = extract_lifted_methods(module_name, section)
        module_maps[module_name] = mapping
        lifted_by_module[module_name] = lifted
        for old, new in mapping.items():
            all_unqualified[old].append(new)

    unique_unqualified = {
        old: names[0] for old, names in all_unqualified.items() if len(names) == 1
    }
    return module_maps, unique_unqualified, lifted_by_module


def rewrite_calls(text, module_maps, unique_unqualified):
    # Qualified generated calls: Foo.default__.Bar(...)
    for module_name, mapping in module_maps.items():
        for old, new in mapping.items():
            text = re.sub(
                r"\b{}\.default__\.{}\b".format(
                    re.escape(module_name), re.escape(old)
                ),
                new,
                text,
            )

    # Calls within one generated default__ class often appear as default__.Foo.
    for old, new in unique_unqualified.items():
        text = re.sub(
            r"\bdefault__\.{}\b".format(re.escape(old)),
            new,
            text,
        )

    return text


def rewrite_generated_locals(text):
    replacements = {}
    used = Counter()

    def repl(match):
        original = match.group(0)
        if original in replacements:
            return replacements[original]
        base = safe_identifier(match.group(1))
        used[base] += 1
        clean = base if used[base] == 1 else "{}_{}".format(base, used[base])
        replacements[original] = clean
        return clean

    return GENERATED_LOCAL_RE.sub(repl, text), replacements


def remove_type_annotations(text):
    # Generated local annotations occur as ``name: int`` or ``name: Type``.
    # Keep function signatures unchanged; strip only standalone local annotations
    # and annotation portions of initialized assignments.
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


def simplify_control_flow(text):
    text = re.sub(r"^(\s*)elif\s+True\s*:", r"\1else:", text, flags=re.MULTILINE)
    text = re.sub(r"\(([_A-Za-z]\w*)\)", r"\1", text)
    return text


def compile_source(source, source_name="<memory>"):
    sections = split_module_sections(source)
    if not sections:
        raise ValueError("No '# Module:' sections found in {}".format(source_name))

    module_maps, unique_unqualified, lifted_by_module = build_global_method_map(sections)

    chunks = [
        '"""Clean Python generated deterministically from Dafny Python."""',
        "",
        "from math import floor",
        "",
    ]

    for module_name, _section in sections:
        methods = lifted_by_module.get(module_name, [])
        if not methods:
            continue
        chunks.append("# Dafny module: {}".format(module_name))
        chunks.extend(methods)
        chunks.append("")

    clean = "\n".join(chunks)
    clean = RUNTIME_IMPORT_RE.sub("", clean)
    clean = GENERATED_IMPORT_RE.sub("", clean)
    clean = rewrite_calls(clean, module_maps, unique_unqualified)
    clean, local_map = rewrite_generated_locals(clean)
    clean = remove_type_annotations(clean)

    for pattern, replacement in SIMPLE_REWRITES:
        clean = pattern.sub(replacement, clean)

    clean = simplify_control_flow(clean)
    clean = re.sub(r"\n{3,}", "\n\n", clean).strip() + "\n"

    unsupported = sorted(set(UNSUPPORTED_RUNTIME_RE.findall(clean)))
    ast.parse(clean, filename=source_name)

    metadata = {
        "modules": [name for name, _ in sections],
        "module_method_map": module_maps,
        "generated_local_map": local_map,
        "unsupported_runtime_symbols": unsupported,
        "source_sha256": sha256_text(source),
        "output_sha256": sha256_text(clean),
    }
    return clean, metadata


def compile_file(source_path, output_path):
    source = source_path.read_text(encoding="utf-8", errors="replace")
    clean, metadata = compile_source(source, str(source_path))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(clean, encoding="utf-8")

    py_compile.compile(str(output_path), doraise=True)
    cache_dir = output_path.parent / "__pycache__"
    if cache_dir.exists():
        shutil.rmtree(str(cache_dir))
    return metadata


def compile_tree(input_root, output_root, manifest_json, manifest_csv, fail_on_unsupported=False):
    records = []
    totals = Counter()

    for source_path in sorted(input_root.rglob("*.py")):
        relative = source_path.relative_to(input_root)
        output_path = output_root / relative
        record = {
            "source": str(source_path),
            "output": str(output_path),
            "status": "failed",
            "error": None,
            "unsupported_runtime_symbols": [],
            "modules": [],
        }
        try:
            metadata = compile_file(source_path, output_path)
            record.update(metadata)
            record["status"] = "success"
            if metadata["unsupported_runtime_symbols"]:
                record["status"] = "needs_review"
                if fail_on_unsupported:
                    raise RuntimeError(
                        "Unsupported Dafny runtime symbols: {}".format(
                            ", ".join(metadata["unsupported_runtime_symbols"])
                        )
                    )
        except Exception as exc:
            record["error"] = "{}: {}".format(type(exc).__name__, exc)
            if output_path.exists():
                output_path.unlink()

        totals[record["status"]] += 1
        records.append(record)
        print("{:<12} {}".format(record["status"].upper(), relative))

    manifest = {
        "input_root": str(input_root),
        "output_root": str(output_root),
        "total": len(records),
        "status_counts": dict(totals),
        "records": records,
    }
    manifest_json.parent.mkdir(parents=True, exist_ok=True)
    manifest_json.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    fields = [
        "source", "output", "status", "error", "modules",
        "unsupported_runtime_symbols", "source_sha256", "output_sha256",
    ]
    with manifest_csv.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for record in records:
            row = {key: record.get(key) for key in fields}
            row["modules"] = ";".join(record.get("modules", []))
            row["unsupported_runtime_symbols"] = ";".join(
                record.get("unsupported_runtime_symbols", [])
            )
            writer.writerow(row)

    return 0 if totals["failed"] == 0 else 2


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Compile Dafny-generated Python into clean native Python."
    )
    parser.add_argument(
        "--input",
        default="journal_phase/dafny_to_rtl_pipeline/generated_python",
        help="Input file or directory.",
    )
    parser.add_argument(
        "--output",
        default="journal_phase/dafny_to_rtl_pipeline/clean_python",
        help="Output file or directory.",
    )
    parser.add_argument(
        "--manifest-json",
        default="journal_phase/dafny_to_rtl_pipeline/manifests/dafny_python_cleaner.json",
    )
    parser.add_argument(
        "--manifest-csv",
        default="journal_phase/dafny_to_rtl_pipeline/manifests/dafny_python_cleaner.csv",
    )
    parser.add_argument(
        "--fail-on-unsupported",
        action="store_true",
        help="Treat remaining _dafny/System_ symbols as hard failures.",
    )
    args = parser.parse_args(argv)

    input_path = Path(args.input).resolve()
    output_path = Path(args.output).resolve()

    if input_path.is_file():
        metadata = compile_file(input_path, output_path)
        print(json.dumps(metadata, indent=2))
        return 0

    if not input_path.is_dir():
        parser.error("Input does not exist: {}".format(input_path))

    return compile_tree(
        input_path,
        output_path,
        Path(args.manifest_json).resolve(),
        Path(args.manifest_csv).resolve(),
        args.fail_on_unsupported,
    )


if __name__ == "__main__":
    sys.exit(main())
