#!/usr/bin/env python3
"""Live snapshot of in-progress Proof2Silicon journal evaluations.

Unlike summarize_journal_eval.py, this script does NOT wait for a whole
condition to finish.  test_journal.py writes one atomic JSON trajectory after
each completed task, so this script aggregates those trajectory files directly
while Slurm jobs are still running.

Outputs under --root:
  live_conditions.csv       one row per condition with current partial metrics
  live_pairwise_stats.csv   paired aligned-success comparisons on task IDs that
                            are complete in both comparable conditions
  live_report.md            compact human-readable snapshot

IMPORTANT: all metrics are INTERIM.  Faster/easier tasks may finish first, so
partial rates and p-values must not be reported as final paper results.
"""
from __future__ import annotations

import argparse
import csv
import json
import math
import random
import time
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

DEFAULT_ROOT = Path("/u/mjha1/Proof2Silicon/journal_phase/journal_eval")
CFG_FIELDS = (
    "instructor",
    "policy",
    "coder",
    "evaluation_mode",
    "feedback_mode",
    "recursion_hint",
    "adapter_scale",
    "slm_decode",
    "seed",
    "max_attempts",
)


def read_json(path: Path) -> Optional[dict]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def as_bool(value) -> bool:
    if isinstance(value, bool):
        return value
    return str(value).strip().lower() in {"1", "true", "yes"}


def mean(values: Iterable[float]) -> float:
    vals = list(values)
    return sum(vals) / len(vals) if vals else 0.0


def rate(rows: List[dict], key: str) -> float:
    return mean(1.0 if as_bool(row.get(key)) else 0.0 for row in rows)


def dataset_size(cfg: dict) -> int:
    dataset = cfg.get("dataset")
    if not dataset:
        return 0
    path = Path(dataset)
    try:
        return sum(1 for child in path.iterdir() if child.is_dir())
    except OSError:
        return 0


def load_trajectories(condition: Path) -> Dict[str, dict]:
    result: Dict[str, dict] = {}
    tdir = condition / "trajectories"
    if not tdir.exists():
        return result
    for path in sorted(tdir.glob("*.json")):
        row = read_json(path)
        if not row:
            continue
        task_id = str(row.get("task_id") or path.stem)
        result[task_id] = row
    return result


def completed_metric_keys(mode: str, max_attempts: int) -> List[str]:
    if mode == "independent":
        ks = [k for k in (1, 3, 5) if k <= max_attempts]
        return [f"pass_at_{k}" for k in ks] + [f"aligned_pass_at_{k}" for k in ks]
    ks = [k for k in (1, 3, 5, 7) if k <= max_attempts]
    return [f"repair_at_{k}" for k in ks] + [f"aligned_repair_at_{k}" for k in ks]


