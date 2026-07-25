#!/usr/bin/env python3

import csv
import json
import shutil
from collections import Counter, defaultdict
from pathlib import Path


PIPELINE = Path(
    "/u/mjha1/Proof2Silicon/journal_phase/"
    "dafny_to_rtl_pipeline"
)

DAFNY_ROOT = PIPELINE / "dafny_outputs"
RAW_ROOT = PIPELINE / "generated_python_raw"
OUTPUT_ROOT = PIPELINE / "generated_python"

OLD_MANIFEST = (
    PIPELINE
    / "manifests"
    / "dafny_to_python_manifest.json"
)

NEW_MANIFEST_JSON = (
    PIPELINE
    / "manifests"
    / "dafny_to_python_recovered_manifest.json"
)

NEW_MANIFEST_CSV = (
    PIPELINE
    / "manifests"
    / "dafny_to_python_recovered_manifest.csv"
)


def remove_path(path):
    if not path.exists():
        return

    if path.is_dir():
        shutil.rmtree(str(path))
    else:
        path.unlink()


def find_raw_task_directory(model, task):
    """
    Current Dafny layout:

        generated_python_raw/<model>/<task>-py/

    Also recognize alternate layouts defensively.
    """
    model_root = RAW_ROOT / model

    candidates = [
        model_root / (task + "-py"),
        model_root / task,
    ]

    for candidate in candidates:
        if candidate.is_dir():
            return candidate

    if model_root.exists():
        possible = sorted(
            path
            for path in model_root.iterdir()
            if path.is_dir()
            and (
                path.name == task
                or path.name == task + "-py"
                or task in path.name
            )
        )

        if possible:
            return possible[0]

    return None


def find_python_files(raw_task_dir):
    """
    Return all generated Python source files.

    __main__.py is retained separately as a launcher, but it does not by
    itself prove that an implementation was generated.
    """
    if raw_task_dir is None:
        return [], []

    all_python = sorted(
        path
        for path in raw_task_dir.rglob("*.py")
        if path.is_file()
    )

    implementation_python = [
        path
        for path in all_python
        if path.name != "__main__.py"
    ]

    launcher_python = [
        path
        for path in all_python
        if path.name == "__main__.py"
    ]

    return implementation_python, launcher_python


def copy_generated_files(
    raw_task_dir,
    implementation_files,
    launcher_files,
    model,
    task,
):
    """
    Copy all generated Python files while preserving their relative paths.

    Output:

        generated_python/<model>/<task>/
            module_.py
            F.py
            GeneratedStepsProgram.py
            __main__.py
    """
    task_output_dir = OUTPUT_ROOT / model / task

    remove_path(task_output_dir)
    task_output_dir.mkdir(parents=True, exist_ok=True)

    copied_files = []

    for source in implementation_files + launcher_files:
        relative = source.relative_to(raw_task_dir)
        destination = task_output_dir / relative

        destination.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        shutil.copy2(
            str(source),
            str(destination),
        )

        copied_files.append(str(destination))

    return task_output_dir, copied_files


def load_old_records():
    if not OLD_MANIFEST.exists():
        return {}

    try:
        with OLD_MANIFEST.open("r", encoding="utf-8") as file:
            data = json.load(file)
    except Exception:
        return {}

    records = {}

    for record in data.get("records", []):
        key = (
            record.get("model"),
            record.get("task"),
        )
        records[key] = record

    return records


