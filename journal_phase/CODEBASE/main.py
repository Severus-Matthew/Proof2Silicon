# main.py

import argparse
import concurrent.futures
import gc
import json
import logging
import multiprocessing as mp
import os
from typing import Any, Dict, Optional, Tuple

import torch
import wandb
import wandb
# wandb.init(settings=wandb.Settings(init_timeout=400))  # Sets timeout to 300 seconds

from preface_rl.envs import DafnyEnv
from preface_rl.slm import (
    initialize_slm,
    train_slm_with_grpo,
    save_checkpoint_safely,
)

# --------------------------------------------------
# Logging
# --------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("training.log"),
        logging.StreamHandler(),
    ],
)

# --------------------------------------------------
# Constants
# --------------------------------------------------
CHECKPOINT_DIR = "/u/mjha1/Proof2Silicon/journal_phase/checkpoints_3" #HERE_FOR_CHANGE
LORA_ADAPTER_DIR = "/u/mjha1/Proof2Silicon/journal_phase/lora_adapters_3" #HERE_FOR_CHANGE
ROOT_DIRECTORY = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset_2" #HERE_FOR_CHANGE

os.makedirs(CHECKPOINT_DIR, exist_ok=True)
os.makedirs(LORA_ADAPTER_DIR, exist_ok=True)


def collect_trainable_subfolders(root_directory: str):
    subfolders = []
    for entry in sorted(os.listdir(root_directory)):
        subfolder_path = os.path.join(root_directory, entry)
        if not os.path.isdir(subfolder_path):
            continue

        description_file = os.path.join(subfolder_path, "detailed_description.txt")
        if not os.path.exists(description_file):
            logging.warning(f"Skipping {entry}: missing {description_file}")
            continue

        subfolders.append(
            {
                "entry": entry,
                "subfolder_path": subfolder_path,
                "description_file": description_file,
            }
        )
    return subfolders

# def process_one_subfolder(
#     entry: str,
#     subfolder_path: str,
#     args: argparse.Namespace,
#     # FIX 3: accept the parent W&B run-id so the worker can re-attach to the
#     # same run and call wandb.log() directly without spawning a new run.
#     wandb_run_id: Optional[str] = None,
# ) -> Tuple[str, Optional[Dict[str, Any]]]:
#     """
#     Worker-side function.

#     FIX 3: We now call wandb.init(id=wandb_run_id, resume="allow") inside
#     the worker so that all step/batch/epoch logs are written directly into
#     the parent run instead of being silently dropped.  The parent process
#     still receives the summary dict and logs job-level aggregates.
#     """
#     worker_wandb_enabled = False
#     try:
#         # FIX 3: re-attach to the parent W&B run inside the worker process.
#         # Without this, wandb.run is None in the worker and every wandb.log()
#         # call in train_slm_with_grpo is silently skipped.
#         if wandb_run_id is not None:
#             try:
#                 wandb.init(
#                     id="tmxqi16n",
#                     project="Proof2Silicon-journal_phase_CODEBASE",
#                     entity="drprofmjha-university-of-illinois-urbana-champaign",
#                     resume="allow",
#                     settings=wandb.Settings(init_timeout=800),
#                 )
#                 worker_wandb_enabled = True
#                 logging.info(f"Worker for {entry}: re-attached to W&B run {wandb_run_id}")
#             except Exception as wb_err:
#                 logging.warning(f"Worker for {entry}: could not re-attach to W&B: {wb_err}")

#         model, tokenizer = initialize_slm(args.checkpoint)

#         epoch_dir = os.path.join(
#             "/u/mjha1/Proof2Silicon/journal_phase/dataset_new",
#             f"epoch_0_{entry}",
#         )
#         result_file = os.path.join(epoch_dir, "iteration_1_results.json")

#         if os.path.exists(result_file):
#             logging.info(
#                 f"Skipping {entry} because it appears already processed "
#                 f"(found {result_file})"
#             )
#             return entry, {
#                 "status": "skipped",
#                 "entry": entry,
#                 "reason": f"Found existing result file: {result_file}",
#                 "metrics_dir": os.path.join(subfolder_path, "metrics"),
#             }

#         description_file = os.path.join(subfolder_path, "detailed_description.txt")
#         if not os.path.exists(description_file):
#             logging.warning(f"Skipping {entry}: missing {description_file}")
#             return entry, {
#                 "status": "skipped",
#                 "entry": entry,
#                 "reason": f"Missing file: {description_file}",
#                 "metrics_dir": os.path.join(subfolder_path, "metrics"),
#             }

