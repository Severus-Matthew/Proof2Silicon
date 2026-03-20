import os
import re
import subprocess
import gym
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.distributions.categorical import Categorical
import json
import random
from difflib import get_close_matches
from collections import Counter, defaultdict
import time
from transformers import (
    pipeline,
    AutoModelForCausalLM,
    AutoTokenizer,
    TrainingArguments,
    Trainer,
    BitsAndBytesConfig,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from datasets import Dataset
import torch.nn.functional as F
import argparse
from dataclasses import dataclass
from typing import List, Dict, Optional, Any
from datetime import datetime
from vllm import LLM
from vllm.sampling_params import SamplingParams

# GPU / CUDA setup
torch.cuda.set_per_process_memory_fraction(0.8, device=0)
os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "expandable_segments:True"
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print("Using device:", device)

# Globals for SLM
global_model = None
global_tokenizer = None
metrics_tracker = None

###############################################################################
# Helper functions
###############################################################################

def calculate_example_weight(reward: float, scale: float = 1.0) -> float:
    if reward < 0:
        return 1.0 + scale * abs(reward)
    else:
        return 1.0

def append_to_weighted_dataset(file_path: str, example: Dict):
    with open(file_path, "a") as f:
        json.dump(example, f)
        f.write("\n")

###############################################################################
# Data structures
###############################################################################

@dataclass
class TreeNode:
    error_code: str
    error_message: str
    reward: float
    prompt: str
    parent: Optional['TreeNode']
    children: List['TreeNode']
    depth: int
    success: bool = False

class ErrorTree:
    def __init__(self, max_depth: int = 7):
        self.root = None
        self.max_depth = max_depth
        self.current_node = None
        self.successful_path = None

    def add_node(self, error_code: str, error_message: str, reward: float, prompt: str, parent: Optional[TreeNode] = None) -> TreeNode:
        depth = 0 if parent is None else parent.depth + 1
        node = TreeNode(
            error_code=error_code,
            error_message=error_message,
            reward=reward,
            prompt=prompt,
            parent=parent,
            children=[],
            depth=depth
        )
        if parent:
            parent.children.append(node)
        else:
            self.root = node
        return node

    def get_path_to_node(self, node: TreeNode) -> List[TreeNode]:
        path = []
        current = node
        while current:
            path.append(current)
            current = current.parent
        return list(reversed(path))

    def traverse(self) -> List[TreeNode]:
        nodes = []
        def rec(node: TreeNode):
            nodes.append(node)
            for child in node.children:
                rec(child)
        if self.root:
            rec(self.root)
        return nodes


class WeightedTrainer(Trainer):
    def compute_loss(self, model, inputs, return_outputs=False):
        loss_weights = inputs.pop('loss_weight', None)
        outputs = model(**inputs)
        loss = outputs.loss
        if loss_weights is not None:
            loss = (loss * loss_weights).mean()
        return (loss, outputs) if return_outputs else loss
###############################################################################
# Metrics and Environment
###############################################################################
class MetricsTracker:
    def __init__(self, save_dir):
        self.save_dir = save_dir
        os.makedirs(self.save_dir, exist_ok=True)
        self.episode_rewards = []
        self.cumulative_rewards = []
        self.success_rates = []
        self.error_counts = []
        self.iteration_counts = []
        self.average_rewards_per_epoch = []
        self.training_loss = []
        self.validation_loss = []
        self.model_perplexity = []
        self.error_types = defaultdict(list)
        self.verification_success_rate = []
        self.proof_obligation_counts = []
        self.start_time = time.time()
        self.epoch_times = []

    def update_rl_metrics(self, reward, success, error_count, iterations):
        self.episode_rewards.append(reward)
        self.cumulative_rewards.append(sum(self.episode_rewards))
        self.success_rates.append(float(success))
        self.error_counts.append(error_count)
        self.iteration_counts.append(iterations)

    def update_epoch_metrics(self, avg_reward, training_loss=None, val_loss=None):
        self.average_rewards_per_epoch.append(avg_reward)
        if training_loss is not None:
            self.training_loss.append(training_loss)
        if val_loss is not None:
            self.validation_loss.append(val_loss)
        self.epoch_times.append(time.time() - self.start_time)

    def update_error_analysis(self, error_type, verification_success, proof_obligations):
        self.error_types[error_type].append(1)
        self.verification_success_rate.append(float(verification_success))
        self.proof_obligation_counts.append(proof_obligations)

    def plot_learning_curves(self):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        folder_name = os.path.basename(os.path.dirname(self.save_dir))

        import matplotlib.pyplot as plt
        plt.figure(figsize=(12, 6))
        plt.plot(self.episode_rewards, label='Episode Rewards')
        plt.xlabel('Episode')
        plt.ylabel('Reward')
        plt.title(f'Episode Rewards - {folder_name}')
        plt.grid(True)
        plt.legend()
        plt.savefig(os.path.join(self.save_dir, f'episode_rewards_{folder_name}_{timestamp}.png'))
        plt.close()

        plt.figure(figsize=(12, 6))
        plt.plot(self.cumulative_rewards, label='Cumulative Rewards')
        plt.xlabel('Episode')
        plt.ylabel('Cumulative Reward')
        plt.title(f'Cumulative Rewards - {folder_name}')
        plt.grid(True)
        plt.legend()
        plt.savefig(os.path.join(self.save_dir, f'cumulative_rewards_{folder_name}_{timestamp}.png'))
        plt.close()

        plt.figure(figsize=(12, 6))
        plt.plot(self.success_rates, label='Success Rate')
        plt.xlabel('Episode')
        plt.ylabel('Success Rate')
        plt.title(f'Verification Success Rate - {folder_name}')
        plt.grid(True)
        plt.legend()
        plt.savefig(os.path.join(self.save_dir, f'success_rate_{folder_name}_{timestamp}.png'))
        plt.close()

        plt.figure(figsize=(12, 6))
        for etype, counts in self.error_types.items():
            plt.plot(counts, label=etype)
        plt.xlabel('Episode')
        plt.ylabel('Error Count')
        plt.title(f'Error Analysis - {folder_name}')
        plt.grid(True)
        plt.legend()
        plt.savefig(os.path.join(self.save_dir, f'error_analysis_{folder_name}_{timestamp}.png'))
        plt.close()

        if self.training_loss:
            plt.figure(figsize=(12, 6))
            plt.plot(self.training_loss, label='Training Loss')
            if self.validation_loss:
                plt.plot(self.validation_loss, label='Validation Loss')
            plt.xlabel('Epoch')
            plt.ylabel('Loss')
            plt.title(f'Training Loss - {folder_name}')
            plt.grid(True)
            plt.legend()
            plt.savefig(os.path.join(self.save_dir, f'training_loss_{folder_name}_{timestamp}.png'))
            plt.close()

    def save_metrics(self):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        folder_name = os.path.basename(os.path.dirname(self.save_dir))
        metrics_data = {
            'episode_rewards': self.episode_rewards,
            'cumulative_rewards': self.cumulative_rewards,
            'success_rates': self.success_rates,
            'error_counts': self.error_counts,
            'iteration_counts': self.iteration_counts,
            'average_rewards_per_epoch': self.average_rewards_per_epoch,
            'training_loss': self.training_loss,
            'validation_loss': self.validation_loss,
            'verification_success_rate': self.verification_success_rate,
            'proof_obligation_counts': self.proof_obligation_counts,
            'error_types': dict(self.error_types),
            'epoch_times': self.epoch_times,
            'total_time': time.time() - self.start_time
        }
        with open(os.path.join(self.save_dir, f'metrics_{folder_name}_{timestamp}.json'), 'w') as f:
            json.dump(metrics_data, f, indent=2)

class DafnyEnv(gym.Env):
    def __init__(self, prompt, tmp_path, error_path):
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
        os.makedirs(self.subfolder_path, exist_ok=True)

        global metrics_tracker
        if metrics_tracker is None:
            metrics_tracker = MetricsTracker(os.path.join(self.subfolder_path, "metrics"))

        self.weighted_dataset_path = os.path.join(self.subfolder_path, "weighted_training_examples.jsonl")
        open(self.weighted_dataset_path, "a").close()

        # simple action/obs spaces (unused)
        self.observation_space = gym.spaces.Discrete(1)
        self.action_space = gym.spaces.Discrete(1)

    def reset(self):
        self.error_tree = ErrorTree(max_depth=7)
        self.current_iteration = 0
        self.epoch_rewards = []
        return self.prompt

    def set_current_loss(self, loss):
        self.current_loss = float(loss.detach().item())

    def get_dafny_output(self, code: str) -> tuple:
        if not code or code.strip() == "":
            reward = -7.0
            error_output = "Error: Empty Dafny file"
            code = ""
            metrics_tracker.update_rl_metrics(reward, False, 1, self.current_iteration)
            metrics_tracker.update_error_analysis("empty_file", False, 1)
            print("saving empty file")
            save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, error_output, code, 1)
            return reward, error_output, code

        with open(self.tmp_path, "w", encoding='utf-8') as file:
            if code.startswith("Dafny code"):
                code = code.split("Dafny code", 1)[1].strip()
            file.write(code)
        
        dafny_directory = r"/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
        os.chdir(dafny_directory)
        
        dafny_command = f"/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny '{self.tmp_path}' > '{self.error_path}'"
        os.system(dafny_command)
        
        with open(self.error_path, "r", encoding='utf-8') as output_file:
            output = output_file.read()
            
            if "verified, 0 errors" in output and "Compiled assembly into" in output:
                    reward = 5.0
                    metrics_tracker.update_rl_metrics(reward, True, 0, self.current_iteration)
                    metrics_tracker.update_error_analysis("success", True, 0)
                    print("saving success")
                    save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, output, code, 0)
            else:
                error_count = 0
                error_types = defaultdict(int)
                for line in output.split('\n'):
                    if "Error:" in line or "error:" in line:
                        error_count += 1
                        if "assertion violation" in line.lower():
                            error_types["assertion"] += 1
                        elif "precondition violation" in line.lower():
                            error_types["precondition"] += 1
                        elif "postcondition violation" in line.lower():
                            error_types["postcondition"] += 1
                        else:
                            error_types["other"] += 1
                
                a = 0.2
                b = 0.5 * self.current_iteration
                shaped_penalty = -a * error_count - b
                reward = -5.0 + shaped_penalty
                metrics_tracker.update_rl_metrics(reward, False, error_count, self.current_iteration)
                for error_type, count in error_types.items():
                    metrics_tracker.update_error_analysis(error_type, False, error_count)
                # metrics_tracker.update_rl_metrics(reward, False, 1, self.current_iteration)
                # metrics_tracker.update_error_analysis("empty_file", False, 1)
                print("saving error file")
                save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, output, code, error_count)
                print("total_reward: ", reward)
                print("error_count: ", error_count)
                print("iteration: ", self.current_iteration)
                print("--------------------------------")
                # save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, output, code, error_count)
            return reward, output, code

    def stepss(self, action):
        current_prompt = self.prompt if self.current_iteration == 0 else None
        total_reward = 0
        done = False
        
        # Pre-fetch error context outside the loop
        error_context = None
        if self.current_iteration > 0 and self.error_tree.current_node:
            current_node = self.error_tree.current_node
            error_context = {
                'error_code': current_node.error_code,
                'error_message': current_node.error_message,
                'reward': current_node.reward,
                'attempts': self.current_iteration
            }
        
        # Process attempts sequentially
        max_attempts = 7
        attempt = 0
        
        while attempt < max_attempts and not done:
            # Generate prompt based on attempt number
            if attempt == 0:
                current_prompt = ShortPrompt(self.prompt)
            else:
                # Use error context from previous attempt
                if hasattr(self, 'last_attempt_info'):
                    current_prompt = ErrorPrompt(
                        self.last_attempt_info['error_output'],
                        self.prompt,
                        self.last_attempt_info['code'],
                        str(self.last_attempt_info['reward'])
                    )
                else:
                    current_prompt = ShortPrompt(self.prompt)
            
            # Get responses
            slm_response = run_SLM(current_prompt)
            llm_response = run_LLM(slm_response)
            
            # Extract and validate Dafny code
            dafny_code = extract_dafny_code(llm_response)
            if not dafny_code or dafny_code.strip() == "":
                attempt += 1
                self.current_iteration += 1
                continue
            
            # Get Dafny output and update rewards
            print("getting dafny output")
            reward, error_output, code = self.get_dafny_output(dafny_code)
            total_reward += reward
            self.epoch_rewards.append(reward)
            
            # Store current attempt info for next iteration
            self.last_attempt_info = {
                'error_output': error_output,
                'code': code,
                'reward': reward
            }
            
            # Update error tree
            new_node = self.error_tree.add_node(
                error_code=code,
                error_message=error_output,
                reward=reward,
                prompt=slm_response,
                parent=self.error_tree.current_node
            )
            self.error_tree.current_node = new_node
            
            # Prepare weighted training example
            example = {
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                "prompt": slm_response,
                "llm_response": llm_response,
                "dafny_code": code,
                "error_output": error_output,
                "reward": reward,
                "loss_weight": calculate_example_weight(reward, scale=1.0)
            }
            append_to_weighted_dataset(self.weighted_dataset_path, example)
            
            # Handle successful cases
            if reward > 0:
                self.successful_examples.append({
                    "prompt": slm_response,
                    "response": llm_response,
                    "reward": reward,
                    "error_context": error_context
                })
                
                if len(self.successful_examples) > 100:
                    self.successful_examples = self.successful_examples[-100:]
                
                new_node.success = True
                self.error_tree.successful_path = self.error_tree.get_path_to_node(new_node)
                done = True
                break
            
            attempt += 1
            self.current_iteration += 1
            
            # Check if we've reached max attempts
            if attempt >= max_attempts:
                done = True
        
        info = {
            "error_tree": self.error_tree,
            "successful_examples_count": len(self.successful_examples),
            "iterations": self.current_iteration,
            "final_reward": total_reward,
            "epoch_rewards": self.epoch_rewards
        }
        
        if done:
            save_epoch_summary(
                self.subfolder_path,
                self.current_epoch,
                total_reward,
                len(self.successful_examples),
                self.error_tree
            )
            avg_epoch_reward = sum(self.epoch_rewards) / len(self.epoch_rewards) if self.epoch_rewards else 0
            metrics_tracker.update_epoch_metrics(
                avg_reward=avg_epoch_reward,
                training_loss=self.current_loss
            )
        
        torch.cuda.empty_cache()
        
        return self.prompt, total_reward, done, info

