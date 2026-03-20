# # import os
# # import subprocess
# # import openai
# # import json
# # import csv

# # # Configuration
# # ROOT_DIR = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/TEST"
# # DAFNY_CLI = "/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny"
# # OPENAI_MODEL = "o4-mini-2025-04-16"
# # TESTCASE_JSON = os.path.join(ROOT_DIR, "testcases.json")
# # OUTPUT_CSV = os.path.join(ROOT_DIR, "conversion_results.csv")

# # # Initialize OpenAI
# # from openai import OpenAI

# # client = OpenAI(api_key="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")


# # # Step 1: Generate test case JSON for each Dafny file
# # testcases = []
# # for folder in os.listdir(ROOT_DIR):
# #     folder_path = os.path.join(ROOT_DIR, folder)
# #     if not os.path.isdir(folder_path):
# #         continue
# #     folder_name = folder_path.split("/")[-1]
# #     # dfy_files = [f for f in os.listdir(folder_path) if f.endswith('.dfy')]
# #     # if not dfy_files:
# #     #     continue
# #     # dfy_file = dfy_files[0]
# #     #check if folder_name.dfy exists
# #     if not os.path.exists(os.path.join(folder_path, f"{folder_name}.dfy")):
# #         continue
# #     dfy_path = os.path.join(folder_path, f"{folder_name}.dfy")
# #     #read the dfy file
# #     with open(dfy_path, 'r') as f:
# #         dfy_code = f.read()

# #     # Prompt AI to suggest a test case JSON entry
# #         prompt_tc = (
# #             f"Given the following Dafny code, creat a test case. Please genarate only the test inputs, example if ther code is for a binary search, then generate test inputs like : [1,2,3,4,5,6,7,8,9,10]; 5. where ; seperates each input. Code: {dfy_code}"
# #         )
# #         response_tc = client.chat.completions.create(
# #             model=OPENAI_MODEL,
# #             messages=[{"role": "user", "content": prompt_tc}]
# #         )
# #         # Parse and store
# #         entry = response_tc.choices[0].message.content
# #         # testcases.append(entry)

# #     # Write testcases.json
# #         with open(TESTCASE_JSON, 'a') as jf:
# #             #write two object for each dafny file
# #             json.dump({
# #                 "file_name": folder_name,
# #                 "test_case": entry
# #             }, jf, indent=2)


# # #!/usr/bin/env python3
# # import os
# # import subprocess
# # import json
# # import csv
# # import re
# # import openai

# # # ─── Configuration ─────────────────────────────────────────────────────────────
# # # Base directory containing one subfolder per .dfy test
# # BASE_DIR = "/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
# # DAFNY_CLI = "/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny"
# # # Path to your JSON file with test cases:
# # # [
# # #   {"file_name": "Foo.dfy", "test_case": "[…literal Python value…]"},
# # #   … 
# # # ]
# # TEST_JSON = "/path/to/test_cases.json"
# # # Output CSV
# # RESULT_CSV = os.path.join(BASE_DIR, "results.csv")

# # # Make sure your OPENAI_API_KEY is set in env
# # openai.api_key = os.getenv("OPENAI_API_KEY")
# # if not openai.api_key:
# #     raise RuntimeError("Please set OPENAI_API_KEY in your environment")

# # # ─── Load test cases ──────────────────────────────────────────────────────────
# # with open(TEST_JSON, "r") as f:
# #     test_entries = json.load(f)

# # # Map file_name → test_case value
# # tests = {entry["file_name"]: entry["test_case"] for entry in test_entries}

# # # ─── Prepare results CSV ───────────────────────────────────────────────────────
# # with open(RESULT_CSV, "w", newline="") as csvfile:
# #     writer = csv.writer(csvfile)
# #     writer.writerow(["file_name", "status", "error_output"])

# #     # ─── Iterate each folder ────────────────────────────────────────────────
# #     for folder in os.listdir(BASE_DIR):
# #         folder_path = os.path.join(BASE_DIR, folder)
# #         if not os.path.isdir(folder_path):
# #             continue

# #         # Find any .dfy file(s) in this folder
# #         dfy_files = [f for f in os.listdir(folder_path) if f.endswith(".dfy")]
# #         for dfy in dfy_files:
# #             dfy_path = os.path.join(folder_path, dfy)
# #             print(f"--- Processing {dfy} ---")

