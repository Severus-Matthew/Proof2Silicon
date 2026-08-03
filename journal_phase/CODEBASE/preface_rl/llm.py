import json
import logging
import os
import random
import re
import time
from typing import Dict, Optional, Tuple

from openai import OpenAI


# Generator experiment modes:
#   deepseek  -> DeepSeek API
#   openai    -> OpenAI API
#   qwen_hf   -> Hugging Face Inference Providers router
#   mixed     -> randomly choose one of the three on the first attempt of a task
GENERATOR_MODE = os.environ.get("DAFNY_GENERATOR_MODE", "deepseek").strip().lower()

DEEPSEEK_BASE_URL = os.environ.get("DEEPSEEK_BASE_URL", "https://api.deepseek.com")
DEEPSEEK_GENERATOR_MODEL = os.environ.get("DEEPSEEK_GENERATOR_MODEL", "deepseek-chat")
OPENAI_GENERATOR_MODEL = os.environ.get("OPENAI_GENERATOR_MODEL", "gpt-5.2")
HF_GENERATOR_MODEL = os.environ.get(
    "HF_GENERATOR_MODEL", "Qwen/Qwen3-Coder-30B-A3B-Instruct:cheapest"
)
HF_BASE_URL = os.environ.get("HF_BASE_URL", "https://router.huggingface.co/v1")

# The semantic judge is deliberately independent from the generator.  Use an
# exact model ID available in the caller's OpenAI project.  The launch scripts
# perform a model-list preflight rather than assuming a ChatGPT product name is
# also an API model ID.
JUDGE_MODEL = os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.2")
JUDGE_PROVIDER = os.environ.get("DAFNY_JUDGE_PROVIDER", "openai").strip().lower()

MIXED_GENERATORS = tuple(
    item.strip() for item in os.environ.get(
        "DAFNY_MIXED_GENERATORS", "deepseek,openai,qwen_hf"
    ).split(",") if item.strip()
)
MIXED_SEED = int(os.environ.get("DAFNY_MIXED_SEED", "20260802"))
_rng = random.Random(MIXED_SEED)
_active_mixed_generator = None


def _require_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(
            "{} is not set. Export it in the shell or job environment; never "
            "hard-code API keys in the repository.".format(name)
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
            timeout=180.0,
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
    invalid = set(MIXED_GENERATORS) - {"deepseek", "openai", "qwen_hf"}
    if invalid:
        raise ValueError("Unsupported mixed generators: {}".format(sorted(invalid)))

    # A first attempt has no prior code/error. Select once and keep the same
    # generator for all repair iterations of that task. This avoids changing
    # generator halfway through an episode.
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

    kwargs = {
        "model": model,
        "messages": [
            {
                "role": "system",
                "content": (
                    "You are an expert Dafny programmer. Solve exactly the supplied "
                    "task. Verifier success alone is insufficient: an independent "
                    "semantic judge rejects code that solves another problem."
                ),
            },
            {"role": "user", "content": full_prompt},
        ],
        "temperature": 0.2,
        "stream": False,
    }
    # Keep enough room for complete Dafny programs across providers.
    if provider in {"deepseek", "qwen_hf"}:
        kwargs["max_tokens"] = int(os.environ.get("DAFNY_GENERATOR_MAX_TOKENS", "4096"))

    response = _client_for(provider).chat.completions.create(**kwargs)
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
            "mixed_seed": MIXED_SEED if GENERATOR_MODE == "mixed" else None,
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
    return None


def judge_semantic_alignment(
    original_task: str,
    dafny_code: str,
) -> Tuple[bool, Dict[str, object]]:
    judge_prompt = """
You are a strict semantic-equivalence judge for Dafny synthesis.
Determine whether the candidate Dafny program actually solves the ORIGINAL TASK,
not merely whether it is valid or verifiable.

Reject the candidate if it:
- solves a different or easier problem;
- changes required inputs, outputs, signatures, or named functions;
- uses placeholders, constant answers, generic examples, or unrelated code;
- omits essential behavior or edge cases from the task;
- only satisfies a weak self-invented specification.

Ignore formatting and proof style. Judge implemented behavior and interface.
Respond with exactly one token: YES or NO. Do not explain.

ORIGINAL TASK:
{task}

CANDIDATE DAFNY CODE:
{code}
""".format(task=original_task.strip(), code=dafny_code.strip())

    metadata = {
        "provider": JUDGE_PROVIDER,
        "model": JUDGE_MODEL,
        "raw_response": "",
        "prompt_tokens": 0,
        "completion_tokens": 0,
        "valid_binary_response": False,
        "error": None,
    }

    try:
        response = _client_for(JUDGE_PROVIDER).chat.completions.create(
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
        usage = getattr(response, "usage", None)
        metadata.update(
            {
                "raw_response": raw,
                "prompt_tokens": int(getattr(usage, "prompt_tokens", 0) or 0),
                "completion_tokens": int(getattr(usage, "completion_tokens", 0) or 0),
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
