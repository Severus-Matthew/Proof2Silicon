# import os
# import re

# # Define the main folder path
# main_folder_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny'  # Replace with your actual path
# n=0
# # Define the required patterns
# required_patterns = ['qwen2_']'chatgpt4'gemini25Proexpgemini2flash,'qwen2_'qwen27bchatgpto1

# # Initialize a list to store the names of selected subfolders
# selected_subfolders = []


# # Iterate through each subfolder in the main folder
# for subfolder_name in os.listdir(main_folder_path):
#     subfolder_path = os.path.join(main_folder_path, subfolder_name)
#     # print(subfolder_path)
    
#     if os.path.isdir(subfolder_path):
#         # Track which patterns are matched in the current subfolder
#         matched_patterns = {pattern: False for pattern in required_patterns}
        
#         # Check each file in the subfolder
#         for file_name in os.listdir(subfolder_path):
#             # print(file_name)
#             for pattern in required_patterns:
#                 if pattern in file_name:  # Checks if the pattern is part of the file name
#                     matched_patterns[pattern] = True
        
#         # Check if all patterns have been matched
#         if all(matched_patterns.values()):
#             selected_subfolders.append(subfolder_name)
#             n+=1

# # Display the result
# if selected_subfolders:
#     print("Selected Subfolders:")
#     for folder in selected_subfolders:
#         print(f"- {folder}")
# else:
#     print("No subfolders matched all the required patterns.")









# print(n)

import os
import shutil

def copy_files_with_keyword(main_folder_path, destination_folder, keyword):
    # Ensure the destination folder exists
    os.makedirs(destination_folder, exist_ok=True)
    
    # Iterate through each subfolder in the main folder
    for subfolder_name in os.listdir(main_folder_path):
        subfolder_path = os.path.join(main_folder_path, subfolder_name)
        
        if os.path.isdir(subfolder_path):  # Ensure it's a folder
            # Create a corresponding subfolder in the destination folder
            destination_subfolder = os.path.join(destination_folder, subfolder_name)
            os.makedirs(destination_subfolder, exist_ok=True)

            # Iterate over files in the subfolder
            for file_name in os.listdir(subfolder_path):
                if keyword in file_name:  # Check if the file name contains the keyword
                    source_file_path = os.path.join(subfolder_path, file_name)
                    destination_file_path = os.path.join(destination_subfolder, file_name)

                    # Copy the file to the destination
                    shutil.copy2(source_file_path, destination_file_path)

    print(f"Files containing '{keyword}' have been copied to '{destination_folder}'.")

# Usage example
main_folder_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny'  # Replace with the path to your main folder
destination_folder = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/DQWEN'  # Replace with the path where you want to copy files
keyword = 'Dqwen32b'  # Replace with the keyword to search for in file names

copy_files_with_keyword(main_folder_path, destination_folder, keyword)




import os

def remove_empty_folders(path):
    # Iterate over all subfolders and files in the given path
    for root, dirs, files in os.walk(path, topdown=False):
        for dir_name in dirs:
            dir_path = os.path.join(root, dir_name)
            
            # Check if the directory is empty
            if not os.listdir(dir_path):
                os.rmdir(dir_path)
                print(f"Removed empty folder: {dir_path}")

# Usage example
main_folder_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/DQWEN'  # Replace with your folder path
remove_empty_folders(main_folder_path)














import os
import shutil

def copy_description_files(source_folder, destination_folder):
    # Ensure the destination folder exists
    os.makedirs(destination_folder, exist_ok=True)
    
    # Iterate through each subfolder in the source folder
    for subfolder_name in os.listdir(source_folder):
        source_subfolder_path = os.path.join(source_folder, subfolder_name)
        
        if os.path.isdir(source_subfolder_path):  # Check if it's a folder
            # Create the corresponding subfolder in the destination folder
            destination_subfolder_path = os.path.join(destination_folder, subfolder_name)
            os.makedirs(destination_subfolder_path, exist_ok=True)
            
            # Define the files to be copied
            files_to_copy = ['one_line_description.txt', 'detailed_description.txt']
            
            for file_name in files_to_copy:
                source_file_path = os.path.join(source_subfolder_path, file_name)
                
                if os.path.exists(source_file_path):  # Check if the file exists in the source folder
                    destination_file_path = os.path.join(destination_subfolder_path, file_name)
                    shutil.copy2(source_file_path, destination_file_path)
                    print(f"Copied {file_name} to {destination_subfolder_path}")
                else:
                    print(f"File {file_name} not found in {source_subfolder_path}")

# Usage Example
source_folder = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny'  # Replace with your source folder path
destination_folder = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/DQWEN'  # Replace with your destination folder path

copy_description_files(source_folder, destination_folder)



import os
import shutil

def remove_folders_with_two_files(path):
    # Iterate over all subfolders and files in the given path
    for root, dirs, files in os.walk(path, topdown=False):
        for dir_name in dirs:
            dir_path = os.path.join(root, dir_name)
            
            # Check the number of files in the directory
            if len(os.listdir(dir_path)) == 2:  # Remove if it has exactly 2 files
                shutil.rmtree(dir_path)
                print(f"Removed folder with 2 files: {dir_path}")

# Usage example
main_folder_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/DQWEN'  # Replace with your folder path
remove_folders_with_two_files(main_folder_path)





# import os
# import re
# import subprocess
# import gym
# import numpy as np
# import torch
# import torch.nn as nn
# import torch.optim as optim
# from torch.distributions.categorical import Categorical
# import json
# import random
# from difflib import get_close_matches
# from collections import Counter, defaultdict
# import time
# from transformers import (
#     pipeline,
#     AutoModelForCausalLM,
#     AutoTokenizer,
#     TrainingArguments,
#     Trainer,
#     BitsAndBytesConfig,
#     DataCollatorForLanguageModeling
# )
# from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
# from datasets import Dataset
# import torch.nn.functional as F
# import argparse
# from dataclasses import dataclass
# from typing import List, Dict, Optional, Any
# import matplotlib.pyplot as plt
# from datetime import datetime

# # Ensure margin for peaks
# torch.cuda.set_per_process_memory_fraction(0.8, device=0)

# # Environment vars
# os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "expandable_segments:True"