#         subfolders = collect_trainable_subfolders(ROOT_DIRECTORY)
#         logging.info(f"Found {len(subfolders)} trainable subfolders in {ROOT_DIRECTORY}")

#         logging.info("Starting training across all subfolders")

#         total_rewards, successful_examples = train_slm_with_grpo(
#             subfolders=subfolders,
#             slm=model,
#             global_tokenizer=tokenizer,
#             num_epochs=5,
#             checkpoint_path=args.checkpoint,
#             start_epoch=args.start_epoch,
#         )

#         checkpoint_dir = os.path.dirname(args.checkpoint)
#         os.makedirs(checkpoint_dir, exist_ok=True)

#         checkpoint_data = {
#             "model_state_dict": model.state_dict(),
#             "entry": entry,
#             "rewards": total_rewards,
#             "successful_examples": successful_examples,
#         }

#         checkpoint_saved = save_checkpoint_safely(checkpoint_data, args.checkpoint)
#         if not checkpoint_saved:
#             logging.warning(f"Failed to save checkpoint after processing {entry}")
#         else:
#             logging.info(f"Successfully saved checkpoint after processing {entry}")

#         result: Dict[str, Any] = {
#             "status": "success",
#             "entry": "ALL_SUBFOLDERS",
#             "total_reward": float(sum(total_rewards)) if total_rewards else 0.0,
#             "num_epochs": len(total_rewards),
#             "final_epoch_reward": float(total_rewards[-1]) if total_rewards else 0.0,
#             "successful_examples_count": len(successful_examples),
#             "metrics_dir": os.path.join(ROOT_DIRECTORY, "metrics"),
#             "checkpoint_path": args.checkpoint,
#             "checkpoint_saved": checkpoint_saved,
#         }

#         return entry, result

#     except Exception as e:
#         logging.exception(f"Error while processing subfolder {entry}: {e}")
#         return entry, {
#             "status": "failed",
#             "entry": entry,
#             "error": str(e),
#             "metrics_dir": os.path.join(subfolder_path, "metrics"),
#         }

#     finally:
#         # FIX 3: flush and close the worker's W&B connection before the
#         # process exits so no metrics are lost.
#         if worker_wandb_enabled:
#             try:
#                 wandb.finish()
#             except Exception:
#                 pass
#         try:
#             torch.cuda.empty_cache()
#         except Exception:
#             pass
#         gc.collect()


# def log_subfolder_metrics_to_parent_run(entry: str, result: Dict[str, Any]) -> None:
#     """
#     Parent-only W&B logging for a completed worker result.
#     Reads saved metrics from disk and logs them into the single parent run.

#     FIX 3: Also reads step_metrics.json (previously never read) so that
#     per-step reward, error-type, and structure metrics appear in W&B.
#     """
#     metrics_dir = result.get("metrics_dir")
#     if not metrics_dir:
#         return

#     # --- epoch-level metrics (previously existing) ---
#     epoch_metrics_path = os.path.join(metrics_dir, "epoch_metrics.json")
#     if os.path.exists(epoch_metrics_path):
#         try:
#             with open(epoch_metrics_path, "r", encoding="utf-8") as f:
#                 epoch_metrics = json.load(f)

#             epoch_rewards          = epoch_metrics.get("epoch_rewards", [])
#             training_losses        = epoch_metrics.get("training_losses", [])
#             avg_outcome_rewards    = epoch_metrics.get("avg_outcome_rewards", [])
#             avg_progress_rewards   = epoch_metrics.get("avg_progress_rewards", [])
#             avg_structure_rewards  = epoch_metrics.get("avg_structure_rewards", [])
#             avg_efficiency_rewards = epoch_metrics.get("avg_efficiency_rewards", [])
#             avg_stability_rewards  = epoch_metrics.get("avg_stability_rewards", [])

#             max_len = max(
#                 len(epoch_rewards), len(training_losses),
#                 len(avg_outcome_rewards), len(avg_progress_rewards),
#                 len(avg_structure_rewards), len(avg_efficiency_rewards),
#                 len(avg_stability_rewards), 0,
#             )

