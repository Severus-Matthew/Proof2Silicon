import json
import logging
import os
import time
import zipfile
from typing import Any, Dict, List, Set, Tuple
from preface_rl.envs import DafnyEnv
from dataclasses import dataclass
from transformers import GenerationConfig
import torch
import torch.nn as nn
import torch.nn.functional as F
import wandb
import wandb
# wandb.init(settings=wandb.Settings(init_timeout=400))  # Sets timeout to 300 seconds
from accelerate import init_empty_weights, load_checkpoint_and_dispatch  # noqa: F401
from datasets import Dataset  # noqa: F401
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from torch.distributions.categorical import Categorical
from torch.optim import Adam
from torch.optim.lr_scheduler import ReduceLROnPlateau
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    BitsAndBytesConfig,
    DataCollatorForLanguageModeling,
    Trainer,
    TrainingArguments,
)

from .metrics import get_metrics_tracker, set_metrics_tracker, MetricsTracker

# # GPU / CUDA setup and constants previously at top-level
# torch.cuda.set_per_process_memory_fraction(0.8, device=0)
# os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "max_split_size_mb:128,expandable_segments:True"
# device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
# logging.info(f"Using device: {device}")
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

CHECKPOINT_DIR = "/u/mjha1/Proof2Silicon/journal_phase/checkpoints_3" #HERE_FOR_CHANGE
LORA_ADAPTER_DIR = (
    "/u/mjha1/Proof2Silicon/journal_phase/lora_adapters_3" #HERE_FOR_CHANGE
)
METRICS_DIR = "/u/mjha1/Proof2Silicon/journal_phase/wandb_metrics_3" #HERE_FOR_CHANGE
os.makedirs(METRICS_DIR, exist_ok=True)
os.makedirs(CHECKPOINT_DIR, exist_ok=True)
os.makedirs(LORA_ADAPTER_DIR, exist_ok=True)

# Globals for SLM
global_model = None
global_tokenizer = None

def configure_runtime():
    os.environ.setdefault(
        "PYTORCH_CUDA_ALLOC_CONF",
        "max_split_size_mb:128,expandable_segments:True",
    )
    if torch.cuda.is_available():
        try:
            torch.cuda.empty_cache()
            torch.cuda.set_per_process_memory_fraction(0.8, device=0)
        except Exception as e:
            logging.warning(f"Could not set CUDA runtime config: {e}")

def _do_policy_update(log_probs_window, values_window, rewards_window,
                      actor_optimizer, critic_optimizer,
                      actor_params, critic_params,
                      gamma, device):
    """Compute returns+advantages and do one optimizer step on a window of steps."""
    clipped = [max(-10.0, min(10.0, float(r))) for r in rewards_window]
    R = 0.0
    returns = []
    for r in reversed(clipped):
        R = float(r) + gamma * R
        returns.append(R)
    returns = list(reversed(returns))

    returns_t   = torch.tensor(returns, device=device, dtype=torch.float32)
    values_t    = torch.stack(values_window).float()
    log_probs_t = torch.stack(log_probs_window).float()

    if not (torch.isfinite(returns_t).all() and
            torch.isfinite(values_t).all() and
            torch.isfinite(log_probs_t).all()):
        logging.warning("Non-finite tensors in mini-batch update; skipping.")
        return None, None

    advantages_t = returns_t - values_t.detach()
    if len(advantages_t) > 1:
        adv_std = advantages_t.std(unbiased=False)
        if torch.isfinite(adv_std) and adv_std.item() > 1e-8:
            advantages_t = (advantages_t - advantages_t.mean()) / (adv_std + 1e-8)
        else:
            advantages_t = advantages_t - advantages_t.mean()
    else:
        advantages_t = advantages_t - advantages_t.mean()

    policy_loss       = -(log_probs_t * advantages_t).mean()
    value_loss        = F.mse_loss(values_t, returns_t)
    total_loss_tensor = policy_loss + value_loss

    if not (torch.isfinite(policy_loss).all() and
            torch.isfinite(value_loss).all() and
            torch.isfinite(total_loss_tensor).all()):
        logging.warning("Non-finite loss in mini-batch update; skipping.")
        return None, None

    actor_optimizer.zero_grad()
    critic_optimizer.zero_grad()
    total_loss_tensor.backward()
    torch.nn.utils.clip_grad_norm_(actor_params, max_norm=0.5)
    torch.nn.utils.clip_grad_norm_(critic_params, max_norm=0.5)
    actor_optimizer.step()
    critic_optimizer.step()

    return float(policy_loss.item()), float(value_loss.item())

class WeightedTrainer(Trainer):
    def compute_loss(self, model, inputs, return_outputs=False):
        loss_weights = inputs.pop("loss_weight", None)
        outputs = model(**inputs)
        loss = outputs.loss
        if loss_weights is not None:
            loss = (loss * loss_weights).mean()
        return (loss, outputs) if return_outputs else loss


