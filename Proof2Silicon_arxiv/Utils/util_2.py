# # import os

# # def fix_dfy_file(file_path):
# #     try:
# #         with open(file_path, 'r') as file:
# #             content = file.read()
        
# #         # Replace all occurrences of '\n' with actual new lines
# #         fixed_content = content.replace(r'\n', '\n')

# #         # Overwrite the original file with the fixed content
# #         with open(file_path, 'w') as file:
# #             file.write(fixed_content)

# #         print(f"Fixed file: {file_path}")
    
# #     except Exception as e:
# #         print(f"An error occurred while processing {file_path}: {e}")

# # def fix_all_dfy_files_in_folder(main_folder_path):
# #     # Traverse the directory tree
# #     for root, dirs, files in os.walk(main_folder_path):
# #         for file_name in files:
# #             if file_name.endswith(".dfy"):
# #                 file_path = os.path.join(root, file_name)
# #                 fix_dfy_file(file_path)

# # # Usage Example
# # main_folder_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/CHATGPTo1'  # Replace with your main folder path
# # fix_all_dfy_files_in_folder(main_folder_path)


# import os

# def run_Dafny(dafny_code_path, err_path):
#     """
#     Run Dafny code using the specified paths for temporary and error files.
#     """
#     # with open(tmp_path, "w", encoding='utf-8') as file:
#     #     file.write(dafny_code)
    
#     # Change directory to where Dafny executable is located
#     dafny_directory = r"/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
#     os.chdir(dafny_directory)
    
#     # Execute Dafny command and redirect output to a temporary file
#     dafny_command = f"/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny '{dafny_code_path}' > '{err_path}'"
#     os.system(dafny_command)

#     # Read the contents of the temporary output file
#     with open(err_path, "r", encoding='utf-8') as output_file:
#         output = output_file.read()
        
#         if "verified, 0 errors" in output:
#             # Check if it is also compiled
#             if "Compiled assembly into" in output:
#                 success = 1  # Successfully verified and compiled
#             else: 
#                 success = 0  # Verified but not compiled
#         else:
#             success = 0  # Not verified successfully
        
#     return success

# def run_all_dafny_files(main_folder_path, err_path_folder):
#     """
#     Run all .dfy files in the main folder and its subfolders using Dafny.
#     Results are saved in error files named according to the .dfy files.
#     """
#     for root, dirs, files in os.walk(main_folder_path):
#         for file_name in files:
#             if file_name.endswith(".dfy") and file_name.startswith("generated"):
#                 # Full path of the .dfy file
#                 file_path = os.path.join(root, file_name)
                
#                 # # Read the .dfy file content
#                 # with open(file_path, "r", encoding='utf-8') as file:
#                 #     dafny_code = file.read()
                
#                 # Generate tmp_path and err_path
#                 # tmp_path = os.path.join(tmp_path_folder, file_name)
                
#                 # Modify the name of the error file by replacing 'generated' with 'error'
#                 error_file_name = file_name.replace("generated", "error").replace(".dfy", ".txt")
#                 err_path = os.path.join(root, error_file_name)
                
#                 # Run the Dafny file and get the success status
#                 success = run_Dafny(file_path, err_path)
                
#                 # Print the result for tracking
#                 print(f"Processed {file_name}: {'Success' if success else 'Failure'}")

# main_folder_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/CHATGPTo1'
# # tmp_path_folder = '/path/to/tmp/folder'
# err_path_folder = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/CHATGPTo1'

# run_all_dafny_files(main_folder_path, err_path_folder)


# import os

# def delete_prompt_files(main_folder_path):
#     # Traverse the directory tree
#     for root, dirs, files in os.walk(main_folder_path):
#         for file_name in files:
#             if file_name.startswith("prompt") and file_name.endswith(".txt"):
#                 file_path = os.path.join(root, file_name)
#                 try:
#                     os.remove(file_path)
#                     print(f"Deleted file: {file_path}")
#                 except Exception as e:
#                     print(f"Failed to delete {file_path}: {e}")

# # Usage Example
# main_folder_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/CHATGPTo1'  # Replace with your main folder path
# delete_prompt_files(main_folder_path)


# import pandas as pd
# from sklearn.feature_extraction.text import TfidfVectorizer
# from sklearn.metrics.pairwise import cosine_similarity
# import numpy as np


