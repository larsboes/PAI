#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  sync-deploy.sh — Deploy PAI skills to coding assistants
#
#  Reads skills.yaml for active packs, deploys src/ contents
#  to ~/.claude/skills/ and ~/.pi/agent/skills/
#  Patches descriptions for pi using short-descriptions.yaml
#
#  Usage:
#    ./sync-deploy.sh                    # deploy active skills
#    ./sync-deploy.sh --profile security # include profile skills
#    ./sync-deploy.sh --dry-run          # show what would happen
#    ./sync-deploy.sh --pi-only          # only deploy to pi
#    ./sync-deploy.sh --claude-only      # only deploy to claude
# ═══════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKS_DIR="$SCRIPT_DIR/Packs"
SKILLS_YAML="$SCRIPT_DIR/skills.yaml"
SHORT_DESC="$SCRIPT_DIR/short-descriptions.yaml"

CLAUDE_SKILLS="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
PI_SKILLS="${PI_SKILLS_DIR:-$HOME/.pi/agent/skills}"

# Colors
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; RESET='\033[0m'; BOLD='\033[1m'
ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
info() { echo -e "  ${BLUE}ℹ${RESET} $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; exit 1; }

# Parse args
DRY_RUN=false
PROFILE=""
DEPLOY_CLAUDE=true
DEPLOY_PI=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --pi-only) DEPLOY_CLAUDE=false; shift ;;
    --claude-only) DEPLOY_PI=false; shift ;;
    *) fail "Unknown option: $1" ;;
  esac
done

# Parse skills.yaml (requires yq or simple grep)
parse_active_skills() {
  # Simple parser: extract lines under "active:" until next top-level key
  sed -n '/^active:/,/^[a-z]/{/^  - /p}' "$SKILLS_YAML" | sed 's/^  - //'
}

parse_profile_skills() {
  local profile="$1"
  sed -n "/^  $profile:/,/^  [a-z]/{/^    - /p}" "$SKILLS_YAML" | sed 's/^    - //'
}

get_short_description() {
  local pack="$1"
  # Extract description for this pack from short-descriptions.yaml
  local desc
  desc=$(grep "^${pack}:" "$SHORT_DESC" 2>/dev/null | sed "s/^${pack}: *\"\\?//;s/\"\\?\$//" | head -1)
  echo "$desc"
}

patch_description() {
  local skill_file="$1"
  local pack="$2"
  local short_desc
  short_desc=$(get_short_description "$pack")
  if [[ -n "$short_desc" ]]; then
    # Replace the description line in the deployed copy
    sed -i "s|^description:.*|description: \"$short_desc\"|" "$skill_file"
  fi
}

# Gather active skills
ACTIVE_SKILLS=$(parse_active_skills)

if [[ -n "$PROFILE" ]]; then
  PROFILE_SKILLS=$(parse_profile_skills "$PROFILE")
  ACTIVE_SKILLS=$(echo -e "$ACTIVE_SKILLS\n$PROFILE_SKILLS" | sort -u)
fi

SKILL_COUNT=$(echo "$ACTIVE_SKILLS" | wc -l)

echo -e "${BOLD}${BLUE}── PAI Skill Deployment ──────────────────────────────────${RESET}"
info "Source: $PACKS_DIR"
info "Active skills: $SKILL_COUNT"
[[ -n "$PROFILE" ]] && info "Profile: $PROFILE"
$DRY_RUN && info "DRY RUN — no changes will be made"
echo ""

DEPLOYED=0
SKIPPED=0
ERRORS=0

while IFS= read -r pack; do
  [[ -z "$pack" ]] && continue
  SRC="$PACKS_DIR/$pack/src"

  if [[ ! -d "$SRC" ]]; then
    warn "$pack — no src/ directory, skipping"
    ((SKIPPED++)) || true
    continue
  fi

  if [[ ! -f "$SRC/SKILL.md" ]]; then
    warn "$pack — no src/SKILL.md, skipping"
    ((SKIPPED++)) || true
    continue
  fi

  if $DRY_RUN; then
    ok "$pack (would deploy)"
    ((DEPLOYED++)) || true
    continue
  fi

  # Deploy to Claude Code
  if $DEPLOY_CLAUDE; then
    DEST="$CLAUDE_SKILLS/$pack"
    rm -rf "$DEST"
    cp -R "$SRC" "$DEST"
  fi

  # Deploy to Pi (with description patching)
  if $DEPLOY_PI; then
    DEST="$PI_SKILLS/$pack"
    rm -rf "$DEST"
    cp -R "$SRC" "$DEST"
    # Patch description if we have a short version
    if [[ -f "$DEST/SKILL.md" ]]; then
      patch_description "$DEST/SKILL.md" "$pack"
    fi
  fi

  ok "$pack"
  ((DEPLOYED++)) || true
done <<< "$ACTIVE_SKILLS"

echo ""
echo -e "${BOLD}── Summary ──────────────────────────────────────────────────${RESET}"
info "Deployed: $DEPLOYED"
[[ $SKIPPED -gt 0 ]] && warn "Skipped: $SKIPPED"
[[ $ERRORS -gt 0 ]] && fail "Errors: $ERRORS"

if ! $DRY_RUN; then
  $DEPLOY_CLAUDE && ok "Claude Code: $CLAUDE_SKILLS"
  $DEPLOY_PI && ok "Pi agent: $PI_SKILLS"
fi
