import multiprocessing as mp
mp.set_start_method('spawn', force=True)

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
import google.generativeai as genai
from google.generativeai.types import HarmCategory, HarmBlockThreshold
from accelerate import init_empty_weights, load_checkpoint_and_dispatch
import logging
import wandb
import zipfile
from torch.optim.lr_scheduler import ReduceLROnPlateau
import concurrent.futures

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('training.log'),
        logging.StreamHandler()
    ]
)

# GPU / CUDA setup
torch.cuda.set_per_process_memory_fraction(0.8, device=0)
os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "max_split_size_mb:128,expandable_segments:True"
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
logging.info(f"Using device: {device}")

# Globals for SLM and Gemini
global_model = None
global_tokenizer = None
metrics_tracker = None
gemini_model = None

# Constants for model saving
CHECKPOINT_DIR = "/mnt/shared/gpfs/home/manvij2/checkpoints"
LORA_ADAPTER_DIR = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny/lora_adapters"

# Create directories if they don't exist
os.makedirs(CHECKPOINT_DIR, exist_ok=True)
os.makedirs(LORA_ADAPTER_DIR, exist_ok=True)

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
        self.save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny/Dafny(75)/metrics"
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
        print("getting dafny output")
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
        
        try:
            # Run Dafny with a 4-minute timeout
            dafny_command = f"/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny '{self.tmp_path}' > '{self.error_path}'"
            process = subprocess.Popen(dafny_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            try:
                process.communicate(timeout=180)  # 240 seconds = 4 minutes
                with open(self.error_path, "r", encoding='utf-8') as output_file:
                    print("reading error file")
                    output = output_file.read()
            except subprocess.TimeoutExpired:
                process.kill()
                reward = -7.0
                error_output = "Error: Dafny verification timeout (4 minutes)"
                metrics_tracker.update_rl_metrics(reward, False, 1, self.current_iteration)
                metrics_tracker.update_error_analysis("timeout", False, 1)
                save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, error_output, "", 1)
                return reward, error_output, ""
            
            print("output: has been read")
            if "verified, 0 errors" in output and "Compiled assembly into" in output:
                reward = 5.0
                metrics_tracker.update_rl_metrics(reward, True, 0, self.current_iteration)
                metrics_tracker.update_error_analysis("success", True, 0)
                print("saving success")
                print("saving success file")
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
                print("saving error file")
                save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, output, code, error_count)
                print("total_reward: ", reward)
                print("error_count: ", error_count)
                print("iteration: ", self.current_iteration)
                print("--------------------------------")
            
            return reward, output, code
            
        except Exception as e:
            print(f"Error running Dafny: {str(e)}")
            reward = -7.0
            error_output = f"Error running Dafny: {str(e)}"
            metrics_tracker.update_rl_metrics(reward, False, 1, self.current_iteration)
            metrics_tracker.update_error_analysis("execution_error", False, 1)
            save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, error_output, "", 1)
            return reward, error_output, ""

    def stepss(self):
        print("stepssssssssssssss")
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
            print("attempt: ", attempt)
            self.current_iteration += 1
            # Generate prompt based on attempt number
            if attempt == 0:
                current_prompt = ShortPrompt(self.prompt)
            else:
                print("using error context from previous attempt")
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
            print("extracting dafny code")
            dafny_code = extract_dafny_code(llm_response)
            print("dafny code extracted")
            # if not dafny_code or dafny_code.strip() == "":
            #     attempt += 1
            #     self.current_iteration += 1
            #     continue
            
            # Get Dafny output and update rewards
            print("getting dafny output")
            reward, error_output, code = self.get_dafny_output(dafny_code)
            print("dafny output gotten")
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
            
            
            # Check if we've reached max attempts
            if attempt >= max_attempts:
                self.current_epoch += 1
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

