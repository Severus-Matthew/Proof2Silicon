import json
import logging
import os
import time
import zipfile
from typing import Any, Dict, List, Set, Tuple

import torch
import torch.nn as nn
import torch.nn.functional as F
import wandb
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

from .metrics import get_metrics_tracker

# # GPU / CUDA setup and constants previously at top-level
# torch.cuda.set_per_process_memory_fraction(0.8, device=0)
# os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "max_split_size_mb:128,expandable_segments:True"
# device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
# logging.info(f"Using device: {device}")
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

CHECKPOINT_DIR = "/mnt/shared/gpfs/home/manvij2/journal_phase/checkpoints"
LORA_ADAPTER_DIR = (
    "/mnt/shared/gpfs/home/manvij2/journal_phase/lora_adapters"
)

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

    # Set memory management environment variables
    # os.environ["PYTORCH_CUDA_ALLOC_CONF"] = (
    #     "max_split_size_mb:128,expandable_segments:True"
    # )
    # torch.cuda.empty_cache()

    # Force single GPU usage
    # os.environ["CUDA_VISIBLE_DEVICES"] = "0"
    local_device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    # global_model.config.use_cache = False
    # global_model.gradient_checkpointing_enable()
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
        offload_folder = "/mnt/shared/gpfs/home/manvij2/journal_phase/model_offload"
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
            nn.Linear(hidden_size, hidden_size, dtype=torch.float16),
            nn.ReLU(),
            nn.Linear(hidden_size, 1, dtype=torch.float16),
        )

    def forward(self, input_ids, attention_mask=None):
        outputs = self.model(
            input_ids=input_ids,
            attention_mask=attention_mask,
            output_hidden_states=True,
            return_dict=True,
        )
        logits = outputs.logits  # [B, T, V]
        last_hidden = outputs.hidden_states[-1][:, -1, :].to(device=device, dtype=torch.float16)
        values = self.value_head(last_hidden).squeeze(-1).to(device=device, dtype=torch.float16)
        return logits, values


MAX_PROMPT_TOKENS = 2048   # hard cap on input prompt tokens fed to SLM
MAX_NEW_TOKENS    = 2048    # tokens the SLM is allowed to generate
MAX_SEQ_LEN       = MAX_PROMPT_TOKENS + MAX_NEW_TOKENS  # 1280 total

def generate_instruction_with_logprobs(slm_pg, tokenizer, prompt_text, max_new_tokens=MAX_NEW_TOKENS, temperature=1.0):
    slm_pg.eval()
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

    generated_tokens = []
    log_probs = []
    step_distributions = []

    with torch.no_grad():
        _, state_value = slm_pg(input_ids=input_ids, attention_mask=attention_mask)

        for _ in range(max_new_tokens):
            logits, _ = slm_pg(input_ids=input_ids, attention_mask=attention_mask)
            next_token_logits = logits[:, -1, :] / temperature

            probs = F.softmax(next_token_logits, dim=-1).float()
            probs = (probs + 1e-10)
            probs = probs / probs.sum(dim=-1, keepdim=True)

            step_distributions.append(probs.detach().cpu())

            dist = Categorical(probs)
            next_token = dist.sample()
            next_log_prob = dist.log_prob(next_token)

            generated_tokens.append(next_token.detach().cpu())
            log_probs.append(next_log_prob.detach().cpu())

            next_token_expanded = next_token.unsqueeze(1)
            input_ids = torch.cat([input_ids, next_token_expanded], dim=1)
            attention_mask = torch.cat([
                attention_mask,
                torch.ones((attention_mask.size(0), 1), device=device, dtype=attention_mask.dtype)
            ], dim=1)

            if next_token.item() == tokenizer.eos_token_id:
                break
            # Stop if we've generated enough new tokens (don't cap on total length)
            if len(generated_tokens) >= max_new_tokens:
                break

    if len(generated_tokens) == 0:
        logging.warning(
            "SLM generated 0 tokens for prompt of %d tokens (max_prompt=%d, max_new=%d)",
            prompt_len, MAX_PROMPT_TOKENS, max_new_tokens,
        )
        slm_pg.train()
        return "", None, None, None, 0, []

    generated_ids = torch.stack(generated_tokens, dim=1)
    instruction_text = tokenizer.decode(generated_ids[0], skip_special_tokens=False)

    logging.debug(
        "SLM generated %d tokens from %d prompt tokens. Instruction preview: %s",
        generated_ids.shape[1], prompt_len, instruction_text[:120],
    )

    # Recompute log_probs WITH grad only once on the full sequence (not per-step)
    slm_pg.train()
    seq_log_prob, value = recompute_logprobs_for_sequence(
        slm_pg, inputs["input_ids"].to(device), generated_ids.to(device), attention_mask
    )

    token_count = generated_ids.shape[1]
    _save_slm_interaction(prompt_text, instruction_text)
    return instruction_text, seq_log_prob, value.squeeze(), generated_ids, token_count, step_distributions