# device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
# print("Using device:", device)

# # Globals
# global_model = None
# global_tokenizer = None

# ###############################################################################
# # Helper functions for weighted dataset creation and saving
# ###############################################################################

# def calculate_example_weight(reward: float, scale: float = 1.0) -> float:
#     if reward < 0:
#         return 1.0 + scale * abs(reward)
#     else:
#         return 1.0

# def append_to_weighted_dataset(file_path: str, example: Dict):
#     with open(file_path, "a") as f:
#         json.dump(example, f)
#         f.write("\n")

# ###############################################################################
# # Data Structures
# ###############################################################################

# @dataclass
# class TreeNode:
#     error_code: str
#     error_message: str
#     reward: float
#     prompt: str
#     parent: Optional['TreeNode']
#     children: List['TreeNode']
#     depth: int
#     success: bool = False

# class ErrorTree:
#     def __init__(self, max_depth: int = 7):
#         self.root = None
#         self.max_depth = max_depth
#         self.current_node = None
#         self.successful_path = None

#     def add_node(self, error_code: str, error_message: str, reward: float, prompt: str, parent: Optional[TreeNode] = None) -> TreeNode:
#         depth = 0 if parent is None else parent.depth + 1
#         node = TreeNode(
#             error_code=error_code,
#             error_message=error_message,
#             reward=reward,
#             prompt=prompt,
#             parent=parent,
#             children=[],
#             depth=depth
#         )
#         if parent:
#             parent.children.append(node)
#         else:
#             self.root = node
#         return node

#     def get_path_to_node(self, node: TreeNode) -> List[TreeNode]:
#         path = []
#         current = node
#         while current:
#             path.append(current)
#             current = current.parent
#         return list(reversed(path))
    
#     def traverse(self) -> List[TreeNode]:
#         """Return a flat list of all nodes in the tree."""
#         nodes = []
#         def rec(node: TreeNode):
#             nodes.append(node)
#             for child in node.children:
#                 rec(child)
#         if self.root:
#             rec(self.root)
#         return nodes

# ###############################################################################
# # Custom Trainer that uses weighted loss
# ###############################################################################

# class WeightedTrainer(Trainer):
#     def compute_loss(self, model, inputs, return_outputs=False):
#         loss_weights = inputs.pop('loss_weight', None)  # should be a tensor of shape [batch_size]
#         outputs = model(**inputs)
#         loss = outputs.loss
#         if loss_weights is not None:
#             loss = (loss * loss_weights).mean() # scaling loss by the average weight (alternative strategies are possible)
#         return (loss, outputs) if return_outputs else loss

# ###############################################################################
# # SLM (Supervised Language Model) Initialization & Fine-Tuning Functions
# ###############################################################################

# def initialize_slm():
#     global global_model, global_tokenizer

#     if global_model is not None and global_tokenizer is not None:
#         print("Model and tokenizer already initialized, reusing existing instances")
#         return global_model, global_tokenizer

#     print("Initializing model and tokenizer for the first time...")

#     model_name = "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
#     global_tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
#     if global_tokenizer.pad_token is None:
#         global_tokenizer.pad_token = global_tokenizer.eos_token
#         global_tokenizer.pad_token_id = global_tokenizer.eos_token_id

#     print("Loading quantized model (4-bit, NF4)...")
#     quant_config = BitsAndBytesConfig(
#         load_in_4bit=True,
#         bnb_4bit_quant_type="nf4",
#         bnb_4bit_use_double_quant=True,
#         bnb_4bit_compute_dtype=torch.float16
#     )

#     print("Loading model...")
#     global_model = AutoModelForCausalLM.from_pretrained(
#         model_name,
#         quantization_config=quant_config,
#         trust_remote_code=True,
#         device_map="auto",  # This will handle multi-GPU automatically
#         use_cache=False,  # Disable KV cache for training
#         torch_dtype=torch.float16
#     )
    
#     # Prepare model for training
#     global_model = prepare_model_for_kbit_training(global_model)
    
#     # Configure LoRA
#     lora_config = LoraConfig(
#         r=16,
#         lora_alpha=32,
#         target_modules=["q_proj","k_proj","v_proj","o_proj","gate_proj","up_proj","down_proj"],
#         lora_dropout=0.1,
#         bias="none",
#         task_type="CAUSAL_LM",
#         modules_to_save=["embed_tokens", "lm_head"],
#         inference_mode=False
#     )

#     print("Preparing model for LoRA fine-tuning...")
#     global_model = get_peft_model(global_model, lora_config)
    
#     # Enable memory efficient features
#     global_model.gradient_checkpointing_enable()
#     global_model.enable_input_require_grads()
    
#     # No need for DataParallel as device_map="auto" handles multi-GPU
#     print(f"Model device map: {global_model.hf_device_map if hasattr(global_model, 'hf_device_map') else 'Not available'}")
    
#     return global_model, global_tokenizer

# def fine_tune_slm(successful_examples):
#     global global_model, global_tokenizer

#     if not successful_examples:
#         print("\n[Fine-tuning] No successful examples available for fine-tuning. Skipping...")
#         return

#     print(f"\n[Fine-tuning] Starting fine-tuning with {len(successful_examples)} successful examples")
    
#     training_args = TrainingArguments(
#         output_dir="./slm_checkpoints",
#         num_train_epochs=1,
#         per_device_train_batch_size=2,  # Reduced batch size
#         gradient_accumulation_steps=8,  # Increased gradient accumulation
#         learning_rate=2e-4,
#         fp16=True,
#         logging_steps=1,
#         save_strategy="steps",
#         save_steps=4,
#         overwrite_output_dir=True,
#         remove_unused_columns=False,
#         gradient_checkpointing=True,
#         save_total_limit=1,
#         optim="paged_adamw_32bit",
#         lr_scheduler_type="cosine",
#         warmup_ratio=0.1,
#         ddp_find_unused_parameters=False,
#         label_names=["labels"],
#         max_grad_norm=0.3,  # Added gradient clipping
#         logging_first_step=True,
#         dataloader_num_workers=1,
#         group_by_length=True  # Added length batching
#     )
    
#     def format_training_example(example):
#         prompt = example["prompt"]
#         response = example["response"]
#         full_text = f"{prompt}\n{response}"
        