# #             # 1) Run Dafny → Python
# #             try:
# #                 subprocess.run(
# #                     [DAFNY_CLI, "build", "--target:py", dfy_path, "--allow-warnings"],
# #                     cwd=BASE_DIR,
# #                     check=True,
# #                     stdout=subprocess.PIPE, stderr=subprocess.PIPE
# #                 )
# #             except subprocess.CalledProcessError as e:
# #                 writer.writerow([dfy, "dafny-build-failed", e.stderr.decode()])
# #                 continue

# #             # 2) Locate generated module_.py
# #             out_folder = os.path.join(BASE_DIR, folder + "-py")
# #             src_py = os.path.join(out_folder, "module_.py")
# #             if not os.path.isfile(src_py):
# #                 writer.writerow([dfy, "no-module_.py", ""])
# #                 continue
# #             code = open(src_py, "r").read()

# #             # 3) Ask ChatGPT to refactor into “plain” Python + numpy types
# #             prompt = f"""
# # Refactor the following Python code (from a Dafny → Python compile) into a stand-alone Python module:
# # - Remove the `class default__:` wrapper and all `@staticmethod` decorators.
# # - Emit only top-level `def` functions (no classes).
# # - Replace every `int` (and other built-in primitives) with appropriate NumPy types (e.g. `np.int32`).
# # - Do not introduce any Dafny runtime dependencies.

# # ```python
# # {code}
# # """
# # resp = openai.ChatCompletion.create(
# # model="o4-mini-high",
# # temperature=0,
# # messages=[
# # {"role": "system", "content": "You are a Python refactoring assistant."},
# # {"role": "user", "content": prompt}
# # ]
# # )
# # refactored = resp.choices[0].message.content
# #         # 4) Write out clean module, prepending numpy import
# #         clean_py = os.path.join(out_folder, f"{folder}.py")
# #         with open(clean_py, "w") as f:
# #             f.write("import numpy as np\n\n")
# #             f.write(refactored)

# #         # 5) Inject the user’s test case under __main__
# #         test_case = tests.get(dfy)
# #         if test_case is None:
# #             writer.writerow([dfy, "no-test-case", ""])
# #             continue

# #         # detect the first function name
# #         m = re.search(r"^def\s+([A-Za-z_]\w*)\s*\(", refactored, re.MULTILINE)
# #         if not m:
# #             writer.writerow([dfy, "no-func-found", ""])
# #             continue
# #         func_name = m.group(1)

# #         with open(clean_py, "a") as f:
# #             f.write("\n\nif __name__ == '__main__':\n")
# #             f.write(f"    # auto-injected by script\n")
# #             f.write(f"    test_input = {test_case}\n")
# #             f.write(f"    result = {func_name}(test_input)\n")
# #             f.write(f"    print('RESULT:', result)\n")

# #         # 6) Run the resulting Python file and record success/failure
# #         proc = subprocess.run(
# #             ["python3", clean_py],
# #             cwd=out_folder,
# #             capture_output=True,
# #             text=True
# #         )
# #         status = "PASS" if proc.returncode == 0 else "FAIL"
# #         err = proc.stderr.strip().replace("\n", "\\n")
# #         writer.writerow([dfy, status, err])

# #         print(f"{dfy} → {status}")
# # print(f"\nDone! Results in {RESULT_CSV}")




# # import json
# # import sys

# # def sort_by_filename(input_path, output_path, key="file_name"):
# #     with open(input_path, "r") as f:
# #         data = json.load(f)
# #     # assume data is a list of objects
# #     sorted_data = sorted(data, key=lambda obj: obj.get(key, ""))
# #     with open(output_path, "w") as f:
# #         json.dump(sorted_data, f, indent=2)

# # if __name__ == "__main__":
# #     sort_by_filename("/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/TEST/testcases.json", "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/TEST/testcases_sorted.json")


# #!/usr/bin/env python3
# # import os
# # import json
# # import re
# # import logging

# # logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
# # print("Starting the script")

# # # Regex to parse filenames
# # pattern = re.compile(
# #     r"^result_(?P<problem>.+?)_llm-(?P<model>.+?)_pass@1_"
# #     r"(?P<feedback>with_feedback|no_feedback)\.json$"
# # )

# # # directories (edit these)
# # input_dir   = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_with_trained/"
# # base_target = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_with_trained_converted"

