#!/usr/bin/env bash
# Call Anthropic Messages API — one-shot
# Usage: call-anthropic.sh MODEL PROMPT [SYSTEM_PROMPT] [MAX_TOKENS]
# Env: ANTHROPIC_API_KEY

set -euo pipefail

MODEL="${1:?Usage: call-anthropic.sh MODEL PROMPT [SYSTEM] [MAX_TOKENS]}"
PROMPT="${2:?Missing PROMPT}"
SYSTEM="${3:-}"
MAX_TOKENS="${4:-4096}"

BODY=$(jq -n \
  --arg model "$MODEL" \
  --arg prompt "$PROMPT" \
  --arg system "$SYSTEM" \
  --argjson max_tokens "$MAX_TOKENS" \
  '{
    model: $model,
    max_tokens: $max_tokens,
    messages: [{role: "user", content: $prompt}]
  } + (if $system != "" then {system: $system} else {} end)')

curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d "$BODY" | jq -r '.content[] | select(.type=="text") | .text'
