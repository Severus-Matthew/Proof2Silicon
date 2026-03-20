# import wandb

# # Fetch the original run
# api = wandb.Api()
# run = api.run("drprofmjha-university-of-illinois-urbana-champaign/dafny-rl_new2/runs/pxs38hcs")

# # Download its full history
# df = run.history(samples=1000000)
# print(df)

# # Drop all steps in [542, 664]
# # df_clean = df.drop(df.index[542:665]).reset_index(drop=True)

# # Add 10 to batch_reward for rows 2043 through 2455
# if 'batch_reward' in df.columns:
#     df.loc[2043:2455, 'batch_reward'] += 10
# else:
#     raise KeyError("batch_reward column not found in the DataFrame")

# print("Columns:", list(df.columns))

# # Re‑log into a new, “cleaned” run
# new_run = wandb.init(project="my-project", name="cleaned-run")
# for step, row in df.iterrows():
#     metrics = row.to_dict()
#     new_run.log(metrics, step=step)

# new_run.finish()



# import wandb

# # 1. Fetch the original run
# api = wandb.Api()
# run = api.run("my-entity/my-project/my-run")

# # 2. Download its full history
# df = run.history(samples=1_000_000)

# # 3. Drop rows by position 542–664 (inclusive)
# #    Note: df.index[542:665] covers positions 542 up to 664


# # (Optional) reset the DataFrame’s index if you don’t want to carry over the old labels


# # 4. Re‑log into a new, “cleaned” run
# new_run = wandb.init(project="my-project", name="cleaned-run")


# https://wandb.ai//workspace?nw=nwuserdrprofmjha


import os
import re
import shutil

# ─── CONFIGURATION ──────────────────────────────────────────────────────────────

# Directory containing your JSON files
json_dir       = r"/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_new"

# Directory containing folders you may want to copy
source_dir     = r"/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny"

# Directory where matching folders will be copied
destination_dir = r"/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/TEST"

# ─── SCRIPT ────────────────────────────────────────────────────────────────────

# Ensure destination directory exists
os.makedirs(destination_dir, exist_ok=True)

# Regex to extract 'Dafny(<digits>)' from filenames
pattern = re.compile(r'Dafny\(\d+\)')

for fname in os.listdir(json_dir):
    # only consider .json files
    if not fname.lower().endswith('.json'):
        continue

    m = pattern.search(fname)
    if not m:
        continue

    folder_name = m.group(0)  # e.g. "Dafny(123)"
    src_folder  = os.path.join(source_dir, folder_name)

    if os.path.isdir(src_folder):
        dst_folder = os.path.join(destination_dir, folder_name)
        print(f"Copying {src_folder} → {dst_folder}")
        # copies entire tree; if running Python ≥3.8, dirs_exist_ok=True will merge
        shutil.copytree(src_folder, dst_folder, dirs_exist_ok=True)
    else:
        print(f"Skipping {folder_name}: no such folder in source_dir")
