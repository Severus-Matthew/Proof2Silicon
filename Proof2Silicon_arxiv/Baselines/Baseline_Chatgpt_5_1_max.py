# import os
# import re
# import time
# import argparse
# import subprocess
# from concurrent.futures import ThreadPoolExecutor, as_completed
# from openai import OpenAI

# # ----------------------------
# # PROMPT BUILDERS (unchanged)
# # ----------------------------
# def ShortPrompt(Task):
#     Prompt = "You are an Expert in Dafny programming, follow the below instrution to write an error free Dafny code:\n"
#     Prompt += Task + "\n"
#     Prompt += "You must return the method in the following Form:\n```dafny\n//Dafny Code\n```"
#     return Prompt

# def DetailedAndShortPrompt(Task, Detailed):
#     Prompt = "You are an Expert in Dafny programming, follow the below instrution to write an error free Dafny code:\n"
#     Prompt += Task + "\n"
#     Prompt += "This query can be explained in a more detailed way as:\n" + Detailed + "\n"
#     Prompt += "You must return the method in the following Form:\n```dafny\n//Dafny Code\n```"
#     return Prompt

# def ErrorSpecifiedPrompt(Task):
#     Prompt = "You are an Expert in Dafny programming, follow the below instrution to write an error free Dafny code:\n"
#     Prompt += Task + "\n"
#     Prompt += "Make sure that the generated code is free from Out-of-bound error, logic error, syntax error, undefined variable or input type error"
#     Prompt += "\nYou must return the method in the following Form:\n```dafny\n//Dafny Code\n```"
#     return Prompt

# def FewShotPrompt(Task, Detailed):
#     Prompt = "Dafny is a formal verification language, here are some examples of Dafny code:\n"
#     Prompt += "Example 1:\n"
#     Prompt += "Task: The code defines a Dafny method called `TriangularPrismVolume` ...\n"
#     Prompt += "Code:\n"
#     Prompt += "//Dafny Code\n"
#     Prompt += "method TriangularPrismVolume(base: int, height: int, length: int) returns (volume: int)\n"
#     Prompt += "requires base > 0 && height > 0 && length > 0\n"
#     Prompt += "ensures volume == base * height * length / 2\n"
#     Prompt += "{\n"
#     Prompt += "  volume := (base * height * length) / 2;\n"
#     Prompt += "  assert volume == base * height * length / 2;\n"
#     Prompt += "}\n"
#     Prompt += "Example 2:\n"
#     Prompt += "Task: The provided Dafny code defines a method, `AllCharactersSame` ...\n"
#     Prompt += "Code:\n"
#     Prompt += "// Dafny Code\n"
#     Prompt += "method AllCharactersSame(s: string) returns (result: bool)\n"
#     Prompt += "ensures result == (forall i, j :: 0 <= i < |s| && 0 <= j < |s| ==> s[i] == s[j])\n"
#     Prompt += "{\n"
#     Prompt += "  if |s| == 0 {\n"
#     Prompt += "    result := true;\n"
#     Prompt += "    return;\n"
#     Prompt += "  }\n"
#     Prompt += "  var firstChar := s[0];\n"
#     Prompt += "  var i: int := 1;\n"
#     Prompt += "  result := true;\n"
#     Prompt += "  while i < |s|\n"
#     Prompt += "    invariant 0 <= i <= |s|\n"
#     Prompt += "    invariant result == (forall k: int :: 0 <= k < i ==> s[k] == firstChar)\n"
#     Prompt += "  {\n"
#     Prompt += "    if s[i] != firstChar {\n"
#     Prompt += "      result := false;\n"
#     Prompt += "      return;\n"
#     Prompt += "    }\n"
#     Prompt += "    i := i + 1;\n"
#     Prompt += "  }\n"
#     Prompt += "}\n"
#     Prompt += "You are an Expert in Dafny programming, follow the below instrution to write an error free Dafny code, you can use the above examples to learn the style of writing Dafny code:\n"
#     Prompt += Task + "\n"
#     Prompt += "This query can be explained in a more detailed way as:\n" + Detailed + "\n"
#     Prompt += "You must return the method in the following Form:\n```dafny\n//Dafny Code\n```"
#     return Prompt


# def ErrorPrompt(code, error):
#     Prompt = "You are an Expert in Dafny programming, The following code gave an error followed by the code. Please resolve the error and regenrate the correct code:\n"
#     Prompt += code + "\n"
#     Prompt += " The error is: \n" + error
#     Prompt += "\nMake sure that the generated code is free from Out-of-bound error, logic error, syntax error, undefined variable or input type error"
#     Prompt += "\nYou must return the method in the following Form:\n```dafny\n//Dafny Code\n```"
#     return Prompt

