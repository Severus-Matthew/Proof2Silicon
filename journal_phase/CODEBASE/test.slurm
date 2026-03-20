#!/bin/bash
#SBATCH --job-name=dafny_smoke
#SBATCH --output=dafny_smoke_%j.out
#SBATCH --error=dafny_smoke_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --partition=gpu-l40-dchen
#SBATCH --time=00:30:00
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=drprofmjha@gmail.com

set -euo pipefail

export PYTHONUNBUFFERED=1
export TOKENIZERS_PARALLELISM=false
export PYTHONPATH=/mnt/shared/gpfs/home/manvij2/journal_phase/CODEBASE:${PYTHONPATH:-}
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:128

echo "=============================="
echo "Starting smoke test at $(date)"
echo "Host: $(hostname)"
echo "Working dir: $(pwd)"
echo "Python: $(which python)"
echo "=============================="

nvidia-smi

# Activate environment
source /mnt/shared/gpfs/home/manvij2/dafny/bin/activate

# Go to project root
cd /mnt/shared/gpfs/home/manvij2/journal_phase/CODEBASE

echo "=============================="
echo "Import smoke test"
echo "=============================="
python -c "from preface_rl.envs import DafnyEnv; from preface_rl.slm import initialize_slm, train_slm_with_grpo; print('imports ok')"

echo "=============================="
echo "CUDA smoke test"
echo "=============================="
python -c "import torch; print('cuda_available=', torch.cuda.is_available()); print('device_count=', torch.cuda.device_count()); print('device_name=', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'cpu')"

echo "=============================="
echo "Model load smoke test"
echo "=============================="
python -c "from preface_rl.slm import initialize_slm; m,t=initialize_slm(None); print('model/tokenizer load ok')"

echo "=============================="
echo "Running main smoke test"
echo "=============================="
python main.py \
  --checkpoint /mnt/shared/gpfs/home/manvij2/checkpoints/run_CHK/test_new.pt \
  --start_epoch 0 \
  --wandb_project dafny-rl_new2 \
  --wandb_entity drprofmjha-university-of-illinois-urbana-champaign \
  --max_workers 1 2>&1 | tee smoke_test.log

echo "Finished at $(date)"