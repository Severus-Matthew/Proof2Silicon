from typing import Any, Optional


MAX_TASK_CHARS = 4000
MAX_ERROR_CHARS = 1800
MAX_CODE_CHARS = 5000
MAX_PREV_INSTR_CHARS = 2200
MAX_PREV_RESPONSE_CHARS = 2600


def _clean(text: Optional[str]) -> str:
    if text is None:
        return ""
    return str(text).strip()


def _trim(text: Optional[str], max_chars: int) -> str:
    text = _clean(text)
    if len(text) <= max_chars:
        return text
    return text[:max_chars].rstrip() + "\n...[truncated]"


def ShortPrompt(task: str) -> str:
    task = _trim(task, MAX_TASK_CHARS)
    return f"""
You are the prompt-policy model for a downstream Dafny code generator.
You must write an instruction that solves exactly the original task below.
You are NOT allowed to replace the task with an easier problem, a generic demo,
a constant-returning implementation, an unrelated verified program, or a program
that merely compiles. Semantic fidelity to the original task is mandatory.

Your output is only an instruction for the downstream code model; do not write
Dafny code yourself.

Requirements for your instruction:
- restate the exact requested inputs, outputs, behavior, and edge cases;
- preserve every named function/method and required signature when specified;
- require a complete executable Dafny implementation, not a placeholder;
- require that postconditions correspond to the requested computation;
- prefer iterative loops and explicit invariants; do not use recursion;
- do not introduce a different algorithmic task to obtain verification reward;
- tell the code model that a separate semantic judge will compare the original
  task and generated code, so verifier success alone is insufficient;
- ask for only the full Dafny code in one fenced block.

Return exactly this structure:
Task Summary: <faithful one-line summary>
Required Interface: <required names/signatures, or "infer from task">
Behavioral Obligations: <what must be computed>
Verification Plan: <invariants/specification guidance>
Instruction: <final instruction to the downstream Dafny model>

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
    task = _trim(task, MAX_TASK_CHARS)
    error = _trim(error, MAX_ERROR_CHARS)
    code = _trim(code, MAX_CODE_CHARS)
    previous_instruction = _trim(previous_instruction, MAX_PREV_INSTR_CHARS)
    previous_llm_response = _trim(previous_llm_response, MAX_PREV_RESPONSE_CHARS)

    return f"""
You are repairing an instruction for a downstream Dafny code generator.
The next attempt must solve exactly the original task. Do not substitute an
easier or unrelated verified program, do not emit a generic FindMax example,
and do not optimize only for the Dafny verifier. A semantic judge will compare
the original task against the generated code.

Your output is only a revised instruction, not Dafny code.

Repair priorities:
1. Preserve the original requested behavior and interface.
2. Fix the concrete verifier/compiler failure shown below.
3. Remove recursion and replace it with loop-based logic and invariants.
4. Prevent semantic drift, placeholders, hard-coded outputs, and unrelated code.
5. Require complete code in one Dafny fenced block.

Return exactly this structure:
Failure Cause: <root cause>
Semantic Check: <how the previous code differs from the original task, or "aligned">
Required Repair: <specific changes>
Instruction: <complete improved instruction for the downstream model>

Original Task:
{task}

Previous Instruction:
{previous_instruction}

Previous Generated Code:
{code}

Previous LLM Response:
{previous_llm_response}

Verifier/Judge Feedback:
{error}

Previous Reward:
{previous_reward}
""".strip()
