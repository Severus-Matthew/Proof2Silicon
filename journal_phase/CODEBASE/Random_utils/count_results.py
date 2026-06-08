# import os
# from collections import defaultdict

# BASE_DIR = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset_3"  # change if needed

# MODEL_MAP = {
#     "baseline_runs_5_3": "chatgpt5.3",
#     "baseline_runs_v2": "chatgpt5.1",
#     "baselines_runs_deepseek": "deepseek"
# }

# PROMPT_TYPES = ["fewshot", "short", "shortanddetailed"]

# # results[model][prompt] = stats
# results = defaultdict(lambda: defaultdict(lambda: {
#     "total": 0,
#     "success": 0,
#     "success_round1": 0,
#     "failure": 0
# }))


# def check_attempt_success(attempt_path):
#     """Check if .dll exists in attempt folder"""
#     if not os.path.exists(attempt_path):
#         return False
#     return any(f.endswith(".dll") for f in os.listdir(attempt_path))


# for problem_folder in os.listdir(BASE_DIR):
#     problem_path = os.path.join(BASE_DIR, problem_folder)
#     if not os.path.isdir(problem_path):
#         continue

#     for run_folder, model_name in MODEL_MAP.items():
#         run_path = os.path.join(problem_path, run_folder, "llm_only")
#         if not os.path.exists(run_path):
#             continue  # this problem wasn't run for this model

#         for prompt in PROMPT_TYPES:
#             prompt_path = os.path.join(run_path, prompt)
#             if not os.path.exists(prompt_path):
#                 continue

#             # Each problem counts once per model+prompt
#             results[model_name][prompt]["total"] += 1

#             success = False
#             success_round1 = False

#             # Check attempts 0 → 6
#             for i in range(7):
#                 attempt_path = os.path.join(prompt_path, f"attempt_{i}")

#                 if check_attempt_success(attempt_path):
#                     success = True
#                     if i == 0:
#                         success_round1 = True
#                     break  # stop at first success

#             if success:
#                 results[model_name][prompt]["success"] += 1
#                 if success_round1:
#                     results[model_name][prompt]["success_round1"] += 1
#             else:
#                 results[model_name][prompt]["failure"] += 1


# # 🔥 Pretty print results
# print("\n===== FINAL RESULTS =====\n")

# for model in results:
#     print(f"Model: {model}")
#     for prompt in results[model]:
#         stats = results[model][prompt]
#         print(f"  Prompt: {prompt}")
#         print(f"    Total: {stats['total']}")
#         print(f"    Success: {stats['success']}")
#         print(f"    Success (Round 1): {stats['success_round1']}")
#         print(f"    Failure: {stats['failure']}")
#     print()



# import os
# import re
# import json
# from collections import defaultdict

# # Change this to your folder containing the JSON result files
# RESULTS_DIR = "/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_cleaned"

# # results[model] = stats
# results = defaultdict(lambda: {
#     "total": 0,
#     "success_round1": 0,
#     "success_other": 0,
#     "failure": 0
# })

# # Example filename:
# # result_Dafny(91)_llm-gpt-5.1-codex-max_pass@1_with_feedback.json
# filename_pattern = re.compile(
#     r"^result_(.+?)_llm-gpt-(.+?)_pass@1_with_feedback\.json$"
# )

# for fname in os.listdir(RESULTS_DIR):
#     if not fname.endswith(".json"):
#         continue

#     match = filename_pattern.match(fname)
#     if not match:
#         print(f"Skipping unrecognized filename: {fname}")
#         continue

#     problem_name, model_name = match.groups()
#     file_path = os.path.join(RESULTS_DIR, fname)

#     try:
#         with open(file_path, "r", encoding="utf-8") as f:
#             data = json.load(f)
#     except Exception as e:
#         print(f"Could not read {fname}: {e}")
#         continue

#     attempts = data.get("attempts", [])
#     results[model_name]["total"] += 1

#     round1_success = False
#     any_success = False

#     for att in attempts:
#         attempt_num = att.get("attempt")
#         success = att.get("success", 0)

#         if success == 1:
#             any_success = True
#             if attempt_num == 1:
#                 round1_success = True
#             break  # stop at first success

#     if round1_success:
#         results[model_name]["success_round1"] += 1
#     elif any_success:
#         results[model_name]["success_other"] += 1
#     else:
#         results[model_name]["failure"] += 1


# # Print report
# print("\n===== JSON RESULTS REPORT =====\n")
# for model_name, stats in sorted(results.items()):
#     total = stats["total"]
#     r1 = stats["success_round1"]
#     other = stats["success_other"]
#     fail = stats["failure"]

#     print(f"Model: {model_name}")
#     print(f"  Problems run       : {total}")
#     print(f"  Success in round 1 : {r1}")
#     print(f"  Success otherwise  : {other}")
#     print(f"  Failure            : {fail}")

#     if total > 0:
#         print(f"  Round-1 success %  : {100*r1/total:.2f}%")
#         print(f"  Overall success %  : {100*(r1+other)/total:.2f}%")
#         print(f"  Failure %          : {100*fail/total:.2f}%")
#     print()



