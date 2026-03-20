import os
import re
import subprocess
import gym
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.distributions.categorical import Categorical
import os
import subprocess  # Used to check Dafny code
from openai import ChatCompletion  # Assuming OpenAI LLM API
import google.generativeai as genai
import json
import os
import re
import subprocess
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
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel as DDP
from torch.utils.data.distributed import DistributedSampler

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
        # Extract the loss weight (shape: [batch_size]) from inputs.
        # We assume loss_weight is a float tensor for each example.
        loss_weight = inputs.pop('loss_weight', None)
        outputs = model(**inputs)
        loss = outputs.loss
        if loss_weight is not None:
            # Scale the loss by the average weight in the batch.
            # (Alternatively, you might want to do per-token or per-example loss weighting.)
            loss = loss * loss_weight.mean()
        return (loss, outputs) if return_outputs else loss

def setup_distributed(rank, world_size):
    """Initialize distributed training."""
    os.environ['MASTER_ADDR'] = 'localhost'
    os.environ['MASTER_PORT'] = '12355'
    dist.init_process_group("nccl", rank=rank, world_size=world_size)
    torch.cuda.set_device(rank)

def cleanup_distributed():
    """Clean up distributed training."""
    dist.destroy_process_group()

def get_available_gpus():
    """Get list of available GPU devices."""
    gpu_list = []
    try:
        # Check CUDA devices
        if torch.cuda.is_available():
            for i in range(torch.cuda.device_count()):
                gpu_name = torch.cuda.get_device_name(i)
                if 'H100' in gpu_name or 'h100' in gpu_name:
                    gpu_list.append(('H100', i))
                elif 'A30' in gpu_name or 'a30' in gpu_name:
                    gpu_list.append(('A30', i))
    except:
        pass
    return gpu_list

def initialize_slm(rank=-1):
    global global_model, global_tokenizer
    
    # Initialize the model and tokenizer
    model_name = "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
    global_tokenizer = AutoTokenizer.from_pretrained(model_name)
    
    # Set pad token to eos token if not set
    if global_tokenizer.pad_token is None:
        global_tokenizer.pad_token = global_tokenizer.eos_token
        global_tokenizer.pad_token_id = global_tokenizer.eos_token_id
    
    # Load model with specific GPU device if distributed
    device_map = 0 if rank == -1 else rank
    global_model = AutoModelForCausalLM.from_pretrained(
        model_name,
        torch_dtype=torch.bfloat16,
        device_map=device_map
    )
    
    # Configure LoRA for efficient fine-tuning
    lora_config = LoraConfig(
        r=8,
        lora_alpha=32,
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
        lora_dropout=0.05,
        bias="none",
        task_type="CAUSAL_LM"
    )
    
    # Prepare model for training
    global_model = prepare_model_for_kbit_training(global_model)
    global_model = get_peft_model(global_model, lora_config)
    
    # Wrap model in DDP if distributed
    if rank != -1:
        global_model = DDP(global_model, device_ids=[rank])
    
    # Enable gradient computation for all parameters
    for param in global_model.parameters():
        param.requires_grad = True
    
    return global_model, global_tokenizer

