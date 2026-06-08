# import multiprocessing as mp
# mp.set_start_method('spawn', force=True)

# import os
# import re
# import json
# import time
# import torch
# from transformers import AutoModelForCausalLM, AutoTokenizer
# from peft import LoraConfig, get_peft_model, PeftModel
# import google.generativeai as genai
# import logging
# import subprocess
# import concurrent.futures
# from transformers import BitsAndBytesConfig
# from transformers import pipeline
# # Set up logging
# logging.basicConfig(
#     level=logging.INFO,
#     format='%(asctime)s - %(levelname)s - %(message)s',
#     handlers=[
#         logging.FileHandler('testing.log'),
#         logging.StreamHandler()
#     ]
# )

# # Memory management
# os.environ['PYTORCH_CUDA_ALLOC_CONF'] = 'expandable_segments:True'
# torch.cuda.empty_cache()

# # GPU setup
# device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
# logging.info(f"Using device: {device}")

# from openai import OpenAI

# client = OpenAI(api_key="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")



# def initialize_slm():
#     """Initialize the SLM model for generation."""
#     base_model_name = "deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B"
#     # checkpoint_path = "/mnt/shared/gpfs/home/manvij2/checkpoints/run_CHK/final_model_new.pt"

#     logging.info("Loading tokenizer...")
#     tokenizer = AutoTokenizer.from_pretrained(base_model_name, trust_remote_code=True)
#     if tokenizer.pad_token is None:
#         tokenizer.pad_token = tokenizer.eos_token
#     print("Configuring quantization and offloading settings...")
#     quant_config = BitsAndBytesConfig(
#             load_in_4bit=True,  # Changed from 8bit to 4bit for memory efficiency
#             llm_int8_threshold=6.0,
#             llm_int8_has_fp16_weight=False,
#             bnb_4bit_compute_dtype=torch.float16,
#             bnb_4bit_use_double_quant=True,
#             bnb_4bit_quant_type="nf4"
#         )
#     offload_folder = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/model_offload"
#     os.makedirs(offload_folder, exist_ok=True)

#     # Configure memory limits - reduced for safety
#     max_memory = {0: "8GiB", "cpu": "32GiB"}  # Reduced from 24GiB to 8GiB

#     print("Loading base model with offloading configuration...")
#     model = AutoModelForCausalLM.from_pretrained(
#             base_model_name,
#             quantization_config=quant_config,
#             trust_remote_code=True,
#             device_map="auto",  # Changed from "balanced" to "auto"
#             max_memory=max_memory,
#             offload_folder=offload_folder,
#             offload_state_dict=True,
#             torch_dtype=torch.float16,
#             low_cpu_mem_usage=True
#         )

#     # Configure LoRA
#     logging.info("Configuring LoRA...")
#     lora_config = LoraConfig(
#         r=8,  # Reduced from 16 to 8 for memory efficiency
#         lora_alpha=16,  # Reduced from 32 to 16
#         target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
#         lora_dropout=0.1,
#         bias="none",
#         task_type="CAUSAL_LM",
#         modules_to_save=["embed_tokens", "lm_head"],
#         inference_mode=False
#     )

#     # Add LoRA adapters to the model
#     model = get_peft_model(model, lora_config)


#     #     logging.warning(f"Checkpoint not found at {checkpoint_path}, using base model")

#     model.eval()  # Set to evaluation mode
#     return model, tokenizer

# def create_short_prompt(task):
#     """Create the initial prompt for code generation."""
#     return (
#         "You are an expert in understanding Dafny code and explaining it in detailed, structured steps "
#         "to another agent. Your explanations should be clear, thorough, and logically organized so that the agent "
#         "can effectively use them to write correct and error-free Dafny code. Given the following task, break down "
#         "the required Dafny program into:\n"
#         " Step-by-step reasoning about the logic and specification.\n"
#         " Relevant Dafny constructs and their usage (e.g., preconditions, postconditions, invariants).\n"
#         " Potential edge cases and how to handle them.\n"
#         " Final suggestions or reminders to avoid common pitfalls.\n"
#         " Here is the task:\n" + task
#     )

# def create_error_prompt(task, code, error, reward):
#     """Create prompt for error correction."""
#     return (
#         "You are an expert in understanding Dafny code and explaining it in detailed, structured steps "
#         "to another agent. Your explanations should be clear, thorough, and logically organized so that the agent "
#         "can effectively use them to write correct and error-free Dafny code. Given the following task, an previously "
#         "LLM generated code based on your instructions and the associated error message, break down "
#         "the required Dafny program into:\n"
#         " Step-by-step reasoning about the logic and specification and ways to solve this error.\n"
#         " Relevant Dafny constructs and their usage (e.g., preconditions, postconditions, invariants).\n"
#         " Potential edge cases and how to handle them.\n"
#         " Final suggestions or reminders to avoid common pitfalls.\n"
#         f" Here is the task:\n{task}\n"
#         f"Below is the errored code:\n{code}\n"
#         f"Below is the error message:\n{error}\n"
#         f"Below is the reward for the previous attempt:\n{reward}"
#     )


