#!/usr/bin/env python3
"""Generate the hardware Proof2Silicon evaluation matrix.

Seven large downstream coders x five instructor conditions. No self/external
instructor rows are generated. Every condition uses a five-attempt repair
budget. The trained-only bit reminder requested for the hardware study is made
an explicit matrix column so it is auditable rather than hidden.

HF provider routes are API-only; no downstream generator weights are downloaded
locally.
"""

import argparse
import csv
from pathlib import Path

SEED = 20260811
MAX_ATTEMPTS = 5

CODERS = [
    ("hf:deepseek-ai/DeepSeek-V4-Flash:cheapest", "none"),
    ("hf:Qwen/Qwen2.5-Coder-32B-Instruct:cheapest", "none"),
    ("hf:nvidia/NVIDIA-Nemotron-3-Ultra-550B-A55B-NVFP4:fireworks-ai", "none"),
    ("hf:meta-llama/Llama-3.3-70B-Instruct:novita", "none"),
    ("hf:Qwen/Qwen3-Coder-30B-A3B-Instruct:cheapest", "none"),
    ("hf:deepseek-ai/DeepSeek-V3.1:cheapest", "none"),
    ("openai:gpt-5.4-nano", "none"),
]


def tag(coder):
    return coder.replace(":", "_").replace("/", "_")


def make_row(name, instructor, policy, coder, reasoning, bit_reminder):
    return {
        "name": name,
        "instructor": instructor,
        "policy": policy,
        "coder": coder,
        "recursion_hint": "1",
        "adapter_scale": "1.0",
        "slm_decode": "train_match",
        "max_attempts": str(MAX_ATTEMPTS),
        "seed": str(SEED),
        "coder_reasoning": reasoning,
        "trained_bit_reminder": "1" if bit_reminder else "0",
    }


def build():
    rows = []
    for coder, reasoning in CODERS:
        t = tag(coder)
        rows.append(make_row("none__" + t, "none", "na", coder, reasoning, False))
        rows.append(
            make_row("untrained__" + t, "untrained", "na", coder, reasoning, False)
        )
        for policy in ("openai", "qwen", "mixed"):
            rows.append(
                make_row(
                    "trained_%s__%s" % (policy, t),
                    "trained",
                    policy,
                    coder,
                    reasoning,
                    True,
                )
            )
    return rows


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    rows = build()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as f:
        # Bash launchers consume the final TSV column directly. Force Unix line
        # endings so the last value is exactly "0"/"1" rather than "0\r"/"1\r".
        writer = csv.DictWriter(
            f,
            fieldnames=list(rows[0]),
            delimiter="\t",
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(rows)
    print("Wrote %d P2S conditions to %s" % (len(rows), args.output))


if __name__ == "__main__":
    main()
