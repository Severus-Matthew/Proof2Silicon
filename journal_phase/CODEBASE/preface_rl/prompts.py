from typing import Any, Dict, Iterable, List, Optional, Tuple


MAX_TASK_CHARS = 4200
MAX_ERROR_CHARS = 2200
MAX_CODE_CHARS = 3000
MAX_PREV_INSTR_CHARS = 1600
MAX_PREV_RESPONSE_CHARS = 900
MAX_FEEDBACK_CHARS = 2600


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
        lines.append("- Missing required heading: {}".format(heading))
    for pattern in quality.get("forbidden_patterns", []) or []:
        lines.append("- Forbidden output pattern detected: {}".format(pattern))

    repeated_lines = int(quality.get("repeated_line_count", 0) or 0)
    if repeated_lines > 0:
        lines.append("- Repeated {} non-empty line(s).".format(repeated_lines))

    repeated_ratio = float(quality.get("repeated_fourgram_ratio", 0.0) or 0.0)
    if repeated_ratio >= 0.20:
        lines.append(
            "- Excessive phrase repetition: repeated four-gram ratio {:.3f}.".format(
                repeated_ratio
            )
        )

    word_count = int(quality.get("word_count", 0) or 0)
    if word_count > 650:
        lines.append("- Output was too long: {} words (preferred maximum 650).".format(word_count))
    if word_count and word_count < 35:
        lines.append("- Output was too short to cover the requested structure: {} words.".format(word_count))

    if quality and not bool(quality.get("valid", False)) and not lines:
        lines.append("- The previous instruction failed the structured prompt-quality check.")
    return lines


def format_negative_training_feedback(
    quality_analysis: Optional[Dict[str, Any]] = None,
    reward_breakdown: Optional[Dict[str, Any]] = None,
) -> str:
    """Convert negative analysis/reward values into textual repair guidance."""
    lines = _quality_defect_lines(quality_analysis)
    seen = set(lines)

    for source_name, payload in (
        ("quality", quality_analysis or {}),
        ("reward", reward_breakdown or {}),
    ):
        for key, value in _negative_numeric_items(payload):
            line = "- Negative {} signal: {} = {:.4f}.".format(source_name, key, value)
            if line not in seen:
                lines.append(line)
                seen.add(line)

    if not lines:
        return "- No negative prompt-quality or reward component was recorded."
    return _trim_head("\n".join(lines), MAX_FEEDBACK_CHARS)


def ShortPrompt(task: str) -> str:
    task = _trim_head(task, MAX_TASK_CHARS)
    return f"""
Write a complete instruction for a downstream Dafny code generator.
Do not write Dafny code. Do not add facts, signatures, names, or edge-case
behavior that the original task does not specify. Preserve every name that is
specified, including spelling. Do not replace the task with a different one.

Use exactly these five headings, once each, with no preamble or closing text:
Task Summary:
Required Interface:
Behavioral Obligations:
Verification Plan:
Instruction:

Rules:
- Cover all task details needed by the downstream model; prefer clarity over
  artificial brevity, while avoiding repetition and filler.
- State unknown interface details as "infer from the provided task/source".
- Require complete Dafny code from the downstream model in one fenced block.
- Prefer iterative loops and explicit invariants; prohibit recursion.
- Require semantic fidelity because a separate judge checks task-code alignment.
- Never include a Dafny fenced block yourself.

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
    previous_llm_response = _trim_head(previous_llm_response, MAX_PREV_RESPONSE_CHARS)
    negative_feedback = format_negative_training_feedback(
        quality_analysis=quality_analysis,
        reward_breakdown=reward_breakdown,
    )

    return f"""
Repair the instruction for a downstream Dafny code generator. Output only the
four fields below. Do not write Dafny code, repeat filler, invent interfaces, or
change the original task.

Use exactly these headings, once each:
Failure Cause:
Semantic Check:
Required Repair:
Instruction:

Rules:
- Produce enough detail to cover the complete task, but avoid repetition.
- Explicitly correct every negative training-analysis item listed below.
- Diagnose the concrete newest verifier/judge feedback.
- Preserve all original names and specified behavior.
- If the original task leaves a signature or no-match behavior unspecified,
  explicitly tell the downstream model to infer it from the source/task rather
  than inventing one.
- Require iterative, non-recursive Dafny with useful invariants.
- Never include a Dafny fenced block yourself.

Original Task:
{task}

Negative Training-Analysis Feedback From the Previous Attempt:
{negative_feedback}

Newest Verifier/Judge Feedback:
{error}

Previous Reward:
{previous_reward}

Previous Instruction (abbreviated):
{previous_instruction}

Previous Generated Code (abbreviated):
{code}

Previous Downstream Response (abbreviated):
{previous_llm_response}
""".strip()