def initialize_slm(checkpoint_path=None):
    global global_model, global_tokenizer

    if global_model is not None:
        return global_model, global_tokenizer

    # Set memory management environment variables
    os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "max_split_size_mb:128,expandable_segments:True"
    torch.cuda.empty_cache()
    
    # Force single GPU usage
    os.environ["CUDA_VISIBLE_DEVICES"] = "0"
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

    model_name = "deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B"
    print("Loading tokenizer...")
    global_tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
    if global_tokenizer.pad_token is None:
        global_tokenizer.pad_token = global_tokenizer.eos_token
        global_tokenizer.pad_token_id = global_tokenizer.eos_token_id

    try:
        # Configure quantization and offloading
        print("Configuring quantization and offloading settings...")
        quant_config = BitsAndBytesConfig(
            load_in_8bit=True,
            llm_int8_threshold=6.0,
            llm_int8_has_fp16_weight=False,
            bnb_8bit_compute_dtype=torch.float16,
            bnb_8bit_use_double_quant=True
        )

        # Create offload folder
        offload_folder = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/model_offload"
        os.makedirs(offload_folder, exist_ok=True)

        # Configure memory limits
        max_memory = {0: "24GiB", "cpu": "96GiB"}

        print("Loading base model with offloading configuration...")
        global_model = AutoModelForCausalLM.from_pretrained(
            model_name,
            quantization_config=quant_config,
            trust_remote_code=True,
            device_map="balanced",
            max_memory=max_memory,
            offload_folder=offload_folder,
            offload_state_dict=True,
            torch_dtype=torch.float16,
            low_cpu_mem_usage=True
        )

        # Prepare for kbit training with offloading
        print("Preparing model for kbit training...")
        global_model = prepare_model_for_kbit_training(global_model)

        # Configure LoRA with offloading support
        print("Configuring LoRA...")
        lora_config = LoraConfig(
            r=16,
            lora_alpha=32,
            target_modules=["q_proj","k_proj","v_proj","o_proj","gate_proj","up_proj","down_proj"],
            lora_dropout=0.1,
            bias="none",
            task_type="CAUSAL_LM",
            modules_to_save=["embed_tokens", "lm_head"],
            inference_mode=False
        )

        # Apply LoRA config with offloading
        print("Applying LoRA configuration...")
        global_model = get_peft_model(global_model, lora_config)

        # Load checkpoint if provided
        if checkpoint_path and os.path.exists(checkpoint_path):
            print(f"Loading checkpoint from {checkpoint_path}")
            try:
                checkpoint = torch.load(checkpoint_path, map_location=device)
                if 'model_state_dict' in checkpoint:
                    state_dict = checkpoint["model_state_dict"]
                    model_state = global_model.state_dict()
                    filtered_state_dict = {k: v for k, v in state_dict.items() if k in model_state}
                    model_state.update(filtered_state_dict)
                    global_model.load_state_dict(model_state, strict=False)
                    logging.info("Successfully loaded model state from checkpoint")
                else:
                    logging.warning("Checkpoint does not contain model_state_dict, using base model")
                    global_model.load_state_dict(checkpoint, strict=False)
                    print("Successfully loaded direct state dict from checkpoint")
                    # Try loading as direct state dict
                    
            except Exception as e:
                print(f"Warning: Could not load checkpoint: {str(e)}")

        # Enable training optimizations
        global_model.gradient_checkpointing_enable()
        global_model.enable_input_require_grads()
        global_model.train()

        # Set up activation checkpointing for memory efficiency
        if hasattr(global_model, 'model') and hasattr(global_model.model, 'layers'):
            for layer in global_model.model.layers:
                layer.gradient_checkpointing = True

        print(f"Model successfully initialized with offloading")
        print(f"Device map: {global_model.hf_device_map}")
        print(f"Offload folder: {offload_folder}")
        
        return global_model, global_tokenizer

    except Exception as e:
        print(f"Error during model initialization: {str(e)}")
        torch.cuda.empty_cache()
        if os.path.exists(offload_folder):
            import shutil
            shutil.rmtree(offload_folder)
        raise e

class SLMPG(nn.Module):
    def __init__(self, base_model):
        super().__init__()
        self.model = base_model
        hidden_size = base_model.config.hidden_size
        self.value_head = nn.Sequential(
            nn.Linear(hidden_size, hidden_size),
            nn.ReLU(),
            nn.Linear(hidden_size, 1)
        )

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