#         tokenized = global_tokenizer(
#             full_text,
#             truncation=True,
#             max_length=1024,
#             padding="max_length",
#             return_tensors=None
#         )
        
#         input_ids = tokenized["input_ids"]
#         attention_mask = tokenized["attention_mask"]
#         labels = input_ids.copy()
        
#         # Calculate weight from the reward field of the example
#         weight = calculate_example_weight(example.get("reward", 0.0), scale=1.0)
        
#         return {
#             "input_ids": input_ids,
#             "attention_mask": attention_mask,
#             "labels": labels,
#             "loss_weight": weight
#         }
    
#     print("[Fine-tuning] Formatting training examples...")
#     train_data = [format_training_example(ex) for ex in successful_examples]
#     dataset = Dataset.from_list(train_data)
#     print(f"[Fine-tuning] Created dataset with {len(dataset)} examples")
    
#     def collate_fn(examples):
#         try:
#             batch = {
#                 key: torch.tensor([ex[key] for ex in examples], dtype=torch.long if key != "loss_weight" else torch.float).to(device)
#                 for key in examples[0].keys()
#             }
#             return batch
#         except Exception as e:
#             print(f"[Fine-tuning] Error in collate_fn: {str(e)}")
#             raise e
    
#     print("[Fine-tuning] Initializing trainer...")
#     trainer = WeightedTrainer(  # Changed to WeightedTrainer
#         model=global_model,
#         args=training_args,
#         train_dataset=dataset,
#         data_collator=collate_fn,
#     )
    
#     try:
#         print("[Fine-tuning] Starting training...")
#         trainer.train()
#         print("[Fine-tuning] Training completed successfully!")
        
#         # Save the fine-tuned model
#         output_dir = f"./slm_checkpoints/final_model_{time.strftime('%Y%m%d_%H%M%S')}"
#         trainer.save_model(output_dir)
#         print(f"[Fine-tuning] Model saved to {output_dir}")
        
#     except Exception as e:
#         print(f"[Fine-tuning] Error during training: {str(e)}")
#         import traceback
#         traceback.print_exc()

# def fine_tune_slm_on_tree(error_tree: ErrorTree):
#     global global_model, global_tokenizer

#     if not error_tree or error_tree.root is None:
#         print("No error tree available for training.")
#         return

#     nodes = error_tree.traverse()
#     if not nodes:
#         print("Error tree is empty. Skipping fine-tuning.")
#         return
    
#     print(f"\n[Tree Fine-tuning] Starting fine-tuning with {len(nodes)} nodes")
    
#     training_args = TrainingArguments(
#         output_dir="./slm_tree_checkpoints",
#         num_train_epochs=1,
#         per_device_train_batch_size=2,
#         gradient_accumulation_steps=8,
#         learning_rate=2e-4,
#         fp16=True,
#         logging_steps=1,
#         save_strategy="steps",
#         save_steps=4,
#         overwrite_output_dir=True,
#         remove_unused_columns=False,
#         gradient_checkpointing=True,
#         save_total_limit=1,
#         optim="paged_adamw_32bit",
#         lr_scheduler_type="cosine",
#         warmup_ratio=0.1,
#         ddp_find_unused_parameters=False,
#         label_names=["labels"],
#         max_grad_norm=0.3,
#         logging_first_step=True,
#         dataloader_num_workers=1,
#         group_by_length=True
#     )
    
#     def format_training_example(node: TreeNode):
#         try:
#             prompt = node.prompt
#             response = node.error_message
#             full_text = f"{prompt}\nError:\n{response}"
            
#             tokenized = global_tokenizer(
#                 full_text,
#                 truncation=True,
#                 max_length=1024,
#                 padding="max_length",
#                 return_tensors=None
#             )
            
#             weight = calculate_example_weight(node.reward, scale=1.0)
            
#             return {
#                 "input_ids": tokenized["input_ids"],
#                 "attention_mask": tokenized["attention_mask"],
#                 "labels": tokenized["input_ids"].copy(),
#                 "loss_weight": weight
#             }
#         except Exception as e:
#             print(f"[Tree Fine-tuning] Error formatting example: {str(e)}")
#             return None
    
#     print("[Tree Fine-tuning] Formatting training examples...")
#     train_data = []
#     for node in nodes:
#         example = format_training_example(node)
#         if example is not None:
#             train_data.append(example)
    
#     if not train_data:
#         print("[Tree Fine-tuning] No valid training examples found. Skipping fine-tuning.")
#         return
    
#     dataset = Dataset.from_list(train_data)
#     print(f"[Tree Fine-tuning] Created dataset with {len(dataset)} examples")
    
#     def collate_fn(examples):
#         try:
#             batch = {
#                 key: torch.tensor([ex[key] for ex in examples], dtype=torch.long if key != "loss_weight" else torch.float).to(device)
#                 for key in examples[0].keys()
#             }
#             return batch
#         except Exception as e:
#             print(f"[Tree Fine-tuning] Error in collate_fn: {str(e)}")
#             raise e
    
#     print("[Tree Fine-tuning] Initializing trainer...")
#     trainer = WeightedTrainer(
#         model=global_model,
#         args=training_args,
#         train_dataset=dataset,
#         data_collator=collate_fn,
#     )
    
#     try:
#         print("[Tree Fine-tuning] Starting training...")
#         trainer.train()
#         print("[Tree Fine-tuning] Training completed successfully!")
        
#         # Save the fine-tuned model
#         output_dir = f"./slm_tree_checkpoints/final_model_{time.strftime('%Y%m%d_%H%M%S')}"
#         trainer.save_model(output_dir)
#         print(f"[Tree Fine-tuning] Model saved to {output_dir}")
        
#     except Exception as e:
#         print(f"[Tree Fine-tuning] Error during training: {str(e)}")
#         import traceback
#         traceback.print_exc()

# ###############################################################################
# # Inference Functions (SLM and vLLM-based)
# ###############################################################################

# def run_SLM(prompts, batch_size=4, successful_examples: Optional[List] = None,
#             error_tree: Optional[ErrorTree] = None):
#     global global_model, global_tokenizer
    
#     if global_model is None or global_tokenizer is None:
#         global_model, global_tokenizer = initialize_slm()
    