# # # ensure base_target exists
# # os.makedirs(base_target, exist_ok=True)

# # for fname in os.listdir(input_dir):
# #     m = pattern.match(fname)
# #     if not m:
# #         print(f"skip non-matching: {fname}")
# #         continue

# #     full_path = os.path.join(input_dir, fname)
# #     try:
# #         with open(full_path, "r") as f:
# #             data = json.load(f)
# #     except Exception as e:
# #         print(f"failed to read {fname}: {e}")
# #         continue

# #     # skip if not successful
# #     if int(data.get("success", 0)) != 1:
# #         print(f"skip unsuccessful: {fname}")
# #         continue

# #     problem  = m.group("problem")
# #     model    = m.group("model")
# #     feedback = m.group("feedback")  # with_feedback or no_feedback

# #     # build and create the full target path
# #     target_folder = os.path.join(base_target, f"{model}_{feedback}", problem)
# #     os.makedirs(target_folder, exist_ok=True)

# #     # get the code
# #     raw_code = data.get("final_code", "")
# #     if not raw_code:
# #         print(f"no final_code in {fname}, skipping")
# #         continue

# #     # decode escaped newlines and tabs
# #     decoded = raw_code.replace("\\n", "\n").replace("\\t", "\t")

# #     # write out .dfy
# #     out_path = os.path.join(target_folder, f"{problem}.dfy")
# #     try:
# #         with open(out_path, "w") as out_f:
# #             out_f.write(decoded)
# #         print(f"wrote {out_path}")
# #     except Exception as e:
# #         print(f"failed to write {out_path}: {e}")



# #!/usr/bin/env python3
# #!/usr/bin/env python3
# # import os
# # import glob
# # import shutil
# # import subprocess
# # import logging

# # # ─── EDIT THESE ───────────────────────────────────────────
# # # List of root directories you want to process:
# # input_dirs = [
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_with_trained_converted/gemini_no_feedback",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_with_trained_converted/gemini_with_feedback",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_with_trained_converted/gpt4o_no_feedback",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_with_trained_converted/gpt4o_with_feedback",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_with_trained_converted/o1mini_no_feedback",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_with_trained_converted/o1mini_with_feedback",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/TEST_WITHOUTTRAINED2_converted/gemini_no_feedbackwt",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/TEST_WITHOUTTRAINED2_converted/gemini_with_feedbackwt",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/TEST_WITHOUTTRAINED2_converted/gpt4o_no_feedbackwt",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/TEST_WITHOUTTRAINED2_converted/gpt4o_with_feedbackwt",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/TEST_WITHOUTTRAINED2_converted/o1mini_no_feedbackwt",
# #     "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/TEST_WITHOUTTRAINED2_converted/o1mini_with_feedbackwt",
# #     # add more as needed
# # ]

# # # Where to mirror the structure and drop module_.py:
# # dest_root = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Dafny_to_HLS"
# # # ─────────────────────────────────────────────────────────
# # failure_log   = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/conversion_failures.txt"
# # # ─────────────────────────────────────────────────────────

# # INTEGRATION_TESTS_DIR = "/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
# # DAFNY_SCRIPT         = "/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny"

# # def log_failure(dfy_path):
# #     with open(failure_log, "a") as log_f:
# #         log_f.write(dfy_path + "\n")

# # def process_subfolder(subfolder_path, dest_root, parent_basename):
# #     # locate the .dfy file
# #     #get file name from subfolder_path
# #     file_name = os.path.basename(subfolder_path)
# #     dfy_files = glob.glob(os.path.join(subfolder_path, f"{file_name}.dfy"))
# #     if not dfy_files:
# #         logging.warning(f"No .dfy in {subfolder_path}, skipping")
# #         return
# #     dfy_path = dfy_files[0]
# #     basename = os.path.splitext(os.path.basename(dfy_path))[0]

# #     # run Dafny build --target:py
# #     cmd = [DAFNY_SCRIPT, "build", "--target:py", dfy_path, "--allow-warnings"]
# #     logging.info(f"Running: {' '.join(cmd)} (cwd={INTEGRATION_TESTS_DIR})")
# #     try:
# #         subprocess.run(cmd, cwd=INTEGRATION_TESTS_DIR, check=True)
# #     except subprocess.CalledProcessError as e:
# #         logging.error(f"Dafny build failed for {dfy_path}: {e}")
# #         log_failure(dfy_path)
# #         return

