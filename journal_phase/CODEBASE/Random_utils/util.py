# import os
# import shutil
# from pathlib import Path

# SRC_ROOT = Path("/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_trained_lora_chklora7")
# DST_ROOT = Path("/u/mjha1/Proof2Silicon/journal_phase/trained_outputs")

# KEYWORDS = ["gpt-5.1"]

# def should_copy(path: Path) -> bool:
#     name = path.name.lower()
#     return any(k.lower() in name for k in KEYWORDS)

# def copy_matching_files(src_root: Path, dst_root: Path):
#     copied = 0

#     for root, dirs, files in os.walk(src_root):
#         root_path = Path(root)

#         for fname in files:
#             src_file = root_path / fname

#             if should_copy(src_file):
#                 rel_path = src_file.relative_to(src_root)
#                 dst_file = dst_root / rel_path

#                 dst_file.parent.mkdir(parents=True, exist_ok=True)
#                 shutil.copy2(src_file, dst_file)

#                 copied += 1
#                 print(f"Copied: {rel_path}")

#     print(f"\nDone. Copied {copied} files to {dst_root}")

# if __name__ == "__main__":
#     copy_matching_files(SRC_ROOT, DST_ROOT)
#-------------------------------------------------------------------------------------------------------

import os
import re
import json
import shutil
import tempfile
import importlib.util
from pathlib import Path

# -----------------------------
# CHANGE THESE
# -----------------------------
FOLDER1 = Path("/u/mjha1/Proof2Silicon/journal_phase/trained_outputs copy")
FOLDER2 = Path("/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_trained_loraO")

DAF_SCC_PATH = "/u/mjha1/Proof2Silicon/journal_phase/CODEBASE/preface_rl/Dafny_SCC.py"

DRY_RUN = False   # first run True, then set False

filename_pattern = re.compile(
    r"^result_(.+?)_llm-gpt-5\.1-(.+?)_pass@1_with_feedback\.json$"
)

# -----------------------------
# Load your recursion analyzer
# -----------------------------
spec = importlib.util.spec_from_file_location("daf_scc_module", DAF_SCC_PATH)
daf_scc_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(daf_scc_module)

extract_regex_reward_features = daf_scc_module.extract_regex_reward_features


def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def find_success_subobject(obj):
    if isinstance(obj, dict):
        if obj.get("success") == 1:
            return obj

        for v in obj.values():
            found = find_success_subobject(v)
            if found is not None:
                return found

    elif isinstance(obj, list):
        for item in obj:
            found = find_success_subobject(item)
            if found is not None:
                return found

    return None


def get_success_code(json_path):
    data = load_json(json_path)
    success_obj = find_success_subobject(data)

    if success_obj is None:
        return None

    return success_obj.get("code") or success_obj.get("final_code")


def has_success(json_path):
    try:
        data = load_json(json_path)
        return find_success_subobject(data) is not None
    except Exception:
        return False


def collect_gpt53_jsons(root):
    """
    returns:
      result[problem_name] = path
    where problem_name is e.g. Dafny(193)
    """
    result = {}

    for dirpath, _, filenames in os.walk(root):
        for fname in filenames:
            m = filename_pattern.match(fname)
            if not m:
                continue

            problem_name, model_suffix = m.groups()
            path = Path(dirpath) / fname

            if problem_name not in result:
                result[problem_name] = path
            else:
                # prefer successful JSON if duplicate exists
                if has_success(path) and not has_success(result[problem_name]):
                    result[problem_name] = path

    return result


def is_recursive_using_your_file(code):
    """
    Writes successful code to a temp .dfy file,
    calls your extract_regex_reward_features(),
    and checks recursion_count.
    """
    with tempfile.NamedTemporaryFile(
        mode="w",
        suffix=".dfy",
        delete=False,
        encoding="utf-8"
    ) as tmp:
        tmp.write(code)
        tmp_path = tmp.name

    try:
        features = extract_regex_reward_features(tmp_path)
        return features.get("recursion_count", 0) > 0, features
    finally:
        try:
            os.remove(tmp_path)
        except OSError:
            pass


def is_associated_gpt53_file(path, problem_name):
    """
    Copy any file associated with same Dafny case and gpt-5.3.
    This includes JSON, PDB, DLL, DFY, deps.json, TXT, CS, props, targets,
    and files inside obj folders.
    """
    path_str = str(path)

    if problem_name not in path_str:
        return False

    if "gpt-5.1" not in path_str:
        return False

    if "obj" in path.parts:
        return True

    allowed_exts = {
        ".json", ".pdb", ".dll", ".dfy", ".txt",
        ".cs", ".props", ".targets"
    }

    if path.suffix in allowed_exts:
        return True

    if path.name == "deps.json":
        return True

    return False


def copy_associated_files(problem_name):
    copied = 0

    for dirpath, _, filenames in os.walk(FOLDER2):
        for fname in filenames:
            src = Path(dirpath) / fname

            if not is_associated_gpt53_file(src, problem_name):
                continue

            rel = src.relative_to(FOLDER2)
            dst = FOLDER1 / rel

            print(f"    COPY: {rel}")

            if not DRY_RUN:
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)

            copied += 1

    return copied