def initialize_slm():
    global global_model, global_tokenizer
    if global_model and global_tokenizer:
        print("Reusing existing SLM and tokenizer")
        return global_model, global_tokenizer

    print("Initializing SLM and tokenizer...")
    model_name = "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
    global_tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
    if global_tokenizer.pad_token is None:
        global_tokenizer.pad_token = global_tokenizer.eos_token
        global_tokenizer.pad_token_id = global_tokenizer.eos_token_id

    quant_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_use_double_quant=True,
        bnb_4bit_compute_dtype=torch.float16
    )
    global_model = AutoModelForCausalLM.from_pretrained(
        model_name,
        quantization_config=quant_config,
        trust_remote_code=True,
        device_map="auto",
        use_cache=False,
        torch_dtype=torch.float16
    )
    global_model = prepare_model_for_kbit_training(global_model)

    lora_cfg = LoraConfig(
        r=16,
        lora_alpha=32,
        target_modules=["q_proj","k_proj","v_proj","o_proj","gate_proj","up_proj","down_proj"],
        lora_dropout=0.1,
        bias="none",
        task_type="CAUSAL_LM",
        modules_to_save=["embed_tokens","lm_head"],
        inference_mode=False
    )
    global_model = get_peft_model(global_model, lora_cfg)
    global_model.gradient_checkpointing_enable()
    global_model.enable_input_require_grads()

    print("SLM initialized with LoRA adapters")
    return global_model, global_tokenizer