# def run_slm(model, tokenizer, prompt):
#     """Run the SLM model to generate a response."""
#     try:
#         generation_config = {
#             "max_new_tokens": 2000,
#             "do_sample": True,
#             "temperature": 0.75,
#             "top_p": 0.95,
#             "top_k": 50,
#             "num_beams": 1,
#             "pad_token_id": tokenizer.pad_token_id,
#             "eos_token_id": tokenizer.eos_token_id,
#             "length_penalty": 1.0,
#             "repetition_penalty": 1.0
#         }
        
#         inputs = tokenizer(prompt, return_tensors="pt", truncation=True, padding=True).to(device)
        
#         model.eval()
#         with torch.no_grad():
#             out = model.generate(**inputs, **generation_config)
        
#         response = tokenizer.decode(out[0], skip_special_tokens=True)
        
#         # Save interaction
#         save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/slm_wt2"
#         os.makedirs(save_dir, exist_ok=True)
        
#         with open(os.path.join(save_dir, f"slm_interaction_slm_{time.strftime('%Y%m%d_%H%M%S')}.json"), "w") as f:
#             json.dump({
#                 "prompt": prompt,
#                 "response": response
#             }, f, indent=2)
            
#         return response
        
#     except Exception as e:
#         logging.error(f"Error in run_slm: {str(e)}")
#         return ""

# def run_llm(prompt):
#     """Run the Gemini model to generate code."""
#     try:
#         genai.configure(api_key="AIzaSyAImTEOaz6oQXEvesUx18rluO0exqo2XIA")
#         model = genai.GenerativeModel('gemini-2.0-flash')
        
#         full_prompt = (
#             prompt
#             + "\nDo not repeat or include the input task or prompt in your response. Only output the Dafny code."
#             + "\nYou must return the full code in the following form:\n```dafny\nDafny Code\n```"
#         )
        
#         response = model.generate_content(full_prompt, generation_config=genai.types.GenerationConfig(temperature=0.75))
        
#         # Save interaction
#         save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/llm_wt2"
#         os.makedirs(save_dir, exist_ok=True)
        
#         with open(os.path.join(save_dir, f"llm_interaction_gemini_{time.strftime('%Y%m%d_%H%M%S')}.json"), "w") as f:
#             json.dump({
#                 "prompt": full_prompt,
#                 "response": response.text
#             }, f, indent=2)
            
#         return response.text
        
#     except Exception as e:
#         logging.error(f"Error in run_llm: {str(e)}")
#         return ""

# def run_llm_chatgpt4o(prompt):
#     time.sleep(30)
#     """Run the Gemini model to generate code."""
#     try:
           
#         model = "gpt-4o-2024-08-06"
        
#         full_prompt = (
#             prompt
#             + "\nDo not repeat or include the input task or prompt in your response. Only output the Dafny code."
#             + "\nYou must return the full code in the following form:\n```dafny\nDafny Code\n```"
#         )
#         # response = client.chat.completions.create(model=model,
#         #     messages=[
#         #         {"role": "system", "content": "You are a helpful assistant."},
#         #         {"role": "user", "content": prompt}
#         #     ],
#         #     temperature=temperature)

#             # Extract and print the response content
#             # generated_ntent = response.choices[0].message.content
#         response = client.chat.completions.create(model=model,
#             messages=[
#                 {"role": "system", "content": "You are a helpful assistant."},
#                 {"role": "user", "content": prompt}
#             ],
#             temperature=0.75)
#         # Save interaction
#         save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/llm_wt2"
#         os.makedirs(save_dir, exist_ok=True)
        
#         with open(os.path.join(save_dir, f"llm_interaction_chagpt4o_{time.strftime('%Y%m%d_%H%M%S')}.json"), "w") as f:
#             json.dump({
#                 "prompt": full_prompt,
#                 "response":response.choices[0].message.content
#             }, f, indent=2)
            
#         return response.choices[0].message.content
        
#     except Exception as e:
#         logging.error(f"Error in run_llm: {str(e)}")
#         return ""



# def run_llm_chatgpto1(prompt):
#     time.sleep(30)
#     try:
           
#         model = "o1-mini-2024-09-12"
        
#         full_prompt = (
#             prompt
#             + "\nDo not repeat or include the input task or prompt in your response. Only output the Dafny code."
#             + "\nYou must return the full code in the following form:\n```dafny\nDafny Code\n```"
#         )
        