# def generate_prompts(one_line_desc, detailed_desc):
#     return [
#         ShortPrompt(one_line_desc),
#         DetailedAndShortPrompt(one_line_desc, detailed_desc),
#         ErrorSpecifiedPrompt(one_line_desc),
#         FewShotPrompt(one_line_desc, detailed_desc)
#     ]

# # ----------------------------
# # DAFNY RUNNER (unchanged)
# # ----------------------------
# def run_Dafny(dafny_code, tmp_path, err_path, timeout_sec=60):
#     with open(tmp_path, "w", encoding="utf-8") as f:
#         f.write(dafny_code)

#     dafny_exec = "/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny"
#     cmd = [dafny_exec, tmp_path]

#     try:
#         result = subprocess.run(
#             cmd,
#             stdout=subprocess.PIPE,
#             stderr=subprocess.STDOUT,
#             timeout=timeout_sec,
#             text=True
#         )
#         output = result.stdout

#         with open(err_path, "w", encoding="utf-8") as f:
#             f.write(output)

#         return 1 if ("verified, 0 errors" in output and "Compiled assembly into" in output) else 0

#     except subprocess.TimeoutExpired as e:
#         with open(err_path, "w", encoding="utf-8") as f:
#             f.write(f"TIMEOUT after {timeout_sec} seconds\n")
#             if e.stdout:
#                 f.write(e.stdout)
#         return 0

# # ----------------------------
# # EXTRACTION (unchanged)
# # ----------------------------
# def extract_dafny_code(text):
#     pattern_snippet = r"```dafny(.*?)```"
#     snippets = re.findall(pattern_snippet, text, re.DOTALL)
#     if not snippets:
#         return 0
#     return snippets[-1].strip()

# # ----------------------------
# # LLM LOOP (minor change: client passed in)
# # ----------------------------
# def RUN_LLM(client, subfolder, one_line_desc, detailed_desc, temperature, max_iterations=5):
#     prompts = generate_prompts(one_line_desc, detailed_desc)

#     for i, prompt in enumerate(prompts, start=1):
#         for attempt in range(max_iterations):
#             print(f"[{subfolder}] Attempt {attempt + 1} with Prompt {i}...")

#             promptfile = os.path.join(subfolder, f"Prompt_chatgpt5_1codexMax_0.25_{i}_{attempt}.dfy")
#             output_dafny_path = os.path.join(subfolder, f"generated_chatgpt5_1codexMax_0.25_{i}_{attempt}.dfy")
#             Error_path = os.path.join(subfolder, f"error_chatgpt5_1codexMax_0.25_{i}_{attempt}.txt")

#             if os.path.exists(promptfile) and os.path.exists(output_dafny_path):
#                 print(f"[{subfolder}] Files for Prompt {i}, Attempt {attempt + 1} exist. Skipping...")
#                 continue

#             os.makedirs(subfolder, exist_ok=True)

#             with open(promptfile, "w", encoding="utf-8") as f:
#                 f.write(prompt)

#             model = "gpt-5.1-codex-max"
#             response = client.responses.create(
#                 model=model,
#                 instructions="You are a helpful assistant.",
#                 input=prompt,
#                 # temperature=temperature,
#             )

#             generated_content = response.output_text
#             dafny_code = extract_dafny_code(str(generated_content))
#             if dafny_code == 0:
#                 break

#             success = run_Dafny(dafny_code, output_dafny_path, Error_path)

#             if success == 1:
#                 print(f"[{subfolder}] Success")
#                 break
#             else:
#                 with open(Error_path, "r", encoding="utf-8") as ef:
#                     err = ef.read()
#                 with open(output_dafny_path, "r", encoding="utf-8") as of:
#                     prev_code = of.read()
#                 prompt = ErrorPrompt(prev_code, err)

#         time.sleep(30)

# # ----------------------------
# # NEW: JOB COLLECTION + PARALLEL EXECUTION
# # ----------------------------
# def collect_jobs(base_folder):
#     """
#     Returns a list of (subdir, one_line_desc, detailed_desc) jobs under base_folder.
#     """
#     jobs = []
#     for subdir, _, _files in os.walk(base_folder):
#         if subdir == base_folder:
#             continue
#         one_line_file = os.path.join(subdir, "one_line_description.txt")
#         detailed_file = os.path.join(subdir, "detailed_description.txt")
#         if os.path.exists(one_line_file) and os.path.exists(detailed_file):
#             with open(one_line_file, "r", encoding="utf-8") as f:
#                 one_line_desc = f.read().strip()
#             with open(detailed_file, "r", encoding="utf-8") as f:
#                 detailed_desc = f.read().strip()
#             jobs.append((subdir, one_line_desc, detailed_desc))
#     return jobs