class SLMPG(nn.Module):
    def __init__(self, base_model):
        super().__init__()
        self.model = base_model
        hidden_size = base_model.config.hidden_size
        self.value_head = nn.Linear(hidden_size, 1)

    def forward(self, input_ids, attention_mask=None):
        outputs = self.model(
            input_ids=input_ids,
            attention_mask=attention_mask,
            output_hidden_states=True,
            return_dict=True
        )
        logits = outputs.logits  # [B, T, V]
        last_hidden = outputs.hidden_states[-1][:, -1, :]  # [B, H]
        values = self.value_head(last_hidden).squeeze(-1)    # [B]
        return logits, values



def train_slm_with_grpo(slm, tokenizer, env, optimizer, num_epochs=5, gamma=0.99):
    slm_pg = SLMPG(slm).to(device)
    slm_pg.train()

    for epoch in range(num_epochs):
        obs = env.reset()
        # Tokenize prompt
        inputs = tokenizer(obs, return_tensors="pt", truncation=True, padding=True).to(device)
        # Generate one sequence
        ids = slm.generate(
            **inputs,
            do_sample=True,
            max_new_tokens=6000,
            pad_token_id=tokenizer.pad_token_id,
            eos_token_id=tokenizer.eos_token_id,
            temperature=0.7,
            top_k=50,
            top_p=0.95
        )  # [1, T]

        # Compute log-probs & values
        logits, values = slm_pg(ids[:, :-1], attention_mask=None)
        log_probs = F.log_softmax(logits, dim=-1)
        chosen = ids[:, 1:].unsqueeze(-1)
        token_log_probs = log_probs.gather(2, chosen).squeeze(-1)
        seq_log_prob = token_log_probs.sum(1)  # [1]

        # Decode and get reward
        decoded = tokenizer.batch_decode(ids, skip_special_tokens=True)[0]
        reward, _, _ = env.get_dafny_output(decoded)

        # Compute returns & advantage
        returns = reward
        advantage = returns - values.detach()

        # GRPO loss
        pg_loss = -(seq_log_prob * advantage).mean()
        v_loss = F.mse_loss(values, torch.tensor([returns], device=device))
        loss = pg_loss + 0.5 * v_loss

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        print(f"Epoch {epoch+1}/{num_epochs} — Reward: {reward:.3f}, Loss: {loss.item():.4f}")

    return slm