#         response = client.chat.completions.create(
#                 model=model,  # Use a model that supports system role, like 'gpt-3.5-turbo' or 'gpt-4'
#                 messages=[
#                     {"role": "user", "content": "You are a helpful assistant and an expert in Dafny code generation. You return only the Dafny code. " + full_prompt}  # Combine system instructions into user message
#                 ],
#             )
#         generated_content = response.choices[0].message.content
#         print(response)
#         print(generated_content)
#         # Save interaction
#         save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/llm_new"
#         os.makedirs(save_dir, exist_ok=True)
        
#         with open(os.path.join(save_dir, f"llm_interaction_chagpto1_{time.strftime('%Y%m%d_%H%M%S')}.json"), "w") as f:
#             json.dump({
#                 "prompt": full_prompt,
#                 "response": generated_content
#             }, f, indent=2)
            
            
#         return generated_content
        
#     except Exception as e:
#         logging.error(f"Error in run_llm: {str(e)}")
#         return ""

# def run_llm_gemini_25flash(prompt):
#     time.sleep(30)
#     """Run the Qwen model to generate code."""
#     try:
#         # base_model_name = "Qwen/Qwen2.5-7B"
#         # Reset CUDA state
#         try:
#             torch.cuda.empty_cache()
#             torch.cuda.reset_peak_memory_stats()
#             if hasattr(torch.cuda, 'reset_accumulated_memory_stats'):
#                 torch.cuda.reset_accumulated_memory_stats()
#         except Exception as e:
#             logging.warning(f"Failed to reset CUDA state: {e}")
#         os.environ["CUDA_LAUNCH_BLOCKING"] = "1"
#         os.environ["TORCH_USE_CUDA_DSA"] = "1"
#         if not torch.cuda.is_available():
#             logging.error("CUDA is not available. This model requires GPU acceleration.")
#             return ""
#         torch.cuda.set_device(0)
#         device = torch.device("cuda:0")
#         logging.info(f"Using device: {device}")
#         logging.info(f"CUDA device count: {torch.cuda.device_count()}")
#         logging.info(f"Current CUDA device: {torch.cuda.current_device()}")
#         logging.info("Loading Qwen tokenizer...")

#         full_prompt = (
#             prompt
#             + "\nDo not repeat or include the input task or prompt in your response. Only output the Dafny code."
#             + "\nYou must return the full code in the following form:\n```dafny\n <Your Dafny Code>\n```"
#         )

#         pipe = pipeline(
#                 task="text-generation",
#                 model="Qwen/Qwen2.5-7B-Instruct",
#                 torch_dtype=torch.bfloat16,
#                 device_map=0
#             )

#         messages = [
#                 {"role": "system", "content": "You are a helpful assistant and an expert in Dafny code generation. You return only the Dafny code."},
#                 {"role": "user", "content": full_prompt},
#             ]
#         outputs = pipe(messages, max_new_tokens=5000, do_sample=True, temperature=0.75, top_k=50, top_p=0.95)
#         response = outputs[0]["generated_text"][-1]['content']

#         # dafny_code = extract_dafny_code(response)
#         save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/llm_wt2"
#         os.makedirs(save_dir, exist_ok=True)
#         with open(os.path.join(save_dir, f"llm_interaction_qwen257b_{time.strftime('%Y%m%d_%H%M%S')}.json"), "w") as f:
#             json.dump({
#                 "prompt": full_prompt,
#                 "response": response
#             }, f, indent=2)
#         torch.cuda.empty_cache()
#         return response
#     except Exception as e:
#         logging.error(f"Error in run_llm_qwen: {str(e)}")
#         try:
#             torch.cuda.empty_cache()
#         except:
#             pass
#         return ""



# def run_llm_qwen(prompt):
#     time.sleep(30)
#     """Run the Qwen model to generate code."""
#     try:
#         base_model_name = "Qwen/Qwen2.5-Coder-14B"
#         # Reset CUDA state
#         try:
#             torch.cuda.empty_cache()
#             torch.cuda.reset_peak_memory_stats()
#             if hasattr(torch.cuda, 'reset_accumulated_memory_stats'):
#                 torch.cuda.reset_accumulated_memory_stats()
#         except Exception as e:
#             logging.warning(f"Failed to reset CUDA state: {e}")
        
#         # Set environment variables for better memory management
#         os.environ["CUDA_LAUNCH_BLOCKING"] = "1"
#         os.environ["TORCH_USE_CUDA_DSA"] = "1"
        
#         if not torch.cuda.is_available():
#             logging.error("CUDA is not available. This model requires GPU acceleration.")
#             return ""
        
#         torch.cuda.set_device(0)
#         device = torch.device("cuda:0")
#         logging.info(f"Using device: {device}")
#         logging.info(f"CUDA device count: {torch.cuda.device_count()}")
#         logging.info(f"Current CUDA device: {torch.cuda.current_device()}")
#         logging.info("Loading Qwen tokenizer...")

