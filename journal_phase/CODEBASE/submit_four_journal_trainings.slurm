#!/bin/bash -l
#SBATCH --job-name=p2s_journal
#SBATCH --output=p2s_journal_%A_%a.out
#SBATCH --error=p2s_journal_%A_%a.err
#SBATCH --open-mode=append
#SBATCH --account=bgrm-dtai-gh
#SBATCH --partition=ghx4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=2-00:00:00
#SBATCH --array=0-3
#SBATCH --requeue
#SBATCH --signal=B:USR1@600

set -euo pipefail

# Use one stable study ID for the entire four-run experiment. Re-submit with the
# SAME ID after a timeout so the checkpoint path and W&B run IDs are reused:
#   export PROOF2SILICON_STUDY_ID=journal_final_v1
#   sbatch --export=ALL submit_four_journal_trainings.slurm
: "${PROOF2SILICON_STUDY_ID:?Set a stable PROOF2SILICON_STUDY_ID before sbatch}"
: "${OPENAI_API_KEY:?Export OPENAI_API_KEY before sbatch}"
: "${DEEPSEEK_API_KEY:?Export DEEPSEEK_API_KEY before sbatch}"
: "${HF_TOKEN:?Export HF_TOKEN before sbatch}"

export PYTHONUNBUFFERED=1
export TOKENIZERS_PARALLELISM=false
export PYTHONPATH=/u/mjha1/Proof2Silicon/journal_phase/CODEBASE:${PYTHONPATH:-}
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:128
export HF_HOME=/u/mjha1/.cache/huggingface
export WANDB_RESUME=allow

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

# These identifiers deliberately do NOT contain the Slurm job ID. They remain
# stable across requeue and manual resubmission, so W&B appends to one run and
# the same rolling checkpoint is loaded.
RUN_KEY=${PROOF2SILICON_STUDY_ID}_${EXPERIMENT}
export WANDB_RUN_NAME=journal_${RUN_KEY}
export WANDB_RUN_ID=p2s_${RUN_KEY}
export WANDB_MODE=online
export WANDB_DIR=/u/mjha1/wandb_logs/$WANDB_RUN_NAME
export PROOF2SILICON_RUN_DIR=$ROOT/journal_runs/$WANDB_RUN_NAME
CHECKPOINT=$PROOF2SILICON_RUN_DIR/checkpoints/final_model.pt

mkdir -p "$WANDB_DIR" "$PROOF2SILICON_RUN_DIR/checkpoints"

cat > "$PROOF2SILICON_RUN_DIR/config.env" <<EOF
PROOF2SILICON_STUDY_ID=$PROOF2SILICON_STUDY_ID
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
LATEST_SLURM_JOB_ID=$SLURM_JOB_ID
LATEST_SLURM_ARRAY_JOB_ID=$SLURM_ARRAY_JOB_ID
LATEST_SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID
EOF

TRAIN_PID=""
REQUEUE_REQUESTED=0
handle_timeout() {
  if [[ "$REQUEUE_REQUESTED" -eq 1 ]]; then
    return
  fi
  REQUEUE_REQUESTED=1
  echo "Received Slurm pre-timeout signal at $(date)."
  echo "Stopping cleanly; restart will use the latest atomically written completed-epoch checkpoint."
  if [[ -n "${TRAIN_PID:-}" ]]; then
    kill -TERM "$TRAIN_PID" 2>/dev/null || true
    wait "$TRAIN_PID" 2>/dev/null || true
  fi
  sync || true
  echo "Requesting Slurm requeue for job $SLURM_JOB_ID"
  scontrol requeue "$SLURM_JOB_ID" || true
  exit 0
}
trap handle_timeout USR1

printf '%s\n' "==============================" \
  "Starting/resuming $EXPERIMENT at $(date)" \
  "Study ID: $PROOF2SILICON_STUDY_ID" \
  "Host: $(hostname)" \
  "Slurm job: $SLURM_JOB_ID array task: $SLURM_ARRAY_TASK_ID" \
  "Run directory: $PROOF2SILICON_RUN_DIR" \
  "Checkpoint: $CHECKPOINT" \
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
import os
checkpoint = os.environ.get("PROOF2SILICON_RUN_DIR", "") + "/checkpoints/final_model.pt"
model, tokenizer = initialize_slm(None)
print("SLM loaded:", model.config._name_or_path)
print("trainable snapshot:", trainable_parameter_snapshot(model))
print("rolling checkpoint exists:", os.path.exists(checkpoint), checkpoint)
PY

python3 journal_main.py \
  --checkpoint "$CHECKPOINT" \
  --start_epoch 0 \
  --num_epochs 5 \
  --wandb_project proof2silicon-journal-final \
  --wandb_entity drprofmjha-university-of-illinois-urbana-champaign \
  2>&1 | tee -a "$PROOF2SILICON_RUN_DIR/training.log" &
TRAIN_PID=$!
wait "$TRAIN_PID"
TRAIN_PID=""

echo "Finished $EXPERIMENT at $(date)"
