#!/usr/bin/env python3
"""Robust entry point for journal evaluation.

Patches test_journal.call_model at runtime so evaluation uses the same OpenAI
coder inference policy as journal training while retaining explicit diagnostics
for empty/incomplete Responses API outputs.
"""

from __future__ import annotations

import logging
import os
import time
from typing import Any, Optional, Tuple

import test_journal as tj


def _usage(response: Any) -> Tuple[int, int, int]:
    usage = getattr(response, "usage", None)
    if usage is None:
        return 0, 0, 0
    input_tokens = int(getattr(usage, "input_tokens", 0) or 0)
    output_tokens = int(getattr(usage, "output_tokens", 0) or 0)
    details = getattr(usage, "output_tokens_details", None)
    reasoning_tokens = int(getattr(details, "reasoning_tokens", 0) or 0) if details is not None else 0
    return input_tokens, output_tokens, reasoning_tokens


def _incomplete_reason(response: Any) -> Optional[str]:
    details = getattr(response, "incomplete_details", None)
    if details is None:
        return None
    return getattr(details, "reason", None) or str(details)


def _output_types(response: Any) -> str:
    output = getattr(response, "output", None) or []
    types = [str(getattr(item, "type", type(item).__name__)) for item in output]
    return ",".join(types) if types else "none"


def _openai_once(client, spec, system, user, reasoning, max_tokens):
    kwargs = {
        "model": spec.model,
        "instructions": system,
        "input": user,
        "max_output_tokens": int(max_tokens),
    }
    if reasoning:
        kwargs["reasoning"] = {"effort": reasoning}
    response = client.responses.create(**kwargs)
    text = (getattr(response, "output_text", "") or "").strip()
    input_tokens, output_tokens, reasoning_tokens = _usage(response)
    return response, text, input_tokens, output_tokens, reasoning_tokens


def _log_empty(spec, attempt, total, response, input_tokens, output_tokens, reasoning_tokens, max_tokens, reasoning):
    status = getattr(response, "status", None)
    reason = _incomplete_reason(response)
    response_id = getattr(response, "id", None)
    output_types = _output_types(response)
    logging.warning(
        "OpenAI empty response for %s attempt %d/%d: id=%s status=%s "
        "incomplete_reason=%s input_tokens=%d output_tokens=%d reasoning_tokens=%d "
        "max_output_tokens=%d reasoning_effort=%s output_types=%s",
        spec.key,
        attempt,
        total,
        response_id,
        status,
        reason,
        input_tokens,
        output_tokens,
        reasoning_tokens,
        int(max_tokens),
        reasoning,
        output_types,
    )
    return RuntimeError(
        "model returned an empty response "
        f"(status={status}, incomplete_reason={reason}, output_tokens={output_tokens}, "
        f"reasoning_tokens={reasoning_tokens}, max_output_tokens={int(max_tokens)}, "
        f"reasoning_effort={reasoning})"
    )


def robust_call_model(
    spec: tj.ModelSpec,
    system: str,
    user: str,
    *,
    max_tokens: int,
    reasoning: Optional[str] = None,
    temperature: float = 0.2,
    retries: int = 3,
):
    """Same contract as test_journal.call_model, with training-matched coder behavior."""
    client = tj.make_client(spec)
    last_error: Optional[Exception] = None

    is_semantic_judge = "semantic alignment judge" in system.lower()
    is_dafny_coder = "expert dafny programmer" in system.lower()

    # EXACT journal-training OpenAI generator policy from preface_rl/llm.py:
    #   attempt 1: configured reasoning (medium), 16,384 output tokens
    #   if visible text is empty: low reasoning, 24,576 output tokens
    # This is intentionally not a dynamic evaluation-only heuristic; it mirrors
    # the generator behavior under which the OpenAI and mixed SLMs were trained.
    if spec.provider == "openai" and is_dafny_coder:
        primary_reasoning = (
            reasoning
            or os.environ.get("OPENAI_GENERATOR_REASONING", "medium").strip().lower()
        )
        primary_tokens = int(os.environ.get("OPENAI_GENERATOR_MAX_TOKENS", "16384"))
        retry_tokens = int(os.environ.get("OPENAI_GENERATOR_RETRY_MAX_TOKENS", "24576"))
        attempts = [
            (primary_reasoning, primary_tokens),
            ("low", retry_tokens),
        ]

        for attempt_index, (attempt_reasoning, token_budget) in enumerate(attempts, 1):
            try:
                response, text, p, c, reasoning_tokens = _openai_once(
                    client,
                    spec,
                    system,
                    user,
                    attempt_reasoning,
                    token_budget,
                )
                if text:
                    if attempt_index > 1:
                        logging.info(
                            "Recovered empty OpenAI coder response with training-matched fallback: "
                            "%s reasoning=%s max_output_tokens=%d",
                            spec.key,
                            attempt_reasoning,
                            token_budget,
                        )
                    return text, p, c
                last_error = _log_empty(
                    spec,
                    attempt_index,
                    len(attempts),
                    response,
                    p,
                    c,
                    reasoning_tokens,
                    token_budget,
                    attempt_reasoning,
                )
            except Exception as exc:
                last_error = exc
                logging.warning(
                    "OpenAI coder attempt %d/%d failed for %s: %s",
                    attempt_index,
                    len(attempts),
                    spec.key,
                    exc,
                )
            if attempt_index < len(attempts):
                time.sleep(min(8, 2 ** attempt_index))

        raise RuntimeError(
            f"API failed after training-matched OpenAI coder attempts for {spec.key}: {last_error}"
        )

    # Semantic judge also mirrors journal training: GPT-5.4, low reasoning,
    # 512-token output budget. Transport-level retries remain enabled here so
    # transient API failures do not become scientific failures.
    effective_max_tokens = int(max_tokens)
    if spec.provider == "openai" and is_semantic_judge:
        effective_max_tokens = max(
            effective_max_tokens,
            int(os.environ.get("DAFNY_JUDGE_MAX_TOKENS", "512")),
        )
        reasoning = os.environ.get("DAFNY_JUDGE_REASONING", "low").strip().lower()

    for attempt in range(1, retries + 1):
        try:
            if spec.provider == "openai":
                response, text, p, c, reasoning_tokens = _openai_once(
                    client,
                    spec,
                    system,
                    user,
                    reasoning,
                    effective_max_tokens,
                )
                if text:
                    return text, p, c
                last_error = _log_empty(
                    spec,
                    attempt,
                    retries,
                    response,
                    p,
                    c,
                    reasoning_tokens,
                    effective_max_tokens,
                    reasoning,
                )
            else:
                response = client.chat.completions.create(
                    model=spec.model,
                    messages=[
                        {"role": "system", "content": system},
                        {"role": "user", "content": user},
                    ],
                    temperature=temperature,
                    max_tokens=max_tokens,
                    stream=False,
                )
                text = (response.choices[0].message.content or "").strip()
                p, c = tj.usage_counts(response)
                if text:
                    return text, p, c
                last_error = RuntimeError("model returned an empty response")
                logging.warning(
                    "HF/OpenAI-compatible empty response for %s attempt %d/%d",
                    spec.key,
                    attempt,
                    retries,
                )
        except Exception as exc:
            last_error = exc
            logging.warning(
                "API attempt %d/%d failed for %s: %s",
                attempt,
                retries,
                spec.key,
                exc,
            )

        if attempt < retries:
            time.sleep(min(8, 2 ** attempt))

    raise RuntimeError(f"API failed after {retries} attempts for {spec.key}: {last_error}")


tj.call_model = robust_call_model

if __name__ == "__main__":
    tj.main()