#         full_prompt = (
#             prompt
#             + "\nDo not repeat or include the input task or prompt in your response. Only output the Dafny code."
#             + "\nYou must return the full code in the following form:\n```dafny\n <Your Dafny Code>\n```"
#         )

#         # Use pipeline with memory-efficient settings
#         pipe = pipeline(
#                 task="text-generation",
#                 model="Qwen/Qwen2.5-Coder-14B",
#                 torch_dtype=torch.bfloat16,
#                 device_map="auto"  # Changed from device_map=0 to "auto"
#             )

#         messages = [
#                 {"role": "system", "content": "You are a helpful assistant and an expert in Dafny code generation. You return only the Dafny code."},
#                 {"role": "user", "content": full_prompt},
#             ]
        
#         outputs = pipe(messages, max_new_tokens=5000, do_sample=True, temperature=0.75, top_k=50, top_p=0.95)
#         response = outputs[0]["generated_text"][-1]['content']
        
#         # Save interaction
#         save_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/llm_wt2"
#         os.makedirs(save_dir, exist_ok=True)
#         with open(os.path.join(save_dir, f"llm_interaction_qwen25coder14b_{time.strftime('%Y%m%d_%H%M%S')}.json"), "w") as f:
#             json.dump({
#                 "prompt": full_prompt,
#                 "response": response
#             }, f, indent=2)
        
#         # Clean up memory
#         del pipe
#         torch.cuda.empty_cache()
#         return response
        
#     except Exception as e:
#         logging.error(f"Error in run_llm_qwen: {str(e)}")
#         try:
#             torch.cuda.empty_cache()
#         except:
#             pass
#         return ""

# def extract_dafny_code(text):
#     """Extract Dafny code from the response."""
#     pattern = r"```dafny(.*?)```"
#     snippets = re.findall(pattern, text, re.DOTALL)
#     return snippets[-1].strip() if snippets else ""

# def run_dafny(code, tmp_path, error_path):
#     """Run Dafny verification on the generated code."""
#     if not code or code.strip() == "":
#         return -1, "Error: Empty Dafny file", ""
        
#     try:
#         with open(tmp_path, "w", encoding='utf-8') as f:
#             if code.startswith("Dafny code"):
#                 code = code.split("Dafny code", 1)[1].strip()
#             f.write(code)

        
        
#         dafny_dir = "/mnt/shared/gpfs/home/manvij2/dafny/Source/IntegrationTests"
#         os.chdir(dafny_dir)
#             # Run Dafny with a 4-minute timeout
#         dafny_command = f"/mnt/shared/gpfs/home/manvij2/dafny/Scripts/dafny '{tmp_path}' > '{error_path}'"
#         process = subprocess.Popen(dafny_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
#         try:
#                 process.communicate(timeout=240)  # 240 seconds = 4 minutes
#                 with open(error_path, "r", encoding='utf-8') as output_file:
#                     print("reading error file")
#                     output = output_file.read()
#         except subprocess.TimeoutExpired:
#                 process.kill()   
        
#         with open(error_path, "r", encoding='utf-8') as f:
#             output = f.read()
            
#         if "verified, 0 errors" in output and "Compiled assembly into" in output:
#             return 1, output, code
#         else:
#             return 0, output, code
            
#     except Exception as e:
#         return -1, f"Error running Dafny: {str(e)}", ""

