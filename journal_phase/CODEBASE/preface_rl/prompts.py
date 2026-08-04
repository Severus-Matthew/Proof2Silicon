from typing import Any, Dict, Iterable, List, Optional, Tuple


# Character budgets are deliberately conservative because the rendered Qwen
# chat template is capped at 1,600 tokens. These limits keep the complete task,
# newest verifier feedback, and negative training feedback visible without
# depending on global tokenizer truncation.
MAX_TASK_CHARS = 1800
MAX_ERROR_CHARS = 1100
MAX_CODE_CHARS = 750
MAX_PREV_INSTR_CHARS = 500
MAX_FEEDBACK_CHARS = 850


def _clean(text: Optional[str]) -> str:
    if text is None:
        return ""
    return str(text).strip()


def _trim_head(text: Optional[str], max_chars: int) -> str:
    text = _clean(text)
    if len(text) <= max_chars:
        return text
    return text[:max_chars].rstrip() + "\n...[truncated]"


def _trim_tail(text: Optional[str], max_chars: int) -> str:
    """Keep the newest verifier/judge lines, which are usually at the end."""
    text = _clean(text)
    if len(text) <= max_chars:
        return text
    return "...[earlier output truncated]\n" + text[-max_chars:].lstrip()


def _negative_numeric_items(
    payload: Any,
    prefix: str = "",
) -> Iterable[Tuple[str, float]]:
    """Yield every finite negative numeric leaf from nested analysis JSON."""
    if isinstance(payload, dict):
        for key, value in payload.items():
            child = "{}.{}".format(prefix, key) if prefix else str(key)
            yield from _negative_numeric_items(value, child)
    elif isinstance(payload, (list, tuple)):
        for index, value in enumerate(payload):
            child = "{}[{}]".format(prefix, index)
            yield from _negative_numeric_items(value, child)
    elif isinstance(payload, (int, float)) and not isinstance(payload, bool):
        value = float(payload)
        if value < 0 and value == value and value not in (float("inf"), float("-inf")):
            yield prefix or "negative_value", value


def _quality_defect_lines(quality: Optional[Dict[str, Any]]) -> List[str]:
    quality = quality or {}
    lines: List[str] = []

    for heading in quality.get("missing_headings", []) or []:
        lines.append("- Add missing heading {}".format(heading))
    for pattern in quality.get("forbidden_patterns", []) or []:
        lines.append("- Remove forbidden pattern {}".format(pattern))

    repeated_lines = int(quality.get("repeated_line_count", 0) or 0)
    if repeated_lines > 0:
        lines.append("- Remove {} repeated line(s)".format(repeated_lines))

    repeated_ratio = float(quality.get("repeated_fourgram_ratio", 0.0) or 0.0)
    if repeated_ratio >= 0.20:
        lines.append("- Reduce phrase repetition (4-gram ratio {:.3f})".format(repeated_ratio))

    word_count = int(quality.get("word_count", 0) or 0)
    if word_count > 650:
        lines.append("- Shorten output from {} words to at most 650".format(word_count))
    if word_count and word_count < 35:
        lines.append("- Expand incomplete output of only {} words".format(word_count))

    if quality and not bool(quality.get("valid", False)) and not lines:
        lines.append("- Fix the failed structured prompt-quality check")
    return lines


def format_negative_training_feedback(
    quality_analysis: Optional[Dict[str, Any]] = None,
    reward_breakdown: Optional[Dict[str, Any]] = None,
) -> str:
    """Convert all negative analysis/reward leaves into compact repair feedback."""
    lines = _quality_defect_lines(quality_analysis)
    seen = set(lines)

    for source_name, payload in (
        ("quality", quality_analysis or {}),
        ("reward", reward_breakdown or {}),
    ):
        for key, value in _negative_numeric_items(payload):
            line = "- {}.{}={:.3f}".format(source_name, key, value)
            if line not in seen:
                lines.append(line)
                seen.add(line)

    if not lines:
        return "- No negative quality or reward signal recorded"
    return _trim_head("\n".join(lines), MAX_FEEDBACK_CHARS)


def ShortPrompt(task: str) -> str:
    task = _trim_head(task, MAX_TASK_CHARS)
    return f"""
Write an instruction for a downstream Dafny generator. Do not write Dafny code,
invent missing facts/signatures, rename specified symbols, or change the task.

Use each heading exactly once:
Task Summary:
Required Interface:
Behavioral Obligations:
Verification Plan:
Instruction:

Requirements:
- Cover the full task without repetition or filler.
- For unspecified interface details, say "infer from the provided task/source".
- Require complete Dafny code in one fenced block, iterative logic, useful
  invariants, no recursion, and exact semantic fidelity.
- Never include a Dafny code block yourself.

Original Task:
{task}
""".strip()


def ErrorPrompt(
    error: str,
    task: str,
    code: str,
    previous_reward: Any,
    previous_instruction: str = "",
    previous_llm_response: str = "",
    quality_analysis: Optional[Dict[str, Any]] = None,
    reward_breakdown: Optional[Dict[str, Any]] = None,
) -> str:
    task = _trim_head(task, MAX_TASK_CHARS)
    error = _trim_tail(error, MAX_ERROR_CHARS)
    code = _trim_head(code, MAX_CODE_CHARS)
    previous_instruction = _trim_head(previous_instruction, MAX_PREV_INSTR_CHARS)
    negative_feedback = format_negative_training_feedback(
        quality_analysis=quality_analysis,
        reward_breakdown=reward_breakdown,
    )

    # previous_llm_response is intentionally omitted: the extracted Dafny code
    # and verifier/judge output contain the actionable information, while the
    # full downstream prose duplicated context and consumed the 1,600-token
    # SLM input budget.
    return f"""
Repair the downstream Dafny instruction. Do not write Dafny code, invent an
interface, rename symbols, repeat filler, or change the original task.

Use each heading exactly once:
Failure Cause:
Semantic Check:
Required Repair:
Instruction:

Correct every negative item below, address the newest verifier/judge failure,
preserve specified behavior and names, infer unspecified details from the
source/task, and require iterative non-recursive Dafny with useful invariants.

Original Task:
{task}

Negative Previous Signals:
{negative_feedback}

Newest Verifier/Judge Feedback:
{error}

Previous Reward: {previous_reward}

Previous Instruction (abbreviated):
{previous_instruction}

Previous Dafny Code (abbreviated):
{code}
""".strip()