# #     # find module_.py in <basename>-py
# #     generated_dir = os.path.join(subfolder_path, f"{basename}-py")
# #     module_py     = os.path.join(generated_dir, "module_.py")
# #     if not os.path.isfile(module_py):
# #         logging.error(f"module_.py not found in {generated_dir}, skipping")
# #         log_failure(dfy_path)
# #         return

# #     # copy into mirror under dest_root
# #     dest_dir = os.path.join(dest_root, parent_basename, os.path.basename(subfolder_path))
# #     os.makedirs(dest_dir, exist_ok=True)
# #     dest_py = os.path.join(dest_dir, "module_.py")

# #     try:
# #         shutil.copy2(module_py, dest_py)
# #         logging.info(f"Copied -> {dest_py}")
# #     except Exception as e:
# #         logging.error(f"Failed to copy to {dest_py}: {e}")
# #         log_failure(dfy_path)

# # def main():
# #     logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

# #     # ensure destination and clear failure log
# #     os.makedirs(dest_root, exist_ok=True)
# #     open(failure_log, "w").close()

# #     for input_dir in input_dirs:
# #         if not os.path.isdir(input_dir):
# #             logging.warning(f"Input directory not found: {input_dir}")
# #             continue

# #         parent_basename = os.path.basename(os.path.normpath(input_dir))
# #         logging.info(f"Processing `{parent_basename}` at {input_dir}")

# #         for entry in os.listdir(input_dir):
# #             subfolder = os.path.join(input_dir, entry)
# #             if not os.path.isdir(subfolder):
# #                 continue
# #             process_subfolder(subfolder, dest_root, parent_basename)

# # if __name__ == "__main__":
# #     main()



# #!/usr/bin/env python3
# # import os
# # import openai
# # import time
# # from openai import OpenAI

# # # ─── EDIT THESE ───────────────────────────────────────────
# # # Directory containing subfolders, each with one Dafny-generated .py file
# # INPUT_ROOT  = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Dafny_to_HLS"

# # # Where to write the cleaned files (mirror INPUT_ROOT structure)
# # OUTPUT_ROOT = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Dafny_to_HLS/cleaned_files"

# # # Model name
# # MODEL_NAME  = "o4-mini-2025-04-16"
# # # ──────────────────────────────────────────────────────────

# # # Make sure you have your API key in the env var OPENAI_API_KEY
# # # export OPENAI_API_KEY="sk-..."

# # client = OpenAI(api_key="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")

# # def clean_dafny_code(code: str) -> str:
# #     """
# #     Sends `code` to o4-mini-high asking to strip all Dafny
# #     dependencies, remove empty classes and @staticmethods,
# #     replace built-in primitives with numpy types, etc.
# #     """
# #     system = {
# #         "role": "system",
# #         "content": (
# #             "You are a code assistant specialized in cleaning up "
# #             "Dafny-generated Python.  Your output must be valid, "
# #             "standalone Python with no Dafny imports or runtime.  "
# #             "Remove any `class default__:` wrappers and all "
# #             "`@staticmethod` decorators.  Replace built-in types "
# #             "like `int` with appropriate NumPy types (e.g. `np.int32`)."
# #         )
# #     }
# #     user = {
# #         "role": "user",
# #         "content": (
# #             "Here is a Dafny-generated Python file.  Rewrite it so that:\n"
# #             "  • No `import _dafny` or other Dafny runtime imports or any dafny related dependencies or functions are present.\n"
# #             "  • No empty classes or `@staticmethod` usage.\n"
# #             "  • All built-in primitives become NumPy types (`np.int32`, etc.).\n"
# #             "  • Preserve logic and function signatures.\n\n"
# #             "```python\n"
# #             f"{code}\n"
# #             "```"
# #         )
# #     }

# #     resp = client.chat.completions.create(
# #         model=MODEL_NAME,
# #         messages=[system, user] # adjust as needed
# #     )
# #     return resp.choices[0].message.content

# # def main():
# #     for level1 in os.listdir(INPUT_ROOT):
# #         dir1 = os.path.join(INPUT_ROOT, level1)
# #         if not os.path.isdir(dir1):
# #             continue

# #         for level2 in os.listdir(dir1):
# #             subdir = os.path.join(dir1, level2)
# #             if not os.path.isdir(subdir):
# #                 continue

