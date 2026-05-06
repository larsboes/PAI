#!/usr/bin/env bash
# Call OpenAI Chat Completions — one-shot
# Usage: call-openai.sh MODEL PROMPT [SYSTEM_PROMPT] [MAX_TOKENS]
# Env: OPENAI_API_KEY

set -euo pipefail

MODEL="${1:?Usage: call-openai.sh MODEL PROMPT [SYSTEM] [MAX_TOKENS]}"
PROMPT="${2:?Missing PROMPT}"
SYSTEM="${3:-}"
MAX_TOKENS="${4:-4096}"

MESSAGES="[]"
if [[ -n "$SYSTEM" ]]; then
  MESSAGES=$(jq -n --arg s "$SYSTEM" '[{role:"system",content:$s}]')
fi
MESSAGES=$(echo "$MESSAGES" | jq --arg p "$PROMPT" '. + [{role:"user",content:$p}]')

BODY=$(jq -n \
  --arg model "$MODEL" \
  --argjson messages "$MESSAGES" \
  --argjson max_tokens "$MAX_TOKENS" \
  '{model: $model, messages: $messages, max_tokens: $max_tokens}')

curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$BODY" | jq -r '.choices[0].message.content'
