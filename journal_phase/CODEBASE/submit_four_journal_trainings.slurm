#!/bin/bash -l
#SBATCH --job-name=p2s_journal
#SBATCH --output=p2s_journal_%A_%a.out
#SBATCH --error=p2s_journal_%A_%a.err
#SBATCH --account=bgrm-dtai-gh
#SBATCH --partition=ghx4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=24:00:00
#SBATCH --array=0-3

set -euo pipefail

# Submit with the API keys already exported in the login shell:
# sbatch --export=ALL submit_four_journal_trainings.slurm
: "${OPENAI_API_KEY:?Export OPENAI_API_KEY before sbatch}"
: "${DEEPSEEK_API_KEY:?Export DEEPSEEK_API_KEY before sbatch}"
: "${HF_TOKEN:?Export HF_TOKEN before sbatch}"

export PYTHONUNBUFFERED=1
export TOKENIZERS_PARALLELISM=false
export PYTHONPATH=/u/mjha1/Proof2Silicon/journal_phase/CODEBASE:${PYTHONPATH:-}
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:128
export HF_HOME=/u/mjha1/.cache/huggingface

ROOT=/u/mjha1/Proof2Silicon/journal_phase
CODEBASE=$ROOT/CODEBASE
ARRAY_ID=${SLURM_ARRAY_TASK_ID:?}

case "$ARRAY_ID" in
  0) EXPERIMENT=deepseek ;;
  1) EXPERIMENT=openai ;;
  2) EXPERIMENT=qwen_hf ;;
  3) EXPERIMENT=mixed ;;
  *) echo "Invalid array task: $ARRAY_ID" >&2; exit 2 ;;
esac

export PROOF2SILICON_EXPERIMENT=$EXPERIMENT
export DAFNY_GENERATOR_MODE=$EXPERIMENT
export DAFNY_MIXED_GENERATORS=deepseek,openai,qwen_hf
export DAFNY_MIXED_SEED=20260802

# All four runs use the identical trainable SLM.
export SLM_MODEL_NAME=Qwen/Qwen3-1.7B

# Generator configurations.
export DEEPSEEK_GENERATOR_MODEL=deepseek-chat
export OPENAI_GENERATOR_MODEL=gpt-5.4-mini
export OPENAI_GENERATOR_REASONING=medium
export HF_GENERATOR_MODEL=Qwen/Qwen3-Coder-30B-A3B-Instruct:cheapest
export HF_BASE_URL=https://router.huggingface.co/v1

# Independent semantic judge for every run.
export DAFNY_JUDGE_PROVIDER=openai
export DAFNY_JUDGE_MODEL=gpt-5.4
export DAFNY_JUDGE_REASONING=high
export DAFNY_JUDGE_MAX_TOKENS=128

RUN_KEY=${SLURM_ARRAY_JOB_ID}_${ARRAY_ID}_${EXPERIMENT}
export WANDB_RUN_NAME=journal_${EXPERIMENT}_${SLURM_ARRAY_JOB_ID}_${ARRAY_ID}
export WANDB_RUN_ID=p2s_${RUN_KEY}
export WANDB_MODE=online
export WANDB_DIR=/u/mjha1/wandb_logs/$WANDB_RUN_NAME
export PROOF2SILICON_RUN_DIR=$ROOT/journal_runs/$WANDB_RUN_NAME
CHECKPOINT=$PROOF2SILICON_RUN_DIR/checkpoints/final_model.pt

mkdir -p "$WANDB_DIR" "$PROOF2SILICON_RUN_DIR/checkpoints"

cat > "$PROOF2SILICON_RUN_DIR/config.env" <<EOF
EXPERIMENT=$EXPERIMENT
SLM_MODEL_NAME=$SLM_MODEL_NAME
DAFNY_GENERATOR_MODE=$DAFNY_GENERATOR_MODE
DEEPSEEK_GENERATOR_MODEL=$DEEPSEEK_GENERATOR_MODEL
OPENAI_GENERATOR_MODEL=$OPENAI_GENERATOR_MODEL
OPENAI_GENERATOR_REASONING=$OPENAI_GENERATOR_REASONING
HF_GENERATOR_MODEL=$HF_GENERATOR_MODEL
DAFNY_JUDGE_MODEL=$DAFNY_JUDGE_MODEL
DAFNY_JUDGE_REASONING=$DAFNY_JUDGE_REASONING
DAFNY_MIXED_SEED=$DAFNY_MIXED_SEED
SLURM_JOB_ID=$SLURM_JOB_ID
SLURM_ARRAY_JOB_ID=$SLURM_ARRAY_JOB_ID
SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID
EOF

printf '%s\n' "==============================" \
  "Starting $EXPERIMENT at $(date)" \
  "Host: $(hostname)" \
  "Slurm job: $SLURM_JOB_ID array task: $SLURM_ARRAY_TASK_ID" \
  "Run directory: $PROOF2SILICON_RUN_DIR" \
  "=============================="

nvidia-smi
module purge
module load gcc-native/14
module load cuda/12.9
module load python/miniforge3_pytorch/2.10.0
conda activate base
source ~/rl_env311/bin/activate

cd "$CODEBASE"

python3 - <<'PY'
import torch
print("torch", torch.__version__)
print("cuda_available", torch.cuda.is_available())
print("device_count", torch.cuda.device_count())
print("device", torch.cuda.get_device_name(0) if torch.cuda.is_available() else "cpu")
assert torch.cuda.is_available(), "GPU is unavailable"
PY

# Verify API/model access before spending time loading the SLM.
python3 preflight_models.py

# Verify Qwen3-1.7B and LoRA initialization on the allocated GPU.
python3 - <<'PY'
from preface_rl.slm_qwen3 import initialize_slm, trainable_parameter_snapshot
model, tokenizer = initialize_slm(None)
print("SLM loaded:", model.config._name_or_path)
print("trainable snapshot:", trainable_parameter_snapshot(model))
PY

python3 journal_main.py \
  --checkpoint "$CHECKPOINT" \
  --start_epoch 0 \
  --num_epochs 5 \
  --wandb_project proof2silicon-journal-final \
  --wandb_entity drprofmjha-university-of-illinois-urbana-champaign \
  2>&1 | tee "$PROOF2SILICON_RUN_DIR/training.log"

python3 audit_slm_training.py \
  "$CHECKPOINT" "$CHECKPOINT" \
  --json "$PROOF2SILICON_RUN_DIR/checkpoint_structure_audit.json" || true

echo "Finished $EXPERIMENT at $(date)"
