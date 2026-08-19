#!/bin/bash -l
#SBATCH --job-name=p2s_journal3
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
#SBATCH --array=0-2
#SBATCH --requeue
#SBATCH --signal=B:USR1@600

set -euo pipefail

# PROOF2SILICON_STUDY_ID names ONLY the fresh Qwen restart trace.
# OpenAI and mixed intentionally continue their existing journal_final_v6
# checkpoints and W&B run IDs so their plots extend from the prior history.
: "${PROOF2SILICON_STUDY_ID:?Set a NEW study ID for the fresh Qwen trace, e.g. journal_final_v7}"
: "${OPENAI_API_KEY:?Export OPENAI_API_KEY before sbatch}"
: "${HF_TOKEN:?Export HF_TOKEN before sbatch}"

REQUESTED_NEW_STUDY_ID=$PROOF2SILICON_STUDY_ID
if [[ "$REQUESTED_NEW_STUDY_ID" == "journal_final_v6" ]]; then
  echo "ERROR: PROOF2SILICON_STUDY_ID must be new for the Qwen restart; do not use journal_final_v6." >&2
  exit 2
fi

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
  0)
    EXPERIMENT=openai
    RUN_STUDY_ID=journal_final_v6
    RESUME_MODE=required
    ;;
  1)
    EXPERIMENT=qwen_hf
    RUN_STUDY_ID=$REQUESTED_NEW_STUDY_ID
    RESUME_MODE=fresh
    ;;
  2)
    EXPERIMENT=mixed
    RUN_STUDY_ID=journal_final_v6
    RESUME_MODE=required
    ;;
  *) echo "Invalid array task: $ARRAY_ID" >&2; exit 2 ;;
esac

# journal_main records the actual study identity of each trace.
export PROOF2SILICON_STUDY_ID=$RUN_STUDY_ID
export PROOF2SILICON_EXPERIMENT=$EXPERIMENT
export DAFNY_GENERATOR_MODE=$EXPERIMENT
export DAFNY_MIXED_GENERATORS=openai,qwen_hf
export DAFNY_MIXED_SEED=20260802
export SLM_MODEL_NAME=Qwen/Qwen3-1.7B

export OPENAI_GENERATOR_MODEL=gpt-5.4-mini
export OPENAI_GENERATOR_REASONING=medium
export OPENAI_GENERATOR_MAX_TOKENS=16384
export OPENAI_GENERATOR_RETRY_MAX_TOKENS=24576

# Qwen is restarted because the serving condition is now pinned rather than
# continuing the old :cheapest trace.
export HF_GENERATOR_MODEL=Qwen/Qwen3-Coder-30B-A3B-Instruct:featherless-ai
export HF_BASE_URL=https://router.huggingface.co/v1
export DAFNY_GENERATOR_MAX_TOKENS=8192

export DAFNY_JUDGE_PROVIDER=openai
export DAFNY_JUDGE_MODEL=gpt-5.4
export DAFNY_JUDGE_REASONING=low
export DAFNY_JUDGE_MAX_TOKENS=512

# Critic stabilization introduced after the v6 wall-time stop.
export SLM_VALUE_HEAD_LR=5e-5

RUN_KEY=${RUN_STUDY_ID}_${EXPERIMENT}
export WANDB_RUN_NAME=journal_${RUN_KEY}
export WANDB_RUN_ID=p2s_${RUN_KEY}
export WANDB_MODE=online
export WANDB_DIR=/u/mjha1/wandb_logs/$WANDB_RUN_NAME
export PROOF2SILICON_RUN_DIR=$ROOT/journal_runs/$WANDB_RUN_NAME
CHECKPOINT=$PROOF2SILICON_RUN_DIR/checkpoints/final_model.pt
RESUME_STATE=$PROOF2SILICON_RUN_DIR/resume_state.json

if [[ "$RESUME_MODE" == "required" ]]; then
  # Exact plot continuation depends on BOTH the model checkpoint and the custom
  # journal_step sidecar. Refuse to silently start a new trace if either is gone.
  if [[ ! -s "$CHECKPOINT" ]]; then
    echo "ERROR: required v6 checkpoint missing for $EXPERIMENT: $CHECKPOINT" >&2
    exit 3
  fi
  if [[ ! -s "$RESUME_STATE" ]]; then
    echo "ERROR: required v6 W&B resume sidecar missing for $EXPERIMENT: $RESUME_STATE" >&2
    echo "Refusing to reset journal_step because plots must continue exactly." >&2
    exit 3
  fi
