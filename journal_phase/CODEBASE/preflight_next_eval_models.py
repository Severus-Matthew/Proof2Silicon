#!/usr/bin/env python3
"""API-only preflight for the next large-model and P2S evaluation suites.

Safe to run on a Delta login node: this script does not load the SLM, any coder
weights, CUDA, or Dafny.  It verifies that the exact HF router model strings are
callable and that DeepSeek-V4 obeys strict non-thinking mode.  It also verifies
the P2S OpenAI coder with reasoning effort explicitly set to ``none``.
"""

import argparse
import os
import re
import sys
from openai import OpenAI

HF_MODELS = [
    "deepseek-ai/DeepSeek-V4-Flash:cheapest",
    "Qwen/Qwen2.5-Coder-32B-Instruct:cheapest",
    "mistralai/Mistral-Large-Instruct-2411:cheapest",
    "meta-llama/Llama-3.1-70B-Instruct:cheapest",
    "Qwen/Qwen3-Coder-30B-A3B-Instruct:cheapest",
    "deepseek-ai/DeepSeek-V3.1:cheapest",
]
OPENAI_MODEL = "gpt-5.4-nano"
DEEPSEEK_V4 = "deepseek-ai/DeepSeek-V4-Flash"


def hf_repo(model):
    repo, sep, suffix = model.rpartition(":")
    return repo if sep and "/" in repo else model


def usage_text(message):
    for field in ("reasoning_content", "reasoning", "thinking"):
        value = getattr(message, field, None)
        if value:
            return str(value).strip()
    return ""


def check_hf(client, model):
    kwargs = {
        "model": model,
        "messages": [
            {"role": "system", "content": "Return only OK."},
            {"role": "user", "content": "Return exactly OK."},
        ],
        "temperature": 0.0,
        "max_tokens": 64,
        "stream": False,
    }
    if hf_repo(model) == DEEPSEEK_V4:
        kwargs["extra_body"] = {"thinking_mode": "chat"}

    response = client.chat.completions.create(**kwargs)
    message = response.choices[0].message
    text = (message.content or "").strip()
    if not text:
        raise RuntimeError("empty response")

    if hf_repo(model) == DEEPSEEK_V4:
        reasoning = usage_text(message)
        if reasoning:
            raise RuntimeError(
                "strict non-think failed: provider returned reasoning_content"
            )
        if re.search(r"<think\b|</think>", text, flags=re.I):
            raise RuntimeError(
                "strict non-think failed: visible response contains <think>"
            )

    return text


def check_openai(client, model):
    response = client.responses.create(
        model=model,
        instructions="Return only OK.",
        input="Return exactly OK.",
        reasoning={"effort": "none"},
        max_output_tokens=128,
    )
    text = (getattr(response, "output_text", "") or "").strip()
    if not text:
        raise RuntimeError("empty response")
    return text


def main():
    p = argparse.ArgumentParser()
    p.add_argument(
        "--hf-models",
        nargs="*",
        default=HF_MODELS,
        help="Exact HF router model IDs to test.",
    )
    p.add_argument(
        "--skip-openai",
        action="store_true",
        help="Skip the gpt-5.4-nano no-reasoning P2S preflight.",
    )
    args = p.parse_args()

    failures = []
    hf_token = os.environ.get("HF_TOKEN")
    if not hf_token:
        failures.append("HF_TOKEN is not set")
    openai_key = os.environ.get("OPENAI_API_KEY")
    if not args.skip_openai and not openai_key:
        failures.append("OPENAI_API_KEY is not set")

    if failures:
        for failure in failures:
            print("ERROR:", failure)
        raise SystemExit(2)

    hf_client = OpenAI(
        api_key=hf_token,
        base_url=os.environ.get(
            "HF_BASE_URL", "https://router.huggingface.co/v1"
        ),
        timeout=180.0,
        max_retries=1,
    )

    for model in args.hf_models:
        try:
            text = check_hf(hf_client, model)
            protocol = " strict-nonthink" if hf_repo(model) == DEEPSEEK_V4 else ""
            print("HF %-72s OK%s  %r" % (model, protocol, text[:80]))
        except Exception as exc:
            print("HF %-72s FAILED  %s" % (model, exc))
            failures.append("%s: %s" % (model, exc))

    if not args.skip_openai:
        oa_client = OpenAI(
            api_key=openai_key,
            timeout=180.0,
            max_retries=1,
        )
        try:
            text = check_openai(oa_client, OPENAI_MODEL)
            print(
                "OpenAI %-68s OK reasoning=none  %r"
                % (OPENAI_MODEL, text[:80])
            )
        except Exception as exc:
            print("OpenAI %-68s FAILED  %s" % (OPENAI_MODEL, exc))
            failures.append("%s: %s" % (OPENAI_MODEL, exc))

    if failures:
        print("\nPREFLIGHT FAILED (%d):" % len(failures))
        for failure in failures:
            print(" -", failure)
        print(
            "\nDo not launch the array.  For an HF failure, inspect the model's "
            "live providers and pin a provider suffix only after confirming it "
            "supports the required protocol."
        )
        sys.exit(1)

    print("\nPREFLIGHT PASSED")


if __name__ == "__main__":
    main()