def load_checkpoint(checkpoint_path, slm_pg, optimizer):
    if not os.path.exists(checkpoint_path):
        print(f"Checkpoint not found at {checkpoint_path}")
        return None, [], [], set()
    
    print(f"Loading checkpoint from {checkpoint_path}")
    
    try:
        # Try to load the checkpoint
        checkpoint = torch.load(checkpoint_path, map_location=device)
        # For 8-bit quantized models, we don't need to explicitly move to CUDA
        missing_keys, unexpected_keys = slm_pg.load_state_dict(checkpoint['model_state_dict'], strict=False)
        if missing_keys:
            print(f"[Checkpoint Load] Missing keys in model: {missing_keys}")
        if unexpected_keys:
            print(f"[Checkpoint Load] Unexpected keys in checkpoint: {unexpected_keys}")
        # Additional completeness check
        model_keys = set(slm_pg.state_dict().keys())
        checkpoint_keys = set(checkpoint['model_state_dict'].keys())
        missing = model_keys - checkpoint_keys
        unexpected = checkpoint_keys - model_keys
        if missing:
            print(f"[Checkpoint Load] Model keys missing from checkpoint: {missing}")
        if unexpected:
            print(f"[Checkpoint Load] Checkpoint keys not in model: {unexpected}")
        if 'optimizer_state_dict' in checkpoint:
            optimizer.load_state_dict(checkpoint['optimizer_state_dict'])
            # Move optimizer states to GPU if needed
            for state in optimizer.state.values():
                for k, v in state.items():
                    if isinstance(v, torch.Tensor):
                        state[k] = v.to(device)
        total_rewards = checkpoint.get('rewards', [])
        successful_examples = checkpoint.get('successful_examples', [])
        processed_samples = checkpoint.get('processed_samples', set())
        print(f"Loaded checkpoint with {len(total_rewards)} previous rewards, {len(successful_examples)} successful examples, and {len(processed_samples)} processed samples")
        return checkpoint, total_rewards, successful_examples, processed_samples
    except (RuntimeError, EOFError, zipfile.BadZipFile) as e:
        print(f"Error loading checkpoint - file may be corrupted: {str(e)}")
        # Try to remove the corrupted checkpoint
        try:
            os.remove(checkpoint_path)
            print(f"Removed corrupted checkpoint file: {checkpoint_path}")
        except OSError as e:
            print(f"Could not remove corrupted checkpoint: {str(e)}")
        return None, [], [], set()
    except Exception as e:
        print(f"Unexpected error loading checkpoint: {str(e)}")
        return None, [], [], set()

def save_checkpoint_safely(checkpoint_data, checkpoint_path):
    checkpoint_path = "/mnt/shared/gpfs/home/manvij2/checkpoints/run_CHK/final_model_new.pt"
    """
    Safely save a checkpoint by first saving to a temporary file and then moving it to the final location.
    This prevents corruption if the saving process is interrupted.
    
    Args:
        checkpoint_data (dict): Dictionary containing the checkpoint data
        checkpoint_path (str): Path where the checkpoint should be saved
        
    Returns:
        bool: True if saving was successful, False otherwise
    """
    try:
        # Create a temporary file path
        temp_path =  "/mnt/shared/gpfs/home/manvij2/checkpoints/run_CHK/final_model_temp.pt"
        backup_path = "/mnt/shared/gpfs/home/manvij2/checkpoints/run_CHK/final_model_backup.pt"
        
        # Save to temporary file first
        torch.save(checkpoint_data, temp_path)

        # Check for missing/unexpected keys after saving
        if 'model_state_dict' in checkpoint_data:
            model_keys = set(checkpoint_data['model_state_dict'].keys())
            print(f"[Checkpoint Save] Model state_dict keys: {sorted(model_keys)}")
        
        # Verify the saved file can be loaded
        try:
            # Test load the temporary file
            test_load = torch.load(temp_path, map_location='cpu')
            if not all(k in test_load for k in ['model_state_dict', 'optimizer_state_dict']):
                raise ValueError("Saved checkpoint is missing required keys")
            # Check for missing/unexpected keys after loading
            if 'model_state_dict' in test_load and 'model_state_dict' in checkpoint_data:
                saved_keys = set(test_load['model_state_dict'].keys())
                orig_keys = set(checkpoint_data['model_state_dict'].keys())
                missing = orig_keys - saved_keys
                unexpected = saved_keys - orig_keys
                if missing:
                    print(f"[Checkpoint Save] Missing keys in saved checkpoint: {missing}")
                if unexpected:
                    print(f"[Checkpoint Save] Unexpected keys in saved checkpoint: {unexpected}")
        except Exception as e:
            print(f"Verification of saved checkpoint failed: {str(e)}")
            if os.path.exists(temp_path):
                os.remove(temp_path)
            return False
        
        # If we have an existing checkpoint, create a backup
        if os.path.exists(checkpoint_path):
            try:
                os.replace(checkpoint_path, backup_path)
            except OSError as e:
                print(f"Warning: Could not create backup of existing checkpoint: {str(e)}")
        
        # Move the temporary file to the final location
        try:
            os.replace(temp_path, checkpoint_path)
            # Remove the backup if everything succeeded
            return True
        except OSError as e:
            print(f"Error moving temporary checkpoint to final location: {str(e)}")
            # Try to restore from backup if move failed
            if os.path.exists(backup_path):
                try:
                    os.replace(backup_path, checkpoint_path)
                    print("Restored previous checkpoint from backup")
                except OSError:
                    print("Could not restore from backup")
            return False
            
    except Exception as e:
        print(f"Error saving checkpoint: {str(e)}")
        # Clean up temporary files
        for path in [temp_path, backup_path]:
            if os.path.exists(path):
                try:
                    os.remove(path)
                except:
                    pass
        return False

