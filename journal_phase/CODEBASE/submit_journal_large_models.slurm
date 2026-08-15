#!/bin/bash -l
#SBATCH --job-name=p2s_large_eval
#SBATCH --output=p2s_large_eval_%A_%a.out
#SBATCH --error=p2s_large_eval_%A_%a.err
#SBATCH --open-mode=append
#SBATCH --account=bgrm-dtai-gh
#SBATCH --partition=ghx4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=2-00:00:00
#SBATCH --requeue
#SBATCH --signal=B:USR1@600

set -euo pipefail

: "${EVAL_MATRIX_FILE:?Set EVAL_MATRIX_FILE to the large-model TSV matrix}"
: "${OPENAI_API_KEY:?Export OPENAI_API_KEY for the semantic judge}"
: "${HF_TOKEN:?Export HF_TOKEN for Hugging Face Inference Providers}"

ROOT=/u/mjha1/Proof2Silicon/journal_phase
CODEBASE=$ROOT/CODEBASE
OUTPUT_ROOT=${JOURNAL_LARGE_OUTPUT_ROOT:-$ROOT/journal_eval_large_models}
ARRAY_ID=${SLURM_ARRAY_TASK_ID:?}

export PYTHONUNBUFFERED=1
export TOKENIZERS_PARALLELISM=false
export PYTHONPATH=$CODEBASE:${PYTHONPATH:-}
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:128
export HF_HOME=${HF_HOME:-/u/mjha1/.cache/huggingface}
export HF_BASE_URL=${HF_BASE_URL:-https://router.huggingface.co/v1}
export DAFNY_GENERATOR_MAX_TOKENS=${DAFNY_GENERATOR_MAX_TOKENS:-8192}
export DAFNY_JUDGE_MODEL=${DAFNY_JUDGE_MODEL:-gpt-5.4}
export DAFNY_JUDGE_REASONING=${DAFNY_JUDGE_REASONING:-low}
export DAFNY_JUDGE_MAX_TOKENS=${DAFNY_JUDGE_MAX_TOKENS:-512}

ROW=$(awk -F '\t' -v n=$((ARRAY_ID + 2)) 'NR==n {print; exit}' "$EVAL_MATRIX_FILE")
if [[ -z "$ROW" ]]; then
  echo "ERROR: no matrix row for array index $ARRAY_ID in $EVAL_MATRIX_FILE" >&2
  exit 2
fi

IFS=$'\t' read -r NAME INSTRUCTOR POLICY CODER EVAL_MODE FEEDBACK_MODE RECURSION_HINT ADAPTER_SCALE SLM_DECODE MAX_ATTEMPTS SEED EXTERNAL_INSTRUCTOR <<< "$ROW"
if [[ -z "$NAME" || -z "$INSTRUCTOR" || -z "$CODER" ]]; then
  echo "ERROR: malformed matrix row: $ROW" >&2
  exit 2
fi
if [[ "$INSTRUCTOR" == "self" || "$INSTRUCTOR" == "external" ]]; then
  echo "ERROR: this suite forbids self/external instructor categories" >&2
  exit 2
fi
if [[ "$MAX_ATTEMPTS" -ne 5 ]]; then
  echo "ERROR: post-core large-model protocol requires exactly 5 attempts" >&2
  exit 2
fi

module purge
module load gcc-native/14
module load cuda/12.9
module load python/miniforge3_pytorch/2.10.0
conda activate base
source ~/rl_env311/bin/activate
cd "$CODEBASE"

python3 -m py_compile test_journal.py journal_eval_entry.py journal_large_eval_entry.py make_journal_large_model_matrix.py
command -v dafny >/dev/null || { echo "ERROR: dafny not found" >&2; exit 3; }

ARGS=(
  --dataset "$ROOT/Input_dataset_3"
  --output-root "$OUTPUT_ROOT"
  --instructor "$INSTRUCTOR"
  --coder "$CODER"
  --evaluation-mode repair
  --feedback-mode full
  --adapter-scale "$ADAPTER_SCALE"
  --slm-decode "$SLM_DECODE"
  --max-attempts 5
  --coder-max-tokens "$DAFNY_GENERATOR_MAX_TOKENS"
  --seed "$SEED"
  --fail-on-runtime-errors
)

if [[ "$INSTRUCTOR" == "trained" ]]; then
  ARGS+=(--policy "$POLICY")
fi
if [[ "$RECURSION_HINT" == "1" ]]; then
  ARGS+=(--recursion-hint)
else
  ARGS+=(--no-recursion-hint)
fi

RUN_LOG_DIR="$OUTPUT_ROOT/_slurm"
mkdir -p "$RUN_LOG_DIR"

echo "=============================================="
echo "Large-generator journal condition: $NAME"
echo "Array index: $ARRAY_ID"
echo "Instructor: $INSTRUCTOR policy=${POLICY:-na}"
echo "Coder API: $CODER"
echo "Downstream generator weights: API ONLY (not loaded locally)"
echo "Repair budget: 5"
echo "Judge: $DAFNY_JUDGE_MODEL/$DAFNY_JUDGE_REASONING/$DAFNY_JUDGE_MAX_TOKENS"
echo "Output: $OUTPUT_ROOT"
echo "=============================================="

TRAIN_PID=""
REQUEUE_REQUESTED=0
handle_timeout() {
  if [[ "$REQUEUE_REQUESTED" -eq 1 ]]; then return; fi
  REQUEUE_REQUESTED=1
  echo "Received Slurm pre-timeout signal at $(date). Requeueing."
  if [[ -n "${TRAIN_PID:-}" ]]; then
    kill -TERM "$TRAIN_PID" 2>/dev/null || true
    wait "$TRAIN_PID" 2>/dev/null || true
  fi
  sync || true
  scontrol requeue "$SLURM_JOB_ID" || true
  exit 0
}
trap handle_timeout USR1

set +e
python3 journal_large_eval_entry.py "${ARGS[@]}" > >(tee -a "$RUN_LOG_DIR/${NAME}.log") 2>&1 &
TRAIN_PID=$!
wait "$TRAIN_PID"
RC=$?
TRAIN_PID=""
set -e

if [[ "$RC" -ne 0 ]]; then
  echo "ERROR: evaluation exited $RC for $NAME" >&2
  tail -120 "$RUN_LOG_DIR/${NAME}.log" 2>&1 || true
  nvidia-smi 2>&1 || true
  exit "$RC"
fi

echo "Finished $NAME at $(date)"
