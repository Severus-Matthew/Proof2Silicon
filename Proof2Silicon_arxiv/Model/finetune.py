import os
from datasets import load_dataset
from transformers import AutoTokenizer, AutoModelForCausalLM, Trainer, TrainingArguments
from peft import LoraConfig, get_peft_model

# 1. Configuration
model_name = "Qwen/Qwen2.5-Coder-14B"  # e.g., "facebook/opt-1.5b"
train_file = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny/output.jsonl"             # JSON lines with fields "code" and "description"
eval_file = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/TEST/output_test.jsonl"               # Optional: evaluation split
output_dir = "./lora-finetuned"
seq_length = 1000
batch_size = 1
num_epochs = 7

# 2. Load dataset
data_files = {"train": train_file}
if os.path.exists(eval_file):
    data_files["validation"] = eval_file
print("Loading dataset...")

raw_ds = load_dataset("json", data_files=data_files)

# 3. Load tokenizer
tokenizer = AutoTokenizer.from_pretrained(model_name, use_fast=False)
if tokenizer.pad_token_id is None:
    tokenizer.pad_token = tokenizer.eos_token

# 4. Preprocess examples: concatenate description and code
def preprocess_fn(examples):
    inputs = [
        f"### Description:\n{desc}\n\n### Code:\n{code}"
        for code, desc in zip(examples["code"], examples["description"])
    ]
    model_inputs = tokenizer(
        inputs,
        max_length=seq_length,
        padding="max_length",
        truncation=True,
    )
    # labels are the same as inputs for causal LM
    model_inputs["labels"] = model_inputs["input_ids"].copy()
    return model_inputs

tokenized_ds = raw_ds.map(
    preprocess_fn,
    batched=True,
    remove_columns=["code", "description"],
)

# 5. Load base model
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    load_in_4bit=True,            # 4-bit quantization to save memory
    device_map="cuda:0",          # explicitly use first GPU
)

# 6. Prepare LoRA configuration
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj"],  # adjust based on model architecture
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM",
)

model = get_peft_model(model, lora_config)
model.print_trainable_parameters()

# 7. Training arguments
training_args = TrainingArguments(
    output_dir=output_dir,
    per_device_train_batch_size=batch_size,
    per_device_eval_batch_size=batch_size,
    gradient_accumulation_steps=4,   # effective batch size = batch_size * 4
    num_train_epochs=num_epochs,
    learning_rate=2e-4,
    fp16=True,
    logging_steps=50,
    save_steps=500,                 # Save every 500 steps
    save_total_limit=3,
    remove_unused_columns=False,
    warmup_steps=100,
    weight_decay=0.01,          # explicitly use first GPU
)

# 8. Initialize Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_ds["train"],
    eval_dataset=tokenized_ds.get("validation", None),
    tokenizer=tokenizer,
)

# 9. Start training
trainer.train()
trainer.save_model(output_dir)

print("LoRA fine-tuning complete. Model saved to", output_dir)

# /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny/Dafny(75)/detailed_description.txt

# import os
# import json

# def collect_examples(root_dir):
#     examples = []
#     for entry in os.scandir(root_dir):
#         if not entry.is_dir():
#             continue
#         folder = entry.name
#         folder_path = entry.path

#         # 1) Read description.txt
#         desc_path = os.path.join(folder_path, "detailed_description.txt")
#         try:
#             with open(desc_path, "r", encoding="utf-8") as f:
#                 description = f.read().strip()
#         except FileNotFoundError:
#             print(f"⚠️  Skipping '{folder}': no description.txt")
#             continue

#         # 2) Find the Dafny file (foldername.dfy or .dafny)
#         code = None
#         for ext in (".dfy", ".dafny"):
#             code_path = os.path.join(folder_path, folder + ext)
#             if os.path.isfile(code_path):
#                 with open(code_path, "r", encoding="utf-8") as f:
#                     code = f.read()
#                 break
#         if code is None:
#             print(f"⚠️  Skipping '{folder}': no '{folder}.dfy/.dafny'")
#             continue

#         examples.append({
#             "description": description,
#             "code": code
#         })

#     return examples

# if __name__ == "__main__":
#     # Change this to your parent directory
#     ROOT = "/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/TEST"

#     data = collect_examples(ROOT)
#     out_path = os.path.join(ROOT, "output_test.json")
#     with open(out_path, "w", encoding="utf-8") as out:
#         json.dump(data, out, indent=2, ensure_ascii=False)

#     print(f"✅  Wrote {len(data)} examples to {out_path!r}")


# import json

# with open("/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny/output.json", "r", encoding="utf-8") as f:
#     data = json.load(f)

# with open("/mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/dataset/Dafny/output.jsonl", "w", encoding="utf-8") as out:
#     for obj in data:
#         out.write(json.dumps(obj, ensure_ascii=False) + "\n")
