#!/usr/bin/env python3
"""Show partial journal results using ONLY the first five attempts.

Existing trajectories may contain attempts 6 and 7 from the already-running
core study.  This monitor recomputes every headline metric from the embedded
attempt records after truncating them to attempts 1..5, so later attempts cannot
leak into success, recursion, token, latency, or attempt-count statistics.
"""
from __future__ import annotations

import argparse
import csv
import json
import os
import time
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional

DEFAULT_ROOT = Path("/u/mjha1/Proof2Silicon/journal_phase/journal_eval")
DEFAULT_DATASET = Path("/u/mjha1/Proof2Silicon/journal_phase/Input_dataset_3")
MAX_ITERATIONS = 5


def pct(value: float) -> str:
    return f"{100.0 * value:5.1f}%"


def mean(values: Iterable[float]) -> float:
    vals = list(values)
    return sum(vals) / len(vals) if vals else 0.0


def short_condition(name: str) -> str:
    parts = name.split("__")
    keep = []
    for part in parts:
        if part.startswith(("instr_", "policy_", "coder_", "fb_", "rechint_", "scale_", "decode_", "mode_")):
            keep.append(part)
    return " | ".join(keep) if keep else name


def load_json(path: Path) -> Optional[dict]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def expected_tasks(condition: Path, fallback: int) -> int:
    cfg = load_json(condition / "config.json") or {}
    dataset = Path(str(cfg.get("dataset", ""))) if cfg.get("dataset") else None
    if dataset and dataset.exists():
        try:
            return sum(1 for path in dataset.iterdir() if path.is_dir())
        except OSError:
            pass
    return fallback


def truncate_trajectory(row: dict) -> dict:
    attempts = []
    for attempt in row.get("attempts") or []:
        try:
            index = int(attempt.get("sample_or_attempt", 0))
        except (TypeError, ValueError):
            continue
        if 1 <= index <= MAX_ITERATIONS:
            attempts.append(attempt)
    attempts.sort(key=lambda item: int(item.get("sample_or_attempt", 0)))

    first_verified = next(
        (int(a["sample_or_attempt"]) for a in attempts if a.get("verifier_success")),
        None,
    )
    first_aligned = next(
        (
            int(a["sample_or_attempt"])
            for a in attempts
            if a.get("verifier_success") and a.get("semantic_aligned")
        ),
        None,
    )
    n_attempts = len(attempts)
    mode = str(row.get("evaluation_mode", "repair"))

    out = {
        "task_id": row.get("task_id"),
        "evaluation_mode": mode,
        "samples_or_attempts_run": n_attempts,
        "any_verified": any(a.get("verifier_success") for a in attempts),
        "any_aligned": any(
            a.get("verifier_success") and a.get("semantic_aligned") for a in attempts
        ),
        "any_aligned_nonrecursive": any(
            a.get("verifier_success")
            and a.get("semantic_aligned")
            and not a.get("recursive")
            for a in attempts
        ),
        "recursive_generation_rate": (
            sum(bool(a.get("recursive")) for a in attempts) / n_attempts
            if n_attempts
            else 0.0
        ),
        "total_coder_prompt_tokens": sum(
            float(a.get("coder_prompt_tokens", 0) or 0) for a in attempts
        ),
        "total_coder_completion_tokens": sum(
            float(a.get("coder_completion_tokens", 0) or 0) for a in attempts
        ),
        "total_instructor_prompt_tokens": sum(
            float(a.get("instructor_prompt_tokens", 0) or 0) for a in attempts
        ),
        "total_instructor_completion_tokens": sum(
            float(a.get("instructor_completion_tokens", 0) or 0) for a in attempts
        ),
        "total_slm_generated_tokens": sum(
            float(a.get("slm_generated_tokens", 0) or 0) for a in attempts
        ),
        "total_latency_sec": sum(float(a.get("latency_sec", 0) or 0) for a in attempts),
        "api_or_runtime_errors": sum(bool(a.get("error")) for a in attempts),
    }

    if mode == "repair":
        for k in (1, 3, 5):
            out[f"repair_at_{k}"] = bool(first_verified and first_verified <= k)
            out[f"aligned_repair_at_{k}"] = bool(first_aligned and first_aligned <= k)
    else:
        verified = [bool(a.get("verifier_success")) for a in attempts]
        aligned = [
            bool(a.get("verifier_success") and a.get("semantic_aligned"))
            for a in attempts
        ]
        for k in (1, 3, 5):
            out[f"pass_at_{k}"] = any(verified[:k])
            out[f"aligned_pass_at_{k}"] = any(aligned[:k])
    return out