def initialize_slm(checkpoint_path: str | None = None):
    global global_model, global_tokenizer
    import gc
    torch.cuda.empty_cache()
    gc.collect()
    configure_runtime()
    if global_model is not None:
        return global_model, global_tokenizer
    local_device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    model_name = "Qwen/Qwen2.5-1.5B-Instruct"
    print("Loading tokenizer...")
    global_tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
    if global_tokenizer.pad_token is None:
        global_tokenizer.pad_token = global_tokenizer.eos_token
        global_tokenizer.pad_token_id = global_tokenizer.eos_token_id

    try:
        # Configure quantization and offloading
        print("Configuring quantization and offloading settings...")
        quant_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_use_double_quant=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.float16,
        )

        # Create offload folder
        offload_folder = "/u/mjha1/Proof2Silicon/journal_phase/model_offload_3" #HERE_FOR_CHANGE
        os.makedirs(offload_folder, exist_ok=True)

        # Configure memory limits
        max_memory = {0: "24GiB", "cpu": "96GiB"}

        print("Loading base model with offloading configuration...")
        global_model = AutoModelForCausalLM.from_pretrained(
            model_name,
            quantization_config=quant_config,
            trust_remote_code=True,
            device_map="auto",
            max_memory=max_memory,
            offload_folder=offload_folder,
            offload_state_dict=True,
            torch_dtype=torch.float16,
            low_cpu_mem_usage=True,
        )

        # Prepare for kbit training with offloading
        print("Preparing model for kbit training...")
        global_model = prepare_model_for_kbit_training(global_model)
        global_model.config.use_cache = False

        global_model.gradient_checkpointing_enable()
        # Configure LoRA with offloading support
        print("Configuring LoRA...")
        lora_config = LoraConfig(
            r=16,
            lora_alpha=32,
            target_modules=[
                "q_proj",
                "k_proj",
                "v_proj",
                "o_proj",
                "gate_proj",
                "up_proj",
                "down_proj",
            ],
            lora_dropout=0.1,
            bias="none",
            task_type="CAUSAL_LM",
            # modules_to_save=["embed_tokens", "lm_head"],
            inference_mode=False,
        )

        # Apply LoRA config with offloading
        print("Applying LoRA configuration...")
        global_model = get_peft_model(global_model, lora_config)

        # Load checkpoint if provided
        if checkpoint_path and os.path.exists(checkpoint_path):
            print(f"Loading checkpoint from {checkpoint_path}")
            try:
                checkpoint = torch.load(checkpoint_path, map_location=local_device)
                if "model_state_dict" in checkpoint:
                    state_dict = checkpoint["model_state_dict"]
                    model_state = global_model.state_dict()
                    filtered_state_dict = {
                        k: v for k, v in state_dict.items() if k in model_state
                    }
                    model_state.update(filtered_state_dict)
                    global_model.load_state_dict(model_state, strict=False)
                    logging.info("Successfully loaded model state from checkpoint")
                else:
                    logging.warning(
                        "Checkpoint does not contain model_state_dict, using base model"
                    )
                    global_model.load_state_dict(checkpoint, strict=False)
                    print("Successfully loaded direct state dict from checkpoint")

            except Exception as e:
                print(f"Warning: Could not load checkpoint: {str(e)}")

        # Enable training optimizations
        global_model.gradient_checkpointing_enable()
        global_model.enable_input_require_grads()
        global_model.train()

        # Set up activation checkpointing for memory efficiency
        if hasattr(global_model, "model") and hasattr(global_model.model, "layers"):
            for layer in global_model.model.layers:
                layer.gradient_checkpointing = True

        print("Model successfully initialized with offloading")
        print(f"Device map: {getattr(global_model, 'hf_device_map', 'not set')}")
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
            nn.Linear(hidden_size, hidden_size, dtype=torch.float16),
            nn.ReLU(),
            nn.Linear(hidden_size, 1, dtype=torch.float16),
        )

    def forward(self, input_ids, attention_mask=None, prompt_len: int = -1):
        outputs = self.model(
            input_ids=input_ids,
            attention_mask=attention_mask,
            output_hidden_states=True,
            return_dict=True,
        )
        logits = outputs.logits
        # Use last prompt token as state representation, not last generated token.
        # Falls back to -1 (last token) during pure generation where prompt_len unknown.
        value_idx = (prompt_len - 1) if prompt_len > 0 else -1
        last_hidden = outputs.hidden_states[-1][:, value_idx, :].to(device=device, dtype=torch.float16)
        values = self.value_head(last_hidden).squeeze(-1).to(device=device, dtype=torch.float16)
        return logits, values


MAX_PROMPT_TOKENS = 1024   # hard cap on input prompt tokens fed to SLM
MAX_NEW_TOKENS    = 768  # tokens the SLM is allowed to generate
MAX_SEQ_LEN       = MAX_PROMPT_TOKENS + MAX_NEW_TOKENS  # 1280 total
@dataclass
class RolloutSample:
    prompt_text: str
    prompt_ids: torch.Tensor
    generated_ids: torch.Tensor
    instruction_text: str
    old_logprob: torch.Tensor
    old_value: torch.Tensor
    reward: float
    advantage: float = 0.0
    return_: float = 0.0
    entropy: float = 0.0
    episode_id: int = 0

def _save_slm_interaction(prompt: str, response: str) -> None:
    """Save SLM prompt and generated instruction to disk for inspection."""
    save_dir = "/u/mjha1/Proof2Silicon/journal_phase/prompts/slm_new_3" #HERE_FOR_CHANGE
    os.makedirs(save_dir, exist_ok=True)
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    try:
        with open(os.path.join(save_dir, f"slm_interaction_{timestamp}.json"), "w") as f:
            json.dump({"timestamp": timestamp, "prompt": prompt, "response": response}, f, indent=2)
    except Exception as e:
        logging.warning("Could not save SLM interaction to disk: %s", e)

def compute_sequence_logprob_and_value(slm_pg, prompt_ids, generated_ids):
    full_ids = torch.cat([prompt_ids, generated_ids], dim=1)
    if full_ids.shape[1] > MAX_SEQ_LEN:
        full_ids = full_ids[:, :MAX_SEQ_LEN]

    attention_mask = torch.ones_like(full_ids).to(full_ids.device)
    logits, value = slm_pg(
        input_ids=full_ids,
        attention_mask=attention_mask,
        prompt_len=prompt_ids.shape[1],
    )

    prompt_len = prompt_ids.shape[1]
    gen_len = generated_ids.shape[1]

    token_logits = logits[:, prompt_len - 1 : prompt_len - 1 + gen_len, :]
    log_probs = F.log_softmax(token_logits, dim=-1)

    token_log_probs = log_probs.gather(
        2, generated_ids.unsqueeze(-1)
    ).squeeze(-1)

    seq_log_prob = token_log_probs.sum(dim=1).squeeze(0)

    token_probs = torch.exp(log_probs)
    entropy = -(token_probs * log_probs).sum(dim=-1).mean()

    return seq_log_prob, value, entropy



def generate_instruction_sequence(slm_pg, tokenizer, prompt_text, max_new_tokens=MAX_NEW_TOKENS, temperature=0.2):
    slm_pg.eval()
    if hasattr(slm_pg.model, "gradient_checkpointing_disable"):
        slm_pg.model.gradient_checkpointing_disable()
    # Tokenise prompt with its own budget so generation is never squeezed out
    inputs = tokenizer(
        prompt_text,
        return_tensors="pt",
        truncation=True,
        padding=False,
        max_length=MAX_PROMPT_TOKENS,
    )
    input_ids = inputs["input_ids"].to(device)
    attention_mask = inputs["attention_mask"].to(device)

    prompt_len = input_ids.shape[1]  # actual prompt length after truncation
    gen_config = GenerationConfig(
        max_new_tokens=max_new_tokens,
        do_sample=True,
        temperature=0.3,
        top_p=0.9,
        top_k=50,
        pad_token_id=tokenizer.pad_token_id,
        eos_token_id=tokenizer.eos_token_id,
    )
    # generated_tokens = []
    # log_probs = []
    # step_distributions = []

    with torch.no_grad():
        _, state_value = slm_pg(input_ids=input_ids, attention_mask=attention_mask)
        output_ids = slm_pg.model.generate(input_ids=input_ids, attention_mask=attention_mask, generation_config=gen_config)
    generated_ids = output_ids[:, prompt_len:]
    if generated_ids.shape[1] == 0:
            slm_pg.train()
            return "", None, None, None, 0, []
    instruction_text = tokenizer.decode(generated_ids[0], skip_special_tokens=True)

    # Recompute log_probs WITH grad only once on the full sequence (not per-step)
    if hasattr(slm_pg.model, "gradient_checkpointing_enable"):
        slm_pg.model.gradient_checkpointing_enable()
    slm_pg.train()

    seq_log_prob, value, entropy = compute_sequence_logprob_and_value(
        slm_pg, inputs["input_ids"].to(device), generated_ids.to(device))

    token_count = generated_ids.shape[1]
    _save_slm_interaction(prompt_text, instruction_text)
    return instruction_text, seq_log_prob, value.squeeze(), generated_ids, token_count, entropy