def extract_dafny_code(text):
    pattern_snippet = r"```dafny(.*?)```"
    snippets = re.findall(pattern_snippet, text, re.DOTALL)
    trimmed_snippet = ""
    if snippets:
        trimmed_snippet = snippets[-1].strip()
    return trimmed_snippet

def run_SLM(prompt):
    model, tok = initialize_slm()
    inputs = tok(prompt, return_tensors="pt", truncation=True, padding=True).to(device)
    out = model.generate(**inputs, max_new_tokens=512)
    return tok.decode(out[0], skip_special_tokens=True)

class InferlessPythonModel:
    def initialize(self):
        model_id = "Qwen/Qwen2.5-Coder-14B-Instruct-GPTQ-Int8"
        self.llm = LLM(model=model_id, gpu_memory_utilization=0.98, max_model_len=6000, dtype="float16")
        self.tokenizer = AutoTokenizer.from_pretrained(model_id)

    def infer(self, inputs):
        prompts = inputs["prompt"]
        temperature = inputs.get("temperature", 0.7)
        top_p = inputs.get("top_p", 0.1)
        repetition_penalty = inputs.get("repetition_penalty", 1.18)
        top_k = int(inputs.get("top_k", 40))
        max_tokens = inputs.get("max_tokens", 256)

        sampling_params = SamplingParams(
            temperature=temperature,
            top_p=top_p,
            repetition_penalty=repetition_penalty,
            top_k=top_k,
            max_tokens=max_tokens,
        )
        input_text = self.tokenizer.apply_chat_template(
            [{"role": "user", "content": prompts}], tokenize=False
        )
        
        # Truncate input text to ensure we don't exceed the model's context length
        tokenized = self.tokenizer(input_text, truncation=True, max_length=6000, return_tensors="pt")
        input_text = self.tokenizer.decode(tokenized.input_ids[0], skip_special_tokens=True)
        
        result = self.llm.generate(input_text, sampling_params)
        result_output = [output.outputs[0].text for output in result]
        return {"generated_text": result_output[0]}

    def finalize(self):
        self.llm = None

