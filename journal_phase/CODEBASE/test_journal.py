#!/usr/bin/env python3
"""Journal evaluation harness for Proof2Silicon.

This script evaluates held-out Dafny tasks from Input_dataset_3 under a controlled
matrix of instructor conditions and downstream coding models.

Instructor conditions
---------------------
1. trained:<policy>  - Qwen3-1.7B prompt policy loaded from a journal checkpoint
2. untrained         - the same Qwen3-1.7B prompt-policy architecture, no RL checkpoint
3. none              - downstream coding LLM receives the task directly
4. self              - the same downstream coding LLM first acts as instructor, then coder

The three trained policies are the OpenAI-trained, Qwen-trained, and mixed-trained
journal runs. Cross-generator evaluation is obtained simply by pairing any trained
policy with any downstream coding model.

The harness records pass@1/3/5/7, attempts-to-success, semantic-aligned verified
success, recursion, token counts, wall time, and the complete trajectory. It also
supports inference-time LoRA-strength and SLM-decoding ablations without retraining.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import logging
import os
import random
import re
import subprocess
import sys
import time
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

import torch
from openai import OpenAI

CODEBASE = Path(__file__).resolve().parent
if str(CODEBASE) not in sys.path:
    sys.path.insert(0, str(CODEBASE))

from preface_rl.slm import SLMPG
from preface_rl.slm_qwen3 import initialize_slm as initialize_qwen3_slm


# -----------------------------------------------------------------------------
# Stable paths / defaults
# -----------------------------------------------------------------------------

ROOT = Path("/u/mjha1/Proof2Silicon/journal_phase")
DEFAULT_DATASET = ROOT / "Input_dataset_3"
DEFAULT_OUTPUT = ROOT / "journal_eval"
SLM_MODEL_NAME = os.environ.get("SLM_MODEL_NAME", "Qwen/Qwen3-1.7B")

POLICY_CHECKPOINTS: Dict[str, Path] = {
    "openai": ROOT / "journal_runs/journal_journal_final_v6_openai/checkpoints/final_model.pt",
    "qwen": ROOT / "journal_runs/journal_journal_final_v9_qwen_hf/checkpoints/final_model.pt",
    "mixed": ROOT / "journal_runs/journal_journal_final_v6_mixed/checkpoints/final_model.pt",
}

# Defaults deliberately include in-distribution models plus cross-family models.
# The registry is CLI-overridable so a paper revision does not require source edits.
DEFAULT_CODER_MODELS = [
    "openai:gpt-5.4-mini",
    "openai:gpt-5.4",
    "hf:Qwen/Qwen3-Coder-30B-A3B-Instruct:featherless-ai",
    "hf:mistralai/Devstral-Small-2-24B-Instruct-2512",
]

MAX_PROMPT_TOKENS = 1600
MAX_NEW_TOKENS = 800
MAX_SEQ_LEN = 2400
DEFAULT_MAX_ATTEMPTS = 7
DEFAULT_DAFNY_TIMEOUT = 120


# -----------------------------------------------------------------------------
# Data classes
# -----------------------------------------------------------------------------

@dataclass(frozen=True)
class ModelSpec:
    provider: str
    model: str

    @property
    def key(self) -> str:
        return f"{self.provider}:{self.model}"


@dataclass
class AttemptRecord:
    task_id: str
    instructor: str
    policy_name: Optional[str]
    adapter_scale: float
    slm_decode: str
    coder_model: str
    attempt: int
    instruction: str
    coder_response: str
    dafny_code: str
    verifier_success: bool
    verifier_output: str
    semantic_aligned: Optional[bool]
    semantic_metadata: Dict[str, Any]
    recursive: bool
    recursion_names: List[str]
    instructor_prompt_tokens: int
    instructor_completion_tokens: int
    coder_prompt_tokens: int
    coder_completion_tokens: int
    slm_generated_tokens: int
    latency_sec: float
    error: Optional[str] = None


# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

def safe_name(text: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", text).strip("_")


def atomic_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")
    os.replace(tmp, path)


def append_jsonl(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload, ensure_ascii=False) + "\n")


def parse_model_spec(value: str) -> ModelSpec:
    if ":" not in value:
        raise ValueError(f"Model must be provider:model, got {value!r}")
    provider, model = value.split(":", 1)
    provider = provider.strip().lower()
    model = model.strip()
    if provider not in {"openai", "hf"}:
        raise ValueError(f"Unsupported provider {provider!r}; use openai or hf")
    if not model:
        raise ValueError("Empty model name")
    return ModelSpec(provider, model)


def read_task(folder: Path) -> str:
    for filename in ("detailed_description.txt", "one_line_description.txt"):
        path = folder / filename
        if path.exists():
            return path.read_text(encoding="utf-8").strip()
    return ""


def extract_dafny_code(text: str) -> str:
    matches = re.findall(r"```dafny\s*(.*?)```", text or "", flags=re.I | re.S)
    if matches:
        return matches[-1].strip()
    # Conservative fallback: if the model omitted fences but clearly emitted Dafny.
    stripped = (text or "").strip()
    if re.search(r"\b(method|function|lemma|predicate|class|datatype)\b", stripped):
        return stripped
    return ""


def detect_recursion(code: str) -> Tuple[bool, List[str]]:
    """Lightweight language-level recursion detector for evaluation reporting.

    It catches direct self-recursion of methods/functions/lemmas/predicates. The
    hardware dataset can later replace/augment this with the AST analyzer.
    """
    names: List[str] = []
    decl = re.compile(
        r"\b(?:method|function(?:\s+method)?|lemma|predicate)\s+([A-Za-z_][A-Za-z0-9_]*)\b",
        flags=re.I,
    )
    for match in decl.finditer(code or ""):
        name = match.group(1)
        body_start = match.end()
        next_decl = decl.search(code, body_start)
        body = code[body_start : next_decl.start() if next_decl else len(code)]
        if re.search(rf"\b{re.escape(name)}\s*\(", body):
            names.append(name)
    names = sorted(set(names))
    return bool(names), names


def run_dafny(code: str, work_dir: Path, timeout_sec: int) -> Tuple[bool, str]:
    work_dir.mkdir(parents=True, exist_ok=True)
    dafny_file = work_dir / "candidate.dfy"
    dafny_file.write_text(code or "", encoding="utf-8")
    if not code.strip():
        return False, "Error: empty Dafny program"
    try:
        result = subprocess.run(
            ["dafny", str(dafny_file)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=timeout_sec,
            check=False,
        )
        output = result.stdout or ""
        success = "verified, 0 errors" in output.lower()
        return success, output
    except subprocess.TimeoutExpired:
        return False, f"Error: Dafny verification timeout ({timeout_sec}s)"
    except Exception as exc:
        return False, f"Error running Dafny: {exc}"


# -----------------------------------------------------------------------------
# API clients
# -----------------------------------------------------------------------------

def make_client(spec: ModelSpec) -> OpenAI:
    if spec.provider == "openai":
        key = os.environ.get("OPENAI_API_KEY", "")
        if not key:
            raise RuntimeError("OPENAI_API_KEY is not set")
        return OpenAI(api_key=key)
    key = os.environ.get("HF_TOKEN", "")
    if not key:
        raise RuntimeError("HF_TOKEN is not set")
    return OpenAI(api_key=key, base_url=os.environ.get("HF_BASE_URL", "https://router.huggingface.co/v1"))


def usage_counts(response: Any) -> Tuple[int, int]:
    usage = getattr(response, "usage", None)
    if usage is None:
        return 0, 0
    prompt = int(
        getattr(usage, "input_tokens", 0)
        or getattr(usage, "prompt_tokens", 0)
        or 0
    )
    completion = int(
        getattr(usage, "output_tokens", 0)
        or getattr(usage, "completion_tokens", 0)
        or 0
    )
    return prompt, completion


def call_model(
    spec: ModelSpec,
    system: str,
    user: str,
    *,
    max_tokens: int,
    reasoning: Optional[str] = None,
    temperature: float = 0.2,
    retries: int = 3,
) -> Tuple[str, int, int]:
    client = make_client(spec)
    last_error: Optional[Exception] = None
    for attempt in range(1, retries + 1):
        try:
            if spec.provider == "openai":
                kwargs: Dict[str, Any] = {
                    "model": spec.model,
                    "instructions": system,
                    "input": user,
                    "max_output_tokens": max_tokens,
                }
                if reasoning:
                    kwargs["reasoning"] = {"effort": reasoning}
                response = client.responses.create(**kwargs)
                text = getattr(response, "output_text", "") or ""
                p, c = usage_counts(response)
                return text.strip(), p, c

            response = client.chat.completions.create(
                model=spec.model,
                messages=[
                    {"role": "system", "content": system},
                    {"role": "user", "content": user},
                ],
                temperature=temperature,
                max_tokens=max_tokens,
                stream=False,
            )
            text = response.choices[0].message.content or ""
            p, c = usage_counts(response)
            return text.strip(), p, c
        except Exception as exc:
            last_error = exc
            logging.warning("API attempt %d/%d failed for %s: %s", attempt, retries, spec.key, exc)
            if attempt < retries:
                time.sleep(min(8, 2 ** attempt))
    raise RuntimeError(f"API failed after {retries} attempts for {spec.key}: {last_error}")


# -----------------------------------------------------------------------------
# Journal Qwen3 prompt policy
# -----------------------------------------------------------------------------

def load_policy_model(
    instructor: str,
    policy_name: Optional[str],
    checkpoint_override: Optional[Path],
    adapter_scale: float,
):
    """Return (SLMPG, tokenizer) for trained/untrained Qwen3 instructor modes."""
    base_model, tokenizer = initialize_qwen3_slm(None)
    slm_pg = SLMPG(base_model)

    if instructor == "trained":
        if not policy_name:
            raise ValueError("trained instructor requires --policy")
        checkpoint_path = checkpoint_override or POLICY_CHECKPOINTS[policy_name]
        if not checkpoint_path.exists():
            raise FileNotFoundError(f"Policy checkpoint not found: {checkpoint_path}")
        logging.info("Loading journal policy %s from %s", policy_name, checkpoint_path)
        checkpoint = torch.load(checkpoint_path, map_location="cpu")
        state = checkpoint.get("model_state_dict", checkpoint)
        missing, unexpected = slm_pg.load_state_dict(state, strict=False)
        logging.info("Policy checkpoint loaded: missing=%d unexpected=%d", len(missing), len(unexpected))

        # Inference-time adapter-strength ablation. LoRA output is proportional
        # to B(Ax), so scaling trained lora_B weights provides a clean continuous
        # intervention while keeping the base model and prompts fixed.
        if adapter_scale != 1.0:
            with torch.no_grad():
                count = 0
                for name, parameter in slm_pg.named_parameters():
                    if "lora_B" in name:
                        parameter.mul_(adapter_scale)
                        count += 1
            logging.info("Applied LoRA-B scale %.3f to %d tensors", adapter_scale, count)

    slm_pg.eval()
    if hasattr(slm_pg.model, "gradient_checkpointing_disable"):
        slm_pg.model.gradient_checkpointing_disable()
    if hasattr(slm_pg.model.config, "use_cache"):
        slm_pg.model.config.use_cache = True
    return slm_pg, tokenizer


def generate_slm_instruction(
    slm_pg,
    tokenizer,
    prompt: str,
    decode_mode: str,
    seed: int,
) -> Tuple[str, int]:
    messages = [
        {
            "role": "system",
            "content": (
                "You are a prompt-policy model. Produce a concise instruction for a Dafny coding agent. "
                "Preserve the exact requested task and avoid recursion."
            ),
        },
        {"role": "user", "content": prompt},
    ]
    try:
        rendered = tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
            enable_thinking=False,
        )
    except TypeError:
        rendered = tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
        )

    inputs = tokenizer(
        rendered,
        return_tensors="pt",
        truncation=True,
        padding=False,
        max_length=MAX_PROMPT_TOKENS,
    )
    model_device = next(slm_pg.model.parameters()).device
    inputs = {key: value.to(model_device) for key, value in inputs.items()}

    if decode_mode == "greedy":
        generation = dict(
            max_new_tokens=MAX_NEW_TOKENS,
            do_sample=False,
            repetition_penalty=1.12,
            no_repeat_ngram_size=4,
        )
    elif decode_mode == "train_match":
        generator = torch.Generator(device=model_device)
        generator.manual_seed(seed)
        generation = dict(
            max_new_tokens=MAX_NEW_TOKENS,
            do_sample=True,
            temperature=0.25,
            top_p=0.90,
            top_k=40,
            repetition_penalty=1.12,
            no_repeat_ngram_size=4,
            generator=generator,
        )
    else:
        raise ValueError(f"Unknown SLM decode mode: {decode_mode}")

    with torch.no_grad():
        output = slm_pg.model.generate(
            **inputs,
            pad_token_id=tokenizer.pad_token_id,
            eos_token_id=tokenizer.eos_token_id,
            **generation,
        )
    prompt_len = inputs["input_ids"].shape[1]
    generated = output[0][prompt_len:]
    return tokenizer.decode(generated, skip_special_tokens=True).strip(), int(generated.numel())


# -----------------------------------------------------------------------------
# Instructor / coder prompts
# -----------------------------------------------------------------------------

def initial_instructor_prompt(task: str) -> str:
    return (
        "Create an instruction for another coding model that must solve exactly the following Dafny task. "
        "Focus on specifications, invariants, proof obligations, edge cases, and verifier-friendly iterative control flow. "
        "Do not substitute another problem and avoid recursion.\n\n"
        f"TASK:\n{task}"
    )


def repair_instructor_prompt(task: str, code: str, verifier_output: str) -> str:
    return (
        "Create a revised instruction for another coding model. Preserve the original Dafny task exactly, diagnose the "
        "previous verifier failure, and tell the coder how to repair it without recursion.\n\n"
        f"ORIGINAL TASK:\n{task}\n\n"
        f"PREVIOUS CODE:\n{code}\n\n"
        f"VERIFIER OUTPUT:\n{verifier_output}"
    )


def coder_prompt(task: str, instruction: Optional[str], previous_code: str = "", previous_error: str = "") -> str:
    pieces = [f"Original task:\n{task}"]
    if instruction:
        pieces.append(f"Instructor guidance:\n{instruction}")
    if previous_code:
        pieces.append(f"Previous Dafny code:\n{previous_code}")
    if previous_error:
        pieces.append(f"Previous verifier feedback:\n{previous_error}")
    pieces.append(
        "Requirements:\n"
        "- Solve exactly the original task; preserve requested names, inputs, outputs, and behavior.\n"
        "- Avoid recursion; prefer loops with invariants.\n"
        "- Return exactly one complete Dafny program inside ```dafny ... ``` and no other code block.\n"
        "- Include all specifications/invariants/assertions needed for verification."
    )
    return "\n\n".join(pieces)


def get_instruction(
    instructor: str,
    task: str,
    previous_code: str,
    previous_error: str,
    coder_spec: ModelSpec,
    slm_pg,
    tokenizer,
    slm_decode: str,
    seed: int,
) -> Tuple[Optional[str], int, int, int]:
    if instructor == "none":
        return None, 0, 0, 0

    prompt = (
        repair_instructor_prompt(task, previous_code, previous_error)
        if previous_code or previous_error
        else initial_instructor_prompt(task)
    )

    if instructor in {"trained", "untrained"}:
        text, generated_tokens = generate_slm_instruction(
            slm_pg, tokenizer, prompt, slm_decode, seed
        )
        return text, 0, 0, generated_tokens

    if instructor == "self":
        text, p, c = call_model(
            coder_spec,
            "You are the instructor in a two-agent Dafny system. Do not write the final code; give precise guidance to the coding agent.",
            prompt,
            max_tokens=2048,
            reasoning="low" if coder_spec.provider == "openai" else None,
            temperature=0.2,
        )
        return text, p, c, 0

    raise ValueError(f"Unknown instructor mode: {instructor}")


# -----------------------------------------------------------------------------
# Semantic judge
# -----------------------------------------------------------------------------

def semantic_judge(task: str, code: str) -> Tuple[bool, Dict[str, Any]]:
    """Use the same journal semantic criterion: same underlying task, not correctness."""
    spec = ModelSpec("openai", os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.4"))
    prompt = (
        "Determine only whether the Dafny program attempts to solve the SAME underlying problem as the task. "
        "Do not judge verifier correctness, proof completeness, or minor interface bugs. Answer YES for the same problem "
        "even if buggy. Answer NO only for task substitution, unrelated/generic programs, placeholders, or shells. "
        "Return exactly YES or NO.\n\n"
        f"TASK:\n{task}\n\nPROGRAM:\n{code}"
    )
    text, p, c = call_model(
        spec,
        "You are an anti-reward-hacking semantic alignment judge.",
        prompt,
        max_tokens=32,
        reasoning=os.environ.get("DAFNY_JUDGE_REASONING", "low"),
        temperature=0.0,
    )
    normalized = re.sub(r"[^A-Za-z]", "", text).upper()
    aligned = normalized == "YES"
    return aligned, {
        "judge_model": spec.model,
        "raw": text,
        "prompt_tokens": p,
        "completion_tokens": c,
        "parsed": normalized if normalized in {"YES", "NO"} else "INVALID",
    }


# -----------------------------------------------------------------------------
# Evaluation
# -----------------------------------------------------------------------------

def condition_key(args: argparse.Namespace, coder: ModelSpec) -> str:
    policy = args.policy if args.instructor == "trained" else "na"
    return safe_name(
        f"instr={args.instructor}__policy={policy}__scale={args.adapter_scale:g}__decode={args.slm_decode}__coder={coder.key}"
    )


def evaluate_task(
    task_id: str,
    task: str,
    args: argparse.Namespace,
    coder: ModelSpec,
    slm_pg,
    tokenizer,
    condition_dir: Path,
) -> Dict[str, Any]:
    trajectory_path = condition_dir / "trajectories" / f"{safe_name(task_id)}.json"
    if trajectory_path.exists() and not args.overwrite:
        return json.loads(trajectory_path.read_text(encoding="utf-8"))

    attempts: List[AttemptRecord] = []
    previous_code = ""
    previous_error = ""
    first_success_attempt: Optional[int] = None
    first_aligned_success_attempt: Optional[int] = None

    for attempt in range(1, args.max_attempts + 1):
        start = time.time()
        seed_material = f"{args.seed}|{task_id}|{attempt}|{condition_key(args, coder)}"
        seed = int(hashlib.sha256(seed_material.encode()).hexdigest()[:8], 16)

        try:
            instruction, ip, ic, slm_tokens = get_instruction(
                args.instructor,
                task,
                previous_code,
                previous_error,
                coder,
                slm_pg,
                tokenizer,
                args.slm_decode,
                seed,
            )
            cp = coder_prompt(task, instruction, previous_code, previous_error)
            response, coder_p, coder_c = call_model(
                coder,
                "You are an expert Dafny programmer. Return only the requested complete Dafny program.",
                cp,
                max_tokens=args.coder_max_tokens,
                reasoning=args.openai_coder_reasoning if coder.provider == "openai" else None,
                temperature=args.coder_temperature,
            )
            code = extract_dafny_code(response)
            work = condition_dir / "work" / safe_name(task_id) / f"attempt_{attempt}"
            verified, verifier_output = run_dafny(code, work, args.dafny_timeout)
            recursive, recursion_names = detect_recursion(code)

            aligned: Optional[bool] = None
            semantic_meta: Dict[str, Any] = {}
            if verified and args.semantic_judge:
                aligned, semantic_meta = semantic_judge(task, code)
            elif verified:
                aligned = True

            record = AttemptRecord(
                task_id=task_id,
                instructor=args.instructor,
                policy_name=args.policy if args.instructor == "trained" else None,
                adapter_scale=args.adapter_scale,
                slm_decode=args.slm_decode,
                coder_model=coder.key,
                attempt=attempt,
                instruction=instruction or "",
                coder_response=response,
                dafny_code=code,
                verifier_success=verified,
                verifier_output=verifier_output,
                semantic_aligned=aligned,
                semantic_metadata=semantic_meta,
                recursive=recursive,
                recursion_names=recursion_names,
                instructor_prompt_tokens=ip,
                instructor_completion_tokens=ic,
                coder_prompt_tokens=coder_p,
                coder_completion_tokens=coder_c,
                slm_generated_tokens=slm_tokens,
                latency_sec=time.time() - start,
            )
        except Exception as exc:
            logging.exception("Task %s attempt %d failed", task_id, attempt)
            record = AttemptRecord(
                task_id=task_id,
                instructor=args.instructor,
                policy_name=args.policy if args.instructor == "trained" else None,
                adapter_scale=args.adapter_scale,
                slm_decode=args.slm_decode,
                coder_model=coder.key,
                attempt=attempt,
                instruction="",
                coder_response="",
                dafny_code="",
                verifier_success=False,
                verifier_output="",
                semantic_aligned=None,
                semantic_metadata={},
                recursive=False,
                recursion_names=[],
                instructor_prompt_tokens=0,
                instructor_completion_tokens=0,
                coder_prompt_tokens=0,
                coder_completion_tokens=0,
                slm_generated_tokens=0,
                latency_sec=time.time() - start,
                error=str(exc),
            )

        attempts.append(record)
        append_jsonl(condition_dir / "attempts.jsonl", asdict(record))

        if record.verifier_success and first_success_attempt is None:
            first_success_attempt = attempt
        if record.verifier_success and record.semantic_aligned and first_aligned_success_attempt is None:
            first_aligned_success_attempt = attempt
        if record.verifier_success and (not args.semantic_judge or record.semantic_aligned):
            break

        previous_code = record.dafny_code
        previous_error = record.verifier_output or record.error or "Unknown failure"

    summary = {
        "task_id": task_id,
        "condition": condition_key(args, coder),
        "instructor": args.instructor,
        "policy": args.policy if args.instructor == "trained" else None,
        "adapter_scale": args.adapter_scale,
        "slm_decode": args.slm_decode,
        "coder": coder.key,
        "attempts_run": len(attempts),
        "first_verified_attempt": first_success_attempt,
        "first_aligned_verified_attempt": first_aligned_success_attempt,
        "pass_at_1": bool(first_success_attempt and first_success_attempt <= 1),
        "pass_at_3": bool(first_success_attempt and first_success_attempt <= 3),
        "pass_at_5": bool(first_success_attempt and first_success_attempt <= 5),
        "pass_at_7": bool(first_success_attempt and first_success_attempt <= 7),
        "aligned_pass_at_1": bool(first_aligned_success_attempt and first_aligned_success_attempt <= 1),
        "aligned_pass_at_3": bool(first_aligned_success_attempt and first_aligned_success_attempt <= 3),
        "aligned_pass_at_5": bool(first_aligned_success_attempt and first_aligned_success_attempt <= 5),
        "aligned_pass_at_7": bool(first_aligned_success_attempt and first_aligned_success_attempt <= 7),
        "final_verified": bool(attempts[-1].verifier_success),
        "final_aligned": bool(attempts[-1].verifier_success and attempts[-1].semantic_aligned),
        "final_recursive": bool(attempts[-1].recursive),
        "aligned_nonrecursive_final": bool(
            attempts[-1].verifier_success and attempts[-1].semantic_aligned and not attempts[-1].recursive
        ),
        "total_coder_prompt_tokens": sum(x.coder_prompt_tokens for x in attempts),
        "total_coder_completion_tokens": sum(x.coder_completion_tokens for x in attempts),
        "total_instructor_prompt_tokens": sum(x.instructor_prompt_tokens for x in attempts),
        "total_instructor_completion_tokens": sum(x.instructor_completion_tokens for x in attempts),
        "total_slm_generated_tokens": sum(x.slm_generated_tokens for x in attempts),
        "total_latency_sec": sum(x.latency_sec for x in attempts),
        "api_or_runtime_errors": sum(1 for x in attempts if x.error),
        "attempts": [asdict(x) for x in attempts],
    }
    atomic_json(trajectory_path, summary)
    return summary


def aggregate(condition_dir: Path, rows: List[Dict[str, Any]]) -> Dict[str, Any]:
    n = len(rows)
    def rate(key: str) -> float:
        return sum(bool(row.get(key)) for row in rows) / n if n else 0.0

    solved_attempts = [row["first_aligned_verified_attempt"] for row in rows if row.get("first_aligned_verified_attempt")]
    result = {
        "n_tasks": n,
        "pass_at_1": rate("pass_at_1"),
        "pass_at_3": rate("pass_at_3"),
        "pass_at_5": rate("pass_at_5"),
        "pass_at_7": rate("pass_at_7"),
        "aligned_pass_at_1": rate("aligned_pass_at_1"),
        "aligned_pass_at_3": rate("aligned_pass_at_3"),
        "aligned_pass_at_5": rate("aligned_pass_at_5"),
        "aligned_pass_at_7": rate("aligned_pass_at_7"),
        "final_verified_rate": rate("final_verified"),
        "final_aligned_rate": rate("final_aligned"),
        "final_recursion_rate": rate("final_recursive"),
        "aligned_nonrecursive_final_rate": rate("aligned_nonrecursive_final"),
        "mean_attempts_to_aligned_success": (
            sum(solved_attempts) / len(solved_attempts) if solved_attempts else None
        ),
        "mean_coder_tokens": (
            sum(row["total_coder_prompt_tokens"] + row["total_coder_completion_tokens"] for row in rows) / n if n else 0
        ),
        "mean_instructor_tokens": (
            sum(row["total_instructor_prompt_tokens"] + row["total_instructor_completion_tokens"] + row["total_slm_generated_tokens"] for row in rows) / n if n else 0
        ),
        "mean_latency_sec": sum(row["total_latency_sec"] for row in rows) / n if n else 0,
        "runtime_error_rate": (
            sum(row["api_or_runtime_errors"] > 0 for row in rows) / n if n else 0.0
        ),
    }
    atomic_json(condition_dir / "summary.json", result)

    csv_path = condition_dir / "tasks.csv"
    if rows:
        keys = [key for key in rows[0].keys() if key != "attempts"]
        with csv_path.open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=keys)
            writer.writeheader()
            for row in rows:
                writer.writerow({key: row.get(key) for key in keys})
    return result


# -----------------------------------------------------------------------------
# CLI / matrix helpers
# -----------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    parser.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--instructor", choices=["trained", "untrained", "none", "self"], required=True)
    parser.add_argument("--policy", choices=["openai", "qwen", "mixed"])
    parser.add_argument("--checkpoint", type=Path, default=None)
    parser.add_argument("--coder", default=DEFAULT_CODER_MODELS[0], help="provider:model")
    parser.add_argument("--adapter-scale", type=float, default=1.0)
    parser.add_argument("--slm-decode", choices=["greedy", "train_match"], default="train_match")
    parser.add_argument("--max-attempts", type=int, default=DEFAULT_MAX_ATTEMPTS)
    parser.add_argument("--dafny-timeout", type=int, default=DEFAULT_DAFNY_TIMEOUT)
    parser.add_argument("--coder-max-tokens", type=int, default=8192)
    parser.add_argument("--coder-temperature", type=float, default=0.2)
    parser.add_argument("--openai-coder-reasoning", default="medium")
    parser.add_argument("--semantic-judge", action=argparse.BooleanOptionalAction, default=True)
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--seed", type=int, default=20260811)
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument("--list-default-matrix", action="store_true")
    return parser


def print_default_matrix() -> None:
    print("# Core instructor comparison for every coder")
    for coder in DEFAULT_CODER_MODELS:
        for instructor in ("none", "untrained", "self"):
            print(f"--instructor {instructor} --coder '{coder}'")
        for policy in ("openai", "qwen", "mixed"):
            print(f"--instructor trained --policy {policy} --coder '{coder}'")
    print("# Recommended LoRA-strength ablation on trained policies: --adapter-scale 0.5,1.0,1.5")
    print("# Recommended decoding ablation on a representative subset: --slm-decode greedy vs train_match")


def main() -> None:
    args = build_parser().parse_args()
    if args.list_default_matrix:
        print_default_matrix()
        return

    if args.instructor == "trained" and not args.policy:
        raise SystemExit("--policy is required with --instructor trained")
    if args.instructor != "trained" and args.policy:
        raise SystemExit("--policy is only meaningful with --instructor trained")
    if args.adapter_scale < 0:
        raise SystemExit("--adapter-scale must be nonnegative")

    coder = parse_model_spec(args.coder)
    condition = condition_key(args, coder)
    condition_dir = args.output_root / condition
    condition_dir.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler(condition_dir / "evaluation.log"),
            logging.StreamHandler(),
        ],
        force=True,
    )

    config = {
        "dataset": str(args.dataset),
        "condition": condition,
        "instructor": args.instructor,
        "policy": args.policy,
        "checkpoint": str(args.checkpoint) if args.checkpoint else (
            str(POLICY_CHECKPOINTS[args.policy]) if args.policy else None
        ),
        "slm_model": SLM_MODEL_NAME,
        "coder": coder.key,
        "adapter_scale": args.adapter_scale,
        "slm_decode": args.slm_decode,
        "max_prompt_tokens": MAX_PROMPT_TOKENS,
        "max_new_tokens": MAX_NEW_TOKENS,
        "max_seq_len": MAX_SEQ_LEN,
        "max_attempts": args.max_attempts,
        "semantic_judge": args.semantic_judge,
        "judge_model": os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.4"),
        "seed": args.seed,
    }
    atomic_json(condition_dir / "config.json", config)

    slm_pg = tokenizer = None
    if args.instructor in {"trained", "untrained"}:
        slm_pg, tokenizer = load_policy_model(
            args.instructor,
            args.policy,
            args.checkpoint,
            args.adapter_scale,
        )

    folders = sorted(path for path in args.dataset.iterdir() if path.is_dir())
    if args.limit > 0:
        folders = folders[: args.limit]
    logging.info("Evaluating %d tasks for %s", len(folders), condition)

    rows: List[Dict[str, Any]] = []
    for index, folder in enumerate(folders, 1):
        task = read_task(folder)
        if not task:
            logging.warning("Skipping %s: no task description", folder.name)
            continue
        logging.info("[%d/%d] %s", index, len(folders), folder.name)
        rows.append(
            evaluate_task(
                folder.name,
                task,
                args,
                coder,
                slm_pg,
                tokenizer,
                condition_dir,
            )
        )

    summary = aggregate(condition_dir, rows)
    logging.info("Summary: %s", json.dumps(summary, sort_keys=True))


if __name__ == "__main__":
    main()
