#!/bin/bash -l
#SBATCH --job-name=p2s_jkl
#SBATCH --output=p2s_journal_klfix_%A_%a.out
#SBATCH --error=p2s_journal_klfix_%A_%a.err
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

# The supplied study ID names the Qwen trace. OpenAI and mixed continue their
# existing journal_final_v6 checkpoints/W&B IDs. Qwen automatically starts
# fresh when its run directory is empty and resumes when a valid checkpoint +
# resume sidecar already exist (including Slurm requeues).
: "${PROOF2SILICON_STUDY_ID:?Set the Qwen study ID, e.g. journal_final_v9}"
: "${OPENAI_API_KEY:?Export OPENAI_API_KEY before sbatch}"
: "${HF_TOKEN:?Export HF_TOKEN before sbatch}"

REQUESTED_NEW_STUDY_ID=$PROOF2SILICON_STUDY_ID
if [[ "$REQUESTED_NEW_STUDY_ID" == "journal_final_v6" || "$REQUESTED_NEW_STUDY_ID" == "journal_final_v7" ]]; then
  echo "ERROR: choose the intended Qwen study ID (for example journal_final_v9)." >&2
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
    RESUME_MODE=auto
    ;;
  2)
    EXPERIMENT=mixed
    RUN_STUDY_ID=journal_final_v6
    RESUME_MODE=required
    ;;
  *) echo "Invalid array task: $ARRAY_ID" >&2; exit 2 ;;
esac

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

export HF_GENERATOR_MODEL=Qwen/Qwen3-Coder-30B-A3B-Instruct:featherless-ai
export HF_BASE_URL=https://router.huggingface.co/v1
export DAFNY_GENERATOR_MAX_TOKENS=8192

export DAFNY_JUDGE_PROVIDER=openai
export DAFNY_JUDGE_MODEL=gpt-5.4
export DAFNY_JUDGE_REASONING=low
export DAFNY_JUDGE_MAX_TOKENS=512

export SLM_VALUE_HEAD_LR=5e-5

# Corrected PPO KL control: all finite rollout samples participate in PPO.
# KL is aggregated over a completed update pass; only subsequent PPO passes are
# stopped when the pass mean exceeds this target.
export PPO_TARGET_MEAN_KL=0.15
export PPO_MIN_KL_SAMPLES=8

RUN_KEY=${RUN_STUDY_ID}_${EXPERIMENT}
export WANDB_RUN_NAME=journal_${RUN_KEY}
export WANDB_RUN_ID=p2s_${RUN_KEY}
export WANDB_MODE=online
export WANDB_DIR=/u/mjha1/wandb_logs/$WANDB_RUN_NAME
export PROOF2SILICON_RUN_DIR=$ROOT/journal_runs/$WANDB_RUN_NAME
CHECKPOINT=$PROOF2SILICON_RUN_DIR/checkpoints/final_model.pt
RESUME_STATE=$PROOF2SILICON_RUN_DIR/resume_state.json

# For Qwen, decide fresh vs resume from durable run state. This is what makes
# automatic Slurm requeue safe: the second invocation sees the checkpoint and
# resumes the same W&B run instead of rejecting the populated run directory.
if [[ "$RESUME_MODE" == "auto" ]]; then
  if [[ -s "$CHECKPOINT" && -s "$RESUME_STATE" ]]; then
    RESUME_MODE=required
  elif [[ ! -e "$CHECKPOINT" && ! -e "$RESUME_STATE" && ! -d "$PROOF2SILICON_RUN_DIR/workspaces" ]]; then
    RESUME_MODE=fresh
  else
    echo "ERROR: inconsistent Qwen run state in $PROOF2SILICON_RUN_DIR" >&2
    echo "Expected either both checkpoint + resume_state for resume, or no prior state for fresh start." >&2
    exit 4
  fi
fi

if [[ "$RESUME_MODE" == "required" ]]; then
  if [[ ! -s "$CHECKPOINT" ]]; then
    echo "ERROR: required checkpoint missing for $EXPERIMENT: $CHECKPOINT" >&2
    exit 3
  fi
  if [[ ! -s "$RESUME_STATE" ]]; then
    echo "ERROR: required W&B resume state missing for $EXPERIMENT: $RESUME_STATE" >&2
    exit 3
  fi