# #             # find all .py files in this subdirectory
# #             py_files = [f for f in os.listdir(subdir) if f.endswith(".py")]
# #             if not py_files:
# #                 print(f"[skip] no .py files in {subdir}")
# #                 continue

# #             for py_fname in py_files:
# #                 in_path = os.path.join(subdir, py_fname)
# #                 if os.path.exists(os.path.join(OUTPUT_ROOT, level1, level2, py_fname)):
# #                     print(f"[skip] {in_path} already exists")
# #                     continue
                
# #                 with open(in_path, "r") as f:
# #                     original = f.read()

# #                 try:
# #                     cleaned = clean_dafny_code(original)
# #                 except Exception as e:
# #                     print(f"[error] API failed for {in_path}: {e}")
# #                     continue

# #                 # mirror structure in OUTPUT_ROOT
# #                 out_subdir = os.path.join(OUTPUT_ROOT, level1, level2)
# #                 os.makedirs(out_subdir, exist_ok=True)
# #                 out_path = os.path.join(out_subdir, py_fname)

# #                 with open(out_path, "w") as f:
# #                     f.write(cleaned)
# #                 print(f"[ok] {in_path} → {out_path}")

# #                 # be polite to the API
# #                 time.sleep(1)

# # if __name__ == "__main__":
# #     main()


# # #!/usr/bin/env python3
# # import os
# # import re
# # import subprocess
# # import shutil
# # import csv

# # # ─── EDIT THESE ───────────────────────────────────────────
# # INPUT_ROOT = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Dafny_to_HLS/cleaned_files"
# # LOG_CSV    = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Dafny_to_HLS/cleaned_files/log.csv"
# # PYTHON_CMD = "python"   # or full path to your python
# # # ─────────────────────────────────────────────────────────

# # HEADER_LINES = [
# #     "import sys",
# #     'sys.path.append("/mnt/shared/gpfs/home/manvij2")',
# #     "from pylog import *",
# #     "import numpy as np",
# #     "",
# #     "@pylog(mode='cgen')",
# #     ""
# # ]

# # # regex to strip triple-backtick wrappers
# # RE_BACKTICK_START = re.compile(r'^\s*```python\s*$', re.IGNORECASE)
# # RE_BACKTICK_END   = re.compile(r'^\s*```\s*$')

# # # regex to remove multiline comments
# # RE_MULTILINE = re.compile(r'""".*?"""', re.DOTALL)

# # # regex to capture HLS output path
# # RE_HLS_OUT   = re.compile(r"HLS C code written to (.+)")

# # def process_file(py_path):
# #     # --- read and clean ---
# #     with open(py_path, "r") as f:
# #         lines = f.readlines()

# #     # strip ```python / ``` if at very start/end
# #     if lines and RE_BACKTICK_START.match(lines[0]):
# #         lines = lines[1:]
# #     if lines and RE_BACKTICK_END.match(lines[-1]):
# #         lines = lines[:-1]
# #     content = "".join(lines)
# #     # remove multiline comments
# #     content = RE_MULTILINE.sub("", content)

# #     # prepend header
# #     new_content = "\n".join(HEADER_LINES) + content

# #     # overwrite file
# #     with open(py_path, "w") as f:
# #         f.write(new_content)

# #     # --- run it ---
# #     proc = subprocess.run(
# #         [PYTHON_CMD, py_path],
# #         capture_output=True,
# #         text=True
# #     )

# #     out = proc.stdout + proc.stderr
# #     success = (proc.returncode == 0)
# #     hls_path = None

# #     if success:
# #         m = RE_HLS_OUT.search(out)
# #         if m:
# #             hls_path = m.group(1).strip()
# #             # copy generated C file next to the .py
# #             dest_dir = os.path.dirname(py_path)
# #             try:
# #                 shutil.copy2(hls_path, dest_dir)
# #             except Exception as e:
# #                 # copying failed
# #                 success = False
# #                 out += f"\n[copy error] {e}"
# #         else:
# #             success = False
# #             out += "\n[error] did not find HLS output path"

# #     return success, out, hls_path

# # def main():
# #     # prepare CSV
# #     with open(LOG_CSV, "w", newline="") as csvf:
# #         writer = csv.writer(csvf)
# #         writer.writerow(["py_file", "success", "hls_path", "log"])

