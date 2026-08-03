import json
import os
import subprocess
import time
from typing import Any, Dict, Tuple

import gymnasium as gym
import torch
import wandb

from .Dafny_AST_Analyzer import extract_reward_features
from .llm import judge_semantic_alignment, run_LLM
from .metrics import MetricsTracker, get_metrics_tracker, set_metrics_tracker
from .prompts import ErrorPrompt, ShortPrompt
from .rewards import calculate_example_weight, compute_total_reward
from .tree import ErrorTree
from .utils import (
    append_to_weighted_dataset,
    extract_dafny_code,
    save_epoch_summary,
    save_iteration_results,
)


class DafnyEnv(gym.core.Env):
    """RL environment with verifier + semantic-judge acceptance.

    A candidate terminates successfully only when both conditions hold:
      1. Dafny verifies and compiles it with zero errors.
      2. The semantic judge says it solves the original task.

    A verified but semantically rejected candidate receives a heavy penalty and
    the SLM -> generator -> verifier -> judge cycle continues.
    """

    def __init__(self, prompt: str, tmp_path: str, error_path: str):
        super().__init__()
        self.prompt = prompt
        self.tmp_path = tmp_path
        self.error_path = error_path
        self.successful_examples = []
        self.error_tree = ErrorTree(max_depth=7)
        self.current_iteration = 0
        self.current_epoch = 0
        self.prev_llm_tokens = 0
        self.subfolder_path = os.path.dirname(tmp_path)
        self.epoch_rewards = []
        self.current_loss = 0.0

        self.plugin_dll_path = (
            "/u/mjha1/Proof2Silicon/journal_phase/dafny-extractor-pp/"
            "bin/Release/net8.0/DafnyAstExtractor.dll"
        )
        self.ast_json_path = (
            "/u/mjha1/Proof2Silicon/journal_phase/ast_json/"
            "dafny-ast-output.json"
        )
        self.regex_analyzer_path = (
            "/u/mjha1/Proof2Silicon/journal_phase/CODEBASE/"
            "preface_rl/Dafny_SCC.py"
        )

        self.prev_error_counts = self._zero_error_counts()
        self.prev_structure = self._zero_structure_features()
        self.last_attempt_info = None
        os.makedirs(self.subfolder_path, exist_ok=True)

        tracker = get_metrics_tracker()
        if tracker is None:
            metrics_dir = (
                "/u/mjha1/Proof2Silicon/journal_phase/"
                "wandb_metrics_journal_final"
            )
            os.makedirs(metrics_dir, exist_ok=True)
            tracker = MetricsTracker(metrics_dir)
            set_metrics_tracker(tracker)
        self.metrics_tracker = tracker

        self.weighted_dataset_path = os.path.join(
            self.subfolder_path,
            "weighted_training_examples.jsonl",
        )
        open(self.weighted_dataset_path, "a").close()

        self.observation_space = gym.spaces.Discrete(1)
        self.action_space = gym.spaces.Discrete(1)

    @staticmethod
    def _zero_error_counts() -> Dict[str, int]:
        return {
            "syntax": 0,
            "type": 0,
            "missing_invariant": 0,
            "postcondition": 0,
            "timeout": 0,
        }

    @staticmethod
    def _zero_structure_features() -> Dict[str, int]:
        return {
            "lemma_count": 0,
            "recursion_count": 0,
            "invariant_count": 0,
            "ghost_var_count": 0,
        }

    def reset(self):
        self.error_tree = ErrorTree(max_depth=7)
        self.current_iteration = 0
        self.epoch_rewards = []
        self.successful_examples = []
        self.prev_llm_tokens = 0
        self.prev_error_counts = self._zero_error_counts()
        self.prev_structure = self._zero_structure_features()
        self.last_attempt_info = None
        return self.prompt

    def categorize_errors(self, output: str) -> Dict[str, int]:
        counts = self._zero_error_counts()
        for line in output.split("\n"):
            low = line.lower()
            if (
                "syntax error" in low
                or "parse error" in low
                or "invalid unary expression" in low
            ):
                counts["syntax"] += 1
            elif (
                "type mismatch" in low
                or "expected type" in low
                or "incorrect type" in low
            ):
                counts["type"] += 1
            elif "invariant" in low:
                counts["missing_invariant"] += 1
            elif "postcondition" in low:
                counts["postcondition"] += 1
        return counts

    def _run_regex_analyzer(self, dafny_file_path: str) -> Dict[str, int]:
        try:
            subprocess.run(
                ["python", self.regex_analyzer_path, dafny_file_path],
                check=True,
                capture_output=True,
                text=True,
            )
            from .Dafny_SCC import extract_regex_reward_features

            return extract_regex_reward_features(dafny_file_path)
        except Exception as exc:
            print("Regex fallback analyzer failed: {}".format(exc))
            return self._zero_structure_features()

    def run_ast_plugin_and_analyzer(
        self,
        dafny_file_path: str,
    ) -> Tuple[Dict[str, int], int]:
        try:
            plugin_arg = "--plugin:{} {}".format(
                self.plugin_dll_path,
                dafny_file_path,
            )
            result = subprocess.run(
                [
                    "dafny",
                    "resolve",
                    "--allow-warnings",
                    plugin_arg,
                    dafny_file_path,
                ],
                check=False,
                capture_output=True,
                text=True,
            )
            if result.returncode != 0 or not os.path.exists(self.ast_json_path):
                return self._run_regex_analyzer(dafny_file_path), -3

            with open(self.ast_json_path, "r", encoding="utf-8") as handle:
                data = json.load(handle)
            tmp_name = os.path.splitext(os.path.basename(self.tmp_path))[0]
            return extract_reward_features(data, tmp_name), 0
        except Exception as exc:
            print("AST plugin/analyzer failed: {}".format(exc))
            return self._run_regex_analyzer(dafny_file_path), -3

    def set_current_loss(self, loss: torch.Tensor):
        self.current_loss = float(loss.detach().item()) if isinstance(
            loss, torch.Tensor
        ) else float(loss)

    def build_state_prompt(self) -> str:
        if self.current_iteration == 0 or self.last_attempt_info is None:
            return ShortPrompt(self.prompt)

        return ErrorPrompt(
            self.last_attempt_info["error_output"],
            self.prompt,
            self.last_attempt_info["code"],
            str(self.last_attempt_info["reward"]),
            previous_instruction=self.last_attempt_info.get(
                "instruction_text", ""
            ),
            previous_llm_response=self.last_attempt_info.get(
                "llm_response", ""
            ),
        )

    def get_dafny_output(self, code: str) -> Tuple[str, str, str]:
        if not code or not code.strip():
            return "empty", "Error: Empty Dafny file", ""

        if code.startswith("Dafny code"):
            code = code.split("Dafny code", 1)[1].strip()
        with open(self.tmp_path, "w", encoding="utf-8") as handle:
            handle.write(code)

        try:
            process = subprocess.Popen(
                ["dafny", self.tmp_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
            )
            try:
                output, _ = process.communicate(timeout=120)
            except subprocess.TimeoutExpired:
                process.kill()
                process.communicate()
                return "timeout", "Error: Dafny verification timeout (2 minutes)", code

            with open(self.error_path, "w", encoding="utf-8") as handle:
                handle.write(output)

            if "verified, 0 errors" in output and "Compiled assembly into" in output:
                return "success", output, code
            return "wrong", output, code
        except Exception as exc:
            return "wrong", "Error running Dafny: {}".format(exc), code

    @staticmethod
    def _wandb_log(payload: Dict[str, Any]) -> None:
        try:
            if wandb.run is not None:
                wandb.log(payload)
        except Exception:
            pass

    def step(
        self,
        instruction_text: str,
        state_prompt: str = None,
        prompt_token_increase: int = 0,
        kl_value: float = 0.0,
        training_epoch: int = None,
    ):
        self.current_iteration += 1
        effective_epoch = (
            training_epoch
            if training_epoch is not None
            else self.current_epoch
        )

        last_code = ""
        last_error = ""
        if self.last_attempt_info is not None:
            last_code = self.last_attempt_info.get("code", "")
            last_error = self.last_attempt_info.get("error_output", "")

        llm_response, current_llm_tokens = run_LLM(
            instruction_text,
            last_code=last_code,
            last_error=last_error,
        )
        prompt_token_increase = max(
            0,
            current_llm_tokens - self.prev_llm_tokens,
        )
        self.prev_llm_tokens = current_llm_tokens

        dafny_code = extract_dafny_code(llm_response)
        verifier_outcome, verifier_output, code = self.get_dafny_output(dafny_code)

        semantic_judge_pass = None
        judge_metadata: Dict[str, Any] = {
            "passed": False,
            "model": None,
            "raw_response": "",
            "prompt_tokens": 0,
            "completion_tokens": 0,
            "valid_binary_response": False,
            "error": None,
        }

        # Judge only code that passed Dafny. Judge failure is fail-closed.
        if verifier_outcome == "success":
            semantic_judge_pass, judge_metadata = judge_semantic_alignment(
                self.prompt,
                code,
            )

        accepted_success = (
            verifier_outcome == "success"
            and semantic_judge_pass is True
        )

        if verifier_outcome == "timeout":
            curr_error_counts = self._zero_error_counts()
            curr_error_counts["timeout"] = 1
        else:
            curr_error_counts = self.categorize_errors(verifier_output)

        if code.strip():
            curr_structure, parse_errors = self.run_ast_plugin_and_analyzer(
                self.tmp_path
            )
        else:
            curr_structure = self._zero_structure_features()
            parse_errors = 0

        reward_breakdown = compute_total_reward(
            outcome=verifier_outcome,
            semantic_judge_pass=semantic_judge_pass,
            prev_error_counts=self.prev_error_counts,
            curr_error_counts=curr_error_counts,
            prev_structure=self.prev_structure,
            curr_structure=curr_structure,
            prompt_token_increase=prompt_token_increase,
            kl_value=kl_value,
            epoch=effective_epoch,
        )
        reward = reward_breakdown["total_reward"]

        # Feed judge rejection back into the next repair prompt.
        error_output = verifier_output
        if verifier_outcome == "success" and semantic_judge_pass is not True:
            error_output = (
                verifier_output
                + "\nSEMANTIC_JUDGE_REJECTED: The code verified but did not "
                + "faithfully solve the original task. Preserve the requested "
                + "behavior and interface; do not substitute another problem."
            )

        self.metrics_tracker.update_reward_breakdown(
            reward_breakdown,
            prompt_token_increase=prompt_token_increase,
            kl_value=kl_value,
        )

        error_count = sum(curr_error_counts.values())
        self.metrics_tracker.update_rl_metrics(
            reward,
            accepted_success,
            error_count,
            self.current_iteration,
        )
        for error_type, count in curr_error_counts.items():
            for _ in range(count):
                self.metrics_tracker.update_error_analysis(
                    error_type,
                    accepted_success,
                    error_count,
                )

        self._wandb_log(
            {
                "journal/iteration": self.current_iteration,
                "journal/epoch": effective_epoch,
                "journal/reward_total": reward,
                "journal/reward_outcome": reward_breakdown["outcome_reward"],
                "journal/reward_progress": reward_breakdown["progress_reward"],
                "journal/reward_structure": reward_breakdown["structure_reward"],
                "journal/reward_recursion": reward_breakdown["recursion_reward"],
                "journal/reward_lemma": reward_breakdown["lemma_reward"],
                "journal/reward_invariant": reward_breakdown["invariant_reward"],
                "journal/reward_ghost": reward_breakdown["ghost_reward"],
                "journal/reward_efficiency": reward_breakdown["efficiency_reward"],
                "journal/reward_stability": reward_breakdown["stability_reward"],
                "journal/verifier_pass": float(verifier_outcome == "success"),
                "journal/semantic_judge_pass": float(semantic_judge_pass is True),
                "journal/accepted_success": float(accepted_success),
                "journal/semantic_rejection": float(
                    verifier_outcome == "success"
                    and semantic_judge_pass is not True
                ),
                "journal/recursion_count": curr_structure.get("recursion_count", 0),
                "journal/recursion_delta": (
                    curr_structure.get("recursion_count", 0)
                    - self.prev_structure.get("recursion_count", 0)
                ),
                "journal/lemma_count": curr_structure.get("lemma_count", 0),
                "journal/invariant_count": curr_structure.get("invariant_count", 0),
                "journal/ghost_var_count": curr_structure.get("ghost_var_count", 0),
                "journal/error_count": error_count,
                "journal/prompt_token_increase": prompt_token_increase,
                "journal/generator_prompt_tokens": current_llm_tokens,
                "journal/judge_prompt_tokens": judge_metadata.get("prompt_tokens", 0),
                "journal/judge_completion_tokens": judge_metadata.get(
                    "completion_tokens", 0
                ),
                "journal/judge_valid_binary_response": float(
                    bool(judge_metadata.get("valid_binary_response", False))
                ),
                "journal/judge_api_error": float(bool(judge_metadata.get("error"))),
                "journal/kl_value": kl_value,
                "journal/current_loss": self.current_loss,
            }
        )

        save_iteration_results(
            self.subfolder_path,
            self.current_iteration,
            effective_epoch,
            reward,
            error_output,
            code,
            error_count,
            reward_breakdown=reward_breakdown,
            parse_errors=parse_errors,
            error_counts_by_type=curr_error_counts,
            structure_features=curr_structure,
            prompt_token_increase=prompt_token_increase,
            kl_value=kl_value,
        )

        # Save an additional audit record required for paper analysis.
        audit_record = {
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "iteration": self.current_iteration,
            "epoch": effective_epoch,
            "original_task": self.prompt,
            "state_prompt": state_prompt,
            "instruction_text": instruction_text,
            "llm_response": llm_response,
            "dafny_code": code,
            "verifier_outcome": verifier_outcome,
            "verifier_output": verifier_output,
            "semantic_judge_pass": semantic_judge_pass,
            "judge_metadata": judge_metadata,
            "accepted_success": accepted_success,
            "reward": reward,
            "reward_breakdown": reward_breakdown,
            "curr_error_counts": curr_error_counts,
            "curr_structure": curr_structure,
            "parse_errors": parse_errors,
            "loss_weight": calculate_example_weight(reward, scale=1.0),
        }
        append_to_weighted_dataset(
            self.weighted_dataset_path,
            audit_record,
        )

        self.epoch_rewards.append(reward)
        self.last_attempt_info = {
            "error_output": error_output,
            "code": code,
            "parse_errors": parse_errors,
            "reward": reward,
            "instruction_text": instruction_text,
            "llm_response": llm_response,
            "semantic_judge_pass": semantic_judge_pass,
            "judge_metadata": judge_metadata,
        }

        new_node = self.error_tree.add_node(
            error_code=code,
            error_message=error_output,
            reward=reward,
            prompt=instruction_text,
            parent=self.error_tree.current_node,
        )
        self.error_tree.current_node = new_node

        self.prev_error_counts = curr_error_counts
        self.prev_structure = curr_structure

        done = False
        if accepted_success:
            self.successful_examples.append(
                {
                    "state_prompt": state_prompt,
                    "instruction_text": instruction_text,
                    "response": llm_response,
                    "reward": reward,
                    "reward_breakdown": reward_breakdown,
                    "semantic_judge_pass": True,
                    "judge_metadata": judge_metadata,
                }
            )
            self.successful_examples = self.successful_examples[-100:]
            new_node.success = True
            self.error_tree.successful_path = self.error_tree.get_path_to_node(
                new_node
            )
            done = True

        if self.current_iteration >= 7:
            self.current_epoch += 1
            done = True

        info: Dict[str, Any] = {
            "error_tree": self.error_tree,
            "successful_examples": self.successful_examples.copy(),
            "successful_examples_count": len(self.successful_examples),
            "iterations": self.current_iteration,
            "final_reward": reward,
            "epoch_rewards": self.epoch_rewards,
            "error_output": error_output,
            "dafny_code": code,
            "llm_response": llm_response,
            "reward_breakdown": reward_breakdown,
            "curr_error_counts": curr_error_counts,
            "curr_structure": curr_structure,
            "parse_errors": parse_errors,
            "verifier_outcome": verifier_outcome,
            "semantic_judge_pass": semantic_judge_pass,
            "judge_metadata": judge_metadata,
            "accepted_success": accepted_success,
        }

        if done:
            save_epoch_summary(
                self.subfolder_path,
                effective_epoch,
                sum(self.epoch_rewards),
                len(self.successful_examples),
                self.error_tree,
            )

        torch.cuda.empty_cache()
        return reward, done, info
