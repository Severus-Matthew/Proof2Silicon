#!/usr/bin/env python3

import csv
import json
import shutil
import subprocess
import sys
import time
from pathlib import Path


JOURNAL_PHASE = Path("/u/mjha1/Proof2Silicon/journal_phase")
PIPELINE_DIR = JOURNAL_PHASE / "dafny_to_rtl_pipeline"

INPUT_ROOT = PIPELINE_DIR / "dafny_outputs"
OUTPUT_ROOT = PIPELINE_DIR / "generated_python"
RAW_ROOT = PIPELINE_DIR / "generated_python_raw"
FAILED_ROOT = PIPELINE_DIR / "failed" / "dafny_to_python"
LOG_ROOT = PIPELINE_DIR / "logs" / "dafny_to_python"
MANIFEST_ROOT = PIPELINE_DIR / "manifests"

MANIFEST_JSON = MANIFEST_ROOT / "dafny_to_python_manifest.json"
MANIFEST_CSV = MANIFEST_ROOT / "dafny_to_python_manifest.csv"

DAFNY_CMD = shutil.which("dafny") or "/u/mjha1/.dotnet/tools/dafny"


def clear_path(path):
    if path.exists():
        if path.is_dir():
            shutil.rmtree(str(path))
        else:
            path.unlink()


def find_generated_module(raw_model_dir, task_name):
    """
    Dafny 4.11 typically creates:
        <raw_model_dir>/<task_name>-py/module_.py
    """

    preferred_candidates = [
        raw_model_dir / f"{task_name}-py" / "module_.py",
        raw_model_dir / task_name / "module_.py",
        raw_model_dir / "module_.py",
    ]

    for candidate in preferred_candidates:
        if candidate.is_file():
            return candidate

    recursive_candidates = sorted(
        raw_model_dir.rglob("module_.py")
    )

    for candidate in recursive_candidates:
        if task_name in str(candidate.parent):
            return candidate

    return None


def translate_one(dfy_path, model_name):
    task_name = dfy_path.stem

    raw_model_dir = RAW_ROOT / model_name
    output_model_dir = OUTPUT_ROOT / model_name
    log_model_dir = LOG_ROOT / model_name

    raw_model_dir.mkdir(parents=True, exist_ok=True)
    output_model_dir.mkdir(parents=True, exist_ok=True)
    log_model_dir.mkdir(parents=True, exist_ok=True)

    raw_generated_dir = raw_model_dir / f"{task_name}-py"
    requested_output = raw_model_dir / task_name
    output_python = output_model_dir / f"{task_name}.py"
    log_path = log_model_dir / f"{task_name}.log"

    clear_path(raw_generated_dir)
    clear_path(requested_output)
    clear_path(output_python)

    command = [
        DAFNY_CMD,
        "translate",
        "py",
        str(dfy_path),
        "--output",
        str(requested_output),
        "--no-verify",
        "--allow-warnings",
        "--verbose",
    ]

    start_time = time.time()

    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )

    elapsed_seconds = time.time() - start_time

    generated_module = find_generated_module(
        raw_model_dir,
        task_name,
    )

    success = (
        completed.returncode == 0
        and generated_module is not None
        and generated_module.is_file()
    )

    failure_dir = FAILED_ROOT / model_name / task_name

    if success:
        output_model_dir.mkdir(parents=True, exist_ok=True)

        shutil.copy2(
            str(generated_module),
            str(output_python),
        )

        if failure_dir.exists():
            shutil.rmtree(str(failure_dir))

    else:
        failure_dir.mkdir(parents=True, exist_ok=True)

        shutil.copy2(
            str(dfy_path),
            str(failure_dir / dfy_path.name),
        )

    generated_files = sorted(
        str(path)
        for path in raw_model_dir.rglob("*")
        if path.is_file()
        and task_name in str(path)
    )

    log_text = (
        "COMMAND:\n"
        + " ".join(command)
        + "\n\nRETURN CODE:\n"
        + str(completed.returncode)
        + "\n\nGENERATED MODULE:\n"
        + (
            str(generated_module)
            if generated_module is not None
            else "NOT FOUND"
        )
        + "\n\nGENERATED FILES:\n"
        + "\n".join(generated_files)
        + "\n\nSTDOUT:\n"
        + completed.stdout
        + "\n\nSTDERR:\n"
        + completed.stderr
    )

    log_path.write_text(log_text, encoding="utf-8")

    if not success:
        shutil.copy2(
            str(log_path),
            str(failure_dir / log_path.name),
        )

    return {
        "model": model_name,
        "task": task_name,
        "first_verified": task_name.endswith("_firstverified"),
        "input_dfy": str(dfy_path),
        "raw_requested_output": str(requested_output),
        "raw_generated_directory": (
            str(raw_generated_dir)
            if raw_generated_dir.exists()
            else None
        ),
        "generated_module": (
            str(generated_module)
            if generated_module is not None
            else None
        ),
        "output_python": (
            str(output_python)
            if success
            else None
        ),
        "return_code": completed.returncode,
        "success": success,
        "elapsed_seconds": round(elapsed_seconds, 3),
        "log_path": str(log_path),
        "stdout_tail": completed.stdout[-2000:],
        "stderr_tail": completed.stderr[-2000:],
    }


