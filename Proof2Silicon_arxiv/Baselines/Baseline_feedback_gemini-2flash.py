import os
import subprocess  # Used to check Dafny code
from openai import ChatCompletion  # Assuming OpenAI LLM API
import google.generativeai as genai
import json
import os
import re
import subprocess
import random
from difflib import get_close_matches
from collections import Counter
import time



def ShortPrompt(Task):
    Prompt = "You are an Expert in Dafny programming, follow the below instrution to write an error free Dafny code:\n"
    Prompt+=Task+"\n"
    Prompt+="You must return the method in the following Form:"+"\n"+"```dafny"+"\n"+"//Dafny Code"+"\n"+"```"
    return Prompt

def DetailedAndShortPrompt(Task, Detailed):
    Prompt = "You are an Expert in Dafny programming, follow the below instrution to write an error free Dafny code:\n"
    Prompt+=Task+"\n"
    Prompt += "This query can be explained in a more detailed way as:\n" + Detailed + "\n" 
    Prompt+="You must return the method in the following Form:"+"\n"+"```dafny"+"\n"+"//Dafny Code"+"\n"+"```"
    return Prompt

def ErrorSpecifiedPrompt(Task):
    Prompt = "You are an Expert in Dafny programming, follow the below instrution to write an error free Dafny code:\n"
    Prompt+=Task+"\n"
    Prompt +="Make sure that the generated code is free from Out-of-bound error, logic error, syntax error, undefined variable or input type error"
    Prompt+="You must return the method in the following Form:"+"\n"+"```dafny"+"\n"+"//Dafny Code"+"\n"+"```"
    return Prompt

def FewShotPrompt(Task, Detailed):
    Prompt = "Dafny is a formal verification language, here are some examples of Dafny code:\n"
    Prompt += "Example 1:\n"
    Prompt += "Task: The code defines a Dafny method called `TriangularPrismVolume`, which calculates the volume of a triangular prism given its base, height, and length. It includes preconditions to ensure that all inputs are positive integers and a postcondition to verify that the computed volume is equal to half the product of the base, height, and length. The method effectively encapsulates the mathematical formula for the volume of a triangular prism while ensuring the validity of input values.\n"
    Prompt += "Code:\n"
    Prompt += "//Dafny Code\n"
    Prompt += "method TriangularPrismVolume(base: int, height: int, length: int) returns (volume: int)\n"
    Prompt += "requires base > 0 && height > 0 && length > 0\n"
    Prompt += "ensures volume == base * height * length / 2\n"
    Prompt += "{\n"
    Prompt += "  // Calculate the volume directly to avoid intermediate truncation\n"
    Prompt += "  volume := (base * height * length) / 2;\n"
    Prompt += "  // Assert that the calculated volume satisfies the postcondition\n"
    Prompt += "  assert volume == base * height * length / 2;\n"
    Prompt += "}\n"
    Prompt += "Example 2:\n"
    Prompt += "Task: The provided Dafny code defines a method, `AllCharactersSame`, which checks whether all characters in a given string `s` are the same. It verifies that if the result is true, all characters must be equal; if false, it ensures there are at least two different characters in the string. The method uses loop invariants to ensure the correctness of the character comparisons throughout its execution.\n"
    Prompt += "Code:\n"
    Prompt += "// Dafny Code\n"
    Prompt += "method AllCharactersSame(s: string) returns (result: bool)\n"
    Prompt += "ensures result == (forall i, j :: 0 <= i < |s| && 0 <= j < |s| ==> s[i] == s[j])\n"
    Prompt += "{\n"
    Prompt += "  if |s| == 0 {\n"
    Prompt += "    result := true;\n"
    Prompt += "    return;\n"
    Prompt += "  }\n"
    Prompt += "  var firstChar := s[0];\n"
    Prompt += "  var i: int := 1;\n"
    Prompt += "  result := true;\n"
    Prompt += "  while i < |s|\n"
    Prompt += "    invariant 0 <= i <= |s|\n"
    Prompt += "    invariant result == (forall k: int :: 0 <= k < i ==> s[k] == firstChar)\n"
    Prompt += "  {\n"
    Prompt += "    if s[i] != firstChar {\n"
    Prompt += "      result := false;\n"
    Prompt += "      return;\n"
    Prompt += "    }\n"
    Prompt += "    i := i + 1;\n"
    Prompt += "  }\n"
    Prompt += "}\n"
    Prompt += "You are an Expert in Dafny programming, follow the below instrution to write an error free Dafny code, you can use the above examples to learn the style of writing Dafny code:\n"
    Prompt+=Task+"\n"
    Prompt += "This query can be explained in a more detailed way as:\n" + Detailed + "\n" 
    Prompt+="You must return the method in the following Form:"+"\n"+"```dafny"+"\n"+"//Dafny Code"+"\n"+"```"
    return Prompt