def run_LLM(responses, batch_size=4):
    if not hasattr(run_LLM, "infer_model"):
        run_LLM.infer_model = InferlessPythonModel()
        run_LLM.infer_model.initialize()

    if isinstance(responses, str):
        responses = [responses]

    prompts = [
        resp + " You must return the full code in the following form:\n```dafny\nDafny Code\n```"
        for resp in responses
    ]

    generated_texts = []
    for prompt in prompts:
        inputs = {
            "prompt": prompt,
            "temperature": 0.7,
            "top_p": 0.1,
            "repetition_penalty": 1.18,
            "top_k": 40,
            "max_tokens": 6000,
        }
        res_dict = run_LLM.infer_model.infer(inputs)
        generated_texts.append(res_dict["generated_text"])
        # print(generated_texts)

    return generated_texts[0] if len(responses) == 1 else generated_texts


def save_iteration_results(subfolder_path, iteration, epoch, reward, error_output, code, error_count):
    try:
        folder_name = os.path.basename(subfolder_path)
        root_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset"
        
        # Create root directory if it doesn't exist
        os.makedirs(root_dir, exist_ok=True)
        
        # Create epoch directory with descriptive name
        
        epoch_dir = os.path.join(root_dir, f"epoch_{epoch}_{folder_name}")
        print(epoch_dir)
        os.makedirs(epoch_dir, exist_ok=True)
        print(f"Saving results to directory: {epoch_dir}")
        
        # Save results JSON
        results_file = os.path.join(epoch_dir, f"iteration_{iteration}_results.json")
        with open(results_file, "w", encoding='utf-8') as f:
            json.dump({
                "reward": reward,
                "error_count": error_count,
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                "folder": folder_name,
                "iteration": iteration,
                "epoch": epoch
            }, f, indent=2)
        
        # Save Dafny code
        code_file = os.path.join(epoch_dir, f"iteration_{iteration}_code.dfy")
        with open(code_file, "w", encoding='utf-8') as f:
            f.write(code)
        
        # Save error output
        error_file = os.path.join(epoch_dir, f"iteration_{iteration}_error.txt")
        with open(error_file, "w", encoding='utf-8') as f:
            f.write(error_output)
        
        print(f"Successfully saved iteration {iteration} results for epoch {epoch}")
        
    except Exception as e:
        print(f"Error saving iteration results: {str(e)}")
        print(f"Attempted to save to: {epoch_dir}")
        print(f"Current working directory: {os.getcwd()}")

