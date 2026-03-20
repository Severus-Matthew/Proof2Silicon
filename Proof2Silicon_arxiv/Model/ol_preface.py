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
from transformers import pipeline, AutoModelForCausalLM, AutoTokenizer, TrainingArguments, Trainer
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from datasets import Dataset
import torch.nn.functional as F
import argparse
from dataclasses import dataclass
from typing import List, Dict, Optional, Any
import matplotlib.pyplot as plt
from datetime import datetime

# --- Memory Management: Set environment variable for CUDA allocation ---
if "PYTORCH_CUDA_ALLOC_CONF" not in os.environ:
    os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "expandable_segments:True"

# --- Set global device ---
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print("Using device:", device)

# Global variables for SLM
global_model = None
global_tokenizer = None

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
        """Return a flat list of all nodes in the tree."""
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
        loss_weight = inputs.pop('loss_weight', None)
        outputs = model(**inputs)
        loss = outputs.loss
        if loss_weight is not None:
            loss = loss * loss_weight.mean()
        return (loss, outputs) if return_outputs else loss
def initialize_slm():
    global global_model, global_tokenizer

    if global_model is not None and global_tokenizer is not None:
        print("Model and tokenizer already initialized, reusing existing instances")
        return global_model, global_tokenizer

    print("Initializing model and tokenizer for the first time...")

    model_name = "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
    global_tokenizer = AutoTokenizer.from_pretrained(model_name)
    if global_tokenizer.pad_token is None:
        global_tokenizer.pad_token = global_tokenizer.eos_token
        global_tokenizer.pad_token_id = global_tokenizer.eos_token_id

    # Force the model onto a single GPU (cuda:0) by setting device_map accordingly.
    print("Loading model on a single GPU (cuda:0) with lower precision (bfloat16)...")
    global_model = AutoModelForCausalLM.from_pretrained(
        model_name,
        torch_dtype=torch.bfloat16,
        device_map={"": "cuda:0"},  # Force all model components to gpu 0
        use_cache=True,
        low_cpu_mem_usage=True
    )
    
    # (Optional) You can also explicitly move the model to the global device, though it's already placed.
    global_model = global_model.to(device)
    
    lora_config = LoraConfig(
        r=16,
        lora_alpha=32,
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
        lora_dropout=0.1,
        bias="none",
        task_type="CAUSAL_LM",
        inference_mode=False,
        modules_to_save=["embed_tokens", "lm_head"]
    )
    
    print("Preparing model for LoRA fine-tuning...")
    global_model = prepare_model_for_kbit_training(global_model)
    global_model = get_peft_model(global_model, lora_config)
    
    return global_model, global_tokenizer


def fine_tune_slm(successful_examples):
    global global_model, global_tokenizer

    if not successful_examples:
        print("\n[Fine-tuning] No successful examples available for fine-tuning. Skipping...")
        return

    print(f"\n[Fine-tuning] Starting fine-tuning with {len(successful_examples)} successful examples")
    
    training_args = TrainingArguments(
        output_dir="./slm_checkpoints",
        num_train_epochs=1,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=4,
        learning_rate=2e-4,
        fp16=True,
        logging_steps=1,
        save_strategy="steps",
        save_steps=4,
        overwrite_output_dir=True,
        remove_unused_columns=False,
        gradient_checkpointing=True,
        save_total_limit=1,
        optim="paged_adamw_32bit",
        lr_scheduler_type="cosine",
        warmup_ratio=0.1,
        ddp_find_unused_parameters=False,
        label_names=["labels"],
    )
    
    def format_training_example(example):
        prompt = example["prompt"]
        response = example["response"]
        full_text = f"{prompt}\n{response}"
        
        tokenized = global_tokenizer(
            full_text,
            truncation=True,
            max_length=10000,
            padding="max_length",
            return_tensors=None  # Do not create tensors yet
        )
        input_ids = tokenized["input_ids"]
        attention_mask = tokenized["attention_mask"]
        labels = input_ids.copy()
        return {
            "input_ids": input_ids,
            "attention_mask": attention_mask,
            "labels": labels
        }
    
    print("[Fine-tuning] Formatting training examples...")
    train_data = [format_training_example(ex) for ex in successful_examples]
    dataset = Dataset.from_list(train_data)
    print(f"[Fine-tuning] Created dataset with {len(dataset)} examples")
    
    def collate_fn(examples):
        batch = {
            key: torch.tensor([ex[key] for ex in examples]).to(device)
            for key in examples[0].keys()
        }
        return batch
    
    print("[Fine-tuning] Initializing trainer...")
    trainer = Trainer(
        model=global_model,
        args=training_args,
        train_dataset=dataset,
        data_collator=collate_fn,
    )
    
    global_model.train()
    for param in global_model.parameters():
        param.requires_grad = True

    try:
        print("[Fine-tuning] Starting training...")
        trainer.train()
        print("[Fine-tuning] Training completed successfully!")
        print("[Fine-tuning] Model parameters after fine-tuning:", sum(p.numel() for p in global_model.parameters() if p.requires_grad))
    except Exception as e:
        print(f"[Fine-tuning] Error during training: {str(e)}")
        pass

