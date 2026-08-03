#!/usr/bin/env bash
set -euo pipefail

# Launch one experiment at a time by setting EXPERIMENT to:
#   deepseek | openai | qwen_hf | mixed
# Every run gets an independent checkpoint and audit directory.

EXPERIMENT="${EXPERIMENT:-deepseek}"
ROOT="/u/mjha1/Proof2Silicon/journal_phase"
CODEBASE="$ROOT/CODEBASE"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

export DAFNY_JUDGE_PROVIDER="openai"
# Use an exact model ID returned by: python preflight_models.py
export DAFNY_JUDGE_MODEL="${DAFNY_JUDGE_MODEL:-gpt-5.2}"
export DAFNY_MIXED_SEED="${DAFNY_MIXED_SEED:-20260802}"
export DAFNY_MIXED_GENERATORS="deepseek,openai,qwen_hf"

case "$EXPERIMENT" in
  deepseek)
    export DAFNY_GENERATOR_MODE="deepseek"
    export DEEPSEEK_GENERATOR_MODEL="${DEEPSEEK_GENERATOR_MODEL:-deepseek-chat}"
    ;;
  openai)
    export DAFNY_GENERATOR_MODE="openai"
    # Replace only after preflight confirms the exact Codex model in your account.
    export OPENAI_GENERATOR_MODEL="${OPENAI_GENERATOR_MODEL:-gpt-5.2}"
    ;;
  qwen_hf)
    export DAFNY_GENERATOR_MODE="qwen_hf"
    export HF_GENERATOR_MODEL="${HF_GENERATOR_MODEL:-Qwen/Qwen3-Coder-30B-A3B-Instruct:cheapest}"
    ;;
  mixed)
    export DAFNY_GENERATOR_MODE="mixed"
    export DEEPSEEK_GENERATOR_MODEL="${DEEPSEEK_GENERATOR_MODEL:-deepseek-chat}"
    export OPENAI_GENERATOR_MODEL="${OPENAI_GENERATOR_MODEL:-gpt-5.2}"
    export HF_GENERATOR_MODEL="${HF_GENERATOR_MODEL:-Qwen/Qwen3-Coder-30B-A3B-Instruct:cheapest}"
    ;;
  *)
    echo "Unknown EXPERIMENT=$EXPERIMENT" >&2
    exit 2
    ;;
esac

RUN_NAME="journal_${EXPERIMENT}_${TIMESTAMP}"
export WANDB_RUN_NAME="$RUN_NAME"
export PROOF2SILICON_EXPERIMENT="$EXPERIMENT"
export PROOF2SILICON_RUN_DIR="$ROOT/journal_runs/$RUN_NAME"
CHECKPOINT_PATH="$PROOF2SILICON_RUN_DIR/checkpoints/final_model.pt"
mkdir -p "$PROOF2SILICON_RUN_DIR/checkpoints"

python "$CODEBASE/preflight_models.py"

cat > "$PROOF2SILICON_RUN_DIR/config.env" <<EOF
EXPERIMENT=$EXPERIMENT
DAFNY_GENERATOR_MODE=$DAFNY_GENERATOR_MODE
DEEPSEEK_GENERATOR_MODEL=${DEEPSEEK_GENERATOR_MODEL:-}
OPENAI_GENERATOR_MODEL=${OPENAI_GENERATOR_MODEL:-}
HF_GENERATOR_MODEL=${HF_GENERATOR_MODEL:-}
DAFNY_JUDGE_PROVIDER=$DAFNY_JUDGE_PROVIDER
DAFNY_JUDGE_MODEL=$DAFNY_JUDGE_MODEL
DAFNY_MIXED_SEED=$DAFNY_MIXED_SEED
SLM_MODEL_NAME=${SLM_MODEL_NAME:-Qwen/Qwen2.5-1.5B-Instruct}
CHECKPOINT_PATH=$CHECKPOINT_PATH
EOF

cd "$CODEBASE"
python main.py --checkpoint "$CHECKPOINT_PATH" "$@" \
  2>&1 | tee "$PROOF2SILICON_RUN_DIR/training.log"