# def process_folder_experiment(entry, root_dir, output_dir, slm_model, tokenizer, llm_type):
#     file1= os.path.join(output_dir, f"result_{entry}_llm-gemini_pass@1_with_feedback.json")
#     file1_no_feedback= os.path.join(output_dir, f"result_{entry}_llm-gemini_pass@1_no_feedback.json")
#     file2= os.path.join(output_dir, f"result_{entry}_llm-qwen_pass@1_with_feedback.json")
#     file2_no_feedback= os.path.join(output_dir, f"result_{entry}_llm-qwen_pass@1_no_feedback.json")
#     file3= os.path.join(output_dir, f"result_{entry}_llm-gpt4o_pass@1_with_feedback.json")
#     file3_no_feedback= os.path.join(output_dir, f"result_{entry}_llm-gpt4o_pass@1_no_feedback.json")
#     file4= os.path.join(output_dir, f"result_{entry}_llm-o1mini_pass@1_with_feedback.json")
#     file4_no_feedback= os.path.join(output_dir, f"result_{entry}_llm-o1mini_pass@1_no_feedback.json")
#     file5= os.path.join(output_dir, f"result_{entry}_llm-gemini25flash_pass@1_with_feedback.json")
#     file5_no_feedback= os.path.join(output_dir, f"result_{entry}_llm-gemini25flash_pass@1_no_feedback.json")
#     if llm_type == "gemini":
#         if os.path.exists(file1) and os.path.exists(file1_no_feedback):
#             return
#     elif llm_type == "qwen":
#         if os.path.exists(file2) and os.path.exists(file2_no_feedback):
#             return
#     elif llm_type == "gpt4o":   
#         if os.path.exists(file3) and os.path.exists(file3_no_feedback):
#             return
#     elif llm_type == "o1mini":
#         if os.path.exists(file4) and os.path.exists(file4_no_feedback):
#             return
#     elif llm_type == "gemini25flash":
#         if os.path.exists(file5) and os.path.exists(file5_no_feedback):
#             return
#     # if (os.path.exists(file1) and os.path.exists(file1_no_feedback)) or (os.path.exists(file2) and os.path.exists(file2_no_feedback)) or (os.path.exists(file3) and os.path.exists(file3_no_feedback)) or (os.path.exists(file4) and os.path.exists(file4_no_feedback)) or (os.path.exists(file5) and os.path.exists(file5_no_feedback)):
#     #     return
#     subfolder = os.path.join(root_dir, entry)
#     desc_file = os.path.join(subfolder, "detailed_description.txt")
#     if not os.path.isdir(subfolder) or not os.path.exists(desc_file):
#         return
#     with open(desc_file, "r", encoding='utf-8') as f:
#         task = f.read().strip()
#     tmp_path = os.path.join(subfolder, "test_output.dfy")
#     error_path = os.path.join(subfolder, "test_error.txt")
#     short_prompt = create_short_prompt(task)
#     slm_response = run_slm(slm_model, tokenizer, short_prompt)
#     if llm_type == "gemini":
#         llm_response = run_llm(slm_response)
#     elif llm_type == "qwen":
#         llm_response = run_llm_qwen(slm_response)
#     elif llm_type == "gpt4o":
#         llm_response = run_llm_chatgpt4o(slm_response)
#     elif llm_type == "o1mini":
#         llm_response = run_llm_chatgpto1(slm_response)
#     elif llm_type == "gemini25flash":
#         llm_response = run_llm_gemini_25flash(slm_response)
#     else:
#         raise ValueError("Unknown LLM type")
#     code = extract_dafny_code(llm_response)
#     success, output, final_code = run_dafny(code, tmp_path, error_path)
#     # Save pass@1 no_feedback
#     result_1_no_feedback = {
#         "folder": entry,
#         "llm": llm_type,
#         "pass": 1,
#         "type": "no_feedback",
#         "success": success,
#         "final_code": final_code,
#         "output": output
#     }
#     with open(os.path.join(output_dir, f"result_{entry}_llm-{llm_type}_pass@1_no_feedback.json"), "w") as f:
#         json.dump(result_1_no_feedback, f, indent=2)
#     # Feedback loop for up to 5 attempts
#     attempts = [{"success": success, "output": output, "code": final_code}]
#     for n in range(2, 6):
#         if attempts[-1]["success"] == 1:
#             break
#         error_prompt = create_error_prompt(task, attempts[-1]["code"], attempts[-1]["output"], "-1")
#         slm_response = run_slm(slm_model, tokenizer, error_prompt)
#         if llm_type == "gemini":
#             llm_response = run_llm(slm_response)
#         elif llm_type == "qwen":
#             llm_response = run_llm_qwen(slm_response)
#         elif llm_type == "gpt4o":
#             llm_response = run_llm_chatgpt4o(slm_response)
#         elif llm_type == "o1mini":
#             llm_response = run_llm_chatgpto1(slm_response)
#         elif llm_type == "gemini25flash":
#             llm_response = run_llm_gemini_25flash(slm_response)
#         code = extract_dafny_code(llm_response)
#         success, output, final_code = run_dafny(code, tmp_path, error_path)
#         attempts.append({"success": success, "output": output, "code": final_code})

#     last = attempts[-1]
#     result_1_with_feedback = {
#         "folder": entry,
#         "llm": llm_type,
#         "pass": 1,
#         "type": "with_feedback",
#         "success": last["success"],
#         "final_code": last["code"],
#         "output": last["output"]
#     }
#     with open(os.path.join(output_dir, f"result_{entry}_llm-{llm_type}_pass@1_with_feedback.json"), "w") as f:
#         json.dump(result_1_with_feedback, f, indent=2)

# def main():
#     logging.info("Initializing models...")
#     slm_model, tokenizer = initialize_slm()
#     root_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/TEST"
#     output_dir = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/test_outputs/TEST_WITHOUTTRAINED2"
#     os.makedirs(output_dir, exist_ok=True)
#     entries = [entry for entry in os.listdir(root_dir) if os.path.isdir(os.path.join(root_dir, entry))]
#     llm_types = ["qwen", "gemini25flash"]
    
