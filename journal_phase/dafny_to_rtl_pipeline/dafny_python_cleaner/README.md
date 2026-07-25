# Dafny Python Cleaner

Deterministic source-to-source compiler for the Proof2Silicon pipeline:

```text
verified Dafny -> Dafny Python backend -> generated_python -> clean_python
```

The compiler is designed around recurring patterns found in the current
`generated_python` corpus:

- `_dafny`, `System_`, and `module_` runtime imports;
- generated `class default__` wrappers;
- `@staticmethod` methods containing the executable algorithms;
- named generated modules appended below `# Module: ...` markers;
- calls such as `Max.default__.ComputeMax(...)`;
- generated locals such as `d_0_i_`;
- array length expressions such as `arr.length(0)`;
- trivial constructors such as `int(0)`;
- generated `elif True:` branches.

## Run the full corpus

From the repository root:

```bash
python3 journal_phase/dafny_to_rtl_pipeline/dafny_python_cleaner/compiler.py
```

The default paths are:

```text
input:  journal_phase/dafny_to_rtl_pipeline/generated_python
output: journal_phase/dafny_to_rtl_pipeline/clean_python
```

The model hierarchy and filenames are preserved.

## Strict run

A normal run emits syntactically valid Python and marks outputs containing an
unmapped Dafny runtime symbol as `needs_review`. A strict run treats those
cases as failures:

```bash
python3 journal_phase/dafny_to_rtl_pipeline/dafny_python_cleaner/compiler.py \
  --fail-on-unsupported
```

## Compile one file

```bash
python3 journal_phase/dafny_to_rtl_pipeline/dafny_python_cleaner/compiler.py \
  --input journal_phase/dafny_to_rtl_pipeline/generated_python/deepseek-chat/Dafny_104_firstverified.py \
  --output /tmp/Dafny_104_clean.py
```

## Reports

The batch compiler writes:

```text
journal_phase/dafny_to_rtl_pipeline/manifests/dafny_python_cleaner.json
journal_phase/dafny_to_rtl_pipeline/manifests/dafny_python_cleaner.csv
```

Each record includes:

- source and output paths;
- `success`, `needs_review`, or `failed` status;
- Dafny modules discovered;
- function-name mappings;
- generated-local mappings;
- remaining unsupported runtime symbols;
- source and output SHA-256 hashes;
- syntax or compilation errors.

## Safety rule

The compiler fails closed. It does not erase an unknown `_dafny` or `System_`
operation. Such symbols remain visible and the file is marked `needs_review`,
so unsupported semantics cannot silently become an apparently successful clean
program.

## Current transformations

1. Split appended source into independent `# Module: NAME` sections.
2. Parse each section with Python AST.
3. Lift methods from each generated `default__` class.
4. Prefix named-module functions when needed to avoid collisions.
5. Rewrite qualified calls to the lifted functions.
6. Normalize generated local names.
7. Remove generated local type scaffolding.
8. Rewrite recognized Dafny runtime idioms to native Python.
9. Validate with `ast.parse` and `py_compile`.
10. Produce a complete manifest for unsupported patterns and failures.

This is the first deterministic compiler pass. The manifest from the full
corpus should be used to expand the runtime rewrite table without introducing
problem-specific rules.
