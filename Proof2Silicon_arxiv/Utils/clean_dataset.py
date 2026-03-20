# import os

# def remove_no_hints_dafny_files(folder_path):
#     """
#     Removes '_no_hints.dfy' files from the given folder if a corresponding '.dfy' file exists.

#     :param folder_path: Path to the folder containing the files
#     """
#     try:
#         # Get the list of all files in the folder
#         files = os.listdir(folder_path)
        
#         # Create a set of base filenames for '.dfy' files (excluding '_no_hints.dfy')
#         base_files = {
#             os.path.splitext(file)[0] for file in files if file.endswith('.dfy') and not file.endswith('_no_hints.dfy')
#         }
        
#         # Iterate through the files
#         for file in files:
#             # Check if the file ends with '_no_hints.dfy'
#             if file.endswith('_no_hints.dfy'):
#                 # Extract the base filename (without '_no_hints.dfy')
#                 base_filename = file.replace('_no_hints.dfy', '')
#                 # Check if the corresponding base file exists
#                 if base_filename in base_files:
#                     # Get the full path of the file
#                     file_path = os.path.join(folder_path, file)
#                     # Delete the file
#                     os.remove(file_path)
#                     print(f"Removed: {file}")
#         print("All matching '_no_hints.dfy' files have been removed.")
#     except Exception as e:
#         print(f"An error occurred: {e}")

# # Example usage
# folder_path = input("Enter the path to the folder: ").strip()
# remove_no_hints_dafny_files(folder_path)

import os

def rename_dafny_files(base_folder):
    for subdir, _, files in os.walk(base_folder):
        # Skip the base folder itself
        if subdir == base_folder:
            continue

        # Get the name of the subfolder
        print(subdir)
        subfolder_name = os.path.basename(subdir)
        subfolder_name2 = subfolder_name.replace(" ", "")

        # Look for Dafny files in the subfolder
        old_file_path = os.path.join(base_folder, subfolder_name)
        print(old_file_path)
        # file2 = file.replace(" ", "")
        new_file_path = os.path.join(base_folder, subfolder_name2)
        print(new_file_path)

                # Rename the Dafny file
        os.rename(old_file_path, new_file_path)
        print(f"Renamed: {old_file_path} -> {new_file_path}")
rename_dafny_files("D:\\UIUC_PROJ_2\\dataset\\Dafny")