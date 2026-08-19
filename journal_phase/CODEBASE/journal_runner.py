#!/usr/bin/env python3
"""Journal entry point that installs the corrected PPO update before training."""

# Configure logging before importing the training stack.  Importing
# preface_rl.slm first can cause third-party libraries to install a root handler;
# after that, the logging.basicConfig() calls in main.py/journal_main.py become
# no-ops and INFO rollout logs disappear even though training is still running.
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    force=True,
)

import preface_rl.slm as slm_module
from preface_rl.ppo_update_override import install as install_ppo_update_override

install_ppo_update_override(slm_module)

import journal_main


if __name__ == "__main__":
    journal_main.main()