#     if error_tree is not None:
#         fine_tune_slm_on_tree(error_tree)
#     elif successful_examples:
#         fine_tune_slm(successful_examples)
    
#     if isinstance(prompts, str):
#         prompts = [prompts]
    
#     prompts = [p.split("</think>", 1)[1].strip() if "</think>" in p else p for p in prompts]
#     dataset = Dataset.from_dict({"prompt": prompts})
    
#     def tokenize_function(examples):
#         return global_tokenizer(
#             examples["prompt"],
#             truncation=True,
#             max_length=1024,
#             padding="max_length",
#             return_tensors="pt"
#         )
    
#     tokenized_dataset = dataset.map(
#         tokenize_function,
#         batched=True,
#         batch_size=batch_size,
#         remove_columns=dataset.column_names
#     )
    
#     responses = []
#     for i in range(0, len(tokenized_dataset), batch_size):
#         batch = tokenized_dataset[i:i + batch_size]
#         inputs = {k: torch.tensor(v).to(global_model.device) for k, v in batch.items()}
        
#         try:
#             with torch.no_grad():
#                 outputs = global_model.generate(
#                     **inputs,
#                     max_new_tokens=1024,
#                     do_sample=True,
#                     temperature=0.7,
#                     top_k=50,
#                     top_p=0.95,
#                     pad_token_id=global_tokenizer.pad_token_id,
#                     eos_token_id=global_tokenizer.eos_token_id
#                 )
            
#             batch_responses = global_tokenizer.batch_decode(outputs, skip_special_tokens=True)
#             responses.extend(batch_responses)
#         except Exception as e:
#             print(f"Error during generation: {str(e)}")
#             import traceback
#             traceback.print_exc()
#             # Return empty responses in case of error
#             responses.extend([""] * len(batch))
    
#     return responses[0] if len(prompts) == 1 else responses

# from vllm import LLM
# from vllm.sampling_params import SamplingParams
# from transformers import AutoTokenizer

# class InferlessPythonModel:
#     def initialize(self):
#         model_id = "Qwen/Qwen2.5-Coder-14B-Instruct-GPTQ-Int8"
#         self.llm = LLM(model=model_id, gpu_memory_utilization=0.98, max_model_len=1024, dtype="float16")
#         self.tokenizer = AutoTokenizer.from_pretrained(model_id)

#     def infer(self, inputs):
#         prompts = inputs["prompt"]
#         temperature = inputs.get("temperature", 0.7)
#         top_p = inputs.get("top_p", 0.1)
#         repetition_penalty = inputs.get("repetition_penalty", 1.18)
#         top_k = int(inputs.get("top_k", 40))
#         max_tokens = inputs.get("max_tokens", 256)

#         sampling_params = SamplingParams(
#             temperature=temperature,
#             top_p=top_p,
#             repetition_penalty=repetition_penalty,
#             top_k=top_k,
#             max_tokens=max_tokens,
#         )
#         input_text = self.tokenizer.apply_chat_template(
#             [{"role": "user", "content": prompts}], tokenize=False
#         )
        
#         # Truncate input text to ensure we don't exceed the model's context length
#         tokenized = self.tokenizer(input_text, truncation=True, max_length=1024, return_tensors="pt")
#         input_text = self.tokenizer.decode(tokenized.input_ids[0], skip_special_tokens=True)
        
#         result = self.llm.generate(input_text, sampling_params)
#         result_output = [output.outputs[0].text for output in result]
#         return {"generated_text": result_output[0]}

#     def finalize(self):
#         self.llm = None

# def run_LLM(responses, batch_size=4):
#     if not hasattr(run_LLM, "infer_model"):
#         run_LLM.infer_model = InferlessPythonModel()
#         run_LLM.infer_model.initialize()

#     if isinstance(responses, str):
#         responses = [responses]

#     prompts = [
#         resp + " You must return the full code in the following form:\n```dafny\nDafny Code\n```"
#         for resp in responses
#     ]

#     generated_texts = []
#     for prompt in prompts:
#         inputs = {
#             "prompt": prompt,
#             "temperature": 0.7,
#             "top_p": 0.1,
#             "repetition_penalty": 1.18,
#             "top_k": 40,
#             "max_tokens": 1024,
#         }
#         res_dict = run_LLM.infer_model.infer(inputs)
#         generated_texts.append(res_dict["generated_text"])
#         # print(generated_texts)

#     return generated_texts[0] if len(responses) == 1 else generated_texts

# def ShortPrompt(Task):
#     Prompt = ("You are an expert in understanding Dafny code and explaining it in detailed, structured steps "
#               "to another agent. Your explanations should be clear, thorough, and logically organized so that the agent "
#               "can effectively use them to write correct and error-free Dafny code. Given the following task, break down "
#               "the required Dafny program into:\n"
#               " Step-by-step reasoning about the logic and specification.\n"
#               " Relevant Dafny constructs and their usage (e.g., preconditions, postconditions, invariants).\n"
#               " Potential edge cases and how to handle them.\n"
#               " Final suggestions or reminders to avoid common pitfalls.\n"
#               " Here is the task:\n")
#     Prompt += Task + "\n"
#     return Prompt

# def ErrorPrompt(error, Task, code, rewa):
#     Prompt = ("You are an expert in understanding Dafny code and explaining it in detailed, structured steps "
#               "to another agent. Your explanations should be clear, thorough, and logically organized so that the agent "
#               "can effectively use them to write correct and error-free Dafny code. Given the following task, an previously LLM generated code based on your instructions and the associated error message, break down "
#               "the required Dafny program into:\n"
#               " Step-by-step reasoning about the logic and specification and ways to solve this error.\n"
#               " Relevant Dafny constructs and their usage (e.g., preconditions, postconditions, invariants).\n"
#               " Potential edge cases and how to handle them.\n"
#               " Final suggestions or reminders to avoid common pitfalls.\n"
#               " Here is the task:\n")
#     Prompt += Task + "\n Below is the errored code: \n"
#     Prompt += code + "\n Below is the error message: \n"
#     Prompt += error + "\n Below is the reward for the previous attempt. TRY TO MAXIMIZE IT THIS TIME, it is based on the correctness of the code that the LLM generated based on your instructions: \n"
#     Prompt += rewa
#     return Prompt

