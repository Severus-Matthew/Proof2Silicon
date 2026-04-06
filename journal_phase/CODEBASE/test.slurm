#!/bin/bash -l
#SBATCH --job-name=dafny_smoke
#SBATCH --output=dafny_smoke_%j.out
#SBATCH --error=dafny_smoke_%j.err
#SBATCH --account=bgrm-dtai-gh
#SBATCH --partition=ghx4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=00:30:00

set -euo pipefail

export PYTHONUNBUFFERED=1
export TOKENIZERS_PARALLELISM=false
export PYTHONPATH=/u/mjha1/Proof2Silicon/journal_phase/CODEBASE:${PYTHONPATH:-}
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:128

echo "=============================="
echo "Starting smoke test at $(date)"
echo "Host: $(hostname)"
echo "Working dir: $(pwd)"
echo "Python: $(which python3)"
echo "=============================="

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
# Go to project root
cd /u/mjha1/Proof2Silicon/journal_phase/CODEBASE
export WANDB_MODE=online
export WANDB_DIR=/u/mjha1/wandb_logs
echo "export WANDB_MODE=online ok"
echo "export WANDB_DIR=/u/mjha1/wandb_logs ok"
echo "=============================="
echo "Import smoke test"
echo "=============================="
python3 -c "from preface_rl.envs import DafnyEnv; from preface_rl.slm import initialize_slm, train_slm_with_grpo; print('imports ok')"

echo "=============================="
echo "CUDA smoke test"
echo "=============================="
python3 -c "import torch; print('cuda_available=', torch.cuda.is_available()); print('device_count=', torch.cuda.device_count()); print('device_name=', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'cpu')"

echo "=============================="
echo "Model load smoke test"
echo "=============================="
python3 -c "from preface_rl.slm import initialize_slm; m,t=initialize_slm(None); print('model/tokenizer load ok')"

echo "=============================="
echo "Running main smoke test"
echo "=============================="
python3 main.py \
  --checkpoint /u/mjha1/Proof2Silicon/journal_phase/checkpoints/run_CHK/test_new.pt \
  --start_epoch 0 \
  --wandb_project dafny-rl_new2 \
  --wandb_entity drprofmjha-university-of-illinois-urbana-champaign \
  --max_workers 1 2>&1 | tee smoke_test.log

echo "Finished at $(date)"