def write_manifests(records):
    MANIFEST_ROOT.mkdir(parents=True, exist_ok=True)

    summary = {
        "dafny_command": DAFNY_CMD,
        "input_root": str(INPUT_ROOT),
        "output_root": str(OUTPUT_ROOT),
        "raw_output_root": str(RAW_ROOT),
        "total": len(records),
        "successful": sum(
            1 for record in records
            if record["success"]
        ),
        "failed": sum(
            1 for record in records
            if not record["success"]
        ),
        "models": {},
        "records": records,
    }

    for record in records:
        stats = summary["models"].setdefault(
            record["model"],
            {
                "total": 0,
                "successful": 0,
                "failed": 0,
                "first_verified": 0,
            },
        )

        stats["total"] += 1
        stats["successful"] += int(record["success"])
        stats["failed"] += int(not record["success"])
        stats["first_verified"] += int(
            record["first_verified"]
        )

    MANIFEST_JSON.write_text(
        json.dumps(summary, indent=2),
        encoding="utf-8",
    )

    csv_fields = [
        "model",
        "task",
        "first_verified",
        "input_dfy",
        "raw_requested_output",
        "raw_generated_directory",
        "generated_module",
        "output_python",
        "return_code",
        "success",
        "elapsed_seconds",
        "log_path",
    ]

    with MANIFEST_CSV.open(
        "w",
        encoding="utf-8",
        newline="",
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=csv_fields,
        )
        writer.writeheader()

        for record in records:
            writer.writerow({
                field: record.get(field)
                for field in csv_fields
            })

    return summary


def main():
    if not INPUT_ROOT.exists():
        print(
            f"Input directory not found: {INPUT_ROOT}",
            file=sys.stderr,
        )
        return 1

    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    RAW_ROOT.mkdir(parents=True, exist_ok=True)
    FAILED_ROOT.mkdir(parents=True, exist_ok=True)
    LOG_ROOT.mkdir(parents=True, exist_ok=True)
    MANIFEST_ROOT.mkdir(parents=True, exist_ok=True)

    records = []

    model_dirs = sorted(
        path
        for path in INPUT_ROOT.iterdir()
        if path.is_dir()
    )

    print(f"Dafny command : {DAFNY_CMD}")
    print(f"Input root    : {INPUT_ROOT}")
    print(f"Output root   : {OUTPUT_ROOT}")
    print(f"Raw root      : {RAW_ROOT}")

    for model_dir in model_dirs:
        model_name = model_dir.name
        dfy_files = sorted(
            model_dir.glob("*.dfy")
        )

        print()
        print(f"Model: {model_name}")
        print(f"Dafny files: {len(dfy_files)}")

        for index, dfy_path in enumerate(
            dfy_files,
            start=1,
        ):
            print(
                f"  [{index}/{len(dfy_files)}] "
                f"{dfy_path.name}",
                end="",
            )
            sys.stdout.flush()

            record = translate_one(
                dfy_path,
                model_name,
            )
            records.append(record)

            if record["success"]:
                print(
                    f" -> SUCCESS: "
                    f"{record['output_python']}"
                )
            elif record["return_code"] == 0:
                print(
                    " -> FAILED: translation returned 0 "
                    "but module_.py was not found"
                )
            else:
                print(
                    f" -> FAILED: Dafny return code "
                    f"{record['return_code']}"
                )

    summary = write_manifests(records)

    print()
    print("=" * 72)
    print("DAFNY-TO-PYTHON TRANSLATION COMPLETE")
    print("=" * 72)
    print(f"Total      : {summary['total']}")
    print(f"Successful : {summary['successful']}")
    print(f"Failed     : {summary['failed']}")

    for model, stats in sorted(
        summary["models"].items()
    ):
        print(
            f"{model:<25} "
            f"total={stats['total']:<4} "
            f"success={stats['successful']:<4} "
            f"failed={stats['failed']:<4}"
        )

    print()
    print(f"JSON manifest: {MANIFEST_JSON}")
    print(f"CSV manifest : {MANIFEST_CSV}")

    return 0 if summary["failed"] == 0 else 2


if __name__ == "__main__":
    sys.exit(main())