def fine_tune_slm_on_tree(error_tree: ErrorTree):
    global global_model, global_tokenizer

    if not error_tree or error_tree.root is None:
        print("No error tree available for training.")
        return

    # Traverse all nodes
    nodes = error_tree.traverse()

    # Function to determine a loss weight based on reward
    # Here, we add an offset so that even negative rewards yield a positive weight.
    def calculate_weight(reward: float):
        offset = 10.0  # Chosen so that a negative reward does not zero out weight (adjust as needed)
        # For instance, if reward = 5 then weight = 15; if reward = -7 then weight = 3.
        return reward + offset

    # Format training examples from each tree node.
    def format_training_example(node: TreeNode):
        # Here we assume that the SLM response (node.prompt) is the text you want the model to reproduce.
        # You could also incorporate the error message if that is useful.
        full_text = node.prompt  # Alternatively: node.prompt + "\nError: " + node.error_message
        tokenized = global_tokenizer(
            full_text,
            truncation=True,
            max_length=10000,
            padding="max_length",
            return_tensors="pt"
        )
        # We take the first (and only) element along the batch dimension.
        input_ids = tokenized["input_ids"][0]
        attention_mask = tokenized["attention_mask"][0]
        # Calculate weight from reward:
        weight = calculate_weight(node.reward)
        return {
            "input_ids": input_ids,
            "attention_mask": attention_mask,
            "labels": input_ids.clone(),
            "loss_weight": torch.tensor([weight], dtype=torch.float32)
        }

    train_data = [format_training_example(node) for node in nodes]
    dataset = Dataset.from_list(train_data)

    # Custom collate function to collate loss_weight as well.
    def collate_fn(examples):
        batch = {
            "input_ids": torch.stack([ex["input_ids"] for ex in examples]).to(0),
            "attention_mask": torch.stack([ex["attention_mask"] for ex in examples]).to(0),
            "labels": torch.stack([ex["labels"] for ex in examples]).to(0),
            "loss_weight": torch.stack([ex["loss_weight"] for ex in examples]).to(0).squeeze()  # shape: [batch_size]
        }
        return batch

    # Training arguments (adjust parameters as needed)
    training_args = TrainingArguments(
        output_dir="./slm_tree_checkpoints",
        num_train_epochs=1,
        per_device_train_batch_size=1,
        gradient_accumulation_steps=4,
        learning_rate=2e-4,
        fp16=True,
        logging_steps=10,
        save_strategy="epoch",
        overwrite_output_dir=True,
        remove_unused_columns=False,
        gradient_checkpointing=True,
        save_total_limit=1,
        optim="adamw_torch",
        ddp_find_unused_parameters=False,
    )

    # Set model to training mode.
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

def fine_tune_slm(successful_examples):
    global global_model, global_tokenizer
    
    if not successful_examples:
        return
    
    # Format data for training
    def format_training_example(example):
        prompt = example["prompt"]
        response = example["response"]
        full_text = f"{prompt}\n{response}"
        
        # Tokenize the text
        tokenized = global_tokenizer(
            full_text,
            truncation=True,
            max_length=10000,
            padding="max_length",
            return_tensors="pt"
        ).to(0)  # Move to GPU
        print("--------------------------------")
        print("--------------------------------")
        print(type(tokenized["input_ids"]))
        print(tokenized["input_ids"].shape)
        print(type(tokenized["attention_mask"]))
        print(tokenized["attention_mask"].shape)
        print("--------------------------------")
        print("--------------------------------")
        return {
            "input_ids": tokenized["input_ids"][0],
            "attention_mask": tokenized["attention_mask"][0],
            "labels": tokenized["input_ids"][0].clone()
        }
    
    # Custom data collator
    def collate_fn(examples):
        if not examples:
            return {}
        
        # Ensure all tensors are properly shaped and on GPU
        batch = {
            "input_ids": torch.stack([ex["input_ids"] for ex in examples]).to(0),
            "attention_mask": torch.stack([ex["attention_mask"] for ex in examples]).to(0),
            "labels": torch.stack([ex["labels"] for ex in examples]).to(0)
        }
        return batch
    
    # Convert successful examples to a dataset
    train_data = [format_training_example(ex) for ex in successful_examples]
    dataset = Dataset.from_list(train_data)
    
    # Training arguments
    training_args = TrainingArguments(
        output_dir="./slm_checkpoints",
        num_train_epochs=1,
        per_device_train_batch_size=1,
        gradient_accumulation_steps=4,
        learning_rate=2e-4,
        fp16=True,
        logging_steps=10,
        save_strategy="epoch",
        save_steps=20,
        overwrite_output_dir=True,
        remove_unused_columns=False,
        gradient_checkpointing=True,
        save_total_limit=1,
        optim="adamw_torch",  # Use PyTorch's AdamW optimizer
        ddp_find_unused_parameters=False,  # Disable unused parameter detection
    )
    
    # Initialize trainer with custom collator
    trainer = Trainer(
        model=global_model,
        args=training_args,
        train_dataset=dataset,
        data_collator=collate_fn,
    )
    
    # Set model to training mode
    global_model.train()
    
    # Fine-tune the model
    try:
        trainer.train()
    except Exception as e:
        print(f"Fine-tuning error: {str(e)}")
        # Continue with training even if fine-tuning fails
        pass

