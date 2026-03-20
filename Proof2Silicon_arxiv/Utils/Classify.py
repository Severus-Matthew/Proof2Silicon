import os
import pandas as pd

import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

def count_error_occurrences_case_insensitive(text: str) -> int:
    """
    Count occurrences of "error:" in the text without considering case differences.
    """
    return text.lower().count("error:")

def check_file_score(file_path):
 
    try:
        with open(file_path, 'r') as file:
            content = file.read()
            
            # Return appropriate score based on verification result and category
            if "verified, 0 errors" in content:
                if "Compiled assembly" in content:
                    base_score = str(0)                           
                else:
                    base_score = str(1)
                    if "Error:" in content:
                        if "parse errors" in content:
                            base_score += str(3)
                        if "resolution/type errors" in content:
                            base_score += str(4)
            else:
                base_score = str(2)
                if "Error:" in content:
                    for line in content.split("\n"):
                        if "loop invariant violation" in line:
                            base_score += str(3)
                        if "postcondition might not hold" in line:
                            base_score += str(4)
                        if "bound errors" in line:
                            base_score += str(5)
                        if "index out of bounds" in line:
                            base_score += str(6)
                        if "possible division by zero" in line:
                            base_score += str(7)
                        if "verification time out" in line:
                            base_score += str(8)
                        print(base_score)
            
        return int(base_score)
                
            
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
        return 9

def generate_score_report(main_folder_path, output_excel_path):
    # Define the file patterns to check
    file_patterns = ['_1_0.txt', '_1_1.txt', '_1_2.txt', '_1_3.txt', '_1_4.txt', '_2_0.txt', '_2_1.txt', '_2_2.txt', '_2_3.txt', '_2_4.txt', '_3_0.txt', '_3_1.txt', '_3_2.txt', '_3_3.txt', '_3_4.txt']

    # Initialize a dictionary to store scores
    score_data = {}

    # Traverse through each subfolder in the main folder
    for subfolder_name in os.listdir(main_folder_path):
        subfolder_path = os.path.join(main_folder_path, subfolder_name)
        
        if os.path.isdir(subfolder_path):  # Check if it's a folder
            # Initialize score row for the current subfolder
            print(subfolder_path)
            score_data[subfolder_name] = {pattern: 0 for pattern in file_patterns}
            
            # Check each file in the subfolder
            for file_name in os.listdir(subfolder_path):
                if file_name.startswith("error") and "_0.25" not in file_name:
                    print("hi")
                    for pattern in file_patterns:
                        if file_name.endswith(pattern):
                            file_path = os.path.join(subfolder_path, file_name)
                            print(file_path)
                            score = check_file_score(file_path)
                            score_data[subfolder_name][pattern] = score
                            break  # No need to check other patterns once matched

    # Convert the score data to a pandas DataFrame
    df = pd.DataFrame.from_dict(score_data, orient='index', columns=file_patterns)
    
    # Save the DataFrame to an Excel file
    df.to_excel(output_excel_path, index=True, index_label="Subfolder Name")
    print(f"Score report saved to {output_excel_path}")

# Usage example
main_folder_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/CHATGPT4'  # Replace with your main folder path
output_excel_path = '/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/CHATGPT4/score_report_CHATGPT4.xlsx'  # Replace with your desired output path

generate_score_report(main_folder_path, output_excel_path)
