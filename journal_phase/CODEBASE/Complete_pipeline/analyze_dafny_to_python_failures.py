#!/usr/bin/env python3

import csv
import json
import re
from collections import Counter, defaultdict
from pathlib import Path


JOURNAL_PHASE = Path("/u/mjha1/Proof2Silicon/journal_phase")
PIPELINE_DIR = JOURNAL_PHASE / "dafny_to_rtl_pipeline"

MANIFEST_PATH = (
    PIPELINE_DIR
    / "manifests"
    / "dafny_to_python_manifest.json"
)

RAW_ROOT = PIPELINE_DIR / "generated_python_raw"
OUTPUT_ROOT = PIPELINE_DIR / "generated_python"
LOG_ROOT = PIPELINE_DIR / "logs" / "dafny_to_python"

REPORT_DIR = PIPELINE_DIR / "failure_analysis"
REPORT_JSON = REPORT_DIR / "dafny_to_python_failure_analysis.json"
REPORT_CSV = REPORT_DIR / "dafny_to_python_failure_analysis.csv"
SUMMARY_TXT = REPORT_DIR / "dafny_to_python_failure_summary.txt"


def read_text(path):
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return ""


def locate_module(model, task):
    """
    Search all plausible Dafny Python output locations.
    """
    model_root = RAW_ROOT / model

    preferred = [
        model_root / (task + "-py") / "module_.py",
        model_root / task / "module_.py",
        model_root / "module_.py",
    ]

    for candidate in preferred:
        if candidate.is_file():
            return candidate

    if model_root.exists():
        matches = sorted(model_root.rglob("module_.py"))

        for match in matches:
            if task in str(match.parent):
                return match

    return None


def extract_error_lines(log_text):
    """
    Extract the most informative error-related lines from a Dafny log.
    """
    selected = []

    patterns = [
        r"\berror\b",
        r"unsupported",
        r"not supported",
        r"cannot compile",
        r"not compilable",
        r"compilation failed",
        r"resolution/type errors",
        r"parse errors",
        r"translation failed",
        r"invalid",
        r"exception",
        r"internal error",
        r"unhandled",
    ]

    compiled = [
        re.compile(pattern, re.IGNORECASE)
        for pattern in patterns
    ]

    lines = log_text.splitlines()

    for index, line in enumerate(lines):
        if any(pattern.search(line) for pattern in compiled):
            start = max(0, index - 1)
            end = min(len(lines), index + 3)

            for nearby_line in lines[start:end]:
                cleaned = nearby_line.strip()

                if cleaned and cleaned not in selected:
                    selected.append(cleaned)

        if len(selected) >= 20:
            break

    return selected[:20]