def run_SLM(prompt: str,
            error_context: Optional[Dict] = None,
            successful_examples: Optional[List] = None,
            error_tree: Optional[ErrorTree] = None):
    global global_model, global_tokenizer

    # Initialize the SLM if necessary.
    if global_model is None or global_tokenizer is None:
        global_model, global_tokenizer = initialize_slm()

    # Instead of tuning only on successful examples,
    # we check if a full error_tree is provided and use it.
    if error_tree is not None:
        fine_tune_slm_on_tree(error_tree)
    elif successful_examples:
        fine_tune_slm(successful_examples)

    # Build the prompt: if error context is present, include that detail.
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

    # Tokenize and generate the SLM response.
    inputs = global_tokenizer(full_prompt, return_tensors="pt").to(0)
    outputs = global_model.generate(
        **inputs,
        max_new_tokens=8000,
        do_sample=True,
        temperature=0.7,
        top_k=50,
        top_p=0.95
    )
    response = global_tokenizer.decode(outputs[0], skip_special_tokens=True)
    if "</think>" in response:
        response = response.split("</think>", 1)[1].strip()
    
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
              " Here is the task: \n")
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
    Prompt += "You must return the full code in the following Form:" + "\n" + "dafny" + "\n" + "Dafny Code" + "\n" + "```"
    Prompt += error
    return Prompt

def run_LLM(response):
    prompt = str(response) + "You must return the full code in the following Form:" + "\n" + "dafny" + "\n" + "Dafny Code" + "\n" + ""
    pipe = pipeline(
        task="text-generation",
        model="deepseek-ai/DeepSeek-R1-Distill-Qwen-32B",
        torch_dtype=torch.bfloat16,
        device_map=0
    )
    messages = [
        {"role": "system", "content": "You are an expert in writing Dafny code"},
        {"role": "user", "content": prompt},
    ]
    print(prompt)
    outputs = pipe(messages, max_new_tokens=8000, do_sample=True, temperature=0.7, top_k=50, top_p=0.95)
    response = outputs[0]["generated_text"][-1]['content']
    return response

def extract_dafny_code(text):
    pattern_snippet = r"dafny(.*?)"
    snippets = re.findall(pattern_snippet, text, re.DOTALL)
    trimmed_snippet = ""
    if snippets:
        # Takes the last code-block in case there are multiple
        trimmed_snippet = snippets[-1].strip()
    return trimmed_snippet

def run_dafny(tmp_path, code, error_path):
    # Write the Dafny code to a temporary file
    with open(tmp_path, "w", encoding='utf-8') as file:
        file.write(code)
    
    # Change directory to where the Dafny executable is located
    dafny_directory = r"/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
    os.chdir(dafny_directory)
    
    # Execute Dafny command and redirect output to a temporary file
    dafny_command = f"/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny '{tmp_path}' > '{error_path}'"
    os.system(dafny_command)
    
    # Read the output file and determine success
    with open(error_path, "r", encoding='utf-8') as output_file:
        output = output_file.read()
        if "verified, 0 errors" in output:
            if "Compiled assembly into" in output:
                success = 1
            else:
                success = 0
        else:
            success = 0
    return success

# ----- Custom Gym Environment -----

def save_iteration_results(subfolder_path, iteration, epoch, reward, error_output, code, error_count):
    """Save detailed results for each iteration"""
    # Change the base directory to the root dataset directory
    results_dir = os.path.join("/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset", f"epoch_{epoch}_{os.path.basename(subfolder_path)}")
    os.makedirs(results_dir, exist_ok=True)
    
    # Save iteration details
    with open(os.path.join(results_dir, f"iteration_{iteration}_results.json"), "w") as f:
        json.dump({
            "reward": reward,
            "error_count": error_count,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
        }, f, indent=2)
    
    # Save generated code
    with open(os.path.join(results_dir, f"iteration_{iteration}_code.dfy"), "w") as f:
        f.write(code)
    
    # Save error output
    with open(os.path.join(results_dir, f"iteration_{iteration}_error.txt"), "w") as f:
        f.write(error_output)

