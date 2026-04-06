#!/bin/bash
#SBATCH --job-name=dafny_full
#SBATCH --output=dafny_full_%j.out
#SBATCH --error=dafny_full_%j.err
#SBATCH --account=bgrm-dtai-gh
#SBATCH --partition=ghx4
#SBATCH --nodes=2
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=6
#SBATCH --gres=gpu:1
#SBATCH --time=2-00:00:00

set -euo pipefail

# --------------------------------------------------
# Environment setup
# --------------------------------------------------

export PYTHONUNBUFFERED=1
export TOKENIZERS_PARALLELISM=false
export PYTHONPATH=/u/mjha1/Proof2Silicon/journal_phase/CODEBASE:${PYTHONPATH:-}
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
nvidia-smi
echo "nvidia-smi ok"
module purge
echo "module purge ok"
module load gcc-native/14
echo "module load gcc-native/14 ok"
module load cuda/12.9
echo "module load cuda/12.9 ok"
module load python/miniforge3_pytorch/2.10.0
echo "module load python/miniforge3_pytorch/2.10.0 ok"
conda activate base
echo "conda activate base ok"
# Activate environment
source ~/rl_env311/bin/activate
echo "source ~/rl_env311/bin/activate ok"
python3 -m pip list
echo "python3 -m pip list ok"

# --------------------------------------------------
# Move to project
# --------------------------------------------------

cd /u/mjha1/Proof2Silicon/journal_phase/CODEBASE

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