def classify_failure(return_code, module_path, log_text, error_lines):
    lower = log_text.lower()

    # The translation succeeded, and the expected generated source exists.
    if return_code == 0 and module_path is not None:
        return (
            "false_failure_module_exists",
            "Dafny succeeded and module_.py exists; the earlier script "
            "misclassified this result."
        )

    # Dafny says success, but no implementation file can be found.
    if return_code == 0:
        return (
            "successful_command_but_no_module",
            "Dafny returned 0, but module_.py could not be found."
        )

    if return_code == 3:
        if "unsupported" in lower or "not supported" in lower:
            return (
                "python_backend_unsupported_construct",
                "The Python backend reported an unsupported Dafny construct."
            )

        if "cannot be compiled" in lower or "not compilable" in lower:
            return (
                "non_compilable_dafny_construct",
                "The verified Dafny program contains a construct that is "
                "not executable or compilable."
            )

        if "ghost" in lower:
            return (
                "ghost_compilation_issue",
                "A ghost-only value, declaration, or construct affected "
                "compiled code."
            )

        if "method must have a body" in lower:
            return (
                "missing_compiled_body",
                "A compiled method or function has no executable body."
            )

        if "newtype" in lower:
            return (
                "newtype_compilation_issue",
                "The Python backend encountered a newtype-related "
                "compilation restriction."
            )

        if "extern" in lower:
            return (
                "extern_compilation_issue",
                "The program contains an extern declaration that the "
                "Python backend could not compile."
            )

        if "nondetermin" in lower:
            return (
                "nondeterministic_construct",
                "The program contains a nondeterministic construct that "
                "cannot be translated normally."
            )

        if "datatype" in lower:
            return (
                "datatype_compilation_issue",
                "The Python backend encountered a datatype-related "
                "compilation restriction."
            )

        if "iterator" in lower:
            return (
                "iterator_compilation_issue",
                "The Python backend encountered an unsupported or invalid "
                "iterator construct."
            )

        if "internal error" in lower or "exception" in lower:
            return (
                "dafny_internal_error",
                "Dafny or its Python backend encountered an internal error."
            )

        return (
            "generic_compilation_error",
            "Dafny returned compilation error code 3. Inspect the extracted "
            "error message for the precise construct."
        )

    if return_code == 2:
        return (
            "parse_resolution_or_type_error",
            "The file has a parsing, name-resolution, or type-resolution "
            "error during this invocation."
        )

    if return_code == 4:
        return (
            "verification_error",
            "Dafny reported verification failure. This would be unexpected "
            "with --no-verify unless another project setting changed it."
        )

    if return_code == 1:
        return (
            "command_line_error",
            "Dafny rejected one or more command-line arguments."
        )

    return (
        "unknown_nonzero_return_code",
        "Dafny returned an unrecognized nonzero status."
    )


def normalize_error_signature(error_lines):
    """
    Produce a compact signature so equivalent errors can be grouped.
    """
    if not error_lines:
        return "NO_ERROR_TEXT_FOUND"

    for line in error_lines:
        lower = line.lower()

        if (
            "error" in lower
            or "unsupported" in lower
            or "cannot" in lower
            or "exception" in lower
        ):
            signature = line

            # Remove file-specific source locations.
            signature = re.sub(
                r"\([^)]*\.dfy[^)]*\)",
                "(SOURCE_LOCATION)",
                signature,
            )
            signature = re.sub(
                r"[^ ]+\.dfy\(\d+,\d+\)",
                "SOURCE_LOCATION",
                signature,
            )
            signature = re.sub(
                r"line \d+",
                "line N",
                signature,
                flags=re.IGNORECASE,
            )

            return signature[:500]

    return error_lines[0][:500]