def _save_slm_interaction(prompt: str, response: str) -> None:
    """Save SLM prompt and generated instruction to disk for inspection."""
    save_dir = "/mnt/shared/gpfs/home/manvij2/journal_phase/prompts/slm_new"
    os.makedirs(save_dir, exist_ok=True)
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    try:
        with open(os.path.join(save_dir, f"slm_interaction_{timestamp}.json"), "w") as f:
            json.dump({"timestamp": timestamp, "prompt": prompt, "response": response}, f, indent=2)
    except Exception as e:
        logging.warning("Could not save SLM interaction to disk: %s", e)


def recompute_logprobs_for_sequence(slm_pg, prompt_ids, generated_ids, full_attention_mask):
    """Single forward pass over full sequence to get log_probs + value for training."""
    full_ids = torch.cat([prompt_ids, generated_ids.to(device)], dim=1)
    # Trim to combined budget (prompt + generation), not old 512 hard-cap
    if full_ids.shape[1] > MAX_SEQ_LEN:
        full_ids = full_ids[:, :MAX_SEQ_LEN]

    attn = torch.ones_like(full_ids)
    logits, value = slm_pg(input_ids=full_ids, attention_mask=attn)

    # Get log probs only over generated portion
    gen_len = generated_ids.shape[1]
    prompt_len = prompt_ids.shape[1]
    shift_logits = logits[:, prompt_len - 1: prompt_len - 1 + gen_len, :]
    shift_labels = generated_ids.to(device)

    log_probs = F.log_softmax(shift_logits, dim=-1)
    token_log_probs = log_probs.gather(2, shift_labels.unsqueeze(-1)).squeeze(-1)
    seq_log_prob = token_log_probs.sum(dim=-1).squeeze()

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
            "/mnt/shared/gpfs/home/manvij2/journal_phase/checkpoints/run_CHK/final_model_new.pt"
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
            "use_cache": False,
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
            with torch.no_grad():
                if inputs["input_ids"].shape[1] > 512:
                    inputs = {k: v[:, :512] for k, v in inputs.items()}
                out = model.generate(**inputs, **generation_config)
            model.train()
            response = tok.decode(out[0], skip_special_tokens=True)
        save_dir = "/mnt/shared/gpfs/home/manvij2/journal_phase/prompts/slm_new"
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