#             for epoch_idx in range(max_len):
#                 wandb.log(
#                     {
#                         "epoch/subfolder": entry,
#                         "epoch/index": epoch_idx,
#                         "epoch/reward":           epoch_rewards[epoch_idx]          if epoch_idx < len(epoch_rewards)          else 0.0,
#                         "epoch/training_loss":    training_losses[epoch_idx]        if epoch_idx < len(training_losses)        else 0.0,
#                         "epoch/outcome_reward":   avg_outcome_rewards[epoch_idx]    if epoch_idx < len(avg_outcome_rewards)    else 0.0,
#                         "epoch/progress_reward":  avg_progress_rewards[epoch_idx]   if epoch_idx < len(avg_progress_rewards)   else 0.0,
#                         "epoch/structure_reward": avg_structure_rewards[epoch_idx]  if epoch_idx < len(avg_structure_rewards)  else 0.0,
#                         "epoch/efficiency_reward":avg_efficiency_rewards[epoch_idx] if epoch_idx < len(avg_efficiency_rewards) else 0.0,
#                         "epoch/stability_reward": avg_stability_rewards[epoch_idx]  if epoch_idx < len(avg_stability_rewards)  else 0.0,
#                     }
#                 )
#         except Exception as e:
#             logging.warning(f"Could not log epoch metrics for {entry}: {e}")

#     # FIX 3: --- step-level metrics (previously never logged to W&B) ---
#     step_metrics_path = os.path.join(metrics_dir, "step_metrics.json")
#     if os.path.exists(step_metrics_path):
#         try:
#             with open(step_metrics_path, "r", encoding="utf-8") as f:
#                 step_metrics = json.load(f)

#             episode_rewards        = step_metrics.get("episode_rewards", [])
#             outcome_rewards        = step_metrics.get("outcome_rewards", [])
#             progress_rewards       = step_metrics.get("progress_rewards", [])
#             structure_rewards      = step_metrics.get("structure_rewards", [])
#             efficiency_rewards     = step_metrics.get("efficiency_rewards", [])
#             stability_rewards      = step_metrics.get("stability_rewards", [])
#             success_rates          = step_metrics.get("success_rates", [])
#             error_counts           = step_metrics.get("error_counts", [])
#             kl_values              = step_metrics.get("kl_values", [])
#             prompt_token_increases = step_metrics.get("prompt_token_increases", [])

#             num_steps = max(len(episode_rewards), len(outcome_rewards), len(success_rates), 0)
#             for step_idx in range(num_steps):
#                 wandb.log(
#                     {
#                         "step_replay/subfolder":             entry,
#                         "step_replay/index":                 step_idx,
#                         "step_replay/reward_total":          episode_rewards[step_idx]        if step_idx < len(episode_rewards)        else 0.0,
#                         "step_replay/reward_outcome":        outcome_rewards[step_idx]        if step_idx < len(outcome_rewards)        else 0.0,
#                         "step_replay/reward_progress":       progress_rewards[step_idx]       if step_idx < len(progress_rewards)       else 0.0,
#                         "step_replay/reward_structure":      structure_rewards[step_idx]      if step_idx < len(structure_rewards)      else 0.0,
#                         "step_replay/reward_efficiency":     efficiency_rewards[step_idx]     if step_idx < len(efficiency_rewards)     else 0.0,
#                         "step_replay/reward_stability":      stability_rewards[step_idx]      if step_idx < len(stability_rewards)      else 0.0,
#                         "step_replay/success":               success_rates[step_idx]          if step_idx < len(success_rates)          else 0.0,
#                         "step_replay/error_count":           error_counts[step_idx]           if step_idx < len(error_counts)           else 0,
#                         "step_replay/kl_value":              kl_values[step_idx]              if step_idx < len(kl_values)              else 0.0,
#                         "step_replay/prompt_token_increase": prompt_token_increases[step_idx] if step_idx < len(prompt_token_increases) else 0,
#                     }
#                 )
#         except Exception as e:
#             logging.warning(f"Could not log step metrics for {entry}: {e}")