def COTPrompt(Task, Detailed):
    Prompt = "Dafny is a formal verification language, here are some examples of Dafny code and the reasoning behind the code:\n"
    Prompt += "Example 1:\n"
    Prompt += "Task: The code defines a Dafny method called `TriangularPrismVolume`, which calculates the volume of a triangular prism given its base, height, and length. It includes preconditions to ensure that all inputs are positive integers and a postcondition to verify that the computed volume is equal to half the product of the base, height, and length. The method effectively encapsulates the mathematical formula for the volume of a triangular prism while ensuring the validity of input values.\n"
    Prompt += "Thought Process:\n"
    Prompt+= " Let us define the volume of a triangular prism as the product of the base, height, and length divided by 2. We can write the following Dafny code to calculate the volume of a triangular prism:\n We begin by defining the method TriangularPrismVolume, which takes three integer parameters: base, height, and length. The method returns an integer value representing the volume of the triangular prism. We then use the preconditions to ensure that all inputs are positive integers and the postcondition to verify that the computed volume is equal to half the product of the base, height, and length. The method effectively encapsulates the mathematical formula for the volume of a triangular prism while ensuring the validity of input values.\n We follow the following steps to write the code:\n"
    Prompt += "Code:\n"
    Prompt += "//Dafny Code\n"
    Prompt += "method TriangularPrismVolume(base: int, height: int, length: int) returns (volume: int)\n"
    Prompt += "requires base > 0 && height > 0 && length > 0\n"
    Prompt += "ensures volume == base * height * length / 2\n"
    Prompt += "{\n"
    Prompt += "  // Calculate the volume directly to avoid intermediate truncation\n"
    Prompt += "  volume := (base * height * length) / 2;\n"
    Prompt += "  // Assert that the calculated volume satisfies the postcondition\n"
    Prompt += "  assert volume == base * height * length / 2;\n"
    Prompt += "}\n"
    Prompt += "Example 2:\n"
    Prompt += "Task: The provided Dafny code defines a method, `AllCharactersSame`, which checks whether all characters in a given string `s` are the same. It verifies that if the result is true, all characters must be equal; if false, it ensures there are at least two different characters in the string. The method uses loop invariants to ensure the correctness of the character comparisons throughout its execution.\n"
    Prompt += "Thought Process:\n"
    Prompt += "Let us define a method, `AllCharactersSame`, which checks whether all characters in a given string `s` are the same. It verifies that if the result is true, all characters must be equal; if false, it ensures there are at least two different characters in the string. The method uses loop invariants to ensure the correctness of the character comparisons throughout its execution.\n We follow the following steps to write the code:\n"
    Prompt += "Code:\n"
    Prompt += "// Dafny Code\n"
    Prompt += "method AllCharactersSame(s: string) returns (result: bool)\n"
    Prompt += "ensures result == (forall i, j :: 0 <= i < |s| && 0 <= j < |s| ==> s[i] == s[j])\n"
    Prompt += "{\n"
    Prompt += "  if |s| == 0 {\n"
    Prompt += "    result := true;\n"
    Prompt += "    return;\n"
    Prompt += "  }\n"
    Prompt += "  var firstChar := s[0];\n"
    Prompt += "  var i: int := 1;\n"
    Prompt += "  result := true;\n"
    Prompt += "  while i < |s|\n"
    Prompt += "    invariant 0 <= i <= |s|\n"
    Prompt += "    invariant result == (forall k: int :: 0 <= k < i ==> s[k] == firstChar)\n"
    Prompt += "  {\n"
    Prompt += "    if s[i] != firstChar {\n"
    Prompt += "      result := false;\n"
    Prompt += "      return;\n"
    Prompt += "    }\n"
    Prompt += "    i := i + 1;\n"
    Prompt += "  }\n"
    Prompt += "}\n"    
    Prompt = "You are an Expert in Dafny programming, follow the below instrution to write an error free Dafny code, you can use the above examples to learn the style of writing Dafny code:\n"
    Prompt+=Task+"\n"
    Prompt += "This query can be explained in a more detailed way as:\n" + Detailed + "\n" 
    Prompt+="You must return the method in the following Form:"+"\n"+"```dafny"+"\n"+"//Dafny Code"+"\n"+"```"
    return Prompt

