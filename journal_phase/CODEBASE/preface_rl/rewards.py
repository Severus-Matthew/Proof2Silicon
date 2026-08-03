from typing import Dict, Optional


# Outcome rewards. Verification alone is deliberately insufficient: a verified
# program receives the full positive reward only when the semantic judge agrees
# that it solves the original task.
REWARD_VERIFIED_AND_ALIGNED = 12.0
REWARD_VERIFIED_BUT_MISALIGNED = -15.0
REWARD_EMPTY = -10.0
REWARD_TIMEOUT = -8.0

ERROR_WEIGHTS = {
    "syntax": 0.2,
    "type": 0.3,
    "missing_invariant": 0.8,
    "postcondition": 1.0,
    "timeout": 1.2,
}

NEW_LEMMA_REWARD = 0.2
NEW_INVARIANT_REWARD = 0.3

# Recursion-aware shaping.  The reward depends on both the absolute recursion
# count and whether recursion was introduced, removed, or retained.
RECURSION_INTRODUCTION_PENALTY = -3.0
RECURSION_PERSISTENCE_PENALTY = -1.0
RECURSION_REMOVAL_REWARD = 2.0
RECURSION_PER_CALL_PENALTY = -0.75
RECURSION_ON_SUCCESS_PENALTY = -2.0

GHOST_VAR_ERROR_DECREASE_REWARD = 0.4
GHOST_VAR_INVARIANT_INCREASE_REWARD = 0.2
GHOST_VAR_NO_PROGRESS_PENALTY = -0.2
GHOST_VAR_ERROR_INCREASE_PENALTY = -0.5

PROMPT_TOKEN_EFFICIENCY_COEFF = -0.001
KL_REWARD_COEFF = 0.1


def compute_outcome_reward(outcome: str, semantic_judge_pass: Optional[bool]) -> float:
    if outcome == "success":
        if semantic_judge_pass is True:
            return REWARD_VERIFIED_AND_ALIGNED
        if semantic_judge_pass is False:
            return REWARD_VERIFIED_BUT_MISALIGNED
        # Missing/failed judge calls must not silently receive the success bonus.
        return 0.0
    if outcome == "empty":
        return REWARD_EMPTY
    if outcome == "timeout":
        return REWARD_TIMEOUT
    return 0.0


def compute_progress_reward(
    prev_error_counts: Optional[Dict[str, int]],
    curr_error_counts: Optional[Dict[str, int]],
) -> float:
    prev_error_counts = prev_error_counts or {}
    curr_error_counts = curr_error_counts or {}

    reward = 0.0
    for error_type, weight in ERROR_WEIGHTS.items():
        reward += weight * (
            prev_error_counts.get(error_type, 0)
            - curr_error_counts.get(error_type, 0)
        )
    return reward


def compute_recursion_reward(
    prev_structure: Optional[Dict[str, int]],
    curr_structure: Optional[Dict[str, int]],
    outcome: str,
) -> float:
    prev_structure = prev_structure or {}
    curr_structure = curr_structure or {}

    prev_rec = max(0, int(prev_structure.get("recursion_count", 0)))
    curr_rec = max(0, int(curr_structure.get("recursion_count", 0)))

    reward = RECURSION_PER_CALL_PENALTY * curr_rec

    if prev_rec == 0 and curr_rec > 0:
        reward += RECURSION_INTRODUCTION_PENALTY
    elif prev_rec > 0 and curr_rec == 0:
        reward += RECURSION_REMOVAL_REWARD
    elif prev_rec > 0 and curr_rec > 0:
        reward += RECURSION_PERSISTENCE_PENALTY

    # A verified recursive program is still less desirable for this pipeline,
    # because downstream HLS/PyLog compatibility is a core objective.
    if outcome == "success" and curr_rec > 0:
        reward += RECURSION_ON_SUCCESS_PENALTY

    return reward


