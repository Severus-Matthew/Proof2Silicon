#!/usr/bin/env python3
"""Apply API protocol patches, then run the hardware-aware P2S harness."""

# Importing this module installs the existing training-matched OpenAI behavior
# plus strict DeepSeek-V4 non-thinking behavior into test_journal.call_model.
import journal_large_eval_entry  # noqa: F401
import test_p2s_journal


if __name__ == "__main__":
    test_p2s_journal.main()
