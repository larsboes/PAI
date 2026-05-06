#!/usr/bin/env bash
# Generic API caller with retry, timeout, and error handling
# Usage: api-call.sh METHOD URL [DATA]
# Env: API_TOKEN (or pass -H manually), API_RETRIES (default: 3), API_TIMEOUT (default: 30)

set -euo pipefail

METHOD="${1:?Usage: api-call.sh METHOD URL [DATA]}"
URL="${2:?Usage: api-call.sh METHOD URL [DATA]}"
DATA="${3:-}"
RETRIES="${API_RETRIES:-3}"
TIMEOUT="${API_TIMEOUT:-30}"
TOKEN="${API_TOKEN:-}"

HEADERS=(-H "Content-Type: application/json")
[[ -n "$TOKEN" ]] && HEADERS+=(-H "Authorization: Bearer $TOKEN")

CURL_ARGS=(-s -w "\n%{http_code}" --max-time "$TIMEOUT")

attempt=0
while (( attempt < RETRIES )); do
  ((attempt++))
  
  if [[ -n "$DATA" ]]; then
    response=$(curl "${CURL_ARGS[@]}" -X "$METHOD" "${HEADERS[@]}" -d "$DATA" "$URL")
  else
    response=$(curl "${CURL_ARGS[@]}" -X "$METHOD" "${HEADERS[@]}" "$URL")
  fi
  
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')
  
  # Success
  if [[ "$http_code" =~ ^2 ]]; then
    echo "$body"
    exit 0
  fi
  
  # Non-retryable errors
  if [[ "$http_code" =~ ^4 ]] && [[ "$http_code" != "429" ]]; then
    echo "ERROR $http_code: $body" >&2
    exit 1
  fi
  
  # Rate limited or server error — retry with backoff
  if (( attempt < RETRIES )); then
    backoff=$((attempt * 2))
    echo "Retry $attempt/$RETRIES after ${backoff}s (HTTP $http_code)" >&2
    sleep "$backoff"
  fi
done

echo "FAILED after $RETRIES attempts (HTTP $http_code): $body" >&2
exit 1
