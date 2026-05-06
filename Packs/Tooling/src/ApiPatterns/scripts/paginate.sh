#!/usr/bin/env bash
# Auto-paginate APIs using Link header (GitHub-style) or offset/cursor
# Usage: paginate.sh URL [--mode link|offset|cursor] [--limit N]
# Env: API_TOKEN, PAGE_SIZE (default: 100)

set -euo pipefail

URL="${1:?Usage: paginate.sh URL [--mode link|offset|cursor] [--limit N]}"
shift

MODE="link"
LIMIT=0  # 0 = unlimited
PAGE_SIZE="${PAGE_SIZE:-100}"
TOKEN="${API_TOKEN:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) MODE="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

HEADERS=(-H "Content-Type: application/json")
[[ -n "$TOKEN" ]] && HEADERS+=(-H "Authorization: Bearer $TOKEN")

count=0

case "$MODE" in
  link)
    # RFC 5988 Link header pagination (GitHub, GitLab, etc.)
    next_url="$URL"
    while [[ -n "$next_url" ]]; do
      response_headers=$(mktemp)
      body=$(curl -s -D "$response_headers" "${HEADERS[@]}" "$next_url")
      echo "$body"
      ((count++))
      [[ $LIMIT -gt 0 && $count -ge $LIMIT ]] && break
      next_url=$(grep -i '^link:' "$response_headers" | grep -oP '(?<=<)[^>]+(?=>; rel="next")' || true)
      rm -f "$response_headers"
    done
    ;;
  
  offset)
    # Offset-based pagination
    offset=0
    while true; do
      separator=$([[ "$URL" == *"?"* ]] && echo "&" || echo "?")
      page_url="${URL}${separator}offset=${offset}&limit=${PAGE_SIZE}"
      body=$(curl -s "${HEADERS[@]}" "$page_url")
      
      # Check if empty array
      item_count=$(echo "$body" | jq 'if type == "array" then length else .data // .results // .items | length end' 2>/dev/null || echo 0)
      [[ "$item_count" -eq 0 ]] && break
      
      echo "$body"
      ((offset += PAGE_SIZE))
      ((count++))
      [[ $LIMIT -gt 0 && $count -ge $LIMIT ]] && break
    done
    ;;
  
  cursor)
    # Cursor-based pagination
    cursor=""
    while true; do
      if [[ -n "$cursor" ]]; then
        separator=$([[ "$URL" == *"?"* ]] && echo "&" || echo "?")
        page_url="${URL}${separator}cursor=${cursor}"
      else
        page_url="$URL"
      fi
      
      body=$(curl -s "${HEADERS[@]}" "$page_url")
      echo "$body"
      
      # Extract next cursor (common field names)
      cursor=$(echo "$body" | jq -r '.next_cursor // .cursor // .pagination.next // empty' 2>/dev/null || true)
      [[ -z "$cursor" || "$cursor" == "null" ]] && break
      ((count++))
      [[ $LIMIT -gt 0 && $count -ge $LIMIT ]] && break
    done
    ;;
esac