def ErrorPrompt(code, error):
    Prompt = "You are an Expert in Dafny programming, The following code gave an error followed by the code. Please resolve the error and regenrate the correct code:\n"
    Prompt+=code+"\n"
    Prompt += " The error is: \n" + error
    Prompt +="Make sure that the generated code is free from Out-of-bound error, logic error, syntax error, undefined variable or input type error"
    Prompt+="You must return the method in the following Form:"+"\n"+"```dafny"+"\n"+"//Dafny Code"+"\n"+"```"
    return Prompt

def generate_prompts(one_line_desc, detailed_desc):
    return [
        ShortPrompt(one_line_desc),
        DetailedAndShortPrompt(one_line_desc, detailed_desc),
        ErrorSpecifiedPrompt(one_line_desc),
        FewShotPrompt(one_line_desc, detailed_desc),
        COTPrompt(one_line_desc, detailed_desc)
    ]

def process_subfolders(base_folder, temperature):
    temperature = temperature
    for subdir, _, files in os.walk(base_folder):
        if subdir == base_folder:
            continue

        # Look for description files
        one_line_file = os.path.join(subdir, "one_line_description.txt")
        detailed_file = os.path.join(subdir, "detailed_description.txt")

        if os.path.exists(one_line_file) and os.path.exists(detailed_file):
            with open(one_line_file, "r") as f:
                one_line_desc = f.read().strip()
            with open(detailed_file, "r") as f:
                detailed_desc = f.read().strip()

            # Check for existing files first
            folder_name = os.path.basename(subdir)
            all_files_exist = True
            
            # Check all possible combinations of files that should exist
            for i in range(1, 6):  # For each prompt type
                for attempt in range(5):  # For each attempt
                    prompt_file = os.path.join(subdir, f"Prompt_gemini2flash_0.25_{i}_{attempt}.dfy")
                    output_file = os.path.join(subdir, f"generated_gemini2flash_0.25_{i}_{attempt}.dfy")
                    error_file = os.path.join(subdir, f"error_gemini2flash_0.25_{i}_{attempt}.txt")
                    
                    # If any file in the set is missing, mark for processing
                    if not all(os.path.exists(f) for f in [prompt_file, output_file, error_file]):
                        all_files_exist = False
                        break
                if not all_files_exist:
                    break

            if all_files_exist:
                print(f"\nSkipping {folder_name} - All files already exist")
                continue

            print(f"\nProcessing {folder_name} - Some files missing")
            # Run feedback loop for this folder
            RUN_LLM(subdir, one_line_desc, detailed_desc, temperature)


