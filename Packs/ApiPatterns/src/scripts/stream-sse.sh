#!/usr/bin/env bash
# Stream SSE responses and extract data events
# Usage: stream-sse.sh URL [JSON_DATA]
# Env: API_TOKEN, SSE_FIELD (default: "data")

set -euo pipefail

URL="${1:?Usage: stream-sse.sh URL [JSON_DATA]}"
DATA="${2:-}"
TOKEN="${API_TOKEN:-}"
FIELD="${SSE_FIELD:-data}"

HEADERS=(-H "Content-Type: application/json" -H "Accept: text/event-stream")
[[ -n "$TOKEN" ]] && HEADERS+=(-H "Authorization: Bearer $TOKEN")

if [[ -n "$DATA" ]]; then
  curl -sN -X POST "${HEADERS[@]}" -d "$DATA" "$URL"
else
  curl -sN "${HEADERS[@]}" "$URL"
fi | while IFS= read -r line; do
  # Skip empty lines and comments
  [[ -z "$line" || "$line" == :* ]] && continue
  
  # Extract field value
  if [[ "$line" == "${FIELD}:"* ]]; then
    value="${line#${FIELD}: }"
    # Stop on [DONE] sentinel
    [[ "$value" == "[DONE]" ]] && break
    echo "$value"
  fi
done