def save_epoch_summary(subfolder_path, epoch, total_reward, successful_examples_count, error_tree):
    """Save summary for each epoch"""
    # Change the base directory to the root dataset directory
    results_dir = os.path.join("/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset", f"epoch_{epoch}_{os.path.basename(subfolder_path)}")
    os.makedirs(results_dir, exist_ok=True)
    
    with open(os.path.join(results_dir, f"epoch_summary.json"), "w") as f:
        json.dump({
            "epoch": epoch,
            "total_reward": total_reward,
            "successful_examples_count": successful_examples_count,
            "error_tree_depth": error_tree.current_node.depth if error_tree.current_node else 0,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
        }, f, indent=2)

class MetricsTracker:
    def __init__(self, save_dir):
        self.save_dir = save_dir
        os.makedirs(save_dir, exist_ok=True)
        
        # RL metrics
        self.episode_rewards = []
        self.cumulative_rewards = []
        self.success_rates = []
        self.error_counts = []
        self.iteration_counts = []
        self.average_rewards_per_epoch = []
        
        # Fine-tuning metrics
        self.training_loss = []
        self.validation_loss = []
        self.model_perplexity = []
        
        # Error analysis
        self.error_types = defaultdict(list)
        self.verification_success_rate = []
        self.proof_obligation_counts = []
        
        # Time tracking
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
        
        # Plot episode rewards
        plt.figure(figsize=(12, 6))
        plt.plot(self.episode_rewards, label='Episode Rewards', color='blue')
        plt.xlabel('Episode')
        plt.ylabel('Reward')
        plt.title('Episode-wise Rewards')
        plt.legend()
        plt.grid(True)
        plt.savefig(os.path.join(self.save_dir, f'episode_rewards_{timestamp}.png'))
        plt.close()

        # Plot cumulative rewards separately
        plt.figure(figsize=(12, 6))
        plt.plot(self.cumulative_rewards, label='Cumulative Rewards', color='green')
        plt.xlabel('Episode')
        plt.ylabel('Cumulative Reward')
        plt.title('Cumulative Rewards Over Time')
        plt.legend()
        plt.grid(True)
        plt.savefig(os.path.join(self.save_dir, f'cumulative_rewards_{timestamp}.png'))
        plt.close()
        
        # Plot success rate
        plt.figure(figsize=(12, 6))
        plt.plot(self.success_rates, label='Success Rate')
        plt.xlabel('Episode')
        plt.ylabel('Success Rate')
        plt.title('Verification Success Rate')
        plt.legend()
        plt.grid(True)
        plt.savefig(os.path.join(self.save_dir, f'success_rate_{timestamp}.png'))
        plt.close()
        
        # Plot error analysis
        plt.figure(figsize=(12, 6))
        for error_type, counts in self.error_types.items():
            plt.plot(counts, label=error_type)
        plt.xlabel('Episode')
        plt.ylabel('Error Count')
        plt.title('Error Type Analysis')
        plt.legend()
        plt.grid(True)
        plt.savefig(os.path.join(self.save_dir, f'error_analysis_{timestamp}.png'))
        plt.close()
        
        if self.training_loss:
            # Filter out NaN values for loss plotting
            valid_indices = []
            valid_losses = []
            for i, loss in enumerate(self.training_loss):
                if not (np.isnan(loss) or np.isinf(loss)):
                    valid_indices.append(i)
                    valid_losses.append(loss)
            
            if valid_losses:  # Only plot if there are valid losses
                plt.figure(figsize=(12, 6))
                plt.plot(valid_indices, valid_losses, label='Training Loss', color='red')
                
                # Plot validation loss if available (also filtering NaN)
                if self.validation_loss:
                    valid_val_indices = []
                    valid_val_losses = []
                    for i, loss in enumerate(self.validation_loss):
                        if not (np.isnan(loss) or np.isinf(loss)):
                            valid_val_indices.append(i)
                            valid_val_losses.append(loss)
                    if valid_val_losses:
                        plt.plot(valid_val_indices, valid_val_losses, label='Validation Loss', color='blue')
                
                plt.xlabel('Epoch')
                plt.ylabel('Loss')
                plt.title('Model Training Progress (NaN values excluded)')
                plt.legend()
                plt.grid(True)
                plt.savefig(os.path.join(self.save_dir, f'training_loss_{timestamp}.png'))
                plt.close()
            else:
                print("Warning: No valid loss values to plot")
    
    def save_metrics(self):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        metrics_data = {
            'episode_rewards': self.episode_rewards,
            'cumulative_rewards': self.cumulative_rewards,
            'success_rates': self.success_rates,
            'error_counts': self.error_counts,
            'iteration_counts': self.iteration_counts,
            'average_rewards_per_epoch': self.average_rewards_per_epoch,
            'training_loss': [float(loss) if not (np.isnan(loss) or np.isinf(loss)) else "NaN" for loss in self.training_loss],
            'validation_loss': [float(loss) if not (np.isnan(loss) or np.isinf(loss)) else "NaN" for loss in self.validation_loss],
            'verification_success_rate': self.verification_success_rate,
            'proof_obligation_counts': self.proof_obligation_counts,
            'error_types': {k: list(v) for k, v in self.error_types.items()},
            'epoch_times': self.epoch_times,
            'total_training_time': time.time() - self.start_time
        }
        
        with open(os.path.join(self.save_dir, f'metrics_{timestamp}.json'), 'w') as f:
            json.dump(metrics_data, f, indent=2)

