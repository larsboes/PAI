#!/usr/bin/env bash
# Process a file of prompts through any LLM provider
# Usage: batch-process.sh PROVIDER MODEL INPUT_FILE [OUTPUT_DIR]
# INPUT_FILE: one prompt per line, or JSON lines with {"id","prompt"} format
# PROVIDER: openai|anthropic|gemini|ollama
# Env: Respective API keys

set -euo pipefail

PROVIDER="${1:?Usage: batch-process.sh PROVIDER MODEL INPUT_FILE [OUTPUT_DIR]}"
MODEL="${2:?Missing MODEL}"
INPUT="${3:?Missing INPUT_FILE}"
OUTPUT_DIR="${4:-./batch-output}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARALLEL="${BATCH_PARALLEL:-5}"
DELAY="${BATCH_DELAY:-0.2}"

mkdir -p "$OUTPUT_DIR"

echo "Provider: $PROVIDER | Model: $MODEL | Parallel: $PARALLEL"
echo "Input: $INPUT ($(wc -l < "$INPUT") items)"
echo "Output: $OUTPUT_DIR/"
echo "---"

process_line() {
  local line="$1"
  local idx="$2"
  
  # Detect format: JSON lines or plain text
  if echo "$line" | jq -e '.prompt' &>/dev/null; then
    id=$(echo "$line" | jq -r '.id // empty')
    prompt=$(echo "$line" | jq -r '.prompt')
    [[ -z "$id" ]] && id="item_$idx"
  else
    id="item_$idx"
    prompt="$line"
  fi
  
  # Call appropriate provider
  case "$PROVIDER" in
    openai)    result=$("$SCRIPT_DIR/call-openai.sh" "$MODEL" "$prompt") ;;
    anthropic) result=$("$SCRIPT_DIR/call-anthropic.sh" "$MODEL" "$prompt") ;;
    gemini)    result=$("$SCRIPT_DIR/call-gemini.sh" "$MODEL" "$prompt") ;;
    ollama)    result=$(curl -s http://localhost:11434/api/chat \
                 -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$prompt" | jq -Rs .)}],\"stream\":false}" \
                 | jq -r '.message.content') ;;
    *) echo "Unknown provider: $PROVIDER" >&2; exit 1 ;;
  esac
  
  # Save result
  jq -n --arg id "$id" --arg prompt "$prompt" --arg result "$result" \
    '{id: $id, prompt: $prompt, result: $result}' > "$OUTPUT_DIR/${id}.json"
  
  echo "✓ $id"
}

export -f process_line
export SCRIPT_DIR MODEL PROVIDER OUTPUT_DIR

idx=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  ((idx++))
  process_line "$line" "$idx" &
  
  # Rate limiting
  if (( idx % PARALLEL == 0 )); then
    wait
    sleep "$DELAY"
  fi
done < "$INPUT"

wait

echo "---"
echo "Done! $idx items processed → $OUTPUT_DIR/"
echo "Merge: jq -s '.' $OUTPUT_DIR/*.json > results.json"
