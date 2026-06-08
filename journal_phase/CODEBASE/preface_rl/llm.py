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

def run_LLM(prompt: str, last_code: str = "", last_error: str = "") -> str:
    client = OpenAI(
        api_key=os.environ.get('DEEPSEEK_API_KEY'),
        base_url="https://api.deepseek.com"
    )
    full_prompt = ""
    if last_code or last_error:
        full_prompt = "### Previous Attempt Context"
        if last_code:
            full_prompt += "\n### Previous Dafny Code\n" + last_code.strip() +"\n\n"
        if last_error:
            full_prompt += "\n### Previous Error\n" + last_error.strip() + "\n\n"
        full_prompt += "\n Fix teh issue and return the corrected code based on the following instructions: "
    full_prompt +=prompt
    full_prompt += " You must return the full code in the following form:\n```dafny\nDafny Code\n```"

    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[
            {"role": "system", "content": "You are an expert Dafny programmer. You are given a description of a problem and you need to write a Dafny program to solve it."},
            {"role": "user", "content": full_prompt},
        ],
        temperature=0.2,   
        stream=False
    )

    generated_texts = response.choices[0].message.content
    prompt_count = response.usage.prompt_tokens
    print(generated_texts)

    save_dir = "/u/mjha1/Proof2Silicon/journal_phase/prompts/llm_new_4" #HERE_FOR_CHANGE
    save_prompt_response(full_prompt, generated_texts, save_dir)

    return generated_texts, prompt_count



