import json
import os
import time

# import google.generativeai as genai
# from google.generativeai.types import HarmBlockThreshold, HarmCategory  # noqa: F401
# import requests
# import os

def save_prompt_response(prompt: str, response: str, save_dir: str) -> None:
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    os.makedirs(save_dir, exist_ok=True)

    with open(os.path.join(save_dir, f"llm_interaction_{timestamp}.json"), "w") as f:
        json.dump(
            {"timestamp": timestamp, "prompt": prompt, "response": response},
            f,
            indent=2,
        )


import os
from openai import OpenAI
os.environ['DEEPSEEK_API_KEY'] = "sk-d7844b60db514574982d2e06c7f66fca"

def run_LLM(responses: str) -> str:
    client = OpenAI(
        api_key=os.environ.get('DEEPSEEK_API_KEY'),
        base_url="https://api.deepseek.com"
    )

    prompt = (
        responses
        + " You must return the full code in the following form:\n```dafny\nDafny Code\n```"
    )

    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[
            {"role": "system", "content": "You are an expert Dafny programmer. You are given a description of a problem and you need to write a Dafny program to solve it."},
            {"role": "user", "content": prompt},
        ],
        temperature=0.75,
        stream=False
    )

    generated_texts = response.choices[0].message.content
    print(generated_texts)

    save_dir = "/u/mjha1/Proof2Silicon/journal_phase/prompts/llm_new"
    save_prompt_response(prompt, generated_texts, save_dir)

    return generated_texts