else
  # Qwen must be a genuinely fresh trace. Never overwrite/reuse a prior run.
  if [[ -e "$CHECKPOINT" || -e "$RESUME_STATE" || -d "$PROOF2SILICON_RUN_DIR/workspaces" ]]; then
    echo "ERROR: fresh Qwen run directory already contains prior state: $PROOF2SILICON_RUN_DIR" >&2
    echo "Choose a new PROOF2SILICON_STUDY_ID (for example journal_final_v7_qwen_restart)." >&2
    exit 4
  fi
fi

mkdir -p "$WANDB_DIR" "$PROOF2SILICON_RUN_DIR/checkpoints"

cat > "$PROOF2SILICON_RUN_DIR/config.env" <<EOF
PROOF2SILICON_STUDY_ID=$RUN_STUDY_ID
REQUESTED_NEW_STUDY_ID=$REQUESTED_NEW_STUDY_ID
EXPERIMENT=$EXPERIMENT
RESUME_MODE=$RESUME_MODE
TARGET_TOTAL_EPOCHS=7
SLM_MODEL_NAME=$SLM_MODEL_NAME
DAFNY_GENERATOR_MODE=$DAFNY_GENERATOR_MODE
DAFNY_MIXED_GENERATORS=$DAFNY_MIXED_GENERATORS
OPENAI_GENERATOR_MODEL=$OPENAI_GENERATOR_MODEL
OPENAI_GENERATOR_REASONING=$OPENAI_GENERATOR_REASONING
OPENAI_GENERATOR_MAX_TOKENS=$OPENAI_GENERATOR_MAX_TOKENS
OPENAI_GENERATOR_RETRY_MAX_TOKENS=$OPENAI_GENERATOR_RETRY_MAX_TOKENS
DAFNY_GENERATOR_MAX_TOKENS=$DAFNY_GENERATOR_MAX_TOKENS
HF_GENERATOR_MODEL=$HF_GENERATOR_MODEL
DAFNY_JUDGE_MODEL=$DAFNY_JUDGE_MODEL
DAFNY_JUDGE_REASONING=$DAFNY_JUDGE_REASONING
DAFNY_JUDGE_MAX_TOKENS=$DAFNY_JUDGE_MAX_TOKENS
DAFNY_JUDGE_SCOPE=same_problem_only_not_correctness
DAFNY_MIXED_SEED=$DAFNY_MIXED_SEED
SLM_MAX_PROMPT_TOKENS=1600
SLM_MAX_NEW_TOKENS=800
SLM_MAX_SEQUENCE_TOKENS=2400
SLM_THINKING_DISABLED=true
SLM_ACTOR_LR=5e-7
SLM_VALUE_HEAD_LR=$SLM_VALUE_HEAD_LR
CRITIC_BACKBONE_DETACHED=true
KL_SIGNAL=sampled_logprob_gap_to_base_policy
PARSE_ERROR_SENTINEL_REMOVED=true
TRAINING_REVISION=critic-stabilized-three-generator-v7
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
  "Starting $EXPERIMENT at $(date)" \
  "Trace study ID: $RUN_STUDY_ID" \
  "Resume mode: $RESUME_MODE" \
  "Host: $(hostname)" \
  "Slurm job: $SLURM_JOB_ID array task: $SLURM_ARRAY_TASK_ID" \
  "W&B run name: $WANDB_RUN_NAME" \
  "W&B run ID: $WANDB_RUN_ID" \
  "Run directory: $PROOF2SILICON_RUN_DIR" \
  "Checkpoint: $CHECKPOINT" \
  "Resume sidecar: $RESUME_STATE" \
  "Mixed generators: $DAFNY_MIXED_GENERATORS" \
  "SLM token budget: prompt=1600 new=800 total=2400 thinking=disabled" \
  "Actor LR: 5e-7 | value-head LR: $SLM_VALUE_HEAD_LR | critic backbone detached" \
  "Qwen-HF provider pinned: $HF_GENERATOR_MODEL" \
  "Judge: scope=same-problem-only reasoning=$DAFNY_JUDGE_REASONING max_output_tokens=$DAFNY_JUDGE_MAX_TOKENS" \
  "Target total epochs: 7" \
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

python3 check_slm_token_budget.py
python3 preflight_models.py

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
  --num_epochs 7 \
  --wandb_project proof2silicon-journal-final \
  --wandb_entity drprofmjha-university-of-illinois-urbana-champaign \
  > >(tee -a "$PROOF2SILICON_RUN_DIR/training.log") 2>&1 &
TRAIN_PID=$!
wait "$TRAIN_PID"
TRAIN_PID=""

echo "Finished $EXPERIMENT at $(date)"
