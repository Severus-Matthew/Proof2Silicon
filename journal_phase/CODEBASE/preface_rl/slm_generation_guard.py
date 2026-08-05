"""Qwen3-aware, bounded generation for the prompt-policy SLM."""

import logging
import re
from typing import Dict, List, Tuple

import torch
from transformers import GenerationConfig

from .run_audit import save_interaction


REQUIRED_INITIAL = (
    "Task Summary:",
    "Required Interface:",
    "Behavioral Obligations:",
    "Verification Plan:",
    "Instruction:",
)
REQUIRED_REPAIR = (
    "Failure Cause:",
    "Semantic Check:",
    "Required Repair:",
    "Instruction:",
)
LAST_QUALITY_REPORT: Dict[str, object] = {}
LAST_SAMPLED_KL = 0.0


def current_quality_report() -> Dict[str, object]:
    return dict(LAST_QUALITY_REPORT)


def current_quality_reward() -> float:
    return float(LAST_QUALITY_REPORT.get("quality_reward", 0.0) or 0.0)


def current_sampled_kl() -> float:
    return float(LAST_SAMPLED_KL)


def _quality_report(text: str, repair: bool) -> Dict[str, object]:
    stripped = (text or "").strip()
    required = REQUIRED_REPAIR if repair else REQUIRED_INITIAL
    missing = [heading for heading in required if heading not in stripped]
    lowered = stripped.lower()
    forbidden = []
    if "```dafny" in lowered:
        forbidden.append("dafny_code_block")
    if lowered.count("answer:") > 1:
        forbidden.append("answer_loop")

    lines = [re.sub(r"\s+", " ", line.strip()) for line in stripped.splitlines()]
    lines = [line for line in lines if line]
    repeated_lines = len(lines) - len(set(lines))
    words = re.findall(r"\b\w+\b", lowered)
    fourgrams = [tuple(words[i : i + 4]) for i in range(max(0, len(words) - 3))]
    repeated_fourgram_ratio = 0.0
    if fourgrams:
        repeated_fourgram_ratio = 1.0 - (len(set(fourgrams)) / len(fourgrams))

    penalties = {
        "missing_headings_penalty": -1.0 * len(missing),
        "forbidden_patterns_penalty": -2.0 * len(forbidden),
        "repeated_lines_penalty": -0.25 * max(0, repeated_lines - 1),
        "repetition_ratio_penalty": -4.0 * max(0.0, repeated_fourgram_ratio - 0.20),
        "excess_length_penalty": -0.01 * max(0, len(words) - 650),
        "too_short_penalty": -1.0 if 0 < len(words) < 35 else 0.0,
        "empty_output_penalty": -4.0 if not stripped else 0.0,
    }
    quality_reward = sum(float(value) for value in penalties.values())

    valid = bool(stripped)
    valid = valid and not missing and not forbidden
    valid = valid and repeated_fourgram_ratio < 0.32
    valid = valid and repeated_lines <= 4
    valid = valid and len(words) <= 700
    if valid:
        quality_reward += 0.75

    return {
        "valid": valid,
        "missing_headings": missing,
        "forbidden_patterns": forbidden,
        "word_count": len(words),
        "repeated_line_count": repeated_lines,
        "repeated_fourgram_ratio": repeated_fourgram_ratio,
        "penalties": penalties,
        "quality_reward": quality_reward,
    }


def _render_chat(tokenizer, prompt_text: str) -> str:
    messages = [
        {
            "role": "system",
            "content": (
                "You are a prompt-policy model. Follow the requested schema "
                "exactly. Produce only an instruction for a downstream Dafny "
                "model, never Dafny code and never repeated filler."
            ),
        },
        {"role": "user", "content": prompt_text},
    ]
    kwargs = {"tokenize": False, "add_generation_prompt": True}
    try:
        return tokenizer.apply_chat_template(messages, enable_thinking=False, **kwargs)
    except TypeError:
        return tokenizer.apply_chat_template(messages, **kwargs)