# def run_one_job(job, temperature):
#     """
#     Each worker makes its own client instance (safe for parallel threads).
#     """
#     api_key = os.environ.get("OPENAI_API_KEY")
#     if not api_key:
#         raise RuntimeError("OPENAI_API_KEY env var is not set.")
#     client = OpenAI(api_key=api_key)

#     subdir, one_line_desc, detailed_desc = job
#     RUN_LLM(client, subdir, one_line_desc, detailed_desc, temperature)

# def process_folders_parallel(base_folders, temperature, workers):
#     """
#     Flattens all subfolder jobs across multiple base folders,
#     then runs them in parallel with a worker pool.
#     """
#     all_jobs = []
#     for bf in base_folders:
#         all_jobs.extend(collect_jobs(bf))

#     print(f"Total jobs found: {len(all_jobs)} across {len(base_folders)} base folders")
#     if not all_jobs:
#         return

#     with ThreadPoolExecutor(max_workers=workers) as ex:
#         futures = [ex.submit(run_one_job, job, temperature) for job in all_jobs]
#         for fut in as_completed(futures):
#             # propagate exceptions clearly
#             fut.result()

# # ----------------------------
# # MAIN
# # ----------------------------
# if __name__ == "__main__":
#     parser = argparse.ArgumentParser(description="Run Dafny code generation in parallel across folders")
#     parser.add_argument("--temperature", type=float, default=0.25, help="Temperature for LLM generation")
#     parser.add_argument("--workers", type=int, default=8, help="Number of parallel workers (folders/subfolders at once)")
#     parser.add_argument(
#         "--base_folders",
#         nargs="+",
#         default=["/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny_gpt5_1codexMax"],
#         help="One or more base folders to process in parallel",
#     )
#     args = parser.parse_args()

#     process_folders_parallel(args.base_folders, args.temperature, args.workers)


import os
import re
import json
import time
import argparse
import subprocess
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor, as_completed

from openai import OpenAI

try:
    import torch
    from transformers import AutoModelForCausalLM, AutoTokenizer
except Exception:
    torch = None
    AutoModelForCausalLM = None
    AutoTokenizer = None


# ============================================================
# CONFIG / CONSTANTS
# ============================================================
DEFAULT_DAFNY_EXEC = "/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny"
DEFAULT_LLM_MODEL = "gpt-5.1-codex-max"
DEFAULT_SLM_MODEL = "Qwen/Qwen2.5-1.5B-Instruct"
PROMPT_TYPES = ["short", "shortanddetailed", "fewshot"]


# ============================================================
# PROMPT BUILDERS
# ============================================================
def _common_dafny_requirements() -> str:
    return (
        "Write Dafny code that is verifier-friendly and robust.\\n"
        "Requirements:\\n"
        "- Return ONLY one complete Dafny program inside a ```dafny code block.\\n"
        "- Avoid syntax errors, undefined identifiers, type mismatches, and out-of-bounds accesses.\\n"
        "- Use precise requires/ensures/invariants/asserts whenever needed for verification.\\n"
        "- Make the code logically correct, not just syntactically valid.\\n"
        "- Prefer simple verifier-friendly structure over cleverness.\\n"
        "- Do not include explanations outside the code block.\\n"
    )


def ShortPrompt(task: str) -> str:
    return (
        "You are an expert Dafny programmer. Generate an error-free, verifier-friendly Dafny solution.\\n\\n"
        f"Task:\\n{task}\\n\\n"
        f"{_common_dafny_requirements()}\\n"
        "Output format:\\n```dafny\\n// your Dafny code here\\n```"
    )

def ShortPrompt_slm(task: str) -> str:
    return (
        f"The task is to make the other model write a Dafny program that solves the following problem: Task:\\n{task}\\n\\n"
    )


def DetailedAndShortPrompt(task: str, detailed: str) -> str:
    return (
        "You are an expert Dafny programmer. Generate an error-free, verifier-friendly Dafny solution.\\n\\n"
        f"Task:\\n{task}\\n\\n"
        f"Detailed problem explanation:\\n{detailed}\\n\\n"
        f"{_common_dafny_requirements()}\\n"
        "Output format:\\n```dafny\\n// your Dafny code here\\n```"
    )
def DetailedAndShortPrompt_slm(task: str, detailed: str) -> str:
    return (
        f"The task is to make the other model write a Dafny program that solves the following problem: Task:\\n{task}\\n\\n"
        f"Detailed problem explanation:\\n{detailed}\\n\\n"
    )