def fine_tune_slm_on_tree(error_tree: ErrorTree):
    global global_model, global_tokenizer

    if not error_tree or error_tree.root is None:
        print("No error tree available for training.")
        return

    nodes = error_tree.traverse()
    
    def calculate_weight(reward: float):
        offset = 10.0
        return reward + offset

    training_args = TrainingArguments(
        output_dir="./slm_tree_checkpoints",
        num_train_epochs=1,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=4,
        learning_rate=2e-4,
        fp16=True,
        logging_steps=1,
        save_strategy="steps",
        save_steps=4,
        overwrite_output_dir=True,
        remove_unused_columns=False,
        gradient_checkpointing=True,
        save_total_limit=1,
        optim="paged_adamw_32bit",
        lr_scheduler_type="cosine",
        warmup_ratio=0.1,
        ddp_find_unused_parameters=False
    )
    
    def format_training_example(node: TreeNode):
        prompt = node.prompt
        response = node.error_message
        full_text = f"{prompt}\n Error: \n{response}"
        
        tokenized = global_tokenizer(
            full_text,
            truncation=True,
            max_length=10000,
            padding="max_length",
            return_tensors=None
        )
        weight = calculate_weight(node.reward)
        return {
            "input_ids": tokenized["input_ids"],
            "attention_mask": tokenized["attention_mask"],
            "labels": tokenized["input_ids"].copy(),
            "loss_weight": weight
        }
    
    train_data = [format_training_example(node) for node in nodes]
    dataset = Dataset.from_list(train_data)
    
    def collate_fn(examples):
        batch = {
            "input_ids": torch.tensor([ex["input_ids"] for ex in examples]).to(device),
            "attention_mask": torch.tensor([ex["attention_mask"] for ex in examples]).to(device),
            "labels": torch.tensor([ex["labels"] for ex in examples]).to(device),
            "loss_weight": torch.tensor([ex["loss_weight"] for ex in examples], dtype=torch.float32).to(device)
        }
        return batch
    
    global_model.train()
    trainer = WeightedTrainer(
        model=global_model,
        args=training_args,
        train_dataset=dataset,
        data_collator=collate_fn,
    )

    try:
        trainer.train()
    except Exception as e:
        print(f"Fine-tuning on full tree error: {str(e)}")
        pass

def run_SLM(prompt: str,
            error_context: Optional[Dict] = None,
            successful_examples: Optional[List] = None,
            error_tree: Optional[ErrorTree] = None):
    global global_model, global_tokenizer

    if global_model is None or global_tokenizer is None:
        global_model, global_tokenizer = initialize_slm()

    if error_tree is not None:
        fine_tune_slm_on_tree(error_tree)
    elif successful_examples:
        fine_tune_slm(successful_examples)

    if error_context:
        full_prompt = (
            f"Given the following context:\n"
            f"1. Original Task: {prompt}\n"
            f"2. Current Error Code: {error_context['error_code']}\n"
            f"3. Error Message: {error_context['error_message']}\n"
            f"4. Current Reward: {error_context['reward']}\n"
            f"5. Previous Attempts: {error_context['attempts']} attempts made\n\n"
            f"Please analyze the error and generate a new prompt that will help the LLM resolve this specific error. "
            f"Focus on addressing the root cause of the error while maintaining the original task requirements."
        )
    else:
        full_prompt = ShortPrompt(prompt)

    inputs = global_tokenizer(full_prompt, return_tensors="pt").to(device)
    outputs = global_model.generate(
        **inputs,
        max_new_tokens=8000,
        do_sample=True,
        temperature=0.7,
        top_k=50,
        top_p=0.95
    )
    response = global_tokenizer.decode(outputs[0], skip_special_tokens=True)
    return response

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