def recompute_logprobs_for_sequence(slm_pg, prompt_ids, generated_ids):
    """Single forward pass over full sequence to get log_probs + value for training."""
    full_ids = torch.cat([prompt_ids, generated_ids.to(device)], dim=1)
    # Trim to combined budget (prompt + generation), not old 512 hard-cap
    if full_ids.shape[1] > MAX_SEQ_LEN:
        full_ids = full_ids[:, :MAX_SEQ_LEN]

    attn = torch.ones_like(full_ids)
    logits, value = slm_pg(input_ids=full_ids, attention_mask=attn, prompt_len=prompt_ids.shape[1])

    # Get log probs only over generated portion
    gen_len = generated_ids.shape[1]
    prompt_len = prompt_ids.shape[1]
    shift_logits = logits[:, prompt_len - 1: prompt_len - 1 + gen_len, :]
    shift_labels = generated_ids.to(device)

    log_probs = F.log_softmax(shift_logits, dim=-1)
    token_log_probs = log_probs.gather(2, shift_labels.unsqueeze(-1)).squeeze(-1)
    seq_log_prob = token_log_probs.mean(dim=-1).squeeze()

    return seq_log_prob, value
def compute_mean_kl(current_distributions, previous_distributions):
    if previous_distributions is None or len(previous_distributions) == 0:
        return 0.0

    steps = min(len(current_distributions), len(previous_distributions))
    if steps == 0:
        return 0.0

    kl_total = 0.0
    for i in range(steps):
        p = current_distributions[i].clamp_min(1e-10)
        q = previous_distributions[i].clamp_min(1e-10)
        kl = torch.sum(p * torch.log(p / q), dim=-1).mean()
        kl_total += kl.item()

    return kl_total / steps

def load_checkpoint(
    checkpoint_path: str, slm_pg: SLMPG, optimizer: Adam
) -> Tuple[Dict[str, Any] | None, List[float], List[Any], Set[str]]:
    if not os.path.exists(checkpoint_path):
        print(f"Checkpoint not found at {checkpoint_path}")
        return None, [], [], set()

    print(f"Loading checkpoint from {checkpoint_path}")

    try:
        checkpoint = torch.load(checkpoint_path, map_location=device)
        missing_keys, unexpected_keys = slm_pg.load_state_dict(
            checkpoint["model_state_dict"], strict=False
        )
        if missing_keys:
            print(f"[Checkpoint Load] Missing keys in model: {missing_keys}")
        if unexpected_keys:
            print(f"[Checkpoint Load] Unexpected keys in checkpoint: {unexpected_keys}")

        model_keys = set(slm_pg.state_dict().keys())
        checkpoint_keys = set(checkpoint["model_state_dict"].keys())
        missing = model_keys - checkpoint_keys
        unexpected = checkpoint_keys - model_keys
        if missing:
            print(f"[Checkpoint Load] Model keys missing from checkpoint: {missing}")
        if unexpected:
            print(f"[Checkpoint Load] Checkpoint keys not in model: {unexpected}")

        if "optimizer_state_dict" in checkpoint:
            optimizer.load_state_dict(checkpoint["optimizer_state_dict"])
            for state in optimizer.state.values():
                for k, v in state.items():
                    if isinstance(v, torch.Tensor):
                        state[k] = v.to(device)

        total_rewards = checkpoint.get("rewards", [])
        successful_examples = checkpoint.get("successful_examples", [])
        processed_samples = checkpoint.get("processed_samples", set())
        print(
            f"Loaded checkpoint with {len(total_rewards)} previous rewards, "
            f"{len(successful_examples)} successful examples, and "
            f"{len(processed_samples)} processed samples"
        )
        return checkpoint, total_rewards, successful_examples, processed_samples
    except (RuntimeError, EOFError, zipfile.BadZipFile) as e:
        print(f"Error loading checkpoint - file may be corrupted: {str(e)}")
        try:
            os.remove(checkpoint_path)
            print(f"Removed corrupted checkpoint file: {checkpoint_path}")
        except OSError as e:
            print(f"Could not remove corrupted checkpoint: {str(e)}")
        return None, [], [], set()
    except Exception as e:
        print(f"Unexpected error loading checkpoint: {str(e)}")
        return None, [], [], set()


def save_checkpoint_safely(checkpoint_data: Dict[str, Any], checkpoint_path: str) -> bool:
    """
    Safely save a checkpoint by first saving to a temporary file and then moving it
    to the final location. This prevents corruption if saving is interrupted.
    """
    checkpoint_dir = os.path.dirname(checkpoint_path)
    os.makedirs(checkpoint_dir, exist_ok=True)

    base_name = os.path.splitext(os.path.basename(checkpoint_path))[0]
    temp_path = os.path.join(checkpoint_dir, f"{base_name}.tmp.pt")
    backup_path = os.path.join(checkpoint_dir, f"{base_name}.backup.pt")

    try:
        torch.save(checkpoint_data, temp_path)

        # Basic integrity check
        test_load = torch.load(temp_path, map_location="cpu")
        if "model_state_dict" not in test_load:
            raise ValueError("Saved checkpoint is missing required model_state_dict")

        if os.path.exists(checkpoint_path):
            try:
                os.replace(checkpoint_path, backup_path)
            except OSError as e:
                print(f"Warning: could not backup existing checkpoint: {e}")

        os.replace(temp_path, checkpoint_path)

        # Cleanup backup after successful replace
        if os.path.exists(backup_path):
            try:
                os.remove(backup_path)
            except OSError:
                pass

        return True

    except Exception as e:
        print(f"Error saving checkpoint: {e}")

        if os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except OSError:
                pass

        if os.path.exists(backup_path) and not os.path.exists(checkpoint_path):
            try:
                os.replace(backup_path, checkpoint_path)
            except OSError:
                pass

        return False

