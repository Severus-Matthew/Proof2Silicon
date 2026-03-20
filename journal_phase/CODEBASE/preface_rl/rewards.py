# """
# Reward computation for Dafny verification outcomes.

# All reward constants and logic live here so you can iterate on
# reward shaping (e.g. success/penalty values, error weighting)
# without touching prompts or environment flow.
# """
# from typing import Dict, Optional

# # ---------------------------------------------------------------------------
# # Reward constants (tune these for the next version)
# # ---------------------------------------------------------------------------

# REWARD_SUCCESS = 5.0
# """Reward when Dafny verifies and compiles with 0 errors."""

# REWARD_EMPTY = -7.0
# """Reward when the generated code is empty or invalid."""

# REWARD_TIMEOUT = -7.0
# """Reward when Dafny verification times out."""

# REWARD_EXCEPTION = -7.0
# """Reward when running Dafny raises an exception."""

# REWARD_BASE_FAIL = -5.0
# """Base reward when verification fails with one or more errors (before shaping)."""

# ERROR_COEFFICIENT = 0.2
# """Coefficient for error-count penalty: penalty += ERROR_COEFFICIENT * error_count."""

# ITERATION_COEFFICIENT = 0.5
# """Coefficient for iteration penalty: penalty += ITERATION_COEFFICIENT * iteration."""


# # ---------------------------------------------------------------------------
# # Reward computation
# # ---------------------------------------------------------------------------

# def compute_reward(
#     outcome: str,
#     *,
#     error_count: int = 0,
#     iteration: int = 0,
#     error_types: Optional[Dict[str, int]] = None,
# ) -> float:
#     """
#     Compute reward for a single verification step.

#     Args:
#         outcome: One of "success", "empty", "timeout", "exception", "failure".
#         error_count: Number of errors (for "failure").
#         iteration: Current attempt index (for "failure" shaping).
#         error_types: Optional dict of error type -> count (for future reward shaping).

#     Returns:
#         Scalar reward (higher is better).
#     """
#     if outcome == "success":
#         return REWARD_SUCCESS
#     if outcome == "empty":
#         return REWARD_EMPTY
#     if outcome == "timeout":
#         return REWARD_TIMEOUT
#     if outcome == "exception":
#         return REWARD_EXCEPTION
#     if outcome == "failure":
#         # Shaped penalty: more errors and more iterations => more negative
#         shaped_penalty = -ERROR_COEFFICIENT * error_count - ITERATION_COEFFICIENT * iteration
#         return REWARD_BASE_FAIL + shaped_penalty
#     raise ValueError(f"Unknown outcome: {outcome!r}")


# def calculate_example_weight(reward: float, scale: float = 1.0) -> float:
#     """
#     Map reward to a loss weight for weighted training (e.g. negative rewards
#     get higher weight so the model focuses on fixing failures).

#     Override or extend this in the next version to experiment with
#     different weighting schemes.
#     """
#     if reward < 0:
#         return 1.0 + scale * abs(reward)
#     return 1.0



from typing import Dict, Optional


REWARD_SUCCESS = 10.0
REWARD_EMPTY = -10.0

ERROR_WEIGHTS = {
    "syntax": 0.2,
    "type": 0.3,
    "missing_invariant": 0.8,
    "postcondition": 1.0,
    "timeout": 1.2,
}

NEW_LEMMA_REWARD = 0.2
RECURSION_PENALTY = -1.0
NEW_INVARIANT_REWARD = 0.3

GHOST_VAR_ERROR_DECREASE_REWARD = 0.4
GHOST_VAR_INVARIANT_INCREASE_REWARD = 0.2
GHOST_VAR_NO_PROGRESS_PENALTY = -0.2
GHOST_VAR_ERROR_INCREASE_PENALTY = -0.5

PROMPT_TOKEN_EFFICIENCY_COEFF = -0.001
KL_REWARD_COEFF =0.1


def compute_outcome_reward(outcome: str) -> float:
    if outcome == "success":
        return REWARD_SUCCESS
    if outcome == "empty":
        return REWARD_EMPTY
    return 0.0


