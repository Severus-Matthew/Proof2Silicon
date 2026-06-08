#!/bin/bash
#SBATCH --job-name=preface_baselines
#SBATCH --output=logs/baselines_%j.out
#SBATCH --error=logs/baselines_%j.err
#SBATCH --account=bgrm-dtai-gh
#SBATCH --partition=ghx4              # change if needed
#SBATCH --gres=gpu:1                  # needed for SLM (Qwen)
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00

# ==============================
# ENV SETUP
# ==============================
echo "Starting job on $(hostname)"
echo "CUDA devices: $CUDA_VISIBLE_DEVICES"

# Avoid fragmentation (important for your runs)
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128,expandable_segments:True
export TOKENIZERS_PARALLELISM=false

# Activate your env (EDIT THIS)
source ~/rl_env311/bin/activate
echo "source ~/rl_env311/bin/activate ok"

# Make sure OpenAI key exists
export OPENAI_API_KEY="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"

# Optional: avoid OOM crashes
ulimit -n 65536

# ==============================
# PATHS
# ==============================
CODE_PATH=/u/mjha1/Proof2Silicon/Proof2Silicon_arxiv/Baselines/
SCRIPT_NAME=Baseline_Chatgpt_5_1_max.py  # <-- rename to your actual file

cd $CODE_PATH

# ==============================
# RUN
# ==============================
python $SCRIPT_NAME \
    --experiment_mode llm_only \
    --prompt_types short shortanddetailed fewshot \
    --workers 8 \
    --max_iterations 7 \
    --temperature 0.25 \
    --dafny_timeout 180 \
    --output_root_name baseline_runs_v2 \
    --base_folders /u/mjha1/Proof2Silicon/journal_phase/Input_dataset_3

echo "Job finished"