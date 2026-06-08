# # import os
# # import shutil

# # def copy_files_from_subfolders(src_dir, dest_dir):
# #     """
# #     Copies files from immediate subfolders of src_dir into dest_dir,
# #     preserving the subfolder structure.
# #     Ignores any deeper nested directories.
# #     """

# #     # Create destination directory if it doesn't exist
# #     os.makedirs(dest_dir, exist_ok=True)

# #     # Iterate over immediate subdirectories
# #     for subfolder in os.listdir(src_dir):
# #         subfolder_path = os.path.join(src_dir, subfolder)

# #         if os.path.isdir(subfolder_path):
# #             # Create corresponding subfolder in destination
# #             dest_subfolder = os.path.join(dest_dir, subfolder)
# #             os.makedirs(dest_subfolder, exist_ok=True)

# #             # Copy only files directly inside this subfolder
# #             for item in os.listdir(subfolder_path):
# #                 item_path = os.path.join(subfolder_path, item)

# #                 if os.path.isfile(item_path):
# #                     dest_path = os.path.join(dest_subfolder, item)

# #                     # Handle duplicate filenames inside subfolder
# #                     if os.path.exists(dest_path):
# #                         base, ext = os.path.splitext(item)
# #                         counter = 1
# #                         while os.path.exists(dest_path):
# #                             new_name = f"{base}_{counter}{ext}"
# #                             dest_path = os.path.join(dest_subfolder, new_name)
# #                             counter += 1

# #                     shutil.copy2(item_path, dest_path)
# #                     print(f"Copied: {item_path} -> {dest_path}")

# #     print("\n✅ Done copying files!")


# # # Example usage
# # src_directory = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny"
# # dest_directory = "/mnt/shared/gpfs/home/manvij2/Proof2Silicon/journal_phase/CODEBASE/Input_dataset"

# # copy_files_from_subfolders(src_directory, dest_directory)



# import os
# import shutil
# import random

# def copy_random_subfolders(src_dir, dest_dir, num_subfolders=111, seed=42):
#     # Create destination folder if it does not exist
#     os.makedirs(dest_dir, exist_ok=True)

#     # Get only immediate subfolders
#     subfolders = [
#         f for f in os.listdir(src_dir)
#         if os.path.isdir(os.path.join(src_dir, f))
#     ]

#     print(f"Found {len(subfolders)} subfolders in source.")

#     if len(subfolders) < num_subfolders:
#         raise ValueError(
#             f"Only {len(subfolders)} subfolders found, but {num_subfolders} requested."
#         )

#     # Set seed for reproducibility
#     random.seed(seed)

#     # Randomly choose subfolders
#     selected = random.sample(subfolders, num_subfolders)

#     # Copy selected subfolders
#     for folder in selected:
#         src_path = os.path.join(src_dir, folder)
#         dest_path = os.path.join(dest_dir, folder)

#         shutil.copytree(src_path, dest_path)
#         print(f"Copied: {folder}")

#     print(f"\nDone. Copied {num_subfolders} subfolders to: {dest_dir}")


# # Example usage
# src_dir = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset"
# dest_dir = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset_2"

# copy_random_subfolders(src_dir, dest_dir, num_subfolders=111, seed=42)


# import os
# import shutil
# import random

# def copy_new_random_subfolders(src_dir, existing_dir, dest_dir, num_subfolders=100, seed=42):
#     os.makedirs(dest_dir, exist_ok=True)

#     # All subfolders in source
#     src_subfolders = {
#         f for f in os.listdir(src_dir)
#         if os.path.isdir(os.path.join(src_dir, f))
#     }

#     # Already used subfolders
#     existing_subfolders = {
#         f for f in os.listdir(existing_dir)
#         if os.path.isdir(os.path.join(existing_dir, f))
#     }

#     # Get remaining subfolders
#     remaining = list(src_subfolders - existing_subfolders)

#     print(f"Total source: {len(src_subfolders)}")
#     print(f"Already used: {len(existing_subfolders)}")
#     print(f"Remaining: {len(remaining)}")

#     if len(remaining) < num_subfolders:
#         raise ValueError(
#             f"Only {len(remaining)} remaining, but {num_subfolders} requested."
#         )

#     random.seed(seed)
#     selected = random.sample(remaining, num_subfolders)

#     # Copy
#     for folder in selected:
#         src_path = os.path.join(src_dir, folder)
#         dest_path = os.path.join(dest_dir, folder)

#         shutil.copytree(src_path, dest_path)
#         print(f"Copied: {folder}")

#     print(f"\nDone. Copied {num_subfolders} new subfolders to: {dest_dir}")


# # Paths
# src_dir = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset"
# existing_dir = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset_2"
# dest_dir = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset_3"

# copy_new_random_subfolders(src_dir, existing_dir, dest_dir, num_subfolders=100, seed=42)

from preface_rl.slm import initialize_slm, SLMPG
import torch
import os

CHECKPOINT_PATH = "/u/mjha1/Proof2Silicon/journal_phase/checkpoints_4/run_CHK/final_model_new.pt"
LORA_SAVE_PATH = "/u/mjha1/Proof2Silicon/journal_phase/checkpoints_4/run_CHK/final_adapter"

model, tokenizer = initialize_slm(None)
slm_pg = SLMPG(model)

checkpoint = torch.load(CHECKPOINT_PATH, map_location="cuda")
slm_pg.load_state_dict(checkpoint["model_state_dict"], strict=False)

os.makedirs(LORA_SAVE_PATH, exist_ok=True)

# Save only PEFT/LoRA adapter
slm_pg.model.save_pretrained(LORA_SAVE_PATH)
tokenizer.save_pretrained(LORA_SAVE_PATH)

print("Saved LoRA adapter to:", LORA_SAVE_PATH)