def FewShotPrompt(task: str, detailed: str) -> str:
    return (
        "Dafny is a formal verification language. Follow the style of the examples below.\\n\\n"
        "Example 1\\n"
        "Task: Compute triangular prism volume.\\n"
        "```dafny\\n"
        "method TriangularPrismVolume(base: int, height: int, length: int) returns (volume: int)\\n"
        "  requires base > 0 && height > 0 && length > 0\\n"
        "  ensures volume == base * height * length / 2\\n"
        "{\\n"
        "  volume := (base * height * length) / 2;\\n"
        "  assert volume == base * height * length / 2;\\n"
        "}\\n"
        "```\\n\\n"
        "Example 2\\n"
        "Task: Check if all characters of a string are the same.\\n"
        "```dafny\\n"
        "method AllCharactersSame(s: string) returns (result: bool)\\n"
        "  ensures result == (forall i, j :: 0 <= i < |s| && 0 <= j < |s| ==> s[i] == s[j])\\n"
        "{\\n"
        "  if |s| == 0 {\\n"
        "    result := true;\\n"
        "    return;\\n"
        "  }\\n"
        "  var firstChar := s[0];\\n"
        "  var i := 1;\\n"
        "  result := true;\\n"
        "  while i < |s|\\n"
        "    invariant 0 <= i <= |s|\\n"
        "    invariant result == (forall k :: 0 <= k < i ==> s[k] == firstChar)\\n"
        "  {\\n"
        "    if s[i] != firstChar {\\n"
        "      result := false;\\n"
        "      return;\\n"
        "    }\\n"
        "    i := i + 1;\\n"
        "  }\\n"
        "}\\n"
        "```\\n\\n"
        "Now solve the next task in the same style.\\n\\n"
        f"Task:\\n{task}\\n\\n"
        f"Detailed problem explanation:\\n{detailed}\\n\\n"
        f"{_common_dafny_requirements()}\\n"
        "Output format:\\n```dafny\\n// your Dafny code here\\n```"
    )


def FewShotPrompt_slm(task: str, detailed: str) -> str:
    return (
        "Dafny is a formal verification language. Follow the style of the examples below to write instructions that can help the other model generate verifier-friendly Dafny code.\\n\\n"
        "Example 1\\n"
        "Task: Compute triangular prism volume.\\n"
        "```dafny\\n"
        "method TriangularPrismVolume(base: int, height: int, length: int) returns (volume: int)\\n"
        "  requires base > 0 && height > 0 && length > 0\\n"
        "  ensures volume == base * height * length / 2\\n"
        "{\\n"
        "  volume := (base * height * length) / 2;\\n"
        "  assert volume == base * height * length / 2;\\n"
        "}\\n"
        "```\\n\\n"
        "Example 2\\n"
        "Task: Check if all characters of a string are the same.\\n"
        "```dafny\\n"
        "method AllCharactersSame(s: string) returns (result: bool)\\n"
        "  ensures result == (forall i, j :: 0 <= i < |s| && 0 <= j < |s| ==> s[i] == s[j])\\n"
        "{\\n"
        "  if |s| == 0 {\\n"
        "    result := true;\\n"
        "    return;\\n"
        "  }\\n"
        "  var firstChar := s[0];\\n"
        "  var i := 1;\\n"
        "  result := true;\\n"
        "  while i < |s|\\n"
        "    invariant 0 <= i <= |s|\\n"
        "    invariant result == (forall k :: 0 <= k < i ==> s[k] == firstChar)\\n"
        "  {\\n"
        "    if s[i] != firstChar {\\n"
        "      result := false;\\n"
        "      return;\\n"
        "    }\\n"
        "    i := i + 1;\\n"
        "  }\\n"
        "}\\n"
        "```\\n\\n"
    )

def build_base_prompt(prompt_type: str, one_line_desc: str, detailed_desc: str) -> str:
    prompt_type = prompt_type.lower()
    if prompt_type == "short":
        return ShortPrompt(one_line_desc)
    if prompt_type == "shortanddetailed":
        return DetailedAndShortPrompt(one_line_desc, detailed_desc)
    if prompt_type == "fewshot":
        return FewShotPrompt(one_line_desc, detailed_desc)
    raise ValueError(f"Unsupported prompt_type: {prompt_type}")

def build_base_prompt_slm(prompt_type: str, one_line_desc: str, detailed_desc: str) -> str:
    prompt_type = prompt_type.lower()
    if prompt_type == "short":
        return ShortPrompt_slm(one_line_desc)
    if prompt_type == "shortanddetailed":
        return DetailedAndShortPrompt_slm(one_line_desc, detailed_desc)
    if prompt_type == "fewshot":
        return FewShotPrompt_slm(one_line_desc, detailed_desc)
    raise ValueError(f"Unsupported prompt_type: {prompt_type}")