import os
import importlib.util
from collections import defaultdict

BASE_DIR = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset_3"

MODEL_MAP = {
    "baseline_runs_5_3": "chatgpt5.3",
    "baseline_runs_v2": "chatgpt5.1",
    "baseline_runs_deepseek": "deepseek"
}

PROMPT_TYPES = ["fewshot", "short", "shortanddetailed"]

# Path to your daf_scc / robust analyzer file
DAF_SCC_PATH = "/u/mjha1/Proof2Silicon/journal_phase/CODEBASE/preface_rl/Dafny_SCC.py"

# -----------------------------
# Load analyzer module dynamically
# -----------------------------
spec = importlib.util.spec_from_file_location("daf_scc_module", DAF_SCC_PATH)
daf_scc_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(daf_scc_module)

extract_regex_reward_features = daf_scc_module.extract_regex_reward_features

# -----------------------------
# results[model][prompt] = stats
# -----------------------------
results = defaultdict(lambda: defaultdict(lambda: {
    "total": 0,
    "success": 0,
    "success_round1": 0,
    "failure": 0,
    "success_with_recursion": 0,
    "success_without_recursion": 0
}))

def find_files_with_ext(folder_path, ext):
    if not os.path.exists(folder_path):
        return []
    return [
        os.path.join(folder_path, f)
        for f in os.listdir(folder_path)
        if f.endswith(ext)
    ]

def check_attempt_success(attempt_path):
    """Success = any .dll present"""
    dlls = find_files_with_ext(attempt_path, ".dll")
    return len(dlls) > 0

def get_dfy_file(attempt_path):
    """Return one .dfy file if present, else None"""
    dfys = find_files_with_ext(attempt_path, ".dfy")
    if not dfys:
        return None
    if len(dfys) > 1:
        print(f"[WARN] Multiple .dfy files in {attempt_path}, using: {dfys[0]}")
    return dfys[0]

for problem_folder in os.listdir(BASE_DIR):
    problem_path = os.path.join(BASE_DIR, problem_folder)
    if not os.path.isdir(problem_path):
        continue

    for run_folder, model_name in MODEL_MAP.items():
        run_path = os.path.join(problem_path, run_folder, "llm_only")
        if not os.path.exists(run_path):
            continue

        for prompt in PROMPT_TYPES:
            prompt_path = os.path.join(run_path, prompt)
            if not os.path.exists(prompt_path):
                continue

            results[model_name][prompt]["total"] += 1

            success = False
            success_round1 = False
            recursive_success = False

            # Check attempts 0 → 6
            for i in range(7):
                attempt_path = os.path.join(prompt_path, f"attempt_{i}")

                if check_attempt_success(attempt_path):
                    success = True
                    if i == 0:
                        success_round1 = True

                    # Find .dfy and analyze recursion
                    dfy_file = get_dfy_file(attempt_path)
                    if dfy_file is None:
                        print(f"[WARN] Success .dll found but no .dfy in {attempt_path}")
                    else:
                        try:
                            features = extract_regex_reward_features(dfy_file)
                            if features.get("recursion_count", 0) > 0:
                                recursive_success = True
                        except Exception as e:
                            print(f"[WARN] Analyzer failed on {dfy_file}: {e}")

                    break  # stop at first successful attempt

            if success:
                results[model_name][prompt]["success"] += 1
                if success_round1:
                    results[model_name][prompt]["success_round1"] += 1

                if recursive_success:
                    results[model_name][prompt]["success_with_recursion"] += 1
                else:
                    results[model_name][prompt]["success_without_recursion"] += 1
            else:
                results[model_name][prompt]["failure"] += 1

# -----------------------------
# Pretty print
# -----------------------------
print("\n===== FINAL RESULTS =====\n")

for model in sorted(results.keys()):
    print(f"Model: {model}")
    for prompt in PROMPT_TYPES:
        if prompt not in results[model]:
            continue

        stats = results[model][prompt]
        print(f"  Prompt: {prompt}")
        print(f"    Total: {stats['total']}")
        print(f"    Success: {stats['success']}")
        print(f"    Success (Round 1): {stats['success_round1']}")
        print(f"    Failure: {stats['failure']}")
        print(f"    Successful files with recursion: {stats['success_with_recursion']}")
        print(f"    Successful files without recursion: {stats['success_without_recursion']}")

        if stats["success"] > 0:
            pct_recursive = 100 * stats["success_with_recursion"] / stats["success"]
            print(f"    % of successful files that are recursive: {pct_recursive:.2f}%")
    print()
print("\n===== OVERALL RECURSION SUMMARY =====\n")
for model in sorted(results.keys()):
    total_success = 0
    total_recursive = 0
    for prompt in PROMPT_TYPES:
        if prompt not in results[model]:
            continue
        total_success += results[model][prompt]["success"]
        total_recursive += results[model][prompt]["success_with_recursion"]

    print(f"{model}:")
    print(f"  Total successful files: {total_success}")
    print(f"  Successful recursive files: {total_recursive}")
    if total_success > 0:
        print(f"  Recursive among successful: {100*total_recursive/total_success:.2f}%")
    print()