def run_SLM(prompt: str) -> str:
    try:
        checkpoint_path = (
            "/u/mjha1/Proof2Silicon/journal_phase/checkpoints_3/run_CHK/final_model_new.pt" #HERE_FOR_CHANGE
        )
        model, tok = initialize_slm(checkpoint_path)
        print("Model config hidden size:", getattr(model.config, "hidden_size", "N/A"))
        print("Model embedding size:", model.get_input_embeddings().weight.shape)
        generation_config = {
            "max_new_tokens": 128,
            "do_sample": False,
            "num_beams": 1,
            "pad_token_id": tok.pad_token_id,
            "eos_token_id": tok.eos_token_id,
            "repetition_penalty": 1.0,
            "no_repeat_ngram_size": 0,
            "max_length": 640,
            "min_length": 10,
            "length_penalty": 1.0,
        }
        with torch.cuda.amp.autocast():
            inputs = tok(
                prompt,
                return_tensors="pt",
                truncation=True,
                padding=False,
                max_length=512,
            ).to(device)
            print("Input IDs shape:", inputs["input_ids"].shape)
            model.eval()
            if hasattr(model, "gradient_checkpointing_disable"):
                model.gradient_checkpointing_disable()
            with torch.no_grad():
                if inputs["input_ids"].shape[1] > 512:
                    inputs = {k: v[:, :512] for k, v in inputs.items()}
                out = model.generate(**inputs, **generation_config)
            if hasattr(model, "gradient_checkpointing_enable"):
                model.gradient_checkpointing_enable()
            model.train()
            prompt_len = inputs["input_ids"].shape[1]
            generated_only= out[0][prompt_len:]
            response = tok.decode(generated_only, skip_special_tokens=True).strip()
        save_dir = "/u/mjha1/Proof2Silicon/journal_phase/prompts/slm_new_3" #HERE_FOR_CHANGE
        os.makedirs(save_dir, exist_ok=True)
        timestamp = time.strftime("%Y%m%d_%H%M%S")
        with open(
            os.path.join(save_dir, f"slm_interaction_{timestamp}.json"), "w"
        ) as f:
            json.dump(
                {"timestamp": timestamp, "prompt": prompt, "response": response},
                f,
                indent=2,
            )
        return response
    except Exception as e:
        logging.error(f"Error in run_SLM: {str(e)}")
        return ""
    finally:
        if "model" in locals():
            model.train()

def collect_rollout_for_env(env, slm_pg, tokenizer, training_epoch: int):
    prompt_text = env.build_state_prompt()

    (
        instruction_text,
        old_logprob,
        old_value,
        generated_ids,
        _token_count,
        entropy,
    ) = generate_instruction_sequence(slm_pg, tokenizer, prompt_text)

    prompt_ids = tokenizer(
        prompt_text,
        return_tensors="pt",
        truncation=True,
        padding=False,
        max_length=MAX_PROMPT_TOKENS,
    )["input_ids"].to(device)

    if not instruction_text:
        instruction_text = (
            "Write concise verifier-friendly Dafny code that matches the task exactly. "
            "Include only necessary invariants, specifications, and termination reasoning."
        )
        generated_ids = tokenizer(
            instruction_text,
            return_tensors="pt",
            truncation=True,
            max_length=MAX_NEW_TOKENS,
            add_special_tokens=False,
        )["input_ids"].to(device)
        old_logprob, old_value, entropy = compute_sequence_logprob_and_value(
            slm_pg,
            prompt_ids,
            generated_ids,
        )

    reward, done, info = env.step(
        instruction_text=instruction_text,
        state_prompt=prompt_text,
        kl_value=0.0,
        training_epoch=training_epoch,
    )

    sample = RolloutSample(
        prompt_text=prompt_text,
        prompt_ids=prompt_ids.detach(),
        generated_ids=generated_ids.detach(),
        instruction_text=instruction_text,
        old_logprob=old_logprob.detach(),
        old_value=old_value.detach(),
        reward=float(reward),
        entropy=float(entropy.detach().item()) if isinstance(entropy, torch.Tensor) else float(entropy),
        episode_id=episode_idx,
    )

    return sample, done, info

def finalize_rollouts(
    rollouts: List[RolloutSample],
    gamma: float = 0.99,
    reward_clip: float = 10.0,
) -> List[RolloutSample]:
    """
    Compute discounted returns and GAE-style advantages per episode,
    then write them back into each RolloutSample before PPO reads them.

    Episodes are identified by episode_id. Within each episode the samples
    are assumed to be in step order (which is guaranteed by how extend() builds
    epoch_rollouts).
    """
    from collections import defaultdict

    # Group samples by episode, preserving step order
    episodes: dict[int, List[int]] = defaultdict(list)
    for idx, r in enumerate(rollouts):
        episodes[r.episode_id].append(idx)

    for ep_indices in episodes.values():
        ep_samples = [rollouts[i] for i in ep_indices]

        # Clip rewards to prevent exploding returns
        clipped_rewards = [
            max(-reward_clip, min(reward_clip, s.reward)) for s in ep_samples
        ]

        # Discounted return: G_t = r_t + gamma * r_{t+1} + gamma^2 * r_{t+2} + ...
        G = 0.0
        returns = []
        for r in reversed(clipped_rewards):
            G = r + gamma * G
            returns.append(G)
        returns = list(reversed(returns))  # back to forward order

        # Advantage = return - baseline(value)
        advantages = [
            returns[t] - ep_samples[t].old_value.item()
            for t in range(len(ep_samples))
        ]

        # Write back into the original rollout list
        for t, idx in enumerate(ep_indices):
            rollouts[idx].return_ = returns[t]
            rollouts[idx].advantage = advantages[t]

    return rollouts


def ppo_update_sequence_level(
    slm_pg,
    optimizer,
    rollouts: List[RolloutSample],
    clip_eps: float = 0.2,
    value_coef: float = 0.5,
    entropy_coef: float = 0.01,
    num_update_epochs: int = 4,
):
    slm_pg.train()

    advantages = torch.tensor(
        [r.advantage for r in rollouts],
        dtype=torch.float32,
        device=device,
    )
    returns = torch.tensor(
        [r.return_ for r in rollouts],
        dtype=torch.float32,
        device=device,
    )
    old_logprobs = torch.stack([r.old_logprob for r in rollouts]).to(device)
    old_values = torch.stack([r.old_value for r in rollouts]).to(device)

    if len(advantages) > 1:
        advantages = (advantages - advantages.mean()) / (
            advantages.std(unbiased=False) + 1e-8
        )

    stats = {
        "policy_loss": 0.0,
        "value_loss": 0.0,
        "entropy": 0.0,
        "total_loss": 0.0,
        "approx_kl": 0.0,
    }
    steps = 0

    for _ in range(num_update_epochs):
        for i, r in enumerate(rollouts):
            new_logprob, new_value, entropy = compute_sequence_logprob_and_value(
                slm_pg,
                r.prompt_ids.to(device),
                r.generated_ids.to(device),
            )

            new_value = new_value.squeeze()
            ratio = torch.exp(new_logprob - old_logprobs[i])

            unclipped = ratio * advantages[i]
            clipped = torch.clamp(ratio, 1.0 - clip_eps, 1.0 + clip_eps) * advantages[i]
            policy_loss = -torch.min(unclipped, clipped)

            value_pred_clipped = old_values[i] + torch.clamp(
                new_value - old_values[i],
                -clip_eps,
                clip_eps,
            )
            value_loss_unclipped = (new_value - returns[i]) ** 2
            value_loss_clipped = (value_pred_clipped - returns[i]) ** 2
            value_loss = 0.5 * torch.max(value_loss_unclipped, value_loss_clipped)

            total_loss = policy_loss + value_coef * value_loss - entropy_coef * entropy

            optimizer.zero_grad()
            total_loss.backward()
            torch.nn.utils.clip_grad_norm_(slm_pg.parameters(), 1.0)
            optimizer.step()

            approx_kl = (old_logprobs[i] - new_logprob).abs()

            stats["policy_loss"] += float(policy_loss.item())
            stats["value_loss"] += float(value_loss.item())
            stats["entropy"] += float(entropy.item())
            stats["total_loss"] += float(total_loss.item())
            stats["approx_kl"] += float(approx_kl.item())
            steps += 1

    if steps > 0:
        for k in stats:
            stats[k] /= steps

    return stats


