#!/usr/bin/env python3
"""Robust entry point for journal evaluation.

Patches test_journal.call_model at runtime so OpenAI Responses calls expose
status/incomplete/token diagnostics, use the journal judge budget, and never
silently score an empty API response as a model failure.
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
    types = []
    for item in output:
        types.append(str(getattr(item, "type", type(item).__name__)))
    return ",".join(types) if types else "none"


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
    """Same contract as test_journal.call_model with robust Responses handling."""
    client = tj.make_client(spec)
    last_error: Optional[Exception] = None

    # Journal training used a 512-token semantic-judge budget.  The original
    # test harness accidentally used 32, which can be consumed entirely by
    # reasoning tokens before a visible YES/NO appears.
    is_semantic_judge = "semantic alignment judge" in system.lower()
    effective_max_tokens = int(max_tokens)
    if spec.provider == "openai" and is_semantic_judge:
        effective_max_tokens = max(
            effective_max_tokens,
            int(os.environ.get("DAFNY_JUDGE_MAX_TOKENS", "512")),
        )

    for attempt in range(1, retries + 1):
        try:
            if spec.provider == "openai":
                kwargs = {
                    "model": spec.model,
                    "instructions": system,
                    "input": user,
                    "max_output_tokens": effective_max_tokens,
                }
                if reasoning:
                    kwargs["reasoning"] = {"effort": reasoning}

                response = client.responses.create(**kwargs)
                text = (getattr(response, "output_text", "") or "").strip()
                input_tokens, output_tokens, reasoning_tokens = _usage(response)

                if text:
                    return text, input_tokens, output_tokens

                status = getattr(response, "status", None)
                reason = _incomplete_reason(response)
                response_id = getattr(response, "id", None)
                output_types = _output_types(response)
                logging.warning(
                    "OpenAI empty response for %s attempt %d/%d: id=%s status=%s "
                    "incomplete_reason=%s input_tokens=%d output_tokens=%d "
                    "reasoning_tokens=%d max_output_tokens=%d output_types=%s",
                    spec.key,
                    attempt,
                    retries,
                    response_id,
                    status,
                    reason,
                    input_tokens,
                    output_tokens,
                    reasoning_tokens,
                    effective_max_tokens,
                    output_types,
                )
                last_error = RuntimeError(
                    "model returned an empty response "
                    f"(status={status}, incomplete_reason={reason}, "
                    f"output_tokens={output_tokens}, reasoning_tokens={reasoning_tokens}, "
                    f"max_output_tokens={effective_max_tokens})"
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

    raise RuntimeError(
        f"API failed after {retries} attempts for {spec.key}: {last_error}"
    )


tj.call_model = robust_call_model

if __name__ == "__main__":
    tj.main()