# # Load your error messages (Replace with your file path)
# error_messages = pd.read_csv('error_messages.csv')  # Assuming you have a CSV file with a column 'error_message'


# # Predefined categories and their keywords
# categories = {
#     'Syntax Error': ['syntax', 'unexpected', 'invalid', 'token', 'parsing', 'missing', 'mismatch'],
#     'Postcondition Error': ['postcondition', 'failed', 'does not hold', 'contract', 'violation'],
#     'Assertion Error': ['assertion', 'failed', 'violation', 'assert'],
#     'Logic Error': ['logic', 'incorrect', 'wrong', 'flaw', 'mistake', 'unexpected result'],
#     'Out of Bounds Error': ['index', 'out of bounds', 'overflow', 'underflow', 'boundary']
# }


# # Prepare data
# vectorizer = TfidfVectorizer()
# X = vectorizer.fit_transform(error_messages['error_message'])


# # Calculate similarity of each message to predefined categories
# category_vectors = {category: vectorizer.transform([' '.join(keywords)]) for category, keywords in categories.items()}


# # Assign categories based on similarity
# results = []
# threshold = 0.2  # Similarity threshold for categorizing

# for i, message_vector in enumerate(X):
#     message_text = error_messages['error_message'].iloc[i]
#     assigned_categories = []
    
#     for category, category_vector in category_vectors.items():
#         similarity = cosine_similarity(message_vector, category_vector)[0][0]
#         if similarity > threshold:
#             assigned_categories.append(category)

#     if not assigned_categories:
#         assigned_categories.append('Uncategorized')
    
#     results.append({'error_message': message_text, 'categories': assigned_categories})


# # Convert results to DataFrame and save to CSV
# results_df = pd.DataFrame(results)
# results_df.to_csv('error_message_categories.csv', index=False)


# print('Clustering completed. Results saved to error_message_categories.csv.')
# import os
# import json
# import glob
# from datetime import datetime
# import matplotlib.pyplot as plt
# import pandas as pd

# # Set the root folder path here
# root_folder = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset"  # Change to your folder path

# # Empty list to hold data from all JSON files
# data = []
# total_reward_data = []
# # Iterate through subfolders in the root folder
# for subfolder in os.listdir(root_folder):
#     # Check if subfolder name starts with "epoch" and contains "Dafny"
#     if subfolder.startswith("epoch") and "Dafny" in subfolder:
#         subfolder_path = os.path.join(root_folder, subfolder)
#         # Use glob to find all JSON files in the subfolder
#         json_files = glob.glob(os.path.join(subfolder_path, "*.json"))
        
#         for json_file in json_files:
#             try:
#                 with open(json_file, "r", encoding="utf-8") as f:
#                     episode_data = json.load(f)
#                     json_file_name = json_file.split("/")[-1]
#                     if json_file_name == "epoch_summary.json":
#                         total_reward = episode_data["total_reward"] 
#                         total_reward_data.append({"total_reward": total_reward, "timestamp": episode_data["timestamp"]})
#                 # Ensure we have the keys we are interested in.
#                 if "reward" in episode_data and "timestamp" in episode_data:
#                     reward = episode_data["reward"]
#                     timestamp_str = episode_data["timestamp"]
#                     # Convert timestamp to datetime (adjust the format as per your timestamp)
#                     timestamp = datetime.strptime(timestamp_str, "%Y-%m-%d %H:%M:%S")
#                     data.append({"reward": reward, "timestamp": timestamp})
#             except Exception as e:
#                 print(f"Failed to process {json_file}: {e}")

# # Create a DataFrame from the data list
# df = pd.DataFrame(data)
# df_total_reward = pd.DataFrame(total_reward_data)
# # Dump all collected raw data to a JSON file
# with open("all_episode_data.json", "w", encoding="utf-8") as f:
#     json.dump(data, f, indent=2, default=str)
# print("All episode data saved as all_episode_data.json")

# if df.empty:
#     raise ValueError("No data found. Check that your JSON files and keys are correct.")

# if df_total_reward.empty:
#     raise ValueError("No total reward data found. Check that your JSON files and keys are correct.")

# # Dump the DataFrame (with all columns, including cumulative_reward and episode) as a JSON file
# # Use ISO date format for timestamps

# df.to_json("all_episode_data_with_cumulative.json", orient="records", indent=2, date_format="iso")
# print("All episode data with cumulative info saved as all_episode_data_with_cumulative.json")