#HERE_FOR_CHANGE
def train_slm_with_grpo(
    subfolders,
    slm,
    global_tokenizer,
    num_epochs: int = 10,
    learning_rate: float = 1e-5,
    gamma: float = 0.99,
    epsilon: float = 0.2,
    checkpoint_path: str = "/u/mjha1/Proof2Silicon/journal_phase/checkpoints_3/run_CHK/final_model_new.pt",
    start_epoch: int = 0,
):
    """
    Sequence-level PPO training loop.

    Logging policy:
    - step/*     : every environment step inside an episode
    - episode/*  : one completed trajectory / subfolder rollout
    - epoch/*    : summary across all episodes in the epoch

    This keeps the observability style from the earlier GRPO-style loop,
    while using the newer sequence-level PPO update path.
    """
    logging.info("Starting sequence-level PPO training.")

    if wandb.run is None:
        wandb.init(
            project="Proof2Silicon-journal_phase_CODEBASE",
            entity="drprofmjha-university-of-illinois-urbana-champaign",
            name="Proof2Silicon-journal_phase_CODEBASE",
            resume="allow",
            settings=wandb.Settings(init_timeout=800),
        )

    wandb_enabled = wandb.run is not None

    metrics_tracker = get_metrics_tracker()
    if metrics_tracker is None or metrics_tracker.save_dir != METRICS_DIR:
        metrics_tracker = MetricsTracker(METRICS_DIR)
        set_metrics_tracker(metrics_tracker)

    def save_metric_plots_to_fixed_dir():
        metrics_tracker = get_metrics_tracker()
        if metrics_tracker is None:
            return
        metrics_tracker.plot_learning_curves()
        metrics_tracker.save_metrics()
    # --------------------------------------------------
    # Model / optimizer
    # --------------------------------------------------
    slm_pg = SLMPG(slm).to(device)
    optimizer = Adam(slm_pg.parameters(), lr=learning_rate)

    total_rewards: List[float] = []
    successful_examples: List[Any] = []
    processed_samples: Set[str] = set()

    # --------------------------------------------------
    # Resume from checkpoint if present
    # --------------------------------------------------
    if checkpoint_path and os.path.exists(checkpoint_path):
        checkpoint, loaded_rewards, loaded_examples, loaded_samples = load_checkpoint(
            checkpoint_path, slm_pg, optimizer
        )
        if checkpoint:
            total_rewards = loaded_rewards
            successful_examples = loaded_examples
            processed_samples = loaded_samples
            logging.info(f"Loaded checkpoint. Resuming from epoch {start_epoch}")

    run_dir = os.path.join(CHECKPOINT_DIR, "run_CHK")
    os.makedirs(run_dir, exist_ok=True)

    # Global step counter for step-wise W&B curves
    global_step_idx = 0

    # --------------------------------------------------
    # Epoch loop
    # --------------------------------------------------
    for epoch in range(start_epoch, num_epochs):
        epoch_start_time = time.time()
        logging.info(f"\nStarting Epoch {epoch + 1}/{num_epochs}")

        epoch_rollouts: List[RolloutSample] = []
        epoch_reward_sum = 0.0
        epoch_successes = 0

        # For epoch-level summary stats
        epoch_policy_losses: List[float] = []
        epoch_value_losses: List[float] = []
        epoch_total_losses: List[float] = []
        epoch_entropies: List[float] = []
        epoch_kls: List[float] = []

        epoch_step_count = 0
        epoch_step_successes = 0

        epoch_outcome_rewards: List[float] = []
        epoch_progress_rewards: List[float] = []
        epoch_structure_rewards: List[float] = []
        epoch_efficiency_rewards: List[float] = []
        epoch_stability_rewards: List[float] = []

        # --------------------------------------------------
        # Episode / subfolder loop
        # --------------------------------------------------
        for episode_idx, item in enumerate(subfolders):
            entry = item["entry"]
            subfolder_path = item["subfolder_path"]
            description_file = item["description_file"]

            logging.info(
                f"Processing episode {episode_idx + 1}/{len(subfolders)} for subfolder {entry}"
            )

            sample_id = f"{subfolder_path}_{epoch}"
            if sample_id in processed_samples:
                logging.info(f"Skipping already processed episode: {sample_id}")
                continue

            try:
                with open(description_file, "r", encoding="utf-8") as f:
                    task_prompt = f.read().strip()

                tmp_path = os.path.join(subfolder_path, "tmp_generated.dfy")
                error_path = os.path.join(subfolder_path, "dafny_error.txt")

                env = DafnyEnv(
                    prompt=task_prompt,
                    tmp_path=tmp_path,
                    error_path=error_path,
                )
                env.reset()

                done = False
                episode_reward = 0.0
                episode_rollout_samples: List[RolloutSample] = []

                # Logging-only tensors/statistics for episode summary
                episode_values: List[torch.Tensor] = []
                episode_log_probs: List[torch.Tensor] = []
                episode_rewards: List[float] = []
                episode_step_success_count = 0

                # --------------------------------------------------
                # Step loop inside one env rollout
                # --------------------------------------------------
                while not done:
                    state_prompt = env.build_state_prompt()

                    (
                        instruction_text,
                        old_logprob,
                        old_value,
                        generated_ids,
                        generated_token_count,
                        entropy,
                    ) = generate_instruction_sequence(
                        slm_pg,
                        global_tokenizer,
                        state_prompt,
                        max_new_tokens=MAX_NEW_TOKENS,
                    )

                    prompt_ids = global_tokenizer(
                        state_prompt,
                        return_tensors="pt",
                        truncation=True,
                        padding=False,
                        max_length=MAX_PROMPT_TOKENS,
                    )["input_ids"].to(device)

                    # Fallback if generation failed schema checks
                    if not instruction_text:
                        logging.warning(
                            "Invalid or empty instruction generated for %s. Using fallback instruction.",
                            entry,
                        )
                        instruction_text = (
                            "Write concise verifier-friendly Dafny code that matches the task exactly. "
                            "Include only necessary invariants, specifications, and termination reasoning."
                        )
                        generated_ids = global_tokenizer(
                            instruction_text,
                            return_tensors="pt",
                            truncation=True,
                            max_length=MAX_NEW_TOKENS,
                            add_special_tokens=False,
                        )["input_ids"].to(device)
                        old_logprob, old_value, entropy = compute_sequence_logprob_and_value(
                            slm_pg,
                            prompt_ids,
                            generated_ids,
                        )

                    # prompt_token_increase = int(generated_ids.shape[1])
                    prompt_token_increase = int(generated_token_count)
                    kl_value = 0.0  # kept for compatibility with existing metrics/logging

                    reward, done, info = env.step(
                        instruction_text=instruction_text,
                        state_prompt=state_prompt,
                        kl_value=kl_value,
                        training_epoch=epoch,
                    )

                    global_step_idx += 1
                    epoch_step_count += 1

                    is_successful_step = info.get("successful_examples_count", 0) > 0
                    if is_successful_step:
                        epoch_step_successes += 1
                        episode_step_success_count += 1

                    # NaN / finite checks for safe PPO bookkeeping
                    value_ok = torch.isfinite(old_value).all().item()
                    logprob_ok = torch.isfinite(old_logprob).all().item()
                    reward_ok = isinstance(reward, (int, float)) and not (reward != reward)

                    if value_ok and logprob_ok and reward_ok:
                        sample = RolloutSample(
                            prompt_text=state_prompt,
                            prompt_ids=prompt_ids.detach(),
                            generated_ids=generated_ids.detach(),
                            instruction_text=instruction_text,
                            old_logprob=old_logprob.detach(),
                            old_value=old_value.detach(),
                            reward=float(reward),
                            entropy=float(entropy.detach().item()) if isinstance(entropy, torch.Tensor) else float(entropy),
                        )
                        episode_rollout_samples.append(sample)

                        episode_values.append(old_value.detach())
                        episode_log_probs.append(old_logprob.detach())
                        episode_rewards.append(float(reward))
                        episode_reward += float(reward)
                    else:
                        logging.warning(
                            "Skipping invalid step for %s | value_ok=%s logprob_ok=%s reward_ok=%s",
                            entry,
                            value_ok,
                            logprob_ok,
                            reward_ok,
                        )

                    reward_breakdown = info.get("reward_breakdown", {})
                    curr_error_counts = info.get("curr_error_counts", {})
                    curr_structure = info.get("curr_structure", {})

                    epoch_outcome_rewards.append(reward_breakdown.get("outcome_reward", 0.0))
                    epoch_progress_rewards.append(reward_breakdown.get("progress_reward", 0.0))
                    epoch_structure_rewards.append(reward_breakdown.get("structure_reward", 0.0))
                    epoch_efficiency_rewards.append(reward_breakdown.get("efficiency_reward", 0.0))
                    epoch_stability_rewards.append(reward_breakdown.get("stability_reward", 0.0))

                    # --------------------------------------------------
                    # Step-wise local metrics tracker updates
                    # --------------------------------------------------
                    metrics_tracker.update_rl_metrics(
                        reward=float(reward),
                        success=bool(is_successful_step),
                        error_count=sum(curr_error_counts.values()) if isinstance(curr_error_counts, dict) else 0,
                        iterations=int(info.get("iterations", env.current_iteration)),
                    )
                    metrics_tracker.update_reward_breakdown(
                        reward_breakdown=reward_breakdown,
                        prompt_token_increase=prompt_token_increase,
                        kl_value=kl_value,
                    )

                    # Optional error analysis logging into tracker
                    if isinstance(curr_error_counts, dict):
                        dominant_error = "none"
                        if len(curr_error_counts) > 0:
                            dominant_error = max(curr_error_counts, key=curr_error_counts.get)
                        metrics_tracker.update_error_analysis(
                            error_type=dominant_error,
                            verification_success=bool(is_successful_step),
                            proof_obligations=int(sum(curr_error_counts.values())),
                        )

                    # --------------------------------------------------
                    # Step-wise W&B logging
                    # --------------------------------------------------
                    if wandb_enabled:
                        wandb.log(
                            {
                                "step/global_index": global_step_idx,
                                "step/epoch": epoch + 1,
                                "step/episode_index_within_epoch": episode_idx + 1,
                                "step/subfolder": entry,
                                "step/reward_total": float(reward),
                                "step/value": float(old_value.item()) if torch.is_tensor(old_value) else float(old_value),
                                "step/log_prob": float(old_logprob.item()) if torch.is_tensor(old_logprob) else float(old_logprob),
                                "step/entropy": float(entropy.item()) if torch.is_tensor(entropy) else float(entropy),
                                "step/token_increase": prompt_token_increase,
                                "step/kl_value": float(kl_value),
                                "step/success": int(bool(is_successful_step)),
                                "step/iteration": int(info.get("iterations", env.current_iteration)),
                                "step/error_count_total": int(sum(curr_error_counts.values())) if isinstance(curr_error_counts, dict) else 0,
                                "step/parse_errors": int(info.get("parse_errors", 0)),
                                "step/reward_outcome": float(reward_breakdown.get("outcome_reward", 0.0)),
                                "step/reward_progress": float(reward_breakdown.get("progress_reward", 0.0)),
                                "step/reward_structure": float(reward_breakdown.get("structure_reward", 0.0)),
                                "step/reward_efficiency": float(reward_breakdown.get("efficiency_reward", 0.0)),
                                "step/reward_stability": float(reward_breakdown.get("stability_reward", 0.0)),
                                "step/error_syntax": int(curr_error_counts.get("syntax", 0)) if isinstance(curr_error_counts, dict) else 0,
                                "step/error_type": int(curr_error_counts.get("type", 0)) if isinstance(curr_error_counts, dict) else 0,
                                "step/error_missing_invariant": int(curr_error_counts.get("missing_invariant", 0)) if isinstance(curr_error_counts, dict) else 0,
                                "step/error_postcondition": int(curr_error_counts.get("postcondition", 0)) if isinstance(curr_error_counts, dict) else 0,
                                "step/error_timeout": int(curr_error_counts.get("timeout", 0)) if isinstance(curr_error_counts, dict) else 0,
                                "step/structure_lemma_count": int(curr_structure.get("lemma_count", 0)) if isinstance(curr_structure, dict) else 0,
                                "step/structure_recursion_count": int(curr_structure.get("recursion_count", 0)) if isinstance(curr_structure, dict) else 0,
                                "step/structure_invariant_count": int(curr_structure.get("invariant_count", 0)) if isinstance(curr_structure, dict) else 0,
                                "step/structure_ghost_var_count": int(curr_structure.get("ghost_var_count", 0)) if isinstance(curr_structure, dict) else 0,
                            }
                        )

                    logging.info(
                        "Step metrics - Reward: %s, Value: %s, Log Prob: %s, Token Increase: %s, KL: %s, Success: %s",
                        reward,
                        float(old_value.item()) if torch.is_tensor(old_value) else old_value,
                        float(old_logprob.item()) if torch.is_tensor(old_logprob) else old_logprob,
                        prompt_token_increase,
                        kl_value,
                        is_successful_step,
                    )
                    logging.info(
                        "Reward breakdown: %s | Error counts: %s | Structure: %s",
                        reward_breakdown,
                        curr_error_counts,
                        curr_structure,
                    )

                # End step loop
                processed_samples.add(sample_id)

                if len(episode_rollout_samples) == 0:
                    logging.warning(
                        "Episode %s/%s (%s) produced no valid trajectory.",
                        episode_idx + 1,
                        len(subfolders),
                        entry,
                    )
                    continue
                
                # --------------------------------------------------
                # Episode aggregates
                # (returns/advantages are computed in finalize_rollouts
                #  after all episodes are collected — read them back for logging)
                # --------------------------------------------------
                epoch_rollouts.extend(episode_rollout_samples)
                epoch_reward_sum += episode_reward

                if info.get("successful_examples_count", 0) > 0 or info.get("outcome") == "success":
                    epoch_successes += 1

                if "successful_examples" in info and isinstance(info["successful_examples"], list):
                    successful_examples.extend(info["successful_examples"])

                # --------------------------------------------------
                # Episode-wise W&B logging
                # returns_t / advantages_t are read from the samples
                # that finalize_rollouts will fill in — but finalize
                # hasn't run yet at this point (it runs after all
                # episodes). So we log raw episode stats here; the
                # PPO-level logging after finalize covers the rest.
                # --------------------------------------------------
                if wandb_enabled:
                    episode_log = {
                        "episode/epoch": epoch + 1,
                        "episode/index_within_epoch": episode_idx + 1,
                        "episode/subfolder": entry,
                        "episode/reward_total": float(episode_reward),
                        "episode/trajectory_length": len(episode_rollout_samples),
                        "episode/successful_examples_count": len(env.successful_examples),
                        "episode/final_iteration": env.current_iteration,
                        "episode/step_success_count": episode_step_success_count,
                        # mean raw reward across steps — the discounted
                        # return will appear in epoch/mean_return after PPO
                        "episode/mean_raw_reward": (
                            float(episode_reward / len(episode_rollout_samples))
                            if episode_rollout_samples else 0.0
                        ),
                    }
                    wandb.log(episode_log)

                logging.info(
                    "Episode %s/%s (%s) finished | reward=%s | trajectory_len=%s | successes=%s",
                    episode_idx + 1,
                    len(subfolders),
                    entry,
                    episode_reward,
                    len(episode_rollout_samples),
                    len(env.successful_examples),
                )
                # # --------------------------------------------------
                # # Episode-level returns/advantages for logging
                # # --------------------------------------------------
                # returns_t = None
                # advantages_t = None
                # policy_loss = None
                # value_loss = None
                # total_loss = None

                # clipped_rewards = [max(-10.0, min(10.0, float(r))) for r in episode_rewards]
                # returns = []
                # R = 0.0
                # for r in reversed(clipped_rewards):
                #     R = float(r) + gamma * R
                #     returns.append(R)
                # returns = list(reversed(returns))

                # returns_t = torch.tensor(returns, device=device, dtype=torch.float32)
                # values_t = torch.stack(episode_values).float()
                # log_probs_t = torch.stack(episode_log_probs).float()

                # if (
                #     torch.isfinite(returns_t).all()
                #     and torch.isfinite(values_t).all()
                #     and torch.isfinite(log_probs_t).all()
                # ):
                #     advantages_t = returns_t - values_t.detach()
                #     if len(advantages_t) > 1:
                #         adv_std = advantages_t.std(unbiased=False)
                #         if torch.isfinite(adv_std) and adv_std.item() > 1e-8:
                #             advantages_t = (advantages_t - advantages_t.mean()) / (adv_std + 1e-8)
                #         else:
                #             advantages_t = advantages_t - advantages_t.mean()
                #     else:
                #         advantages_t = advantages_t - advantages_t.mean()

                #     # Logging-only losses before PPO update
                #     policy_loss = -(log_probs_t * advantages_t).mean()
                #     value_loss = F.mse_loss(values_t, returns_t)
                #     total_loss = float((policy_loss + value_loss).item())

                # # Episode aggregates
                # epoch_rollouts.extend(episode_rollout_samples)
                # epoch_reward_sum += episode_reward

                # if info.get("successful_examples_count", 0) > 0 or info.get("outcome") == "success":
                #     epoch_successes += 1

                # if "successful_examples" in info and isinstance(info["successful_examples"], list):
                #     successful_examples.extend(info["successful_examples"])

                # # --------------------------------------------------
                # # Episode-wise W&B logging
                # # --------------------------------------------------
                # if wandb_enabled:
                #     episode_log = {
                #         "episode/epoch": epoch + 1,
                #         "episode/index_within_epoch": episode_idx + 1,
                #         "episode/subfolder": entry,
                #         "episode/reward_total": float(episode_reward),
                #         "episode/trajectory_length": len(episode_rollout_samples),
                #         "episode/successful_examples_count": len(env.successful_examples),
                #         "episode/final_iteration": env.current_iteration,
                #         "episode/step_success_count": episode_step_success_count,
                #         "episode/loss_computed": int(
                #             policy_loss is not None and value_loss is not None and total_loss is not None
                #         ),
                #     }

                #     if policy_loss is not None:
                #         episode_log["episode/policy_loss"] = float(policy_loss.item())
                #     if value_loss is not None:
                #         episode_log["episode/value_loss"] = float(value_loss.item())
                #     if total_loss is not None:
                #         episode_log["episode/total_loss"] = float(total_loss)
                #     if returns_t is not None:
                #         episode_log["episode/mean_return"] = float(returns_t.mean().item())
                #     if advantages_t is not None:
                #         episode_log["episode/mean_advantage"] = float(advantages_t.mean().item())

                #     wandb.log(episode_log)

                # logging.info(
                #     "Episode %s/%s (%s) finished | reward=%s | trajectory_len=%s | successes=%s",
                #     episode_idx + 1,
                #     len(subfolders),
                #     entry,
                #     episode_reward,
                #     len(episode_rollout_samples),
                #     len(env.successful_examples),
                # )

            except Exception as e:
                logging.exception(f"Failed on subfolder {entry}: {e}")
                continue

        # --------------------------------------------------
        # PPO update after collecting all episode rollouts in the epoch
        # --------------------------------------------------
        if not epoch_rollouts:
            logging.warning(f"No rollouts collected for epoch {epoch}")
            continue

        epoch_rollouts = finalize_rollouts(epoch_rollouts, gamma=gamma)

        ppo_stats = ppo_update_sequence_level(
            slm_pg=slm_pg,
            optimizer=optimizer,
            rollouts=epoch_rollouts,
            clip_eps=epsilon,
            value_coef=0.5,
            entropy_coef=0.01,
            num_update_epochs=4,
        )

        epoch_policy_losses.append(ppo_stats["policy_loss"])
        epoch_value_losses.append(ppo_stats["value_loss"])
        epoch_total_losses.append(ppo_stats["total_loss"])
        epoch_entropies.append(ppo_stats["entropy"])
        epoch_kls.append(ppo_stats["approx_kl"])

        avg_reward = epoch_reward_sum / max(len(epoch_rollouts), 1)
        success_rate = epoch_successes / max(len(subfolders), 1)
        step_success_rate = epoch_step_successes / max(epoch_step_count, 1)

        total_rewards.append(avg_reward)

        avg_outcome_reward = (
            sum(epoch_outcome_rewards) / len(epoch_outcome_rewards) if epoch_outcome_rewards else 0.0
        )
        avg_progress_reward = (
            sum(epoch_progress_rewards) / len(epoch_progress_rewards) if epoch_progress_rewards else 0.0
        )
        avg_structure_reward = (
            sum(epoch_structure_rewards) / len(epoch_structure_rewards) if epoch_structure_rewards else 0.0
        )
        avg_efficiency_reward = (
            sum(epoch_efficiency_rewards) / len(epoch_efficiency_rewards) if epoch_efficiency_rewards else 0.0
        )
        avg_stability_reward = (
            sum(epoch_stability_rewards) / len(epoch_stability_rewards) if epoch_stability_rewards else 0.0
        )

        # --------------------------------------------------
        # Epoch-level tracker updates
        # --------------------------------------------------
        metrics_tracker.update_epoch_metrics(
            avg_reward=avg_reward,
            training_loss=ppo_stats["total_loss"],
            avg_outcome_reward=avg_outcome_reward,
            avg_progress_reward=avg_progress_reward,
            avg_structure_reward=avg_structure_reward,
            avg_efficiency_reward=avg_efficiency_reward,
            avg_stability_reward=avg_stability_reward,
            avg_policy_loss=ppo_stats["policy_loss"],
            avg_value_loss=ppo_stats["value_loss"],
            epoch_success_rate=success_rate,
        )

        # --------------------------------------------------
        # Epoch-wise W&B logging
        # --------------------------------------------------
        if wandb_enabled:
            wandb.log(
                {
                    "epoch": epoch + 1,
                    "epoch/avg_reward": float(avg_reward),
                    "epoch/success_rate": float(success_rate),
                    "epoch/step_success_rate": float(step_success_rate),
                    "epoch/policy_loss": float(ppo_stats["policy_loss"]),
                    "epoch/value_loss": float(ppo_stats["value_loss"]),
                    "epoch/entropy": float(ppo_stats["entropy"]),
                    "epoch/approx_kl": float(ppo_stats["approx_kl"]),
                    "epoch/total_loss": float(ppo_stats["total_loss"]),
                    "epoch/avg_outcome_reward": float(avg_outcome_reward),
                    "epoch/avg_progress_reward": float(avg_progress_reward),
                    "epoch/avg_structure_reward": float(avg_structure_reward),
                    "epoch/avg_efficiency_reward": float(avg_efficiency_reward),
                    "epoch/avg_stability_reward": float(avg_stability_reward),
                    "epoch/num_rollouts": len(epoch_rollouts),
                    "epoch/num_subfolders": len(subfolders),
                    "epoch/step_count": int(epoch_step_count),
                    "epoch/duration_sec": float(time.time() - epoch_start_time),
                }
            )

        logging.info(
            "Epoch %s summary | avg_reward=%.4f | success_rate=%.4f | step_success_rate=%.4f | "
            "policy_loss=%.4f | value_loss=%.4f | total_loss=%.4f",
            epoch + 1,
            avg_reward,
            success_rate,
            step_success_rate,
            ppo_stats["policy_loss"],
            ppo_stats["value_loss"],
            ppo_stats["total_loss"],
        )

        # --------------------------------------------------
        # Checkpointing
        # --------------------------------------------------
        checkpoint_path_epoch = os.path.join(run_dir, f"checkpoint_epoch_{epoch + 1}.pt")
        checkpoint_data_epoch = {
            "epoch": epoch,
            "model_state_dict": slm_pg.state_dict(),
            "optimizer_state_dict": optimizer.state_dict(),
            "rewards": total_rewards,
            "successful_examples": successful_examples,
            "processed_samples": processed_samples,
        }

        if not save_checkpoint_safely(checkpoint_data_epoch, checkpoint_path_epoch):
            logging.warning(f"Failed to save checkpoint for epoch {epoch + 1}")

        save_checkpoint_safely(checkpoint_data_epoch, checkpoint_path)
        torch.cuda.empty_cache()

    # --------------------------------------------------
    # Final save
    # --------------------------------------------------
    final_model_path = os.path.join(run_dir, "final_model_new.pt")
    final_lora_path = os.path.join(run_dir, "final_lora")

    checkpoint_data = {
        "epoch": num_epochs - 1,
        "model_state_dict": slm_pg.state_dict(),
        "optimizer_state_dict": optimizer.state_dict(),
        "rewards": total_rewards,
        "successful_examples": successful_examples,
        "processed_samples": processed_samples,
    }

    if not save_checkpoint_safely(checkpoint_data, final_model_path):
        logging.error("Failed to save final model checkpoint!")

    if hasattr(slm_pg.model, "save_pretrained"):
        try:
            slm_pg.model.save_pretrained(final_lora_path)
            logging.info("Successfully saved LoRA weights")
        except Exception as e:
            logging.error(f"Failed to save LoRA weights: {str(e)}")

    metrics_tracker = get_metrics_tracker()
    if metrics_tracker is not None:
        metrics_tracker.plot_learning_curves()
        metrics_tracker.save_metrics()

        for plot_name in [
            "episode_rewards",
            "cumulative_rewards",
            "success_rate",
            "training_loss",
            "avg_reward_per_epoch",
            "policy_loss_per_epoch",
            "value_loss_per_epoch",
            "success_rate_per_epoch",
        ]:
            matching_files = [
                f
                for f in os.listdir(metrics_tracker.save_dir)
                if f.startswith(plot_name) and f.endswith(".png")
            ]
            if matching_files:
                latest_file = sorted(matching_files)[-1]
                plot_path = os.path.join(metrics_tracker.save_dir, latest_file)
                if wandb_enabled:
                    wandb.log({plot_name: wandb.Image(plot_path)})

    return total_rewards, successful_examples