else
  if [[ -e "$CHECKPOINT" || -e "$RESUME_STATE" || -d "$PROOF2SILICON_RUN_DIR/workspaces" ]]; then
    echo "ERROR: fresh run directory already contains state: $PROOF2SILICON_RUN_DIR" >&2
    echo "Choose another PROOF2SILICON_STUDY_ID." >&2
    exit 4
  fi
fi

mkdir -p "$WANDB_DIR" "$PROOF2SILICON_RUN_DIR/checkpoints"

cat > "$PROOF2SILICON_RUN_DIR/config.env" <<EOF
PROOF2SILICON_STUDY_ID=$RUN_STUDY_ID
EXPERIMENT=$EXPERIMENT
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
PPO_KL_CONTROL=aggregate_completed_pass
PPO_TARGET_MEAN_KL=$PPO_TARGET_MEAN_KL
PPO_MIN_KL_SAMPLES=$PPO_MIN_KL_SAMPLES
PPO_PER_SAMPLE_KL_REJECTION=false
TRAINING_REVISION=critic-stabilized-aggregate-kl-v8
TARGET_EPOCHS=7
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
  if [[ -n "${TRAIN_PID:-}" ]]; then
    kill -TERM "$TRAIN_PID" 2>/dev/null || true
    wait "$TRAIN_PID" 2>/dev/null || true
  fi
  sync || true
  scontrol requeue "$SLURM_JOB_ID" || true
  exit 0
}
trap handle_timeout USR1

printf '%s\n' \
  "==============================" \
  "Starting/resuming $EXPERIMENT at $(date)" \
  "Study ID used by this trace: $RUN_STUDY_ID" \
  "Resume mode: $RESUME_MODE" \
  "Run directory: $PROOF2SILICON_RUN_DIR" \
  "Checkpoint: $CHECKPOINT" \
  "Target epochs: 7" \
  "PPO KL: aggregate-pass target=$PPO_TARGET_MEAN_KL; per-sample rejection disabled" \
  "=============================="

nvidia-smi
module purge
module load gcc-native/14
module load cuda/12.9
module load python/miniforge3_pytorch/2.10.0
conda activate base
source ~/rl_env311/bin/activate

cd "$CODEBASE"

python3 -m py_compile \
  journal_runner.py \
  journal_main.py \
  preface_rl/ppo_update_override.py

python3 check_slm_token_budget.py
python3 preflight_models.py

python3 - <<'PY'
import os
from preface_rl.ppo_update_override import install
import preface_rl.slm as slm
install(slm)
print("PPO update implementation:", slm.ppo_update_sequence_level.__module__)
print("PPO target mean KL:", os.environ.get("PPO_TARGET_MEAN_KL"))
print("Per-sample KL rejection: disabled")
PY

set +e
python3 journal_runner.py \
  --checkpoint "$CHECKPOINT" \
  --start_epoch 0 \
  --num_epochs 7 \
  --wandb_project proof2silicon-journal-final \
  --wandb_entity drprofmjha-university-of-illinois-urbana-champaign \
  > >(tee -a "$PROOF2SILICON_RUN_DIR/training.log") 2>&1 &
TRAIN_PID=$!
wait "$TRAIN_PID"
TRAIN_RC=$?
TRAIN_PID=""
set -e

if [[ "$TRAIN_RC" -ne 0 ]]; then
  echo "ERROR: training process exited with code $TRAIN_RC at $(date)" >&2
  echo "---- quota ----" >&2
  quota -s 2>&1 || true
  echo "---- run size ----" >&2
  du -sh "$PROOF2SILICON_RUN_DIR" 2>&1 || true
  echo "---- filesystem ----" >&2
  df -h /u/mjha1 2>&1 || true
  echo "---- GPU ----" >&2
  nvidia-smi 2>&1 || true
  echo "---- final training log ----" >&2
  tail -120 "$PROOF2SILICON_RUN_DIR/training.log" 2>&1 || true
  exit "$TRAIN_RC"
fi

echo "Finished $EXPERIMENT at $(date)"
