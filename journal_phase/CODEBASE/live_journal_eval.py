#!/usr/bin/env python3
"""Show partial Proof2Silicon journal-evaluation results while jobs are running.

Reads only atomically-written per-task trajectory JSON files, so it is safe to run
concurrently with evaluation jobs. Rates are computed over completed tasks only
and are therefore preliminary until a condition reaches the full dataset size.
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


def pct(value: float) -> str:
    return f"{100.0 * value:5.1f}%"


def mean(values: Iterable[float]) -> float:
    vals = list(values)
    return sum(vals) / len(vals) if vals else 0.0


def short_condition(name: str) -> str:
    # Keep the scientifically important parts while avoiding an unreadably wide table.
    parts = name.split("__")
    keep = []
    for p in parts:
        if p.startswith(("instr_", "policy_", "coder_", "fb_", "rechint_", "scale_", "decode_", "mode_")):
            keep.append(p)
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
            return sum(1 for p in dataset.iterdir() if p.is_dir())
        except OSError:
            pass
    return fallback


def summarize_condition(condition: Path, fallback_expected: int) -> Optional[Dict[str, Any]]:
    traj_dir = condition / "trajectories"
    if not traj_dir.exists():
        return None
    rows: List[dict] = []
    for p in sorted(traj_dir.glob("*.json")):
        d = load_json(p)
        if d:
            rows.append(d)
    if not rows:
        return None

    n = len(rows)
    expected = expected_tasks(condition, fallback_expected)
    mode = str(rows[0].get("evaluation_mode", "repair"))
    completed = (condition / "summary.json").exists() and n >= expected
    status = "DONE" if completed else "PARTIAL"

    def rate(key: str) -> float:
        return sum(bool(r.get(key)) for r in rows) / n

    result: Dict[str, Any] = {
        "condition": condition.name,
        "display": short_condition(condition.name),
        "status": status,
        "n_done": n,
        "n_expected": expected,
        "progress": n / expected if expected else 0.0,
        "any_verified_rate": rate("any_verified"),
        "any_aligned_rate": rate("any_aligned"),
        "aligned_nonrecursive_rate": rate("any_aligned_nonrecursive"),
        "mean_recursive_generation_rate": mean(float(r.get("recursive_generation_rate", 0.0)) for r in rows),
        "mean_attempts_run": mean(float(r.get("samples_or_attempts_run", 0)) for r in rows),
        "mean_coder_tokens": mean(
            float(r.get("total_coder_prompt_tokens", 0)) + float(r.get("total_coder_completion_tokens", 0))
            for r in rows
        ),
        "mean_instructor_tokens": mean(
            float(r.get("total_instructor_prompt_tokens", 0))
            + float(r.get("total_instructor_completion_tokens", 0))
            + float(r.get("total_slm_generated_tokens", 0))
            for r in rows
        ),
        "runtime_error_task_rate": rate("api_or_runtime_errors"),
    }

    if mode == "repair":
        for k in (1, 3, 5, 7):
            key = f"repair_at_{k}"
            aligned_key = f"aligned_repair_at_{k}"
            if any(key in r for r in rows):
                result[key] = rate(key)
            if any(aligned_key in r for r in rows):
                result[aligned_key] = rate(aligned_key)
    else:
        for k in (1, 3, 5):
            key = f"pass_at_{k}"
            aligned_key = f"aligned_pass_at_{k}"
            if any(key in r for r in rows):
                result[key] = rate(key)
            if any(aligned_key in r for r in rows):
                result[aligned_key] = rate(aligned_key)

    # Useful for seeing exactly which finished tasks are driving the interim result.
    result["verified_tasks"] = ",".join(str(r.get("task_id")) for r in rows if r.get("any_verified"))
    result["aligned_tasks"] = ",".join(str(r.get("task_id")) for r in rows if r.get("any_aligned"))
    return result


def collect(root: Path, fallback_expected: int) -> List[Dict[str, Any]]:
    if not root.exists():
        return []
    rows = []
    for condition in sorted(p for p in root.iterdir() if p.is_dir() and not p.name.startswith("_")):
        d = summarize_condition(condition, fallback_expected)
        if d:
            rows.append(d)
    return rows


def render(rows: List[Dict[str, Any]], root: Path) -> None:
    os.system("clear")
    print(f"Live journal evaluation: {root}")
    print(f"Snapshot: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print("Rates below use COMPLETED TASKS ONLY; PARTIAL rows are not final results.\n")
    if not rows:
        print("No completed trajectory files yet.")
        return

    header = (
        f"{'STATUS':7} {'DONE':>8} {'VER':>7} {'ALIGN':>7} {'A+NR':>7} "
        f"{'RECUR':>7} {'ATT':>5} {'CODTOK':>8} {'INSTTOK':>8}  CONDITION"
    )
    print(header)
    print("-" * min(180, len(header) + 80))
    for r in rows:
        print(
            f"{r['status']:7} {r['n_done']:3d}/{r['n_expected']:<4d} "
            f"{pct(r['any_verified_rate']):>7} {pct(r['any_aligned_rate']):>7} "
            f"{pct(r['aligned_nonrecursive_rate']):>7} "
            f"{pct(r['mean_recursive_generation_rate']):>7} "
            f"{r['mean_attempts_run']:5.2f} {r['mean_coder_tokens']:8.0f} "
            f"{r['mean_instructor_tokens']:8.0f}  {r['display']}"
        )

    print("\nDetailed repair/pass checkpoints:")
    for r in rows:
        metrics = []
        for key in (
            "repair_at_1", "repair_at_3", "repair_at_5", "repair_at_7",
            "aligned_repair_at_1", "aligned_repair_at_3", "aligned_repair_at_5", "aligned_repair_at_7",
            "pass_at_1", "pass_at_3", "pass_at_5",
            "aligned_pass_at_1", "aligned_pass_at_3", "aligned_pass_at_5",
        ):
            if key in r:
                metrics.append(f"{key}={pct(r[key])}")
        print(f"- {r['display']}: " + ", ".join(metrics))


def write_csv(rows: List[Dict[str, Any]], path: Path) -> None:
    if not rows:
        return
    keys = []
    seen = set()
    for r in rows:
        for k in r:
            if k not in seen:
                seen.add(k)
                keys.append(k)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=keys)
        w.writeheader()
        w.writerows(rows)


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    p.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    p.add_argument("--watch", type=float, default=0.0, help="Refresh every N seconds; 0 prints one snapshot.")
    p.add_argument("--csv", type=Path, default=None, help="Optional output CSV path.")
    args = p.parse_args()

    fallback_expected = 0
    if args.dataset.exists():
        fallback_expected = sum(1 for pth in args.dataset.iterdir() if pth.is_dir())

    while True:
        rows = collect(args.root, fallback_expected)
        render(rows, args.root)
        csv_path = args.csv or (args.root / "live_partial_results.csv")
        write_csv(rows, csv_path)
        print(f"\nCSV snapshot: {csv_path}")
        if args.watch <= 0:
            break
        time.sleep(args.watch)


if __name__ == "__main__":
    main()
