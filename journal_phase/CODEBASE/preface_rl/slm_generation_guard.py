"""Qwen3-aware, bounded generation for the prompt-policy SLM."""

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


def current_quality_reward() -> float:
    """Small auxiliary reward for concise, schema-valid prompt-policy output."""
    report = LAST_QUALITY_REPORT
    if not report:
        return 0.0
    if bool(report.get("valid")):
        return 0.75
    penalty = -4.0
    penalty -= min(2.0, 0.5 * len(report.get("missing_headings", [])))
    penalty -= min(1.5, 4.0 * float(report.get("repeated_fourgram_ratio", 0.0)))
    penalty -= min(1.0, 0.25 * len(report.get("forbidden_patterns", [])))
    return max(-8.0, penalty)


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

    valid = bool(stripped)
    valid = valid and not missing and not forbidden
    valid = valid and repeated_fourgram_ratio < 0.32
    valid = valid and repeated_lines <= 3
    valid = valid and len(words) <= 420

    return {
        "valid": valid,
        "missing_headings": missing,
        "forbidden_patterns": forbidden,
        "word_count": len(words),
        "repeated_line_count": repeated_lines,
        "repeated_fourgram_ratio": repeated_fourgram_ratio,
    }


def _render_chat(tokenizer, prompt_text: str) -> str:
    messages = [
        {
            "role": "system",
            "content": (
                "You are a concise prompt-policy model. Follow the requested "
                "schema exactly. Produce only an instruction for a downstream "
                "Dafny model, never Dafny code and never repeated filler."
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

    def guarded_generate_instruction_sequence(
        slm_pg,
        tokenizer,
        prompt_text,
        max_new_tokens=320,
        temperature=0.25,
    ):
        global LAST_QUALITY_REPORT
        slm_pg.eval()
        if hasattr(slm_pg.model, "gradient_checkpointing_disable"):
            slm_pg.model.gradient_checkpointing_disable()

        rendered = _render_chat(tokenizer, prompt_text)
        previous_side = getattr(tokenizer, "truncation_side", "right")
        tokenizer.truncation_side = "left"
        try:
            inputs = tokenizer(
                rendered,
                return_tensors="pt",
                truncation=True,
                padding=False,
                max_length=slm_module.MAX_PROMPT_TOKENS,
            )
        finally:
            tokenizer.truncation_side = previous_side

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
                max_new_tokens=min(int(max_new_tokens), 384),
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
        LAST_QUALITY_REPORT = dict(report)
        LAST_QUALITY_REPORT["quality_reward"] = current_quality_reward()

        save_interaction(
            "slm",
            prompt_text,
            instruction_text,
            {
                "slm_model": getattr(slm_pg.model.config, "_name_or_path", None),
                "quality": LAST_QUALITY_REPORT,
                "all_attempt_quality": [item[2] for item in attempts],
            },
        )

        if generated_ids.shape[1] == 0:
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