#     for llm_type in llm_types:
#         logging.info(f"Processing LLM type: {llm_type}")
#         for entry in entries:
#             try:
#                 logging.info(f"Processing entry: {entry}")
#                 process_folder_experiment(entry, root_dir, output_dir, slm_model, tokenizer, llm_type)
#             except Exception as e:
#                 logging.error(f"Error processing folder {entry}: {e}")
#                 continue

# if __name__ == "__main__":
#     main() 




import os
import re
import json
import time
import logging
import subprocess
from typing import Tuple, List, Dict, Any

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
from openai import OpenAI

# ============================================================
# CONFIG
# ============================================================

ROOT_DIR = "/u/mjha1/Proof2Silicon/journal_phase/Input_dataset_3"
OUTPUT_DIR = "/u/mjha1/Proof2Silicon/journal_phase/baseline_outputs_cleaned"

SLM_MODEL_NAME = "Qwen/Qwen2.5-1.5B-Instruct"
LLM_MODELS = [
    "gpt-5.1-codex-max",
    "gpt-5.3-codex",
    "deepseek-chat",
]

MAX_FEEDBACK_ATTEMPTS = 5
DAFNY_TIMEOUT_SEC = 240
SLEEP_BETWEEN_API_CALLS = 2

# ============================================================
# LOGGING
# ============================================================

os.makedirs(OUTPUT_DIR, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(os.path.join(OUTPUT_DIR, "testing.log")),
        logging.StreamHandler()
    ]
)

# ============================================================
# ENV / DEVICE
# ============================================================

os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "expandable_segments:True"
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
logging.info(f"Using device: {device}")

# OpenAI-compatible clients
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "")
DEEPSEEK_API_KEY = os.environ.get("DEEPSEEK_API_KEY", "")

openai_client = OpenAI(api_key=OPENAI_API_KEY) if OPENAI_API_KEY else None
deepseek_client = OpenAI(
    api_key=DEEPSEEK_API_KEY,
    base_url="https://api.deepseek.com"
) if DEEPSEEK_API_KEY else None

# ============================================================
# SLM INIT
# ============================================================

def initialize_slm():
    """Initialize the untrained SLM model for instruction generation."""
    logging.info(f"Loading SLM tokenizer: {SLM_MODEL_NAME}")
    tokenizer = AutoTokenizer.from_pretrained(SLM_MODEL_NAME, trust_remote_code=True)

    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token

    quant_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_compute_dtype=torch.float16,
        bnb_4bit_use_double_quant=True,
        bnb_4bit_quant_type="nf4"
    )

    offload_folder = os.path.join(OUTPUT_DIR, "slm_offload")
    os.makedirs(offload_folder, exist_ok=True)

    logging.info(f"Loading SLM model: {SLM_MODEL_NAME}")
    model = AutoModelForCausalLM.from_pretrained(
        SLM_MODEL_NAME,
        quantization_config=quant_config,
        trust_remote_code=True,
        device_map="auto",
        offload_folder=offload_folder,
        offload_state_dict=True,
        dtype=torch.float16,
        low_cpu_mem_usage=True
    )

    model.eval()
    return model, tokenizer

# ============================================================
# PROMPTS
# ============================================================

def create_short_prompt(task: str) -> str:
    return (
        "You are an expert in Dafny and formal verification. Your job is not to write the final code directly. "
        "Instead, generate a clear instruction for another coding agent that will write the Dafny program.\n\n"
        "Your instruction must help the coding agent produce Dafny code that is verifier-friendly and avoids common errors.\n\n"
        "Include:\n"
        "1. The core logic the program should implement.\n"
        "2. Required Dafny specifications such as requires, ensures, invariants, asserts, decreases if needed.\n"
        "3. Edge cases to handle.\n"
        "4. Common verifier failures to avoid, including syntax mistakes, type mismatches, undefined identifiers, "
        "out-of-bounds access, weak invariants, missing postconditions, and logic/spec mismatches.\n"
        "5. Concrete suggestions for writing code that verifies successfully.\n\n"
        "Task:\n"
        f"{task}\n\n"
        "Return only the instruction text for the coding agent."
    )

def create_error_prompt(task: str, code: str, error: str, reward: str) -> str:
    return (
        "You are an expert in Dafny and formal verification. A coding agent previously wrote Dafny code based on your instruction, "
        "but the code failed verification or compilation.\n\n"
        "Generate a revised instruction for the coding agent.\n\n"
        "Your revised instruction must:\n"
        "1. Explain what likely went wrong.\n"
        "2. Tell the coding agent how to fix the Dafny code.\n"
        "3. Strengthen specifications, invariants, assertions, bounds reasoning, typing, and verifier guidance as needed.\n"
        "4. Explicitly guard against syntax errors, undefined variables, type errors, out-of-bounds errors, weak invariants, "
        "missing proof steps, and logic mistakes.\n"
        "5. Focus on producing Dafny code that verifies successfully.\n\n"
        f"Task:\n{task}\n\n"
        f"Previous code:\n{code}\n\n"
        f"Verifier/compiler output:\n{error}\n\n"
        f"Reward from previous attempt:\n{reward}\n\n"
        "Return only the revised instruction text for the coding agent."
    )

