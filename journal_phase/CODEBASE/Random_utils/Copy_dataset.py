import os
import shutil

def copy_files_from_subfolders(src_dir, dest_dir):
    """
    Copies files from immediate subfolders of src_dir into dest_dir.
    Ignores any deeper nested directories.
    """

    # Create destination directory if it doesn't exist
    os.makedirs(dest_dir, exist_ok=True)

    # Iterate over immediate subdirectories
    for subfolder in os.listdir(src_dir):
        subfolder_path = os.path.join(src_dir, subfolder)

        if os.path.isdir(subfolder_path):
            # Only look at files directly inside this subfolder
            for item in os.listdir(subfolder_path):
                item_path = os.path.join(subfolder_path, item)

                if os.path.isfile(item_path):
                    dest_path = os.path.join(dest_dir, item)

                    # Handle duplicate filenames
                    if os.path.exists(dest_path):
                        base, ext = os.path.splitext(item)
                        counter = 1
                        while os.path.exists(dest_path):
                            new_name = f"{base}_{counter}{ext}"
                            dest_path = os.path.join(dest_dir, new_name)
                            counter += 1

                    shutil.copy2(item_path, dest_path)
                    print(f"Copied: {item_path} -> {dest_path}")

    print("\n✅ Done copying files!")


# Example usage
src_directory = "/u/mjha1/Proof2Silicon/UIUC_PROJ_2/dataset/Dafny"
dest_directory = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset"

copy_files_from_subfolders(src_directory, dest_directory)