def condition_summary(condition: Path) -> Tuple[dict, Dict[str, dict]]:
    cfg = read_json(condition / "config.json") or {}
    trajectories = load_trajectories(condition)
    rows = list(trajectories.values())
    n_completed = len(rows)
    expected = dataset_size(cfg)
    progress = n_completed / expected if expected else 0.0
    mode = str(cfg.get("evaluation_mode") or (rows[0].get("evaluation_mode") if rows else "repair"))
    max_attempts = int(cfg.get("max_attempts") or 7)

    summary = {
        "condition": condition.name,
        **{f"cfg_{key}": cfg.get(key) for key in CFG_FIELDS},
        "status": "complete" if (condition / "summary.json").exists() else ("partial" if n_completed else "started"),
        "n_completed": n_completed,
        "n_expected": expected,
        "progress_fraction": progress,
        "progress_percent": 100.0 * progress,
        "verified_count": sum(1 for row in rows if as_bool(row.get("any_verified"))),
        "aligned_count": sum(1 for row in rows if as_bool(row.get("any_aligned"))),
        "aligned_nonrecursive_count": sum(1 for row in rows if as_bool(row.get("any_aligned_nonrecursive"))),
        "any_verified_rate": rate(rows, "any_verified"),
        "any_aligned_rate": rate(rows, "any_aligned"),
        "aligned_nonrecursive_rate": rate(rows, "any_aligned_nonrecursive"),
        "mean_recursive_generation_rate": mean(float(row.get("recursive_generation_rate", 0) or 0) for row in rows),
        "mean_attempts_or_samples_run": mean(float(row.get("samples_or_attempts_run", 0) or 0) for row in rows),
        "mean_coder_tokens": mean(
            float(row.get("total_coder_prompt_tokens", 0) or 0)
            + float(row.get("total_coder_completion_tokens", 0) or 0)
            for row in rows
        ),
        "mean_instructor_tokens": mean(
            float(row.get("total_instructor_prompt_tokens", 0) or 0)
            + float(row.get("total_instructor_completion_tokens", 0) or 0)
            + float(row.get("total_slm_generated_tokens", 0) or 0)
            for row in rows
        ),
        "mean_latency_sec": mean(float(row.get("total_latency_sec", 0) or 0) for row in rows),
        "runtime_error_tasks_in_completed": sum(1 for row in rows if int(row.get("api_or_runtime_errors", 0) or 0) > 0),
    }

    aligned_first = [
        int(row["first_aligned_verified_index"])
        for row in rows
        if row.get("first_aligned_verified_index") not in (None, "")
    ]
    summary["mean_attempt_to_aligned_success_among_successes"] = mean(aligned_first)

    for key in completed_metric_keys(mode, max_attempts):
        summary[key] = rate(rows, key)

    return summary, trajectories


def binom_two_sided(k: int, n: int) -> float:
    if n == 0:
        return 1.0
    k = min(k, n - k)
    p = 2.0 * sum(math.comb(n, i) for i in range(k + 1)) / (2**n)
    return min(1.0, p)


def bootstrap_diff(a: List[int], b: List[int], iters: int, seed: int) -> Tuple[float, float, float]:
    n = len(a)
    if n == 0:
        return 0.0, 0.0, 0.0
    obs = sum(x - y for x, y in zip(a, b)) / n
    if iters <= 0:
        return obs, float("nan"), float("nan")
    rng = random.Random(seed)
    vals = []
    for _ in range(iters):
        idx = [rng.randrange(n) for __ in range(n)]
        vals.append(sum(a[i] - b[i] for i in idx) / n)
    vals.sort()
    lo = vals[int(0.025 * iters)]
    hi = vals[min(iters - 1, int(0.975 * iters))]
    return obs, lo, hi


def comparison_signature(summary: dict) -> tuple:
    """Only pair conditions that differ in instructor/policy, not evaluation setup."""
    return tuple(
        summary.get(f"cfg_{key}")
        for key in (
            "coder",
            "evaluation_mode",
            "feedback_mode",
            "recursion_hint",
            "adapter_scale",
            "slm_decode",
            "seed",
            "max_attempts",
        )
    )


def pairwise_rows(
    summaries: List[dict],
    trajectories: Dict[str, Dict[str, dict]],
    bootstrap_iters: int,
    min_paired: int,
) -> List[dict]:
    pairs: List[dict] = []
    for i in range(len(summaries)):
        for j in range(i + 1, len(summaries)):
            sa, sb = summaries[i], summaries[j]
            if comparison_signature(sa) != comparison_signature(sb):
                continue
            A = trajectories[sa["condition"]]
            B = trajectories[sb["condition"]]
            ids = sorted(set(A) & set(B))
            if len(ids) < min_paired:
                continue
            xa = [1 if as_bool(A[t].get("any_aligned")) else 0 for t in ids]
            xb = [1 if as_bool(B[t].get("any_aligned")) else 0 for t in ids]
            n10 = sum(x == 1 and y == 0 for x, y in zip(xa, xb))
            n01 = sum(x == 0 and y == 1 for x, y in zip(xa, xb))
            seed_material = f"{sa['condition']}|{sb['condition']}"
            seed = sum(ord(ch) for ch in seed_material) + 20260811
            diff, lo, hi = bootstrap_diff(xa, xb, bootstrap_iters, seed)
            pairs.append(
                {
                    "condition_a": sa["condition"],
                    "condition_b": sb["condition"],
                    "coder": sa.get("cfg_coder"),
                    "n_paired_completed": len(ids),
                    "aligned_rate_a_on_paired": sum(xa) / len(ids),
                    "aligned_rate_b_on_paired": sum(xb) / len(ids),
                    "difference_a_minus_b": diff,
                    "bootstrap95_lo": lo,
                    "bootstrap95_hi": hi,
                    "mcnemar_n10": n10,
                    "mcnemar_n01": n01,
                    "mcnemar_exact_p": binom_two_sided(min(n10, n01), n10 + n01),
                    "INTERIM_ONLY": True,
                }
            )
    return pairs


