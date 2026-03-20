import json
import os
import re
import time
def append_to_weighted_dataset(file_path: str, example: dict) -> None:
    with open(file_path, "a") as f:
        json.dump(example, f)
        f.write("\n")


def extract_dafny_code(text: str) -> str:
    pattern_snippet = r"```dafny(.*?)```"
    snippets = re.findall(pattern_snippet, text, re.DOTALL)
    trimmed_snippet = ""
    if snippets:
        trimmed_snippet = snippets[-1].strip()
    return trimmed_snippet



def save_iteration_results(
    subfolder_path: str,
    iteration: int,
    epoch: int,
    reward: float,
    error_output: str,
    code: str,
    error_count: int,
    reward_breakdown: dict | None = None,
    error_counts_by_type: dict | None = None,
    structure_features: dict | None = None,
    prompt_token_increase: int = 0,
    kl_value: float = 0.0,
    parse_errors: int = 0,
) -> None:
    try:
        folder_name = os.path.basename(subfolder_path)
        root_dir = "/mnt/shared/gpfs/home/manvij2/journal_phase/dataset"
        os.makedirs(root_dir, exist_ok=True)

        epoch_dir = os.path.join(root_dir, f"epoch_{epoch}_{folder_name}")
        os.makedirs(epoch_dir, exist_ok=True)

        results_file = os.path.join(epoch_dir, f"iteration_{iteration}_results.json")
        with open(results_file, "w", encoding="utf-8") as f:
            json.dump(
                {
                    "reward": reward,
                    "reward_breakdown": reward_breakdown or {},
                    "error_count": error_count,
                    "error_counts_by_type": error_counts_by_type or {},
                    "structure_features": structure_features or {},
                    "prompt_token_increase": prompt_token_increase,
                    "kl_value": kl_value,
                    "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                    "folder": folder_name,
                    "iteration": iteration,
                    "epoch": epoch,
                    "parse_errors": parse_errors,
                },
                f,
                indent=2,
            )

        code_file = os.path.join(epoch_dir, f"iteration_{iteration}_code.dfy")
        with open(code_file, "w", encoding="utf-8") as f:
            f.write(code)

        error_file = os.path.join(epoch_dir, f"iteration_{iteration}_error.txt")
        with open(error_file, "w", encoding="utf-8") as f:
            f.write(error_output)

    except Exception as e:
        print(f"Error saving iteration results: {str(e)}")



def save_epoch_summary(
    subfolder_path: str, epoch: int, total_reward: float, successful_examples_count: int, error_tree
) -> None:
    try:
        folder_name = os.path.basename(subfolder_path)
        root_dir = "/mnt/shared/gpfs/home/manvij2/journal_phase/dataset"

        # Create root directory if it doesn't exist
        os.makedirs(root_dir, exist_ok=True)

        # Create epoch directory
        epoch_dir = os.path.join(root_dir, f"epoch_{epoch}_{folder_name}")
        os.makedirs(epoch_dir, exist_ok=True)

        # Save summary file
        summary_file = os.path.join(epoch_dir, "epoch_summary.json")
        with open(summary_file, "w", encoding="utf-8") as f:
            json.dump(
                {
                    "epoch": epoch,
                    "folder": folder_name,
                    "total_reward": total_reward,
                    "successful_examples_count": successful_examples_count,
                    "error_tree_depth": error_tree.current_node.depth
                    if error_tree.current_node
                    else 0,
                    "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                },
                f,
                indent=2,
            )

        print(f"Successfully saved epoch {epoch} summary")

    except Exception as e:
        print(f"Error saving epoch summary: {str(e)}")
        print(f"Attempted to save to: {root_dir}")
        print(f"Current working directory: {os.getcwd()}")

