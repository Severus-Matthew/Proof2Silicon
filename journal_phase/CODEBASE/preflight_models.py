#!/usr/bin/env python3
import os
import sys
from openai import OpenAI


def require(name):
    value = os.environ.get(name)
    if not value:
        raise RuntimeError("Missing required environment variable: {}".format(name))
    return value


def check_openai_model(model):
    client = OpenAI(api_key=require("OPENAI_API_KEY"), timeout=60.0, max_retries=1)
    available = {item.id for item in client.models.list().data}
    if model not in available:
        nearby = sorted(item for item in available if "gpt-5" in item or "codex" in item)
        raise RuntimeError(
            "OpenAI model {!r} is not available in this project. Available GPT/Codex "
            "models include: {}".format(model, nearby[:50])
        )
    print("OpenAI model available:", model)


def check_chat(provider, model, base_url, key_name):
    client = OpenAI(
        api_key=require(key_name),
        base_url=base_url,
        timeout=90.0,
        max_retries=1,
    )
    response = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": "Reply with exactly OK"}],
        temperature=0.0,
        max_tokens=4,
    )
    text = (response.choices[0].message.content or "").strip()
    if not text:
        raise RuntimeError("{} returned an empty preflight response".format(provider))
    print("{} reachable with model {}: {}".format(provider, model, text[:40]))


def main():
    mode = os.environ.get("DAFNY_GENERATOR_MODE", "deepseek")
    judge_provider = os.environ.get("DAFNY_JUDGE_PROVIDER", "openai")
    judge_model = os.environ.get("DAFNY_JUDGE_MODEL", "gpt-5.2")

    if judge_provider != "openai":
        raise RuntimeError("Journal configuration currently requires an OpenAI judge")
    check_openai_model(judge_model)

    providers = [mode] if mode != "mixed" else [
        item.strip() for item in os.environ.get(
            "DAFNY_MIXED_GENERATORS", "deepseek,openai,qwen_hf"
        ).split(",") if item.strip()
    ]

    if "openai" in providers:
        check_openai_model(os.environ.get("OPENAI_GENERATOR_MODEL", "gpt-5.2"))
    if "deepseek" in providers:
        check_chat(
            "DeepSeek",
            os.environ.get("DEEPSEEK_GENERATOR_MODEL", "deepseek-chat"),
            os.environ.get("DEEPSEEK_BASE_URL", "https://api.deepseek.com"),
            "DEEPSEEK_API_KEY",
        )
    if "qwen_hf" in providers:
        check_chat(
            "Hugging Face router",
            os.environ.get(
                "HF_GENERATOR_MODEL",
                "Qwen/Qwen3-Coder-30B-A3B-Instruct:cheapest",
            ),
            os.environ.get("HF_BASE_URL", "https://router.huggingface.co/v1"),
            "HF_TOKEN",
        )

    print("Preflight passed for generator mode:", mode)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print("PREFLIGHT FAILED:", exc, file=sys.stderr)
        sys.exit(2)
