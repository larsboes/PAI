#!/usr/bin/env bash
# Check freshness of world model files and flag stale ones
# Usage: check-freshness.sh [MAX_DAYS]
# Default: flags models older than 90 days

set -euo pipefail

MAX_DAYS="${1:-90}"
MODELS_DIR="${PAI_DIR:-$HOME/.claude/PAI}/MEMORY/RESEARCH/WorldModels"

if [[ ! -d "$MODELS_DIR" ]]; then
  echo "World models directory not found: $MODELS_DIR"
  echo "Run the UpdateModels workflow first."
  exit 1
fi

echo "=== World Model Freshness Check ==="
echo "Directory: $MODELS_DIR"
echo "Stale threshold: ${MAX_DAYS} days"
echo ""

NOW=$(date +%s)
stale_count=0
total_count=0

printf "%-15s %-12s %-8s %s\n" "MODEL" "LAST UPDATED" "AGE" "STATUS"
printf "%-15s %-12s %-8s %s\n" "─────────────" "────────────" "────────" "──────"

for model_file in "$MODELS_DIR"/*.md; do
  [[ ! -f "$model_file" ]] && continue
  [[ "$(basename "$model_file")" == "INDEX.md" ]] && continue
  
  ((total_count++))
  
  name=$(basename "$model_file" .md)
  modified=$(stat -c %Y "$model_file" 2>/dev/null || stat -f %m "$model_file" 2>/dev/null)
  age_days=$(( (NOW - modified) / 86400 ))
  last_date=$(date -d "@$modified" +%Y-%m-%d 2>/dev/null || date -r "$modified" +%Y-%m-%d 2>/dev/null)
  
  if (( age_days > MAX_DAYS )); then
    status="🔴 STALE"
    ((stale_count++))
  elif (( age_days > MAX_DAYS / 2 )); then
    status="🟡 aging"
  else
    status="🟢 fresh"
  fi
  
  printf "%-15s %-12s %-8s %s\n" "$name" "$last_date" "${age_days}d" "$status"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total: $total_count models | Stale: $stale_count (>${MAX_DAYS}d)"

if (( stale_count > 0 )); then
  echo ""
  echo "⚠️  Run the UpdateModels workflow to refresh stale models."
fi
