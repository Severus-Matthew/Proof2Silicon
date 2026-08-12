#!/usr/bin/env python3
"""Generate tiered Proof2Silicon journal evaluation condition matrices.

Output TSV columns:
name, instructor, policy, coder, evaluation_mode, feedback_mode,
recursion_hint, adapter_scale, slm_decode, max_attempts, seed,
external_instructor_model
"""
from __future__ import annotations
import argparse
import csv
from pathlib import Path

CORE_CODERS = [
    "openai:gpt-5.4-mini",
    "openai:gpt-5.4",
    "hf:Qwen/Qwen3-Coder-30B-A3B-Instruct:featherless-ai",
    "hf:mistralai/Devstral-Small-2-24B-Instruct-2512",
]
EXTENDED_CODERS = [
    "hf:Qwen/Qwen3-Coder-Next",
    "hf:zai-org/GLM-4.5-Air",
]
POLICIES = ["openai", "qwen", "mixed"]
SEED = 20260811


def add(rows, name, instructor, coder, *, policy="na", mode="repair", feedback="full",
        recursion=True, scale=1.0, decode="train_match", attempts=7,
        seed=SEED, external="openai:gpt-5.4"):
    rows.append({
        "name": name,
        "instructor": instructor,
        "policy": policy or "na",
        "coder": coder,
        "evaluation_mode": mode,
        "feedback_mode": feedback,
        "recursion_hint": "1" if recursion else "0",
        "adapter_scale": str(scale),
        "slm_decode": decode,
        "max_attempts": str(attempts),
        "seed": str(seed),
        "external_instructor_model": external,
    })


def build(suite: str):
    rows = []
    if suite in {"core", "full"}:
        for coder in CORE_CODERS:
            tag = coder.replace(":", "_").replace("/", "_")
            add(rows, f"none__{tag}", "none", coder)
            add(rows, f"untrained__{tag}", "untrained", coder)
            add(rows, f"self__{tag}", "self", coder)
            add(rows, f"external_gpt54__{tag}", "external", coder)
            for policy in POLICIES:
                add(rows, f"trained_{policy}__{tag}", "trained", coder, policy=policy)

    if suite in {"transfer", "full"}:
        for coder in EXTENDED_CODERS:
            tag = coder.replace(":", "_").replace("/", "_")
            add(rows, f"transfer_none__{tag}", "none", coder)
            add(rows, f"transfer_untrained__{tag}", "untrained", coder)
            add(rows, f"transfer_self__{tag}", "self", coder)
            add(rows, f"transfer_external__{tag}", "external", coder)
            add(rows, f"transfer_mixed__{tag}", "trained", coder, policy="mixed")

    if suite in {"ablations", "full"}:
        reps = [CORE_CODERS[0], CORE_CODERS[2]]
        for coder in reps:
            tag = coder.replace(":", "_").replace("/", "_")
            for policy in POLICIES:
                for scale in (0.0, 0.25, 0.5, 1.0, 1.5):
                    add(rows, f"lora_{policy}_{scale:g}__{tag}", "trained", coder, policy=policy, scale=scale)
        for coder in reps:
            tag = coder.replace(":", "_").replace("/", "_")
            for decode in ("greedy", "train_match"):
                add(rows, f"decode_mixed_{decode}__{tag}", "trained", coder, policy="mixed", decode=decode)
        for coder in reps:
            tag = coder.replace(":", "_").replace("/", "_")
            for instructor, policy in (("none", "na"), ("untrained", "na"), ("trained", "mixed")):
                for recursion in (False, True):
                    add(rows, f"rechint_{instructor}_{policy}_{int(recursion)}__{tag}", instructor, coder,
                        policy=policy, recursion=recursion)
        for coder in reps:
            tag = coder.replace(":", "_").replace("/", "_")
            for feedback in ("full", "coder_only", "none"):
                add(rows, f"feedback_mixed_{feedback}__{tag}", "trained", coder, policy="mixed", feedback=feedback)

    if suite in {"passk", "full"}:
        reps = [CORE_CODERS[0], CORE_CODERS[2]]
        for coder in reps:
            tag = coder.replace(":", "_").replace("/", "_")
            for instructor, policy in (("none", "na"), ("untrained", "na"), ("self", "na"),
                                       ("external", "na"), ("trained", "mixed")):
                add(rows, f"passk_{instructor}_{policy}__{tag}", instructor, coder,
                    policy=policy, mode="independent", feedback="none", attempts=5)

    unique, seen = [], set()
    for row in rows:
        key = tuple(row[k] for k in row if k != "name")
        if key not in seen:
            seen.add(key)
            unique.append(row)
    return unique


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--suite", choices=["core", "transfer", "ablations", "passk", "full"], default="full")
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    rows = build(args.suite)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    fields = list(rows[0].keys()) if rows else []
    with args.output.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fields, delimiter="\t")
        w.writeheader(); w.writerows(rows)
    print(f"Wrote {len(rows)} conditions to {args.output}")

if __name__ == "__main__": main()