def summarize_condition(condition: Path, fallback_expected: int) -> Optional[Dict[str, Any]]:
    traj_dir = condition / "trajectories"
    if not traj_dir.exists():
        return None
    rows = []
    for path in sorted(traj_dir.glob("*.json")):
        raw = load_json(path)
        if raw:
            rows.append(truncate_trajectory(raw))
    if not rows:
        return None

    n = len(rows)
    expected = expected_tasks(condition, fallback_expected)
    mode = str(rows[0].get("evaluation_mode", "repair"))
    completed = (condition / "summary.json").exists() and n >= expected

    def rate(key: str) -> float:
        return sum(bool(row.get(key)) for row in rows) / n

    result = {
        "condition": condition.name,
        "display": short_condition(condition.name),
        "status": "DONE" if completed else "PARTIAL",
        "n_done": n,
        "n_expected": expected,
        "progress": n / expected if expected else 0.0,
        "evaluation_budget": MAX_ITERATIONS,
        "any_verified_rate": rate("any_verified"),
        "any_aligned_rate": rate("any_aligned"),
        "aligned_nonrecursive_rate": rate("any_aligned_nonrecursive"),
        "mean_recursive_generation_rate": mean(
            float(row.get("recursive_generation_rate", 0)) for row in rows
        ),
        "mean_attempts_run": mean(
            float(row.get("samples_or_attempts_run", 0)) for row in rows
        ),
        "mean_coder_tokens": mean(
            float(row.get("total_coder_prompt_tokens", 0))
            + float(row.get("total_coder_completion_tokens", 0))
            for row in rows
        ),
        "mean_instructor_tokens": mean(
            float(row.get("total_instructor_prompt_tokens", 0))
            + float(row.get("total_instructor_completion_tokens", 0))
            + float(row.get("total_slm_generated_tokens", 0))
            for row in rows
        ),
        "mean_latency_sec": mean(
            float(row.get("total_latency_sec", 0)) for row in rows
        ),
        "runtime_error_task_rate": (
            sum(int(row.get("api_or_runtime_errors", 0) or 0) > 0 for row in rows) / n
        ),
    }

    keys = (
        ("repair_at_1", "repair_at_3", "repair_at_5", "aligned_repair_at_1", "aligned_repair_at_3", "aligned_repair_at_5")
        if mode == "repair"
        else ("pass_at_1", "pass_at_3", "pass_at_5", "aligned_pass_at_1", "aligned_pass_at_3", "aligned_pass_at_5")
    )
    for key in keys:
        result[key] = rate(key)

    result["verified_tasks"] = ",".join(
        str(row.get("task_id")) for row in rows if row.get("any_verified")
    )
    result["aligned_tasks"] = ",".join(
        str(row.get("task_id")) for row in rows if row.get("any_aligned")
    )
    return result


def collect(root: Path, fallback_expected: int) -> List[Dict[str, Any]]:
    if not root.exists():
        return []
    rows = []
    for condition in sorted(
        path for path in root.iterdir() if path.is_dir() and not path.name.startswith("_")
    ):
        summary = summarize_condition(condition, fallback_expected)
        if summary:
            rows.append(summary)
    return rows


def render(rows: List[Dict[str, Any]], root: Path) -> None:
    os.system("clear")
    print(f"Live journal evaluation: {root}")
    print(f"Snapshot: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print("Evaluation budget: FIRST FIVE attempts only; attempts 6-7 are ignored.")
    print("Rates use completed tasks only; PARTIAL rows are not final results.\n")
    if not rows:
        print("No completed trajectory files yet.")
        return

    header = (
        f"{'STATUS':7} {'DONE':>8} {'VER@5':>7} {'ALIGN@5':>8} {'A+NR@5':>8} "
        f"{'RECUR':>7} {'ATT':>5} {'CODTOK':>8} {'INSTTOK':>8}  CONDITION"
    )
    print(header)
    print("-" * min(180, len(header) + 80))
    for row in rows:
        print(
            f"{row['status']:7} {row['n_done']:3d}/{row['n_expected']:<4d} "
            f"{pct(row['any_verified_rate']):>7} {pct(row['any_aligned_rate']):>8} "
            f"{pct(row['aligned_nonrecursive_rate']):>8} "
            f"{pct(row['mean_recursive_generation_rate']):>7} "
            f"{row['mean_attempts_run']:5.2f} {row['mean_coder_tokens']:8.0f} "
            f"{row['mean_instructor_tokens']:8.0f}  {row['display']}"
        )

    print("\nDetailed checkpoints (maximum k=5):")
    for row in rows:
        metrics = []
        for key in (
            "repair_at_1", "repair_at_3", "repair_at_5",
            "aligned_repair_at_1", "aligned_repair_at_3", "aligned_repair_at_5",
            "pass_at_1", "pass_at_3", "pass_at_5",
            "aligned_pass_at_1", "aligned_pass_at_3", "aligned_pass_at_5",
        ):
            if key in row:
                metrics.append(f"{key}={pct(row[key])}")
        print(f"- {row['display']}: " + ", ".join(metrics))


def write_csv(rows: List[Dict[str, Any]], path: Path) -> None:
    if not rows:
        return
    keys = []
    seen = set()
    for row in rows:
        for key in row:
            if key not in seen:
                seen.add(key)
                keys.append(key)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=keys)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    parser.add_argument("--watch", type=float, default=0.0)
    parser.add_argument("--csv", type=Path, default=None)
    args = parser.parse_args()

    fallback_expected = 0
    if args.dataset.exists():
        fallback_expected = sum(1 for path in args.dataset.iterdir() if path.is_dir())

    while True:
        rows = collect(args.root, fallback_expected)
        render(rows, args.root)
        csv_path = args.csv or (args.root / "live_partial_results_5attempt.csv")
        write_csv(rows, csv_path)
        print(f"\nCSV snapshot: {csv_path}")
        if args.watch <= 0:
            break
        time.sleep(args.watch)


if __name__ == "__main__":
    main()
