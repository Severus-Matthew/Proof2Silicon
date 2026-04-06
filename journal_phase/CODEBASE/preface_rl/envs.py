
import os
import subprocess
import time
from collections import defaultdict
from typing import Any, Dict, Tuple

import gymnasium as gym
import torch

from .llm import run_LLM
from .metrics import MetricsTracker, get_metrics_tracker, set_metrics_tracker
from .prompts import ErrorPrompt, ShortPrompt
import json
import sys

from .rewards import calculate_example_weight, compute_total_reward
from .Dafny_AST_Analyzer import extract_reward_features
from .tree import ErrorTree
from .utils import (
    append_to_weighted_dataset,
    extract_dafny_code,
    save_epoch_summary,
    save_iteration_results,
)


class DafnyEnv(gym.core.Env):
    def __init__(self, prompt: str, tmp_path: str, error_path: str):
        super().__init__()
        self.prompt = prompt
        self.tmp_path = tmp_path
        self.error_path = error_path
        self.successful_examples = []
        self.error_tree = ErrorTree(max_depth=7)
        self.current_iteration = 0
        self.current_epoch = 0
        self.subfolder_path = os.path.dirname(tmp_path)
        self.epoch_rewards = []
        self.current_loss = 0.0
        self.plugin_dll_path = "/u/mjha1/Proof2Silicon/journal_phase/dafny-extractor-pp/bin/Release/net8.0/DafnyAstExtractor.dll"
        self.ast_json_path = "/u/mjha1/Proof2Silicon/journal_phase/ast_json/dafny-ast-output.json"
        self.regex_analyzer_path = "/u/mjha1/Proof2Silicon/journal_phase/CODEBASE/preface_rl/Dafny_SCC.py"
        self.prev_parse_errors = 0
        self.prev_error_counts = {
            "syntax": 0,
            "type": 0,
            "missing_invariant": 0,
            "postcondition": 0,
            "timeout": 0,
        }
        self.prev_structure = {
            "lemma_count": 0,
            "recursion_count": 0,
            "invariant_count": 0,
            "ghost_var_count": 0,
        }
        os.makedirs(self.subfolder_path, exist_ok=True)

        tracker = get_metrics_tracker()
        if tracker is None:
            tracker = MetricsTracker(os.path.join(self.subfolder_path, "metrics"))
            set_metrics_tracker(tracker)
        self.metrics_tracker = tracker

        self.weighted_dataset_path = os.path.join(
            self.subfolder_path, "weighted_training_examples.jsonl"
        )
        open(self.weighted_dataset_path, "a").close()

        self.observation_space = gym.spaces.Discrete(1)
        self.action_space = gym.spaces.Discrete(1)

    def reset(self):
        self.error_tree = ErrorTree(max_depth=7)
        self.current_iteration = 0
        self.epoch_rewards = []
        self.successful_examples = []
        self.prev_error_counts = {
            "syntax": 0,
            "type": 0,
            "missing_invariant": 0,
            "postcondition": 0,
            "timeout": 0,
        }
        self.prev_structure = {
            "lemma_count": 0,
            "recursion_count": 0,
            "invariant_count": 0,
            "ghost_var_count": 0,
        }
        if hasattr(self, "last_attempt_info"):
            del self.last_attempt_info
        return self.prompt
    def build_state_prompt(self) -> str:
        if self.current_iteration == 0:
            return ShortPrompt(self.prompt)

        if hasattr(self, "last_attempt_info"):
            return ErrorPrompt(
                self.last_attempt_info["error_output"],
                self.prompt,
                self.last_attempt_info["code"],
                str(self.last_attempt_info["reward"]),
                previous_instruction=self.last_attempt_info.get("instruction_text", ""),
                previous_llm_response=self.last_attempt_info.get("llm_response", ""),
            )

        return ShortPrompt(self.prompt)
    def categorize_errors(self, output: str) -> Dict[str, int]:
        counts = {
            "syntax": 0,
            "type": 0,
            "missing_invariant": 0,
            "postcondition": 0,
            "timeout": 0,
        }

        for line in output.split("\n"):
            low = line.lower()

            if "syntax error" in low or "parse error" in low or "invalid unary expression" in low:
                counts["syntax"] += 1
            elif "type mismatch" in low or "expected type" in low or "incorrect type" in low:
                counts["type"] += 1
            elif "invariant" in low:
                counts["missing_invariant"] += 1
            elif "postcondition" in low:
                counts["postcondition"] += 1

        return counts
    def _zero_structure_features(self) -> Dict[str, int]:
        return {
            "lemma_count": 0,
            "recursion_count": 0,
            "invariant_count": 0,
            "ghost_var_count": 0,
        }


    def _run_regex_analyzer(self, dafny_file_path: str) -> Dict[str, int]:
        """
        Fallback analyzer when dafny resolve/plugin fails.
        Command format:
            python <py file location> <dfy file location>
        """
        try:
            cmd = ["python", self.regex_analyzer_path, dafny_file_path]
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            print("regex success")

            # IMPORTANT:
            # This assumes your regex analyzer exposes a callable parser helper.
            # If Dafny_SCC.py only prints a report today, add a helper there
            # (shown below in section 4) and import/call it instead.
            from .Dafny_SCC import extract_regex_reward_features
            return extract_regex_reward_features(dafny_file_path)

        except Exception as e:
            print(f"Regex fallback analyzer failed: {e}")
            return self._zero_structure_features()


    def run_ast_plugin_and_analyzer(self, dafny_file_path: str) -> Tuple[Dict[str, int], int]:
        """
        Returns:
            (structure_features, parse_errors)
            parse_errors = 0  -> plugin resolve + JSON extraction succeeded
            parse_errors = -3 -> plugin resolve/JSON path failed, regex fallback used
        """
        try:
            plugin_cmd = [
                "dafny",
                "resolve",
                "--allow-warnings",
                '--plugin:'+'"'+self.plugin_dll_path+'" "'+dafny_file_path+'"',
            ]
            subprocess.run(plugin_cmd, check=True, capture_output=True, text=True)

            if not os.path.exists(self.ast_json_path):
                print("AST JSON file missing after dafny resolve; using regex fallback.")
                return self._run_regex_analyzer(dafny_file_path), -3

            with open(self.ast_json_path, "r", encoding="utf-8") as f:
                data = json.load(f)

            tmp_dfy_file = os.path.splitext(os.path.basename(self.tmp_path))[0]
            structure = extract_reward_features(data, tmp_dfy_file)
            return structure, 0

        except Exception as e:
            print(f"AST plugin/analyzer failed: {e}")
            print("running regex analyzer")
            return self._run_regex_analyzer(dafny_file_path), -3
    def set_current_loss(self, loss: torch.Tensor):
        self.current_loss = float(loss.detach().item())

    def build_state_prompt(self) -> str:
        if self.current_iteration == 0:
            return ShortPrompt(self.prompt)

        if hasattr(self, "last_attempt_info"):
            return ErrorPrompt(
                self.last_attempt_info["error_output"],
                self.prompt,
                self.last_attempt_info["code"],
                str(self.last_attempt_info["reward"]),
                previous_instruction=self.last_attempt_info.get("instruction_text", ""),
                previous_llm_response=self.last_attempt_info.get("llm_response", ""),
            )

        return ShortPrompt(self.prompt)

    def get_dafny_output(self, code: str) -> Tuple[str, str, str]:
        if not code or code.strip() == "":
            return "empty", "Error: Empty Dafny file", ""

        with open(self.tmp_path, "w", encoding="utf-8") as file:
            if code.startswith("Dafny code"):
                code = code.split("Dafny code", 1)[1].strip()
            file.write(code)


        try:
            dafny_command = (
                f"dafny '{self.tmp_path}' > '{self.error_path}'"
            )
            process = subprocess.Popen(
                dafny_command,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )

            try:
                process.communicate(timeout=180)
                with open(self.error_path, "r", encoding="utf-8") as output_file:
                    output = output_file.read()
            except subprocess.TimeoutExpired:
                process.kill()
                return "timeout", "Error: Dafny verification timeout (3 minutes)", ""

            if "verified, 0 errors" in output and "Compiled assembly into" in output:
                return "success", output, code

            return "wrong", output, code

        except Exception as e:
            return "wrong", f"Error running Dafny: {str(e)}", ""
    def step(self, instruction_text: str, state_prompt: str | None = None, prompt_token_increase: int = 0, kl_value: float = 0.0, training_epoch: int | None = None):
        self.current_iteration += 1
        done = False

        # Use the epoch passed in from the training loop (authoritative).
        # Fall back to self.current_epoch only if not provided (legacy callers).
        effective_epoch = training_epoch if training_epoch is not None else self.current_epoch

        llm_response = run_LLM(instruction_text)
        dafny_code = extract_dafny_code(llm_response)

        outcome, error_output, code = self.get_dafny_output(dafny_code)

        if outcome == "timeout":
            curr_error_counts = {
                "syntax": 0,
                "type": 0,
                "missing_invariant": 0,
                "postcondition": 0,
                "timeout": 1,
            }
        else:
            curr_error_counts = self.categorize_errors(error_output)

        if code.strip():
            curr_structure, parse_errors = self.run_ast_plugin_and_analyzer(self.tmp_path)
        else:
            curr_structure = self._zero_structure_features()
            parse_errors = 0

        reward_breakdown = compute_total_reward(
            outcome=outcome,
            prev_error_counts=self.prev_error_counts,
            curr_error_counts=curr_error_counts,
            prev_structure=self.prev_structure,
            curr_structure=curr_structure,
            prompt_token_increase=prompt_token_increase,
            kl_value=kl_value,
        )
        reward = reward_breakdown["total_reward"]
        self.metrics_tracker.update_reward_breakdown(
            reward_breakdown,
            prompt_token_increase=prompt_token_increase,
            kl_value=kl_value,
        )

        error_count = sum(curr_error_counts.values())
        self.metrics_tracker.update_rl_metrics(
            reward,
            outcome == "success",
            error_count,
            self.current_iteration,
        )
        for error_type, count in curr_error_counts.items():
            for _ in range(count):
                self.metrics_tracker.update_error_analysis(
                    error_type,
                    outcome == "success",
                    error_count,
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

        self.epoch_rewards.append(reward)

        self.last_attempt_info = {
            "error_output": error_output,
            "code": code,
            "parse_errors": parse_errors,
            "reward": reward,
            "instruction_text": instruction_text,
            "llm_response": llm_response,
        }

        new_node = self.error_tree.add_node(
            error_code=code,
            error_message=error_output,
            reward=reward,
            prompt=instruction_text,
            parent=self.error_tree.current_node,
        )
        self.error_tree.current_node = new_node

        example = {
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "state_prompt": state_prompt,
            "instruction_text": instruction_text,
            "llm_response": llm_response,
            "dafny_code": code,
            "error_output": error_output,
            "reward": reward,
            "reward_breakdown": reward_breakdown,
            "curr_error_counts": curr_error_counts,
            "curr_structure": curr_structure,
            "parse_errors": parse_errors,
            "loss_weight": calculate_example_weight(reward, scale=1.0),
        }
        append_to_weighted_dataset(self.weighted_dataset_path, example)

        self.prev_error_counts = curr_error_counts
        self.prev_structure = curr_structure

        if outcome == "success":
            self.successful_examples.append(
                {
                    "state_prompt": state_prompt,
                    "instruction_text": instruction_text,
                    "response": llm_response,
                    "reward": reward,
                    "reward_breakdown": reward_breakdown,
                }
            )
            if len(self.successful_examples) > 100:
                self.successful_examples = self.successful_examples[-100:]
            new_node.success = True
            self.error_tree.successful_path = self.error_tree.get_path_to_node(new_node)
            done = True

        if self.current_iteration >= 7:
            self.current_epoch += 1
            done = True

        info: Dict[str, Any] = {
            "error_tree": self.error_tree,
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
        }

        if done:
            total_reward = sum(self.epoch_rewards)
            save_epoch_summary(
                self.subfolder_path,
                effective_epoch,
                total_reward,
                len(self.successful_examples),
                self.error_tree,
            )

        torch.cuda.empty_cache()
        return reward, done, info
        