# #         # walk tree
# #         for root, _, files in os.walk(INPUT_ROOT):
# #             for fn in files:
# #                 if not fn.endswith(".py"):
# #                     continue
# #                 py_path = os.path.join(root, fn)
# #                 print(f"Processing {py_path}…")
# #                 success, log, hls_path = process_file(py_path)
# #                 writer.writerow([py_path, success, hls_path or "", log.replace("\n", "\\n")])
# #                 status = "OK" if success else "FAIL"
# #                 print(f"  → {status}")

# # if __name__ == "__main__":
# #     main()


# import os
# import subprocess
# import re
# import shutil
# import csv
# import time

# # ─── EDIT THESE ───────────────────────────────────────────
# # Root directory containing first-level folders
# INPUT_ROOT = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Dafny_to_HLS/cleaned_files/o1mini_with_feedback"

# # CSV log file path
# LOG_CSV = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Dafny_to_HLS/cleaned_files/o1mini_with_feedback/results_log_o1mini_with_feedback.csv"

# # Vitis HLS command
# VITIS_HLS_CMD = "vitis_hls"
# # ─────────────────────────────────────────────────────────

# # Reserved top-level names not allowed in HLS
# RESERVED_NAMES = {
#     'acos','acospi','asin','asinpi','atan','atan2','atan2pi','cos','cospi',
#     'sin','sincos','sinpi','tan','tanpi','acosh','asinh','atanh','cosh','sinh',
#     'tanh','exp','exp10','exp2','expm1','frexp','ldexp','modf','ilogb','log',
#     'log10','log1p','cbrt','hypot','pow','rsqrt','sqrt','erf','erfc','ceil',
#     'floor','llrint','llround','lrint','lround','nearbyint','rint','round',
#     'trunc','main','Abs'
# }

# # Regex to capture HLS C output path
# RE_HLS_OUT = re.compile(r"HLS C code written to (.+)")

# results = []

# # Walk two levels under INPUT_ROOT
# for level1 in os.listdir(INPUT_ROOT):
#     print(f"[INFO] Processing {level1}")
#     dir1 = os.path.join(INPUT_ROOT, level1)
#     if not os.path.isdir(dir1):
#         print(f"[ERROR] {dir1} is not a directory")
#         continue
#     for level2 in os.listdir(dir1):
#         print(f"[INFO] Processing {level2}hkjhkjh")
#         subdir = os.path.join(dir1, level2)
#         print(f"[INFO] Processing {subdir}")
#         # if not os.path.isdir(subdir):
#         #     print(f"[ERROR] {subdir} is not a directory")
#         #     continue
#         # find .py files in subdir

#         if os.path.isfile(subdir):
#             print(f"[INFO] Processing {subdir}l;l;,;l,")
#             if not subdir.endswith(".py"):
#                 continue
#             py_path = subdir
#             print(f"[INFO] Running PyLog: {py_path}")
#             # 1) Run the Python file
#             proc = subprocess.run(["python", py_path], capture_output=True, text=True)
#             out = proc.stdout + proc.stderr
#             if proc.returncode != 0:
#                 print(f"[ERROR] PyLog run failed for {py_path}")
#                 results.append({
#                     'py_file': py_path,
#                     'cpp_file': '',
#                     'status': 'FAIL',
#                     'log': out.replace('\n','\\n')
#                 })
#                 continue
#             # 2) Extract .cpp path
#             m = RE_HLS_OUT.search(out)
#             if not m:
#                 print(f"[ERROR] HLS output not found in {py_path}")
#                 results.append({
#                     'py_file': py_path,
#                     'cpp_file': '',
#                     'status': 'FAIL',
#                     'log': out.replace('\n','\\n')
#                 })
#                 continue
#             cpp_path = m.group(1).strip()
#             if not os.path.isfile(cpp_path):
#                 print(f"[ERROR] C++ file not found: {cpp_path}")
#                 results.append({
#                     'py_file': py_path,
#                     'cpp_file': cpp_path,
#                     'status': 'FAIL',
#                     'log': out.replace('\n','\\n')
#                 })
#                 continue

#             # Derive base name
#             cpp_dir  = os.path.dirname(cpp_path)
#             cpp_name = os.path.basename(cpp_path)
#             base_name = os.path.splitext(cpp_name)[0]

