#!/usr/bin/env bash
set -euo pipefail

SUITE=${1:-full}
MAX_CONCURRENT=${MAX_CONCURRENT:-12}
ROOT=/u/mjha1/Proof2Silicon/journal_phase
CODEBASE=$ROOT/CODEBASE
MATRIX_DIR=$ROOT/journal_eval_matrices
OUTPUT_ROOT=${JOURNAL_EVAL_OUTPUT_ROOT:-$ROOT/journal_eval}
MATRIX=$MATRIX_DIR/${SUITE}.tsv

case "$SUITE" in
  core|transfer|ablations|passk|full) ;;
  *) echo "Usage: $0 [core|transfer|ablations|passk|full]" >&2; exit 2 ;;
esac

: "${OPENAI_API_KEY:?Export OPENAI_API_KEY first}"
: "${HF_TOKEN:?Export HF_TOKEN first}"

mkdir -p "$MATRIX_DIR" "$OUTPUT_ROOT"
cd "$CODEBASE"
python3 make_journal_eval_matrix.py --suite "$SUITE" --output "$MATRIX"
N=$(( $(wc -l < "$MATRIX") - 1 ))
if (( N <= 0 )); then echo "No conditions generated" >&2; exit 3; fi

echo "Suite: $SUITE"
echo "Conditions: $N"
echo "Matrix: $MATRIX"
echo "Output root: $OUTPUT_ROOT"
echo "Max concurrent jobs: $MAX_CONCURRENT"

export EVAL_MATRIX_FILE="$MATRIX"
export JOURNAL_EVAL_OUTPUT_ROOT="$OUTPUT_ROOT"
JOB=$(sbatch --parsable --array="0-$((N-1))%${MAX_CONCURRENT}" \
  --export=ALL,EVAL_MATRIX_FILE="$MATRIX",JOURNAL_EVAL_OUTPUT_ROOT="$OUTPUT_ROOT" \
  submit_journal_eval.slurm)

echo "Submitted Slurm array: $JOB"
echo "Watch with: squeue -j ${JOB}"
echo "After completion: python3 summarize_journal_eval.py --root '$OUTPUT_ROOT'"
