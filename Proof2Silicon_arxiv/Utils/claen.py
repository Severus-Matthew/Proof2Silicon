# import os
# import shutil

# # Replace with your main directory path
# main_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny"

# for folder_name in os.listdir(main_dir):
#     folder_path = os.path.join(main_dir, folder_name)
#     if os.path.isdir(folder_path):
#         dfy_file = f"{folder_name}.dfy"
#         desc_file = "detailed_description.txt"
#         one_line_desc_file = "one_line_description.txt"
#         experiments_path = os.path.join(folder_path, "experiments")
        
#         # Create the experiments folder if it doesn't exist
#         os.makedirs(experiments_path, exist_ok=True)

#         for file_name in os.listdir(folder_path):
#             file_path = os.path.join(folder_path, file_name)
            
#             # Skip if it's a directory or one of the files to keep
#             if os.path.isdir(file_path) or file_name in [dfy_file, desc_file, one_line_desc_file]:
#                 continue

#             # Move other files to experiments/
#             shutil.move(file_path, os.path.join(experiments_path, file_name))


# print("Done organizing files.")



import os
import shutil

# Replace this with your base directory containing the 'epoch*' folders
base_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset"
training_dir = os.path.join(base_dir, "Training")

# Create the Training folder if it doesn't exist
os.makedirs(training_dir, exist_ok=True)

# Loop through items in the base directory
for item in os.listdir(base_dir):
    item_path = os.path.join(base_dir, item)
    
    # Check if it's a directory and starts with 'epoch'
    if os.path.isdir(item_path) and item.startswith("epoch"):
        # Move to Training/
        shutil.move(item_path, os.path.join(training_dir, item))

print("All 'epoch*' folders moved to Training/")