def ErrorPrompt(code: str, error: str) -> str:
    return (
        "You are an expert Dafny programmer. The previous Dafny code failed verification or compilation.\\n"
        "Fix the code using the verifier/compiler feedback below.\\n\\n"
        f"Previous code:\\n```dafny\\n{code}\\n```\\n\\n"
        f"Verifier / compiler feedback:\\n{error}\\n\\n"
        "Repair requirements:\\n"
        "- Keep the solution aligned with the original task.\\n"
        "- Fix syntax, type, logic, bounds, specification, invariant, and postcondition issues.\\n"
        "- Add or strengthen requires/ensures/invariants/asserts only as needed.\\n"
        "- Return ONLY the corrected Dafny program inside a ```dafny code block.\\n"
    )



def build_slm_initial_prompt(prompt_type: str, one_line_desc: str, detailed_desc: str) -> str:
    base_prompt = build_base_prompt_slm(prompt_type, one_line_desc, detailed_desc)
    return (
        "You are an instruction generator for a Dafny code-writing LLM.\\n"
        "Your job is to write a concise but strong instruction that will help another model produce verifier-friendly Dafny code.\\n\\n"
        "The instruction you produce should explicitly guide the LLM to avoid:\\n"
        "- syntax mistakes\\n"
        "- type errors\\n"
        "- undefined identifiers\\n"
        "- missing preconditions / postconditions\\n"
        "- weak or missing loop invariants\\n"
        "- out-of-bounds accesses\\n"
        "- verifier failures due to insufficient assertions\\n\\n"
        f"\\n{base_prompt}\\n\\n"
        "Return only the instruction text, not Dafny code.\\n\\n"
    )



def build_slm_error_prompt(
    prompt_type: str,
    one_line_desc: str,
    detailed_desc: str,
    previous_instruction: str,
    previous_code: str,
    verifier_error: str,
) -> str:
    base_prompt = build_base_prompt_slm(prompt_type, one_line_desc, detailed_desc)
    return (
        "You are an instruction generator for a Dafny code-writing LLM.\\n"
        "The previous instruction led to Dafny code that failed verification/compilation.\\n"
        "Generate a better next instruction so the downstream LLM can fix the failure.\\n\\n"
        f"Original Input prompt:\\n{base_prompt}\\n\\n"
        f"Previous instruction:\\n{previous_instruction}\\n\\n"
        f"Previous generated code:\\n```dafny\\n{previous_code}\\n```\\n\\n"
        f"Verifier / compiler feedback:\\n{verifier_error}\\n\\n"
        "Write a revised instruction that explicitly addresses the likely cause of failure.\\n"
        "Focus on verifier guidance such as stronger invariants, assertions, bounds, specs, datatype consistency, or simpler proof structure.\\n"
        "Return only the instruction text, not Dafny code."
    )



def build_llm_prompt_from_instruction( slm_instruction: str) -> str:
    return (
        f"{slm_instruction}\\n"
        "output format:\\n```dafny\\n// your Dafny code here\\n```"
    )


# ============================================================
# DAFNY EXECUTION / EXTRACTION
# ============================================================
def run_Dafny(dafny_code: str, tmp_path: str, err_path: str, timeout_sec: int = 60, dafny_exec: str = DEFAULT_DAFNY_EXEC) -> int:
    with open(tmp_path, "w", encoding="utf-8") as f:
        f.write(dafny_code)

    cmd = ["dafny", tmp_path]

    try:
        result = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout_sec,
            text=True,
        )
        output = result.stdout

        with open(err_path, "w", encoding="utf-8") as f:
            f.write(output)

        return 1 if ("verified, 0 errors" in output and "Compiled assembly into" in output) else 0

    except subprocess.TimeoutExpired as e:
        stdout_text = e.stdout.decode("utf-8", errors="replace") if isinstance(e.stdout, bytes) else (e.stdout or "")
        stderr_text = e.stderr.decode("utf-8", errors="replace") if isinstance(e.stderr, bytes) else (e.stderr or "")

        with open(log_file, "w", encoding="utf-8") as f:
            f.write(f"TIMEOUT after 180 seconds\n")
            if stdout_text:
                f.write("\n==== PARTIAL STDOUT ====\n")
                f.write(stdout_text)
            if stderr_text:
                f.write("\n==== PARTIAL STDERR ====\n")
                f.write(stderr_text)

        return False



def extract_dafny_code(text: str):
    pattern_snippet = r"```dafny(.*?)```"
    snippets = re.findall(pattern_snippet, text, re.DOTALL | re.IGNORECASE)
    if not snippets:
        return 0
    return snippets[-1].strip()


# ============================================================
# CLIENT HELPERS
# ============================================================
def get_openai_client() -> OpenAI:
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY env var is not set.")
    return OpenAI(api_key=api_key)



