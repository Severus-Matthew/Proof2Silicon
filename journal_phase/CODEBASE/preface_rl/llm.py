import json
import logging
import os
import re
import time
from typing import Dict, Optional, Tuple

from openai import OpenAI


DEEPSEEK_BASE_URL = os.environ.get("DEEPSEEK_BASE_URL", "https://api.deepseek.com")
GENERATOR_MODEL = os.environ.get("DAFNY_GENERATOR_MODEL", "deepseek-chat")
JUDGE_MODEL = os.environ.get("DAFNY_JUDGE_MODEL", "deepseek-reasoner")


def _client() -> OpenAI:
    api_key = os.environ.get("DEEPSEEK_API_KEY")
    if not api_key:
        raise RuntimeError(
            "DEEPSEEK_API_KEY is not set. Export it in the shell or job script; "
            "never hard-code API keys in the repository."
        )
    return OpenAI(api_key=api_key, base_url=DEEPSEEK_BASE_URL)


def save_prompt_response(
    prompt: str,
    response: str,
    save_dir: str,
    metadata: Optional[Dict] = None,
) -> None:
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    os.makedirs(save_dir, exist_ok=True)
    payload = {
        "timestamp": timestamp,
        "prompt": prompt,
        "response": response,
    }
    if metadata:
        payload["metadata"] = metadata
    filename = "interaction_{}_{}.json".format(timestamp, time.time_ns())
    with open(os.path.join(save_dir, filename), "w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2)


def run_LLM(
    prompt: str,
    last_code: str = "",
    last_error: str = "",
) -> Tuple[str, int]:
    full_prompt = ""
    if last_code or last_error:
        full_prompt += "### Previous Attempt Context\n"
        if last_code:
            full_prompt += "### Previous Dafny Code\n{}\n\n".format(last_code.strip())
        if last_error:
            full_prompt += "### Previous Verifier or Judge Feedback\n{}\n\n".format(
                last_error.strip()
            )
        full_prompt += (
            "Repair the previous attempt while preserving the exact original task. "
            "Do not substitute another problem.\n\n"
        )

    full_prompt += prompt.strip()
    full_prompt += """

Mandatory output contract:
- Solve exactly the task stated in the instruction.
- Preserve requested names, signatures, inputs, outputs, and behavior.
- Do not emit a generic example, placeholder, hard-coded answer, or unrelated
  verified program.
- Avoid recursion; use iterative control flow and invariants.
- Return only one complete Dafny program in this form:
```dafny
<complete code>
```
"""

    response = _client().chat.completions.create(
        model=GENERATOR_MODEL,
        messages=[
            {
                "role": "system",
                "content": (
                    "You are an expert Dafny programmer. Solve exactly the supplied "
                    "task. Verifier success alone is not sufficient: a separate "
                    "semantic judge will reject code that solves another problem."
                ),
            },
            {"role": "user", "content": full_prompt},
        ],
        temperature=0.2,
        stream=False,
    )

    generated_text = response.choices[0].message.content or ""
    prompt_count = int(getattr(response.usage, "prompt_tokens", 0) or 0)
    completion_count = int(getattr(response.usage, "completion_tokens", 0) or 0)

    save_prompt_response(
        full_prompt,
        generated_text,
        "/u/mjha1/Proof2Silicon/journal_phase/prompts/llm_journal_final",
        {
            "model": GENERATOR_MODEL,
            "prompt_tokens": prompt_count,
            "completion_tokens": completion_count,
        },
    )
    return generated_text, prompt_count


def _normalize_yes_no(text: str) -> Optional[bool]:
    normalized = re.sub(r"[^A-Za-z]", "", (text or "")).upper()
    if normalized == "YES":
        return True
    if normalized == "NO":
        return False
    # Fail closed when the judge violates the exact-output contract.
    return None


def judge_semantic_alignment(
    original_task: str,
    dafny_code: str,
) -> Tuple[bool, Dict[str, object]]:
    """Return whether verified code solves the original task.

    The judge is intentionally binary. Any API failure, malformed answer, or
    ambiguous response is treated as a rejection so verification cannot bypass
    the semantic guard.
    """
    judge_prompt = """
You are a strict semantic equivalence judge for Dafny synthesis.
Determine whether the candidate Dafny program actually solves the ORIGINAL TASK,
not merely whether it is valid or verifiable.

Reject the candidate if it:
- solves a different or easier problem;
- changes required inputs, outputs, signatures, or named functions;
- uses placeholders, constant answers, generic examples, or unrelated code;
- omits essential behavior or edge cases from the task;
- only satisfies a weak self-invented specification.

Ignore formatting and proof style. Judge the implemented behavior and interface.
Respond with exactly one token: YES or NO. Do not explain.

ORIGINAL TASK:
{task}

CANDIDATE DAFNY CODE:
{code}
""".format(task=original_task.strip(), code=dafny_code.strip())

    metadata: Dict[str, object] = {
        "model": JUDGE_MODEL,
        "raw_response": "",
        "prompt_tokens": 0,
        "completion_tokens": 0,
        "valid_binary_response": False,
        "error": None,
    }

    try:
        response = _client().chat.completions.create(
            model=JUDGE_MODEL,
            messages=[
                {
                    "role": "system",
                    "content": "Return only YES or NO. Be strict about task-code alignment.",
                },
                {"role": "user", "content": judge_prompt},
            ],
            temperature=0.0,
            max_tokens=4,
            stream=False,
        )
        raw = (response.choices[0].message.content or "").strip()
        verdict = _normalize_yes_no(raw)
        metadata.update(
            {
                "raw_response": raw,
                "prompt_tokens": int(getattr(response.usage, "prompt_tokens", 0) or 0),
                "completion_tokens": int(
                    getattr(response.usage, "completion_tokens", 0) or 0
                ),
                "valid_binary_response": verdict is not None,
            }
        )
        passed = verdict is True
    except Exception as exc:
        logging.exception("Semantic judge failed; rejecting candidate: %s", exc)
        metadata["error"] = str(exc)
        passed = False

    metadata["passed"] = passed
    save_prompt_response(
        judge_prompt,
        str(metadata.get("raw_response", "")),
        "/u/mjha1/Proof2Silicon/journal_phase/prompts/judge_journal_final",
        metadata,
    )
    return passed, metadata
