#!/usr/bin/env python3
"""Audit which P2S problem.txt prompts contain explicit bit-width requirements.

Run this before the P2S array.  The hardware evaluator's bit checker is
intentionally deterministic, so this report lets us verify that the prompt
wording in the newly added local dataset is actually recognized before spending
API credits.
"""

import argparse
from pathlib import Path

from test_p2s_journal import DEFAULT_DATASET, extract_bit_requirements


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    args = p.parse_args()

    if not args.dataset.is_dir():
        raise SystemExit("Dataset not found: %s" % args.dataset)

    folders = sorted(
        path
        for path in args.dataset.iterdir()
        if path.is_dir() and path.name.startswith("HW_")
    )
    applicable = 0
    missing_problem = 0
    width_counts = {}

    print("P2S bit-width prompt audit")
    print("dataset:", args.dataset)
    print()

    for folder in folders:
        problem_file = folder / "problem.txt"
        if not problem_file.is_file():
            missing_problem += 1
            print("%-10s MISSING problem.txt" % folder.name)
            continue
        text = problem_file.read_text(encoding="utf-8").strip()
        audit = extract_bit_requirements(text)
        widths = audit["requested_widths"]
        if audit["applicable"]:
            applicable += 1
            for width in widths:
                width_counts[width] = width_counts.get(width, 0) + 1
            contexts = " || ".join(
                mention["context"] for mention in audit["mentions"][:3]
            )
            print("%-10s widths=%-16s %s" % (folder.name, str(widths), contexts[:240]))
        else:
            print("%-10s widths=[]  [NO EXPLICIT WIDTH DETECTED]" % folder.name)

    print("\nSummary")
    print("  HW folders:", len(folders))
    print("  explicit-width tasks:", applicable)
    print("  no-width-detected tasks:", len(folders) - applicable - missing_problem)
    print("  missing problem.txt:", missing_problem)
    print("  width counts:", dict(sorted(width_counts.items())))
    print(
        "\nIf a prompt visibly contains a bit width but appears under "
        "NO EXPLICIT WIDTH DETECTED, stop and update the extractor before launch."
    )


if __name__ == "__main__":
    main()