def call_openai_text(client: OpenAI, model: str, prompt: str, temperature: float = 0.25) -> str:
    response = client.responses.create(
        model=model,
        instructions="You are an expert in writing Dafny code.",
        input=prompt,
    )
    return response.output_text


class LocalSLMGenerator:
    def __init__(self, model_name: str, max_new_tokens: int = 256):
        if AutoTokenizer is None or AutoModelForCausalLM is None or torch is None:
            raise RuntimeError(
                "transformers/torch are not available. Install them to use the local SLM instructor pipeline."
            )

        self.model_name = model_name
        self.max_new_tokens = max_new_tokens
        self.tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
        self.model = AutoModelForCausalLM.from_pretrained(
            model_name,
            torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
            device_map="auto",
            trust_remote_code=True,
        )
        self.model.eval()

    def generate_instruction(self, prompt: str, temperature: float = 0.25) -> str:
        messages = [
            {"role": "system", "content": "You are a precise instruction generator for Dafny code synthesis."},
            {"role": "user", "content": prompt},
        ]
        text = self.tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
        )
        inputs = self.tokenizer(text, return_tensors="pt").to(self.model.device)
        with torch.no_grad():
            outputs = self.model.generate(
                **inputs,
                do_sample=True,
                temperature=temperature,
                top_p=0.9,
                max_new_tokens=self.max_new_tokens,
                pad_token_id=self.tokenizer.eos_token_id,
            )
        new_tokens = outputs[0][inputs["input_ids"].shape[1]:]
        return self.tokenizer.decode(new_tokens, skip_special_tokens=True).strip()


# ============================================================
# FILE / RESULT HELPERS
# ============================================================
@dataclass
class RunConfig:
    llm_model: str
    slm_model: str
    temperature: float
    max_iterations: int
    dafny_timeout: int
    dafny_exec: str
    output_root_name: str



def safe_write(path: str, text: str):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)



def safe_write_json(path: str, obj: Dict):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, indent=2, ensure_ascii=False)



def get_experiment_root(subfolder: str, output_root_name: str, experiment_name: str, prompt_type: str) -> str:
    return os.path.join(subfolder, output_root_name, experiment_name, prompt_type)


# ============================================================
# EXPERIMENT 1: PURE LLM BASELINE
# ============================================================
def already_done(experiment_root, max_iterations):
    if not os.path.exists(experiment_root):
        return False

    attempts_found = 0

    for root, _, files in os.walk(experiment_root):
        if "metadata.json" in files:
            meta_path = os.path.join(root, "metadata.json")

            # Count attempts
            attempts_found += 1

            try:
                with open(meta_path, "r") as f:
                    meta = json.load(f)

                # ✅ Case 1: success found → skip
                if str(meta.get("success", 0)) == "1":
                    return True

            except Exception:
                pass

    # ✅ Case 2: all attempts already done → skip
    if attempts_found >= max_iterations:
        return True

    return False
def run_llm_only_experiment(
    client: OpenAI,
    subfolder: str,
    one_line_desc: str,
    detailed_desc: str,
    prompt_type: str,
    cfg: RunConfig,
):
    experiment_root = get_experiment_root(subfolder, cfg.output_root_name, "llm_only", prompt_type)
    if already_done(experiment_root, 7):
        print(f"[{subfolder}][llm_only][{prompt_type}] already solved → skipping whole task")
        return
    base_prompt = build_base_prompt(prompt_type, one_line_desc, detailed_desc)
    current_prompt = base_prompt

    for attempt in range(cfg.max_iterations):
        attempt_dir = os.path.join(experiment_root, f"attempt_{attempt}")
        os.makedirs(attempt_dir, exist_ok=True)

        prompt_path = os.path.join(attempt_dir, "prompt_to_llm.txt")
        raw_response_path = os.path.join(attempt_dir, "raw_llm_response.txt")
        dafny_path = os.path.join(attempt_dir, "generated.dfy")
        error_path = os.path.join(attempt_dir, "dafny_output.txt")
        meta_path = os.path.join(attempt_dir, "metadata.json")

        if os.path.exists(meta_path):
            print(f"[{subfolder}][llm_only][{prompt_type}] attempt {attempt} exists, skipping")
            continue

        print(f"[{subfolder}][llm_only][{prompt_type}] attempt {attempt + 1}/{cfg.max_iterations}")
        safe_write(prompt_path, current_prompt)

        raw_response = call_openai_text(client, cfg.llm_model, current_prompt, temperature=cfg.temperature)
        safe_write(raw_response_path, raw_response)

        dafny_code = extract_dafny_code(raw_response)
        if dafny_code == 0:
            safe_write_json(meta_path, {
                "experiment": "llm_only",
                "prompt_type": prompt_type,
                "attempt": attempt,
                "llm_model": cfg.llm_model,
                "status": "no_dafny_block",
            })
            break

        success = run_Dafny(
            dafny_code,
            dafny_path,
            error_path,
            timeout_sec=cfg.dafny_timeout,
            dafny_exec=cfg.dafny_exec,
        )

        verifier_output = ""
        if os.path.exists(error_path):
            with open(error_path, "r", encoding="utf-8") as f:
                verifier_output = f.read()

        safe_write_json(meta_path, {
            "experiment": "llm_only",
            "prompt_type": prompt_type,
            "attempt": attempt,
            "llm_model": cfg.llm_model,
            "status": "success" if success == 1 else "failed",
            "success": int(success),
        })

        if success == 1:
            print(f"[{subfolder}][llm_only][{prompt_type}] success on attempt {attempt + 1}")
            break

        current_prompt = ErrorPrompt(dafny_code, verifier_output)
        time.sleep(1)