def ErrorPrompt(error, Task, code):
    Prompt = ("You are an expert in understanding Dafny code and explaining it in detailed, structured steps "
              "to another agent. Your explanations should be clear, thorough, and logically organized so that the agent "
              "can effectively use them to write correct and error-free Dafny code. Given the following task, an LLM generated code and the associated error message break down "
              "the required Dafny program into:\n"
              " Step-by-step reasoning about the logic and specification and ways to solve this error.\n"
              " Relevant Dafny constructs and their usage (e.g., preconditions, postconditions, invariants).\n"
              " Potential edge cases and how to handle them.\n"
              " Final suggestions or reminders to avoid common pitfalls.\n"
              " Here is the task:\n")
    Prompt += Task + "\n Below is the errored code: \n"
    Prompt += code + "\n Below is the error message: \n"
    Prompt += error
    return Prompt

def run_LLM(response):
    # Using HF pipeline for LLM inference; consider replacing this with vLLM if desired.
    if not hasattr(run_LLM, 'pipe'):
        print("Initializing LLM model and tokenizer...")
        run_LLM.pipe = pipeline(
            task="text-generation",
            model="deepseek-ai/DeepSeek-R1-Distill-Qwen-32B",
            torch_dtype=torch.bfloat16,
            device_map="auto",
            model_kwargs={
                "low_cpu_mem_usage": True,
                "use_cache": True
            }
        )
    
    if "</think>" in response:
        response = response.split("</think>", 1)[1].strip()
    
    prompt = str(response) + "You must return the full code in the following Form:" + "\n" + "```dafny" + "\n" + "Dafny Code" + "\n" + "```"
    messages = [
        {"role": "system", "content": "You are an expert in writing Dafny code"},
        {"role": "user", "content": prompt},
    ]
    
    outputs = run_LLM.pipe(messages, max_new_tokens=8000, do_sample=True, temperature=0.7, top_k=50, top_p=0.95)
    response = outputs[0]["generated_text"][-1]['content']
    return response

def extract_dafny_code(text):
    pattern_snippet = r"```dafny(.*?)```"
    snippets = re.findall(pattern_snippet, text, re.DOTALL)
    trimmed_snippet = ""
    if snippets:
        trimmed_snippet = snippets[-1].strip()
    return trimmed_snippet

def run_dafny(tmp_path, code, error_path):
    with open(tmp_path, "w", encoding='utf-8') as file:
        file.write(code)
    
    dafny_directory = r"/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
    os.chdir(dafny_directory)
    
    dafny_command = f"/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny '{tmp_path}' > '{error_path}'"
    os.system(dafny_command)
    
    with open(error_path, "r", encoding='utf-8') as output_file:
        output = output_file.read()
        if output.startswith("Dafny code"):
            output = output.split("Dafny code", 1)[1].strip()
        
        if "verified, 0 errors" in output:
            if "Compiled assembly into" in output:
                success = 1
            else:
                success = 0
        else:
            success = 0
    return success

def save_iteration_results(subfolder_path, iteration, epoch, reward, error_output, code, error_count):
    folder_name = os.path.basename(subfolder_path)
    root_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset"
    epoch_dir = os.path.join(root_dir, f"epoch_{epoch}_{folder_name}")
    os.makedirs(epoch_dir, exist_ok=True)
    
    with open(os.path.join(epoch_dir, f"iteration_{iteration}_results.json"), "w") as f:
        json.dump({
            "reward": reward,
            "error_count": error_count,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "folder": folder_name
        }, f, indent=2)
    
    with open(os.path.join(epoch_dir, f"iteration_{iteration}_code.dfy"), "w") as f:
        f.write(code)
    
    with open(os.path.join(epoch_dir, f"iteration_{iteration}_error.txt"), "w") as f:
        f.write(error_output)

def save_epoch_summary(subfolder_path, epoch, total_reward, successful_examples_count, error_tree):
    folder_name = os.path.basename(subfolder_path)
    root_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset"
    
    with open(os.path.join(root_dir, f"epoch_{epoch}_{folder_name}_summary.json"), "w") as f:
        json.dump({
            "epoch": epoch,
            "folder": folder_name,
            "total_reward": total_reward,
            "successful_examples_count": successful_examples_count,
            "error_tree_depth": error_tree.current_node.depth if error_tree.current_node else 0,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
        }, f, indent=2)