def train_slm_with_grpo( env, slm, global_tokenizer, num_epochs: int = 10, batch_size: int = 1, learning_rate: float = 1e-4, gamma: float = 0.99, epsilon: float = 0.2, checkpoint_path: str = "/mnt/shared/gpfs/home/manvij2/journal_phase/checkpoints/run_CHK/final_model_new.pt", start_epoch: int = 0):   

    logging.info(
        "Starting/Resuming SLM training with sequence-level policy gradient..."
    )
    wandb_enabled = wandb.run is not None

    slm_pg = SLMPG(slm)
    slm_pg.value_head = slm_pg.value_head.to(device)
    actor_params = list(slm_pg.model.parameters())
    critic_params = list(slm_pg.value_head.parameters())

    actor_optimizer = Adam(actor_params, lr=learning_rate)
    critic_optimizer = Adam(critic_params, lr=learning_rate)

    total_rewards: List[float] = []
    successful_examples: List[Any] = []
    processed_samples: Set[str] = set()

    if checkpoint_path and os.path.exists(checkpoint_path):
        checkpoint, loaded_rewards, loaded_examples, loaded_samples = load_checkpoint(
            checkpoint_path, slm_pg, actor_optimizer
        )
        if checkpoint:
            total_rewards = loaded_rewards
            successful_examples = loaded_examples
            processed_samples = loaded_samples
            logging.info(
                f"Successfully loaded checkpoint. Resuming from epoch {start_epoch}"
            )

    run_dir = os.path.join(CHECKPOINT_DIR, "run_CHK")
    os.makedirs(run_dir, exist_ok=True)
    logging.info(f"Created checkpoint directory at: {run_dir}")

    actor_scheduler = ReduceLROnPlateau(
        actor_optimizer, mode="min", factor=0.5, patience=7, verbose=True
    )
    critic_scheduler = ReduceLROnPlateau(
        critic_optimizer, mode="min", factor=0.5, patience=7, verbose=True
    )

    for epoch in range(start_epoch, num_epochs):
        epoch_start_time = time.time()
        logging.info(f"\nStarting Epoch {epoch + 1}/{num_epochs}")

        epoch_rewards: List[float] = []
        epoch_successful: List[Any] = []
        epoch_policy_losses: List[float] = []
        epoch_value_losses: List[float] = []
        epoch_step_successes = 0
        epoch_step_count = 0

        for batch_idx in range(batch_size):
            logging.info(f"Processing batch {batch_idx + 1}/{batch_size}")

            env.reset()
            done = False
            episode_reward = 0.0
            episode_values: List[torch.Tensor] = []
            episode_log_probs: List[torch.Tensor] = []
            episode_rewards: List[float] = []
            episode_states: List[str] = []
            epoch_outcome_rewards: List[float] = []
            epoch_progress_rewards: List[float] = []
            epoch_structure_rewards: List[float] = []
            epoch_efficiency_rewards: List[float] = []
            epoch_stability_rewards: List[float] = []

            prev_generated_token_count = 0
            prev_distributions = None

            sample_id = f"{env.subfolder_path}_{epoch}_{batch_idx}"
            if sample_id in processed_samples:
                logging.info(f"Skipping already processed sample: {sample_id}")
                continue
            torch.cuda.empty_cache()
            while not done:
                state_prompt = env.build_state_prompt()

                (
                    instruction_text,
                    seq_log_prob,
                    value,
                    generated_ids,
                    generated_token_count,
                    current_distributions,
                ) = generate_instruction_with_logprobs(
                    slm_pg,
                    global_tokenizer,
                    state_prompt,
                    max_new_tokens=MAX_NEW_TOKENS,
                    temperature=1.0,
                )

                if not instruction_text or seq_log_prob is None or value is None:
                    logging.warning("Empty instruction generated; ending episode.")
                    break

                prompt_token_increase = max(
                    0, generated_token_count - prev_generated_token_count
                )
                kl_value = compute_mean_kl(current_distributions, prev_distributions)

                reward, done, info = env.step(
                    instruction_text,
                    state_prompt=state_prompt,
                    prompt_token_increase=prompt_token_increase,
                    kl_value=kl_value,
                    training_epoch=epoch,   # <-- pass the real epoch index
                )

                prev_generated_token_count = generated_token_count
                prev_distributions = current_distributions

                epoch_step_count += 1
                is_successful_step = info.get("successful_examples_count", 0) > 0
                if is_successful_step:
                    epoch_step_successes += 1

                if not torch.isnan(value).any() and not torch.isinf(value).any():
                    episode_values.append(value)
                    episode_log_probs.append(seq_log_prob)
                    episode_rewards.append(reward)
                    episode_reward += reward
                    episode_states.append(state_prompt)

                reward_breakdown = info.get("reward_breakdown", {})
                epoch_outcome_rewards.append(reward_breakdown.get("outcome_reward", 0.0))
                epoch_progress_rewards.append(reward_breakdown.get("progress_reward", 0.0))
                epoch_structure_rewards.append(reward_breakdown.get("structure_reward", 0.0))
                epoch_efficiency_rewards.append(reward_breakdown.get("efficiency_reward", 0.0))
                epoch_stability_rewards.append(reward_breakdown.get("stability_reward", 0.0))
                curr_error_counts = info.get("curr_error_counts", {})
                curr_structure = info.get("curr_structure", {})
                parse_errors = info.get("parse_errors", 0)
                if wandb_enabled:
                    wandb.log(
                    {
                        "step/reward_total": reward,
                        "step/value": value.item(),
                        "step/log_prob": seq_log_prob.item(),
                        "step/prompt_token_increase": prompt_token_increase,
                        "step/kl_value": kl_value,
                        "step/is_successful": int(is_successful_step),
                        "step/parse_errors": parse_errors,
                        "step/reward_outcome": reward_breakdown.get(
                            "outcome_reward", 0.0
                        ),
                        "step/reward_progress": reward_breakdown.get(
                            "progress_reward", 0.0
                        ),
                        "step/reward_structure": reward_breakdown.get(
                            "structure_reward", 0.0
                        ),
                        "step/reward_efficiency": reward_breakdown.get(
                            "efficiency_reward", 0.0
                        ),
                        "step/reward_stability": reward_breakdown.get(
                            "stability_reward", 0.0
                        ),
                        "step/error_syntax": curr_error_counts.get("syntax", 0),
                        "step/error_type": curr_error_counts.get("type", 0),
                        "step/error_missing_invariant": curr_error_counts.get(
                            "missing_invariant", 0
                        ),
                        "step/error_postcondition": curr_error_counts.get(
                            "postcondition", 0
                        ),
                        "step/error_timeout": curr_error_counts.get("timeout", 0),
                        "step/lemma_count": curr_structure.get("lemma_count", 0),
                        "step/recursion_count": curr_structure.get(
                            "recursion_count", 0
                        ),
                        "step/invariant_count": curr_structure.get(
                            "invariant_count", 0
                        ),
                        "step/ghost_var_count": curr_structure.get(
                            "ghost_var_count", 0
                        ),
                    }
                )

                logging.info(
                    "Step metrics - Reward: %s, Value: %s, Log Prob: %s, Token Increase: %s, KL: %s, Success: %s",
                    reward,
                    value.item(),
                    seq_log_prob.item(),
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

                if is_successful_step and reward > 0:
                    epoch_successful.append(
                        {
                            "state_prompt": state_prompt,
                            "instruction_text": instruction_text,
                            "reward": reward,
                            "reward_breakdown": reward_breakdown,
                            "llm_response": info.get("llm_response", ""),
                            "dafny_code": info.get("dafny_code", ""),
                            "error_output": info.get("error_output", ""),
                            "curr_error_counts": curr_error_counts,
                            "curr_structure": curr_structure,
                            "prompt_token_increase": prompt_token_increase,
                            "kl_value": kl_value,
                        }
                    )

            processed_samples.add(sample_id)

            if len(episode_values) > 0:
                clipped_rewards = [max(-10, min(10, r)) for r in episode_rewards]

                returns = []
                R = 0.0
                for r in reversed(clipped_rewards):
                    R = r + gamma * R
                    returns.append(R)
                returns = list(reversed(returns))

                returns_t = torch.tensor(returns, device=device, dtype=torch.float32)
                values_t = torch.stack(episode_values).float()
                log_probs_t = torch.stack(episode_log_probs).float()

                advantages_t = returns_t - values_t.detach()
                if len(advantages_t) > 1:
                    advantages_t = (advantages_t - advantages_t.mean()) / (
                        advantages_t.std() + 1e-8
                    )

                policy_loss = -(log_probs_t * advantages_t).mean()
                value_loss = F.mse_loss(values_t, returns_t)
                total_loss_tensor = policy_loss + value_loss

                if not (
                    torch.isnan(policy_loss).any() or torch.isnan(value_loss).any() or torch.isnan(total_loss_tensor).any()
                ):
                    actor_optimizer.zero_grad()
                    critic_optimizer.zero_grad()
                    # policy_loss.backward()
                    total_loss_tensor.backward()
                    torch.nn.utils.clip_grad_norm_(actor_params, max_norm=0.5)
                    torch.nn.utils.clip_grad_norm_(critic_params, max_norm=0.5)
                    actor_optimizer.step()
                    critic_optimizer.zero_grad()
                    total_loss = total_loss_tensor.item()
                    # value_loss.backward()
                    # torch.nn.utils.clip_grad_norm_(critic_params, max_norm=0.5)
                    # critic_optimizer.step()

                    # total_loss = policy_loss.item() + value_loss.item()
                    env.set_current_loss(policy_loss + value_loss)

                    epoch_policy_losses.append(policy_loss.item())
                    epoch_value_losses.append(value_loss.item())

                    if wandb_enabled:
                        wandb.log(
                        {
                            "batch/policy_loss": policy_loss.item(),
                            "batch/value_loss": value_loss.item(),
                            "batch/total_loss": total_loss,
                            "batch/reward_total": episode_reward,
                            "batch/trajectory_length": len(episode_values),
                            "batch/mean_return": returns_t.mean().item(),
                            "batch/mean_advantage": advantages_t.mean().item(),
                        }
                    )

                    logging.info(
                        "Batch metrics - Policy Loss: %s, Value Loss: %s, Total Loss: %s, Reward: %s, Trajectory Length: %s",
                        policy_loss.item(),
                        value_loss.item(),
                        total_loss,
                        episode_reward,
                        len(episode_values),
                    )

            epoch_rewards.append(episode_reward)
            logging.info(
                "Batch %s completed with reward: %s", batch_idx + 1, episode_reward
            )

        epoch_time = time.time() - epoch_start_time
        avg_reward = sum(epoch_rewards) / len(epoch_rewards) if epoch_rewards else 0.0
        avg_policy_loss = (
            sum(epoch_policy_losses) / len(epoch_policy_losses)
            if epoch_policy_losses
            else 0.0
        )
        avg_value_loss = (
            sum(epoch_value_losses) / len(epoch_value_losses)
            if epoch_value_losses
            else 0.0
        )

        metrics_tracker = get_metrics_tracker()
        epoch_success_rate = (
            epoch_step_successes / epoch_step_count if epoch_step_count > 0 else 0.0
        )

        avg_outcome_reward = (
            sum(epoch_outcome_rewards) / len(epoch_outcome_rewards)
            if epoch_outcome_rewards else 0.0
        )
        avg_progress_reward = (
            sum(epoch_progress_rewards) / len(epoch_progress_rewards)
            if epoch_progress_rewards else 0.0
        )
        avg_structure_reward = (
            sum(epoch_structure_rewards) / len(epoch_structure_rewards)
            if epoch_structure_rewards else 0.0
        )
        avg_efficiency_reward = (
            sum(epoch_efficiency_rewards) / len(epoch_efficiency_rewards)
            if epoch_efficiency_rewards else 0.0
        )
        avg_stability_reward = (
            sum(epoch_stability_rewards) / len(epoch_stability_rewards)
            if epoch_stability_rewards else 0.0
        )

        if metrics_tracker is not None:
            metrics_tracker.update_epoch_metrics(
                avg_reward=avg_reward,
                training_loss=avg_policy_loss + avg_value_loss,
                avg_outcome_reward=avg_outcome_reward,
                avg_progress_reward=avg_progress_reward,
                avg_structure_reward=avg_structure_reward,
                avg_efficiency_reward=avg_efficiency_reward,
                avg_stability_reward=avg_stability_reward,
                avg_policy_loss=avg_policy_loss,
                avg_value_loss=avg_value_loss,
                epoch_success_rate=epoch_success_rate,
            )

        if wandb_enabled:
            wandb.log(
            {
                "epoch/index": epoch + 1,
                "epoch/avg_reward_total": avg_reward,
                "epoch/avg_policy_loss": avg_policy_loss,
                "epoch/avg_value_loss": avg_value_loss,
                "epoch/success_rate": epoch_success_rate,
                "epoch/successful_examples": len(epoch_successful),
                "epoch/time_sec": epoch_time,
                "epoch/processed_samples_total": len(processed_samples),
                "epoch/lr_actor": actor_optimizer.param_groups[0]["lr"],
                "epoch/lr_critic": critic_optimizer.param_groups[0]["lr"],
                "epoch/memory_allocated": torch.cuda.memory_allocated(device=device),
                "epoch/memory_reserved": torch.cuda.memory_reserved(device=device),
                "epoch/avg_reward_outcome": avg_outcome_reward,
                "epoch/avg_reward_progress": avg_progress_reward,
                "epoch/avg_reward_structure": avg_structure_reward,
                "epoch/avg_reward_efficiency": avg_efficiency_reward,
                "epoch/avg_reward_stability": avg_stability_reward,
            }
        )

        logging.info("Epoch %s metrics:", epoch + 1)
        logging.info("Average Reward: %s", avg_reward)
        logging.info("Average Policy Loss: %s", avg_policy_loss)
        logging.info("Average Value Loss: %s", avg_value_loss)
        logging.info("Success Rate: %s", epoch_success_rate)
        logging.info("Successful Examples: %s", len(epoch_successful))
        logging.info("Epoch Time: %s", epoch_time)
        logging.info("Total Processed Samples: %s", len(processed_samples))
        logging.info(
            "Reward component averages - Outcome: %s, Progress: %s, Structure: %s, Efficiency: %s, Stability: %s",
            avg_outcome_reward,
            avg_progress_reward,
            avg_structure_reward,
            avg_efficiency_reward,
            avg_stability_reward,
        )

        checkpoint_path_epoch = os.path.join(
            run_dir, f"checkpoint_epoch_{epoch + 1}.pt"
        )
        checkpoint_data = {
            "epoch": epoch,
            "model_state_dict": slm_pg.state_dict(),
            "optimizer_state_dict": actor_optimizer.state_dict(),
            "rewards": total_rewards + epoch_rewards,
            "successful_examples": successful_examples + epoch_successful,
            "processed_samples": processed_samples,
        }

        if not save_checkpoint_safely(checkpoint_data, checkpoint_path_epoch):
            logging.warning(
                "Failed to save checkpoint for epoch %s, continuing training...",
                epoch + 1,
            )

        total_rewards.extend(epoch_rewards)
        successful_examples.extend(epoch_successful)

        torch.cuda.empty_cache()

        actor_scheduler.step(avg_policy_loss)
        critic_scheduler.step(avg_value_loss)

    final_model_path = os.path.join(run_dir, "final_model_new.pt")
    final_lora_path = os.path.join(run_dir, "final_lora")

    checkpoint_data = {
        "epoch": epoch,
        "model_state_dict": slm_pg.state_dict(),
        "optimizer_state_dict": actor_optimizer.state_dict(),
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
            "reward_breakdown_step",
            "avg_reward_per_epoch",
            "policy_loss_per_epoch",
            "value_loss_per_epoch",
            "success_rate_per_epoch",
            "reward_breakdown_epoch",
            "prompt_token_increase",
            "kl_drift",
            "error_analysis",
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