def train_slm_with_grpo(env, slm, num_epochs=10, batch_size=1, learning_rate=1e-4, gamma=0.99, epsilon=0.2, checkpoint_path="/mnt/shared/gpfs/home/manvij2/checkpoints/run_CHK/final_model_new.pt", start_epoch=0):
    logging.info("Starting/Resuming SLM training with GRPO...")
    
    # Convert base model to SLMPG to add value head
    slm_pg = SLMPG(slm).to(device)
    # Separate parameter groups for actor and critic
    actor_params = list(slm_pg.model.parameters())
    critic_params = list(slm_pg.value_head.parameters())
    actor_optimizer = optim.Adam(actor_params, lr=learning_rate)
    critic_optimizer = optim.Adam(critic_params, lr=learning_rate)
    
    # Load checkpoint if provided
    total_rewards = []
    successful_examples = []
    processed_samples = set()
    if checkpoint_path and os.path.exists(checkpoint_path):
        checkpoint, loaded_rewards, loaded_examples, loaded_samples = load_checkpoint(checkpoint_path, slm_pg, actor_optimizer)
        if checkpoint:
            total_rewards = loaded_rewards
            successful_examples = loaded_examples
            processed_samples = loaded_samples
            logging.info(f"Successfully loaded checkpoint. Resuming from epoch {start_epoch}")
    
    # Create checkpoint directory
    run_dir = os.path.join(CHECKPOINT_DIR, f"run_CHK")
    os.makedirs(run_dir, exist_ok=True)
    logging.info(f"Created checkpoint directory at: {run_dir}")
    
    actor_scheduler = ReduceLROnPlateau(actor_optimizer, mode='min', factor=0.5, patience=7, verbose=True)
    critic_scheduler = ReduceLROnPlateau(critic_optimizer, mode='min', factor=0.5, patience=7, verbose=True)
    
    for epoch in range(start_epoch, num_epochs):
        epoch_start_time = time.time()
        logging.info(f"\nStarting Epoch {epoch + 1}/{num_epochs}")
        epoch_rewards = []
        epoch_successful = []
        epoch_policy_losses = []
        epoch_value_losses = []
        
        for batch_idx in range(batch_size):
            logging.info(f"Processing batch {batch_idx + 1}/{batch_size}")
            done = False
            episode_reward = 0
            episode_values = []
            episode_log_probs = []
            episode_rewards = []
            episode_actions = []
            episode_states = []
            
            # Skip if this sample has already been processed
            sample_id = f"{env.subfolder_path}_{epoch}_{batch_idx}"
            if sample_id in processed_samples:
                logging.info(f"Skipping already processed sample: {sample_id}")
                continue
            
            while not done:
                prompt, reward, done, info = env.stepss()
                if not prompt:
                    continue
                
                try:
                    inputs = global_tokenizer(prompt, return_tensors="pt", truncation=True, padding=True).to(device)
                    logits, value = slm_pg(**inputs)
                    probs = F.softmax(logits[:, -1, :], dim=-1)
                    probs = probs + 1e-10
                    probs = probs / probs.sum()
                    dist = Categorical(probs)
                    action = dist.sample()
                    log_prob = dist.log_prob(action)
                    if not torch.isnan(value).any() and not torch.isinf(value).any():
                        episode_values.append(value)
                        episode_log_probs.append(log_prob)
                        episode_rewards.append(reward)
                        episode_reward += reward
                        episode_actions.append(action)
                        episode_states.append(inputs)
                    
                    # Log step-level metrics
                    wandb.log({
                        "step_reward": reward,
                        "step_value": value.item(),
                        "step_log_prob": log_prob.item(),
                        "is_successful": info.get("successful_examples_count", 0) > 0
                    })
                    logging.info(f"Step metrics - Reward: {reward}, Value: {value.item()}, Log Prob: {log_prob.item()}, Success: {info.get('successful_examples_count', 0) > 0}")
                    
                    
                except Exception as e:
                    logging.error(f"Error during training step: {str(e)}")
                    done = True
                    continue
            
            processed_samples.add(sample_id)
            
            if len(episode_values) > 0:
                # Clip rewards to [-10, 10]
                episode_rewards = [max(-10, min(10, r)) for r in episode_rewards]
                
                returns = []
                advantages = []
                R = 0
                
                for r, v in zip(reversed(episode_rewards), reversed(episode_values)):
                    R = r + gamma * R
                    advantage = R - v.item()
                    returns.append(R)
                    advantages.append(advantage)
                
                returns = torch.tensor(list(reversed(returns)), device=device)
                advantages = torch.tensor(list(reversed(advantages)), device=device)
                advantages = torch.clamp(advantages, min=-10.0, max=10.0)
                
                if len(advantages) > 1:
                    advantages = (advantages - advantages.mean()) / (advantages.std() + 1e-8)
                # Simple policy gradient loss (for ablation/comparison)
                policy_loss_pg = -advantages.mean()
                # PPO ratio fix: recompute new log_probs under current policy
                old_log_probs = torch.stack(episode_log_probs).detach()
                new_log_probs = []
                for state, action in zip(episode_states, episode_actions):
                    logits, _ = slm_pg(**state)
                    probs = F.softmax(logits[:, -1, :], dim=-1)
                    probs = probs + 1e-10
                    probs = probs / probs.sum()
                    dist = Categorical(probs)
                    new_log_prob = dist.log_prob(action)
                    new_log_probs.append(new_log_prob)
                new_log_probs = torch.stack(new_log_probs)
                ratio = torch.exp(new_log_probs - old_log_probs)
                ratio = torch.clamp(ratio, 0.0, 5.0)
                surr1 = ratio * advantages
                surr2 = torch.clamp(ratio, 1 - epsilon, 1 + epsilon) * advantages
                policy_loss = -torch.min(surr1, surr2).mean()
                # Log both losses for analysis
                wandb.log({
                    "policy_loss_pg": policy_loss_pg.item(),
                    "policy_loss_ppo": policy_loss.item(),
                })
                print(f"Policy Gradient Loss: {policy_loss_pg.item()}, PPO Loss: {policy_loss.item()}")
                
                value_targets = returns.unsqueeze(-1)
                values = torch.stack(episode_values)
                value_pred_clipped = torch.clamp(values, -10.0, 10.0)
                value_loss = F.mse_loss(value_pred_clipped, value_targets)
                
                if not (torch.isnan(policy_loss).any() or torch.isnan(value_loss).any()):
                    # Separate backward and optimizer steps for actor and critic
                    actor_optimizer.zero_grad()
                    policy_loss.backward(retain_graph=True)
                    torch.nn.utils.clip_grad_norm_(actor_params, max_norm=0.5)
                    actor_optimizer.step()

                    critic_optimizer.zero_grad()
                    (value_loss * 0.3).backward()
                    torch.nn.utils.clip_grad_norm_(critic_params, max_norm=0.5)
                    critic_optimizer.step()

                    # For logging and tracking, you can still combine the losses if needed
                    total_loss = policy_loss.item() + 0.3 * value_loss.item()
                    env.set_current_loss(policy_loss + 0.3 * value_loss)
                    epoch_policy_losses.append(policy_loss.item())
                    epoch_value_losses.append(value_loss.item())

                    wandb.log({
                        "batch_policy_loss": policy_loss.item(),
                        "batch_value_loss": value_loss.item(),
                        "batch_total_loss": total_loss,
                        "batch_reward": episode_reward,
                        "batch_size": len(episode_values),
                        "gradient_norm_actor": torch.nn.utils.clip_grad_norm_(actor_params, max_norm=float('inf')).item(),
                        "gradient_norm_critic": torch.nn.utils.clip_grad_norm_(critic_params, max_norm=float('inf')).item()
                    })
                    logging.info(f"Batch metrics - Policy Loss: {policy_loss.item()}, Value Loss: {value_loss.item()}, Total Loss: {total_loss}, Reward: {episode_reward}, Batch Size: {len(episode_values)}")
            
            epoch_rewards.append(episode_reward)
            logging.info(f"Batch {batch_idx + 1} completed with reward: {episode_reward}")
        
        # Calculate and log epoch metrics
        epoch_time = time.time() - epoch_start_time
        avg_reward = sum(epoch_rewards) / len(epoch_rewards) if epoch_rewards else 0
        avg_policy_loss = sum(epoch_policy_losses) / len(epoch_policy_losses) if epoch_policy_losses else 0
        avg_value_loss = sum(epoch_value_losses) / len(epoch_value_losses) if epoch_value_losses else 0
        
        wandb.log({
            "epoch": epoch + 1,
            "epoch_avg_reward": avg_reward,
            "epoch_avg_policy_loss": avg_policy_loss,
            "epoch_avg_value_loss": avg_value_loss,
            "epoch_successful_examples": len(epoch_successful),
            "epoch_time": epoch_time,
            "total_processed_samples": len(processed_samples),
            "learning_rate_actor": actor_optimizer.param_groups[0]['lr'],
            "learning_rate_critic": critic_optimizer.param_groups[0]['lr'],
            "memory_allocated": torch.cuda.memory_allocated(device=device),
            "memory_cached": torch.cuda.memory_reserved(device=device)
        })
        logging.info(f"Epoch {epoch + 1} metrics:")
        logging.info(f"Average Reward: {avg_reward}")
        logging.info(f"Average Policy Loss: {avg_policy_loss}")
        logging.info(f"Average Value Loss: {avg_value_loss}")
        logging.info(f"Successful Examples: {len(epoch_successful)}")
        logging.info(f"Epoch Time: {epoch_time}")
        logging.info(f"Total Processed Samples: {len(processed_samples)}")
        logging.info(f"Learning Rate (Actor): {actor_optimizer.param_groups[0]['lr']}")
        logging.info(f"Learning Rate (Critic): {critic_optimizer.param_groups[0]['lr']}")
        logging.info(f"GPU Memory Allocated: {torch.cuda.memory_allocated(device=device)}")
        logging.info(f"GPU Memory Cached: {torch.cuda.memory_reserved(device=device)}")
        
        # Save checkpoint locally
        checkpoint_path = os.path.join(run_dir, f"checkpoint_epoch_{epoch+1}.pt")
        checkpoint_data = {
            'epoch': epoch,
            'model_state_dict': slm_pg.state_dict(),
            'optimizer_state_dict': actor_optimizer.state_dict(),
            'rewards': total_rewards + epoch_rewards,
            'successful_examples': successful_examples + epoch_successful,
            'processed_samples': processed_samples
        }
        if not save_checkpoint_safely(checkpoint_data, checkpoint_path):
            logging.warning(f"Failed to save checkpoint for epoch {epoch + 1}, continuing training...")
        
        total_rewards.extend(epoch_rewards)
        successful_examples.extend(epoch_successful)
        
        logging.info(f"Epoch {epoch + 1} Summary:")
        logging.info(f"Average Reward: {avg_reward:.4f}")
        logging.info(f"Successful Examples: {len(epoch_successful)}")
        logging.info(f"Total Processed Samples: {len(processed_samples)}")
        
        torch.cuda.empty_cache()
        
        # At the end of each epoch, step the schedulers with the average losses
        actor_scheduler.step(avg_policy_loss)
        critic_scheduler.step(avg_value_loss)
    
    # Save final model locally
    final_model_path = os.path.join(run_dir, "final_model_new.pt")
    final_lora_path = os.path.join(run_dir, "final_lora")

    # Rebuild checkpoint_data with latest state before final save
    checkpoint_data = {
        'epoch': epoch,  # or num_epochs-1
        'model_state_dict': slm_pg.state_dict(),
        'optimizer_state_dict': actor_optimizer.state_dict(),
        'rewards': total_rewards,
        'successful_examples': successful_examples,
        'processed_samples': processed_samples
    }
    if not save_checkpoint_safely(checkpoint_data, final_model_path):
        logging.error("Failed to save final model checkpoint!")

    if hasattr(slm_pg.model, "save_pretrained"):
        try:
            slm_pg.model.save_pretrained(final_lora_path)
            logging.info("Successfully saved LoRA weights")
        except Exception as e:
            logging.error(f"Failed to save LoRA weights: {str(e)}")
    
    # Save final plots and metrics
    if metrics_tracker is not None:
        metrics_tracker.plot_learning_curves()
        metrics_tracker.save_metrics()
        
        # Log final plots to wandb
        for plot_name in ["episode_rewards.png", "success_rate.png", "error_analysis.png"]:
            plot_path = os.path.join(metrics_tracker.save_dir, plot_name)
            if os.path.exists(plot_path):
                wandb.log({plot_name.replace(".png", ""): wandb.Image(plot_path)})
    
    return total_rewards, successful_examples