class MetricsTracker:
    def __init__(self, save_dir):
        self.save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset"
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
        
        plt.figure(figsize=(12, 6))
        plt.plot(self.episode_rewards, label='Episode Rewards', color='blue')
        plt.xlabel('Episode')
        plt.ylabel('Reward')
        plt.title(f'Episode Rewards - {folder_name}')
        plt.grid(True)
        plt.legend()
        plt.savefig(os.path.join(self.save_dir, f'episode_rewards_{folder_name}_{timestamp}.png'))
        plt.close()
        
        plt.figure(figsize=(12, 6))
        plt.plot(self.cumulative_rewards, label='Cumulative Rewards', color='green')
        plt.xlabel('Episode')
        plt.ylabel('Cumulative Reward')
        plt.title(f'Cumulative Rewards - {folder_name}')
        plt.grid(True)
        plt.legend()
        plt.savefig(os.path.join(self.save_dir, f'cumulative_rewards_{folder_name}_{timestamp}.png'))
        plt.close()
        
        plt.figure(figsize=(12, 6))
        plt.plot(self.success_rates, label='Success Rate', color='orange')
        plt.xlabel('Episode')
        plt.ylabel('Success Rate')
        plt.title(f'Verification Success Rate - {folder_name}')
        plt.grid(True)
        plt.legend()
        plt.savefig(os.path.join(self.save_dir, f'success_rate_{folder_name}_{timestamp}.png'))
        plt.close()
        
        plt.figure(figsize=(12, 6))
        colors = ['red', 'purple', 'brown', 'pink']
        for (error_type, counts), color in zip(self.error_types.items(), colors):
            plt.plot(counts, label=error_type, color=color)
        plt.xlabel('Episode')
        plt.ylabel('Error Count')
        plt.title(f'Error Type Analysis - {folder_name}')
        plt.grid(True)
        plt.legend()
        plt.savefig(os.path.join(self.save_dir, f'error_analysis_{folder_name}_{timestamp}.png'))
        plt.close()
        
        if self.training_loss:
            plt.figure(figsize=(12, 6))
            valid_indices = [i for i, x in enumerate(self.training_loss) if not (np.isnan(x) or np.isinf(x))]
            valid_epochs = [i for i in valid_indices]
            valid_losses = [self.training_loss[i] for i in valid_indices]
            if valid_losses:
                plt.plot(valid_epochs, valid_losses, label='Training Loss', color='red')
                if self.validation_loss:
                    valid_val_indices = [i for i, x in enumerate(self.validation_loss) if not (np.isnan(x) or np.isinf(x))]
                    valid_val_epochs = [i for i in valid_val_indices]
                    valid_val_losses = [self.validation_loss[i] for i in valid_val_indices]
                    if valid_val_losses:
                        plt.plot(valid_val_epochs, valid_val_losses, label='Validation Loss', color='blue')
                plt.xlabel('Epoch')
                plt.ylabel('Loss')
                plt.title(f'Model Training Progress - {folder_name}')
                plt.grid(True)
                plt.legend()
                plt.savefig(os.path.join(self.save_dir, f'training_loss_{folder_name}_{timestamp}.png'))
            else:
                print(f"Warning: No valid loss values to plot for {folder_name}")
            plt.close()
    
    def save_metrics(self):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        folder_name = os.path.basename(os.path.dirname(self.save_dir))
        metrics_data = {
            'folder': folder_name,
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
            'error_types': {k: list(v) for k, v in self.error_types.items()},
            'epoch_times': self.epoch_times,
            'total_training_time': time.time() - self.start_time
        }
        with open(os.path.join(self.save_dir, f'metrics_{folder_name}_{timestamp}.json'), 'w') as f:
            json.dump(metrics_data, f, indent=2)

metrics_tracker = None