# Initialize metrics tracker at the start of training
metrics_tracker = None

class DafnyEnv(gym.Env):
    """
    Custom Gym environment that:
      1. Reads a prompt (Dafny task description).
      2. Runs the SLM and LLM pipelines to generate Dafny code.
      3. Evaluates the generated code with run_dafny.
      4. Maintains successful examples for fine-tuning the SLM.
    """
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
        self.current_loss = 0.0  # Add loss tracking
        
        # Initialize metrics tracker if not already initialized
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
        # Check if code is empty or contains only whitespace
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
            
            # Base verification reward
            if "verified, 0 errors" in output:
                if "Compiled assembly into" in output:
                    reward = 5.0
                    metrics_tracker.update_rl_metrics(reward, True, 0, self.current_iteration)
                    metrics_tracker.update_error_analysis("success", True, 0)
                    save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, output, code, 0)
                    return reward, output, code
            
            # Count errors and analyze error types
            error_count = 0
            error_types = defaultdict(int)
            for line in output.split('\n'):
                if "Error:" in line or "error:" in line:
                    error_count += 1
                    # Categorize error type
                    if "assertion violation" in line.lower():
                        error_types["assertion"] += 1
                    elif "precondition violation" in line.lower():
                        error_types["precondition"] += 1
                    elif "postcondition violation" in line.lower():
                        error_types["postcondition"] += 1
                    else:
                        error_types["other"] += 1
            
            # Calculate shaped penalty
            a = 0.2
            b = 0.5 * self.current_iteration
            shaped_penalty = -a * error_count - b
            
            # Base verification failure penalty
            total_reward = -5.0 + shaped_penalty
            
            # Update metrics
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
        
        for attempt in range(7):
            # Get error context for SLM
            error_context = None
            if self.current_iteration > 0:
                current_node = self.error_tree.current_node
                error_context = {
                    'error_code': current_node.error_code,
                    'error_message': current_node.error_message,
                    'reward': current_node.reward,
                    'attempts': self.current_iteration
                }
            
            # Generate new prompt using SLM
            slm_response = run_SLM(
                prompt=current_prompt or self.prompt,
                error_context=error_context,
                successful_examples=self.successful_examples
            )
            
            # Generate Dafny code using LLM
            llm_response = run_LLM(slm_response)
            dafny_code = extract_dafny_code(llm_response)
            
            # Run Dafny and get results
            reward, error_output, code = self.get_dafny_output(dafny_code)
            total_reward += reward
            self.epoch_rewards.append(reward)
            
            # Create new node in error tree
            new_node = self.error_tree.add_node(
                error_code=code,
                error_message=error_output,
                reward=reward,
                prompt=slm_response,
                parent=self.error_tree.current_node
            )
            
            self.error_tree.current_node = new_node
            
            # If successful, store example and break
            if reward > 0:
                self.successful_examples.append({
                    "prompt": slm_response,
                    "response": llm_response,
                    "error_context": error_context
                })
                
                # Keep only last N successful examples
                max_examples = 100
                if len(self.successful_examples) > max_examples:
                    self.successful_examples = self.successful_examples[-max_examples:]
                
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
        
        # Save epoch summary at the end of each epoch
        save_epoch_summary(
            self.subfolder_path,
            self.current_epoch,
            total_reward,
            len(self.successful_examples),
            self.error_tree
        )
        
        # Update metrics at the end of each step
        avg_epoch_reward = np.mean(self.epoch_rewards) if self.epoch_rewards else 0
        metrics_tracker.update_epoch_metrics(
            avg_reward=avg_epoch_reward,
            training_loss=self.current_loss
        )
        
        # Generate plots every 10 epochs
        if (self.current_epoch + 1) % 4 == 0:
            metrics_tracker.plot_learning_curves()
            metrics_tracker.save_metrics()
        
        return self.prompt, total_reward, done, info

