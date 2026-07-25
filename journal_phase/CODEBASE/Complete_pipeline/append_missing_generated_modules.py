#!/usr/bin/env python3

import json
import shutil
from pathlib import Path


PIPELINE_ROOT = Path(
    "/u/mjha1/Proof2Silicon/journal_phase/"
    "dafny_to_rtl_pipeline"
)

GENERATED_ROOT = PIPELINE_ROOT / "generated_python"
RAW_ROOT = PIPELINE_ROOT / "generated_python_raw"
BACKUP_ROOT = PIPELINE_ROOT / "generated_python_before_append"
MANIFEST_PATH = (
    PIPELINE_ROOT
    / "manifests"
    / "appended_generated_modules_manifest.json"
)

MODULE_MARKER = "# Module: module_"
APPEND_MARKER = "# PROOF2SILICON_APPENDED_GENERATED_MODULES"


def content_after_module_marker_is_empty(text):
    """
    Return True only when the file contains '# Module: module_' and
    everything after it is whitespace.
    """
    marker_index = text.find(MODULE_MARKER)

    if marker_index == -1:
        return False

    after_marker = text[
        marker_index + len(MODULE_MARKER):
    ]

    return not after_marker.strip()


def find_raw_task_directory(model_name, task_name):
    """
    Expected layout:
        generated_python_raw/<model>/<task>-py/
    """
    model_raw_dir = RAW_ROOT / model_name

    candidates = [
        model_raw_dir / (task_name + "-py"),
        model_raw_dir / task_name,
    ]

    for candidate in candidates:
        if candidate.is_dir():
            return candidate

    if not model_raw_dir.exists():
        return None

    matching_dirs = sorted(
        path
        for path in model_raw_dir.iterdir()
        if path.is_dir()
        and (
            path.name == task_name
            or path.name == task_name + "-py"
        )
    )

    if matching_dirs:
        return matching_dirs[0]

    return None


def find_extra_python_files(raw_task_dir):
    """
    Find generated implementation files other than:
      - __main__.py
      - module_.py
    """
    if raw_task_dir is None:
        return []

    return sorted(
        path
        for path in raw_task_dir.rglob("*.py")
        if path.is_file()
        and path.name not in {
            "__main__.py",
            "module_.py",
        }
    )


def append_extra_modules(
    destination_path,
    raw_task_dir,
    extra_files,
):
    original_text = destination_path.read_text(
        encoding="utf-8",
        errors="replace",
    )

    appended_sections = []

    for source_path in extra_files:
        relative_path = source_path.relative_to(
            raw_task_dir
        )

        source_text = source_path.read_text(
            encoding="utf-8",
            errors="replace",
        ).rstrip()

        if not source_text:
            continue

        section = (
            "\n\n"
            "# ============================================================\n"
            "# Appended from Dafny-generated file: {}\n"
            "# ============================================================\n"
            "{}\n"
        ).format(
            relative_path,
            source_text,
        )

        appended_sections.append(section)

    if not appended_sections:
        return []

    new_text = (
        original_text.rstrip()
        + "\n\n"
        + APPEND_MARKER
        + "\n"
        + "".join(appended_sections)
    )

    destination_path.write_text(
        new_text,
        encoding="utf-8",
    )

    return [
        str(path.relative_to(raw_task_dir))
        for path in extra_files
    ]


