import os
import shutil

# Paths
output_descriptions_path = 'C:\\Users\\drpro\\Downloads\\output_descriptions.txt'
one_line_path = 'C:\\Users\\drpro\\Downloads\\one_line.txt'
base_folder = 'D:\\UIUC_PROJ_2\\Data_verified_compiled'

# Read files
def read_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read().strip().split('==================================================')

# Parse content
output_descriptions = read_file(output_descriptions_path)
one_line_descriptions = read_file(one_line_path)

# Extract data
def extract_data(entries):
    data = {}
    for entry in entries:
        lines = entry.strip().split('\n')
        if lines:
            file_line = lines[0]
            if file_line.startswith("Files: "):
                file_name = file_line.replace("Files: ", "").strip()
                description = '\n'.join(lines[1:]).strip()
                description = description.replace("ChatCompletionMessage(content='", "").strip()
                description = description.replace('ChatCompletionMessage(content="', "").strip()
                text= "', "+"refusal=None, role='assistant', audio=None, function_call=None, tool_calls=None)"
                text2 =  '", '+"refusal=None, role='assistant', audio=None, function_call=None, tool_calls=None)"
                description = description.replace(text, "").strip()
                description = description.replace(text2, "").strip()
                # description = "hi"
                data[file_name] = description
                # print(data)
                # print("+++++++++++++++++++++++++")
    return data


def extract_data_one(entries):
    data = {}
    for entry in entries:
        lines = entry.strip().split('\n')
        if lines:
            file_line = lines[0]
            if file_line.startswith("Original Description: "):
                file_name = file_line.replace("Original Description: ", "").strip()
                description = '\n'.join(lines[1:]).strip()
                description = description.replace("One-Line Description: ChatCompletionMessage(content='", "").strip()
                description = description.replace('One-Line Description: ChatCompletionMessage(content="', "").strip()
                text= "', "+"refusal=None, role='assistant', audio=None, function_call=None, tool_calls=None)"
                text2 =  '", '+"refusal=None, role='assistant', audio=None, function_call=None, tool_calls=None)"
                description = description.replace(text, "").strip()
                description = description.replace(text2, "").strip()
                # description = "hi"
                data[file_name] = description
                # print(data)
                # print("+++++++++++++++++++++++++")
    return data


output_data = extract_data(output_descriptions)
one_line_data = extract_data_one(one_line_descriptions)

# Create folders and write files
os.makedirs(base_folder, exist_ok=True)

for file_name, detailed_description in output_data.items():
    if detailed_description in one_line_data:
        one_line_description = one_line_data[detailed_description]
        filename2= file_name.replace(".dfy", "")
        subfolder_path = os.path.join(base_folder, filename2)
        os.makedirs(subfolder_path, exist_ok=True)

        # Copy Dafny file (if available)
        dafny_file_path = os.path.join('D:\\UIUC_PROJ_2\\Data_verified_compiled', file_name)
        if os.path.exists(dafny_file_path):
            shutil.copy(dafny_file_path, subfolder_path)

        # Write descriptions
        with open(os.path.join(subfolder_path, 'detailed_description.txt'), 'w', encoding='utf-8') as detailed_file:
            detailed_file.write(detailed_description)

        with open(os.path.join(subfolder_path, 'one_line_description.txt'), 'w', encoding='utf-8') as one_line_file:
            one_line_file.write(one_line_description)

print(f"Organized files are stored in: {base_folder}")