def write_csv(path: Path, rows: List[dict]) -> None:
    if not rows:
        path.write_text("", encoding="utf-8")
        return
    fields = sorted({key for row in rows for key in row})
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def pct(value) -> str:
    return f"{100.0 * float(value or 0):.1f}%"


def short_model(value: object) -> str:
    text = str(value or "")
    text = text.replace("openai:", "").replace("hf:", "")
    if "/" in text:
        text = text.split("/")[-1]
    return text[:34]


def write_markdown(root: Path, summaries: List[dict], pairs: List[dict]) -> Path:
    out = root / "live_report.md"
    lines = [
        "# Proof2Silicon Journal Evaluation — LIVE SNAPSHOT",
        "",
        f"Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        "> **INTERIM ONLY.** Conditions are still running; completed tasks can be a biased subset. "
        "Do not quote these percentages or p-values as final paper results.",
        "",
        "## Current condition results",
        "",
        "| Coder | Instructor | Policy | Progress | Verify | Aligned | Aligned+Nonrec | Recursion | Mean attempts |",
        "|---|---|---|---:|---:|---:|---:|---:|---:|",
    ]
    ordered = sorted(
        summaries,
        key=lambda row: (
            str(row.get("cfg_coder") or ""),
            -int(row.get("n_completed") or 0),
            str(row.get("cfg_instructor") or ""),
            str(row.get("cfg_policy") or ""),
        ),
    )
    for row in ordered:
        policy = row.get("cfg_policy") or "—"
        progress = f"{row['n_completed']}/{row['n_expected'] or '?'}"
        lines.append(
            "| {coder} | {instr} | {policy} | {progress} | {verify} | {aligned} | {nonrec} | {rec} | {attempts:.2f} |".format(
                coder=short_model(row.get("cfg_coder")),
                instr=row.get("cfg_instructor") or "?",
                policy=policy,
                progress=progress,
                verify=pct(row.get("any_verified_rate")),
                aligned=pct(row.get("any_aligned_rate")),
                nonrec=pct(row.get("aligned_nonrecursive_rate")),
                rec=pct(row.get("mean_recursive_generation_rate")),
                attempts=float(row.get("mean_attempts_or_samples_run") or 0),
            )
        )

    if pairs:
        lines += [
            "",
            "## Comparable paired snapshots",
            "",
            "Only conditions with identical coder/evaluation settings are paired, using task IDs completed in both.",
            "",
            "| Coder | A | B | n paired | Δ aligned (A-B) | 95% bootstrap | McNemar p |",
            "|---|---|---|---:|---:|---:|---:|",
        ]
        top_pairs = sorted(pairs, key=lambda row: (-int(row["n_paired_completed"]), -abs(float(row["difference_a_minus_b"]))))
        for row in top_pairs[:50]:
            a = row["condition_a"].split("__coder_")[0]
            b = row["condition_b"].split("__coder_")[0]
            lines.append(
                "| {coder} | `{a}` | `{b}` | {n} | {diff:+.1%} | [{lo:+.1%}, {hi:+.1%}] | {p:.4g} |".format(
                    coder=short_model(row.get("coder")),
                    a=a[-45:],
                    b=b[-45:],
                    n=row["n_paired_completed"],
                    diff=float(row["difference_a_minus_b"]),
                    lo=float(row["bootstrap95_lo"]),
                    hi=float(row["bootstrap95_hi"]),
                    p=float(row["mcnemar_exact_p"]),
                )
            )

    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return out