# def extract_dafny_code(text):
#     pattern_snippet = r"```dafny(.*?)```"
#     snippets = re.findall(pattern_snippet, text, re.DOTALL)
#     trimmed_snippet = ""
#     if snippets:
#         trimmed_snippet = snippets[-1].strip()
#     return trimmed_snippet

# def run_dafny(tmp_path, code, error_path):
#     if code.startswith("Dafny Code"):
#         code = code.split("Dafny Code", 1)[1].strip()
#     with open(tmp_path, "w", encoding='utf-8') as file:
#         file.write(code)
    
#     dafny_directory = r"/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
#     os.chdir(dafny_directory)
    
#     dafny_command = f"/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny '{tmp_path}' > '{error_path}'"
#     os.system(dafny_command)
    
#     with open(error_path, "r", encoding='utf-8') as output_file:
#         output = output_file.read()
#         if output.startswith("Dafny code"):
#             output = output.split("Dafny code", 1)[1].strip()
        
#         if "verified, 0 errors" in output:
#             if "Compiled assembly into" in output:
#                 success = 1
#             else:
#                 success = 0
#         else:
#             success = 0
#     return success

# def save_iteration_results(subfolder_path, iteration, epoch, reward, error_output, code, error_count):
#     try:
#         folder_name = os.path.basename(subfolder_path)
#         root_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset"
        
#         # Create root directory if it doesn't exist
#         os.makedirs(root_dir, exist_ok=True)
        
#         # Create epoch directory with descriptive name
        
#         epoch_dir = os.path.join(root_dir, f"epoch_{epoch}_{folder_name}")
#         print(epoch_dir)
#         os.makedirs(epoch_dir, exist_ok=True)
#         print(f"Saving results to directory: {epoch_dir}")
        
#         # Save results JSON
#         results_file = os.path.join(epoch_dir, f"iteration_{iteration}_results.json")
#         with open(results_file, "w", encoding='utf-8') as f:
#             json.dump({
#                 "reward": reward,
#                 "error_count": error_count,
#                 "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
#                 "folder": folder_name,
#                 "iteration": iteration,
#                 "epoch": epoch
#             }, f, indent=2)
        
#         # Save Dafny code
#         code_file = os.path.join(epoch_dir, f"iteration_{iteration}_code.dfy")
#         with open(code_file, "w", encoding='utf-8') as f:
#             f.write(code)
        
#         # Save error output
#         error_file = os.path.join(epoch_dir, f"iteration_{iteration}_error.txt")
#         with open(error_file, "w", encoding='utf-8') as f:
#             f.write(error_output)
        
#         print(f"Successfully saved iteration {iteration} results for epoch {epoch}")
        
#     except Exception as e:
#         print(f"Error saving iteration results: {str(e)}")
#         print(f"Attempted to save to: {epoch_dir}")
#         print(f"Current working directory: {os.getcwd()}")

# def save_epoch_summary(subfolder_path, epoch, total_reward, successful_examples_count, error_tree):
#     try:
#         folder_name = os.path.basename(subfolder_path)
#         root_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset"
        
#         # Create root directory if it doesn't exist
#         os.makedirs(root_dir, exist_ok=True)
        
#         # Create epoch directory
#         epoch_dir = os.path.join(root_dir, f"epoch_{epoch}_{folder_name}")
#         os.makedirs(epoch_dir, exist_ok=True)
        
#         # Save summary file
#         summary_file = os.path.join(epoch_dir, "epoch_summary.json")
#         with open(summary_file, "w", encoding='utf-8') as f:
#             json.dump({
#                 "epoch": epoch,
#                 "folder": folder_name,
#                 "total_reward": total_reward,
#                 "successful_examples_count": successful_examples_count,
#                 "error_tree_depth": error_tree.current_node.depth if error_tree.current_node else 0,
#                 "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
#             }, f, indent=2)
        
#         print(f"Successfully saved epoch {epoch} summary")
        
#     except Exception as e:
#         print(f"Error saving epoch summary: {str(e)}")
#         print(f"Attempted to save to: {root_dir}")
#         print(f"Current working directory: {os.getcwd()}")

# ###############################################################################
# # Metrics Tracking
# ###############################################################################

# class MetricsTracker:
#     def __init__(self, save_dir):
#         self.save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset"
#         os.makedirs(self.save_dir, exist_ok=True)
#         self.episode_rewards = []
#         self.cumulative_rewards = []
#         self.success_rates = []
#         self.error_counts = []
#         self.iteration_counts = []
#         self.average_rewards_per_epoch = []
#         self.training_loss = []
#         self.validation_loss = []
#         self.model_perplexity = []
#         self.error_types = defaultdict(list)
#         self.verification_success_rate = []
#         self.proof_obligation_counts = []
#         self.start_time = time.time()
#         self.epoch_times = []
    
#     def update_rl_metrics(self, reward, success, error_count, iterations):
#         self.episode_rewards.append(reward)
#         self.cumulative_rewards.append(sum(self.episode_rewards))
#         self.success_rates.append(float(success))
#         self.error_counts.append(error_count)
#         self.iteration_counts.append(iterations)
    
#     def update_epoch_metrics(self, avg_reward, training_loss=None, val_loss=None):
#         self.average_rewards_per_epoch.append(avg_reward)
#         if training_loss is not None:
#             self.training_loss.append(training_loss)
#         if val_loss is not None:
#             self.validation_loss.append(val_loss)
#         self.epoch_times.append(time.time() - self.start_time)
    
#     def update_error_analysis(self, error_type, verification_success, proof_obligations):
#         self.error_types[error_type].append(1)
#         self.verification_success_rate.append(float(verification_success))
#         self.proof_obligation_counts.append(proof_obligations)
    
#     def plot_learning_curves(self):
#         timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
#         folder_name = os.path.basename(os.path.dirname(self.save_dir))
        
#         plt.figure(figsize=(12, 6))
#         plt.plot(self.episode_rewards, label='Episode Rewards', color='blue')
#         plt.xlabel('Episode')
#         plt.ylabel('Reward')
#         plt.title(f'Episode Rewards - {folder_name}')
#         plt.grid(True)
#         plt.legend()
#         plt.savefig(os.path.join(self.save_dir, f'episode_rewards_{folder_name}_{timestamp}.png'))
#         plt.close()
        
