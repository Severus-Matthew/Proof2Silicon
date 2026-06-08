from typing import Any, Optional


# --------------------------------------------------
# Trimming helpers
# --------------------------------------------------

MAX_TASK_CHARS = 2200
MAX_ERROR_CHARS = 1200
MAX_CODE_CHARS = 3500
MAX_PREV_INSTR_CHARS = 1800
MAX_PREV_RESPONSE_CHARS = 2200


def _clean(text: Optional[str]) -> str:
    if text is None:
        return ""
    return str(text).strip()


def _trim(text: Optional[str], max_chars: int) -> str:
    text = _clean(text)
    if len(text) <= max_chars:
        return text
    return text[:max_chars].rstrip() + "\n...[truncated]"


# --------------------------------------------------
# Prompt builders
# --------------------------------------------------

def ShortPrompt(task: str) -> str:
    task = _trim(task, MAX_TASK_CHARS)

    return f"""
You are an expert at writing instructions for a downstream LLM that generates Dafny code.
Your job is NOT to write the Dafny solution directly.
Your job is to produce the best possible instruction so the downstream LLM generates complete, correct, and verifier-friendly Dafny code.



Goal:
Maximize verification success with minimal, precise guidance also avoid recursion.

Do:
- understand task
- identify required spec + structure
- include only necessary Dafny elements (invariants, pre/post, decreases if needed)
- mention edge cases if critical
- ensure full code is returned
- make sure that recursion is not used

The rewards are calculated based on the verification success, absence of recursion, the presence and use of lemmas and ghost variables and the efficeiny of the prompt.

Format:
Task: <1-line summary>
Requirements: <key Dafny constraints>
Verification: <proof hints if needed>
Instruction: <final instruction>


DO NOT WRITE THE DAFNY CODE YOURSELF. ONLY WRITE THE INSTRUCTION.
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

    return f"""
You are an expert at repairing instructions for a downstream LLM that generates Dafny code.
Your job is NOT to fix the Dafny program directly.
Your job is to analyze the failure and write better instructions so the next generated Dafny code is more likely to verify successfully.

Goal:
Increase verification success. Fix root cause only. Avoid recursion. reduce error counts from the previous attempt.

Focus:
- invariants / specs missing or weak
- termination (decreases)
- type/index errors
- incomplete or incorrect logic
- Syntax or formatting mistakes
- Incomplete implementation
- Mismatch between code and specification
- make sure that recursion is not used
The rewards are calculated based on the verification success, absence of recursion, the presence and use of lemmas and ghost variables and the efficeiny of the prompt.

Do NOT write code.

Format:
Cause: <main failure reason>
Fix: <what to change>
Instruction: <improved instruction>

Below is the previous output and task.

Task:
{task}


Code:
{code}

Error:
{error}

Reward:
{previous_reward}
""".strip()