# def main():
#     parser = argparse.ArgumentParser(
#         description="Run Dafny code generation with a single parent W&B run"
#     )
#     parser.add_argument("--temperature", type=float, default=0.75)
#     parser.add_argument(
#         "--checkpoint",
#         type=str,
#         default="/u/mjha1/Proof2Silicon/journal_phase/checkpoints_2/run_CHK/final_model_new.pt",
#     )
#     parser.add_argument("--start_epoch", type=int, default=0)
#     parser.add_argument("--wandb_project", type=str, default="dafny-rl_new2")
#     parser.add_argument(
#         "--wandb_entity",
#         type=str,
#         default="drprofmjha-university-of-illinois-urbana-champaign",
#     )
#     parser.add_argument(
#         "--max_workers",
#         type=int,
#         default=1,
#         help="Number of worker processes. Use 1 if using a single GPU.",
#     )
#     args = parser.parse_args()

#     logging.info("Starting execution...")
#     logging.info(f"Processing folders in {ROOT_DIRECTORY}")

#     subfolder_entries = []
#     for entry in os.listdir(ROOT_DIRECTORY):
#         subfolder_path = os.path.join(ROOT_DIRECTORY, entry)
#         if not os.path.isdir(subfolder_path):
#             continue
#         subfolder_entries.append((entry, subfolder_path))

#     results: Dict[str, Dict[str, Any]] = {}

#     # FIX 3: capture run id before spawning workers
#     parent_run = wandb.init(
#         project="Proof2Silicon-journal_phase_CODEBASE",
#         entity="drprofmjha-university-of-illinois-urbana-champaign",
#         name="Proof2Silicon-journal_phase_CODEBASE",
#         id="tmxqi16n",
#         settings=wandb.Settings(init_timeout=800),
#         resume="allow",
#     )
#     wandb_run_id: Optional[str] = parent_run.id if parent_run else None

#     job_completed_subfolders = 0
#     job_failed_subfolders = 0
#     job_skipped_subfolders = 0
#     job_total_reward = 0.0
#     job_total_successes = 0

#     try:
#         with concurrent.futures.ProcessPoolExecutor(
#             max_workers=args.max_workers
#         ) as executor:
#             # FIX 3: pass wandb_run_id to every worker
#             future_to_entry = {
#                 executor.submit(
#                     process_one_subfolder, entry, subfolder_path, args, wandb_run_id
#                 ): entry
#                 for entry, subfolder_path in subfolder_entries
#             }

#             for future in concurrent.futures.as_completed(future_to_entry):
#                 entry = future_to_entry[future]

#                 try:
#                     entry_key, result = future.result()

#                     if result is None:
#                         continue

#                     results[entry_key] = result
#                     status = result.get("status", "unknown")

#                     if status == "success":
#                         job_completed_subfolders += 1
#                         job_total_reward += result.get("total_reward", 0.0)
#                         job_total_successes += result.get("successful_examples_count", 0)

#                         wandb.log(
#                             {
#                                 "job/completed_subfolders": job_completed_subfolders,
#                                 "job/failed_subfolders": job_failed_subfolders,
#                                 "job/skipped_subfolders": job_skipped_subfolders,
#                                 "job/total_reward_so_far": job_total_reward,
#                                 "job/total_successes_so_far": job_total_successes,
#                                 "subfolder_summary/name": entry,
#                                 "subfolder_summary/total_reward": result.get("total_reward", 0.0),
#                                 "subfolder_summary/final_epoch_reward": result.get("final_epoch_reward", 0.0),
#                                 "subfolder_summary/successful_examples_count": result.get("successful_examples_count", 0),
#                                 "subfolder_summary/num_epochs": result.get("num_epochs", 0),
#                                 "subfolder_summary/checkpoint_saved": int(bool(result.get("checkpoint_saved", False))),
#                             }
#                         )

#                         # Replay disk-saved metrics into parent run for history charts.
#                         # When workers log live (wandb_run_id != None) this is a
#                         # redundant confirmation pass; harmless.
#                         log_subfolder_metrics_to_parent_run(entry, result)

#                     elif status == "skipped":
#                         job_skipped_subfolders += 1
#                         wandb.log(
#                             {
#                                 "job/completed_subfolders": job_completed_subfolders,
#                                 "job/failed_subfolders": job_failed_subfolders,
#                                 "job/skipped_subfolders": job_skipped_subfolders,
#                                 "subfolder_summary/name": entry,
#                                 "subfolder_summary/skipped": 1,
#                             }
#                         )