#         plt.figure(figsize=(12, 6))
#         plt.plot(self.cumulative_rewards, label='Cumulative Rewards', color='green')
#         plt.xlabel('Episode')
#         plt.ylabel('Cumulative Reward')
#         plt.title(f'Cumulative Rewards - {folder_name}')
#         plt.grid(True)
#         plt.legend()
#         plt.savefig(os.path.join(self.save_dir, f'cumulative_rewards_{folder_name}_{timestamp}.png'))
#         plt.close()
        
#         plt.figure(figsize=(12, 6))
#         plt.plot(self.success_rates, label='Success Rate', color='orange')
#         plt.xlabel('Episode')
#         plt.ylabel('Success Rate')
#         plt.title(f'Verification Success Rate - {folder_name}')
#         plt.grid(True)
#         plt.legend()
#         plt.savefig(os.path.join(self.save_dir, f'success_rate_{folder_name}_{timestamp}.png'))
#         plt.close()
        
#         plt.figure(figsize=(12, 6))
#         colors = ['red', 'purple', 'brown', 'pink']
#         for (error_type, counts), color in zip(self.error_types.items(), colors):
#             plt.plot(counts, label=error_type, color=color)
#         plt.xlabel('Episode')
#         plt.ylabel('Error Count')
#         plt.title(f'Error Type Analysis - {folder_name}')
#         plt.grid(True)
#         plt.legend()
#         plt.savefig(os.path.join(self.save_dir, f'error_analysis_{folder_name}_{timestamp}.png'))
#         plt.close()
        
#         if self.training_loss:
#             plt.figure(figsize=(12, 6))
#             valid_indices = [i for i, x in enumerate(self.training_loss) if not (np.isnan(x) or np.isinf(x))]
#             valid_epochs = [i for i in valid_indices]
#             valid_losses = [self.training_loss[i] for i in valid_indices]
#             if valid_losses:
#                 plt.plot(valid_epochs, valid_losses, label='Training Loss', color='red')
#                 if self.validation_loss:
#                     valid_val_indices = [i for i, x in enumerate(self.validation_loss) if not (np.isnan(x) or np.isinf(x))]
#                     valid_val_epochs = [i for i in valid_val_indices]
#                     valid_val_losses = [self.validation_loss[i] for i in valid_val_indices]
#                     if valid_val_losses:
#                         plt.plot(valid_val_epochs, valid_val_losses, label='Validation Loss', color='blue')
#                 plt.xlabel('Epoch')
#                 plt.ylabel('Loss')
#                 plt.title(f'Model Training Progress - {folder_name}')
#                 plt.grid(True)
#                 plt.legend()
#                 plt.savefig(os.path.join(self.save_dir, f'training_loss_{folder_name}_{timestamp}.png'))
#             else:
#                 print(f"Warning: No valid loss values to plot for {folder_name}")
#             plt.close()
    
#     def save_metrics(self):
#         timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
#         folder_name = os.path.basename(os.path.dirname(self.save_dir))
#         metrics_data = {
#             'folder': folder_name,
#             'episode_rewards': self.episode_rewards,
#             'cumulative_rewards': self.cumulative_rewards,
#             'success_rates': self.success_rates,
#             'error_counts': self.error_counts,
#             'iteration_counts': self.iteration_counts,
#             'average_rewards_per_epoch': self.average_rewards_per_epoch,
#             'training_loss': self.training_loss,
#             'validation_loss': self.validation_loss,
#             'verification_success_rate': self.verification_success_rate,
#             'proof_obligation_counts': self.proof_obligation_counts,
#             'error_types': {k: list(v) for k, v in self.error_types.items()},
#             'epoch_times': self.epoch_times,
#             'total_training_time': time.time() - self.start_time
#         }
#         with open(os.path.join(self.save_dir, f'metrics_{folder_name}_{timestamp}.json'), 'w') as f:
#             json.dump(metrics_data, f, indent=2)

#     # metrics_tracker = None

# ###############################################################################
# # Dafny Environment with continuous weighted dataset saving
# ###############################################################################

# class DafnyEnv(gym.Env):
#     def __init__(self, prompt, tmp_path, error_path):
#         super(DafnyEnv, self).__init__()
#         self.prompt = prompt
#         self.tmp_path = tmp_path
#         self.error_path = error_path
#         self.successful_examples = []
#         self.error_tree = ErrorTree(max_depth=7)
#         self.current_iteration = 0
#         self.current_epoch = 0
#         self.subfolder_path = os.path.dirname(tmp_path)
#         self.epoch_rewards = []
#         self.current_loss = 0.0

#         # Define the continuous weighted dataset file (JSON Lines format)
#         self.weighted_dataset_path = os.path.join(self.subfolder_path, "weighted_training_examples.jsonl")
#         # Ensure the file exists (create an empty file if necessary)
#         if not os.path.exists(self.weighted_dataset_path):
#             open(self.weighted_dataset_path, "w").close()
        
#         global metrics_tracker
#         if metrics_tracker is None:
#             metrics_tracker = MetricsTracker(os.path.join(self.subfolder_path, "metrics"))
        
#         self.observation_space = gym.spaces.Box(low=0, high=255, shape=(len(prompt),), dtype=np.uint8)
#         self.action_space = gym.spaces.Discrete(1)  

#     def reset(self):
#         self.error_tree = ErrorTree(max_depth=7)
#         self.current_iteration = 0
#         self.epoch_rewards = []
#         return self.prompt

#     def set_current_loss(self, loss):
#         self.current_loss = float(loss.detach().item())

#     def get_dafny_output(self, code: str) -> tuple:
#         if not code or code.strip() == "":
#             reward = -7.0
#             error_output = "Error: Empty Dafny file"
#             code = ""
#             metrics_tracker.update_rl_metrics(reward, False, 1, self.current_iteration)
#             metrics_tracker.update_error_analysis("empty_file", False, 1)
#             print("saving empty file")
#             save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, error_output, code, 1)
#             return reward, error_output, code

