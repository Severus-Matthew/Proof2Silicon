#!/usr/bin/env python3
"""Apply API protocol patches, then run the hardware-aware P2S harness.

This entry point also installs a corrected bit-width evidence matcher.  The
original harness used old-style ``%`` string formatting on a regex whose first
character was the literal modulo operator ``%``; Python interpreted that literal
percent sign as a formatting directive and raised ``ValueError`` before a P2S
attempt could be recorded.  Keeping the compatibility patch here lets existing
P2S matrices and launchers resume without changing their scientific protocol.
"""

from __future__ import annotations

import re
from typing import List

# Importing this module installs the existing training-matched OpenAI behavior
# plus strict DeepSeek-V4 non-thinking behavior into test_journal.call_model.
import journal_large_eval_entry  # noqa: F401
import test_p2s_journal


def _fixed_width_evidence(code: str, width: int) -> List[str]:
    """Return auditable evidence that ``code`` represents ``width`` bits.

    This is semantically identical to the checker in test_p2s_journal, but uses
    f-strings for regex construction so literal modulo signs are never consumed
    by Python's old-style percent formatter.
    """
    evidence: List[str] = []
    text = code or ""
    pow2 = 1 << width
    umax = pow2 - 1
    smin = -(1 << (width - 1)) if width > 0 else 0
    smax = (1 << (width - 1)) - 1 if width > 0 else 0

    strong_patterns = [
        (rf"\bbv\s*{width}\b", f"Dafny bv{width} type"),
        (rf"\buint\s*{width}\b", f"uint{width} type"),
        (rf"\bint\s*{width}\b", f"int{width} type"),
        (rf"\bap_uint\s*<\s*{width}\s*>", f"ap_uint<{width}> type"),
        (rf"\bap_int\s*<\s*{width}\s*>", f"ap_int<{width}> type"),
    ]
    for pattern, label in strong_patterns:
        if re.search(pattern, text, flags=re.I):
            evidence.append(label)

    symbolic_patterns = [
        (rf"2\s*\^\s*{width}\b", f"2^{width} bound"),
        (rf"2\s*\*\*\s*{width}\b", f"2**{width} bound"),
        (rf"1\s*<<\s*{width}\b", f"1<<{width} bound"),
    ]
    for pattern, label in symbolic_patterns:
        if re.search(pattern, text):
            evidence.append(label)

    if re.search(rf"(?<!\d){pow2}(?!\d)", text):
        evidence.append(f"decimal 2^{width} bound ({pow2})")
    if re.search(rf"(?<!\d){umax}(?!\d)", text):
        evidence.append(f"unsigned {width}-bit max ({umax})")
    if str(smin) in text and re.search(rf"(?<!\d){smax}(?!\d)", text):
        evidence.append(f"signed {width}-bit range ({smin}..{smax})")

    # Literal '%' is safe inside an f-string regex.  This line is the direct fix
    # for the crash caused by: r"%\s*%d(?!\d)" % pow2
    if re.search(rf"%\s*{pow2}(?!\d)", text):
        evidence.append(f"modulo 2^{width}")
    if re.search(rf"&\s*{umax}(?!\d)", text):
        evidence.append(f"{width}-bit mask")

    out: List[str] = []
    seen = set()
    for item in evidence:
        if item not in seen:
            seen.add(item)
            out.append(item)
    return out


def _install_bit_audit_patch() -> None:
    test_p2s_journal._width_evidence = _fixed_width_evidence

    # Fail before any paid model call if a future edit breaks the checker again.
    checks = [
        ("var x: bv8", 8, "Dafny bv8 type"),
        ("x := x % 256;", 8, "modulo 2^8"),
        ("x := x & 255;", 8, "8-bit mask"),
        ("requires 0 <= x < 16", 4, "decimal 2^4 bound (16)"),
    ]
    for code, width, expected in checks:
        hits = _fixed_width_evidence(code, width)
        if expected not in hits:
            raise RuntimeError(
                f"P2S bit-audit self-test failed for width={width}: "
                f"expected {expected!r}, got {hits!r}"
            )


_install_bit_audit_patch()


if __name__ == "__main__":
    test_p2s_journal.main()