#                     else:
#                         job_failed_subfolders += 1
#                         wandb.log(
#                             {
#                                 "job/completed_subfolders": job_completed_subfolders,
#                                 "job/failed_subfolders": job_failed_subfolders,
#                                 "job/skipped_subfolders": job_skipped_subfolders,
#                                 "subfolder_summary/name": entry,
#                                 "subfolder_summary/failed": 1,
#                             }
#                         )

#                 except Exception as exc:
#                     job_failed_subfolders += 1
#                     logging.exception(f"{entry} generated an exception: {exc}")
#                     wandb.log(
#                         {
#                             "job/completed_subfolders": job_completed_subfolders,
#                             "job/failed_subfolders": job_failed_subfolders,
#                             "job/skipped_subfolders": job_skipped_subfolders,
#                             "subfolder_summary/name": entry,
#                             "subfolder_summary/failed": 1,
#                         }
#                     )

#         logging.info("Saving final results...")
#         with open(os.path.join(ROOT_DIRECTORY, "training_results.json"), "w", encoding="utf-8") as f:
#             json.dump(results, f, indent=2)

#         logging.info("Training completed successfully!")

#     finally:
#         wandb.finish()
#         try:
#             torch.cuda.empty_cache()
#         except Exception:
#             pass
#         gc.collect()
def main():
    parser = argparse.ArgumentParser(
        description="Run Dafny code generation with a single W&B run"
    )
    parser.add_argument("--temperature", type=float, default=0.75)
    parser.add_argument(
        "--checkpoint",
        type=str,
        default="/u/mjha1/Proof2Silicon/journal_phase/checkpoints_3/run_CHK/final_model_new.pt", #HERE_FOR_CHANGE
    )
    parser.add_argument("--start_epoch", type=int, default=0)
    parser.add_argument("--wandb_project", type=str, default="dafny-rl_new2")
    parser.add_argument(
        "--wandb_entity",
        type=str,
        default="drprofmjha-university-of-illinois-urbana-champaign",
    )
    args = parser.parse_args()

    logging.info("Starting execution...")
    logging.info(f"Processing folders in {ROOT_DIRECTORY}")

    # Initialize W&B ONCE in the main process
    wandb.init(
        project="Proof2Silicon-journal_phase_CODEBASE",
        entity="drprofmjha-university-of-illinois-urbana-champaign",
        name="Proof2Silicon-journal_phase_CODEBASE",
        # id="tmxqi16n",
        resume="allow",
        settings=wandb.Settings(init_timeout=800),
    )

    try:
        subfolders = collect_trainable_subfolders(ROOT_DIRECTORY)
        logging.info(f"Found {len(subfolders)} trainable subfolders in {ROOT_DIRECTORY}")

        model, tokenizer = initialize_slm(args.checkpoint)

        total_rewards, successful_examples = train_slm_with_grpo(
            subfolders=subfolders,
            slm=model,
            global_tokenizer=tokenizer,
            num_epochs=5,
            checkpoint_path=args.checkpoint,
            start_epoch=args.start_epoch,
        )

        # Save final checkpoint once
        checkpoint_dir = os.path.dirname(args.checkpoint)
        os.makedirs(checkpoint_dir, exist_ok=True)

        checkpoint_data = {
            "model_state_dict": model.state_dict(),
            "rewards": total_rewards,
            "successful_examples": successful_examples,
        }

        checkpoint_saved = save_checkpoint_safely(checkpoint_data, args.checkpoint)
        if not checkpoint_saved:
            logging.warning("Failed to save final checkpoint")
        else:
            logging.info(f"Successfully saved final checkpoint to {args.checkpoint}")

        # Final summary logs
        wandb.log(
            {
                "job/final_total_reward": float(sum(total_rewards)) if total_rewards else 0.0,
                "job/final_epoch_reward": float(total_rewards[-1]) if total_rewards else 0.0,
                "job/final_successful_examples_count": len(successful_examples),
                "job/num_epochs_completed": len(total_rewards),
                "job/checkpoint_saved": int(checkpoint_saved),
            }
        )

    except Exception as e:
        logging.exception(f"Fatal error in main: {e}")
        raise

    finally:
        try:
            wandb.finish()
        except Exception:
            pass

if __name__ == "__main__":
    mp.set_start_method("spawn", force=True)
    try:
        main()
    except Exception as e:
        print(f"Error during execution: {str(e)}")
        import traceback
        traceback.print_exc()
        try:
            torch.cuda.empty_cache()
        except Exception:
            pass
        gc.collect()
        wandb.finish()
