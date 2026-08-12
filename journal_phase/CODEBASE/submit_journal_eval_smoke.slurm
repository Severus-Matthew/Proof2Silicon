#!/bin/bash -l
#SBATCH --job-name=p2s_eval_smoke
#SBATCH --output=p2s_eval_smoke_%A_%a.out
#SBATCH --error=p2s_eval_smoke_%A_%a.err
#SBATCH --open-mode=append
#SBATCH --account=bgrm-dtai-gh
#SBATCH --partition=ghx4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00

set -euo pipefail

: "${OPENAI_API_KEY:?Export OPENAI_API_KEY before sbatch}"
: "${HF_TOKEN:?Export HF_TOKEN before sbatch}"

ROOT=/u/mjha1/Proof2Silicon/journal_phase
CODEBASE=$ROOT/CODEBASE
OUTPUT_ROOT=${JOURNAL_EVAL_SMOKE_ROOT:-$ROOT/journal_eval_smoke}
IDX=${SLURM_ARRAY_TASK_ID:?Submit with --array=0-2}

export PYTHONUNBUFFERED=1
export TOKENIZERS_PARALLELISM=false
export PYTHONPATH=$CODEBASE:${PYTHONPATH:-}
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True,max_split_size_mb:128
export HF_HOME=${HF_HOME:-/u/mjha1/.cache/huggingface}
export HF_BASE_URL=${HF_BASE_URL:-https://router.huggingface.co/v1}
export DAFNY_JUDGE_MODEL=${DAFNY_JUDGE_MODEL:-gpt-5.4}
export DAFNY_JUDGE_REASONING=${DAFNY_JUDGE_REASONING:-low}

module purge
module load gcc-native/14
module load cuda/12.9
module load python/miniforge3_pytorch/2.10.0
conda activate base
source ~/rl_env311/bin/activate
cd "$CODEBASE"

python3 -m py_compile test_journal.py
command -v dafny >/dev/null || { echo "ERROR: dafny not found" >&2; exit 3; }
nvidia-smi

COMMON=(
  --dataset "$ROOT/Input_dataset_3"
  --output-root "$OUTPUT_ROOT"
  --evaluation-mode repair
  --feedback-mode full
  --recursion-hint
  --slm-decode train_match
  --max-attempts 2
  --limit 2
  --overwrite
  --fail-on-runtime-errors
)

case "$IDX" in
  0)
    NAME="trained_mixed_gpt54mini"
    EXTRA=(--instructor trained --policy mixed --coder "openai:gpt-5.4-mini" --adapter-scale 1.0)
    ;;
  1)
    NAME="untrained_gpt54mini"
    EXTRA=(--instructor untrained --coder "openai:gpt-5.4-mini")
    ;;
  2)
    NAME="trained_mixed_qwen"
    EXTRA=(--instructor trained --policy mixed --coder "hf:Qwen/Qwen3-Coder-30B-A3B-Instruct:featherless-ai" --adapter-scale 1.0)
    ;;
  *)
    echo "ERROR: smoke array index must be 0, 1, or 2" >&2
    exit 2
    ;;
esac

mkdir -p "$OUTPUT_ROOT/_slurm"
echo "Running smoke condition $NAME on $(hostname) at $(date)"
echo "CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-unset}"

python3 test_journal.py "${COMMON[@]}" "${EXTRA[@]}" \
  > >(tee -a "$OUTPUT_ROOT/_slurm/${NAME}.log") 2>&1

echo "Finished smoke condition $NAME at $(date)"
