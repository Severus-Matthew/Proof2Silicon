#!/usr/bin/env python3
"""Journal entry point that installs the corrected PPO update before training."""

import preface_rl.slm as slm_module
from preface_rl.ppo_update_override import install as install_ppo_update_override

install_ppo_update_override(slm_module)

import journal_main


if __name__ == "__main__":
    journal_main.main()