# ============================================================
# EXPERIMENT 2: UNTRAINED SLM INSTRUCTOR + LLM
# ============================================================
def run_slm_instructor_experiment(
    client: OpenAI,
    slm_generator: LocalSLMGenerator,
    subfolder: str,
    one_line_desc: str,
    detailed_desc: str,
    prompt_type: str,
    cfg: RunConfig,
):
    experiment_root = get_experiment_root(subfolder, cfg.output_root_name, "slm_instructor_untrained", prompt_type)
    base_prompt = build_base_prompt_slm(prompt_type, one_line_desc, detailed_desc)
    slm_prompt = build_slm_initial_prompt(prompt_type, one_line_desc, detailed_desc)
    previous_instruction = None
    previous_code = None

    for attempt in range(cfg.max_iterations):
        attempt_dir = os.path.join(experiment_root, f"attempt_{attempt}")
        os.makedirs(attempt_dir, exist_ok=True)

        slm_prompt_path = os.path.join(attempt_dir, "prompt_to_slm.txt")
        slm_instruction_path = os.path.join(attempt_dir, "slm_instruction.txt")
        llm_prompt_path = os.path.join(attempt_dir, "prompt_to_llm.txt")
        raw_llm_response_path = os.path.join(attempt_dir, "raw_llm_response.txt")
        dafny_path = os.path.join(attempt_dir, "generated.dfy")
        error_path = os.path.join(attempt_dir, "dafny_output.txt")
        meta_path = os.path.join(attempt_dir, "metadata.json")

        if os.path.exists(meta_path):
            print(f"[{subfolder}][slm_instructor][{prompt_type}] attempt {attempt} exists, skipping")
            continue

        print(f"[{subfolder}][slm_instructor][{prompt_type}] attempt {attempt + 1}/{cfg.max_iterations}")
        safe_write(slm_prompt_path, slm_prompt)

        slm_instruction = slm_generator.generate_instruction(slm_prompt, temperature=cfg.temperature)
        safe_write(slm_instruction_path, slm_instruction)

        llm_prompt = build_llm_prompt_from_instruction(base_prompt, slm_instruction)
        safe_write(llm_prompt_path, llm_prompt)

        raw_response = call_openai_text(client, cfg.llm_model, llm_prompt, temperature=cfg.temperature)
        safe_write(raw_llm_response_path, raw_response)

        dafny_code = extract_dafny_code(raw_response)
        if dafny_code == 0:
            safe_write_json(meta_path, {
                "experiment": "slm_instructor_untrained",
                "prompt_type": prompt_type,
                "attempt": attempt,
                "llm_model": cfg.llm_model,
                "slm_model": cfg.slm_model,
                "status": "no_dafny_block",
            })
            break

        success = run_Dafny(
            dafny_code,
            dafny_path,
            error_path,
            timeout_sec=cfg.dafny_timeout,
            dafny_exec=cfg.dafny_exec,
        )

        verifier_output = ""
        if os.path.exists(error_path):
            with open(error_path, "r", encoding="utf-8") as f:
                verifier_output = f.read()

        safe_write_json(meta_path, {
            "experiment": "slm_instructor_untrained",
            "prompt_type": prompt_type,
            "attempt": attempt,
            "llm_model": cfg.llm_model,
            "slm_model": cfg.slm_model,
            "status": "success" if success == 1 else "failed",
            "success": int(success),
        })

        if success == 1:
            print(f"[{subfolder}][slm_instructor][{prompt_type}] success on attempt {attempt + 1}")
            break

        previous_instruction = slm_instruction
        previous_code = dafny_code
        slm_prompt = build_slm_error_prompt(
            prompt_type=prompt_type,
            one_line_desc=one_line_desc,
            detailed_desc=detailed_desc,
            previous_instruction=previous_instruction,
            previous_code=previous_code,
            verifier_error=verifier_output,
        )
        time.sleep(1)