def main():
    if not DAFNY_ROOT.exists():
        raise SystemExit(
            "Dafny output root not found: {}".format(
                DAFNY_ROOT
            )
        )

    if not RAW_ROOT.exists():
        raise SystemExit(
            "Raw generated Python root not found: {}".format(
                RAW_ROOT
            )
        )

    old_records = load_old_records()

    # Rebuild the clean generated_python tree from scratch.
    remove_path(OUTPUT_ROOT)
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)

    records = []
    status_counts = Counter()
    model_counts = defaultdict(Counter)

    model_dirs = sorted(
        path
        for path in DAFNY_ROOT.iterdir()
        if path.is_dir()
    )

    for model_dir in model_dirs:
        model = model_dir.name
        dfy_files = sorted(model_dir.glob("*.dfy"))

        print()
        print("Model: {}".format(model))
        print("Dafny files: {}".format(len(dfy_files)))

        for index, dfy_path in enumerate(
            dfy_files,
            start=1,
        ):
            task = dfy_path.stem
            old_record = old_records.get(
                (model, task),
                {},
            )

            return_code = old_record.get(
                "return_code"
            )

            raw_task_dir = find_raw_task_directory(
                model,
                task,
            )

            implementation_files, launcher_files = (
                find_python_files(raw_task_dir)
            )

            has_implementation = (
                len(implementation_files) > 0
            )

            if has_implementation:
                output_dir, copied_files = (
                    copy_generated_files(
                        raw_task_dir,
                        implementation_files,
                        launcher_files,
                        model,
                        task,
                    )
                )

                if return_code == 0:
                    status = "SUCCESS"
                else:
                    status = (
                        "OUTPUT_EXISTS_DESPITE_NONZERO_RETURN"
                    )
            else:
                output_dir = None
                copied_files = []

                if return_code == 0:
                    status = (
                        "RETURNED_ZERO_BUT_NO_IMPLEMENTATION"
                    )
                elif return_code is None:
                    status = "NO_MANIFEST_RECORD"
                else:
                    status = "TRUE_TRANSLATION_FAILURE"

            status_counts[status] += 1
            model_counts[model][status] += 1

            records.append({
                "model": model,
                "task": task,
                "input_dfy": str(dfy_path),
                "return_code": return_code,
                "status": status,
                "raw_task_directory": (
                    str(raw_task_dir)
                    if raw_task_dir is not None
                    else None
                ),
                "implementation_file_count": len(
                    implementation_files
                ),
                "implementation_files": [
                    str(path)
                    for path in implementation_files
                ],
                "launcher_files": [
                    str(path)
                    for path in launcher_files
                ],
                "output_directory": (
                    str(output_dir)
                    if output_dir is not None
                    else None
                ),
                "copied_files": copied_files,
                "first_verified": (
                    task.endswith("_firstverified")
                ),
            })

            implementation_names = [
                path.name
                for path in implementation_files
            ]

            print(
                "  [{}/{}] {} -> {}{}".format(
                    index,
                    len(dfy_files),
                    dfy_path.name,
                    status,
                    (
                        " [{}]".format(
                            ", ".join(
                                implementation_names
                            )
                        )
                        if implementation_names
                        else ""
                    ),
                )
            )

    summary = {
        "dafny_root": str(DAFNY_ROOT),
        "raw_root": str(RAW_ROOT),
        "output_root": str(OUTPUT_ROOT),
        "total": len(records),
        "successful_with_python": sum(
            1
            for record in records
            if record["implementation_file_count"] > 0
        ),
        "without_implementation_python": sum(
            1
            for record in records
            if record["implementation_file_count"] == 0
        ),
        "status_counts": dict(status_counts),
        "model_status_counts": {
            model: dict(counts)
            for model, counts in model_counts.items()
        },
        "records": records,
    }

    NEW_MANIFEST_JSON.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    NEW_MANIFEST_JSON.write_text(
        json.dumps(summary, indent=2),
        encoding="utf-8",
    )

    fields = [
        "model",
        "task",
        "return_code",
        "status",
        "first_verified",
        "input_dfy",
        "raw_task_directory",
        "implementation_file_count",
        "implementation_files",
        "launcher_files",
        "output_directory",
        "copied_files",
    ]

    with NEW_MANIFEST_CSV.open(
        "w",
        encoding="utf-8",
        newline="",
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=fields,
        )
        writer.writeheader()

        for record in records:
            row = {
                field: record.get(field)
                for field in fields
            }

            row["implementation_files"] = ";".join(
                record["implementation_files"]
            )
            row["launcher_files"] = ";".join(
                record["launcher_files"]
            )
            row["copied_files"] = ";".join(
                record["copied_files"]
            )

            writer.writerow(row)

    print()
    print("=" * 78)
    print("PYTHON OUTPUT RECOVERY COMPLETE")
    print("=" * 78)
    print("Total Dafny programs          : {}".format(
        summary["total"]
    ))
    print("Programs with Python output   : {}".format(
        summary["successful_with_python"]
    ))
    print("Programs without implementation: {}".format(
        summary["without_implementation_python"]
    ))

    print()
    print("STATUS COUNTS")
    print("-" * 78)

    for status, count in status_counts.most_common():
        print(
            "{:<48} {}".format(
                status,
                count,
            )
        )

    print()
    print("COUNTS BY MODEL")
    print("-" * 78)

    for model in sorted(model_counts):
        print(model)

        for status, count in model_counts[model].most_common():
            print(
                "  {:<46} {}".format(
                    status,
                    count,
                )
            )

    print()
    print(
        "JSON manifest: {}".format(
            NEW_MANIFEST_JSON
        )
    )
    print(
        "CSV manifest : {}".format(
            NEW_MANIFEST_CSV
        )
    )


if __name__ == "__main__":
    main()
