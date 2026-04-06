#!/bin/bash
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


source /etc/profile
module purge
module load gcc-native/14
module load cuda/12.9
module load python/miniforge3_pytorch/2.10.0
conda activate base

python - <<'EOF'
import torch
print(torch.__version__)
print(torch.version.cuda)
print(torch.cuda.is_available())
print(torch.cuda.device_count())
EOF