# ============================================================
# JOB COLLECTION / DRIVER
# ============================================================
def collect_jobs(base_folder: str) -> List[Tuple[str, str, str]]:
    jobs = []
    for subdir, _, _files in os.walk(base_folder):
        if subdir == base_folder:
            continue
        one_line_file = os.path.join(subdir, "one_line_description.txt")
        detailed_file = os.path.join(subdir, "detailed_description.txt")
        if os.path.exists(one_line_file) and os.path.exists(detailed_file):
            with open(one_line_file, "r", encoding="utf-8") as f:
                one_line_desc = f.read().strip()
            with open(detailed_file, "r", encoding="utf-8") as f:
                detailed_desc = f.read().strip()
            jobs.append((subdir, one_line_desc, detailed_desc))
    return jobs



def run_one_job(job, cfg: RunConfig, experiment_mode: str, prompt_types: List[str]):
    client = get_openai_client()
    slm_generator = None
    if experiment_mode in {"slm_instructor", "both"}:
        slm_generator = LocalSLMGenerator(cfg.slm_model)

    subdir, one_line_desc, detailed_desc = job

    for prompt_type in prompt_types:
        if experiment_mode in {"llm_only", "both"}:
            run_llm_only_experiment(
                client=client,
                subfolder=subdir,
                one_line_desc=one_line_desc,
                detailed_desc=detailed_desc,
                prompt_type=prompt_type,
                cfg=cfg,
            )

        if experiment_mode in {"slm_instructor", "both"}:
            run_slm_instructor_experiment(
                client=client,
                slm_generator=slm_generator,
                subfolder=subdir,
                one_line_desc=one_line_desc,
                detailed_desc=detailed_desc,
                prompt_type=prompt_type,
                cfg=cfg,
            )



def process_folders_parallel(base_folders: List[str], cfg: RunConfig, experiment_mode: str, prompt_types: List[str], workers: int):
    all_jobs = []
    for bf in base_folders:
        all_jobs.extend(collect_jobs(bf))

    print(f"Total jobs found: {len(all_jobs)} across {len(base_folders)} base folders")
    if not all_jobs:
        return

    with ThreadPoolExecutor(max_workers=workers) as ex:
        futures = [
            ex.submit(run_one_job, job, cfg, experiment_mode, prompt_types)
            for job in all_jobs
        ]
        for fut in as_completed(futures):
            fut.result()


# ============================================================
# MAIN
# ============================================================
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run Dafny baselines: pure LLM and/or untrained SLM instructor + LLM")
    parser.add_argument("--temperature", type=float, default=0.25, help="Sampling temperature")
    parser.add_argument("--workers", type=int, default=4, help="Parallel worker count")
    parser.add_argument("--max_iterations", type=int, default=5, help="Max repair iterations per prompt type")
    parser.add_argument("--dafny_timeout", type=int, default=60, help="Timeout for Dafny execution")
    parser.add_argument("--dafny_exec", type=str, default=DEFAULT_DAFNY_EXEC, help="Path to Dafny executable")
    parser.add_argument("--llm_model", type=str, default=DEFAULT_LLM_MODEL, help="LLM model name")
    parser.add_argument("--slm_model", type=str, default=DEFAULT_SLM_MODEL, help="Local SLM model name/path")
    parser.add_argument(
        "--experiment_mode",
        type=str,
        default="both",
        choices=["llm_only", "slm_instructor", "both"],
        help="Which baseline setup to run",
    )
    parser.add_argument(
        "--prompt_types",
        nargs="+",
        default=PROMPT_TYPES,
        choices=PROMPT_TYPES,
        help="Prompt families to run",
    )
    parser.add_argument(
        "--output_root_name",
        type=str,
        default="baseline_runs_v2",
        help="Folder created inside each task subfolder to store results",
    )
    parser.add_argument(
        "--base_folders",
        nargs="+",
        default=["/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny_gpt5_1codexMax"],
        help="One or more dataset roots containing subfolders with one_line_description.txt and detailed_description.txt",
    )
    args = parser.parse_args()

    cfg = RunConfig(
        llm_model=args.llm_model,
        slm_model=args.slm_model,
        temperature=args.temperature,
        max_iterations=args.max_iterations,
        dafny_timeout=args.dafny_timeout,
        dafny_exec=args.dafny_exec,
        output_root_name=args.output_root_name,
    )

    process_folders_parallel(
        base_folders=args.base_folders,
        cfg=cfg,
        experiment_mode=args.experiment_mode,
        prompt_types=args.prompt_types,
        workers=args.workers,
    )