def main():
    if not MANIFEST_PATH.exists():
        raise SystemExit(
            "Manifest not found: {}".format(MANIFEST_PATH)
        )

    with MANIFEST_PATH.open("r", encoding="utf-8") as file:
        manifest = json.load(file)

    records = manifest.get("records", [])
    failed_records = [
        record
        for record in records
        if not record.get("success", False)
    ]

    REPORT_DIR.mkdir(parents=True, exist_ok=True)

    analysis_records = []
    category_counts = Counter()
    model_counts = defaultdict(Counter)
    error_signature_counts = Counter()

    recoverable_outputs = []

    for record in failed_records:
        model = record.get("model", "unknown")
        task = record.get("task", "unknown")
        return_code = record.get("return_code")

        log_path_value = record.get("log_path")
        if log_path_value:
            log_path = Path(log_path_value)
        else:
            log_path = LOG_ROOT / model / (task + ".log")

        log_text = read_text(log_path)
        error_lines = extract_error_lines(log_text)

        module_path = locate_module(model, task)

        category, explanation = classify_failure(
            return_code,
            module_path,
            log_text,
            error_lines,
        )

        signature = normalize_error_signature(error_lines)

        category_counts[category] += 1
        model_counts[model][category] += 1
        error_signature_counts[signature] += 1

        output_python = OUTPUT_ROOT / model / (task + ".py")

        if module_path is not None:
            recoverable_outputs.append({
                "model": model,
                "task": task,
                "module_path": str(module_path),
                "expected_output": str(output_python),
            })

        analysis_records.append({
            "model": model,
            "task": task,
            "input_dfy": record.get("input_dfy"),
            "return_code": return_code,
            "category": category,
            "explanation": explanation,
            "module_exists": module_path is not None,
            "module_path": (
                str(module_path)
                if module_path is not None
                else None
            ),
            "log_path": str(log_path),
            "error_signature": signature,
            "error_lines": error_lines,
            "stderr_tail": record.get("stderr_tail", ""),
            "stdout_tail": record.get("stdout_tail", ""),
        })

    report = {
        "manifest": str(MANIFEST_PATH),
        "total_manifest_records": len(records),
        "manifest_successful": sum(
            1 for record in records
            if record.get("success", False)
        ),
        "manifest_failed": len(failed_records),
        "category_counts": dict(category_counts),
        "model_category_counts": {
            model: dict(counts)
            for model, counts in model_counts.items()
        },
        "recoverable_outputs": recoverable_outputs,
        "common_error_signatures": [
            {
                "count": count,
                "signature": signature,
            }
            for signature, count
            in error_signature_counts.most_common()
        ],
        "records": analysis_records,
    }

    REPORT_JSON.write_text(
        json.dumps(report, indent=2),
        encoding="utf-8",
    )

    csv_fields = [
        "model",
        "task",
        "input_dfy",
        "return_code",
        "category",
        "explanation",
        "module_exists",
        "module_path",
        "log_path",
        "error_signature",
        "error_lines",
    ]

    with REPORT_CSV.open(
        "w",
        encoding="utf-8",
        newline="",
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=csv_fields,
        )
        writer.writeheader()

        for record in analysis_records:
            row = {
                field: record.get(field)
                for field in csv_fields
            }
            row["error_lines"] = " | ".join(
                record.get("error_lines", [])
            )
            writer.writerow(row)

    summary_lines = []

    summary_lines.append(
        "DAFNY-TO-PYTHON FAILURE ANALYSIS"
    )
    summary_lines.append("=" * 72)
    summary_lines.append(
        "Manifest failures: {}".format(len(failed_records))
    )
    summary_lines.append(
        "Failures with module_.py present: {}".format(
            len(recoverable_outputs)
        )
    )
    summary_lines.append("")

    summary_lines.append("FAILURE CATEGORIES")
    summary_lines.append("-" * 72)

    for category, count in category_counts.most_common():
        summary_lines.append(
            "{:<45} {}".format(category, count)
        )

    summary_lines.append("")
    summary_lines.append("BY MODEL")
    summary_lines.append("-" * 72)

    for model in sorted(model_counts):
        summary_lines.append(model)

        for category, count in model_counts[model].most_common():
            summary_lines.append(
                "  {:<43} {}".format(category, count)
            )

    summary_lines.append("")
    summary_lines.append("MOST COMMON ERROR MESSAGES")
    summary_lines.append("-" * 72)

    for signature, count in error_signature_counts.most_common(20):
        summary_lines.append(
            "[{}] {}".format(count, signature)
        )

    summary_lines.append("")
    summary_lines.append("RECOVERABLE OUTPUTS")
    summary_lines.append("-" * 72)

    if recoverable_outputs:
        for item in recoverable_outputs:
            summary_lines.append(
                "{} / {} -> {}".format(
                    item["model"],
                    item["task"],
                    item["module_path"],
                )
            )
    else:
        summary_lines.append(
            "None. All marked failures appear to lack module_.py."
        )

    SUMMARY_TXT.write_text(
        "\n".join(summary_lines) + "\n",
        encoding="utf-8",
    )

    print("\n".join(summary_lines))

    print()
    print("Detailed JSON: {}".format(REPORT_JSON))
    print("Detailed CSV : {}".format(REPORT_CSV))
    print("Summary text: {}".format(SUMMARY_TXT))


if __name__ == "__main__":
    main()