#         with open(self.tmp_path, "w", encoding='utf-8') as file:
#             if code.startswith("Dafny code"):
#                 code = code.split("Dafny code", 1)[1].strip()
#             file.write(code)
        
#         dafny_directory = r"/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
#         os.chdir(dafny_directory)
        
#         dafny_command = f"/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny '{self.tmp_path}' > '{self.error_path}'"
#         os.system(dafny_command)
        
#         with open(self.error_path, "r", encoding='utf-8') as output_file:
#             output = output_file.read()
            
#             if "verified, 0 errors" in output and "Compiled assembly into" in output:
#                     reward = 5.0
#                     metrics_tracker.update_rl_metrics(reward, True, 0, self.current_iteration)
#                     metrics_tracker.update_error_analysis("success", True, 0)
#                     print("saving success")
#                     save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, output, code, 0)
#             else:
#                 error_count = 0
#                 error_types = defaultdict(int)
#                 for line in output.split('\n'):
#                     if "Error:" in line or "error:" in line:
#                         error_count += 1
#                         if "assertion violation" in line.lower():
#                             error_types["assertion"] += 1
#                         elif "precondition violation" in line.lower():
#                             error_types["precondition"] += 1
#                         elif "postcondition violation" in line.lower():
#                             error_types["postcondition"] += 1
#                         else:
#                             error_types["other"] += 1
                
#                 a = 0.2
#                 b = 0.5 * self.current_iteration
#                 shaped_penalty = -a * error_count - b
#                 reward = -5.0 + shaped_penalty
#                 metrics_tracker.update_rl_metrics(reward, False, error_count, self.current_iteration)
#                 for error_type, count in error_types.items():
#                     metrics_tracker.update_error_analysis(error_type, False, error_count)
#                 # metrics_tracker.update_rl_metrics(reward, False, 1, self.current_iteration)
#                 # metrics_tracker.update_error_analysis("empty_file", False, 1)
#                 print("saving error file")
#                 save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, output, code, error_count)
#                 print("total_reward: ", reward)
#                 print("error_count: ", error_count)
#                 print("iteration: ", self.current_iteration)
#                 print("--------------------------------")
#                 # save_iteration_results(self.subfolder_path, self.current_iteration, self.current_epoch, reward, output, code, error_count)
#             return reward, output, code

#     def step(self, action):
#         current_prompt = self.prompt if self.current_iteration == 0 else None
#         total_reward = 0
#         done = False
        
#         # Pre-fetch error context outside the loop
#         error_context = None
#         if self.current_iteration > 0 and self.error_tree.current_node:
#             current_node = self.error_tree.current_node
#             error_context = {
#                 'error_code': current_node.error_code,
#                 'error_message': current_node.error_message,
#                 'reward': current_node.reward,
#                 'attempts': self.current_iteration
#             }
        
#         # Process attempts sequentially
#         max_attempts = 7
#         attempt = 0
        
#         while attempt < max_attempts and not done:
#             # Generate prompt based on attempt number
#             if attempt == 0:
#                 current_prompt = ShortPrompt(self.prompt)
#             else:
#                 # Use error context from previous attempt
#                 if hasattr(self, 'last_attempt_info'):
#                     current_prompt = ErrorPrompt(
#                         self.last_attempt_info['error_output'],
#                         self.prompt,
#                         self.last_attempt_info['code'],
#                         str(self.last_attempt_info['reward'])
#                     )
#                 else:
#                     current_prompt = ShortPrompt(self.prompt)
            
#             # Get responses
#             slm_response = run_SLM(current_prompt)
#             llm_response = run_LLM(slm_response)
            
#             # Extract and validate Dafny code
#             dafny_code = extract_dafny_code(llm_response)
#             if not dafny_code or dafny_code.strip() == "":
#                 attempt += 1
#                 self.current_iteration += 1
#                 continue
            
#             # Get Dafny output and update rewards
#             print("getting dafny output")
#             reward, error_output, code = self.get_dafny_output(dafny_code)
#             total_reward += reward
#             self.epoch_rewards.append(reward)
            
#             # Store current attempt info for next iteration
#             self.last_attempt_info = {
#                 'error_output': error_output,
#                 'code': code,
#                 'reward': reward
#             }
            
#             # Update error tree
#             new_node = self.error_tree.add_node(
#                 error_code=code,
#                 error_message=error_output,
#                 reward=reward,
#                 prompt=slm_response,
#                 parent=self.error_tree.current_node
#             )
#             self.error_tree.current_node = new_node
            
#             # Prepare weighted training example
#             example = {
#                 "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
#                 "prompt": slm_response,
#                 "llm_response": llm_response,
#                 "dafny_code": code,
#                 "error_output": error_output,
#                 "reward": reward,
#                 "loss_weight": calculate_example_weight(reward, scale=1.0)
#             }
#             append_to_weighted_dataset(self.weighted_dataset_path, example)
            
#             # Handle successful cases
#             if reward > 0:
#                 self.successful_examples.append({
#                     "prompt": slm_response,
#                     "response": llm_response,
#                     "reward": reward,
#                     "error_context": error_context
#                 })
                
#                 if len(self.successful_examples) > 100:
#                     self.successful_examples = self.successful_examples[-100:]
                
#                 new_node.success = True
#                 self.error_tree.successful_path = self.error_tree.get_path_to_node(new_node)
#                 done = True
#                 break
            
#             attempt += 1
#             self.current_iteration += 1
            
#             # Check if we've reached max attempts
#             if attempt >= max_attempts:
#                 done = True
        
#         info = {
#             "error_tree": self.error_tree,
#             "successful_examples_count": len(self.successful_examples),
#             "iterations": self.current_iteration,
#             "final_reward": total_reward,
#             "epoch_rewards": self.epoch_rewards
#         }
        
#         if done:
#             save_epoch_summary(
#                 self.subfolder_path,
#                 self.current_epoch,
#                 total_reward,
#                 len(self.successful_examples),
#                 self.error_tree
#             )
#             avg_epoch_reward = sum(self.epoch_rewards) / len(self.epoch_rewards) if self.epoch_rewards else 0
#             metrics_tracker.update_epoch_metrics(
#                 avg_reward=avg_epoch_reward,
#                 training_loss=self.current_loss
#             )
        
