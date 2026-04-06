# """
# Prompt construction for the SLM/LLM pipeline.
# """
# from typing import Any


# def ShortPrompt(task: str) -> str:
#     prompt = (
#         "You are an expert in understanding how a downstream LLM responds to instructions for Dafny code generation. \n Your role is to generate high-quality instructions that help the downstream LLM produce correct, complete, \n and verifier-friendly Dafny code.\n\n Given the following task, produce instruction text for the downstream LLM that includes:\n\n 1. Step-by-step reasoning about the logic and specification.\n\n 2. Relevant Dafny constructs and how they should be used.\n\n 3. Important edge cases, invariants, preconditions, postconditions, decreases clauses, and syntax details.\n\n 4. Clear guidance so the downstream LLM returns complete Dafny code.\n\n Original task:\n\n" + task + "\n\n"
#     )
#     return prompt


# def ErrorPrompt(error: str, task: str, code: str, previous_reward: Any, previous_instruction: str = "", previous_llm_response: str = "") -> str:
#     prompt = (
#         "You are an expert in understanding how a downstream LLM responds to instructions for Dafny code generation. \n Your role is to generate improved instructions that help the downstream LLM produce correct and verifier-friendly Dafny code.\n\n Analyze the prior instruction, the downstream LLM response, the generated Dafny code, and the verifier error. Then produce better instructions for the downstream LLM.\n\n Please include:\n\n 1. What likely went wrong in the downstream LLM response.\n\n 2. What the downstream LLM should do differently.\n\n 3. Dafny-specific requirements such as invariants, preconditions, postconditions, decreases clauses, syntax, and semicolon usage where relevant.\n\n 4. A concise but effective instruction that can be passed to the downstream LLM.\n\n Original task:\n\n" + task + "\n\n"
#     )

#     if previous_instruction:
#         prompt += "Previous instruction sent to downstream LLM:\n"
#         prompt += previous_instruction + "\n\n"

#     if previous_llm_response:
#         prompt += "Previous downstream LLM response:\n"
#         prompt += previous_llm_response + "\n\n"

#     prompt += "Previous generated Dafny code:\n"
#     prompt += code + "\n\n"

#     prompt += "Verifier error message:\n"
#     prompt += error + "\n\n"

#     prompt += "Previous reward:\n"
#     prompt += str(previous_reward) + "\n"

#     return prompt



"""
Prompt construction for the SLM/LLM pipeline.

Design goals:
- Keep prompts structured and RL-friendly
- Give the SLM high-level awareness of what improves reward
- Avoid dumping full reward formulas or too much noise
- Fit comfortably under a 1024-token input budget when combined
  with trimmed task/code/error/history
"""

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

Optimization target:
- maximize verification success
- reduce Dafny verifier errors
- encourage useful proof structure only when needed
- avoid recursion
- stay concise and technically precise

What to do:
- understand the task precisely
- identify the required specification and program structure
- mention key Dafny constructs that are likely needed
- point out edge cases, invariants, postconditions, preconditions, helper lemmas, ghost variables, assertions, and decreases clauses when relevant
- guide the downstream LLM to return full Dafny code only

Return instruction text exactly in this format for the task given below:
Task Understanding: <brief summary of what the code must do>
Key Dafny Requirements: <list of requirements>
Proof / Verification Guidance: <list of guidance>
Instruction: <final instruction for the downstream LLM>


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
    task = _trim(task, MAX_TASK_CHARS)
    error = _trim(error, MAX_ERROR_CHARS)
    code = _trim(code, MAX_CODE_CHARS)
    previous_instruction = _trim(previous_instruction, MAX_PREV_INSTR_CHARS)
    previous_llm_response = _trim(previous_llm_response, MAX_PREV_RESPONSE_CHARS)

    return f"""
You are an expert at repairing instructions for a downstream LLM that generates Dafny code.
Your job is NOT to fix the Dafny program directly.
Your job is to analyze the failure and write better instructions so the next generated Dafny code is more likely to verify successfully.

Optimization target:
- improve verifier success
- reduce error counts from the previous attempt
- improve proof structure when useful
- avoid recursion
- keep the instruction stable, focused, and technically precise

When analyzing the failure, focus on the most likely root cause:
- missing or weak invariants
- missing or weak preconditions / postconditions
- missing decreases clause or termination argument
- use of recursion structure
- misuse of lemma / predicate / function / method
- type mismatch or indexing issues
- syntax or formatting mistakes
- incomplete implementation
- mismatch between code and specification

Use the previous instruction and downstream LLM response only to guide a better next instruction.
Do not write the corrected Dafny code yourself.

Return instruction text exactly in this format for the task given below:

Failure Analysis: <brief diagnosis of what most likely went wrong>
What To Change: <list of changes>
Dafny-Specific Guidance: <list of guidance>
Improved Instruction: <final improved instruction for the downstream LLM>

DO NOT WRITE THE DAFNY CODE YOURSELF. ONLY WRITE THE INSTRUCTION.

Original Task:
{task}

Previous Instruction:
{previous_instruction}

Previous Generated Dafny Code:
{code}

Verifier Error:
{error}

Previous Reward:
{previous_reward}
""".strip()