import os
import re
import json
import tempfile
import importlib.util
from collections import defaultdict

# -----------------------------
# Multiple result directories
# -----------------------------
RESULTS_DIRS = {
    "baseline_untranied": "/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_cleaned",
    "trained_outputs": "/u/mjha1/Proof2Silicon/journal_phase/trained_outputs copy",
    # "trained_lora_old": "/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_trained_loraO",
    # "trained_lora_5": "/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_trained_lora",
    # "trained_lora7": "/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_trained_lora7",
    # "trained_lora_chk5": "/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_trained_lora_chk",
    # "trained_lora_chk7": "/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_trained_lora_chk7",
    # "trained_lora_chkaandlora5": "/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_trained_lora_chklora",
    # "trained_lora_chkaandlora7": "/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_trained_lora_chklora7",
    # add more here
}

DAF_SCC_PATH = "/u/mjha1/Proof2Silicon/journal_phase/CODEBASE/preface_rl/Dafny_SCC.py"

# -----------------------------
# Load analyzer module dynamically
# -----------------------------
spec = importlib.util.spec_from_file_location("daf_scc_module", DAF_SCC_PATH)
daf_scc_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(daf_scc_module)

extract_regex_reward_features = daf_scc_module.extract_regex_reward_features

filename_pattern = re.compile(
    r"^result_(.+?)_llm-(.+?)_pass@1_with_feedback\.json$"
)


def analyze_code_for_recursion(code_str, temp_prefix="tmp_dafny_"):
    if not code_str or not code_str.strip():
        return False

    temp_path = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            suffix=".dfy",
            prefix=temp_prefix,
            delete=False,
            encoding="utf-8"
        ) as tmp:
            temp_path = tmp.name
            tmp.write(code_str)

        features = extract_regex_reward_features(temp_path)
        return features.get("recursion_count", 0) > 0

    except Exception as e:
        print(f"[WARN] Recursion analysis failed: {e}")
        return False

    finally:
        if temp_path and os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except Exception:
                pass


def init_stats():
    return {
        "total": 0,
        "success_round1": 0,
        "success_other": 0,
        "failure": 0,
        "success_recursive": 0,
        "success_non_recursive": 0
    }


def analyze_results_dir(results_dir):
    results = defaultdict(init_stats)

    if not os.path.exists(results_dir):
        print(f"[WARN] Directory does not exist: {results_dir}")
        return results

    for fname in os.listdir(results_dir):
        if not fname.endswith(".json"):
            continue

        match = filename_pattern.match(fname)
        if not match:
            continue

        problem_name, model_name = match.groups()
        file_path = os.path.join(results_dir, fname)

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception as e:
            print(f"Could not read {fname}: {e}")
            continue

        attempts = data.get("attempts", [])
        results[model_name]["total"] += 1

        round1_success = False
        any_success = False
        recursive_success = False

        for att in attempts:
            attempt_num = att.get("attempt")
            success = att.get("success", 0)

            if success == 1:
                any_success = True

                if attempt_num == 1:
                    round1_success = True

                code_str = att.get("code", "")
                recursive_success = analyze_code_for_recursion(
                    code_str,
                    temp_prefix=f"{model_name}_{problem_name}_"
                )
                break

        if round1_success:
            results[model_name]["success_round1"] += 1
            if recursive_success:
                results[model_name]["success_recursive"] += 1
            else:
                results[model_name]["success_non_recursive"] += 1

        elif any_success:
            results[model_name]["success_other"] += 1
            if recursive_success:
                results[model_name]["success_recursive"] += 1
            else:
                results[model_name]["success_non_recursive"] += 1

        else:
            results[model_name]["failure"] += 1

    return results


def print_report(run_name, results_dir, results):
    print("\n" + "=" * 80)
    print(f"RESULTS DIR: {run_name}")
    print(f"PATH       : {results_dir}")
    print("=" * 80)

    for model_name, stats in sorted(results.items()):
        total = stats["total"]
        r1 = stats["success_round1"]
        other = stats["success_other"]
        fail = stats["failure"]
        succ = r1 + other
        rec = stats["success_recursive"]
        nonrec = stats["success_non_recursive"]

        print(f"\nModel: {model_name}")
        print(f"  Problems run              : {total}")
        print(f"  Success in round 1        : {r1}")
        print(f"  Success otherwise         : {other}")
        print(f"  Failure                   : {fail}")
        print(f"  Successful recursive      : {rec}")
        print(f"  Successful non-recursive  : {nonrec}")

        if total > 0:
            print(f"  Round-1 success %         : {100*r1/total:.2f}%")
            print(f"  Overall success %         : {100*succ/total:.2f}%")
            print(f"  Failure %                 : {100*fail/total:.2f}%")

        if succ > 0:
            print(f"  Recursive among success % : {100*rec/succ:.2f}%")
            print(f"  Non-recursive success %   : {100*nonrec/succ:.2f}%")


# -----------------------------
# Run all result directories
# -----------------------------
all_results = {}

for run_name, results_dir in RESULTS_DIRS.items():
    results = analyze_results_dir(results_dir)
    all_results[run_name] = results
    print_report(run_name, results_dir, results)