#!/usr/bin/env bash
# Fetch OAuth2 token via client_credentials grant
# Usage: oauth-token.sh TOKEN_URL CLIENT_ID CLIENT_SECRET [SCOPE]
# Outputs: access_token (plain text, pipe-friendly)

set -euo pipefail

TOKEN_URL="${1:?Usage: oauth-token.sh TOKEN_URL CLIENT_ID CLIENT_SECRET [SCOPE]}"
CLIENT_ID="${2:?Missing CLIENT_ID}"
CLIENT_SECRET="${3:?Missing CLIENT_SECRET}"
SCOPE="${4:-}"

DATA="grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}"
[[ -n "$SCOPE" ]] && DATA="${DATA}&scope=${SCOPE}"

response=$(curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "$DATA")

token=$(echo "$response" | jq -r '.access_token // empty')

if [[ -z "$token" ]]; then
  echo "OAuth2 token fetch failed: $response" >&2
  exit 1
fi

echo "$token"
