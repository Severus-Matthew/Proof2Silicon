#!/usr/bin/env python3
"""Paired diagnostic for P2S conditions where SLM guidance may hurt a coder.

Compares completed HW_* trajectories for the same coder between the direct
``none`` baseline and trained/untrained controller conditions.  This is a
diagnostic only; it does not change or rescore any experiment.
"""

import argparse
import json
from pathlib import Path

DEFAULT_ROOT = Path("/u/mjha1/Proof2Silicon/journal_phase/p2s_journal_eval")


def load(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None


def read_condition(path):
    cfg = load(path / "config.json") or {}
    rows = {}
    for hw in path.glob("HW_*"):
        d = load(hw / "trajectory.json")
        if d:
            rows[hw.name] = d
    return cfg, rows


def first_attempt(row):
    attempts = row.get("attempts") or []
    return attempts[0] if attempts else {}


def mean(vals):
    vals = list(vals)
    return sum(vals) / len(vals) if vals else 0.0


def pct(x):
    return "%5.1f%%" % (100.0 * x)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    args = p.parse_args()

    conditions = []
    for path in sorted(args.root.iterdir() if args.root.is_dir() else []):
        if not path.is_dir() or path.name.startswith("_"):
            continue
        cfg, rows = read_condition(path)
        if not rows:
            continue
        conditions.append((path, cfg, rows))

    by_coder = {}
    for path, cfg, rows in conditions:
        coder = cfg.get("coder")
        instr = cfg.get("instructor")
        policy = cfg.get("policy")
        by_coder.setdefault(coder, []).append((path, instr, policy, rows))

    for coder, group in sorted(by_coder.items(), key=lambda x: str(x[0])):
        none = next((g for g in group if g[1] == "none"), None)
        if none is None:
            continue
        none_rows = none[3]
        print("\n" + "=" * 100)
        print("CODER:", coder)
        print("direct none tasks:", len(none_rows))

        for path, instr, policy, rows in group:
            if instr == "none":
                continue
            common = sorted(set(none_rows) & set(rows))
            if not common:
                continue

            base_hw5 = sum(bool(none_rows[t].get("hardware_accepted")) for t in common)
            cond_hw5 = sum(bool(rows[t].get("hardware_accepted")) for t in common)
            base_a1 = sum(bool(first_attempt(none_rows[t]).get("hardware_accepted")) for t in common)
            cond_a1 = sum(bool(first_attempt(rows[t]).get("hardware_accepted")) for t in common)

            lost = [
                t for t in common
                if none_rows[t].get("hardware_accepted") and not rows[t].get("hardware_accepted")
            ]
            gained = [
                t for t in common
                if rows[t].get("hardware_accepted") and not none_rows[t].get("hardware_accepted")
            ]
            lost_a1 = [
                t for t in common
                if first_attempt(none_rows[t]).get("hardware_accepted")
                and not first_attempt(rows[t]).get("hardware_accepted")
            ]
            gained_a1 = [
                t for t in common
                if first_attempt(rows[t]).get("hardware_accepted")
                and not first_attempt(none_rows[t]).get("hardware_accepted")
            ]

            slm_tokens = mean(float(rows[t].get("total_slm_generated_tokens", 0) or 0) for t in common)
            recur_base = mean(float(none_rows[t].get("recursive_generation_rate", 0) or 0) for t in common)
            recur_cond = mean(float(rows[t].get("recursive_generation_rate", 0) or 0) for t in common)
            bit_base = mean(bool(none_rows[t].get("any_bit_mapping_present")) for t in common)
            bit_cond = mean(bool(rows[t].get("any_bit_mapping_present")) for t in common)

            label = instr if instr != "trained" else "trained-" + str(policy)
            if "deploy_repair_only" in path.name:
                label += " [repair-only]"

            print("\n%-34s paired n=%d" % (label, len(common)))
            print("  HW@5: none %s  condition %s  delta %+5.1f pp" % (
                pct(base_hw5 / len(common)),
                pct(cond_hw5 / len(common)),
                100.0 * (cond_hw5 - base_hw5) / len(common),
            ))
            print("  HW@1: none %s  condition %s  delta %+5.1f pp" % (
                pct(base_a1 / len(common)),
                pct(cond_a1 / len(common)),
                100.0 * (cond_a1 - base_a1) / len(common),
            ))
            print("  flips by @5: lost=%d gained=%d net=%+d" % (len(lost), len(gained), len(gained) - len(lost)))
            print("  flips at @1: lost=%d gained=%d net=%+d" % (len(lost_a1), len(gained_a1), len(gained_a1) - len(lost_a1)))
            print("  bit presence: none %s  condition %s" % (pct(bit_base), pct(bit_cond)))
            print("  recursion:    none %s  condition %s" % (pct(recur_base), pct(recur_cond)))
            print("  mean SLM generated tokens/task: %.1f" % slm_tokens)
            if lost:
                print("  first lost tasks:", ",".join(lost[:15]))
            if gained:
                print("  first gained tasks:", ",".join(gained[:15]))


if __name__ == "__main__":
    main()