def ShortPrompt(Task):
    Prompt = ("You are an expert in understanding Dafny code and explaining it in detailed, structured steps "
              "to another agent. Your explanations should be clear, thorough, and logically organized so that the agent "
              "can effectively use them to write correct and error-free Dafny code. Given the following task, break down "
              "the required Dafny program into:\n"
              " Step-by-step reasoning about the logic and specification.\n"
              " Relevant Dafny constructs and their usage (e.g., preconditions, postconditions, invariants).\n"
              " Potential edge cases and how to handle them.\n"
              " Final suggestions or reminders to avoid common pitfalls.\n"
              " Here is the task:\n")
    Prompt += Task + "\n"
    return Prompt

def ErrorPrompt(error, Task, code, rewa):
    Prompt = ("You are an expert in understanding Dafny code and explaining it in detailed, structured steps "
              "to another agent. Your explanations should be clear, thorough, and logically organized so that the agent "
              "can effectively use them to write correct and error-free Dafny code. Given the following task, an previously LLM generated code based on your instructions and the associated error message, break down "
              "the required Dafny program into:\n"
              " Step-by-step reasoning about the logic and specification and ways to solve this error.\n"
              " Relevant Dafny constructs and their usage (e.g., preconditions, postconditions, invariants).\n"
              " Potential edge cases and how to handle them.\n"
              " Final suggestions or reminders to avoid common pitfalls.\n"
              " Here is the task:\n")
    Prompt += Task + "\n Below is the errored code: \n"
    Prompt += code + "\n Below is the error message: \n"
    Prompt += error + "\n Below is the reward for the previous attempt. TRY TO MAXIMIZE IT THIS TIME, it is based on the correctness of the code that the LLM generated based on your instructions: \n"
    Prompt += rewa
    return Prompt

