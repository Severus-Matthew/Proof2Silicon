from typing import Any, Optional


MAX_TASK_CHARS = 3000
MAX_ERROR_CHARS = 1600
MAX_CODE_CHARS = 2200
MAX_PREV_INSTR_CHARS = 900
MAX_PREV_RESPONSE_CHARS = 700


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


def ShortPrompt(task: str) -> str:
    task = _trim_head(task, MAX_TASK_CHARS)
    return f"""
Write a concise instruction for a downstream Dafny code generator.
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
- Each field must be concise; total response should stay under 300 words.
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
) -> str:
    task = _trim_head(task, MAX_TASK_CHARS)
    error = _trim_tail(error, MAX_ERROR_CHARS)
    code = _trim_head(code, MAX_CODE_CHARS)
    previous_instruction = _trim_head(previous_instruction, MAX_PREV_INSTR_CHARS)
    previous_llm_response = _trim_head(previous_llm_response, MAX_PREV_RESPONSE_CHARS)

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
- Total response must stay under 300 words.
- Diagnose the concrete newest verifier/judge feedback.
- Preserve all original names and specified behavior.
- If the original task leaves a signature or no-match behavior unspecified,
  explicitly tell the downstream model to infer it from the source/task rather
  than inventing one.
- Require iterative, non-recursive Dafny with useful invariants.
- Never include a Dafny fenced block yourself.

Original Task:
{task}

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
