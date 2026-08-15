#!/usr/bin/env python3
"""Live/partial summary of p2s_journal_eval condition/HW_XXX results."""

import argparse
import csv
import json
from pathlib import Path

DEFAULT_ROOT = Path("/u/mjha1/Proof2Silicon/journal_phase/p2s_journal_eval")
DEFAULT_DATASET = Path(
    "/u/mjha1/Proof2Silicon/journal_phase/The_hardware_dataset/Sample_dafny"
)


def load(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None


def pct(value):
    return "%5.1f%%" % (100.0 * float(value or 0))


def mean(values):
    values = list(values)
    return sum(values) / len(values) if values else 0.0


def rate(rows, key):
    return sum(bool(row.get(key)) for row in rows) / len(rows) if rows else 0.0


def summarize(condition, expected):
    cfg = load(condition / "config.json") or {}
    rows = []
    for hw_dir in sorted(condition.glob("HW_*")):
        trajectory = load(hw_dir / "trajectory.json")
        if trajectory:
            rows.append(trajectory)
    if not rows:
        return None

    applicable = [r for r in rows if r.get("bit_mapping_applicable")]
    aligned_applicable = [r for r in applicable if r.get("any_aligned")]
    return {
        "condition": condition.name,
        "instructor": cfg.get("instructor"),
        "policy": cfg.get("policy"),
        "coder": cfg.get("coder"),
        "n_done": len(rows),
        "n_expected": expected,
        "verify_at_5": rate(rows, "repair_at_5"),
        "aligned_at_5": rate(rows, "aligned_repair_at_5"),
        "hardware_accepted_at_1": rate(rows, "hardware_accepted_repair_at_1"),
        "hardware_accepted_at_3": rate(rows, "hardware_accepted_repair_at_3"),
        "hardware_accepted_at_5": rate(rows, "hardware_accepted_repair_at_5"),
        "aligned_nonrecursive_bitmapped": rate(
            rows, "any_aligned_nonrecursive_bitmapped"
        ),
        "bit_applicable_tasks_done": len(applicable),
        "bit_presence_rate_applicable": (
            rate(applicable, "any_bit_mapping_present") if applicable else 0.0
        ),
        "bit_given_aligned_applicable": (
            rate(aligned_applicable, "any_aligned_bitmapped")
            if aligned_applicable
            else 0.0
        ),
        "trained_bit_reminder_task_rate": rate(
            rows, "trained_bit_reminder_applied"
        ),
        "mean_recursion": mean(
            float(r.get("recursive_generation_rate", 0) or 0) for r in rows
        ),
        "mean_attempts": mean(
            float(r.get("samples_or_attempts_run", 0) or 0) for r in rows
        ),
        "mean_coder_tokens": mean(
            float(r.get("total_coder_tokens", 0) or 0) for r in rows
        ),
        "runtime_error_rate": (
            sum(int(r.get("api_or_runtime_errors", 0) or 0) > 0 for r in rows)
            / len(rows)
        ),
    }


def short_model(value):
    text = str(value or "").replace("openai:", "").replace("hf:", "")
    if "/" in text:
        text = text.split("/")[-1]
    return text[:38]


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    p.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    args = p.parse_args()

    expected = 0
    if args.dataset.is_dir():
        expected = sum(
            1
            for path in args.dataset.iterdir()
            if path.is_dir() and path.name.startswith("HW_")
        )

    summaries = []
    if args.root.is_dir():
        for condition in sorted(
            path
            for path in args.root.iterdir()
            if path.is_dir() and not path.name.startswith("_")
        ):
            row = summarize(condition, expected)
            if row:
                summaries.append(row)

    print("\nP2S LIVE SNAPSHOT -- all success metrics capped at 5 attempts")
    print(
        "%-38s %-10s %-7s %9s %7s %7s %7s %7s %7s %7s"
        % (
            "coder",
            "instr",
            "policy",
            "done",
            "ver@5",
            "align@5",
            "HW@1",
            "HW@3",
            "HW@5",
            "bit",
        )
    )
    print("-" * 125)
    for row in summaries:
        done = "%d/%s" % (row["n_done"], row["n_expected"] or "?")
        print(
            "%-38s %-10s %-7s %9s %7s %7s %7s %7s %7s %7s"
            % (
                short_model(row["coder"]),
                str(row["instructor"] or "?"),
                str(row["policy"] or "-"),
                done,
                pct(row["verify_at_5"]),
                pct(row["aligned_at_5"]),
                pct(row["hardware_accepted_at_1"]),
                pct(row["hardware_accepted_at_3"]),
                pct(row["hardware_accepted_at_5"]),
                pct(row["bit_presence_rate_applicable"]),
            )
        )

    out = args.root / "live_p2s_conditions.csv"
    if summaries:
        fields = list(summaries[0])
        with out.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fields)
            writer.writeheader()
            writer.writerows(summaries)
    print("\nconditions=%d" % len(summaries))
    print("CSV:", out)


if __name__ == "__main__":
    main()