#         torch.cuda.empty_cache()
        
#         return self.prompt, total_reward, done, info

# ###############################################################################
# # GRPO Agent and Training Routine
# ###############################################################################

# class GRPOAgent(nn.Module):
#     def __init__(self, input_size, hidden_size, output_size):
#         super(GRPOAgent, self).__init__()
#         self.fc = nn.Linear(input_size, hidden_size)
#         self.policy_head = nn.Linear(hidden_size, output_size)
#         self.value_head = nn.Linear(hidden_size, 1)

#     def forward(self, x):
#         x = torch.relu(self.fc(x))
#         policy_logits = self.policy_head(x)
#         value = self.value_head(x)
#         return policy_logits, value

# def train_grpo(agent, env, optimizer, num_epochs=5, gamma=0.99):
#     """
#     A GRPO training routine that uses a vanilla policy gradient update.
#     Instead of clipping the probability ratio, we compute:
#       policy_loss = -log_pi(a|s)*advantage.
#     The value loss is computed as an MSE loss on the baseline.
#     """
#     total_rewards = 0
#     successful_examples_history = []
#     error_trees = []

#     for epoch in range(num_epochs):
#         env.current_epoch = epoch
#         epoch_start_time = time.time()
#         epoch_rewards = []
        
#         obs = env.reset()
#         input_size = agent.fc.in_features
#         obs_encoded = [ord(c) for c in obs]
#         if len(obs_encoded) < input_size:
#             obs_encoded += [0] * (input_size - len(obs_encoded))
#         else:
#             obs_encoded = obs_encoded[:input_size]
#         obs_tensor = torch.tensor(obs_encoded, dtype=torch.float32).unsqueeze(0).to(device)
        
#         policy_logits, value = agent(obs_tensor)
#         m = Categorical(logits=policy_logits)
#         action = m.sample()
#         log_prob = m.log_prob(action)
        
#         next_obs, reward, done, info = env.step(action)
#         total_rewards += reward
#         epoch_rewards.append(reward)
        
#         error_trees.append(info["error_tree"])
#         successful_examples_history.append(info["successful_examples_count"])
        
#         returns = reward * gamma
#         value = value.squeeze(-1)
#         advantage = returns - value.detach()
        
#         # GRPO update: simple vanilla policy gradient objective without clipping.
#         policy_loss = - (log_prob * advantage).mean()
#         value_loss = F.mse_loss(value, torch.tensor([returns], dtype=torch.float32).to(device))
#         loss = policy_loss + 0.5 * value_loss
        
#         env.set_current_loss(loss)
        
#         optimizer.zero_grad()
#         loss.backward()
#         optimizer.step()
        
#         env.set_current_loss(loss)
        
#         if (epoch + 1) % 5 == 0:
#             metrics_tracker.plot_learning_curves()
#             metrics_tracker.save_metrics()
#             print(f"\nEpoch {epoch + 1}/{num_epochs}")
#             print(f"Total Rewards: {total_rewards}")
#             print(f"Successful Examples: {info['successful_examples_count']}")
#             print(f"Average Loss: {loss.item():.4f}")
#             print(f"Iterations in last episode: {info['iterations']}")
    
#     return {
#         "total_rewards": total_rewards,
#         "successful_examples_history": successful_examples_history,
#         "error_trees": error_trees
#     }

# ###############################################################################
# # Process Subfolders and Overall Training Routine
# ###############################################################################

# def process_subfolders(root_directory, temperature):
#     results = {}
    
#     print("Initializing models for all subfolders...")
#     global global_model, global_tokenizer
#     if global_model is None or global_tokenizer is None:
#         global_model, global_tokenizer = initialize_slm()
    
#     lora_save_dir = os.path.join(root_directory, "lora_adapters")
#     os.makedirs(lora_save_dir, exist_ok=True)
    
#     for entry in os.listdir(root_directory):
#         subfolder_path = os.path.join(root_directory, entry)
#         if os.path.isdir(subfolder_path):
#             description_file = os.path.join(subfolder_path, "detailed_description.txt")
#             if os.path.exists(description_file):
#                 with open(description_file, "r", encoding='utf-8') as file:
#                     sample_prompt = file.read().strip()
                
#                 print(f"\nProcessing subfolder: {subfolder_path}")
#                 print("Sample prompt:\n", sample_prompt)
                
#                 tmp_path = os.path.join(subfolder_path, "RL_No_feedback.dfy")
#                 error_path = os.path.join(subfolder_path, "RL_no_feedbacl_error.txt")
                
#                 env = DafnyEnv(sample_prompt, tmp_path, error_path)
                
#                 input_size = 1024  # example value
#                 hidden_size = 64
#                 output_size = 5

#                 # Use GRPO Agent for this variant.
#                 agent = GRPOAgent(input_size, hidden_size, output_size).to(device)
#                 optimizer = optim.Adam(agent.parameters(), lr=5e-4)
                
#                 subfolder_results = train_grpo(agent, env, optimizer, num_epochs=5)
#                 results[entry] = subfolder_results
                
#                 if env.successful_examples:
#                     lora_adapter_path = os.path.join(lora_save_dir, f"lora_adapter_{entry}")
#                     global_model.save_pretrained(lora_adapter_path)
#                     examples_file = os.path.join(subfolder_path, "successful_examples.json")
#                     with open(examples_file, "w") as f:
#                         json.dump(env.successful_examples, f, indent=2)
    
#     return results

# ###############################################################################
# # Main Execution
# ###############################################################################

# if __name__ == "__main__":
#     parser = argparse.ArgumentParser(description='Run Dafny code generation with specified temperature')
#     parser.add_argument('--temperature', type=float, default=0.75,
#                       help='Temperature for LLM generation (default: 0.75)')
#     args = parser.parse_args()

#     results = process_subfolders("/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny", args.temperature)
    
#     with open("training_results.json", "w") as f:
#         json.dump({
#             k: {
#                 "total_rewards": v["total_rewards"],
#                 "successful_examples_count": len(v["successful_examples_history"]),
#                 "iterations_per_epoch": [tree.current_node.depth if tree.current_node else 0 for tree in v["error_trees"]]
#             }
#             for k, v in results.items()
#         }, f, indent=2)