def extract_dafny_code(text):
    pattern_snippet = r"```dafny(.*?)```"
    snippets = re.findall(pattern_snippet, text, re.DOTALL)
    trimmed_snippet = ""
    if snippets:
        trimmed_snippet = snippets[-1].strip()
    return trimmed_snippet

def run_SLM(prompt):
    try:
        checkpoint_path = "/mnt/shared/gpfs/home/manvij2/checkpoints/run_CHK/final_model_new.pt"
        model, tok = initialize_slm(checkpoint_path)
        # Print model config for debugging
        print("Model config hidden size:", getattr(model.config, 'hidden_size', 'N/A'))
        print("Model embedding size:", model.get_input_embeddings().weight.shape)
        # More conservative generation parameters
        generation_config = {
            "max_new_tokens": 512,
            "do_sample": False,
            # "temperature": 0.9,  # Increased from 0.7
            # "top_p": 0.8,
            # "top_k": 20,
            "num_beams": 1,
            "pad_token_id": tok.pad_token_id,
            "eos_token_id": tok.eos_token_id,
            "repetition_penalty": 1.0,  # Reduced from 1.1
            "no_repeat_ngram_size": 0,  # Disabled n-gram repetition penalty
            "use_cache": True,
            "max_length": 1024,  # Add explicit max length
            "min_length": 10,   # Add min length
            "length_penalty": 1.0
        }
        # Enable mixed precision for generation
        with torch.cuda.amp.autocast():
            # Pad/truncate to a safe length (e.g., 256)
            inputs = tok(prompt, return_tensors="pt", truncation=True, padding='max_length', max_length=512).to(device)
            print("Input IDs shape:", inputs['input_ids'].shape)
            # Do NOT squeeze or reshape input_ids
            # Set model to eval mode for generation
            model.eval()
            with torch.no_grad():
                # Add safety check for input length
                if inputs['input_ids'].shape[1] > 512:
                    inputs = {k: v[:, :512] for k, v in inputs.items()}
                out = model.generate(**inputs, **generation_config)
            model.train()
            response = tok.decode(out[0], skip_special_tokens=True)
        # Save SLM prompt and response
        save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/prompts/slm_new"
        os.makedirs(save_dir, exist_ok=True)
        timestamp = time.strftime("%Y%m%d_%H%M%S")
        with open(os.path.join(save_dir, f"slm_interaction_{timestamp}.json"), "w") as f:
            json.dump({
                "timestamp": timestamp,
                "prompt": prompt,
                "response": response
            }, f, indent=2)
        return response
    except Exception as e:
        logging.error(f"Error in run_SLM: {str(e)}")
        # Return empty string instead of error message to allow for retry
        return ""
    finally:
        if 'model' in locals():
            model.train()


