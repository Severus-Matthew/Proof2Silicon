"""Journal SLM initialization using Qwen3-1.7B for every experiment.

The training algorithm remains in preface_rl.slm.  This module only replaces the
base-model initializer so the four generator experiments share exactly the same
SLM architecture, quantization, and LoRA configuration.
"""

import gc
import logging
import os
from typing import Optional, Tuple

import torch
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig


SLM_MODEL_NAME = os.environ.get("SLM_MODEL_NAME", "Qwen/Qwen3-1.7B")
OFFLOAD_FOLDER = os.environ.get(
    "SLM_OFFLOAD_FOLDER",
    "/u/mjha1/Proof2Silicon/journal_phase/model_offload_qwen3_1_7b",
)
SLM_GPU_MEMORY = os.environ.get("SLM_GPU_MEMORY", "24GiB")
SLM_CPU_MEMORY = os.environ.get("SLM_CPU_MEMORY", "96GiB")

_global_model = None
_global_tokenizer = None


def initialize_slm(checkpoint_path: Optional[str] = None):
    global _global_model, _global_tokenizer

    if _global_model is not None:
        return _global_model, _global_tokenizer

    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    gc.collect()
    os.environ.setdefault(
        "PYTORCH_CUDA_ALLOC_CONF",
        "expandable_segments:True,max_split_size_mb:128",
    )
    os.makedirs(OFFLOAD_FOLDER, exist_ok=True)

    logging.info("Loading journal SLM: %s", SLM_MODEL_NAME)
    tokenizer = AutoTokenizer.from_pretrained(
        SLM_MODEL_NAME,
        trust_remote_code=True,
    )
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
        tokenizer.pad_token_id = tokenizer.eos_token_id

    compute_dtype = torch.bfloat16 if torch.cuda.is_available() and torch.cuda.is_bf16_supported() else torch.float16
    quant_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_use_double_quant=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_compute_dtype=compute_dtype,
    )

    model = AutoModelForCausalLM.from_pretrained(
        SLM_MODEL_NAME,
        quantization_config=quant_config,
        trust_remote_code=True,
        device_map="auto",
        max_memory={0: SLM_GPU_MEMORY, "cpu": SLM_CPU_MEMORY},
        offload_folder=OFFLOAD_FOLDER,
        offload_state_dict=True,
        torch_dtype=compute_dtype,
        low_cpu_mem_usage=True,
    )

    model = prepare_model_for_kbit_training(model)
    model.config.use_cache = False
    model.gradient_checkpointing_enable()

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
        inference_mode=False,
    )
    model = get_peft_model(model, lora_config)
    model.enable_input_require_grads()
    model.train()

    trainable = [(name, parameter) for name, parameter in model.named_parameters() if parameter.requires_grad]
    if not trainable:
        raise RuntimeError("Qwen3 SLM has no trainable LoRA parameters")

    logging.info(
        "SLM trainable tensors=%d trainable parameters=%d",
        len(trainable),
        sum(parameter.numel() for _, parameter in trainable),
    )
    model.print_trainable_parameters()

    if checkpoint_path and os.path.exists(checkpoint_path):
        logging.info("Loading SLM checkpoint: %s", checkpoint_path)
        checkpoint = torch.load(checkpoint_path, map_location="cpu")
        state_dict = checkpoint.get("model_state_dict", checkpoint)
        missing, unexpected = model.load_state_dict(state_dict, strict=False)
        logging.info(
            "Checkpoint loaded with missing=%d unexpected=%d",
            len(missing),
            len(unexpected),
        )

    _global_model = model
    _global_tokenizer = tokenizer
    return model, tokenizer


def trainable_parameter_snapshot(model):
    """Return compact norms proving that trainable SLM parameters changed."""
    tensor_count = 0
    parameter_count = 0
    squared_norm = 0.0
    max_abs = 0.0
    for _name, parameter in model.named_parameters():
        if not parameter.requires_grad:
            continue
        data = parameter.detach().float()
        tensor_count += 1
        parameter_count += data.numel()
        squared_norm += float(torch.sum(data * data).cpu().item())
        if data.numel():
            max_abs = max(max_abs, float(data.abs().max().cpu().item()))
    return {
        "tensor_count": tensor_count,
        "parameter_count": parameter_count,
        "l2_norm": squared_norm ** 0.5,
        "max_abs": max_abs,
    }