def save_epoch_summary(subfolder_path, epoch, total_reward, successful_examples_count, error_tree):
    try:
        folder_name = os.path.basename(subfolder_path)
        root_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset"
        
        # Create root directory if it doesn't exist
        os.makedirs(root_dir, exist_ok=True)
        
        # Create epoch directory
        epoch_dir = os.path.join(root_dir, f"epoch_{epoch}_{folder_name}")
        os.makedirs(epoch_dir, exist_ok=True)
        
        # Save summary file
        summary_file = os.path.join(epoch_dir, "epoch_summary.json")
        with open(summary_file, "w", encoding='utf-8') as f:
            json.dump({
                "epoch": epoch,
                "folder": folder_name,
                "total_reward": total_reward,
                "successful_examples_count": successful_examples_count,
                "error_tree_depth": error_tree.current_node.depth if error_tree.current_node else 0,
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
            }, f, indent=2)
        
        print(f"Successfully saved epoch {epoch} summary")
        
    except Exception as e:
        print(f"Error saving epoch summary: {str(e)}")
        print(f"Attempted to save to: {root_dir}")
        print(f"Current working directory: {os.getcwd()}")




def process_subfolders(root_directory, temperature):
    global global_model, global_tokenizer
    if global_model is None or global_tokenizer is None:
        global_model, global_tokenizer = initialize_slm()

    optimizer = optim.Adam(
        filter(lambda p: p.requires_grad, global_model.parameters()),
        lr=5e-5
    )
    results = {}

    for entry in os.listdir(root_directory):
        subfolder = os.path.join(root_directory, entry)
        if not os.path.isdir(subfolder):
            continue
        desc_file = os.path.join(subfolder, "detailed_description.txt")
        if not os.path.exists(desc_file):
            continue

        prompt = open(desc_file).read().strip()
        tmp_path = os.path.join(subfolder, "RL_No_feedback.dfy")
        error_path = os.path.join(subfolder, "RL_error.txt")
        env = DafnyEnv(prompt, tmp_path, error_path)

        print(f"Training SLM with GRPO on: {entry}")
        trained_slm = train_slm_with_grpo(global_model, global_tokenizer, env, optimizer, num_epochs=5)

        results[entry] = {
            'total_successes': len(env.successful_examples),
            'successful_examples': env.successful_examples
        }

        # Save LoRA adapters per subfolder
        save_dir = os.path.join(root_directory, 'lora_adapters', entry)
        os.makedirs(save_dir, exist_ok=True)
        trained_slm.save_pretrained(save_dir)

    return results

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run Dafny code generation with specified temperature')
    parser.add_argument('--temperature', type=float, default=0.75,
                      help='Temperature for LLM generation (default: 0.75)')
    args = parser.parse_args()

    results = process_subfolders("/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny", args.temperature)
    
    with open("training_results.json", "w") as f:
        json.dump({
            k: {
                "total_rewards": v["total_rewards"],
                "successful_examples_count": len(v["successful_examples_history"]),
                "iterations_per_epoch": [tree.current_node.depth if tree.current_node else 0 for tree in v["error_trees"]]
            }
            for k, v in results.items()
        }, f, indent=2)



def initialize_slm():
    global global_model, global_tokenizer
    if global_model and global_tokenizer:
        print("Reusing existing SLM and tokenizer")
        return global_model, global_tokenizer

    print("Initializing SLM and tokenizer...")
    model_name = "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
    global_tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
    if global_tokenizer.pad_token is None:
        global_tokenizer.pad_token = global_tokenizer.eos_token
        global_tokenizer.pad_token_id = global_tokenizer.eos_token_id

    quant_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_use_double_quant=True,
        bnb_4bit_compute_dtype=torch.float16
    )
    global_model = AutoModelForCausalLM.from_pretrained(
        model_name,
        quantization_config=quant_config,
        trust_remote_code=True,
        device_map="auto",
        use_cache=False,
        torch_dtype=torch.float16
    )