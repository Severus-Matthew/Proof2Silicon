#!/usr/bin/env python3
"""Entry point for the post-core large-generator journal experiments.

All downstream open-weight generators are called through Hugging Face Inference
Providers; no downstream generator weights are loaded locally.  The only local
model in trained/untrained conditions remains the existing Qwen3-1.7B prompt
policy used by the journal pipeline.

DeepSeek-V4-Flash is required to run in strict non-thinking/chat mode.  We pass
its documented ``thinking_mode=chat`` request extension and reject a response if
reasoning content or an explicit <think> block is returned.  We deliberately do
not fall back to thinking mode because that would silently change the protocol.
"""

from __future__ import annotations

import logging
import re
import time
from typing import Optional

import journal_eval_entry as base_entry
import test_journal as tj


DEEPSEEK_V4_REPO = "deepseek-ai/DeepSeek-V4-Flash"


def _repo_without_route(model: str) -> str:
    """Remove an HF provider-selection suffix such as :cheapest/:novita."""
    if ":" not in model:
        return model
    repo, suffix = model.rsplit(":", 1)
    if suffix in {"cheapest", "fastest", "preferred"}:
        return repo
    # Explicit provider names are also routing suffixes.  Model repo IDs in this
    # study do not otherwise contain a colon, so treating the final component as
    # routing metadata is safe.
    if "/" in repo:
        return repo
    return model


def _reasoning_text(message) -> str:
    for name in ("reasoning_content", "reasoning", "thinking"):
        value = getattr(message, name, None)
        if value:
            return str(value).strip()
    return ""


def _strict_deepseek_v4_nonthink(
    spec: tj.ModelSpec,
    system: str,
    user: str,
    *,
    max_tokens: int,
    temperature: float,
    retries: int,
):
    client = tj.make_client(spec)
    last_error: Optional[Exception] = None

    for attempt in range(1, retries + 1):
        try:
            response = client.chat.completions.create(
                model=spec.model,
                messages=[
                    {"role": "system", "content": system},
                    {"role": "user", "content": user},
                ],
                temperature=temperature,
                max_tokens=max_tokens,
                stream=False,
                # DeepSeek-V4's official encoding calls this chat mode: it closes
                # the thinking block before generation.  HF providers may differ,
                # which is why preflight + response validation are mandatory.
                extra_body={"thinking_mode": "chat"},
            )
            message = response.choices[0].message
            text = (message.content or "").strip()
            reasoning = _reasoning_text(message)

            if reasoning:
                raise RuntimeError(
                    "DeepSeek-V4 strict non-think protocol violated: provider "
                    "returned non-empty reasoning_content"
                )
            if re.search(r"<think\b|</think>", text, flags=re.I):
                raise RuntimeError(
                    "DeepSeek-V4 strict non-think protocol violated: visible "
                    "response contains a <think> block"
                )
            if not text:
                raise RuntimeError("DeepSeek-V4 returned an empty non-think response")

            p, c = tj.usage_counts(response)
            return text, p, c
        except Exception as exc:
            last_error = exc
            logging.warning(
                "DeepSeek-V4 non-think attempt %d/%d failed for %s: %s",
                attempt,
                retries,
                spec.key,
                exc,
            )
            if attempt < retries:
                time.sleep(min(8, 2 ** attempt))

    raise RuntimeError(
        f"DeepSeek-V4 strict non-think API failed after {retries} attempts "
        f"for {spec.key}: {last_error}"
    )


def large_model_call(
    spec: tj.ModelSpec,
    system: str,
    user: str,
    *,
    max_tokens: int,
    reasoning: Optional[str] = None,
    temperature: float = 0.2,
    retries: int = 3,
):
    if spec.provider == "hf" and _repo_without_route(spec.model) == DEEPSEEK_V4_REPO:
        return _strict_deepseek_v4_nonthink(
            spec,
            system,
            user,
            max_tokens=max_tokens,
            temperature=temperature,
            retries=retries,
        )

    # Existing journal behavior, including the exact OpenAI training-matched
    # coder fallback and GPT-5.4 low/512 semantic judge configuration.
    return base_entry.robust_call_model(
        spec,
        system,
        user,
        max_tokens=max_tokens,
        reasoning=reasoning,
        temperature=temperature,
        retries=retries,
    )


tj.call_model = large_model_call


if __name__ == "__main__":
    tj.main()