def save_prompt_response(prompt, response, save_dir):
        timestamp = time.strftime("%Y%m%d_%H%M%S")
        os.makedirs(save_dir, exist_ok=True)
        
        with open(os.path.join(save_dir, f"llm_interaction_{timestamp}.json"), "w") as f:
            json.dump({
                "timestamp": timestamp,
                "prompt": prompt,
                "response": response
            }, f, indent=2)


def run_LLM(responses):
    

    genai.configure(api_key="AIzaSyAImTEOaz6oQXEvesUx18rluO0exqo2XIA")
    model = genai.GenerativeModel('gemini-2.0-flash')
    prompts = responses + " You must return the full code in the following form:\n```dafny\nDafny Code\n```"

    generated_texts = []
    
    response = model.generate_content(prompts , generation_config=genai.types.GenerationConfig(temperature=0.75))
    generated_texts =response.text
    print(generated_texts)
    save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/prompts/llm_new"
    save_prompt_response(prompts, response.text, save_dir)

    return generated_texts


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
              " Final suggestions or reminders to avoid common pitfalls. make sure that you do not miss ';' in the code, if you see related issues in the error message, make sure to fix it.\n"
              " Here is the task:\n")
    Prompt += Task + "\n Below is the errored code: \n"
    Prompt += code + "\n Below is the error message: \n"
    Prompt += error + "\n Below is the reward for the previous attempt. TRY TO MAXIMIZE IT THIS TIME, it is based on the correctness of the code that the LLM generated based on your instructions: \n"
    if isinstance(rewa, list):
        Prompt += str(rewa[-1])
    else:
        Prompt += str(rewa)
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