# ----- PPO Agent Definition -----

class PPOAgent(nn.Module):
    """
    A simple PPO agent with a policy network and a value function.
    In a full implementation, the agent would modify token-level choices.
    Here we use a dummy model mapping an encoded prompt to a discrete action.
    """
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

# ----- PPO Training Loop -----

def train_ppo(agent, env, optimizer, num_epochs=20, gamma=0.99, clip_epsilon=0.2):
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
        obs_tensor = torch.tensor(obs_encoded, dtype=torch.float32).unsqueeze(0)
        
        # Forward pass to get action logits and state value
        policy_logits, value = agent(obs_tensor)
        m = Categorical(logits=policy_logits)
        action = m.sample()
        log_prob = m.log_prob(action)
        
        # Take a step in the environment
        next_obs, reward, done, info = env.step(action)
        total_rewards += reward
        epoch_rewards.append(reward)
        
        # Store the error tree for analysis
        error_trees.append(info["error_tree"])
        
        # Track successful examples count
        successful_examples_history.append(info["successful_examples_count"])
        
        # Calculate advantages and update the policy
        returns = reward * gamma
        value = value.squeeze(-1)  # Remove the last dimension to match returns shape
        advantage = returns - value.detach()
        
        # Policy loss
        ratio = torch.exp(m.log_prob(action) - log_prob.detach())
        surr1 = ratio * advantage
        surr2 = torch.clamp(ratio, 1 - clip_epsilon, 1 + clip_epsilon) * advantage
        policy_loss = -torch.min(surr1, surr2).mean()
        
        # Value loss - ensure tensor dimensions match
        value_loss = F.mse_loss(value, torch.tensor([returns], dtype=torch.float32))
        
        # Total loss
        loss = policy_loss + 0.5 * value_loss
        env.set_current_loss(loss)  # Set the current loss
        
        # Optimize
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        
        # Update metrics at the end of each step
        avg_epoch_reward = np.mean(epoch_rewards)
        avg_epoch_loss = np.mean(epoch_losses)
        metrics_tracker.update_epoch_metrics(
            avg_reward=avg_epoch_reward,
            training_loss=avg_epoch_loss
        )
        
        # Generate plots every 10 epochs
        if (epoch + 1) % 4 == 0:
            metrics_tracker.plot_learning_curves()
            metrics_tracker.save_metrics()
        
        # Log progress
        if (epoch + 1) % 4 == 0:
            print(f"\nEpoch {epoch + 1}/{num_epochs}")
            print(f"Total Rewards: {total_rewards}")
            print(f"Successful Examples: {info['successful_examples_count']}")
            print(f"Average Loss: {avg_epoch_loss:.4f}")
            print(f"Iterations in last episode: {info['iterations']}")
            
            if info["error_tree"].successful_path:
                print("\nSuccessful error resolution path:")
                for node in info["error_tree"].successful_path:
                    print(f"Depth {node.depth}:")
                    print(f"  Reward: {node.reward}")
                    print(f"  Error Message: {node.error_message[:100]}...")
            print("----------------------------------------")
    
    # Final metrics saving and plotting
    metrics_tracker.plot_learning_curves()
    metrics_tracker.save_metrics()
    
    return {
        "total_rewards": total_rewards,
        "successful_examples_history": successful_examples_history,
        "error_trees": error_trees
    }

