import os
import json

# Define your search parameters
models = ["gemini", "qwen", "gpt4o", "o1mini", "gemini25flash"]
feedback_types = ['no_feedback', 'with_feedback']

# Directory to search (current directory)
search_dir = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/TEST_WITHOUTTRAINED2'
search_dir_2 = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/Test_with_trained'

for model in models:
    for feedback in feedback_types:
        # Find all matching files
        matching_files = [
            f for f in os.listdir(search_dir)
            if f.endswith('.json') and model in f and feedback in f
        ]
        total = len(matching_files)
        passed = 0
        for fname in matching_files:
            try:
                with open(os.path.join(search_dir, fname), 'r') as file:
                    data = json.load(file)
                    if data.get('success') == 1:
                        passed += 1
            except Exception as e:
                x=1
                # print(f"Error reading {fname}: {e}")
        print(f"number of files in {model} {feedback} that pass = {passed} out of total {total} for TEST_WITHOUTTRAINED")

for model in models:
    for feedback in feedback_types:
        # Find all matching files
        matching_files = [
            f for f in os.listdir(search_dir_2)
            if f.endswith('.json') and model in f and feedback in f
        ]
        total = len(matching_files)
        passed = 0
        for fname in matching_files:
            try:
                with open(os.path.join(search_dir_2, fname), 'r') as file:
                    data = json.load(file)
                    if data.get('success') == 1:
                        passed += 1
            except Exception as e:
                x=1
                # print(f"Error reading {fname}: {e}")
        print(f"number of files in {model} {feedback} that pass = {passed} out of total {total} for Test_new")