def process_one_subfolder(entry, subfolder_path, args):
    # Initialize wandb in each subprocess
    wandb.init(
        project=args.wandb_project,
        entity=args.wandb_entity,
        name=f"dafny_rl_new2_{entry}",
        config=vars(args),
        id=f"pxs38hcs",
        resume="allow"
    )
    # Each worker/process gets its own model and tokenizer
    model, tokenizer = initialize_slm(args.checkpoint)
    # Check if this subfolder has already been processed
    epoch_dir = os.path.join("/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset", f"epoch_0_{entry}")
    result_file = os.path.join(epoch_dir, "iteration_1_results.json")
    if os.path.exists(result_file):
        print(f"Skipping {entry} as it has already been processed (found {result_file})")
        # wandb.finish()
        return entry, None
    description_file = os.path.join(subfolder_path, "detailed_description.txt")
    if not os.path.exists(description_file):
        # wandb.finish()
        return entry, None
    print(f"\nProcessing subfolder: {subfolder_path}")
    with open(description_file, "r", encoding='utf-8') as file:
        sample_prompt = file.read().strip()
    print("Sample prompt:\n", sample_prompt[:200] + "...")
    tmp_path = os.path.join(subfolder_path, "RL_No_feedback.dfy")   
    error_path = os.path.join(subfolder_path, "RL_error.txt")
    env = DafnyEnv(sample_prompt, tmp_path, error_path)
    print(f"Starting training for {entry}...")
    successful_examples, total_rewards = train_slm_with_grpo(
        env, model, num_epochs=5,
        checkpoint_path=args.checkpoint,
        start_epoch=args.start_epoch
    )
    # Save checkpoint after each subfolder
    checkpoint_dir = os.path.dirname(args.checkpoint)
    os.makedirs(checkpoint_dir, exist_ok=True)
    checkpoint_data = {
        'model_state_dict': model.state_dict(),
        'optimizer_state_dict': optimizer.state_dict(),
        'entry': entry,
        'total_rewards': total_rewards,
        'successful_examples': successful_examples
    }
    if not save_checkpoint_safely(checkpoint_data, args.checkpoint):
        print(f"Warning: Failed to save checkpoint after processing {entry}")
    else:
        print(f"Successfully saved checkpoint after processing {entry}")
    result = {
        'total_rewards': total_rewards,
        'successful_examples': successful_examples,
        'final_model_state': f"model_state_{entry}.pt"
    }
    torch.cuda.empty_cache()
    import gc
    gc.collect()
    wandb.finish()
    return entry, result