# df_total_reward.to_json("all_episode_data_with_total_reward.json", orient="records", indent=2, date_format="iso")
# print("All episode data with total reward info saved as all_episode_data_with_total_reward.json")

# # Sort DataFrame by timestamp in reverse order (most recent first)
# df.sort_values(by="timestamp", ascending=False, inplace=True)
# df.reset_index(drop=True, inplace=True)
# # Create episode number based on sorted order
# df["episode"] = df.index + 1

# # Compute cumulative reward
# df["cumulative_reward"] = df["reward"].cumsum()

# df_total_reward.sort_values(by="timestamp", ascending=False, inplace=True)
# df_total_reward.reset_index(drop=True, inplace=True)
# df_total_reward["episode"] = df_total_reward.index + 1
# df_total_reward["cumulative_reward"] = df_total_reward["total_reward"].cumsum()
# # -----------------------------
# # Plot 1: Reward vs Episode (with mean reward line)
# # -----------------------------
# plt.figure(figsize=(12, 6))
# plt.plot(df["episode"], df["reward"], linestyle="-", label="Reward per Episode")
# plt.xlabel("Episode ")
# plt.ylabel("Reward")
# plt.title("Reward vs Episode")
# plt.grid(True)
# plt.legend()

# # Save the reward plot
# reward_plot_filename = "reward_vs_episode.png"
# plt.savefig(reward_plot_filename)
# plt.close()
# print(f"Reward plot saved as {reward_plot_filename}")

# # -----------------------------
# # Plot 2: Cumulative Reward vs Episode
# # -----------------------------
# plt.figure(figsize=(12, 6))
# plt.plot(df["episode"], df["cumulative_reward"], linestyle="-", color="purple")
# plt.xlabel("Episode (most recent first)")
# plt.ylabel("Cumulative Reward")
# plt.title("Cumulative Reward vs Episode (reverse chronological order)")
# plt.grid(True)

# # Save the cumulative reward plot
# cumulative_plot_filename = "cumulative_reward_vs_episode.png"
# plt.savefig(cumulative_plot_filename)
# plt.close()
# print(f"Cumulative reward plot saved as {cumulative_plot_filename}")

# # -----------------------------
# # Plot 3: Total Reward vs Episode
# # -----------------------------
# plt.figure(figsize=(12, 6))
# plt.plot(df_total_reward["episode"], 0.1*df_total_reward["total_reward"], linestyle="-", color="purple")
# plt.xlabel("Episode (most recent first)")
# plt.ylabel("Cumulative Reward")
# plt.title("Cumulative Reward vs Episode (reverse chronological order)")
# plt.grid(True)

# # Save the total reward plot
# total_reward_plot_filename = "total_reward_vs_episode.png"
# plt.savefig(total_reward_plot_filename)
# plt.close()
# print(f"Total reward plot saved as {total_reward_plot_filename}")

# # -----------------------------
# # Plot 4: Total Reward vs Episode
# # -----------------------------



import os
import json

def delete_jsons_with_empty_response(dir_path):
    """
    Delete all .json files in dir_path that are either:
      1) empty on disk (0 bytes), or
      2) contain a 'final_code' key whose value is "", None, [], or {}.
    """
    for fname in os.listdir(dir_path):
        if not fname.lower().endswith('.json'):
            continue

        fpath = os.path.join(dir_path, fname)

        # 1) Delete if the file is completely empty
        try:
            if os.path.getsize(fpath) == 0:
                os.remove(fpath)
                print(f"Deleted empty file: {fpath}")
                continue
        except OSError as e:
            print(f"Could not check size for {fpath}: {e}")
            # fall through to JSON loading

        # 2) Otherwise, try loading and inspecting its JSON
        try:
            with open(fpath, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except (json.JSONDecodeError, UnicodeDecodeError) as e:
            print(f"Skipping invalid JSON {fpath}: {e}")
            continue

        # Delete if 'final_code' is missing or empty
        resp = data.get('final_code', None)
        if resp in ("", None, [], {}):
            try:
                os.remove(fpath)
                print(f"Deleted (empty final_code): {fpath}")
            except OSError as e:
                print(f"Error deleting {fpath}: {e}")

if __name__ == "__main__":
    target_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_with_trained"
    delete_jsons_with_empty_response(target_dir)



    # delete_jsons_with_empty_response("/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/TEST_WITHOUTTRAINED")
