#!/usr/bin/env python3
"""Proof2Silicon journal evaluation harness for held-out Input_dataset_3.

One process evaluates one experimental condition.  A condition is defined by:
  * instructor: trained / untrained / none / self / external
  * trained policy: openai / qwen / mixed
  * downstream coder model
  * repair-vs-independent evaluation mode
  * recursion-hint, feedback, LoRA-strength, and SLM-decoding ablations

The harness stores every attempt plus per-task and aggregate summaries.  Dafny
verification is followed by the same anti-reward-hacking semantic judge used by
journal training.  "repair@k" is used for iterative verifier-feedback attempts;
"pass@k" is reserved for independent first-attempt samples.
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
    "hf:mistralai/Devstral-Small-2-24B-Instruct-2512",
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
    provider, model = provider.lower().strip(), model.strip()
    if provider not in {"openai", "hf"} or not model:
        raise ValueError(f"Invalid model spec: {value}")
    return ModelSpec(provider, model)


def read_task(folder: Path) -> str:
    for name in ("detailed_description.txt", "one_line_description.txt"):
        path = folder / name
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
    decl = re.compile(r"\b(?:method|function(?:\s+method)?|lemma|predicate)\s+([A-Za-z_][A-Za-z0-9_]*)\b", re.I)
    matches = list(decl.finditer(code or ""))
    for i, match in enumerate(matches):
        name = match.group(1)
        end = matches[i + 1].start() if i + 1 < len(matches) else len(code)
        body = code[match.end():end]
        if re.search(rf"\b{re.escape(name)}\s*\(", body):
            names.append(name)
    names = sorted(set(names))
    return bool(names), names


def run_dafny(code: str, work_dir: Path, timeout_sec: int) -> Tuple[bool, str]:
    work_dir.mkdir(parents=True, exist_ok=True)
    path = work_dir / "candidate.dfy"
    path.write_text(code or "", encoding="utf-8")
    if not (code or "").strip():
        return False, "Error: empty Dafny program"
    try:
        proc = subprocess.run(["dafny", str(path)], stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              text=True, timeout=timeout_sec, check=False)
        output = proc.stdout or ""
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
    return OpenAI(api_key=key, base_url=os.environ.get("HF_BASE_URL", "https://router.huggingface.co/v1"))


def usage_counts(response: Any) -> Tuple[int, int]:
    usage = getattr(response, "usage", None)
    if usage is None:
        return 0, 0
    p = int(getattr(usage, "input_tokens", 0) or getattr(usage, "prompt_tokens", 0) or 0)
    c = int(getattr(usage, "output_tokens", 0) or getattr(usage, "completion_tokens", 0) or 0)
    return p, c


def call_model(spec: ModelSpec, system: str, user: str, *, max_tokens: int,
               reasoning: Optional[str] = None, temperature: float = 0.2,
               retries: int = 3) -> Tuple[str, int, int]:
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
                p, c = usage_counts(response)
                return (getattr(response, "output_text", "") or "").strip(), p, c
            response = client.chat.completions.create(
                model=spec.model,
                messages=[{"role": "system", "content": system}, {"role": "user", "content": user}],
                temperature=temperature, max_tokens=max_tokens, stream=False,
            )
            p, c = usage_counts(response)
            return (response.choices[0].message.content or "").strip(), p, c
        except Exception as exc:
            last_error = exc
            logging.warning("API attempt %d/%d failed for %s: %s", attempt, retries, spec.key, exc)
            if attempt < retries:
                time.sleep(min(8, 2 ** attempt))
    raise RuntimeError(f"API failed after {retries} attempts for {spec.key}: {last_error}")


def load_policy_model(instructor: str, policy_name: Optional[str], checkpoint_override: Optional[Path],
                      adapter_scale: float):
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
        logging.info("Loaded %s checkpoint: missing=%d unexpected=%d", policy_name, len(missing), len(unexpected))
        if adapter_scale != 1.0:
            with torch.no_grad():
                n = 0
                for name, parameter in slm_pg.named_parameters():
                    if "lora_B" in name:
                        parameter.mul_(adapter_scale)
                        n += 1
            logging.info("Scaled %d LoRA-B tensors by %.3f", n, adapter_scale)
    slm_pg.eval()
    if hasattr(slm_pg.model, "gradient_checkpointing_disable"):
        slm_pg.model.gradient_checkpointing_disable()
    slm_pg.model.config.use_cache = True
    return slm_pg, tokenizer


def recursion_sentence(enabled: bool) -> str:
    return " Avoid recursion; prefer iterative control flow with invariants." if enabled else ""


def generate_slm_instruction(slm_pg, tokenizer, prompt: str, decode_mode: str, seed: int,
                             recursion_hint: bool) -> Tuple[str, int]:
    messages = [
        {"role": "system", "content": "You are a prompt-policy model. Produce a concise instruction for a Dafny coding agent. Preserve the exact requested task." + recursion_sentence(recursion_hint)},
        {"role": "user", "content": prompt},
    ]
    try:
        rendered = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True, enable_thinking=False)
    except TypeError:
        rendered = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    inputs = tokenizer(rendered, return_tensors="pt", truncation=True, padding=False, max_length=MAX_PROMPT_TOKENS)
    device = next(slm_pg.model.parameters()).device
    inputs = {k: v.to(device) for k, v in inputs.items()}
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)
    generation: Dict[str, Any] = {
        "max_new_tokens": MAX_NEW_TOKENS,
        "repetition_penalty": 1.12,
        "no_repeat_ngram_size": 4,
    }
    if decode_mode == "greedy":
        generation["do_sample"] = False
    elif decode_mode == "train_match":
        generation.update(do_sample=True, temperature=0.25, top_p=0.90, top_k=40)
    else:
        raise ValueError(decode_mode)
    with torch.no_grad():
        output = slm_pg.model.generate(**inputs, pad_token_id=tokenizer.pad_token_id,
                                       eos_token_id=tokenizer.eos_token_id, **generation)
    prompt_len = inputs["input_ids"].shape[1]
    generated = output[0][prompt_len:]
    return tokenizer.decode(generated, skip_special_tokens=True).strip(), int(generated.numel())


def initial_instructor_prompt(task: str, recursion_hint: bool) -> str:
    return (
        "Create an instruction for another coding model that must solve exactly the following Dafny task. "
        "Focus on specifications, invariants, proof obligations, edge cases, and verifier-friendly control flow. "
        "Do not substitute another problem." + recursion_sentence(recursion_hint) + f"\n\nTASK:\n{task}"
    )


def repair_instructor_prompt(task: str, code: str, verifier_output: str, recursion_hint: bool) -> str:
    return (
        "Create a revised instruction for another coding model. Preserve the original Dafny task exactly and diagnose "
        "the previous verifier failure." + recursion_sentence(recursion_hint) +
        f"\n\nORIGINAL TASK:\n{task}\n\nPREVIOUS CODE:\n{code}\n\nVERIFIER OUTPUT:\n{verifier_output}"
    )


def coder_prompt(task: str, instruction: Optional[str], previous_code: str, previous_error: str,
                 recursion_hint: bool) -> str:
    pieces = [f"Original task:\n{task}"]
    if instruction:
        pieces.append(f"Instructor guidance:\n{instruction}")
    if previous_code:
        pieces.append(f"Previous Dafny code:\n{previous_code}")
    if previous_error:
        pieces.append(f"Previous verifier feedback:\n{previous_error}")
    requirements = (
        "Requirements:\n- Solve exactly the original task; preserve requested names, inputs, outputs, and behavior.\n"
        "- Return exactly one complete Dafny program inside ```dafny ... ``` and no other code block.\n"
        "- Include all specifications/invariants/assertions needed for verification."
    )
    if recursion_hint:
        requirements += "\n- Avoid recursion; prefer loops with invariants."
    pieces.append(requirements)
    return "\n\n".join(pieces)


def get_instruction(args: argparse.Namespace, task: str, previous_code: str, previous_error: str,
                    coder_spec: ModelSpec, slm_pg, tokenizer, seed: int) -> Tuple[Optional[str], int, int, int]:
    if args.instructor == "none":
        return None, 0, 0, 0
    use_repair_context = bool(previous_code or previous_error) and args.feedback_mode == "full"
    prompt = (repair_instructor_prompt(task, previous_code, previous_error, args.recursion_hint)
              if use_repair_context else initial_instructor_prompt(task, args.recursion_hint))
    if args.instructor in {"trained", "untrained"}:
        text, n = generate_slm_instruction(slm_pg, tokenizer, prompt, args.slm_decode, seed, args.recursion_hint)
        return text, 0, 0, n
    if args.instructor == "self":
        text, p, c = call_model(coder_spec,
            "You are the instructor in a two-agent Dafny system. Do not write final code; give precise guidance.",
            prompt, max_tokens=args.instructor_max_tokens,
            reasoning="low" if coder_spec.provider == "openai" else None, temperature=0.2)
        return text, p, c, 0
    if args.instructor == "external":
        spec = parse_model_spec(args.external_instructor_model)
        text, p, c = call_model(spec,
            "You are the instructor in a two-agent Dafny system. Do not write final code; give precise guidance.",
            prompt, max_tokens=args.instructor_max_tokens,
            reasoning=args.external_instructor_reasoning if spec.provider == "openai" else None, temperature=0.2)
        return text, p, c, 0
    raise ValueError(args.instructor)


def semantic_judge(task: str, code: str) -> Tuple[bool, Dict[str, Any]]:
    spec = ModelSpec("openai", os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.4"))
    prompt = (
        "Determine only whether the Dafny program attempts to solve the SAME underlying problem as the task. "
        "Do not judge verifier correctness, proof completeness, or minor interface bugs. Answer YES for the same problem "
        "even if buggy. Answer NO only for task substitution, unrelated/generic programs, placeholders, or shells. "
        "Return exactly YES or NO.\n\nTASK:\n" + task + "\n\nPROGRAM:\n" + code
    )
    text, p, c = call_model(spec, "You are an anti-reward-hacking semantic alignment judge.", prompt,
                            max_tokens=32, reasoning=os.environ.get("DAFNY_JUDGE_REASONING", "low"), temperature=0.0)
    normalized = re.sub(r"[^A-Za-z]", "", text).upper()
    return normalized == "YES", {
        "judge_model": spec.model, "raw": text, "prompt_tokens": p, "completion_tokens": c,
        "parsed": normalized if normalized in {"YES", "NO"} else "INVALID",
    }


def condition_key(args: argparse.Namespace, coder: ModelSpec) -> str:
    policy = args.policy if args.instructor == "trained" else "na"
    ext = args.external_instructor_model if args.instructor == "external" else "na"
    return safe_name(
        f"mode={args.evaluation_mode}__instr={args.instructor}__policy={policy}__ext={ext}__coder={coder.key}"
        f"__scale={args.adapter_scale:g}__decode={args.slm_decode}__feedback={args.feedback_mode}"
        f"__rechint={int(args.recursion_hint)}__k={args.max_attempts}__seed={args.seed}"
    )


def evaluate_task(task_id: str, task: str, args: argparse.Namespace, coder: ModelSpec,
                  slm_pg, tokenizer, condition_dir: Path) -> Dict[str, Any]:
    trajectory_path = condition_dir / "trajectories" / f"{safe_name(task_id)}.json"
    if trajectory_path.exists() and not args.overwrite:
        return json.loads(trajectory_path.read_text(encoding="utf-8"))

    attempts: List[AttemptRecord] = []
    previous_code = ""
    previous_error = ""
    first_verified: Optional[int] = None
    first_aligned: Optional[int] = None

    for k in range(1, args.max_attempts + 1):
        start = time.time()
        seed_material = f"{args.seed}|{task_id}|{k}|{condition_key(args, coder)}"
        seed = int(hashlib.sha256(seed_material.encode()).hexdigest()[:8], 16)
        if args.evaluation_mode == "independent":
            previous_code_for_call = ""
            previous_error_for_call = ""
        else:
            previous_code_for_call = previous_code if args.feedback_mode in {"full", "coder_only"} else ""
            previous_error_for_call = previous_error if args.feedback_mode in {"full", "coder_only"} else ""
        try:
            instruction, ip, ic, slm_tokens = get_instruction(
                args, task, previous_code_for_call, previous_error_for_call, coder, slm_pg, tokenizer, seed)
            cp = coder_prompt(task, instruction, previous_code_for_call, previous_error_for_call, args.recursion_hint)
            response, coder_p, coder_c = call_model(
                coder, "You are an expert Dafny programmer. Return only the requested complete Dafny program.", cp,
                max_tokens=args.coder_max_tokens,
                reasoning=args.openai_coder_reasoning if coder.provider == "openai" else None,
                temperature=args.coder_temperature)
            code = extract_dafny_code(response)
            work = condition_dir / "work" / safe_name(task_id) / f"sample_{k}"
            verified, verifier_output = run_dafny(code, work, args.dafny_timeout)
            recursive, recursion_names = detect_recursion(code)
            aligned: Optional[bool] = None
            semantic_meta: Dict[str, Any] = {}
            if verified and args.semantic_judge:
                aligned, semantic_meta = semantic_judge(task, code)
            elif verified:
                aligned = True
            record = AttemptRecord(
                task_id, args.instructor, args.policy if args.instructor == "trained" else None,
                coder.key, args.evaluation_mode, args.feedback_mode, args.recursion_hint,
                args.adapter_scale, args.slm_decode, k, instruction or "", response, code, verified,
                verifier_output, aligned, semantic_meta, recursive, recursion_names,
                ip, ic, coder_p, coder_c, slm_tokens, time.time() - start)
        except Exception as exc:
            logging.exception("Task %s sample/attempt %d failed", task_id, k)
            record = AttemptRecord(
                task_id, args.instructor, args.policy if args.instructor == "trained" else None,
                coder.key, args.evaluation_mode, args.feedback_mode, args.recursion_hint,
                args.adapter_scale, args.slm_decode, k, "", "", "", False, "", None, {}, False, [],
                0, 0, 0, 0, 0, time.time() - start, str(exc))
        attempts.append(record)
        append_jsonl(condition_dir / "attempts.jsonl", asdict(record))
        if record.verifier_success and first_verified is None:
            first_verified = k
        if record.verifier_success and record.semantic_aligned and first_aligned is None:
            first_aligned = k
        if args.evaluation_mode == "repair" and record.verifier_success and (not args.semantic_judge or record.semantic_aligned):
            break
        if args.evaluation_mode == "repair":
            previous_code = record.dafny_code
            previous_error = record.verifier_output or record.error or "Unknown failure"

    verified_samples = sum(x.verifier_success for x in attempts)
    aligned_samples = sum(bool(x.verifier_success and x.semantic_aligned) for x in attempts)
    recursive_samples = sum(x.recursive for x in attempts)
    prefix = "pass" if args.evaluation_mode == "independent" else "repair"
    summary: Dict[str, Any] = {
        "task_id": task_id, "condition": condition_key(args, coder), "evaluation_mode": args.evaluation_mode,
        "instructor": args.instructor, "policy": args.policy if args.instructor == "trained" else None,
        "coder": coder.key, "feedback_mode": args.feedback_mode, "recursion_hint": args.recursion_hint,
        "adapter_scale": args.adapter_scale, "slm_decode": args.slm_decode, "samples_or_attempts_run": len(attempts),
        "first_verified_index": first_verified, "first_aligned_verified_index": first_aligned,
        "verified_sample_fraction": verified_samples / len(attempts) if attempts else 0.0,
        "aligned_sample_fraction": aligned_samples / len(attempts) if attempts else 0.0,
        "recursive_sample_fraction": recursive_samples / len(attempts) if attempts else 0.0,
        "any_verified": bool(first_verified), "any_aligned": bool(first_aligned),
        "any_aligned_nonrecursive": any(x.verifier_success and x.semantic_aligned and not x.recursive for x in attempts),
        "total_coder_prompt_tokens": sum(x.coder_prompt_tokens for x in attempts),
        "total_coder_completion_tokens": sum(x.coder_completion_tokens for x in attempts),
        "total_instructor_prompt_tokens": sum(x.instructor_prompt_tokens for x in attempts),
        "total_instructor_completion_tokens": sum(x.instructor_completion_tokens for x in attempts),
        "total_slm_generated_tokens": sum(x.slm_generated_tokens for x in attempts),
        "total_latency_sec": sum(x.latency_sec for x in attempts),
        "api_or_runtime_errors": sum(bool(x.error) for x in attempts),
        "attempts": [asdict(x) for x in attempts],
    }
    for kk in (1, 3, 5, 7):
        if args.evaluation_mode == "repair":
            summary[f"{prefix}_at_{kk}"] = bool(first_verified and first_verified <= kk)
            summary[f"aligned_{prefix}_at_{kk}"] = bool(first_aligned and first_aligned <= kk)
        else:
            subset = attempts[:min(kk, len(attempts))]
            summary[f"{prefix}_at_{kk}"] = any(x.verifier_success for x in subset)
            summary[f"aligned_{prefix}_at_{kk}"] = any(x.verifier_success and x.semantic_aligned for x in subset)
    atomic_json(trajectory_path, summary)
    return summary


def aggregate(condition_dir: Path, rows: List[Dict[str, Any]], evaluation_mode: str) -> Dict[str, Any]:
    n = len(rows)
    rate = lambda key: sum(bool(r.get(key)) for r in rows) / n if n else 0.0
    prefix = "pass" if evaluation_mode == "independent" else "repair"
    result: Dict[str, Any] = {"n_tasks": n, "evaluation_mode": evaluation_mode}
    for kk in (1, 3, 5, 7):
        result[f"{prefix}_at_{kk}"] = rate(f"{prefix}_at_{kk}")
        result[f"aligned_{prefix}_at_{kk}"] = rate(f"aligned_{prefix}_at_{kk}")
    result.update({
        "any_verified_rate": rate("any_verified"),
        "any_aligned_rate": rate("any_aligned"),
        "any_aligned_nonrecursive_rate": rate("any_aligned_nonrecursive"),
        "mean_verified_sample_fraction": sum(r["verified_sample_fraction"] for r in rows) / n if n else 0.0,
        "mean_aligned_sample_fraction": sum(r["aligned_sample_fraction"] for r in rows) / n if n else 0.0,
        "mean_recursive_sample_fraction": sum(r["recursive_sample_fraction"] for r in rows) / n if n else 0.0,
        "mean_coder_tokens": sum(r["total_coder_prompt_tokens"] + r["total_coder_completion_tokens"] for r in rows) / n if n else 0.0,
        "mean_instructor_tokens": sum(r["total_instructor_prompt_tokens"] + r["total_instructor_completion_tokens"] + r["total_slm_generated_tokens"] for r in rows) / n if n else 0.0,
        "mean_latency_sec": sum(r["total_latency_sec"] for r in rows) / n if n else 0.0,
        "runtime_error_rate": sum(r["api_or_runtime_errors"] > 0 for r in rows) / n if n else 0.0,
    })
    aligned_indexes = [r["first_aligned_verified_index"] for r in rows if r.get("first_aligned_verified_index")]
    result["mean_index_to_aligned_success"] = sum(aligned_indexes) / len(aligned_indexes) if aligned_indexes else None
    atomic_json(condition_dir / "summary.json", result)
    if rows:
        keys = [k for k in rows[0] if k != "attempts"]
        with (condition_dir / "tasks.csv").open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=keys)
            writer.writeheader()
            for row in rows:
                writer.writerow({k: row.get(k) for k in keys})
    return result


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    p.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT)
    p.add_argument("--instructor", choices=["trained", "untrained", "none", "self", "external"], required=True)
    p.add_argument("--policy", choices=["openai", "qwen", "mixed"])
    p.add_argument("--checkpoint", type=Path)
    p.add_argument("--coder", default=DEFAULT_CODER_MODELS[0], help="provider:model")
    p.add_argument("--external-instructor-model", default="openai:gpt-5.4")
    p.add_argument("--external-instructor-reasoning", default="low")
    p.add_argument("--instructor-max-tokens", type=int, default=2048)
    p.add_argument("--adapter-scale", type=float, default=1.0)
    p.add_argument("--slm-decode", choices=["greedy", "train_match"], default="train_match")
    p.add_argument("--evaluation-mode", choices=["repair", "independent"], default="repair")
    p.add_argument("--feedback-mode", choices=["full", "coder_only", "none"], default="full")
    p.add_argument("--recursion-hint", action=argparse.BooleanOptionalAction, default=True)
    p.add_argument("--max-attempts", type=int, default=DEFAULT_MAX_ATTEMPTS)
    p.add_argument("--dafny-timeout", type=int, default=DEFAULT_DAFNY_TIMEOUT)
    p.add_argument("--coder-max-tokens", type=int, default=8192)
    p.add_argument("--coder-temperature", type=float, default=0.2)
    p.add_argument("--openai-coder-reasoning", default="medium")
    p.add_argument("--semantic-judge", action=argparse.BooleanOptionalAction, default=True)
    p.add_argument("--limit", type=int, default=0)
    p.add_argument("--seed", type=int, default=20260811)
    p.add_argument("--overwrite", action="store_true")
    return p


def main() -> None:
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
    logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s",
                        handlers=[logging.FileHandler(condition_dir / "evaluation.log"), logging.StreamHandler()], force=True)

    checkpoint = args.checkpoint or (POLICY_CHECKPOINTS[args.policy] if args.policy else None)
    config = vars(args).copy()
    config.update({"dataset": str(args.dataset), "output_root": str(args.output_root),
                   "checkpoint": str(checkpoint) if checkpoint else None,
                   "slm_model": SLM_MODEL_NAME, "condition": condition, "coder": coder.key,
                   "judge_model": os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.4"),
                   "max_prompt_tokens": MAX_PROMPT_TOKENS, "max_new_tokens": MAX_NEW_TOKENS})
    atomic_json(condition_dir / "config.json", config)

    slm_pg = tokenizer = None
    if args.instructor in {"trained", "untrained"}:
        slm_pg, tokenizer = load_policy_model(args.instructor, args.policy, args.checkpoint, args.adapter_scale)

    folders = sorted(x for x in args.dataset.iterdir() if x.is_dir())
    if args.limit > 0:
        folders = folders[:args.limit]
    rows: List[Dict[str, Any]] = []
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
