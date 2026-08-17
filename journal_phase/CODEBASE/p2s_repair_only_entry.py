#!/usr/bin/env python3
"""P2S evaluation variant that invokes the SLM only after the first failure.

This keeps attempt 1 as a direct coder baseline for trained/untrained conditions,
then uses the learned or untrained 1.7B policy only for repair attempts 2..5.
The original P2S harness remains unchanged, so the earlier pilot is reproducible.

The trained-only attempt-2 bit-width reminder is preserved exactly as requested.
"""

# Install the API protocol patches first (strict DeepSeek-V4 non-thinking,
# strict GPT-5.4-nano reasoning=none, HF retry handling).
import journal_large_eval_entry  # noqa: F401
import test_p2s_journal as p2s


_ORIGINAL_GET_POLICY_INSTRUCTION = p2s.get_policy_instruction
_ORIGINAL_CONDITION_KEY = p2s.condition_key


def _repair_only_instruction(
    args,
    task,
    previous_code,
    previous_error,
    slm_pg,
    tokenizer,
    seed,
    bit_reminder,
):
    # Attempt 1 has no previous candidate/error.  For trained and untrained
    # controller conditions, do not perturb the base coder on that first pass.
    if args.instructor in {"trained", "untrained"} and not previous_code and not previous_error:
        return None, 0
    return _ORIGINAL_GET_POLICY_INSTRUCTION(
        args,
        task,
        previous_code,
        previous_error,
        slm_pg,
        tokenizer,
        seed,
        bit_reminder,
    )


def _condition_key(args, coder):
    base = _ORIGINAL_CONDITION_KEY(args, coder)
    if args.instructor in {"trained", "untrained"}:
        return base + "__deploy_repair_only"
    # The none baseline is byte-for-byte the same protocol, so keep its original
    # key and safely reuse/resume already-completed direct-baseline trajectories.
    return base


p2s.get_policy_instruction = _repair_only_instruction
p2s.condition_key = _condition_key


if __name__ == "__main__":
    p2s.main()
