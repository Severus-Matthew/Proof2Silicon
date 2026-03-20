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



# Initialize the LLM client (replace `API_KEY` with your OpenAI API key)
# openai.api_key = "YOUR_API_KEY"


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
        ErrorSpecifiedPrompt(one_line_desc)
    ]

def process_subfolders(base_folder):
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
            
            # Run feedback loop
            RUN_LLM(subdir, one_line_desc, detailed_desc)


def run_Dafny(dafny_code, tmp_path, err_path):
    
    with open(tmp_path, "w", encoding='utf-8') as file:
        file.write(dafny_code)
    
    # Change directory to where Dafny executable is located
    dafny_directory = r"C:\Users\drpro\Downloads\dafny-4.5.0-x64-windows-2019\dafny"
    os.chdir(dafny_directory)
    
    # Execute Dafny command and redirect output to a temporary file
    dafny_command = f'dafny.exe {tmp_path} > {err_path}'
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



def RUN_LLM(subfolder, one_line_desc, detailed_desc, max_iterations=5):
    # Create prompts
    prompts = generate_prompts(one_line_desc, detailed_desc)

    for i, prompt in enumerate(prompts, start=1):
        
        for attempt in range(max_iterations):
            print(f"Attempt {attempt + 1} with Prompt {i}...")
            promptfile= os.path.join(subfolder, f"Prompt_gemini1Pro_{i}_{attempt}.dfy")
            output_dafny_path = os.path.join(subfolder, f"generated_gemini1Pro_{i}_{attempt}.dfy")
            Error_path = os.path.join(subfolder, f"error_gemini1Pro_{i}_{attempt}.txt")
            with open(promptfile, "w", encoding='utf-8') as file:
                file.write(prompt)
            # Generate Dafny code using LLM
            genai.configure(api_key="AIzaSyAImTEOaz6oQXEvesUx18rluO0exqo2XIA")
            model = genai.GenerativeModel('gemini-1.0-pro')
            temperature = 0.5
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
        




# Usage Example
process_subfolders("D:\\UIUC_PROJ_2\\dataset\\Dafny")




        # current_directory = os.getcwd()
        # dfy_relative_path = r'Dafny_scripts/Gemini'
        # dfy_path = os.path.join(current_directory, dfy_relative_path)
        # #temperature = random.uniform(0.0, 1.0)
        # temperature = 0.5
        # response = model.generate_content(Prompt , generation_config=genai.types.GenerationConfig(temperature=temperature))
        # #print(response)
        # response_extract = extract_dafny_code_and_method_names(response.text)
        # genai.configure(api_key="AIzaSyAImTEOaz6oQXEvesUx18rluO0exqo2XIA") 
        # model = genai.GenerativeModel('gemini-1.5-flash')
        # current_directory = os.getcwd()
        # dfy_relative_path = r'Dafny_scripts/Gemini'
        # dfy_path = os.path.join(current_directory, dfy_relative_path)
        # temperature = random.uniform(0.0, 1.0)
        # response = model.generate_content(messages , generation_config=genai.types.GenerationConfig(temperature=temperature))
        # #print(response)
        # response_extract = extract_dafny_code_and_method_names(response.text)


