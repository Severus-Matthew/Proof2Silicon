import json
import logging
import os
import random
import re
import time
from typing import Dict, Optional, Tuple

from openai import OpenAI


GENERATOR_MODE = os.environ.get("DAFNY_GENERATOR_MODE", "deepseek").strip().lower()

DEEPSEEK_BASE_URL = os.environ.get("DEEPSEEK_BASE_URL", "https://api.deepseek.com")
DEEPSEEK_GENERATOR_MODEL = os.environ.get("DEEPSEEK_GENERATOR_MODEL", "deepseek-chat")
OPENAI_GENERATOR_MODEL = os.environ.get("OPENAI_GENERATOR_MODEL", "gpt-5.4-mini")
OPENAI_GENERATOR_REASONING = os.environ.get(
    "OPENAI_GENERATOR_REASONING", "medium"
).strip().lower()
HF_GENERATOR_MODEL = os.environ.get(
    "HF_GENERATOR_MODEL", "Qwen/Qwen3-Coder-30B-A3B-Instruct:cheapest"
)
HF_BASE_URL = os.environ.get("HF_BASE_URL", "https://router.huggingface.co/v1")

JUDGE_MODEL = os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.4")
JUDGE_PROVIDER = os.environ.get("DAFNY_JUDGE_PROVIDER", "openai").strip().lower()
JUDGE_REASONING = os.environ.get("DAFNY_JUDGE_REASONING", "low").strip().lower()

MIXED_GENERATORS = tuple(
    item.strip()
    for item in os.environ.get(
        "DAFNY_MIXED_GENERATORS", "openai,qwen_hf"
    ).split(",")
    if item.strip()
)
MIXED_SEED = int(os.environ.get("DAFNY_MIXED_SEED", "20260802"))
_rng = random.Random(MIXED_SEED)
_active_mixed_generator = None


def _require_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(
            "{} is not set. Export it in the shell or Slurm job environment; "
            "never hard-code API keys in the repository.".format(name)
        )
    return value


def _client_for(provider: str) -> OpenAI:
    provider = provider.strip().lower()
    if provider == "deepseek":
        return OpenAI(
            api_key=_require_env("DEEPSEEK_API_KEY"),
            base_url=DEEPSEEK_BASE_URL,
            timeout=180.0,
            max_retries=3,
        )
    if provider == "openai":
        return OpenAI(
            api_key=_require_env("OPENAI_API_KEY"),
            timeout=300.0,
            max_retries=3,
        )
    if provider == "qwen_hf":
        return OpenAI(
            api_key=_require_env("HF_TOKEN"),
            base_url=HF_BASE_URL,
            timeout=240.0,
            max_retries=3,
        )
    raise ValueError("Unknown provider: {!r}".format(provider))


def _model_for(provider: str) -> str:
    if provider == "deepseek":
        return DEEPSEEK_GENERATOR_MODEL
    if provider == "openai":
        return OPENAI_GENERATOR_MODEL
    if provider == "qwen_hf":
        return HF_GENERATOR_MODEL
    raise ValueError("Unknown provider: {!r}".format(provider))


def _choose_generator(new_task: bool) -> str:
    global _active_mixed_generator
    if GENERATOR_MODE != "mixed":
        if GENERATOR_MODE not in {"deepseek", "openai", "qwen_hf"}:
            raise ValueError("Unsupported DAFNY_GENERATOR_MODE={!r}".format(GENERATOR_MODE))
        return GENERATOR_MODE

    if not MIXED_GENERATORS:
        raise ValueError("DAFNY_MIXED_GENERATORS is empty")
    invalid = set(MIXED_GENERATORS) - {"openai", "qwen_hf"}
    if invalid:
        raise ValueError(
            "Mixed journal training permits only openai and qwen_hf; got: {}".format(
                sorted(invalid)
            )
        )

    if new_task or _active_mixed_generator is None:
        _active_mixed_generator = _rng.choice(MIXED_GENERATORS)
    return _active_mixed_generator