#             # 3) Rename if reserved
#             new_name = base_name
#             if base_name.lower() in RESERVED_NAMES or base_name.startswith('hls_') or base_name.startswith('ap_'):
#                 new_name = base_name + 'sss'
#                 new_cpp = os.path.join(cpp_dir, new_name + '.cpp')
#                 os.rename(cpp_path, new_cpp)
#                 cpp_path = new_cpp
#             else:
#                 new_cpp = cpp_path

#             # 4) Edit C++ file: replace int32 -> ap_int<32>, rename function if needed
#             with open(new_cpp, 'r') as f:
#                 content = f.read()
#             content = content.replace('int32', 'ap_int<32>')
#             #read lines of content
#             lines = content.split('\n')
#             #if the line having void come after return then replace void with int
#             for i in range(len(lines)):
#                 if 'void' in lines[i]:
#                   vo=1
#                   n =i
#                   if 'return' in lines[i] and vo==1:
#                     lines[n] = lines[n].replace('void', 'int')
#                     vo=0
#                 if "True" in lines[i]:
#                     lines[i] = lines[i].replace('True', 'true')
#                 if "False" in lines[i]:
#                     lines[i] = lines[i].replace('False', 'false')
#                 # if ) \\ in lines[i] then replace it with )
#                 if ") \\\\" in lines[i]:
#                     lines[i] = lines[i].replace(") \\\\", ") \\")

#             content = '\n'.join(lines)

#             if new_name != base_name:
#                 # rename function occurrences
#                 content = re.sub(r'\b' + re.escape(base_name) + r'\b', new_name, content)
#             with open(new_cpp, 'w') as f:
#                 f.write(content)

#             # 5) Create synth_only.tcl
#             tcl_path = os.path.join(cpp_dir, 'synth_only.tcl')
#             with open(tcl_path, 'w') as tclf:
#                 tclf.write(f'''# synth_only.tcl
# cd {cpp_dir}
# open_project {new_name}
# set_top {new_name}
# add_files {new_name}.cpp
# open_solution sol1 -flow_target vivado
# set_part {{xc7z020clg484-1}}
# create_clock -period 10 -name default
# csynth_design
# report_utilization
# report_timing -delay_type max
# exit
# ''')

#             # 6) Run HLS synthesis
#             print(f"[INFO] Synthesizing: {new_name}")
#             #run the commadn cd cpp_dir
#             vh = subprocess.run(
#                 [VITIS_HLS_CMD, '-f', tcl_path],
#                 cwd=cpp_dir,
#                 capture_output=True,
#                 text=True
#             )
#             vh_out = vh.stdout + vh.stderr
#             with open(os.path.join(cpp_dir, 'vitis_hls.log'), 'r') as f:
#                 vh_read = f.read()
#                 if 'ERROR:' in vh_read:
#                     vh_out = vh_read
#                     status = 'FAIL'
#                     total_elapsed_time = 0
#                     peak_allocated_memory = 0
#                 else:
#                     status = 'PASS'
#                     #the last line of the vh_read is like Total CPU user time: 25.34 seconds. Total CPU system time: 2.87 seconds. Total elapsed time: 33.4 seconds; peak allocated memory: 731.852 MB., i need to extract the total elapsed time and the peak allocated memory
#                     last_line = vh_read.split('\n')[-2]
#                     total_elapsed_time = last_line.split('Total elapsed time: ')[1].split(' seconds')[0]
#                     peak_allocated_memory = last_line.split('peak allocated memory: ')[1].split(' MB')[0]
#                     vh_out = f"Total elapsed time: {total_elapsed_time} seconds\nPeak allocated memory: {peak_allocated_memory} MB"
#                     print(f"[INFO] Total elapsed time: {total_elapsed_time} seconds\nPeak allocated memory: {peak_allocated_memory} MB")
#             # status = 'PASS' if vh.returncode == 0 else 'FAIL'
#             print(f"[INFO] Synth status for {new_name}: {status}")

#             results.append({
#                 'py_file': py_path,
#                 'cpp_file': new_cpp,
#                 'status': status,
#                 'log': vh_out.replace('\n','\\n'),
#                 'total_elapsed_time': total_elapsed_time,
#                 'peak_allocated_memory': peak_allocated_memory
#             })
#             # be polite
#             time.sleep(0.5)

