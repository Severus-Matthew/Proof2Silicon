#!/usr/bin/env python3
"""Verify that trainable SLM parameters actually change across checkpoints."""
import argparse
import hashlib
import json
import os
import sys

import torch


def tensor_digest(tensor):
    array = tensor.detach().cpu().contiguous().numpy()
    return hashlib.sha256(array.tobytes()).hexdigest()


def load_state(path):
    checkpoint = torch.load(path, map_location="cpu")
    state = checkpoint.get("model_state_dict", checkpoint)
    if not isinstance(state, dict):
        raise ValueError("Checkpoint has no state dictionary: {}".format(path))
    return state


def is_trainable_key(name):
    low = name.lower()
    return "lora_" in low or "value_head" in low


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("before")
    parser.add_argument("after")
    parser.add_argument("--json", dest="json_path", default=None)
    args = parser.parse_args()

    before = load_state(args.before)
    after = load_state(args.after)
    shared = sorted(set(before) & set(after))
    trainable = [key for key in shared if is_trainable_key(key)]

    changed = []
    unchanged = []
    total_l2 = 0.0
    max_abs = 0.0
    for key in trainable:
        a = before[key].float()
        b = after[key].float()
        if a.shape != b.shape:
            changed.append({"name": key, "reason": "shape_changed"})
            continue
        delta = b - a
        l2 = float(torch.linalg.vector_norm(delta).item())
        local_max = float(delta.abs().max().item()) if delta.numel() else 0.0
        total_l2 += l2
        max_abs = max(max_abs, local_max)
        item = {
            "name": key,
            "l2_delta": l2,
            "max_abs_delta": local_max,
            "before_sha256": tensor_digest(before[key]),
            "after_sha256": tensor_digest(after[key]),
        }
        if l2 > 0.0:
            changed.append(item)
        else:
            unchanged.append(item)

    report = {
        "before": os.path.abspath(args.before),
        "after": os.path.abspath(args.after),
        "shared_parameter_count": len(shared),
        "trainable_parameter_tensor_count": len(trainable),
        "changed_trainable_tensor_count": len(changed),
        "unchanged_trainable_tensor_count": len(unchanged),
        "sum_l2_delta": total_l2,
        "max_abs_delta": max_abs,
        "training_change_detected": bool(changed),
        "changed": changed,
        "unchanged": unchanged,
    }

    print(json.dumps({
        "trainable_parameter_tensor_count": len(trainable),
        "changed_trainable_tensor_count": len(changed),
        "unchanged_trainable_tensor_count": len(unchanged),
        "sum_l2_delta": total_l2,
        "max_abs_delta": max_abs,
        "training_change_detected": bool(changed),
    }, indent=2))

    if args.json_path:
        with open(args.json_path, "w", encoding="utf-8") as handle:
            json.dump(report, handle, indent=2)

    if not trainable:
        print("ERROR: no LoRA/value-head tensors found", file=sys.stderr)
        return 3
    if not changed:
        print("ERROR: trainable tensors did not change", file=sys.stderr)
        return 4
    return 0


if __name__ == "__main__":
    sys.exit(main())
