import os

def count_files_with_gemini2flash(directory):
    """
    Counts the number of directories (out of a total) that contain 
    at least one file meeting specific criteria:
      - The filename contains "chatgpt4_0.25"
      - The filename ends with ".dfy"
      - The filename starts with "generated"
      
    Parameters:
        directory (str): The path to the directory to traverse.
        
    Returns:
        tuple: (count of directories with at least one matching file, total directory count)
    """
    matching_dir_count = 0
    total_dirs = 0
    count = 0

    # Walk through all directories and subdirectories
    for root, dirs, files in os.walk(directory):
        total_dirs += 1
        
        # Initialize flag for current directory
        found_flag = 0  
        
        for file in files:
            if ("gemini2flash_0.25" in file and 
                file.endswith(".dfy") and 
                file.startswith("generated")):
                found_flag = 1
                count+=1
                # Since we only need to count one matching file per directory
        
        if found_flag == 1:
            matching_dir_count += 1

    return matching_dir_count, total_dirs, count

# Replace with the path to the directory you want to search
directory_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/gemini2flash'
file_count, total_dirs, count = count_files_with_gemini2flash(directory_path)
print(f"Number of directories with matching files: {file_count} out of {total_dirs}")
print(f"Number of files with 'gemini2flash' in the name: {count}")


# import os

# def count_folders(directory):
#     """
#     Counts the number of folders (directories) inside the specified directory.

#     Parameters:
#         directory (str): The path to the directory to be scanned.

#     Returns:
#         int: The count of folder directories found in the specified directory.
#     """
#     folder_count = 0
#     try:
#         # Iterate over all items in the given directory
#         for item in os.listdir(directory):
#             # Construct full path
#             full_path = os.path.join(directory, item)
#             # Check if the item is a directory
#             if os.path.isdir(full_path):
#                 folder_count += 1
#     except FileNotFoundError:
#         print("Error: The specified directory does not exist.")
#     except PermissionError:
#         print("Error: Permission denied to access one or more parts of the directory.")
    
#     return folder_count

# # Example usage:
# # You can change '.' to any valid directory path.
# directory_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/CHATGPT4'
# print(f"Number of folders in '{directory_path}':", count_folders(directory_path))

