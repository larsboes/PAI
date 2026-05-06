#!/usr/bin/env bash
# Compare same prompt across multiple models — side by side
# Usage: compare-models.sh "PROMPT" [MODEL1 MODEL2 ...]
# Default models: gpt-4o, claude-sonnet-4-20250514, gemini-2.5-flash
# Env: OPENAI_API_KEY, ANTHROPIC_API_KEY, GEMINI_API_KEY

set -euo pipefail

PROMPT="${1:?Usage: compare-models.sh \"PROMPT\" [model1 model2 ...]}"
shift

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Default models if none specified
if [[ $# -eq 0 ]]; then
  MODELS=("gpt-4o" "claude-sonnet-4-20250514" "gemini-2.5-flash")
else
  MODELS=("$@")
fi

echo "Prompt: $PROMPT"
echo "Models: ${MODELS[*]}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for model in "${MODELS[@]}"; do
  echo ""
  echo "┌─── $model ───"
  echo "│"
  
  # Route to correct provider based on model name
  result=""
  start=$(date +%s%3N)
  
  case "$model" in
    gpt-*|o1-*|o3-*)
      result=$("$SCRIPT_DIR/call-openai.sh" "$model" "$PROMPT" 2>/dev/null || echo "[ERROR]")
      ;;
    claude-*)
      result=$("$SCRIPT_DIR/call-anthropic.sh" "$model" "$PROMPT" 2>/dev/null || echo "[ERROR]")
      ;;
    gemini-*)
      result=$("$SCRIPT_DIR/call-gemini.sh" "$model" "$PROMPT" 2>/dev/null || echo "[ERROR]")
      ;;
    *)
      # Try ollama for unknown models
      result=$(curl -s http://localhost:11434/api/chat \
        -d "{\"model\":\"$model\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$PROMPT" | jq -Rs .)}],\"stream\":false}" \
        | jq -r '.message.content // "[ERROR: model not found]"' 2>/dev/null || echo "[ERROR]")
      ;;
  esac
  
  end=$(date +%s%3N)
  elapsed=$(( end - start ))
  
  echo "$result" | sed 's/^/│ /'
  echo "│"
  echo "└─── (${elapsed}ms)"
  echo ""
done