class DafnyEnv(gym.Env):
    def __init__(self, prompt, tmp_path, error_path):
        super(DafnyEnv, self).__init__()
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
        
        global metrics_tracker
        if metrics_tracker is None:
            metrics_tracker = MetricsTracker(os.path.join(self.subfolder_path, "metrics"))
        
        self.observation_space = gym.spaces.Box(low=0, high=255, shape=(len(prompt),), dtype=np.uint8)
        self.action_space = gym.spaces.Discrete(1)

    def reset(self):
        self.error_tree = ErrorTree(max_depth=7)
        self.current_iteration = 0
        self.epoch_rewards = []
        return self.prompt

    def set_current_loss(self, loss):
        self.current_loss = float(loss.detach().item())

    def get_dafny_output(self, code: str) -> tuple[float, str, str]:
        if not code or code.strip() == "":
            metrics_tracker.update_rl_metrics(-7.0, False, 1, self.current_iteration)
            metrics_tracker.update_error_analysis("empty_file", False, 1)
            save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, -7.0, "Error: Empty Dafny file", "", 1)
            return -7.0, "Error: Empty Dafny file", code

        with open(self.tmp_path, "w", encoding='utf-8') as file:
            file.write(code)
        
        dafny_directory = r"/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
        os.chdir(dafny_directory)
        
        dafny_command = f"/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny '{self.tmp_path}' > '{self.error_path}'"
        os.system(dafny_command)
        
        with open(self.error_path, "r", encoding='utf-8') as output_file:
            output = output_file.read()
            if output.startswith("Dafny code"):
                output = output.split("Dafny code", 1)[1].strip()
            
            if "verified, 0 errors" in output:
                if "Compiled assembly into" in output:
                    reward = 5.0
                    metrics_tracker.update_rl_metrics(reward, True, 0, self.current_iteration)
                    metrics_tracker.update_error_analysis("success", True, 0)
                    save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, output, code, 0)
                    return reward, output, code
            
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
            total_reward = -5.0 + shaped_penalty
            metrics_tracker.update_rl_metrics(total_reward, False, error_count, self.current_iteration)
            for error_type, count in error_types.items():
                metrics_tracker.update_error_analysis(error_type, False, error_count)
            
            print("total_reward: ", total_reward)
            print("error_count: ", error_count)
            print("iteration: ", self.current_iteration)
            print("--------------------------------")
            save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, total_reward, output, code, error_count)
            return total_reward, output, code

    def step(self, action):
        current_prompt = self.prompt if self.current_iteration == 0 else None
        total_reward = 0
        done = False
        
        error_context = None
        if self.current_iteration > 0 and self.error_tree.current_node:
            current_node = self.error_tree.current_node
            error_context = {
                'error_code': current_node.error_code,
                'error_message': current_node.error_message,
                'reward': current_node.reward,
                'attempts': self.current_iteration
            }
        
        for attempt in range(7):
            slm_response = run_SLM(
                prompt=current_prompt or self.prompt,
                error_context=error_context,
                successful_examples=self.successful_examples
            )
            
            llm_response = run_LLM(slm_response)
            dafny_code = extract_dafny_code(llm_response)
            
            if not dafny_code or dafny_code.strip() == "":
                self.current_iteration += 1
                continue
            
            reward, error_output, code = self.get_dafny_output(dafny_code)
            total_reward += reward
            self.epoch_rewards.append(reward)
            
            new_node = self.error_tree.add_node(
                error_code=code,
                error_message=error_output,
                reward=reward,
                prompt=slm_response,
                parent=self.error_tree.current_node
            )
            self.error_tree.current_node = new_node
            
            if reward > 0:
                self.successful_examples.append({
                    "prompt": slm_response,
                    "response": llm_response,
                    "error_context": error_context
                })
                if len(self.successful_examples) > 100:
                    self.successful_examples = self.successful_examples[-100:]
                new_node.success = True
                self.error_tree.successful_path = self.error_tree.get_path_to_node(new_node)
                done = True
                break
            
            self.current_iteration += 1
            if self.current_iteration >= 7:
                done = True
                break
        
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
        
        # Clear GPU cache after step to help reduce fragmentation.
        torch.cuda.empty_cache()
        
        return self.prompt, total_reward, done, info

