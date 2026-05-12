#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  sync-capture.sh — Pull agent improvements back into PAI source
#
#  Compares deployed skill copies against PAI/Packs/X/src/ source.
#  Shows diffs and offers to copy changes back.
#
#  Usage:
#    ./sync-capture.sh                # check all deployed skills
#    ./sync-capture.sh Browser        # check specific skill
#    ./sync-capture.sh --auto         # auto-copy all diffs (no prompt)
# ═══════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKS_DIR="$SCRIPT_DIR/Packs"

CLAUDE_SKILLS="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
PI_SKILLS="${PI_SKILLS_DIR:-$HOME/.pi/agent/skills}"

# Colors
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; RESET='\033[0m'; BOLD='\033[1m'

AUTO=false
FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto) AUTO=true; shift ;;
    *) FILTER="$1"; shift ;;
  esac
done

check_skill() {
  local pack="$1"
  local deployed="$2"
  local source="$PACKS_DIR/$pack/src"

  [[ ! -d "$source" ]] && return
  [[ ! -d "$deployed" ]] && return

  # Compare deployed vs source (ignore description line since we patch it)
  local diff_output
  diff_output=$(diff -rq "$deployed" "$source" 2>/dev/null | grep -v "\.DS_Store" || true)

  if [[ -z "$diff_output" ]]; then
    return
  fi

  # Get actual content diff
  local content_diff
  content_diff=$(diff -ru "$source" "$deployed" 2>/dev/null \
    | grep -v "^Only in" \
    | grep -v "^diff " \
    | grep -v "^---" \
    | grep -v "^+++" \
    | grep -v "^@@" \
    | grep "^[+-]" \
    | grep -v "^[+-]description:" \
    || true)

  if [[ -z "$content_diff" ]]; then
    return
  fi

  echo -e "\n${BOLD}${YELLOW}═══ $pack ═══${RESET}"
  echo -e "  Source:   $source"
  echo -e "  Deployed: $deployed"
  echo ""
  diff -ru "$source" "$deployed" 2>/dev/null | head -50 || true

  if $AUTO; then
    echo -e "  ${GREEN}→ Auto-copying back to source${RESET}"
    rsync -a --exclude='.DS_Store' "$deployed/" "$source/"
  else
    echo ""
    read -rp "  Copy deployed → source? [y/N] " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
      rsync -a --exclude='.DS_Store' "$deployed/" "$source/"
      echo -e "  ${GREEN}✓ Copied${RESET}"
    fi
  fi
}

echo -e "${BOLD}${BLUE}── PAI Skill Capture ──────────────────────────────────────${RESET}"
echo ""

FOUND=0

# Check Claude Code skills
if [[ -d "$CLAUDE_SKILLS" ]]; then
  for dir in "$CLAUDE_SKILLS"/*/; do
    [[ ! -d "$dir" ]] && continue
    pack=$(basename "$dir")
    [[ -n "$FILTER" && "$pack" != "$FILTER" ]] && continue
    check_skill "$pack" "$dir"
    ((FOUND++)) || true
  done
fi

# Check Pi skills
if [[ -d "$PI_SKILLS" ]]; then
  for dir in "$PI_SKILLS"/*/; do
    [[ ! -d "$dir" ]] && continue
    pack=$(basename "$dir")
    [[ -n "$FILTER" && "$pack" != "$FILTER" ]] && continue
    # Skip if already checked from claude (avoid duplicate prompts)
    [[ -d "$CLAUDE_SKILLS/$pack" ]] && continue
    check_skill "$pack" "$dir"
    ((FOUND++)) || true
  done
fi

if [[ $FOUND -eq 0 ]]; then
  echo -e "  ${GREEN}✓${RESET} No divergence detected — source is up to date"
fi