def install_slm_generation_guard(slm_module) -> None:
    if getattr(slm_module, "_qwen_generation_guard_installed", False):
        return

    slm_module.MAX_PROMPT_TOKENS = 1600
    slm_module.MAX_NEW_TOKENS = 800
    slm_module.MAX_SEQ_LEN = 2400

    def guarded_generate_instruction_sequence(
        slm_pg,
        tokenizer,
        prompt_text,
        max_new_tokens=800,
        temperature=0.25,
    ):
        global LAST_QUALITY_REPORT, LAST_SAMPLED_KL
        LAST_SAMPLED_KL = 0.0
        slm_pg.eval()
        if hasattr(slm_pg.model, "gradient_checkpointing_disable"):
            slm_pg.model.gradient_checkpointing_disable()

        rendered = _render_chat(tokenizer, prompt_text)
        previous_side = getattr(tokenizer, "truncation_side", "right")
        tokenizer.truncation_side = "right"
        try:
            inputs = tokenizer(
                rendered,
                return_tensors="pt",
                truncation=True,
                padding=False,
                max_length=1600,
            )
        finally:
            tokenizer.truncation_side = previous_side

        register = getattr(tokenizer, "register_policy_prompt", None)
        if callable(register):
            register(prompt_text, inputs)
        else:
            raise RuntimeError(
                "Prompt-policy tokenizer is not wrapped; PPO prompt IDs would differ "
                "from chat-templated rollout IDs."
            )

        input_ids = inputs["input_ids"]
        attention_mask = inputs["attention_mask"]
        vocab_size = slm_pg.model.get_input_embeddings().num_embeddings
        if torch.any(input_ids < 0) or torch.any(input_ids >= vocab_size):
            raise RuntimeError("Prompt token IDs are outside the model vocabulary")

        input_ids = input_ids.to(slm_module.device)
        attention_mask = attention_mask.to(slm_module.device)
        prompt_len = input_ids.shape[1]
        repair = "Repair the instruction" in prompt_text

        attempts: List[Tuple[str, torch.Tensor, Dict[str, object]]] = []
        for attempt_idx, attempt_temperature in enumerate([float(temperature), 0.15], 1):
            generation_config = GenerationConfig(
                max_new_tokens=min(int(max_new_tokens), 800),
                do_sample=True,
                temperature=attempt_temperature,
                top_p=0.90,
                top_k=40,
                repetition_penalty=1.12,
                no_repeat_ngram_size=4,
                pad_token_id=tokenizer.pad_token_id,
                eos_token_id=tokenizer.eos_token_id,
                remove_invalid_values=True,
                renormalize_logits=True,
            )
            with torch.no_grad():
                output_ids = slm_pg.model.generate(
                    input_ids=input_ids,
                    attention_mask=attention_mask,
                    generation_config=generation_config,
                )
            generated_ids = output_ids[:, prompt_len:]
            text = tokenizer.decode(generated_ids[0], skip_special_tokens=True).strip()
            report = _quality_report(text, repair=repair)
            report.update(
                {
                    "attempt": attempt_idx,
                    "temperature": attempt_temperature,
                    "prompt_tokens_after_chat_template": prompt_len,
                    "generated_tokens": int(generated_ids.shape[1]),
                    "chat_template_applied": True,
                    "thinking_disabled": True,
                    "max_prompt_tokens": 1600,
                    "max_new_tokens": 800,
                    "ppo_prompt_ids_aligned": True,
                }
            )
            attempts.append((text, generated_ids, report))
            if report["valid"]:
                break

        valid_attempts = [item for item in attempts if item[2]["valid"]]
        if valid_attempts:
            instruction_text, generated_ids, report = valid_attempts[0]
        else:
            instruction_text, generated_ids, report = min(
                attempts,
                key=lambda item: (
                    not bool(item[0]),
                    float(item[2]["repeated_fourgram_ratio"]),
                    int(item[2]["word_count"]),
                ),
            )

        if generated_ids.shape[1] == 0:
            LAST_QUALITY_REPORT = dict(report)
            slm_pg.train()
            return "", None, None, None, 0, []

        if hasattr(slm_pg.model, "gradient_checkpointing_enable"):
            slm_pg.model.gradient_checkpointing_enable()
        slm_pg.train()
        seq_log_prob, value, entropy = slm_module.compute_sequence_logprob_and_value(
            slm_pg,
            inputs["input_ids"].to(slm_module.device),
            generated_ids.to(slm_module.device),
        )

        # Sampled-token KL proxy against the frozen base model with LoRA disabled.
        # This is a real policy-drift signal, unlike the previous hard-coded zero.
        disable_adapter = getattr(slm_pg.model, "disable_adapter", None)
        if callable(disable_adapter):
            try:
                with torch.no_grad():
                    with disable_adapter():
                        ref_log_prob, _, _ = slm_module.compute_sequence_logprob_and_value(
                            slm_pg,
                            inputs["input_ids"].to(slm_module.device),
                            generated_ids.to(slm_module.device),
                        )
                LAST_SAMPLED_KL = max(
                    0.0,
                    float((seq_log_prob.detach() - ref_log_prob.detach()).item()),
                )
            except Exception as exc:
                logging.warning("Could not compute sampled KL to base policy: %s", exc)
                LAST_SAMPLED_KL = 0.0

        report["sampled_kl_to_base"] = LAST_SAMPLED_KL
        LAST_QUALITY_REPORT = dict(report)
        save_interaction(
            "slm",
            prompt_text,
            instruction_text,
            {
                "slm_model": getattr(slm_pg.model.config, "_name_or_path", None),
                "quality": LAST_QUALITY_REPORT,
                "all_attempt_quality": [item[2] for item in attempts],
                "sampled_kl_to_base": LAST_SAMPLED_KL,
            },
        )

        return (
            instruction_text,
            seq_log_prob,
            value.squeeze(),
            generated_ids,
            int(generated_ids.shape[1]),
            entropy,
        )

    slm_module.generate_instruction_sequence = guarded_generate_instruction_sequence
    slm_module._qwen_generation_guard_installed = True