def create_llm_code_prompt(instruction: str) -> str:
    return (
        f"{instruction}"
        "Return it in this exact format:\n"
        "```dafny\n"
        "// Dafny code here\n"
        "```\n\n"
    )

# ============================================================
# MODEL RUNNERS
# ============================================================

def run_slm(model, tokenizer, prompt: str) -> str:
    """Run the SLM model to generate instruction text."""
    try:
        generation_config = {
            "max_new_tokens": 1024,
            "do_sample": True,
            "temperature": 0.7,
            "top_p": 0.95,
            "top_k": 50,
            "num_beams": 1,
            "pad_token_id": tokenizer.pad_token_id,
            "eos_token_id": tokenizer.eos_token_id,
        }

        inputs = tokenizer(prompt, return_tensors="pt", truncation=True, padding=True)
        inputs = {k: v.to(model.device) for k, v in inputs.items()}

        model.eval()
        with torch.no_grad():
            out = model.generate(**inputs, **generation_config)

        response = tokenizer.decode(out[0], skip_special_tokens=True)

        if response.startswith(prompt):
            response = response[len(prompt):].strip()

        return response.strip()

    except Exception as e:
        logging.error(f"Error in run_slm: {str(e)}")
        return ""

def run_llm(prompt: str, model_name: str) -> str:
    """Run one of: gpt-5.1-codex-max, gpt-5.3-codex, deepseek-chat"""
    try:
        full_prompt = create_llm_code_prompt(prompt)

        if model_name.startswith("gpt-5"):
            if openai_client is None:
                raise RuntimeError("OPENAI_API_KEY is not set.")

            response = openai_client.responses.create(
                model=model_name,
                instructions="You are a precise Dafny code generation assistant.",
                input=full_prompt,
            )
            text = response.output_text

        elif model_name == "deepseek-chat":
            if deepseek_client is None:
                raise RuntimeError("DEEPSEEK_API_KEY is not set.")

            response = deepseek_client.chat.completions.create(
                model=model_name,
                messages=[
                    {"role": "system", "content": "You are a precise Dafny code generation assistant."},
                    {"role": "user", "content": full_prompt}
                ],
                temperature=0.7
            )
            text = response.choices[0].message.content

        else:
            raise ValueError(f"Unsupported model: {model_name}")

        time.sleep(SLEEP_BETWEEN_API_CALLS)
        return text.strip() if text else ""

    except Exception as e:
        logging.error(f"Error in run_llm for {model_name}: {str(e)}")
        return ""

# ============================================================
# DAFNY UTILS
# ============================================================

def extract_dafny_code(text: str) -> str:
    """Extract Dafny code from markdown fenced block."""
    pattern = r"```dafny(.*?)```"
    snippets = re.findall(pattern, text, re.DOTALL | re.IGNORECASE)
    return snippets[-1].strip() if snippets else ""

def run_dafny(code: str, tmp_path: str, error_path: str) -> Tuple[int, str, str]:
    """
    Run Dafny verification on the generated code using:
        dafny <file_name>

    Returns:
        success_code:
            1 => verified success
            0 => ran but failed verify/compile
           -1 => exception / empty
    """
    if not code or code.strip() == "":
        return -1, "Error: Empty Dafny file", ""

    try:
        with open(tmp_path, "w", encoding="utf-8") as f:
            f.write(code)

        cmd = ["dafny", tmp_path]

        result = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=DAFNY_TIMEOUT_SEC,
            text=True
        )

        output = result.stdout

        with open(error_path, "w", encoding="utf-8") as f:
            f.write(output)

        if "verified, 0 errors" in output and "Compiled assembly into" in output:
            return 1, output, code
        return 0, output, code

    except subprocess.TimeoutExpired:
        msg = f"TIMEOUT after {DAFNY_TIMEOUT_SEC} seconds"
        with open(error_path, "w", encoding="utf-8") as f:
            f.write(msg)
        return 0, msg, code

    except Exception as e:
        msg = f"Error running Dafny: {str(e)}"
        with open(error_path, "w", encoding="utf-8") as f:
            f.write(msg)
        return -1, msg, ""

# ============================================================
# FILE HELPERS
# ============================================================