class PPOAgent(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super(PPOAgent, self).__init__()
        self.fc = nn.Linear(input_size, hidden_size)
        self.policy_head = nn.Linear(hidden_size, output_size)
        self.value_head = nn.Linear(hidden_size, 1)

    def forward(self, x):
        x = torch.relu(self.fc(x))
        policy_logits = self.policy_head(x)
        value = self.value_head(x)
        return policy_logits, value

def train_ppo(agent, env, optimizer, num_epochs=5, gamma=0.99, clip_epsilon=0.2):
    total_rewards = 0
    successful_examples_history = []
    error_trees = []
    
    for epoch in range(num_epochs):
        env.current_epoch = epoch
        epoch_start_time = time.time()
        epoch_rewards = []
        epoch_losses = []
        
        obs = env.reset()
        input_size = agent.fc.in_features
        obs_encoded = [ord(c) for c in obs]
        if len(obs_encoded) < input_size:
            obs_encoded += [0] * (input_size - len(obs_encoded))
        else:
            obs_encoded = obs_encoded[:input_size]
        obs_tensor = torch.tensor(obs_encoded, dtype=torch.float32).unsqueeze(0).to(device)
        
        policy_logits, value = agent(obs_tensor)
        m = Categorical(logits=policy_logits)
        action = m.sample()
        log_prob = m.log_prob(action)
        
        next_obs, reward, done, info = env.step(action)
        total_rewards += reward
        epoch_rewards.append(reward)
        
        error_trees.append(info["error_tree"])
        successful_examples_history.append(info["successful_examples_count"])
        
        returns = reward * gamma
        value = value.squeeze(-1)
        advantage = returns - value.detach()
        
        ratio = torch.exp(m.log_prob(action) - log_prob.detach())
        surr1 = ratio * advantage
        surr2 = torch.clamp(ratio, 1 - clip_epsilon, 1 + clip_epsilon) * advantage
        policy_loss = -torch.min(surr1, surr2).mean()
        value_loss = F.mse_loss(value, torch.tensor([returns], dtype=torch.float32).to(device))
        loss = policy_loss + 0.5 * value_loss
        env.set_current_loss(loss)
        
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        
        env.set_current_loss(loss)
        
        if (epoch + 1) % 10 == 0:
            metrics_tracker.plot_learning_curves()
            metrics_tracker.save_metrics()
        
        if (epoch + 1) % 5 == 0:
            print(f"\nEpoch {epoch + 1}/{num_epochs}")
            print(f"Total Rewards: {total_rewards}")
            print(f"Successful Examples: {info['successful_examples_count']}")
            print(f"Average Loss: {loss.item():.4f}")
            print(f"Iterations in last episode: {info['iterations']}")
    
    return {
        "total_rewards": total_rewards,
        "successful_examples_history": successful_examples_history,
        "error_trees": error_trees
    }

def process_subfolders(root_directory, temperature):
    results = {}
    
    print("Initializing models for all subfolders...")
    global global_model, global_tokenizer
    if global_model is None or global_tokenizer is None:
        global_model, global_tokenizer = initialize_slm()
    
    lora_save_dir = os.path.join(root_directory, "lora_adapters")
    os.makedirs(lora_save_dir, exist_ok=True)
    
    for entry in os.listdir(root_directory):
        subfolder_path = os.path.join(root_directory, entry)
        if os.path.isdir(subfolder_path):
            description_file = os.path.join(subfolder_path, "detailed_description.txt")
            if os.path.exists(description_file):
                with open(description_file, "r", encoding='utf-8') as file:
                    sample_prompt = file.read().strip()
                
                print(f"\nProcessing subfolder: {subfolder_path}")
                print("Sample prompt:\n", sample_prompt)
                
                tmp_path = os.path.join(subfolder_path, "RL_No_feedback.dfy")
                error_path = os.path.join(subfolder_path, "RL_no_feedbacl_error.txt")
                
                env = DafnyEnv(sample_prompt, tmp_path, error_path)
                
                input_size = 10000  # example value
                hidden_size = 64
                output_size = 5

                # Send the agent to the designated device (GPU)
                agent = PPOAgent(input_size, hidden_size, output_size).to(device)
                optimizer = optim.Adam(agent.parameters(), lr=5e-4)
                
                subfolder_results = train_ppo(agent, env, optimizer, num_epochs=5)
                results[entry] = subfolder_results
                
                if env.successful_examples:
                    lora_adapter_path = os.path.join(lora_save_dir, f"lora_adapter_{entry}")
                    global_model.save_pretrained(lora_adapter_path)
                    examples_file = os.path.join(subfolder_path, "successful_examples.json")
                    with open(examples_file, "w") as f:
                        json.dump(env.successful_examples, f, indent=2)
    
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