def save_prompt_response(
    prompt: str,
    response: str,
    save_dir: str,
    metadata: Optional[Dict] = None,
) -> None:
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    os.makedirs(save_dir, exist_ok=True)
    payload = {"timestamp": timestamp, "prompt": prompt, "response": response}
    if metadata:
        payload["metadata"] = metadata
    filename = "interaction_{}_{}.json".format(timestamp, time.time_ns())
    with open(os.path.join(save_dir, filename), "w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2)


def _extract_response_text(response) -> str:
    text = getattr(response, "output_text", None)
    if text:
        return str(text)
    chunks = []
    for item in getattr(response, "output", []) or []:
        for content in getattr(item, "content", []) or []:
            value = getattr(content, "text", None)
            if value:
                chunks.append(str(value))
    return "\n".join(chunks)


def _response_diagnostics(response) -> Dict[str, object]:
    incomplete = getattr(response, "incomplete_details", None)
    return {
        "response_status": getattr(response, "status", None),
        "incomplete_reason": getattr(incomplete, "reason", None) if incomplete else None,
        "response_id": getattr(response, "id", None),
    }


def _openai_response(model: str, system: str, user: str, reasoning: str, max_tokens: int):
    return _client_for("openai").responses.create(
        model=model,
        instructions=system,
        input=user,
        reasoning={"effort": reasoning},
        max_output_tokens=max_tokens,
    )


def _openai_generate_with_empty_retry(
    model: str,
    system: str,
    user: str,
) -> Tuple[str, int, int, Dict[str, object]]:
    primary_tokens = int(os.environ.get("OPENAI_GENERATOR_MAX_TOKENS", "16384"))
    retry_tokens = int(os.environ.get("OPENAI_GENERATOR_RETRY_MAX_TOKENS", "24576"))
    attempts = [
        (OPENAI_GENERATOR_REASONING, primary_tokens),
        ("low", retry_tokens),
    ]
    attempt_records = []

    for attempt_index, (reasoning, token_budget) in enumerate(attempts, 1):
        response = _openai_response(
            model=model,
            system=system,
            user=user,
            reasoning=reasoning,
            max_tokens=token_budget,
        )
        text = _extract_response_text(response).strip()
        usage = getattr(response, "usage", None)
        input_tokens = int(getattr(usage, "input_tokens", 0) or 0)
        output_tokens = int(getattr(usage, "output_tokens", 0) or 0)
        diagnostics = _response_diagnostics(response)
        attempt_records.append(
            {
                "attempt": attempt_index,
                "reasoning_effort": reasoning,
                "max_output_tokens": token_budget,
                "input_tokens": input_tokens,
                "output_tokens": output_tokens,
                "visible_response_empty": not bool(text),
                **diagnostics,
            }
        )
        if text:
            return text, input_tokens, output_tokens, {
                "attempt_count": attempt_index,
                "attempts": attempt_records,
                "empty_response_recovered": attempt_index > 1,
            }
        logging.warning(
            "OpenAI generator returned no visible text on attempt %s "
            "(reasoning=%s, max_output_tokens=%s, output_tokens=%s, status=%s, incomplete=%s)",
            attempt_index,
            reasoning,
            token_budget,
            output_tokens,
            diagnostics.get("response_status"),
            diagnostics.get("incomplete_reason"),
        )

    return "", input_tokens, output_tokens, {
        "attempt_count": len(attempts),
        "attempts": attempt_records,
        "empty_response_recovered": False,
        "all_attempts_empty": True,
    }


def run_LLM(
    prompt: str,
    last_code: str = "",
    last_error: str = "",
) -> Tuple[str, int]:
    new_task = not bool(last_code or last_error)
    provider = _choose_generator(new_task=new_task)
    model = _model_for(provider)

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

    system = (
        "You are an expert Dafny programmer. Solve exactly the supplied task. "
        "Verifier success alone is insufficient: an independent anti-reward-hacking "
        "judge rejects code for a different task."
    )

    retry_metadata: Dict[str, object] = {}
    if provider == "openai":
        generated_text, prompt_count, completion_count, retry_metadata = (
            _openai_generate_with_empty_retry(
                model=model,
                system=system,
                user=full_prompt,
            )
        )
    else:
        max_tokens = int(os.environ.get("DAFNY_GENERATOR_MAX_TOKENS", "8192"))
        response = _client_for(provider).chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": full_prompt},
            ],
            temperature=0.2,
            max_tokens=max_tokens,
            stream=False,
        )
        generated_text = response.choices[0].message.content or ""
        usage = getattr(response, "usage", None)
        prompt_count = int(getattr(usage, "prompt_tokens", 0) or 0)
        completion_count = int(getattr(usage, "completion_tokens", 0) or 0)

    save_prompt_response(
        full_prompt,
        generated_text,
        "/u/mjha1/Proof2Silicon/journal_phase/prompts/llm_journal_final",
        {
            "experiment_mode": GENERATOR_MODE,
            "selected_provider": provider,
            "model": model,
            "reasoning_effort": OPENAI_GENERATOR_REASONING if provider == "openai" else None,
            "mixed_generators": list(MIXED_GENERATORS) if GENERATOR_MODE == "mixed" else None,
            "mixed_seed": MIXED_SEED if GENERATOR_MODE == "mixed" else None,
            "prompt_tokens": prompt_count,
            "completion_tokens": completion_count,
            "visible_response_empty": not bool(generated_text.strip()),
            **retry_metadata,
        },
    )
    return generated_text, prompt_count