# # Write CSV
# with open(LOG_CSV, 'w', newline='') as csvf:
#     writer = csv.DictWriter(csvf, fieldnames=['py_file','cpp_file','status','log', 'total_elapsed_time', 'peak_allocated_memory'])
#     writer.writeheader()
#     for r in results:
#         writer.writerow(r)

# print(f"[DONE] Wrote results to {LOG_CSV}")


import os
import csv
import re
from typing import List, Dict, Set

def find_common_folders(dirs: List[str]) -> Set[str]:
    folder_sets = []
    for d in dirs:
        # List only directories inside d
        folders = {f for f in os.listdir(d) if os.path.isdir(os.path.join(d, f))}
        folder_sets.append(folders)
    # Intersection of folder names across all dirs
    common = set.intersection(*folder_sets)
    return common

def extract_latency_from_report(report_path: str) -> str:
    """
    Extract latency value (e.g., '0.120 us') from the .rpt file.
    Looks for line matching pattern '+ Latency:' and then
    searches for a line with the table, extracts the latency absolute min or max values.
    We'll extract the min or max absolute latency string from the table below it.
    """
    if not os.path.isfile(report_path):
        return ""

    with open(report_path, "r") as f:
        lines = f.readlines()

    # We look for the latency table start by detecting the "+ Latency:" line
    latency_start_idx = None
    for i, line in enumerate(lines):
        if line.strip().startswith("+ Latency:"):
            latency_start_idx = i
            break
    if latency_start_idx is None:
        return ""

    # The latency table starts a few lines after latency_start_idx
    # We find the line with the latency absolute values, e.g.
    # |       12|       12|  0.120 us|  0.120 us|   13|   13|       no|
    # We want to extract the 3rd and 4th columns from this line (min and max absolute latency)
    i1=0
    for line in lines[latency_start_idx:latency_start_idx+20]:
        if "+--" in line:
            i1+=1
            print("hi")
            print(line)
              # scan next 20 lines max
        if '|' in line and i1==2:
            # split columns by '|'
                parts = [p.strip() for p in line.strip().split('|')]
                print(parts)
                # There should be 8 columns (including empty at start and end)
                # indices: 0 empty, 1 Latency(cycles) min, 2 Latency(cycles) max, 3 Latency(absolute) min, 4 Latency(absolute) max, etc.
                if len(parts) >= 7 and parts[3] and parts[4]:
                    # Return the min latency absolute value (or max if you want)
                    # Usually something like "0.120 us"
                    
                    return parts[3]  # min absolute latency with units
    return ""

def main(directories: List[str], output_csv: str):
    # Find folders common to all directories
    common_folders = find_common_folders(directories)
    print(f"Found {len(common_folders)} common folders.")

    # Prepare data structure:
    # {folder_name: {dir_name: latency}}
    data: Dict[str, Dict[str, str]] = {}

    for folder in sorted(common_folders):
        data[folder] = {}
        for d in directories:
            # Compose path to report file
            rpt_path = os.path.join(d, folder, folder, "sol1", "syn", "report", f"{folder}_csynth.rpt")
            latency = extract_latency_from_report(rpt_path)
            data[folder][os.path.basename(d.rstrip("/\\"))] = latency

    # Write CSV
    # Header: Folder, dir1_name, dir2_name, ...
    dir_names = [os.path.basename(d.rstrip("/\\")) for d in directories]
    with open(output_csv, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Folder"] + dir_names)
        for folder in sorted(common_folders):
            row = [folder] + [data[folder].get(dir_name, "") for dir_name in dir_names]
            writer.writerow(row)

    print(f"CSV written to {output_csv}")

if __name__ == "__main__":
    # Example usage:
    # Replace these with your actual directory paths
    directories = [
        "/mnt/shared/gpfs/home/manvij2/pylog/pylog_projects",
        "/mnt/shared/gpfs/home/manvij2/pylog/pylog_projects_4o_no_feedback",
        "/mnt/shared/gpfs/home/manvij2/pylog/pylog_projects_GPT4o_withfeedback",
        "/mnt/shared/gpfs/home/manvij2/pylog/pylog_projects_no_feedback_gemini",
        "/mnt/shared/gpfs/home/manvij2/pylog/pylog_projects_o1_no_feedback",
        "/mnt/shared/gpfs/home/manvij2/pylog/pylog_projects_with_feedback"
    ]
    output_csv = "latency_summary.csv"
    main(directories, output_csv)
