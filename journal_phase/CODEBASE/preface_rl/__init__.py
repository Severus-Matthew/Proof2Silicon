"""
Preface RL package.

This package breaks the original monolithic `Preface_RL_1.py` script
into reusable modules:

- `tree`     : error tree data structures
- `metrics`  : tracking and plotting of metrics
- `utils`    : utility helpers (IO, extraction, saving)
- `prompts`  : prompt construction (ShortPrompt, ErrorPrompt)
- `rewards`  : reward constants and compute_total_reward
- `slm`      : SLM initialization and RL training loop
- `llm`      : LLM interaction helpers
- `envs`     : Dafny Gym environment used for RL
"""

from .envs import DafnyEnv
from .ast_isolation import install_ast_isolation
from .slm import initialize_slm, train_slm_with_grpo

# The Dafny AST plugin writes to one fixed JSON file. Install a cross-process
# filesystem lock before any training environment uses it, so parallel Slurm
# array tasks cannot overwrite/read each other's AST output.
install_ast_isolation(DafnyEnv)

__all__ = [
    "DafnyEnv",
    "initialize_slm",
    "train_slm_with_grpo",
]