def compute_structure_reward(
    prev_structure: Optional[Dict[str, int]],
    curr_structure: Optional[Dict[str, int]],
    prev_total_errors: int,
    curr_total_errors: int,
    outcome: str,
) -> Dict[str, float]:
    prev_structure = prev_structure or {}
    curr_structure = curr_structure or {}

    lemma_reward = 0.0
    invariant_reward = 0.0
    ghost_reward = 0.0

    prev_lemma = prev_structure.get("lemma_count", 0)
    curr_lemma = curr_structure.get("lemma_count", 0)
    if curr_lemma > prev_lemma:
        lemma_reward = NEW_LEMMA_REWARD * (curr_lemma - prev_lemma)

    prev_inv = prev_structure.get("invariant_count", 0)
    curr_inv = curr_structure.get("invariant_count", 0)
    if curr_inv > prev_inv:
        invariant_reward = NEW_INVARIANT_REWARD * (curr_inv - prev_inv)

    prev_ghost = prev_structure.get("ghost_var_count", 0)
    curr_ghost = curr_structure.get("ghost_var_count", 0)
    ghost_added = curr_ghost > prev_ghost

    if ghost_added:
        if curr_total_errors < prev_total_errors:
            ghost_reward = GHOST_VAR_ERROR_DECREASE_REWARD
        elif curr_inv > prev_inv:
            ghost_reward = GHOST_VAR_INVARIANT_INCREASE_REWARD
        elif curr_total_errors == prev_total_errors:
            ghost_reward = GHOST_VAR_NO_PROGRESS_PENALTY
        else:
            ghost_reward = GHOST_VAR_ERROR_INCREASE_PENALTY

    recursion_reward = compute_recursion_reward(
        prev_structure,
        curr_structure,
        outcome,
    )

    return {
        "lemma_reward": lemma_reward,
        "invariant_reward": invariant_reward,
        "ghost_reward": ghost_reward,
        "recursion_reward": recursion_reward,
        "structure_reward": (
            lemma_reward
            + invariant_reward
            + ghost_reward
            + recursion_reward
        ),
    }


def compute_efficiency_reward(prompt_token_increase: int) -> float:
    return PROMPT_TOKEN_EFFICIENCY_COEFF * max(0, prompt_token_increase)


def compute_stability_reward(kl_value: float, epoch: int = 0) -> float:
    if epoch < 2:
        return 0.0
    return -KL_REWARD_COEFF * max(0.0, float(kl_value))


def compute_total_reward(
    *,
    outcome: str,
    semantic_judge_pass: Optional[bool] = None,
    prev_error_counts: Optional[Dict[str, int]] = None,
    curr_error_counts: Optional[Dict[str, int]] = None,
    prev_structure: Optional[Dict[str, int]] = None,
    curr_structure: Optional[Dict[str, int]] = None,
    prompt_token_increase: int = 0,
    kl_value: float = 0.0,
    epoch: int = 0,
) -> Dict[str, float]:
    prev_error_counts = prev_error_counts or {}
    curr_error_counts = curr_error_counts or {}

    prev_total_errors = sum(prev_error_counts.values())
    curr_total_errors = sum(curr_error_counts.values())

    outcome_reward = compute_outcome_reward(outcome, semantic_judge_pass)

    if outcome in {"success", "empty"}:
        progress_reward = 0.0
    else:
        progress_reward = compute_progress_reward(
            prev_error_counts,
            curr_error_counts,
        )

    structure = compute_structure_reward(
        prev_structure,
        curr_structure,
        prev_total_errors,
        curr_total_errors,
        outcome,
    )
    efficiency_reward = compute_efficiency_reward(prompt_token_increase)
    stability_reward = compute_stability_reward(kl_value, epoch)

    total_reward = (
        outcome_reward
        + progress_reward
        + structure["structure_reward"]
        + efficiency_reward
        + stability_reward
    )

    return {
        "total_reward": total_reward,
        "outcome_reward": outcome_reward,
        "semantic_judge_reward": (
            REWARD_VERIFIED_AND_ALIGNED
            if outcome == "success" and semantic_judge_pass is True
            else REWARD_VERIFIED_BUT_MISALIGNED
            if outcome == "success" and semantic_judge_pass is False
            else 0.0
        ),
        "semantic_judge_pass": float(semantic_judge_pass is True),
        "progress_reward": progress_reward,
        "structure_reward": structure["structure_reward"],
        "recursion_reward": structure["recursion_reward"],
        "lemma_reward": structure["lemma_reward"],
        "invariant_reward": structure["invariant_reward"],
        "ghost_reward": structure["ghost_reward"],
        "efficiency_reward": efficiency_reward,
        "stability_reward": stability_reward,
    }


def calculate_example_weight(reward: float, scale: float = 1.0) -> float:
    if reward < 0:
        return 1.0 + scale * min(abs(reward), 20.0)
    return 1.0
