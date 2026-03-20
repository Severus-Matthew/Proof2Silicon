"""
Preface RL package.

This package breaks the original monolithic `Preface_RL_1.py` script
into reusable modules:

- `tree`     : error tree data structures
- `metrics`  : tracking and plotting of metrics
- `utils`    : utility helpers (IO, extraction, saving)
- `prompts`  : prompt construction (ShortPrompt, ErrorPrompt)
- `rewards`  : reward constants and compute_total_reward (tune here for next version)
- `slm`      : SLM initialization and RL training loop
- `llm`      : Gemini LLM interaction helpers
- `envs`     : Dafny Gym environment used for RL
"""

from .envs import DafnyEnv
from .slm import initialize_slm, train_slm_with_grpo

__all__ = [
    "DafnyEnv",
    "initialize_slm",
    "train_slm_with_grpo",
]