if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser(description='Run Dafny code generation with specified temperature')
        parser.add_argument('--temperature', type=float, default=0.75,
                          help='Temperature for LLM generation (default: 0.75)')
        parser.add_argument('--checkpoint', type=str, default="/mnt/shared/gpfs/home/manvij2/checkpoints/run_CHK/final_model_new.pt",
                          help='Path to checkpoint file to resume training from')
        parser.add_argument('--start_epoch', type=int, default=0,
                          help='Epoch to start from when resuming training')
        parser.add_argument('--wandb_project', type=str, default="dafny-rl_new2",
                          help='Weights & Biases project name')
        parser.add_argument('--wandb_entity', type=str, default="drprofmjha-university-of-illinois-urbana-champaign",
                          help='Weights & Biases entity (username or team name)')
        args = parser.parse_args()

        print("Starting execution...")
        # Only initialize optimizer globally (not model/tokenizer)
        global optimizer
        optimizer = optim.Adam(
            filter(lambda p: p.requires_grad, initialize_slm(args.checkpoint)[0].parameters()),
            lr=5e-5,
            weight_decay=0.01
        )
        root_directory = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny"
        results = {}
        print(f"\nProcessing folders in {root_directory}")
        # Gather subfolders to process
        subfolder_entries = []
        for entry in os.listdir(root_directory):
            subfolder_path = os.path.join(root_directory, entry)
            if not os.path.isdir(subfolder_path):
                continue
            subfolder_entries.append((entry, subfolder_path))
        # Parallel processing of subfolders using ProcessPoolExecutor
        with concurrent.futures.ProcessPoolExecutor(max_workers=2) as executor:
            future_to_entry = {
                executor.submit(process_one_subfolder, entry, subfolder_path, args): entry
                for entry, subfolder_path in subfolder_entries
            }
            for future in concurrent.futures.as_completed(future_to_entry):
                entry = future_to_entry[future]
                try:
                    entry_key, result = future.result()
                    if result is not None:
                        results[entry_key] = result
                except Exception as exc:
                    print(f"{entry} generated an exception: {exc}")
        print("\nSaving final results...")
        with open(os.path.join(root_directory, "training_results.json"), "w") as f:
            json.dump(results, f, indent=2)
        print("\nTraining completed successfully!")
    except Exception as e:
        print(f"Error during execution: {str(e)}")
        import traceback
        traceback.print_exc()
        torch.cuda.empty_cache()
        import gc
        gc.collect()
        wandb.finish()  # Ensure wandb run is properly closed even on error