def compute_progress_reward(
    prev_error_counts: Optional[Dict[str, int]],
    curr_error_counts: Optional[Dict[str, int]],
) -> float:
    prev_error_counts = prev_error_counts or {}
    curr_error_counts = curr_error_counts or {}

    reward = 0.0
    for error_type, weight in ERROR_WEIGHTS.items():
        prev_count = prev_error_counts.get(error_type, 0)
        curr_count = curr_error_counts.get(error_type, 0)
        reward += weight * (prev_count - curr_count)
    return reward


def compute_structure_reward(
    prev_structure: Optional[Dict[str, int]],
    curr_structure: Optional[Dict[str, int]],
    prev_total_errors: int,
    curr_total_errors: int,
) -> float:
    prev_structure = prev_structure or {}
    curr_structure = curr_structure or {}

    reward = 0.0

    prev_lemma = prev_structure.get("lemma_count", 0)
    curr_lemma = curr_structure.get("lemma_count", 0)
    if curr_lemma > prev_lemma:
        reward += NEW_LEMMA_REWARD * (curr_lemma - prev_lemma)

    prev_rec = prev_structure.get("recursion_count", 0)
    curr_rec = curr_structure.get("recursion_count", 0)
    if curr_rec > prev_rec:
        reward += RECURSION_PENALTY * (curr_rec - prev_rec)

    prev_inv = prev_structure.get("invariant_count", 0)
    curr_inv = curr_structure.get("invariant_count", 0)
    if curr_inv > prev_inv:
        reward += NEW_INVARIANT_REWARD * (curr_inv - prev_inv)

    prev_ghost = prev_structure.get("ghost_var_count", 0)
    curr_ghost = curr_structure.get("ghost_var_count", 0)

    ghost_added = curr_ghost > prev_ghost
    error_decrease = curr_total_errors < prev_total_errors
    error_increase = curr_total_errors > prev_total_errors
    no_progress = curr_total_errors == prev_total_errors
    invariant_increase = curr_inv > prev_inv

    if ghost_added:
        if error_decrease:
            reward += GHOST_VAR_ERROR_DECREASE_REWARD
        elif invariant_increase:
            reward += GHOST_VAR_INVARIANT_INCREASE_REWARD
        elif no_progress:
            reward += GHOST_VAR_NO_PROGRESS_PENALTY
        elif error_increase:
            reward += GHOST_VAR_ERROR_INCREASE_PENALTY

    return reward


def compute_efficiency_reward(prompt_token_increase: int) -> float:
    return PROMPT_TOKEN_EFFICIENCY_COEFF * prompt_token_increase


def compute_stability_reward(kl_value: float) -> float:
    return -KL_REWARD_COEFF * kl_value


def compute_total_reward(
    *,
    outcome: str,
    prev_error_counts: Optional[Dict[str, int]] = None,
    curr_error_counts: Optional[Dict[str, int]] = None,
    prev_structure: Optional[Dict[str, int]] = None,
    curr_structure: Optional[Dict[str, int]] = None,
    prompt_token_increase: int = 0,
    kl_value: float = 0.0,
) -> Dict[str, float]:
    prev_error_counts = prev_error_counts or {}
    curr_error_counts = curr_error_counts or {}

    prev_total_errors = sum(prev_error_counts.values())
    curr_total_errors = sum(curr_error_counts.values())

    outcome_reward = compute_outcome_reward(outcome)

    if outcome in {"success", "empty"}:
        progress_reward = 0.0
        structure_reward = 0.0
    else:
        progress_reward = compute_progress_reward(prev_error_counts, curr_error_counts)
        structure_reward = compute_structure_reward(
            prev_structure,
            curr_structure,
            prev_total_errors,
            curr_total_errors,
        )

    efficiency_reward = compute_efficiency_reward(prompt_token_increase)
    stability_reward = compute_stability_reward(kl_value)

    total_reward = (
        outcome_reward
        + progress_reward
        + structure_reward
        + efficiency_reward
        + stability_reward
    )

    return {
        "total_reward": total_reward,
        "outcome_reward": outcome_reward,
        "progress_reward": progress_reward,
        "structure_reward": structure_reward,
        "efficiency_reward": efficiency_reward,
        "stability_reward": stability_reward,
    }


def calculate_example_weight(reward: float, scale: float = 1.0) -> float:
    if reward < 0:
        return 1.0 + scale * abs(reward)
    return 1.0