def print_terminal(summaries: List[dict], top: int) -> None:
    print("\nINTERIM LIVE SNAPSHOT — do not report as final")
    print(f"{'coder':34} {'instructor':10} {'policy':8} {'done':>8} {'verify':>8} {'aligned':>8} {'nonrec':>8} {'recur':>8}")
    print("-" * 104)
    rows = sorted(
        summaries,
        key=lambda row: (
            str(row.get("cfg_coder") or ""),
            str(row.get("cfg_instructor") or ""),
            str(row.get("cfg_policy") or ""),
        ),
    )
    if top > 0:
        rows = rows[:top]
    for row in rows:
        done = f"{row['n_completed']}/{row['n_expected'] or '?'}"
        print(
            f"{short_model(row.get('cfg_coder')):34} "
            f"{str(row.get('cfg_instructor') or '?'):10} "
            f"{str(row.get('cfg_policy') or '-'):8} "
            f"{done:>8} "
            f"{pct(row.get('any_verified_rate')):>8} "
            f"{pct(row.get('any_aligned_rate')):>8} "
            f"{pct(row.get('aligned_nonrecursive_rate')):>8} "
            f"{pct(row.get('mean_recursive_generation_rate')):>8}"
        )


def snapshot(args) -> None:
    args.root.mkdir(parents=True, exist_ok=True)
    condition_dirs = [
        path
        for path in sorted(args.root.iterdir())
        if path.is_dir() and path.name != "_slurm" and ((path / "config.json").exists() or (path / "trajectories").exists())
    ]

    summaries: List[dict] = []
    trajectories: Dict[str, Dict[str, dict]] = {}
    for condition in condition_dirs:
        summary, task_rows = condition_summary(condition)
        summaries.append(summary)
        trajectories[condition.name] = task_rows

    pairs = pairwise_rows(
        summaries,
        trajectories,
        bootstrap_iters=args.bootstrap_iters,
        min_paired=args.min_paired,
    )

    write_csv(args.root / "live_conditions.csv", summaries)
    write_csv(args.root / "live_pairwise_stats.csv", pairs)
    report = write_markdown(args.root, summaries, pairs)
    print_terminal(summaries, args.top)
    print(
        f"\nconditions_seen={len(summaries)} conditions_with_completed_tasks="
        f"{sum(int(row['n_completed']) > 0 for row in summaries)} paired_comparisons={len(pairs)}"
    )
    print(args.root / "live_conditions.csv")
    print(args.root / "live_pairwise_stats.csv")
    print(report)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument("--bootstrap-iters", type=int, default=2000, help="Use 0 for a very fast snapshot without bootstrap CIs.")
    parser.add_argument("--min-paired", type=int, default=5, help="Minimum shared completed tasks for an interim pairwise row.")
    parser.add_argument("--top", type=int, default=0, help="Limit terminal rows; 0 prints all conditions.")
    parser.add_argument("--watch-seconds", type=int, default=0, help="Refresh repeatedly every N seconds until Ctrl-C.")
    args = parser.parse_args()

    if args.watch_seconds <= 0:
        snapshot(args)
        return

    try:
        while True:
            print("\033[2J\033[H", end="")
            snapshot(args)
            print(f"\nRefreshing in {args.watch_seconds}s (Ctrl-C to stop) ...")
            time.sleep(args.watch_seconds)
    except KeyboardInterrupt:
        print("\nStopped live monitor.")


if __name__ == "__main__":
    main()
