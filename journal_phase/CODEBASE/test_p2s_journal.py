#!/usr/bin/env python3
"""Hardware-aligned Proof2Silicon journal evaluation on Sample_dafny.

Dataset layout expected by default::

    The_hardware_dataset/Sample_dafny/
      HW_001/problem.txt
      HW_002/problem.txt
      ...

The original files in each HW_* dataset directory are never modified.  Results
are written to a separate condition directory while preserving HW_001, HW_002,
... as subdirectories.

A P2S candidate is accepted only when it:
  1) verifies in Dafny,
  2) is semantically aligned with the original problem, and
  3) contains the requested hardware bit-width mapping when problem.txt states
     an explicit width.

The bit-width check is a deterministic structural compliance audit, not a formal
proof of hardware equivalence.  Its evidence is saved per attempt for auditing.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import logging
import os
import re
import shutil
import time
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import test_journal as tj

ROOT = Path("/u/mjha1/Proof2Silicon/journal_phase")
DEFAULT_DATASET = ROOT / "The_hardware_dataset" / "Sample_dafny"
DEFAULT_OUTPUT = ROOT / "p2s_journal_eval"
DEFAULT_MAX_ATTEMPTS = 5


def read_problem(folder: Path) -> str:
    path = folder / "problem.txt"
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8").strip()


def extract_bit_requirements(problem: str) -> Dict[str, Any]:
    """Extract explicit bit widths and the snippets that requested them."""
    patterns = [
        re.compile(r"\b(\d{1,3})\s*(?:-\s*)?bits?\b", re.I),
        re.compile(r"\b(?:u?int|bv)\s*<?\s*(\d{1,3})\s*>?\b", re.I),
        re.compile(r"\bap_(?:u)?int\s*<\s*(\d{1,3})\s*>", re.I),
    ]
    widths = set()
    mentions = []
    for pattern in patterns:
        for match in pattern.finditer(problem or ""):
            try:
                width = int(match.group(1))
            except (TypeError, ValueError):
                continue
            if width <= 0 or width > 256:
                continue
            widths.add(width)
            lo = max(0, match.start() - 45)
            hi = min(len(problem), match.end() + 45)
            mentions.append(
                {
                    "width": width,
                    "match": match.group(0),
                    "context": re.sub(r"\s+", " ", problem[lo:hi]).strip(),
                }
            )
    return {
        "applicable": bool(widths),
        "requested_widths": sorted(widths),
        "mentions": mentions,
    }


def _width_evidence(code: str, width: int) -> List[str]:
    """Return auditable textual evidence that code represents a width."""
    evidence = []
    text = code or ""
    pow2 = 1 << width
    umax = pow2 - 1
    smin = -(1 << (width - 1)) if width > 0 else 0
    smax = (1 << (width - 1)) - 1 if width > 0 else 0

    strong_patterns = [
        (r"\bbv\s*%d\b" % width, "Dafny bv%d type" % width),
        (r"\buint\s*%d\b" % width, "uint%d type" % width),
        (r"\bint\s*%d\b" % width, "int%d type" % width),
        (r"\bap_uint\s*<\s*%d\s*>" % width, "ap_uint<%d> type" % width),
        (r"\bap_int\s*<\s*%d\s*>" % width, "ap_int<%d> type" % width),
    ]
    for pattern, label in strong_patterns:
        if re.search(pattern, text, flags=re.I):
            evidence.append(label)

    symbolic_patterns = [
        (r"2\s*\^\s*%d\b" % width, "2^%d bound" % width),
        (r"2\s*\*\*\s*%d\b" % width, "2**%d bound" % width),
        (r"1\s*<<\s*%d\b" % width, "1<<%d bound" % width),
    ]
    for pattern, label in symbolic_patterns:
        if re.search(pattern, text):
            evidence.append(label)

    # Decimal range/mask constants are accepted as mathematically equivalent
    # evidence. Save the exact kind so reviewers can audit false positives.
    if re.search(r"(?<!\d)%d(?!\d)" % pow2, text):
        evidence.append("decimal 2^%d bound (%d)" % (width, pow2))
    if re.search(r"(?<!\d)%d(?!\d)" % umax, text):
        evidence.append("unsigned %d-bit max (%d)" % (width, umax))
    if str(smin) in text and re.search(r"(?<!\d)%d(?!\d)" % smax, text):
        evidence.append("signed %d-bit range (%d..%d)" % (width, smin, smax))

    # Common masking/modulus formulations. Using an f-string here is deliberate:
    # a literal percent sign in an old-style %-formatted regex is interpreted as
    # a formatting directive and previously crashed the P2S evaluator.
    if re.search(rf"%\s*{pow2}(?!\d)", text):
        evidence.append("modulo 2^%d" % width)
    if re.search(r"&\s*%d(?!\d)" % umax, text):
        evidence.append("%d-bit mask" % width)

    # Deduplicate while retaining stable human-readable order.
    out = []
    seen = set()
    for item in evidence:
        if item not in seen:
            seen.add(item)
            out.append(item)
    return out


def audit_bit_mapping(problem: str, code: str) -> Dict[str, Any]:
    requirements = extract_bit_requirements(problem)
    widths = requirements["requested_widths"]
    evidence = {}
    missing = []
    for width in widths:
        hits = _width_evidence(code, width)
        evidence[str(width)] = hits
        if not hits:
            missing.append(width)

    present = None if not requirements["applicable"] else not missing
    return {
        "bit_mapping_applicable": requirements["applicable"],
        "requested_bit_widths": widths,
        "bit_requirement_mentions": requirements["mentions"],
        "bit_mapping_evidence": evidence,
        "bit_mapping_present": present,
        "bit_mapping_missing_widths": missing,
        "checker_kind": "deterministic_structural_width_audit_v1",
    }


def bit_ok(audit: Dict[str, Any]) -> bool:
    if not audit.get("bit_mapping_applicable"):
        return True
    return audit.get("bit_mapping_present") is True


def initial_policy_prompt(task: str, recursion_hint: bool) -> str:
    text = (
        "Create an instruction for another coding model that must solve exactly "
        "the following hardware-oriented Dafny task. Preserve every interface, "
        "numeric-width requirement, specification, and behavior stated by the task. "
        "Focus on invariants, proof obligations, edge cases, and verifier-friendly "
        "implementation strategy. Do not substitute another problem."
    )
    if recursion_hint:
        text += " Avoid recursion and prefer iterative control flow with invariants."
    return text + "\n\nTASK:\n" + task


def repair_policy_prompt(
    task: str,
    code: str,
    verifier_output: str,
    recursion_hint: bool,
    bit_reminder: bool,
) -> str:
    text = (
        "Create a revised instruction for another coding model. Preserve the "
        "original hardware-oriented Dafny task exactly and diagnose the previous "
        "attempt."
    )
    if recursion_hint:
        text += " Avoid recursion and prefer iterative control flow with invariants."
    if bit_reminder:
        text += (
            "\n\nHARDWARE BIT-WIDTH REMINDER: Re-read the original task's exact "
            "bit-width requirement (for example 4-bit, 8-bit, or another stated "
            "width). The revised instruction must explicitly preserve that bit "
            "mapping using Dafny bitvectors or mathematically equivalent range, "
            "wrapping, or masking constraints. Do not omit the width semantics."
        )
    return (
        text
        + "\n\nORIGINAL TASK:\n"
        + task
        + "\n\nPREVIOUS CODE:\n"
        + (code or "")
        + "\n\nPREVIOUS VERIFIER FEEDBACK:\n"
        + (verifier_output or "")
    )


def get_policy_instruction(
    args,
    task: str,
    previous_code: str,
    previous_error: str,
    slm_pg,
    tokenizer,
    seed: int,
    bit_reminder: bool,
) -> Tuple[Optional[str], int]:
    if args.instructor == "none":
        return None, 0

    if previous_code or previous_error:
        prompt = repair_policy_prompt(
            task,
            previous_code,
            previous_error,
            args.recursion_hint,
            bit_reminder,
        )
    else:
        prompt = initial_policy_prompt(task, args.recursion_hint)

    text, tokens = tj.generate_slm_instruction(
        slm_pg,
        tokenizer,
        prompt,
        args.slm_decode,
        seed,
        args.recursion_hint,
    )
    return text, tokens


def coder_prompt(
    task: str,
    instruction: Optional[str],
    previous_code: str,
    previous_error: str,
    recursion_hint: bool,
) -> str:
    pieces = ["Original hardware-oriented task:\n" + task]
    if instruction:
        pieces.append("Instructor guidance:\n" + instruction)
    if previous_code:
        pieces.append("Previous Dafny code:\n" + previous_code)
    if previous_error:
        pieces.append("Previous verifier feedback:\n" + previous_error)
    requirements = (
        "Requirements:\n"
        "- Solve exactly the original task; preserve requested names, inputs, outputs, numeric semantics, and behavior.\n"
    )
    if recursion_hint:
        requirements += "- Avoid recursion; prefer loops with invariants.\n"
    requirements += (
        "- Return exactly one complete Dafny program inside ```dafny ... ``` and no other code block.\n"
        "- Include all specifications, invariants, and assertions needed for verification."
    )
    pieces.append(requirements)
    return "\n\n".join(pieces)


def condition_key(args, coder: tj.ModelSpec) -> str:
    policy = args.policy if args.instructor == "trained" else "na"
    return tj.safe_name(
        "instr=%s__policy=%s__fb=full__rechint=%d__bitrem=%d__decode=%s__coder=%s__seed=%d"
        % (
            args.instructor,
            policy,
            int(args.recursion_hint),
            int(args.trained_bit_reminder_after_first_fail),
            args.slm_decode,
            coder.key,
            args.seed,
        )
    )


def _write_attempt_files(hw_dir: Path, record: Dict[str, Any]) -> None:
    idx = int(record["sample_or_attempt"])
    (hw_dir / ("attempt_%02d.dfy" % idx)).write_text(
        record.get("dafny_code", ""), encoding="utf-8"
    )
    tj.atomic_json(hw_dir / ("attempt_%02d.json" % idx), record)


def evaluate_task(
    folder: Path,
    task: str,
    args,
    coder: tj.ModelSpec,
    slm_pg,
    tokenizer,
    condition_dir: Path,
) -> Dict[str, Any]:
    task_id = folder.name
    hw_dir = condition_dir / task_id
    trajectory_path = hw_dir / "trajectory.json"
    if trajectory_path.exists() and not args.overwrite:
        return json.loads(trajectory_path.read_text(encoding="utf-8"))

    hw_dir.mkdir(parents=True, exist_ok=True)
    (hw_dir / "problem.txt").write_text(task, encoding="utf-8")

    requirements = extract_bit_requirements(task)
    records = []
    previous_code = ""
    previous_error = ""
    first_verified = None
    first_aligned = None
    first_hardware_accepted = None

    for sample in range(1, args.max_attempts + 1):
        start = time.time()
        seed_material = "%s|%s|%s|%s" % (
            args.seed,
            task_id,
            sample,
            condition_key(args, coder),
        )
        seed = int(hashlib.sha256(seed_material.encode()).hexdigest()[:8], 16)

        # Requested P2S intervention: trained policies alone receive an explicit
        # width reminder on attempt 2 after a failed first candidate. It is
        # recorded in every artifact so this cannot be mistaken for a matched
        # trained-vs-untrained treatment.
        bit_reminder = bool(
            args.trained_bit_reminder_after_first_fail
            and args.instructor == "trained"
            and sample == 2
            and records
            and not records[0].get("hardware_accepted", False)
            and requirements.get("applicable", False)
        )

        runtime_exc = None
        try:
            instruction, slm_tokens = get_policy_instruction(
                args,
                task,
                previous_code,
                previous_error,
                slm_pg,
                tokenizer,
                seed,
                bit_reminder,
            )
            prompt = coder_prompt(
                task,
                instruction,
                previous_code,
                previous_error,
                args.recursion_hint,
            )
            response, coder_p, coder_c = tj.call_model(
                coder,
                "You are an expert Dafny programmer. Return only the requested complete Dafny program.",
                prompt,
                max_tokens=args.coder_max_tokens,
                reasoning=(
                    args.openai_coder_reasoning if coder.provider == "openai" else None
                ),
                temperature=args.coder_temperature,
            )
            code = tj.extract_dafny_code(response)
            work = hw_dir / "work" / ("attempt_%02d" % sample)
            verified, verifier_output = tj.run_dafny(code, work, args.dafny_timeout)
            recursive, recursion_names = tj.detect_recursion(code)
            aligned = None
            semantic_meta = {}
            if verified and args.semantic_judge:
                aligned, semantic_meta = tj.semantic_judge(task, code)
            elif verified:
                aligned = True

            bit_audit = audit_bit_mapping(task, code)
            hardware_accepted = bool(verified and aligned and bit_ok(bit_audit))

            record = {
                "task_id": task_id,
                "sample_or_attempt": sample,
                "instructor": args.instructor,
                "policy": args.policy if args.instructor == "trained" else None,
                "coder": coder.key,
                "instruction": instruction or "",
                "coder_response": response,
                "dafny_code": code,
                "verifier_success": verified,
                "verifier_output": verifier_output,
                "semantic_aligned": aligned,
                "semantic_metadata": semantic_meta,
                "recursive": recursive,
                "recursion_names": recursion_names,
                "slm_generated_tokens": slm_tokens,
                "coder_prompt_tokens": coder_p,
                "coder_completion_tokens": coder_c,
                "latency_sec": time.time() - start,
                "bit_reminder_applied": bit_reminder,
                **bit_audit,
                "hardware_accepted": hardware_accepted,
                "error": None,
            }
        except Exception as exc:
            runtime_exc = exc
            logging.exception("Task %s attempt %d failed", task_id, sample)
            record = {
                "task_id": task_id,
                "sample_or_attempt": sample,
                "instructor": args.instructor,
                "policy": args.policy if args.instructor == "trained" else None,
                "coder": coder.key,
                "instruction": "",
                "coder_response": "",
                "dafny_code": "",
                "verifier_success": False,
                "verifier_output": "",
                "semantic_aligned": None,
                "semantic_metadata": {},
                "recursive": False,
                "recursion_names": [],
                "slm_generated_tokens": 0,
                "coder_prompt_tokens": 0,
                "coder_completion_tokens": 0,
                "latency_sec": time.time() - start,
                "bit_reminder_applied": bit_reminder,
                **audit_bit_mapping(task, ""),
                "hardware_accepted": False,
                "error": str(exc),
            }

        records.append(record)
        _write_attempt_files(hw_dir, record)

        if runtime_exc is not None and args.fail_on_runtime_errors:
            raise RuntimeError(
                "Runtime/API error in %s attempt %d; refusing to score it as a model failure"
                % (task_id, sample)
            ) from runtime_exc

        if record["verifier_success"] and first_verified is None:
            first_verified = sample
        if (
            record["verifier_success"]
            and record.get("semantic_aligned")
            and first_aligned is None
        ):
            first_aligned = sample
        if record["hardware_accepted"] and first_hardware_accepted is None:
            first_hardware_accepted = sample

        if record["hardware_accepted"]:
            break

        previous_code = record.get("dafny_code", "")
        previous_error = record.get("verifier_output") or record.get("error") or "Unknown failure"
        if record["verifier_success"] and record.get("semantic_aligned") and not bit_ok(record):
            # Keep the non-trained feedback generic. The explicit width-focused
            # reminder is intentionally reserved for the trained attempt-2 flag.
            previous_error = (
                "Dafny verification passed, but the candidate did not satisfy all "
                "additional hardware-compliance acceptance checks. Re-read the "
                "original task and revise the candidate without changing its intent."
            )

    def by_k(index, k):
        return bool(index is not None and index <= k)

    metrics = {}
    for k in (1, 3, 5):
        if k <= args.max_attempts:
            metrics["repair_at_%d" % k] = by_k(first_verified, k)
            metrics["aligned_repair_at_%d" % k] = by_k(first_aligned, k)
            metrics["hardware_accepted_repair_at_%d" % k] = by_k(
                first_hardware_accepted, k
            )

    any_aligned_bitmapped = any(
        r.get("verifier_success")
        and r.get("semantic_aligned")
        and bit_ok(r)
        for r in records
    )
    any_aligned_nonrecursive_bitmapped = any(
        r.get("verifier_success")
        and r.get("semantic_aligned")
        and bit_ok(r)
        and not r.get("recursive")
        for r in records
    )

    summary = {
        "task_id": task_id,
        "condition": condition_key(args, coder),
        "instructor": args.instructor,
        "policy": args.policy if args.instructor == "trained" else None,
        "coder": coder.key,
        "samples_or_attempts_run": len(records),
        "first_verified_index": first_verified,
        "first_aligned_verified_index": first_aligned,
        "first_hardware_accepted_index": first_hardware_accepted,
        **metrics,
        "any_verified": any(r.get("verifier_success") for r in records),
        "any_aligned": any(
            r.get("verifier_success") and r.get("semantic_aligned") for r in records
        ),
        "bit_mapping_applicable": requirements.get("applicable", False),
        "requested_bit_widths": requirements.get("requested_widths", []),
        "any_bit_mapping_present": any(
            r.get("bit_mapping_present") is True for r in records
        ),
        "any_aligned_bitmapped": any_aligned_bitmapped,
        "any_aligned_nonrecursive_bitmapped": any_aligned_nonrecursive_bitmapped,
        "hardware_accepted": first_hardware_accepted is not None,
        "trained_bit_reminder_applied": any(
            r.get("bit_reminder_applied") for r in records
        ),
        "recursive_generation_rate": (
            sum(bool(r.get("recursive")) for r in records) / len(records)
        ),
        "total_coder_tokens": sum(
            int(r.get("coder_prompt_tokens", 0) or 0)
            + int(r.get("coder_completion_tokens", 0) or 0)
            for r in records
        ),
        "total_slm_generated_tokens": sum(
            int(r.get("slm_generated_tokens", 0) or 0) for r in records
        ),
        "total_latency_sec": sum(float(r.get("latency_sec", 0) or 0) for r in records),
        "api_or_runtime_errors": sum(bool(r.get("error")) for r in records),
        "attempts": records,
    }

    tj.atomic_json(trajectory_path, summary)
    selected = next((r for r in records if r.get("hardware_accepted")), None)
    if selected is not None:
        (hw_dir / "final.dfy").write_text(
            selected.get("dafny_code", ""), encoding="utf-8"
        )
    elif records:
        (hw_dir / "last_candidate.dfy").write_text(
            records[-1].get("dafny_code", ""), encoding="utf-8"
        )
    return summary


def aggregate(condition_dir: Path, rows: List[Dict[str, Any]]) -> Dict[str, Any]:
    n = len(rows)

    def rate(key):
        return sum(bool(r.get(key)) for r in rows) / n if n else 0.0

    applicable = [r for r in rows if r.get("bit_mapping_applicable")]
    aligned_applicable = [r for r in applicable if r.get("any_aligned")]

    result = {
        "n_tasks": n,
        "max_attempts": DEFAULT_MAX_ATTEMPTS,
        "repair_at_1": rate("repair_at_1"),
        "repair_at_3": rate("repair_at_3"),
        "repair_at_5": rate("repair_at_5"),
        "aligned_repair_at_1": rate("aligned_repair_at_1"),
        "aligned_repair_at_3": rate("aligned_repair_at_3"),
        "aligned_repair_at_5": rate("aligned_repair_at_5"),
        "hardware_accepted_repair_at_1": rate("hardware_accepted_repair_at_1"),
        "hardware_accepted_repair_at_3": rate("hardware_accepted_repair_at_3"),
        "hardware_accepted_repair_at_5": rate("hardware_accepted_repair_at_5"),
        "any_verified_rate": rate("any_verified"),
        "any_aligned_rate": rate("any_aligned"),
        "hardware_accepted_rate": rate("hardware_accepted"),
        "aligned_nonrecursive_bitmapped_rate": rate(
            "any_aligned_nonrecursive_bitmapped"
        ),
        "bit_mapping_applicable_tasks": len(applicable),
        "bit_mapping_presence_rate_applicable": (
            sum(bool(r.get("any_bit_mapping_present")) for r in applicable)
            / len(applicable)
            if applicable
            else 0.0
        ),
        "aligned_verified_bit_mapping_rate_applicable": (
            sum(bool(r.get("any_aligned_bitmapped")) for r in applicable)
            / len(applicable)
            if applicable
            else 0.0
        ),
        "bit_mapping_rate_given_aligned_applicable": (
            sum(bool(r.get("any_aligned_bitmapped")) for r in aligned_applicable)
            / len(aligned_applicable)
            if aligned_applicable
            else 0.0
        ),
        "trained_bit_reminder_task_rate": rate("trained_bit_reminder_applied"),
        "mean_recursive_generation_rate": (
            sum(float(r.get("recursive_generation_rate", 0) or 0) for r in rows) / n
            if n
            else 0.0
        ),
        "mean_attempts_run": (
            sum(int(r.get("samples_or_attempts_run", 0) or 0) for r in rows) / n
            if n
            else 0.0
        ),
        "mean_coder_tokens": (
            sum(int(r.get("total_coder_tokens", 0) or 0) for r in rows) / n
            if n
            else 0.0
        ),
        "mean_slm_generated_tokens": (
            sum(int(r.get("total_slm_generated_tokens", 0) or 0) for r in rows) / n
            if n
            else 0.0
        ),
        "mean_latency_sec": (
            sum(float(r.get("total_latency_sec", 0) or 0) for r in rows) / n
            if n
            else 0.0
        ),
        "runtime_error_rate": (
            sum(int(r.get("api_or_runtime_errors", 0) or 0) > 0 for r in rows) / n
            if n
            else 0.0
        ),
    }
    tj.atomic_json(condition_dir / "summary.json", result)

    if rows:
        fields = [key for key in rows[0] if key != "attempts"]
        with (condition_dir / "tasks.csv").open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fields)
            writer.writeheader()
            for row in rows:
                writer.writerow({key: row.get(key) for key in fields})
    return result


def build_parser():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--dataset", type=Path, default=DEFAULT_DATASET)
    p.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT)
    p.add_argument(
        "--instructor",
        choices=["trained", "untrained", "none"],
        required=True,
    )
    p.add_argument("--policy", choices=["openai", "qwen", "mixed"], default=None)
    p.add_argument("--checkpoint", type=Path, default=None)
    p.add_argument("--coder", required=True)
    p.add_argument("--max-attempts", type=int, default=DEFAULT_MAX_ATTEMPTS)
    p.add_argument("--dafny-timeout", type=int, default=tj.DEFAULT_DAFNY_TIMEOUT)
    p.add_argument("--coder-max-tokens", type=int, default=8192)
    p.add_argument("--coder-temperature", type=float, default=0.2)
    p.add_argument("--openai-coder-reasoning", default="none")
    p.add_argument("--recursion-hint", action=argparse.BooleanOptionalAction, default=True)
    p.add_argument("--slm-decode", choices=["greedy", "train_match"], default="train_match")
    p.add_argument("--adapter-scale", type=float, default=1.0)
    p.add_argument("--semantic-judge", action=argparse.BooleanOptionalAction, default=True)
    p.add_argument(
        "--trained-bit-reminder-after-first-fail",
        action=argparse.BooleanOptionalAction,
        default=False,
        help=(
            "On trained conditions only, explicitly remind the policy about the "
            "task's bit-width semantics on attempt 2 after a failed attempt 1."
        ),
    )
    p.add_argument("--limit", type=int, default=0)
    p.add_argument("--seed", type=int, default=20260811)
    p.add_argument("--overwrite", action="store_true")
    p.add_argument("--fail-on-runtime-errors", action="store_true")
    return p


def main():
    args = build_parser().parse_args()
    if args.max_attempts != 5:
        raise SystemExit("P2S journal protocol requires --max-attempts 5")
    if args.instructor == "trained" and not args.policy:
        raise SystemExit("--policy is required with --instructor trained")
    if args.instructor != "trained" and args.policy:
        raise SystemExit("--policy is only valid with --instructor trained")
    if args.trained_bit_reminder_after_first_fail and args.instructor != "trained":
        raise SystemExit(
            "--trained-bit-reminder-after-first-fail is only valid for trained conditions"
        )
    if args.adapter_scale < 0:
        raise SystemExit("--adapter-scale must be nonnegative")
    if not args.dataset.is_dir():
        raise SystemExit("P2S dataset not found: %s" % args.dataset)

    coder = tj.parse_model_spec(args.coder)
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

    checkpoint = args.checkpoint or (
        tj.POLICY_CHECKPOINTS[args.policy] if args.policy else None
    )
    config = vars(args).copy()
    for key in ("dataset", "output_root", "checkpoint"):
        value = config.get(key)
        if value is not None:
            config[key] = str(value)
    config.update(
        {
            "condition": condition,
            "coder": coder.key,
            "slm_model": tj.SLM_MODEL_NAME,
            "bit_checker": "deterministic_structural_width_audit_v1",
            "acceptance": "dafny_verified AND semantic_aligned AND bit_mapping_if_applicable",
            "output_layout": "<condition>/HW_XXX/{trajectory,attempts,final}.files",
        }
    )
    tj.atomic_json(condition_dir / "config.json", config)

    slm_pg = tokenizer = None
    if args.instructor in {"trained", "untrained"}:
        slm_pg, tokenizer = tj.load_policy_model(
            args.instructor,
            args.policy,
            args.checkpoint,
            args.adapter_scale,
        )

    folders = sorted(
        p for p in args.dataset.iterdir() if p.is_dir() and p.name.startswith("HW_")
    )
    if args.limit > 0:
        folders = folders[: args.limit]
    if not folders:
        raise SystemExit("No HW_* directories found under %s" % args.dataset)

    rows = []
    logging.info("Evaluating %d P2S tasks: %s", len(folders), condition)
    for index, folder in enumerate(folders, 1):
        task = read_problem(folder)
        if not task:
            logging.warning("Skipping %s: missing/empty problem.txt", folder.name)
            continue
        logging.info("[%d/%d] %s", index, len(folders), folder.name)
        rows.append(
            evaluate_task(folder, task, args, coder, slm_pg, tokenizer, condition_dir)
        )

    summary = aggregate(condition_dir, rows)
    logging.info("Summary: %s", json.dumps(summary, sort_keys=True))


if __name__ == "__main__":
    main()
