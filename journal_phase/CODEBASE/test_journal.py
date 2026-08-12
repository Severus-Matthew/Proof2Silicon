#!/usr/bin/env python3
"""Proof2Silicon journal evaluation harness for held-out Input_dataset_3.

One process evaluates one experimental condition. A condition is defined by the
instructor, trained policy (if any), downstream coder, repair-vs-independent
mode, feedback channel, recursion hint, LoRA scale, and SLM decoding mode.

Iterative verifier-feedback metrics are named repair@k. pass@k is reserved for
independent samples with no repair context.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import logging
import os
import re
import subprocess
import sys
import time
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import torch
from openai import OpenAI

CODEBASE = Path(__file__).resolve().parent
if str(CODEBASE) not in sys.path:
    sys.path.insert(0, str(CODEBASE))

from preface_rl.slm import SLMPG
from preface_rl.slm_qwen3 import initialize_slm as initialize_qwen3_slm

ROOT = Path("/u/mjha1/Proof2Silicon/journal_phase")
DEFAULT_DATASET = ROOT / "Input_dataset_3"
DEFAULT_OUTPUT = ROOT / "journal_eval"
SLM_MODEL_NAME = os.environ.get("SLM_MODEL_NAME", "Qwen/Qwen3-1.7B")
MAX_PROMPT_TOKENS = 1600
MAX_NEW_TOKENS = 800
DEFAULT_MAX_ATTEMPTS = 7
DEFAULT_DAFNY_TIMEOUT = 120

POLICY_CHECKPOINTS: Dict[str, Path] = {
    "openai": ROOT / "journal_runs/journal_journal_final_v6_openai/checkpoints/final_model.pt",
    "qwen": ROOT / "journal_runs/journal_journal_final_v9_qwen_hf/checkpoints/final_model.pt",
    "mixed": ROOT / "journal_runs/journal_journal_final_v6_mixed/checkpoints/final_model.pt",
}

DEFAULT_CODER_MODELS = [
    "openai:gpt-5.4-mini",
    "openai:gpt-5.4",
    "hf:Qwen/Qwen3-Coder-30B-A3B-Instruct:featherless-ai",
    "hf:deepseek-ai/DeepSeek-V3.1",
]


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
    coder_model: str
    evaluation_mode: str
    feedback_mode: str
    recursion_hint: bool
    adapter_scale: float
    slm_decode: str
    sample_or_attempt: int
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
    provider, model = provider.strip().lower(), model.strip()
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
    stripped = (text or "").strip()
    if re.search(r"\b(method|function|lemma|predicate|class|datatype)\b", stripped):
        return stripped
    return ""


def detect_recursion(code: str) -> Tuple[bool, List[str]]:
    names: List[str] = []
    decl = re.compile(
        r"\b(?:method|function(?:\s+method)?|lemma|predicate)\s+([A-Za-z_][A-Za-z0-9_]*)\b",
        re.I,
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
        return "verified, 0 errors" in output.lower(), output
    except subprocess.TimeoutExpired:
        return False, f"Error: Dafny verification timeout ({timeout_sec}s)"
    except Exception as exc:
        return False, f"Error running Dafny: {exc}"


def make_client(spec: ModelSpec) -> OpenAI:
    if spec.provider == "openai":
        key = os.environ.get("OPENAI_API_KEY", "")
        if not key:
            raise RuntimeError("OPENAI_API_KEY is not set")
        return OpenAI(api_key=key)
    key = os.environ.get("HF_TOKEN", "")
    if not key:
        raise RuntimeError("HF_TOKEN is not set")
    return OpenAI(
        api_key=key,
        base_url=os.environ.get("HF_BASE_URL", "https://router.huggingface.co/v1"),
    )


def usage_counts(response: Any) -> Tuple[int, int]:
    usage = getattr(response, "usage", None)
    if usage is None:
        return 0, 0
    p = int(getattr(usage, "input_tokens", 0) or getattr(usage, "prompt_tokens", 0) or 0)
    c = int(getattr(usage, "output_tokens", 0) or getattr(usage, "completion_tokens", 0) or 0)
    return p, c


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
                text = (getattr(response, "output_text", "") or "").strip()
                p, c = usage_counts(response)
            else:
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
                text = (response.choices[0].message.content or "").strip()
                p, c = usage_counts(response)
            if not text:
                raise RuntimeError("model returned an empty response")
            return text, p, c
        except Exception as exc:
            last_error = exc
            logging.warning(
                "API attempt %d/%d failed for %s: %s",
                attempt,
                retries,
                spec.key,
                exc,
            )
            if attempt < retries:
                time.sleep(min(8, 2**attempt))
    raise RuntimeError(f"API failed after {retries} attempts for {spec.key}: {last_error}")


def load_policy_model(
    instructor: str,
    policy_name: Optional[str],
    checkpoint_override: Optional[Path],
    adapter_scale: float,
):
    base_model, tokenizer = initialize_qwen3_slm(None)
    slm_pg = SLMPG(base_model)
    if instructor == "trained":
        if not policy_name:
            raise ValueError("trained instructor requires --policy")
        checkpoint_path = checkpoint_override or POLICY_CHECKPOINTS[policy_name]
        if not checkpoint_path.exists():
            raise FileNotFoundError(f"Policy checkpoint not found: {checkpoint_path}")
        checkpoint = torch.load(checkpoint_path, map_location="cpu")
        state = checkpoint.get("model_state_dict", checkpoint)
        missing, unexpected = slm_pg.load_state_dict(state, strict=False)

        current_keys = set(slm_pg.state_dict().keys())
        current_lora = sorted(k for k in current_keys if "lora_" in k)
        missing_lora = [k for k in current_lora if k not in state]
        if missing_lora:
            raise RuntimeError(
                "Checkpoint did not restore all inference LoRA tensors; first missing keys: "
                + ", ".join(missing_lora[:10])
            )
        logging.info(
            "Policy checkpoint loaded: missing=%d unexpected=%d restored_lora_tensors=%d",
            len(missing),
            len(unexpected),
            len(current_lora),
        )
        if unexpected:
            logging.info("Unexpected checkpoint key sample: %s", list(unexpected)[:12])

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


def _seeded_generate(model, inputs: Dict[str, torch.Tensor], generation: Dict[str, Any], seed: int):
    """Generate reproducibly without passing unsupported `generator=` to HF generate()."""
    first_tensor = next(iter(inputs.values()))
    device = first_tensor.device
    if device.type == "cuda":
        device_index = device.index if device.index is not None else torch.cuda.current_device()
        with torch.random.fork_rng(devices=[device_index], enabled=True):
            torch.manual_seed(seed)
            torch.cuda.manual_seed_all(seed)
            return model.generate(**inputs, **generation)
    with torch.random.fork_rng(devices=[], enabled=True):
        torch.manual_seed(seed)
        return model.generate(**inputs, **generation)


def generate_slm_instruction(
    slm_pg,
    tokenizer,
    prompt: str,
    decode_mode: str,
    seed: int,
    recursion_hint: bool,
) -> Tuple[str, int]:
    system = (
        "You are a prompt-policy model. Produce a concise instruction for a Dafny coding agent. "
        "Preserve the exact requested task."
    )
    if recursion_hint:
        system += " Avoid recursion and prefer verifier-friendly iterative control flow."
    messages = [
        {"role": "system", "content": system},
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
    inputs = {k: v.to(model_device) for k, v in inputs.items()}

    common = dict(
        max_new_tokens=MAX_NEW_TOKENS,
        repetition_penalty=1.12,
        no_repeat_ngram_size=4,
        pad_token_id=tokenizer.pad_token_id,
        eos_token_id=tokenizer.eos_token_id,
    )
    if decode_mode == "greedy":
        generation = dict(common, do_sample=False)
        with torch.no_grad():
            output = slm_pg.model.generate(**inputs, **generation)
    elif decode_mode == "train_match":
        generation = dict(
            common,
            do_sample=True,
            temperature=0.25,
            top_p=0.90,
            top_k=40,
        )
        with torch.no_grad():
            output = _seeded_generate(slm_pg.model, inputs, generation, seed)
    else:
        raise ValueError(f"Unknown SLM decode mode: {decode_mode}")

    prompt_len = inputs["input_ids"].shape[1]
    generated = output[0][prompt_len:]
    text = tokenizer.decode(generated, skip_special_tokens=True).strip()
    if not text:
        raise RuntimeError("SLM generated an empty instruction")
    return text, int(generated.numel())


def anti_recursion_text(enabled: bool) -> str:
    return " Avoid recursion; prefer loops with invariants." if enabled else ""


def initial_instructor_prompt(task: str, recursion_hint: bool) -> str:
    return (
        "Create an instruction for another coding model that must solve exactly the following Dafny task. "
        "Focus on specifications, invariants, proof obligations, edge cases, and verifier-friendly proof strategy. "
        "Do not substitute another problem."
        + anti_recursion_text(recursion_hint)
        + f"\n\nTASK:\n{task}"
    )


def repair_instructor_prompt(task: str, code: str, verifier_output: str, recursion_hint: bool) -> str:
    return (
        "Create a revised instruction for another coding model. Preserve the original Dafny task exactly and "
        "diagnose the previous verifier failure."
        + anti_recursion_text(recursion_hint)
        + f"\n\nORIGINAL TASK:\n{task}\n\nPREVIOUS CODE:\n{code}\n\nVERIFIER OUTPUT:\n{verifier_output}"
    )


def coder_prompt(
    task: str,
    instruction: Optional[str],
    previous_code: str = "",
    previous_error: str = "",
    recursion_hint: bool = True,
) -> str:
    pieces = [f"Original task:\n{task}"]
    if instruction:
        pieces.append(f"Instructor guidance:\n{instruction}")
    if previous_code:
        pieces.append(f"Previous Dafny code:\n{previous_code}")
    if previous_error:
        pieces.append(f"Previous verifier feedback:\n{previous_error}")
    req = "Requirements:\n- Solve exactly the original task; preserve requested names, inputs, outputs, and behavior.\n"
    if recursion_hint:
        req += "- Avoid recursion; prefer loops with invariants.\n"
    req += (
        "- Return exactly one complete Dafny program inside ```dafny ... ``` and no other code block.\n"
        "- Include all specifications/invariants/assertions needed for verification."
    )
    pieces.append(req)
    return "\n\n".join(pieces)


def get_instruction(args, task, previous_code, previous_error, coder_spec, slm_pg, tokenizer, seed):
    if args.instructor == "none":
        return None, 0, 0, 0
    prompt = (
        repair_instructor_prompt(task, previous_code, previous_error, args.recursion_hint)
        if (previous_code or previous_error)
        else initial_instructor_prompt(task, args.recursion_hint)
    )
    if args.feedback_mode in {"none", "coder_only"} and (previous_code or previous_error):
        prompt = initial_instructor_prompt(task, args.recursion_hint)
    if args.instructor in {"trained", "untrained"}:
        text, tokens = generate_slm_instruction(
            slm_pg,
            tokenizer,
            prompt,
            args.slm_decode,
            seed,
            args.recursion_hint,
        )
        return text, 0, 0, tokens
    spec = coder_spec if args.instructor == "self" else parse_model_spec(args.external_instructor_model)
    system = (
        "You are the instructor in a two-agent Dafny system. Do not write final code; "
        "give precise guidance to the coding agent."
    )
    text, p, c = call_model(
        spec,
        system,
        prompt,
        max_tokens=2048,
        reasoning="low" if spec.provider == "openai" else None,
        temperature=0.2,
    )
    return text, p, c, 0


def semantic_judge(task: str, code: str) -> Tuple[bool, Dict[str, Any]]:
    spec = ModelSpec("openai", os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.4"))
    prompt = (
        "Determine only whether the Dafny program attempts to solve the SAME underlying problem as the task. "
        "Do not judge verifier correctness, proof completeness, or minor interface bugs. Answer YES for the same "
        "problem even if buggy. Answer NO only for task substitution, unrelated/generic programs, placeholders, or "
        "shells. Return exactly YES or NO.\n\n"
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


def condition_key(args, coder):
    policy = args.policy if args.instructor == "trained" else "na"
    return safe_name(
        f"mode={args.evaluation_mode}__instr={args.instructor}__policy={policy}__fb={args.feedback_mode}__"
        f"rechint={int(args.recursion_hint)}__scale={args.adapter_scale:g}__decode={args.slm_decode}__"
        f"coder={coder.key}__seed={args.seed}"
    )


def evaluate_task(task_id, task, args, coder, slm_pg, tokenizer, condition_dir):
    trajectory_path = condition_dir / "trajectories" / f"{safe_name(task_id)}.json"
    if trajectory_path.exists() and not args.overwrite:
        return json.loads(trajectory_path.read_text(encoding="utf-8"))

    records: List[AttemptRecord] = []
    previous_code = ""
    previous_error = ""
    first_verified = None
    first_aligned = None

    for sample in range(1, args.max_attempts + 1):
        start = time.time()
        seed_material = f"{args.seed}|{task_id}|{sample}|{condition_key(args, coder)}"
        seed = int(hashlib.sha256(seed_material.encode()).hexdigest()[:8], 16)
        if args.evaluation_mode == "independent":
            context_code = context_error = ""
        else:
            context_code, context_error = previous_code, previous_error
        runtime_exc: Optional[Exception] = None
        try:
            instruction, ip, ic, slm_tokens = get_instruction(
                args,
                task,
                context_code,
                context_error,
                coder,
                slm_pg,
                tokenizer,
                seed,
            )
            coder_code_context = context_code if args.feedback_mode in {"full", "coder_only"} else ""
            coder_error_context = context_error if args.feedback_mode in {"full", "coder_only"} else ""
            cp = coder_prompt(
                task,
                instruction,
                coder_code_context,
                coder_error_context,
                args.recursion_hint,
            )
            response, coder_p, coder_c = call_model(
                coder,
                "You are an expert Dafny programmer. Return only the requested complete Dafny program.",
                cp,
                max_tokens=args.coder_max_tokens,
                reasoning=args.openai_coder_reasoning if coder.provider == "openai" else None,
                temperature=args.coder_temperature,
            )
            code = extract_dafny_code(response)
            work = condition_dir / "work" / safe_name(task_id) / f"sample_{sample}"
            verified, verifier_output = run_dafny(code, work, args.dafny_timeout)
            recursive, recursion_names = detect_recursion(code)
            aligned = None
            semantic_meta: Dict[str, Any] = {}
            if verified and args.semantic_judge:
                aligned, semantic_meta = semantic_judge(task, code)
            elif verified:
                aligned = True
            record = AttemptRecord(
                task_id,
                args.instructor,
                args.policy if args.instructor == "trained" else None,
                coder.key,
                args.evaluation_mode,
                args.feedback_mode,
                args.recursion_hint,
                args.adapter_scale,
                args.slm_decode,
                sample,
                instruction or "",
                response,
                code,
                verified,
                verifier_output,
                aligned,
                semantic_meta,
                recursive,
                recursion_names,
                ip,
                ic,
                coder_p,
                coder_c,
                slm_tokens,
                time.time() - start,
            )
        except Exception as exc:
            runtime_exc = exc
            logging.exception("Task %s sample/attempt %d failed", task_id, sample)
            record = AttemptRecord(
                task_id,
                args.instructor,
                args.policy if args.instructor == "trained" else None,
                coder.key,
                args.evaluation_mode,
                args.feedback_mode,
                args.recursion_hint,
                args.adapter_scale,
                args.slm_decode,
                sample,
                "",
                "",
                "",
                False,
                "",
                None,
                {},
                False,
                [],
                0,
                0,
                0,
                0,
                0,
                time.time() - start,
                str(exc),
            )

        records.append(record)
        append_jsonl(condition_dir / "attempts.jsonl", asdict(record))
        if runtime_exc is not None and args.fail_on_runtime_errors:
            raise RuntimeError(
                f"Runtime/API error in {task_id} sample/attempt {sample}; refusing to score it as a model failure"
            ) from runtime_exc

        if record.verifier_success and first_verified is None:
            first_verified = sample
        if record.verifier_success and record.semantic_aligned and first_aligned is None:
            first_aligned = sample
        if args.evaluation_mode == "repair":
            if record.verifier_success and (not args.semantic_judge or record.semantic_aligned):
                break
            previous_code = record.dafny_code
            previous_error = record.verifier_output or record.error or "Unknown failure"

    if args.evaluation_mode == "independent":
        v = [r.verifier_success for r in records]
        a = [bool(r.verifier_success and r.semantic_aligned) for r in records]
        metrics = {f"pass_at_{k}": any(v[:k]) for k in (1, 3, 5) if k <= args.max_attempts}
        metrics.update(
            {f"aligned_pass_at_{k}": any(a[:k]) for k in (1, 3, 5) if k <= args.max_attempts}
        )
    else:
        metrics = {
            f"repair_at_{k}": bool(first_verified and first_verified <= k)
            for k in (1, 3, 5, 7)
            if k <= args.max_attempts
        }
        metrics.update(
            {
                f"aligned_repair_at_{k}": bool(first_aligned and first_aligned <= k)
                for k in (1, 3, 5, 7)
                if k <= args.max_attempts
            }
        )

    summary = {
        "task_id": task_id,
        "condition": condition_key(args, coder),
        "instructor": args.instructor,
        "policy": args.policy if args.instructor == "trained" else None,
        "coder": coder.key,
        "evaluation_mode": args.evaluation_mode,
        "feedback_mode": args.feedback_mode,
        "recursion_hint": args.recursion_hint,
        "adapter_scale": args.adapter_scale,
        "slm_decode": args.slm_decode,
        "samples_or_attempts_run": len(records),
        "first_verified_index": first_verified,
        "first_aligned_verified_index": first_aligned,
        **metrics,
        "any_verified": any(r.verifier_success for r in records),
        "any_aligned": any(r.verifier_success and r.semantic_aligned for r in records),
        "any_aligned_nonrecursive": any(
            r.verifier_success and r.semantic_aligned and not r.recursive for r in records
        ),
        "recursive_generation_rate": sum(r.recursive for r in records) / len(records),
        "total_coder_prompt_tokens": sum(r.coder_prompt_tokens for r in records),
        "total_coder_completion_tokens": sum(r.coder_completion_tokens for r in records),
        "total_instructor_prompt_tokens": sum(r.instructor_prompt_tokens for r in records),
        "total_instructor_completion_tokens": sum(r.instructor_completion_tokens for r in records),
        "total_slm_generated_tokens": sum(r.slm_generated_tokens for r in records),
        "total_latency_sec": sum(r.latency_sec for r in records),
        "api_or_runtime_errors": sum(bool(r.error) for r in records),
        "attempts": [asdict(r) for r in records],
    }
    atomic_json(trajectory_path, summary)
    return summary


def aggregate(condition_dir, rows, mode):
    n = len(rows)
    rate = lambda k: sum(bool(r.get(k)) for r in rows) / n if n else 0.0
    keys = (
        ("pass_at_1", "pass_at_3", "pass_at_5", "aligned_pass_at_1", "aligned_pass_at_3", "aligned_pass_at_5")
        if mode == "independent"
        else (
            "repair_at_1",
            "repair_at_3",
            "repair_at_5",
            "repair_at_7",
            "aligned_repair_at_1",
            "aligned_repair_at_3",
            "aligned_repair_at_5",
            "aligned_repair_at_7",
        )
    )
    result = {
        "n_tasks": n,
        **{k: rate(k) for k in keys},
        "any_verified_rate": rate("any_verified"),
        "any_aligned_rate": rate("any_aligned"),
        "aligned_nonrecursive_rate": rate("any_aligned_nonrecursive"),
        "mean_recursive_generation_rate": (
            sum(r["recursive_generation_rate"] for r in rows) / n if n else 0
        ),
        "mean_coder_tokens": (
            sum(r["total_coder_prompt_tokens"] + r["total_coder_completion_tokens"] for r in rows) / n
            if n
            else 0
        ),
        "mean_instructor_tokens": (
            sum(
                r["total_instructor_prompt_tokens"]
                + r["total_instructor_completion_tokens"]
                + r["total_slm_generated_tokens"]
                for r in rows
            )
            / n
            if n
            else 0
        ),
        "mean_latency_sec": sum(r["total_latency_sec"] for r in rows) / n if n else 0,
        "runtime_error_rate": sum(r["api_or_runtime_errors"] > 0 for r in rows) / n if n else 0,
    }
    atomic_json(condition_dir / "summary.json", result)
    if rows:
        fields = [k for k in rows[0] if k != "attempts"]
        with (condition_dir / "tasks.csv").open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fields)
            writer.writeheader()
            for row in rows:
                writer.writerow({k: row.get(k) for k in fields})
    return result


def build_parser():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    p.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT)
    p.add_argument("--instructor", choices=["trained", "untrained", "none", "self", "external"], required=True)
    p.add_argument("--policy", choices=["openai", "qwen", "mixed"], default=None)
    p.add_argument("--checkpoint", type=Path, default=None)
    p.add_argument("--coder", default=DEFAULT_CODER_MODELS[0])
    p.add_argument("--external-instructor-model", default="openai:gpt-5.4")
    p.add_argument("--evaluation-mode", choices=["repair", "independent"], default="repair")
    p.add_argument("--feedback-mode", choices=["full", "coder_only", "none"], default="full")
    p.add_argument("--recursion-hint", action=argparse.BooleanOptionalAction, default=True)
    p.add_argument("--adapter-scale", type=float, default=1.0)
    p.add_argument("--slm-decode", choices=["greedy", "train_match"], default="train_match")
    p.add_argument("--max-attempts", type=int, default=DEFAULT_MAX_ATTEMPTS)
    p.add_argument("--dafny-timeout", type=int, default=DEFAULT_DAFNY_TIMEOUT)
    p.add_argument("--coder-max-tokens", type=int, default=8192)
    p.add_argument("--coder-temperature", type=float, default=0.2)
    p.add_argument("--openai-coder-reasoning", default="medium")
    p.add_argument("--semantic-judge", action=argparse.BooleanOptionalAction, default=True)
    p.add_argument("--limit", type=int, default=0)
    p.add_argument("--seed", type=int, default=20260811)
    p.add_argument("--overwrite", action="store_true")
    p.add_argument(
        "--fail-on-runtime-errors",
        action="store_true",
        help="Exit nonzero on API/runtime errors instead of counting them as model failures.",
    )
    return p


def main():
    args = build_parser().parse_args()
    if args.instructor == "trained" and not args.policy:
        raise SystemExit("--policy is required with --instructor trained")
    if args.instructor != "trained" and args.policy:
        raise SystemExit("--policy is only valid with --instructor trained")
    if args.adapter_scale < 0:
        raise SystemExit("--adapter-scale must be nonnegative")
    if args.evaluation_mode == "independent" and args.feedback_mode != "none":
        logging.warning("Independent mode ignores repair context; forcing --feedback-mode none")
        args.feedback_mode = "none"

    coder = parse_model_spec(args.coder)
    condition = condition_key(args, coder)
    condition_dir = args.output_root / condition
    condition_dir.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[logging.FileHandler(condition_dir / "evaluation.log"), logging.StreamHandler()],
        force=True,
    )
    checkpoint = args.checkpoint or (POLICY_CHECKPOINTS[args.policy] if args.policy else None)
    config = vars(args).copy()
    config.update(
        {
            "dataset": str(args.dataset),
            "output_root": str(args.output_root),
            "checkpoint": str(checkpoint) if checkpoint else None,
            "slm_model": SLM_MODEL_NAME,
            "condition": condition,
            "coder": coder.key,
            "judge_model": os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.4"),
            "max_prompt_tokens": MAX_PROMPT_TOKENS,
            "max_new_tokens": MAX_NEW_TOKENS,
        }
    )
    atomic_json(condition_dir / "config.json", config)

    slm_pg = tokenizer = None
    if args.instructor in {"trained", "untrained"}:
        slm_pg, tokenizer = load_policy_model(
            args.instructor,
            args.policy,
            args.checkpoint,
            args.adapter_scale,
        )

    folders = sorted(x for x in args.dataset.iterdir() if x.is_dir())
    if args.limit > 0:
        folders = folders[: args.limit]
    rows = []
    logging.info("Evaluating %d tasks: %s", len(folders), condition)
    for i, folder in enumerate(folders, 1):
        task = read_task(folder)
        if not task:
            logging.warning("Skipping %s: no description", folder.name)
            continue
        logging.info("[%d/%d] %s", i, len(folders), folder.name)
        rows.append(evaluate_task(folder.name, task, args, coder, slm_pg, tokenizer, condition_dir))

    summary = aggregate(condition_dir, rows, args.evaluation_mode)
    logging.info("Summary: %s", json.dumps(summary, sort_keys=True))


if __name__ == "__main__":
    main()