def save_json(path: str, data: Dict[str, Any]) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def get_task_text(subfolder: str) -> str:
    """
    Prefer detailed_description.txt if present.
    Fallback to one_line_description.txt.
    """
    detailed_file = os.path.join(subfolder, "detailed_description.txt")
    one_line_file = os.path.join(subfolder, "one_line_description.txt")

    if os.path.exists(detailed_file):
        with open(detailed_file, "r", encoding="utf-8") as f:
            return f.read().strip()

    if os.path.exists(one_line_file):
        with open(one_line_file, "r", encoding="utf-8") as f:
            return f.read().strip()

    return ""

# ============================================================
# EXPERIMENT LOOP
# ============================================================

def process_folder_experiment(
    entry: str,
    root_dir: str,
    output_dir: str,
    slm_model,
    tokenizer,
    llm_model_name: str
) -> None:
    subfolder = os.path.join(root_dir, entry)
    if not os.path.isdir(subfolder):
        return

    task = get_task_text(subfolder)
    if not task:
        logging.warning(f"Skipping {entry}: no description file found")
        return

    safe_llm_name = llm_model_name.replace("/", "_")
    result_no_feedback_path = os.path.join(
        output_dir, f"result_{entry}_llm-{safe_llm_name}_pass@1_no_feedback.json"
    )
    result_with_feedback_path = os.path.join(
        output_dir, f"result_{entry}_llm-{safe_llm_name}_pass@1_with_feedback.json"
    )

    if os.path.exists(result_no_feedback_path) and os.path.exists(result_with_feedback_path):
        logging.info(f"Skipping {entry} for {llm_model_name}: results already exist")
        return

    tmp_path = os.path.join(output_dir, f"{entry}_{safe_llm_name}_test_output.dfy")
    error_path = os.path.join(output_dir, f"{entry}_{safe_llm_name}_test_error.txt")

    # ---------------------------
    # Pass@1 no feedback
    # ---------------------------
    short_prompt = create_short_prompt(task)
    slm_response = run_slm(slm_model, tokenizer, short_prompt)
    llm_response = run_llm(slm_response, llm_model_name)
    code = extract_dafny_code(llm_response)
    success, output, final_code = run_dafny(code, tmp_path, error_path)

    result_1_no_feedback = {
        "folder": entry,
        "llm": llm_model_name,
        "pass": 1,
        "type": "no_feedback",
        "task": task,
        "slm_prompt": short_prompt,
        "slm_response": slm_response,
        "llm_response": llm_response,
        "success": success,
        "final_code": final_code,
        "output": output
    }
    save_json(result_no_feedback_path, result_1_no_feedback)

    # ---------------------------
    # Feedback loop
    # ---------------------------
    attempts: List[Dict[str, Any]] = [{
        "attempt": 1,
        "success": success,
        "output": output,
        "code": final_code,
        "slm_prompt": short_prompt,
        "slm_response": slm_response,
        "llm_response": llm_response
    }]

    for n in range(2, MAX_FEEDBACK_ATTEMPTS + 1):
        if attempts[-1]["success"] == 1:
            break

        error_prompt = create_error_prompt(
            task=task,
            code=attempts[-1]["code"],
            error=attempts[-1]["output"],
            reward="-1"
        )

        slm_response = run_slm(slm_model, tokenizer, error_prompt)
        llm_response = run_llm(slm_response, llm_model_name)
        code = extract_dafny_code(llm_response)
        success, output, final_code = run_dafny(code, tmp_path, error_path)

        attempts.append({
            "attempt": n,
            "success": success,
            "output": output,
            "code": final_code,
            "slm_prompt": error_prompt,
            "slm_response": slm_response,
            "llm_response": llm_response
        })

    last = attempts[-1]
    result_1_with_feedback = {
        "folder": entry,
        "llm": llm_model_name,
        "pass": 1,
        "type": "with_feedback",
        "task": task,
        "success": last["success"],
        "final_code": last["code"],
        "output": last["output"],
        "attempts": attempts
    }
    save_json(result_with_feedback_path, result_1_with_feedback)

# ============================================================
# MAIN
# ============================================================

def main():
    logging.info("Initializing SLM...")
    slm_model, tokenizer = initialize_slm()

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    entries = [
        entry for entry in os.listdir(ROOT_DIR)
        if os.path.isdir(os.path.join(ROOT_DIR, entry))
    ]

    logging.info(f"Found {len(entries)} task folders in {ROOT_DIR}")

    for llm_model_name in LLM_MODELS:
        logging.info(f"Processing LLM model: {llm_model_name}")
        for entry in entries:
            try:
                logging.info(f"Processing entry: {entry}")
                process_folder_experiment(
                    entry=entry,
                    root_dir=ROOT_DIR,
                    output_dir=OUTPUT_DIR,
                    slm_model=slm_model,
                    tokenizer=tokenizer,
                    llm_model_name=llm_model_name
                )
            except Exception as e:
                logging.error(f"Error processing folder {entry} with {llm_model_name}: {e}")
                continue

if __name__ == "__main__":
    main()