# import os
# import shutil

# def copy_files_from_subfolders(src_dir, dest_dir):
#     """
#     Copies files from immediate subfolders of src_dir into dest_dir,
#     preserving the subfolder structure.
#     Ignores any deeper nested directories.
#     """

#     # Create destination directory if it doesn't exist
#     os.makedirs(dest_dir, exist_ok=True)

#     # Iterate over immediate subdirectories
#     for subfolder in os.listdir(src_dir):
#         subfolder_path = os.path.join(src_dir, subfolder)

#         if os.path.isdir(subfolder_path):
#             # Create corresponding subfolder in destination
#             dest_subfolder = os.path.join(dest_dir, subfolder)
#             os.makedirs(dest_subfolder, exist_ok=True)

#             # Copy only files directly inside this subfolder
#             for item in os.listdir(subfolder_path):
#                 item_path = os.path.join(subfolder_path, item)

#                 if os.path.isfile(item_path):
#                     dest_path = os.path.join(dest_subfolder, item)

#                     # Handle duplicate filenames inside subfolder
#                     if os.path.exists(dest_path):
#                         base, ext = os.path.splitext(item)
#                         counter = 1
#                         while os.path.exists(dest_path):
#                             new_name = f"{base}_{counter}{ext}"
#                             dest_path = os.path.join(dest_subfolder, new_name)
#                             counter += 1

#                     shutil.copy2(item_path, dest_path)
#                     print(f"Copied: {item_path} -> {dest_path}")

#     print("\n✅ Done copying files!")


# # Example usage
# src_directory = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny"
# dest_directory = "/mnt/shared/gpfs/home/manvij2/Proof2Silicon/journal_phase/CODEBASE/Input_dataset"

# copy_files_from_subfolders(src_directory, dest_directory)



import os
import shutil
import random

def copy_random_subfolders(src_dir, dest_dir, num_subfolders=111, seed=42):
    # Create destination folder if it does not exist
    os.makedirs(dest_dir, exist_ok=True)

    # Get only immediate subfolders
    subfolders = [
        f for f in os.listdir(src_dir)
        if os.path.isdir(os.path.join(src_dir, f))
    ]

    print(f"Found {len(subfolders)} subfolders in source.")

    if len(subfolders) < num_subfolders:
        raise ValueError(
            f"Only {len(subfolders)} subfolders found, but {num_subfolders} requested."
        )

    # Set seed for reproducibility
    random.seed(seed)

    # Randomly choose subfolders
    selected = random.sample(subfolders, num_subfolders)

    # Copy selected subfolders
    for folder in selected:
        src_path = os.path.join(src_dir, folder)
        dest_path = os.path.join(dest_dir, folder)

        shutil.copytree(src_path, dest_path)
        print(f"Copied: {folder}")

    print(f"\nDone. Copied {num_subfolders} subfolders to: {dest_dir}")


# Example usage
src_dir = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset"
dest_dir = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset_2"

copy_random_subfolders(src_dir, dest_dir, num_subfolders=111, seed=42)