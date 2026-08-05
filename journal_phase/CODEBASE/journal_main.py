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
    """Install run-scoped logs and prompt-policy quality controls."""
    import preface_rl.envs as envs_module
    import preface_rl.llm as llm_module
    import preface_rl.slm as slm_module
    import preface_rl.slm_generation_guard as generation_guard
    from preface_rl.prompts import ErrorPrompt, ShortPrompt
    from preface_rl.run_audit import save_attempt_record, save_interaction, save_slm_interaction

    def scoped_prompt_response(prompt, response, save_dir, metadata=None):
        kind = "judge" if "judge" in str(save_dir).lower() else "llm"
        save_interaction(kind, prompt, response, metadata)

    llm_module.save_prompt_response = scoped_prompt_response
    slm_module._save_slm_interaction = save_slm_interaction
    generation_guard.install_slm_generation_guard(slm_module)

    original_compute_total_reward = envs_module.compute_total_reward

    def compute_total_reward_with_prompt_quality(*args, **kwargs):
        breakdown = original_compute_total_reward(*args, **kwargs)
        quality_reward = generation_guard.current_quality_reward()
        breakdown["prompt_quality_reward"] = quality_reward
        breakdown["total_reward"] = float(breakdown["total_reward"]) + quality_reward
        return breakdown

    envs_module.compute_total_reward = compute_total_reward_with_prompt_quality

    # The AST helper historically returned -3 as a fallback sentinel. That is
    # not a parse-error count, so expose a separate boolean status and keep the
    # plotted count nonnegative.
    original_ast_analysis = envs_module.DafnyEnv.run_ast_plugin_and_analyzer

    def run_ast_with_nonnegative_metrics(self, dafny_file_path):
        structure, parse_errors = original_ast_analysis(self, dafny_file_path)
        self._last_ast_fallback_used = bool(parse_errors < 0)
        return structure, max(0, int(parse_errors))

    envs_module.DafnyEnv.run_ast_plugin_and_analyzer = run_ast_with_nonnegative_metrics

    original_step = envs_module.DafnyEnv.step

    def step_with_quality_state(self, *args, **kwargs):
        quality_report = generation_guard.current_quality_report()
        sampled_kl = generation_guard.current_sampled_kl()
        # Override the legacy hard-coded 0.0 passed by the training loop.
        kwargs["kl_value"] = sampled_kl
        reward, done, info = original_step(self, *args, **kwargs)
        reward_breakdown = dict(info.get("reward_breakdown", {}) or {})
        ast_fallback_used = bool(getattr(self, "_last_ast_fallback_used", False))
        if self.last_attempt_info is not None:
            self.last_attempt_info["slm_quality_analysis"] = quality_report
            self.last_attempt_info["reward_breakdown"] = reward_breakdown
            self.last_attempt_info["sampled_kl_to_base"] = sampled_kl
            self.last_attempt_info["ast_fallback_used"] = ast_fallback_used
        info["slm_quality_analysis"] = quality_report
        info["sampled_kl_to_base"] = sampled_kl
        info["ast_fallback_used"] = ast_fallback_used
        try:
            if wandb.run is not None:
                wandb.log(
                    {
                        "step/kl_value": sampled_kl,
                        "step/ast_fallback_used": int(ast_fallback_used),
                        "step/parse_errors": max(0, int(info.get("parse_errors", 0))),
                    }
                )
        except Exception:
            pass
        return reward, done, info

    envs_module.DafnyEnv.step = step_with_quality_state

    def build_state_prompt_with_quality_feedback(self):
        if self.current_iteration == 0 or self.last_attempt_info is None:
            return ShortPrompt(self.prompt)
        return ErrorPrompt(
            self.last_attempt_info.get("error_output", ""),
            self.prompt,
            self.last_attempt_info.get("code", ""),
            str(self.last_attempt_info.get("reward", 0.0)),
            previous_instruction=self.last_attempt_info.get("instruction_text", ""),
            previous_llm_response=self.last_attempt_info.get("llm_response", ""),
            quality_analysis=self.last_attempt_info.get("slm_quality_analysis", {}),
            reward_breakdown=self.last_attempt_info.get("reward_breakdown", {}),
        )

    envs_module.DafnyEnv.build_state_prompt = build_state_prompt_with_quality_feedback

    original_append = envs_module.append_to_weighted_dataset

    def append_and_audit(path, record):
        original_append(path, record)
        if isinstance(record, dict) and "reward_breakdown" in record:
            enriched = dict(record)
            enriched.setdefault("task_name", Path(path).parent.name)
            enriched.setdefault("task_output_path", str(path))
            enriched.setdefault("slm_quality_analysis", generation_guard.current_quality_report())
            enriched.setdefault("sampled_kl_to_base", generation_guard.current_sampled_kl())
            save_attempt_record(enriched)

    envs_module.append_to_weighted_dataset = append_and_audit
    logging.info(
        "Run-scoped audit, prompt-quality feedback, sampled KL, and nonnegative parse metrics enabled at %s",
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
        "artifacts/dafny",
        "artifacts/ast",
        "audit",
        "checkpoints",
        "workspaces",
    ]:
        (run_dir / relative).mkdir(parents=True, exist_ok=True)

    install_run_scoped_audit_hooks()
    from preface_rl.parallel_isolation import install_parallel_environment_isolation

    install_parallel_environment_isolation()

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
        "openai_generator_max_tokens": int(os.environ.get("OPENAI_GENERATOR_MAX_TOKENS", "16384")),
        "openai_generator_retry_max_tokens": int(os.environ.get("OPENAI_GENERATOR_RETRY_MAX_TOKENS", "24576")),
        "hf_generator_model": os.environ.get(
            "HF_GENERATOR_MODEL", "Qwen/Qwen3-Coder-30B-A3B-Instruct:cheapest"
        ),
        "judge_model": os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.4"),
        "judge_reasoning": os.environ.get("DAFNY_JUDGE_REASONING", "low"),
        "judge_scope": "same_problem_only_not_correctness",
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
        "parallel_workspace_isolation": True,
        "ast_cross_process_lock": True,
        "ast_fallback_separate_from_parse_errors": True,
        "qwen_chat_template": True,
        "qwen_thinking_disabled": True,
        "slm_max_prompt_tokens": 1600,
        "slm_max_new_tokens": 800,
        "slm_repetition_guard": True,
        "prompt_quality_auxiliary_reward": True,
        "prompt_quality_textual_feedback": True,
        "ppo_chat_prompt_alignment": True,
        "sampled_kl_to_base_enabled": True,
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
                "resume/reward_history_length": int(resume_metadata.get("reward_history_length", 0)),
                "resume/processed_sample_count": int(resume_metadata.get("processed_sample_count", 0)),
                "audit/run_scoped_logging_enabled": 1,
                "audit/parallel_workspace_isolation_enabled": 1,
                "audit/ast_cross_process_lock_enabled": 1,
                "slm/qwen_chat_template_enabled": 1,
                "slm/qwen_thinking_disabled": 1,
                "slm/repetition_guard_enabled": 1,
                "slm/prompt_quality_auxiliary_reward_enabled": 1,
                "slm/prompt_quality_textual_feedback_enabled": 1,
                "slm/ppo_chat_prompt_alignment_enabled": 1,
                "slm/sampled_kl_to_base_enabled": 1,
                "slm/max_prompt_tokens": 1600,
                "slm/max_new_tokens": 800,
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
        from preface_rl.policy_tokenizer import wrap_policy_tokenizer

        tokenizer = wrap_policy_tokenizer(tokenizer)
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
                "slm/trainable_parameter_change_detected_this_allocation": int(abs(norm_delta) > 1e-12),
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
