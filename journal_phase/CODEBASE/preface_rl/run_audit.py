"""Per-run JSON/JSONL audit logging for journal experiments."""

import json
import os
import re
import time
from pathlib import Path
from typing import Any, Dict, Optional


def _run_dir() -> Path:
    value = os.environ.get("PROOF2SILICON_RUN_DIR")
    if not value:
        study = os.environ.get("PROOF2SILICON_STUDY_ID", "unscoped")
        experiment = os.environ.get("PROOF2SILICON_EXPERIMENT", "unknown")
        value = (
            "/u/mjha1/Proof2Silicon/journal_phase/journal_runs/"
            "journal_{}_{}".format(study, experiment)
        )
    path = Path(value)
    path.mkdir(parents=True, exist_ok=True)
    return path


def _slug(value: str) -> str:
    text = re.sub(r"[^A-Za-z0-9_.-]+", "_", str(value or "unknown"))
    return text.strip("_") or "unknown"


def _atomic_json(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")
    os.replace(str(tmp), str(path))


def append_jsonl(relative_path: str, payload: Dict[str, Any]) -> Path:
    path = _run_dir() / relative_path
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload, ensure_ascii=False) + "\n")
        handle.flush()
        os.fsync(handle.fileno())
    return path


def save_interaction(
    kind: str,
    prompt: str,
    response: str,
    metadata: Optional[Dict[str, Any]] = None,
) -> Path:
    kind = _slug(kind)
    now_ns = time.time_ns()
    timestamp = time.strftime("%Y-%m-%dT%H:%M:%S%z")
    experiment = os.environ.get("PROOF2SILICON_EXPERIMENT", "unknown")
    payload: Dict[str, Any] = {
        "timestamp": timestamp,
        "timestamp_ns": now_ns,
        "study_id": os.environ.get("PROOF2SILICON_STUDY_ID"),
        "experiment": experiment,
        "slurm_job_id": os.environ.get("SLURM_JOB_ID"),
        "slurm_array_job_id": os.environ.get("SLURM_ARRAY_JOB_ID"),
        "slurm_array_task_id": os.environ.get("SLURM_ARRAY_TASK_ID"),
        "kind": kind,
        "prompt": prompt,
        "response": response,
        "metadata": metadata or {},
    }
    directory = _run_dir() / "artifacts" / kind
    filename = "{}_{}_{}.json".format(kind, _slug(experiment), now_ns)
    path = directory / filename
    _atomic_json(path, payload)
    append_jsonl("audit/{}_interactions.jsonl".format(kind), payload)
    return path


def save_slm_interaction(prompt: str, response: str) -> None:
    save_interaction(
        "slm",
        prompt,
        response,
        {
            "slm_model": os.environ.get("SLM_MODEL_NAME", "Qwen/Qwen3-1.7B"),
        },
    )


def save_attempt_record(payload: Dict[str, Any]) -> None:
    enriched = dict(payload)
    enriched.setdefault("study_id", os.environ.get("PROOF2SILICON_STUDY_ID"))
    enriched.setdefault("experiment", os.environ.get("PROOF2SILICON_EXPERIMENT"))
    enriched.setdefault("slurm_job_id", os.environ.get("SLURM_JOB_ID"))
    enriched.setdefault("slurm_array_job_id", os.environ.get("SLURM_ARRAY_JOB_ID"))
    enriched.setdefault("slurm_array_task_id", os.environ.get("SLURM_ARRAY_TASK_ID"))
    now_ns = time.time_ns()
    enriched.setdefault("timestamp_ns", now_ns)

    append_jsonl("audit/attempts.jsonl", enriched)

    epoch = enriched.get("epoch", "unknown")
    iteration = enriched.get("iteration", "unknown")
    task_name = enriched.get("task_name") or enriched.get("subfolder") or "task"
    stem = "epoch_{}_iter_{}_{}_{}".format(
        _slug(epoch), _slug(iteration), _slug(task_name), now_ns
    )
    _atomic_json(_run_dir() / "artifacts" / "attempts" / (stem + ".json"), enriched)

    # Explicit Dafny artifact: preserves the exact candidate, verifier stdout,
    # verifier outcome, and whether the semantic judge was invoked/passed.
    dafny_record = {
        "timestamp": enriched.get("timestamp"),
        "timestamp_ns": enriched.get("timestamp_ns"),
        "study_id": enriched.get("study_id"),
        "experiment": enriched.get("experiment"),
        "slurm_job_id": enriched.get("slurm_job_id"),
        "slurm_array_job_id": enriched.get("slurm_array_job_id"),
        "slurm_array_task_id": enriched.get("slurm_array_task_id"),
        "task_name": task_name,
        "epoch": epoch,
        "iteration": iteration,
        "dafny_code": enriched.get("dafny_code", ""),
        "verifier_outcome": enriched.get("verifier_outcome"),
        "verifier_output": enriched.get("verifier_output", ""),
        "semantic_judge_invoked": enriched.get("verifier_outcome") == "success",
        "semantic_judge_pass": enriched.get("semantic_judge_pass"),
        "accepted_success": enriched.get("accepted_success"),
        "reward": enriched.get("reward"),
        "reward_breakdown": enriched.get("reward_breakdown", {}),
    }
    append_jsonl("audit/dafny_outputs.jsonl", dafny_record)
    _atomic_json(
        _run_dir() / "artifacts" / "dafny" / (stem + ".json"),
        dafny_record,
    )