def _normalize_yes_no(text: str) -> Optional[bool]:
    normalized = re.sub(r"[^A-Za-z]", "", (text or "")).upper()
    if normalized == "YES":
        return True
    if normalized == "NO":
        return False
    return None


def judge_semantic_alignment(
    original_task: str,
    dafny_code: str,
) -> Tuple[bool, Dict[str, object]]:
    judge_prompt = """
You are an anti-reward-hacking topical-alignment judge for Dafny synthesis.
Your ONLY question is whether the candidate is genuinely attempting the SAME
problem described by the original task.

Return YES when the candidate addresses the same requested algorithm, operation,
data, named routines, and overall input/output intent, EVEN IF the implementation
is buggy, incomplete, over-constrained, under-specified, inefficient, or would
fail some tests. Dafny has already checked formal validity separately; do not
re-grade functional correctness, proof quality, edge-case completeness, or style.

Return NO only for semantic reward hacking or clear task substitution, such as:
- solving a different algorithm or unrelated problem;
- replacing the requested computation with a constant, placeholder, or toy demo;
- removing or replacing the central requested operation;
- changing named routines/interfaces so substantially that it is no longer an
  implementation of the same task.

Minor signature choices, extra preconditions, imperfect tests, missing edge cases,
or an incorrect implementation of the intended algorithm are still YES, provided
the candidate is clearly about the same problem.

Respond with exactly one token: YES or NO.

ORIGINAL TASK:
{task}

CANDIDATE DAFNY CODE:
{code}
""".format(task=original_task.strip(), code=dafny_code.strip())

    metadata = {
        "provider": JUDGE_PROVIDER,
        "model": JUDGE_MODEL,
        "reasoning_effort": JUDGE_REASONING,
        "judge_scope": "same_problem_only_not_correctness",
        "raw_response": "",
        "prompt_tokens": 0,
        "completion_tokens": 0,
        "valid_binary_response": False,
        "error": None,
    }

    try:
        if JUDGE_PROVIDER == "openai":
            response = _openai_response(
                model=JUDGE_MODEL,
                system=(
                    "Judge only whether this is the same problem, not whether the "
                    "implementation is correct. Return exactly YES or NO."
                ),
                user=judge_prompt,
                reasoning=JUDGE_REASONING,
                max_tokens=int(os.environ.get("DAFNY_JUDGE_MAX_TOKENS", "512")),
            )
            raw = _extract_response_text(response).strip()
            usage = getattr(response, "usage", None)
            prompt_tokens = int(getattr(usage, "input_tokens", 0) or 0)
            completion_tokens = int(getattr(usage, "output_tokens", 0) or 0)
            metadata.update(_response_diagnostics(response))
        else:
            response = _client_for(JUDGE_PROVIDER).chat.completions.create(
                model=JUDGE_MODEL,
                messages=[
                    {
                        "role": "system",
                        "content": (
                            "Judge only same-problem alignment, not correctness. "
                            "Return exactly YES or NO."
                        ),
                    },
                    {"role": "user", "content": judge_prompt},
                ],
                temperature=0.0,
                max_tokens=8,
                stream=False,
            )
            raw = (response.choices[0].message.content or "").strip()
            usage = getattr(response, "usage", None)
            prompt_tokens = int(getattr(usage, "prompt_tokens", 0) or 0)
            completion_tokens = int(getattr(usage, "completion_tokens", 0) or 0)

        verdict = _normalize_yes_no(raw)
        metadata.update(
            {
                "raw_response": raw,
                "prompt_tokens": prompt_tokens,
                "completion_tokens": completion_tokens,
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
