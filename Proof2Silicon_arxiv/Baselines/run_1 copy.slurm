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
export PYTHONNOUSERSITE=1
echo "source ~/rl_env311/bin/activate ok"

# Make sure OpenAI key exists
export OPENAI_API_KEY="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"
export DEEPSEEK_API_KEY="sk-d7844b60db514574982d2e06c7f66fca"
# Optional: avoid OOM crashes
ulimit -n 65536

echo "===== PYTHON ====="
which python
python --version

echo "===== TORCH CUDA CHECK ====="
python - <<'PY'
import torch, sys
print("python:", sys.executable)
print("torch version:", torch.__version__)
print("torch cuda version:", torch.version.cuda)
print("cuda available:", torch.cuda.is_available())
print("cuda device count:", torch.cuda.device_count())
if torch.cuda.is_available():
    print("device 0:", torch.cuda.get_device_name(0))
PY

echo "===== NVIDIA SMI ====="
nvidia-smi


python -c "import bitsandbytes as bnb; print(bnb.__version__)"
# ==============================
# PATHS
# ==============================
CODE_PATH=/u/mjha1/Proof2Silicon/Proof2Silicon_arxiv/Baselines/

cd $CODE_PATH

# ==============================
# RUN
# ==============================
python /u/mjha1/Proof2Silicon/Proof2Silicon_arxiv/Baselines/test_without_train.py

echo "Job finished"