def run_Dafny(dafny_code, tmp_path, err_path):
    
    with open(tmp_path, "w", encoding='utf-8') as file:
        file.write(dafny_code)
    
    # Change directory to where Dafny executable is located
    dafny_directory = r"/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
    os.chdir(dafny_directory)
    
    # Execute Dafny command and redirect output to a temporary file
    dafny_command = f"/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny '{tmp_path}' > '{err_path}'"
    os.system(dafny_command)

    # Read the contents of the temporary output file
    with open(err_path, "r", encoding='utf-8') as output_file:
        output = output_file.read()
        if "verified, 0 errors" in output:
            # Check if it is also compiled
            if "Compiled assembly into" in output:
                            # Save to compiled folder
                success=1
            else: 
                success=0
        else:
            success=0
    return success

import re

def extract_dafny_code(text):
    pattern_snippet = r"```dafny(.*?)```"
    pattern_method = r"\bmethod\s+([a-zA-Z_][a-zA-Z0-9_]*)"
    snippets = re.findall(pattern_snippet, text, re.DOTALL)

    # Initialize trimmed_snippet to handle cases where snippets is empty or None
    trimmed_snippet = 0

    if snippets:
        for snippet in snippets:
            trimmed_snippet = snippet.strip()

    return trimmed_snippet



def RUN_LLM(subfolder, one_line_desc, detailed_desc, temperature, max_iterations=5):
    temperature= temperature
    # Create prompts
    prompts = generate_prompts(one_line_desc, detailed_desc)

    for i, prompt in enumerate(prompts, start=1):
        
        for attempt in range(max_iterations):
            print(f"Attempt {attempt + 1} with Prompt {i}...")
            promptfile = os.path.join(subfolder, f"Prompt_gemini2flash_0.25_{i}_{attempt}.dfy")
            output_dafny_path = os.path.join(subfolder, f"generated_gemini2flash_0.25_{i}_{attempt}.dfy")
            Error_path = os.path.join(subfolder, f"error_gemini2flash_0.25_{i}_{attempt}.txt")

            if all(os.path.exists(file_path) for file_path in [promptfile, output_dafny_path]):
                print(f"Files for Prompt {i}, Attempt {attempt + 1} already exist. Skipping to next attempt...")
                continue

            # Ensure the subfolder exists, create it if it doesn't
            os.makedirs(subfolder, exist_ok=True)

            # Create the files if they don't exist
            for file_path in [promptfile, output_dafny_path, Error_path]:
                if not os.path.exists(file_path):
                    with open(file_path, 'w') as file:
                        # Optionally, you can write an initial content to the file
                        file.write("")  # This creates an empty file
            with open(promptfile, "w", encoding='utf-8') as file:
                file.write(prompt)
            # Generate Dafny code using LLM
            genai.configure(api_key="AIzaSyAImTEOaz6oQXEvesUx18rluO0exqo2XIA")
            model = genai.GenerativeModel('gemini-2.0-flash')
            # temperature = 0.5
            response = model.generate_content(prompt , generation_config=genai.types.GenerationConfig(temperature=temperature))
            # response = openai.ChatCompletion.create(
            #     model="gpt-4",
            #     messages=[{"role": "user", "content": prompt}]
            # )
            dafny_code = extract_dafny_code(response.text)
            if dafny_code==0:
                break

            # Test the generated Dafny code
            success = run_Dafny(dafny_code, output_dafny_path, Error_path)
            
            if success==1:
                # Save successful Dafny code
                print("Success")
                break
            else:
                # Save the error message as feedback
                with open(Error_path, "r", encoding='utf-8') as output_file:
                    output = output_file.read()
                with open(output_dafny_path, "r", encoding='utf-8') as output_file2:
                    output2 = output_file2.read()
                
                # Update the prompt with the error message
                prompt = ErrorPrompt(output2, output)
        time.sleep(30)
        


import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run Dafny code generation with specified temperature')
    parser.add_argument('--temperature', type=float, default=0.25,
                      help='Temperature for LLM generation (default: 0.25)')
    args = parser.parse_args()

    # Set the temperature from command line argument
    temperature = args.temperature

    # Process the subfolders
    process_subfolders("/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/gemini2flash", temperature)


