import os
import time
import openai

# Set up your OpenAI API key
# openai.api_key = "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"

def generate_prompt(file_contents):
    """
    Generates the prompt for the API by including the contents of four files.
    """
    prompt = (
        "Given below are four separate code files written in DAFNY. "
        "Write a 2-3 sentence statement describing what the code is doing or verifying. "
        "The output format should be: <generated_description> \\n \\n <Given_code> \\n\\n \"END OF ONE FILE\"\n\n"
        "The codes are:\n"
    )
    for i, content in enumerate(file_contents, start=1):
        prompt += f"code file-{i}:\n{content}\n\n"
    return prompt


from openai import OpenAI

client = OpenAI(
  api_key="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"
)



# print(completion.choices[0].message);

def call_openai_api_with_roles(system_message, user_message):
    """
    Calls the OpenAI Chat API with a system message and user message.
    """
    try:
        # response = openai.ChatCompletion.create(
        #     model="gpt-4o-mini",  # You can modify the model if needed
        #     messages=[
        #         {"role": "system", "content": system_message},
        #         {"role": "user", "content": user_message},
        #     ],
        #     max_tokens=60000,
        #     temperature=0.7,
        # )

        completion = client.chat.completions.create(
        model="gpt-4o-mini",
        store=True,
        messages=[
            {"role": "system", "content": system_message},
            {"role": "user", "content": user_message},
        ]
        )
        return completion.choices[0].message
    except Exception as e:
        print(f"Error calling OpenAI API: {e}")
        return None

def main(folder_path, output_file):
    """
    Processes Dafny code files, sends them to the OpenAI API in batches of four, 
    and saves the results to the output file.
    """
    # System message to set the model's role
    system_message = (
        "You are an expert in analyzing Dafny code. Your task is to read the code provided, "
        "identify its purpose or verification goal, and write a concise 2-3 sentence description "
        "for each code file."
    )

    # Get a list of all Dafny code files in the folder
    files = [f for f in os.listdir(folder_path) if f.endswith(".dfy")]

    if not files:
        print("No Dafny code files found in the specified folder.")
        return

    # Open the output file for writing
    with open(output_file, "w") as output:
        for i in range(0, len(files), 4):
            # Select up to four files for the current batch
            batch_files = files[i:i+4]
            file_contents = []

            # Read the contents of each file in the batch
            for file_name in batch_files:
                with open(os.path.join(folder_path, file_name), "r") as f:
                    file_contents.append(f.read())

            # Generate the user message
            user_message = generate_prompt(file_contents)
            # print(user_message)

            # Call the OpenAI API with the system and user messages
            print(f"Processing files: {batch_files}")
            result = call_openai_api_with_roles(system_message, user_message)

            # Write the result to the output file
            if result:
                output.write(f"Files: {', '.join(batch_files)}\n")
                output.write(str(result) + "\n")
                output.write("=" * 50 + "\n")  # Separator for results

            # Enforce rate-limiting (3 calls per minute)
            time.sleep(20)  # Wait for 20 seconds between API calls

    print("Processing complete. Results saved to:", output_file)

# Example usage
folder_path = input("Enter the path to the folder containing Dafny files: ").strip()
output_file = "output_descriptions.txt"
main(folder_path, output_file)



# from openai import OpenAI
# client = client = OpenAI(
#   api_key="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"
# )

# completion = client.chat.completions.create(
#     model="gpt-4o-mini",
#     messages=[
#         {"role": "developer", "content": "You are a helpful assistant."},
#         {
#             "role": "user",
#             "content": "Write a haiku about recursion in programming."
#         }
#     ]
# )

# print(completion.choices[0].message)