def main():
    folder1_jsons = collect_gpt53_jsons(FOLDER1)
    folder2_jsons = collect_gpt53_jsons(FOLDER2)

    print(f"Folder1 GPT-5.3 JSONs: {len(folder1_jsons)}")
    print(f"Folder2 GPT-5.3 JSONs: {len(folder2_jsons)}")
    print(f"DRY_RUN = {DRY_RUN}")
    print("=" * 80)

    copied_cases = []
    skipped_recursive = []
    skipped_no_success = []
    skipped_already_success_folder1 = []
    skipped_no_code = []

    for problem_name, folder2_json in sorted(folder2_jsons.items()):
        if not has_success(folder2_json):
            skipped_no_success.append(problem_name)
            continue

        folder1_json = folder1_jsons.get(problem_name)

        if folder1_json is not None and has_success(folder1_json):
            skipped_already_success_folder1.append(problem_name)
            continue

        code = get_success_code(folder2_json)

        if not code:
            skipped_no_code.append(problem_name)
            print(f"[SKIP no code] {problem_name}")
            continue

        is_recursive, features = is_recursive_using_your_file(code)

        if is_recursive:
            skipped_recursive.append(problem_name)
            print(f"[SKIP recursive] {problem_name} | features={features}")
            continue

        print(f"\n[COPY non-recursive success] {problem_name}")
        print(f"  folder2 json: {folder2_json}")
        print(f"  folder1 json: {folder1_json if folder1_json else 'MISSING'}")
        print(f"  features: {features}")

        num_copied = copy_associated_files(problem_name)
        copied_cases.append((problem_name, num_copied))

    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print(f"Copied cases: {len(copied_cases)}")
    print(f"Skipped recursive: {len(skipped_recursive)}")
    print(f"Skipped folder2 no success: {len(skipped_no_success)}")
    print(f"Skipped folder1 already success: {len(skipped_already_success_folder1)}")
    print(f"Skipped no code: {len(skipped_no_code)}")

    for problem_name, n in copied_cases:
        print(f"  copied {problem_name}: {n} files")

    if DRY_RUN:
        print("\nDry run only. Set DRY_RUN = False to actually copy/replace files.")


if __name__ == "__main__":
    main()

# import shutil
# from pathlib import Path

# ROOT = Path("/u/mjha1/Proof2Silicon/journal_phase/Input_dataset_3")

# MODEL_KIND = "baseline_runs_v2/llm_only"

# SOURCE_PROMPT = "fewshot"
# TARGET_PROMPT = "shortanddetailed"

# CHECK_ATTEMPT = "attempt_6"
# DRY_RUN = False  # set False after checking


# def has_dll(folder: Path) -> bool:
#     return folder.exists() and any(
#         p.is_file() and p.suffix == ".dll"
#         for p in folder.rglob("*")
#     )


# def copy_folder_contents(src: Path, dst: Path):
#     copied = 0
#     dst.mkdir(parents=True, exist_ok=True)

#     for item in src.iterdir():
#         dst_item = dst / item.name

#         print(f"    COPY: {item} -> {dst_item}")

#         if not DRY_RUN:
#             if item.is_dir():
#                 if dst_item.exists():
#                     shutil.rmtree(dst_item)   # remove old dir first
#                 shutil.copytree(item, dst_item)
#             else:
#                 dst_item.parent.mkdir(parents=True, exist_ok=True)
#                 shutil.copy2(item, dst_item)

#         copied += 1

#     return copied


# def main():
#     copied_cases = []

#     for case_dir in sorted(ROOT.glob("Dafny(*)")):
#         model_dir = case_dir / MODEL_KIND

#         src_prompt = model_dir / SOURCE_PROMPT
#         dst_prompt = model_dir / TARGET_PROMPT

#         src_attempt6 = src_prompt / CHECK_ATTEMPT
#         dst_attempt6 = dst_prompt / CHECK_ATTEMPT

#         if not src_attempt6.exists():
#             continue

#         # Source short/attempt_6 must NOT have dll
#         if has_dll(src_attempt6):
#             continue

#         # Target fewshot is eligible if:
#         # 1. fewshot/attempt_6 does not exist, OR
#         # 2. fewshot/attempt_6 has a dll
#         target_missing_attempt6 = not dst_attempt6.exists()
#         target_has_dll = has_dll(dst_attempt6)

#         if not (target_missing_attempt6 or target_has_dll):
#             continue

#         if not src_prompt.exists():
#             continue

#         print(f"\n[COPY CASE] {case_dir.name}")
#         print(f"  model: {MODEL_KIND}")
#         print(f"  source: {src_prompt}")
#         print(f"  target: {dst_prompt}")

#         if target_missing_attempt6:
#             print("  reason: target fewshot/attempt_6 missing")
#         else:
#             print("  reason: target fewshot/attempt_6 has .dll")

#         copied = copy_folder_contents(src_prompt, dst_prompt)
#         copied_cases.append((case_dir.name, copied))

#     print("\nSUMMARY")
#     print(f"Copied cases: {len(copied_cases)}")

#     for case, n in copied_cases:
#         print(f"  {case}: copied {n} items")

#     if DRY_RUN:
#         print("\nDry run only. Set DRY_RUN = False to actually copy.")


# if __name__ == "__main__":
#     main()