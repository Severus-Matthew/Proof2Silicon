#!/bin/bash
#SBATCH --job-name=dafny_full
#SBATCH --output=dafny_full_%j.out
#SBATCH --error=dafny_full_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --gres=gpu:1
#SBATCH --partition=gpu-h100-dchen
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=drprofmjha@gmail.com

set -euo pipefail

# --------------------------------------------------
# Environment setup
# --------------------------------------------------

export PYTHONUNBUFFERED=1
export TOKENIZERS_PARALLELISM=false
export PYTHONPATH=/mnt/shared/gpfs/home/manvij2/journal_phase/CODEBASE:${PYTHONPATH:-}
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:128

# Optional but useful for stability
export CUDA_LAUNCH_BLOCKING=0
export WANDB__SERVICE_WAIT=300

echo "=============================="
echo "Starting FULL training at $(date)"
echo "Host: $(hostname)"
echo "Working dir: $(pwd)"
echo "=============================="

nvidia-smi

# --------------------------------------------------
# Activate environment
# --------------------------------------------------

source /mnt/shared/gpfs/home/manvij2/dafny/bin/activate

# --------------------------------------------------
# Move to project
# --------------------------------------------------

cd /mnt/shared/gpfs/home/manvij2/journal_phase/CODEBASE

# --------------------------------------------------
# Run training
# --------------------------------------------------

echo "=============================="
echo "Running FULL TRAINING"
echo "=============================="

python main.py \
  --start_epoch 0 \
  --wandb_project dafny-rl_full \
  --wandb_entity drprofmjha-university-of-illinois-urbana-champaign \
  --max_workers 1 \
  2>&1 | tee full_run.log

echo "=============================="
echo "Finished at $(date)"
echo "=============================="