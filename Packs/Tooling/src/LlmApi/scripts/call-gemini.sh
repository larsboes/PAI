#!/usr/bin/env bash
# Call Google Gemini API — one-shot
# Usage: call-gemini.sh MODEL PROMPT [SYSTEM_PROMPT]
# Env: GEMINI_API_KEY

set -euo pipefail

MODEL="${1:?Usage: call-gemini.sh MODEL PROMPT [SYSTEM]}"
PROMPT="${2:?Missing PROMPT}"
SYSTEM="${3:-}"

BODY=$(jq -n --arg prompt "$PROMPT" --arg system "$SYSTEM" '
{
  contents: [{parts: [{text: $prompt}]}]
} + (if $system != "" then {system_instruction: {parts: [{text: $system}]}} else {} end)')

curl -s "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$BODY" | jq -r '.candidates[0].content.parts[0].text'
