#!/usr/bin/env python3
"""Fail fast if prompt-policy token budgets drift across runtime modules."""

from preface_rl import slm as slm_module
from preface_rl.slm_generation_guard import install_slm_generation_guard

EXPECTED_PROMPT_TOKENS = 1600
EXPECTED_NEW_TOKENS = 800
EXPECTED_SEQUENCE_TOKENS = EXPECTED_PROMPT_TOKENS + EXPECTED_NEW_TOKENS


def main() -> None:
    install_slm_generation_guard(slm_module)

    actual = {
        "MAX_PROMPT_TOKENS": int(slm_module.MAX_PROMPT_TOKENS),
        "MAX_NEW_TOKENS": int(slm_module.MAX_NEW_TOKENS),
        "MAX_SEQ_LEN": int(slm_module.MAX_SEQ_LEN),
    }
    expected = {
        "MAX_PROMPT_TOKENS": EXPECTED_PROMPT_TOKENS,
        "MAX_NEW_TOKENS": EXPECTED_NEW_TOKENS,
        "MAX_SEQ_LEN": EXPECTED_SEQUENCE_TOKENS,
    }

    if actual != expected:
        raise RuntimeError(
            "Inconsistent SLM token budget: actual={} expected={}".format(
                actual, expected
            )
        )

    if actual["MAX_SEQ_LEN"] != (
        actual["MAX_PROMPT_TOKENS"] + actual["MAX_NEW_TOKENS"]
    ):
        raise RuntimeError("MAX_SEQ_LEN must equal prompt + generated token limits")

    print("SLM token budget consistency check passed:", actual)
    print("Qwen thinking remains disabled in slm_generation_guard.py")


if __name__ == "__main__":
    main()