def main():
    if not GENERATED_ROOT.exists():
        raise SystemExit(
            "Generated Python directory not found: {}".format(
                GENERATED_ROOT
            )
        )

    if not RAW_ROOT.exists():
        raise SystemExit(
            "Raw generated Python directory not found: {}".format(
                RAW_ROOT
            )
        )

    BACKUP_ROOT.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    records = []

    total_files = 0
    marker_missing = 0
    nonempty_module = 0
    already_appended = 0
    raw_directory_missing = 0
    no_extra_files = 0
    modified = 0

    model_dirs = sorted(
        path
        for path in GENERATED_ROOT.iterdir()
        if path.is_dir()
    )

    for model_dir in model_dirs:
        model_name = model_dir.name

        generated_files = sorted(
            path
            for path in model_dir.rglob("*.py")
            if path.is_file()
        )

        print()
        print("Model: {}".format(model_name))
        print(
            "Generated files: {}".format(
                len(generated_files)
            )
        )

        for generated_path in generated_files:
            total_files += 1
            task_name = generated_path.stem

            text = generated_path.read_text(
                encoding="utf-8",
                errors="replace",
            )

            record = {
                "model": model_name,
                "task": task_name,
                "generated_file": str(generated_path),
                "status": None,
                "raw_task_directory": None,
                "appended_files": [],
                "backup_file": None,
            }

            if APPEND_MARKER in text:
                already_appended += 1
                record["status"] = "already_appended"
                records.append(record)

                print(
                    "  {} -> already appended".format(
                        generated_path.name
                    )
                )
                continue

            if MODULE_MARKER not in text:
                marker_missing += 1
                record["status"] = "module_marker_missing"
                records.append(record)

                print(
                    "  {} -> marker not found".format(
                        generated_path.name
                    )
                )
                continue

            if not content_after_module_marker_is_empty(
                text
            ):
                nonempty_module += 1
                record["status"] = "module_not_empty"
                records.append(record)

                print(
                    "  {} -> module already has content".format(
                        generated_path.name
                    )
                )
                continue

            raw_task_dir = find_raw_task_directory(
                model_name,
                task_name,
            )

            record["raw_task_directory"] = (
                str(raw_task_dir)
                if raw_task_dir is not None
                else None
            )

            if raw_task_dir is None:
                raw_directory_missing += 1
                record["status"] = "raw_directory_missing"
                records.append(record)

                print(
                    "  {} -> raw directory missing".format(
                        generated_path.name
                    )
                )
                continue

            extra_files = find_extra_python_files(
                raw_task_dir
            )

            if not extra_files:
                no_extra_files += 1
                record["status"] = "no_extra_python_files"
                records.append(record)

                print(
                    "  {} -> no extra Python files".format(
                        generated_path.name
                    )
                )
                continue

            relative_generated_path = (
                generated_path.relative_to(
                    GENERATED_ROOT
                )
            )

            backup_path = (
                BACKUP_ROOT
                / relative_generated_path
            )

            backup_path.parent.mkdir(
                parents=True,
                exist_ok=True,
            )

            shutil.copy2(
                str(generated_path),
                str(backup_path),
            )

            appended_files = append_extra_modules(
                generated_path,
                raw_task_dir,
                extra_files,
            )

            if appended_files:
                modified += 1
                record["status"] = "modified"
                record["appended_files"] = appended_files
                record["backup_file"] = str(backup_path)

                print(
                    "  {} -> appended: {}".format(
                        generated_path.name,
                        ", ".join(appended_files),
                    )
                )
            else:
                no_extra_files += 1
                record["status"] = (
                    "extra_python_files_were_empty"
                )

                print(
                    "  {} -> extra files were empty".format(
                        generated_path.name
                    )
                )

            records.append(record)

    manifest = {
        "generated_root": str(GENERATED_ROOT),
        "raw_root": str(RAW_ROOT),
        "backup_root": str(BACKUP_ROOT),
        "total_files_scanned": total_files,
        "modified": modified,
        "module_marker_missing": marker_missing,
        "module_not_empty": nonempty_module,
        "already_appended": already_appended,
        "raw_directory_missing": raw_directory_missing,
        "no_extra_python_files": no_extra_files,
        "records": records,
    }

    MANIFEST_PATH.write_text(
        json.dumps(manifest, indent=2),
        encoding="utf-8",
    )

    print()
    print("=" * 72)
    print("APPEND PROCESS COMPLETE")
    print("=" * 72)
    print(
        "Total files scanned      : {}".format(
            total_files
        )
    )
    print(
        "Files modified           : {}".format(
            modified
        )
    )
    print(
        "Module already nonempty  : {}".format(
            nonempty_module
        )
    )
    print(
        "Already appended         : {}".format(
            already_appended
        )
    )
    print(
        "Module marker missing    : {}".format(
            marker_missing
        )
    )
    print(
        "Raw directory missing    : {}".format(
            raw_directory_missing
        )
    )
    print(
        "No extra Python files    : {}".format(
            no_extra_files
        )
    )
    print(
        "Backup directory         : {}".format(
            BACKUP_ROOT
        )
    )
    print(
        "Manifest                 : {}".format(
            MANIFEST_PATH
        )
    )


if __name__ == "__main__":
    main()
