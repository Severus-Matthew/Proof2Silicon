#!/usr/bin/env python3
"""Entry point for the four controlled journal training runs."""

import argparse
import gc
import logging
import os
from pathlib import Path

import torch
import wandb

from main import ROOT_DIRECTORY, collect_trainable_subfolders
from preface_rl.resumable_training import infer_resume_position, train_slm_resumable
from preface_rl.slm_qwen3 import initialize_slm, trainable_parameter_snapshot


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)


def install_run_scoped_audit_hooks() -> None:
    """Redirect SLM/LLM/judge/attempt records into this experiment's run dir."""
    import preface_rl.envs as envs_module
    import preface_rl.llm as llm_module
    import preface_rl.slm as slm_module
    from preface_rl.run_audit import (
        save_attempt_record,
        save_interaction,
        save_slm_interaction,
    )

    def scoped_prompt_response(prompt, response, save_dir, metadata=None):
        kind = "judge" if "judge" in str(save_dir).lower() else "llm"
        save_interaction(kind, prompt, response, metadata)

    llm_module.save_prompt_response = scoped_prompt_response
    slm_module._save_slm_interaction = save_slm_interaction

    original_append = envs_module.append_to_weighted_dataset

    def append_and_audit(path, record):
        original_append(path, record)
        if isinstance(record, dict) and "reward_breakdown" in record:
            enriched = dict(record)
            enriched.setdefault("task_name", Path(path).parent.name)
            enriched.setdefault("task_output_path", str(path))
            save_attempt_record(enriched)

    envs_module.append_to_weighted_dataset = append_and_audit
    logging.info(
        "Run-scoped audit logging enabled at %s",
        os.environ.get("PROOF2SILICON_RUN_DIR"),
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--checkpoint", required=True)
    parser.add_argument("--start_epoch", type=int, default=0)
    parser.add_argument("--num_epochs", type=int, default=5)
    parser.add_argument("--wandb_project", default="proof2silicon-journal-final")
    parser.add_argument(
        "--wandb_entity",
        default="drprofmjha-university-of-illinois-urbana-champaign",
    )
    args = parser.parse_args()

    experiment = os.environ.get("PROOF2SILICON_EXPERIMENT", "unknown")
    run_name = os.environ.get("WANDB_RUN_NAME", "journal-{}".format(experiment))
    run_id = os.environ.get("WANDB_RUN_ID")
    run_dir = Path(
        os.environ.get(
            "PROOF2SILICON_RUN_DIR",
            "/u/mjha1/Proof2Silicon/journal_phase/journal_runs/{}".format(run_name),
        )
    )
    run_dir.mkdir(parents=True, exist_ok=True)
    for relative in [
        "artifacts/slm",
        "artifacts/llm",
        "artifacts/judge",
        "artifacts/attempts",
        "audit",
        "checkpoints",
    ]:
        (run_dir / relative).mkdir(parents=True, exist_ok=True)

    install_run_scoped_audit_hooks()

    effective_start_epoch, resume_metadata = infer_resume_position(
        args.checkpoint,
        args.start_epoch,
    )
    is_resume = os.path.exists(args.checkpoint)

    config = {
        "experiment": experiment,
        "slm_model": os.environ.get("SLM_MODEL_NAME", "Qwen/Qwen3-1.7B"),
        "generator_mode": os.environ.get("DAFNY_GENERATOR_MODE", "deepseek"),
        "deepseek_generator_model": os.environ.get("DEEPSEEK_GENERATOR_MODEL", "deepseek-chat"),
        "openai_generator_model": os.environ.get("OPENAI_GENERATOR_MODEL", "gpt-5.4-mini"),
        "openai_generator_reasoning": os.environ.get("OPENAI_GENERATOR_REASONING", "medium"),
        "hf_generator_model": os.environ.get(
            "HF_GENERATOR_MODEL", "Qwen/Qwen3-Coder-30B-A3B-Instruct:cheapest"
        ),
        "judge_model": os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.4"),
        "judge_reasoning": os.environ.get("DAFNY_JUDGE_REASONING", "high"),
        "mixed_seed": int(os.environ.get("DAFNY_MIXED_SEED", "20260802")),
        "num_epochs": args.num_epochs,
        "requested_start_epoch": args.start_epoch,
        "effective_start_epoch": effective_start_epoch,
        "checkpoint": args.checkpoint,
        "dataset_root": ROOT_DIRECTORY,
        "run_dir": str(run_dir),
        "slurm_job_id": os.environ.get("SLURM_JOB_ID"),
        "slurm_array_job_id": os.environ.get("SLURM_ARRAY_JOB_ID"),
        "slurm_array_task_id": os.environ.get("SLURM_ARRAY_TASK_ID"),
        "study_id": os.environ.get("PROOF2SILICON_STUDY_ID"),
        "is_resume": is_resume,
        "resume_metadata": resume_metadata,
    }

    run = wandb.init(
        project=args.wandb_project,
        entity=args.wandb_entity,
        name=run_name,
        id=run_id,
        resume="allow" if run_id else None,
        dir=os.environ.get("WANDB_DIR", str(run_dir / "wandb")),
        config=config,
        settings=wandb.Settings(init_timeout=800),
        tags=["journal-final", experiment, "qwen3-1.7b-slm"],
        group="proof2silicon-four-generator-study",
        job_type=experiment,
    )

    try:
        wandb.log(
            {
                "resume/is_resume": int(is_resume),
                "resume/effective_start_epoch": effective_start_epoch,
                "resume/checkpoint_epoch": int(resume_metadata.get("checkpoint_epoch", -1)),
                "resume/reward_history_length": int(
                    resume_metadata.get("reward_history_length", 0)
                ),
                "resume/processed_sample_count": int(
                    resume_metadata.get("processed_sample_count", 0)
                ),
                "audit/run_scoped_logging_enabled": 1,
            }
        )

        if effective_start_epoch >= args.num_epochs:
            logging.info(
                "Training already complete: effective_start_epoch=%s num_epochs=%s",
                effective_start_epoch,
                args.num_epochs,
            )
            wandb.log({"job/already_complete": 1})
            return

        subfolders = collect_trainable_subfolders(ROOT_DIRECTORY)
        if not subfolders:
            raise RuntimeError("No trainable subfolders found in {}".format(ROOT_DIRECTORY))
        wandb.log({"data/trainable_subfolders": len(subfolders)})

        model, tokenizer = initialize_slm(None)
        initial = trainable_parameter_snapshot(model)
        wandb.log(
            {
                "slm/initial_trainable_tensor_count": initial["tensor_count"],
                "slm/initial_trainable_parameter_count": initial["parameter_count"],
                "slm/initial_l2_norm": initial["l2_norm"],
                "slm/initial_max_abs": initial["max_abs"],
            }
        )

        total_rewards, successful_examples = train_slm_resumable(
            subfolders=subfolders,
            slm=model,
            global_tokenizer=tokenizer,
            num_epochs=args.num_epochs,
            checkpoint_path=args.checkpoint,
            start_epoch=effective_start_epoch,
            run_dir=str(run_dir),
        )

        final = trainable_parameter_snapshot(model)
        norm_delta = final["l2_norm"] - initial["l2_norm"]
        checkpoint_exists = os.path.exists(args.checkpoint)
        wandb.log(
            {
                "slm/final_l2_norm": final["l2_norm"],
                "slm/final_max_abs": final["max_abs"],
                "slm/l2_norm_delta_this_allocation": norm_delta,
                "slm/trainable_parameter_change_detected_this_allocation": int(
                    abs(norm_delta) > 1e-12
                ),
                "job/final_total_reward": float(sum(total_rewards)) if total_rewards else 0.0,
                "job/final_epoch_reward": float(total_rewards[-1]) if total_rewards else 0.0,
                "job/final_successful_examples_count": len(successful_examples),
                "job/num_epochs_completed": len(total_rewards),
                "job/checkpoint_saved": int(checkpoint_exists),
            }
        )

        artifact = wandb.Artifact(
            "{}-checkpoint".format(run_name),
            type="model",
            metadata=config,
        )
        if checkpoint_exists:
            artifact.add_file(args.checkpoint)
            run.log_artifact(artifact, aliases=["latest", "epoch-{}".format(len(total_rewards))])
        else:
            logging.warning("Expected checkpoint not found: %s", args.checkpoint)

    finally:
        wandb.finish()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        gc.collect()


if __name__ == "__main__":
    main()
