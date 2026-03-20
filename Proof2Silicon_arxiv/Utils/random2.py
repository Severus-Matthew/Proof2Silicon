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

# vLLM imports
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
    return 1.0 + scale * abs(reward) if reward < 0 else 1.0

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
        node = TreeNode(error_code, error_message, reward, prompt, parent, [], depth)
        if parent:
            parent.children.append(node)
        else:
            self.root = node
        return node

    def get_path_to_node(self, node: TreeNode) -> List[TreeNode]:
        path, current = [], node
        while current:
            path.append(current)
            current = current.parent
        return list(reversed(path))

    def traverse(self) -> List[TreeNode]:
        out = []
        def walk(n):
            out.append(n)
            for c in n.children: walk(c)
        if self.root: walk(self.root)
        return out

###############################################################################
# Metrics Tracker
###############################################################################
class MetricsTracker:
    def __init__(self, save_dir):
        self.save_dir = save_dir
        os.makedirs(save_dir, exist_ok=True)
        self.episode_rewards = []
        self.cumulative_rewards = []
        self.success_rates = []
        self.error_counts = []
        self.iteration_counts = []
        self.average_rewards_per_epoch = []
        self.training_loss = []
        self.validation_loss = []
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
        if training_loss is not None: self.training_loss.append(training_loss)
        if val_loss is not None: self.validation_loss.append(val_loss)
        self.epoch_times.append(time.time() - self.start_time)

    def update_error_analysis(self, error_type, verification_success, proof_obligations):
        self.error_types[error_type].append(1)
        self.verification_success_rate.append(float(verification_success))
        self.proof_obligation_counts.append(proof_obligations)

    def plot_learning_curves(self):
        import matplotlib.pyplot as plt
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        name = os.path.basename(self.save_dir)
        plt.figure(); plt.plot(self.episode_rewards); plt.title(f'Rewards-{name}'); plt.savefig(f'{self.save_dir}/rewards_{ts}.png'); plt.close()
        plt.figure(); plt.plot(self.cumulative_rewards); plt.title(f'Cumulative-{name}'); plt.savefig(f'{self.save_dir}/cum_{ts}.png'); plt.close()

    def save_metrics(self):
        with open(f"{self.save_dir}/metrics_{datetime.now():%Y%m%d_%H%M%S}.json", 'w') as f:
            json.dump(vars(self), f, default=list)

###############################################################################
# DafnyEnv Definition
###############################################################################
class DafnyEnv(gym.Env):
    def __init__(self, prompt, tmp_path, error_path):
        super().__init__()
        self.prompt = prompt
        self.tmp_path = tmp_path
        self.error_path = error_path
        self.successful_examples = []
        self.error_tree = ErrorTree()
        global metrics_tracker
        if metrics_tracker is None:
            metrics_tracker = MetricsTracker(os.path.join(os.path.dirname(tmp_path), "metrics"))

    def reset(self): return self.prompt

    def step(self, action):
        slm_resp = run_SLM(self.prompt)
        llm_resp = run_LLM(slm_resp)
        code = extract_dafny_code(llm_resp)
        reward, err, code = self.get_dafny_output(code)
        example = {"prompt": slm_resp, "llm": llm_resp, "code": code, "err": err, "reward": reward}
        append_to_weighted_dataset(self.tmp_path.replace('.dfy','.jsonl'), example)
        if reward>0: self.successful_examples.append(example)
        return self.prompt, reward, True, {"successes": len(self.successful_examples)}

    def get_dafny_output(self, code):
        open(self.tmp_path,'w').write(code)
        os.system(f"dafny {self.tmp_path} > {self.error_path}")
        out = open(self.error_path).read()
        ok = "verified, 0 errors" in out
        return (5.0 if ok else -1.0), out, code

###############################################################################
# Inference utilities including run_SLM and run_LLM
###############################################################################
def initialize_slm():
    global global_model, global_tokenizer
    if global_model and global_tokenizer: return global_model, global_tokenizer
    name = "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
    tok = AutoTokenizer.from_pretrained(name, trust_remote_code=True)
    if tok.pad_token is None:
        tok.pad_token, tok.pad_token_id = tok.eos_token, tok.eos_token_id
    cfg = BitsAndBytesConfig(load_in_4bit=True, bnb_4bit_quant_type="nf4", bnb_4bit_double_quant=True, bnb_4bit_compute_dtype=torch.float16)
    mdl = AutoModelForCausalLM.from_pretrained(name, quantization_config=cfg, device_map="auto", use_cache=False, torch_dtype=torch.float16)
    mdl = prepare_model_for_kbit_training(mdl)
    lora = LoraConfig(r=16, lora_alpha=32, target_modules=["q_proj","v_proj"], lora_dropout=0.1, bias="none", task_type="CAUSAL_LM")
    mdl = get_peft_model(mdl, lora)
    mdl.gradient_checkpointing_enable()
    mdl.enable_input_require_grads()
    global_model, global_tokenizer = mdl, tok
    return mdl, tok


def run_SLM(prompt):
    mdl, tok = initialize_slm()
    inp = tok(prompt, return_tensors="pt", truncation=True, padding=True).to(device)
    out = mdl.generate(**inp, max_new_tokens=512, do_sample=True)
    return tok.decode(out[0], skip_special_tokens=True)

class InferlessPythonModel:
    def initialize(self):
        mid = "Qwen/Qwen2.5-Coder-14B-Instruct-GPTQ-Int8"
        self.llm = LLM(model=mid, gpu_memory_utilization=0.98, max_model_len=6000, dtype="float16")
        self.tokenizer = AutoTokenizer.from_pretrained(mid)

    def infer(self, inputs):
        prompts = inputs["prompt"]
        sp = SamplingParams(
            temperature=inputs.get("temperature",0.7),
            top_p=inputs.get("top_p",0.1),
            repetition_penalty=inputs.get("repetition_penalty",1.18),
            top_k=int(inputs.get("top_k",40)),
            max_tokens=int(inputs.get("max_tokens",256))
        )
        text = self.tokenizer.apply_chat_template([{"role":"user","content":prompts}], tokenize=False)
        tokd = self.tokenizer(text, truncation=True, max_length=6000, return_tensors="pt")
        txt = self.tokenizer.decode(tokd.input_ids[0], skip_special_tokens=True)
        res = self.llm.generate(txt, sp)
        return {"generated_text": res[0].outputs[0].text}

    def finalize(self): self.llm=None


def run_LLM(response_text):
    if not hasattr(run_LLM, 'infer_model'):
        run_LLM.infer_model = InferlessPythonModel(); run_LLM.infer_model.initialize()
    inp = {"prompt": response_text, "temperature":0.7, "top_p":0.1, "repetition_penalty":1.18, "top_k":40, "max_tokens":6000}
    out = run_LLM.infer_model.infer(inp)["generated_text"]
    return out

# GRPO Wrapper and training loop omitted (unchanged)
# process_subfolders() and __main__ omitted for brevity
