#!/usr/bin/env python3
"""Generate the post-core large-generator matrix for Input_dataset_3.

This suite intentionally excludes self/external instructors. Each large coder
is evaluated with: none, untrained Qwen3-1.7B, and the three trained policies.
All new repair runs stop after five attempts.

All downstream generators are API-only through Hugging Face Inference Providers.
Provider pins reflect routes that are currently deployed; no downstream generator
weights are downloaded locally.
"""

import argparse
import csv
from pathlib import Path

SEED = 20260811
MAX_ATTEMPTS = 5

CODERS = [
    "hf:deepseek-ai/DeepSeek-V4-Flash:cheapest",
    "hf:Qwen/Qwen2.5-Coder-32B-Instruct:cheapest",
    # Mistral-Large was not exposed as a chat model; GLM-5.2 returned empty
    # responses in our preflight. Use NVIDIA Nemotron 3 Ultra instead: 550B
    # total / 55B active, with a currently deployed Fireworks HF route.
    "hf:nvidia/NVIDIA-Nemotron-3-Ultra-550B-A55B-NVFP4:fireworks-ai",
    # Llama-3.1-70B is not currently deployed through our HF providers. Llama
    # 3.3 keeps the 70B Llama-family tier and has a currently deployed Novita route.
    "hf:meta-llama/Llama-3.3-70B-Instruct:novita",
]


def tag(coder):
    return coder.replace(":", "_").replace("/", "_")


def row(name, instructor, coder, policy="na"):
    return {
        "name": name,
        "instructor": instructor,
        "policy": policy,
        "coder": coder,
        "evaluation_mode": "repair",
        "feedback_mode": "full",
        "recursion_hint": "1",
        "adapter_scale": "1.0",
        "slm_decode": "train_match",
        "max_attempts": str(MAX_ATTEMPTS),
        "seed": str(SEED),
        # Unused because this suite contains no external instructor; retained so
        # the TSV remains compatible with the journal Slurm row schema.
        "external_instructor_model": "openai:gpt-5.4",
    }


def build():
    rows = []
    for coder in CODERS:
        t = tag(coder)
        rows.append(row("none__" + t, "none", coder))
        rows.append(row("untrained__" + t, "untrained", coder))
        for policy in ("openai", "qwen", "mixed"):
            rows.append(row("trained_%s__%s" % (policy, t), "trained", coder, policy))
    return rows


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    rows = build()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]), delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)
    print("Wrote %d conditions to %s" % (len(rows), args.output))


if __name__ == "__main__":
    main()
