"""Tokenizer proxy that keeps generation and PPO prompt IDs identical.

The prompt-policy generator renders Qwen chat-template text, while the legacy
training loop re-tokenizes the raw state prompt immediately afterwards. Without
this proxy, rollout log-probabilities are computed from chat-templated IDs but
PPO replay uses different raw IDs. The proxy returns the exact rendered IDs for
that one immediate replay call.
"""

from typing import Any, Dict, Optional

import torch
from transformers.tokenization_utils_base import BatchEncoding


class PolicyTokenizerProxy:
    def __init__(self, tokenizer):
        object.__setattr__(self, "_tokenizer", tokenizer)
        object.__setattr__(self, "_pending_raw_prompt", None)
        object.__setattr__(self, "_pending_encoding", None)

    def __getattr__(self, name: str) -> Any:
        return getattr(self._tokenizer, name)

    def __setattr__(self, name: str, value: Any) -> None:
        if name.startswith("_policy_") or name in {
            "_tokenizer",
            "_pending_raw_prompt",
            "_pending_encoding",
        }:
            object.__setattr__(self, name, value)
        else:
            setattr(self._tokenizer, name, value)

    @staticmethod
    def _clone_encoding(encoding: BatchEncoding) -> BatchEncoding:
        copied: Dict[str, Any] = {}
        for key, value in encoding.items():
            copied[key] = value.detach().clone() if torch.is_tensor(value) else value
        return BatchEncoding(copied)

    def register_policy_prompt(self, raw_prompt: str, encoding: BatchEncoding) -> None:
        object.__setattr__(self, "_pending_raw_prompt", raw_prompt)
        object.__setattr__(self, "_pending_encoding", self._clone_encoding(encoding))

    def __call__(self, text=None, *args, **kwargs):
        pending_prompt: Optional[str] = self._pending_raw_prompt
        pending_encoding = self._pending_encoding
        if (
            isinstance(text, str)
            and pending_prompt is not None
            and text == pending_prompt
            and pending_encoding is not None
            and kwargs.get("return_tensors") == "pt"
        ):
            object.__setattr__(self, "_pending_raw_prompt", None)
            object.__setattr__(self, "_pending_encoding", None)
            return self._clone_encoding(pending_encoding)
        return self._tokenizer(text, *args, **kwargs)


def wrap_policy_tokenizer(tokenizer):
    if isinstance(tokenizer, PolicyTokenizerProxy):
        return tokenizer
    return PolicyTokenizerProxy(tokenizer)
