#!/usr/bin/env python3

import json
import re
from pathlib import Path
from typing import Any, Dict, Optional, Tuple


# ---------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------
JOURNAL_PHASE = Path("/u/mjha1/Proof2Silicon/journal_phase")

INPUT_DIR = JOURNAL_PHASE / "trained_outputs copy"

OUTPUT_DIR = (
    JOURNAL_PHASE
    / "dafny_to_rtl"
    / "dafny_outputs"
)

MANIFEST_PATH = OUTPUT_DIR / "extraction_manifest.json"


# Expected filename:
# result_<problem>_llm-<model>_pass@1_with_feedback.json
FILENAME_PATTERN = re.compile(
    r"^result_(.+?)_llm-(.+?)_pass@1_with_feedback\.json$"
)


def sanitize_component(value: str) -> str:
    """
    Convert a problem or model name into a safe filesystem component.

    Examples:
        Dafny(104)       -> Dafny_104
        gpt-5.3-codex    -> gpt-5.3-codex
    """
    value = value.strip()

    # Replace filesystem-unfriendly characters with underscores.
    value = re.sub(r"[^\w.\-]+", "_", value)

    # Collapse repeated underscores.
    value = re.sub(r"_+", "_", value)

    return value.strip("._") or "unknown"


def find_first_success(
    data: Dict[str, Any]
) -> Optional[Tuple[int, str]]:
    """
    Return:
        (attempt_number, code)

    for the first attempt whose success field is equal to 1.

    Returns None when no valid successful attempt is found.
    """
    attempts = data.get("attempts", [])

    if not isinstance(attempts, list):
        return None

    for index, attempt in enumerate(attempts):
        if not isinstance(attempt, dict):
            continue

        if attempt.get("success") != 1:
            continue

        code = attempt.get("code", "")

        if not isinstance(code, str) or not code.strip():
            continue

        attempt_number = attempt.get("attempt", index)

        try:
            attempt_number = int(attempt_number)
        except (TypeError, ValueError):
            attempt_number = index

        return attempt_number, code.strip()

    return None


def make_unique_path(path: Path) -> Path:
    """
    Avoid overwriting when multiple files map to the same output name.
    """
    if not path.exists():
        return path

    counter = 2

    while True:
        candidate = path.with_name(
            f"{path.stem}_{counter}{path.suffix}"
        )

        if not candidate.exists():
            return candidate

        counter += 1


def main() -> None:
    if not INPUT_DIR.exists():
        raise FileNotFoundError(
            f"Input directory does not exist: {INPUT_DIR}"
        )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    manifest = {
        "input_directory": str(INPUT_DIR),
        "output_directory": str(OUTPUT_DIR),
        "processed_json_files": 0,
        "successful_programs_written": 0,
        "first_verified_written": 0,
        "failed_results": 0,
        "skipped_files": [],
        "outputs": [],
    }

    json_files = sorted(INPUT_DIR.glob("*.json"))

    print(f"Input directory : {INPUT_DIR}")
    print(f"Output directory: {OUTPUT_DIR}")
    print(f"JSON files found: {len(json_files)}")
    print()

    for json_path in json_files:
        match = FILENAME_PATTERN.match(json_path.name)

        if not match:
            manifest["skipped_files"].append({
                "path": str(json_path),
                "reason": "filename does not match expected pattern",
            })
            continue

        problem_name, model_name = match.groups()

        manifest["processed_json_files"] += 1

        try:
            with json_path.open("r", encoding="utf-8") as file:
                data = json.load(file)
        except Exception as exc:
            print(f"[READ ERROR] {json_path.name}: {exc}")

            manifest["skipped_files"].append({
                "path": str(json_path),
                "reason": f"JSON read error: {exc}",
            })
            continue

        success_result = find_first_success(data)

        if success_result is None:
            manifest["failed_results"] += 1
            print(f"[NO SUCCESS] {json_path.name}")
            continue

        attempt_number, code = success_result

        safe_model = sanitize_component(model_name)
        safe_problem = sanitize_component(problem_name)

        model_output_dir = OUTPUT_DIR / safe_model
        model_output_dir.mkdir(parents=True, exist_ok=True)

        # The JSON convention used in your analysis script considers
        # attempt == 1 to be first-round verification.
        if attempt_number == 1:
            output_name = f"{safe_problem}_firstverified.dfy"
            manifest["first_verified_written"] += 1
        else:
            output_name = f"{safe_problem}.dfy"

        output_path = make_unique_path(
            model_output_dir / output_name
        )

        # Ensure every Dafny file ends with a newline.
        output_path.write_text(
            code.rstrip() + "\n",
            encoding="utf-8",
        )

        manifest["successful_programs_written"] += 1

        manifest["outputs"].append({
            "problem": problem_name,
            "model": model_name,
            "attempt": attempt_number,
            "first_verified": attempt_number == 1,
            "source_json": str(json_path),
            "output_dfy": str(output_path),
        })

        print(
            f"[WRITTEN] model={model_name} "
            f"problem={problem_name} "
            f"attempt={attempt_number} "
            f"-> {output_path}"
        )

    with MANIFEST_PATH.open("w", encoding="utf-8") as file:
        json.dump(manifest, file, indent=2)

    print()
    print("=" * 72)
    print("EXTRACTION COMPLETE")
    print("=" * 72)
    print(
        "Processed matching JSON files : "
        f"{manifest['processed_json_files']}"
    )
    print(
        "Successful Dafny files written: "
        f"{manifest['successful_programs_written']}"
    )
    print(
        "First-verified files written  : "
        f"{manifest['first_verified_written']}"
    )
    print(
        "Results with no success       : "
        f"{manifest['failed_results']}"
    )
    print(
        "Skipped or unreadable files   : "
        f"{len(manifest['skipped_files'])}"
    )
    print(f"Manifest                      : {MANIFEST_PATH}")


if __name__ == "__main__":
    main()
