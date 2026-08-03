"""Resume helpers for journal training.

This module keeps a small atomic sidecar next to each rolling checkpoint.  It
makes W&B custom step axes monotonic across Slurm restarts and infers the first
unfinished epoch from the saved PPO checkpoint.
"""

import json
import os
from pathlib import Path
from typing import Any, Dict, Tuple

import torch
import wandb

from .slm import train_slm_with_grpo as _train_slm_with_grpo


def _atomic_json_write(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")
    os.replace(str(tmp), str(path))


def _load_json(path: Path) -> Dict[str, Any]:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def infer_resume_position(checkpoint_path: str, requested_start_epoch: int = 0) -> Tuple[int, Dict[str, Any]]:
    """Return the first unfinished epoch and checkpoint metadata.

    Checkpoints are written only after the PPO update for an epoch. Therefore
    ``checkpoint['epoch'] + 1`` is the correct next epoch. A partially collected
    epoch is intentionally replayed after a timeout because its policy update was
    never committed.
    """
    metadata: Dict[str, Any] = {}
    path = Path(checkpoint_path)
    if path.exists():
        try:
            checkpoint = torch.load(str(path), map_location="cpu")
            metadata = {
                "checkpoint_epoch": int(checkpoint.get("epoch", -1)),
                "reward_history_length": len(checkpoint.get("rewards", [])),
                "processed_sample_count": len(checkpoint.get("processed_samples", [])),
            }
            requested_start_epoch = max(
                int(requested_start_epoch),
                metadata["checkpoint_epoch"] + 1,
            )
        except Exception as exc:
            metadata = {"checkpoint_read_error": str(exc)}
    return int(requested_start_epoch), metadata


def train_slm_resumable(
    *,
    subfolders,
    slm,
    global_tokenizer,
    num_epochs: int,
    checkpoint_path: str,
    start_epoch: int,
    run_dir: str,
):
    """Run the existing PPO trainer with restart-safe W&B custom steps."""
    state_path = Path(run_dir) / "resume_state.json"
    state = _load_json(state_path)
    state.setdefault("global_step", 0)
    state.setdefault("log_events", 0)
    state.setdefault("resume_count", 0)
    state["resume_count"] += 1
    state["last_start_epoch"] = int(start_epoch)
    _atomic_json_write(state_path, state)

    # Define custom axes once per resumed W&B run. This keeps journal plots
    # continuous even though the trainer's local counter restarts at zero.
    if wandb.run is not None:
        wandb.define_metric("journal_step")
        wandb.define_metric("step/*", step_metric="journal_step")
        wandb.define_metric("journal_epoch")
        wandb.define_metric("epoch/*", step_metric="journal_epoch")

    original_log = wandb.log

    def restart_safe_log(data=None, *args, **kwargs):
        if not isinstance(data, dict):
            return original_log(data, *args, **kwargs)

        payload = dict(data)
        if "step/global_index" in payload:
            state["global_step"] = int(state.get("global_step", 0)) + 1
            payload["step/global_index"] = state["global_step"]
            payload["journal_step"] = state["global_step"]
        elif any(str(key).startswith("step/") for key in payload):
            payload["journal_step"] = int(state.get("global_step", 0))

        epoch_value = payload.get("epoch")
        if epoch_value is not None:
            payload["journal_epoch"] = int(epoch_value)
        elif "epoch/avg_reward" in payload:
            payload["journal_epoch"] = int(start_epoch) + 1

        state["log_events"] = int(state.get("log_events", 0)) + 1
        # Persist every step and every epoch; these writes are tiny and atomic.
        if "journal_step" in payload or "journal_epoch" in payload:
            _atomic_json_write(state_path, state)
        return original_log(payload, *args, **kwargs)

    wandb.log = restart_safe_log
    try:
        return _train_slm_with_grpo(
            subfolders=subfolders,
            slm=slm,
            global_tokenizer=global_tokenizer,
            num_epochs=num_epochs,
            checkpoint_path=checkpoint_path,
            start_epoch=start_epoch,
        )
    finally:
        wandb.log = original_log
        state["completed_call"] = True
        _atomic_json_write(state_path, state)