# ----- Processing Multiple Subfolders -----

def process_subfolders(root_directory, temperature, rank=-1, world_size=1):
    """
    Distribute processing across multiple GPUs.
    Each GPU processes a subset of the folders.
    """
    results = {}
    
    # Get list of all subfolders
    all_subfolders = []
    for entry in os.listdir(root_directory):
        subfolder_path = os.path.join(root_directory, entry)
        if os.path.isdir(subfolder_path):
            description_file = os.path.join(subfolder_path, "detailed_description.txt")
            if os.path.exists(description_file):
                all_subfolders.append(subfolder_path)
    
    # If distributed, process only subset of folders assigned to this GPU
    if rank != -1:
        # Distribute folders across GPUs
        folders_per_gpu = len(all_subfolders) // world_size
        start_idx = rank * folders_per_gpu
        end_idx = start_idx + folders_per_gpu if rank < world_size - 1 else len(all_subfolders)
        assigned_subfolders = all_subfolders[start_idx:end_idx]
    else:
        assigned_subfolders = all_subfolders
    
    for subfolder_path in assigned_subfolders:
        with open(os.path.join(subfolder_path, "detailed_description.txt"), "r", encoding='utf-8') as file:
            sample_prompt = file.read().strip()
        
        # Construct file paths in the subfolder
        tmp_path = os.path.join(subfolder_path, "RL_No_feedback.dfy")
        error_path = os.path.join(subfolder_path, "RL_no_feedbacl_error.txt")
        
        print(f"\nProcessing subfolder on GPU {rank}: {subfolder_path}")
        print("Sample prompt:\n", sample_prompt)
        
        # Initialize environment with the sample prompt and file paths
        env = DafnyEnv(sample_prompt, tmp_path, error_path)
        
        # Define PPO agent parameters
        input_size = 10000
        hidden_size = 64
        output_size = 5
        
        # Create agent and move to specific GPU if distributed
        agent = PPOAgent(input_size, hidden_size, output_size)
        if rank != -1:
            agent = agent.to(rank)
            agent = DDP(agent, device_ids=[rank])
        
        optimizer = optim.Adam(agent.parameters(), lr=1e-3)
        
        # Train the PPO agent for the current subfolder
        subfolder_results = train_ppo(agent, env, optimizer, num_epochs=100)
        results[os.path.basename(subfolder_path)] = subfolder_results
        
        # Save successful examples if any
        if env.successful_examples:
            examples_file = os.path.join(subfolder_path, "successful_examples.json")
            with open(examples_file, "w") as f:
                json.dump(env.successful_examples, f, indent=2)
    
    return results

# ----- Main Script -----

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run Dafny code generation with specified temperature')
    parser.add_argument('--temperature', type=float, default=0.25,
                      help='Temperature for LLM generation (default: 0.25)')
    parser.add_argument('--distributed', action='store_true',
                      help='Enable distributed training across multiple GPUs')
    args = parser.parse_args()

    if args.distributed:
        # Get available GPUs
        available_gpus = get_available_gpus()
        world_size = len(available_gpus)
        
        if world_size > 0:
            print(f"Found {world_size} GPUs: {available_gpus}")
            
            # Initialize distributed process group
            setup_distributed(available_gpus[0][1], world_size)
            
            # Process subfolders with distributed training
            results = process_subfolders(
                "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny",
                args.temperature,
                rank=available_gpus[0][1],
                world_size=world_size
            )
            
            # Clean up
            cleanup_distributed()
        else:
            print("No GPUs found, running in single-GPU mode")
            results = process_subfolders(
                "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny",
                args.temperature
            )
    else:
        # Run in single-GPU mode
        results = process_subfolders(
            "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny",
            args.temperature
        )
    
    # Save overall results
    with open("training_results.json", "w") as f:
        json.dump({
            k: {
                "total_rewards": v["total_rewards"],
                "successful_examples_count": len(v["successful_examples_history"]),
                "iterations_per_epoch": [tree.current_node.depth if tree.current_node else 0 for tree in v["error_trees"]]
            }
            for k, v in results.items()
        }, f, indent=2)