#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  sync-deploy.sh — Symlink PAI skills to all coding assistants
#
#  Creates symlinks from agent skill dirs → PAI/Packs/X/src/.
#  Agents read through symlinks → always current source.
#  Agent edits write through to PAI source (git tracked).
#
#  Usage:
#    ./sync-deploy.sh                    # deploy all active skills
#    ./sync-deploy.sh --profile security # include a profile
#    ./sync-deploy.sh --clean            # wipe ALL skills + rebuild
#    ./sync-deploy.sh --dry-run          # show what would happen
# ═══════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKS_DIR="$SCRIPT_DIR/Packs"
SKILLS_YAML="$SCRIPT_DIR/skills.yaml"

# Target directories for each agent
CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
PI_DIR="${PI_SKILLS_DIR:-$HOME/.pi/agent/skills}"
GEMINI_DIR="${GEMINI_SKILLS_DIR:-$HOME/.gemini/skills}"
TARGETS=("$CLAUDE_DIR" "$PI_DIR" "$GEMINI_DIR")

# Colors
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; DIM='\033[2m'; RESET='\033[0m'; BOLD='\033[1m'
ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
info() { echo -e "  ${BLUE}ℹ${RESET} $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; exit 1; }

# Parse args
DRY_RUN=false
PROFILE=""
CLEAN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --clean) CLEAN=true; shift ;;
    -h|--help)
      echo "Usage: ./sync-deploy.sh [--clean] [--profile NAME] [--dry-run]"
      echo ""
      echo "  --clean       Wipe all existing skills (real dirs + symlinks) and rebuild"
      echo "  --profile X   Include profile skills (security, writing, devops, thinking)"
      echo "  --dry-run     Show what would happen without making changes"
      exit 0 ;;
    *) fail "Unknown option: $1" ;;
  esac
done

# Parse skills.yaml
parse_active_skills() {
  sed -n '/^active:/,/^[a-z]/{/^  - /p}' "$SKILLS_YAML" | sed 's/^  - //'
}

parse_profile_skills() {
  local profile="$1"
  sed -n "/^  $profile:/,/^  [a-z]/{/^    - /p}" "$SKILLS_YAML" | sed 's/^    - //'
}

# Gather active skills
ACTIVE_SKILLS=$(parse_active_skills)
if [[ -n "$PROFILE" ]]; then
  PROFILE_SKILLS=$(parse_profile_skills "$PROFILE")
  ACTIVE_SKILLS=$(echo -e "$ACTIVE_SKILLS\n$PROFILE_SKILLS" | sort -u)
fi

SKILL_COUNT=$(echo "$ACTIVE_SKILLS" | grep -c "." || true)

echo -e "${BOLD}${BLUE}── PAI Skill Deploy (symlinks) ──────────────────────────${RESET}"
info "Source: $PACKS_DIR"
info "Active skills: $SKILL_COUNT"
[[ -n "$PROFILE" ]] && info "Profile: $PROFILE"
$DRY_RUN && info "DRY RUN — no changes will be made"
echo ""

# Ensure target dirs exist
for target in "${TARGETS[@]}"; do
  $DRY_RUN || mkdir -p "$target"
done

# Clean phase: remove everything that points to PAI or is a skill we manage
if $CLEAN; then
  info "Cleaning agent skill directories..."
  for target in "${TARGETS[@]}"; do
    [[ ! -d "$target" ]] && continue
    if $DRY_RUN; then
      info "Would clean $target"
      continue
    fi
    # Remove symlinks pointing into PAI/Packs
    find "$target" -maxdepth 1 -type l | while read -r link; do
      dest=$(readlink "$link" 2>/dev/null || true)
      if [[ "$dest" == *"/PAI/Packs/"* ]]; then
        rm -f "$link"
      fi
    done
    # Remove real directories that match active pack names
    while IFS= read -r pack; do
      [[ -z "$pack" ]] && continue
      if [[ -d "$target/$pack" && ! -L "$target/$pack" ]]; then
        rm -rf "$target/$pack"
      fi
    done <<< "$ACTIVE_SKILLS"
    ok "Cleaned: $target"
  done
  echo ""
else
  # Even without --clean, remove stale PAI symlinks
  for target in "${TARGETS[@]}"; do
    [[ ! -d "$target" ]] && continue
    find "$target" -maxdepth 1 -type l | while read -r link; do
      dest=$(readlink "$link" 2>/dev/null || true)
      if [[ "$dest" == *"/PAI/Packs/"* ]]; then
        $DRY_RUN || rm -f "$link"
      fi
    done
  done
fi

# Deploy phase: create symlinks
DEPLOYED=0
SKIPPED=0

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
    ok "$pack → src/"
    ((DEPLOYED++)) || true
    continue
  fi

  # Create symlinks in all target dirs
  for target in "${TARGETS[@]}"; do
    # Remove existing (real dir or broken symlink) if present
    if [[ -e "$target/$pack" || -L "$target/$pack" ]]; then
      rm -rf "$target/$pack"
    fi
    ln -sfn "$SRC" "$target/$pack"
  done

  ok "$pack"
  ((DEPLOYED++)) || true
done <<< "$ACTIVE_SKILLS"

echo ""
echo -e "${BOLD}── Summary ──────────────────────────────────────────────────${RESET}"
info "Deployed: $DEPLOYED skills × ${#TARGETS[@]} agents"
[[ $SKIPPED -gt 0 ]] && warn "Skipped: $SKIPPED"

if ! $DRY_RUN; then
  for target in "${TARGETS[@]}"; do
    count=$(find "$target" -maxdepth 1 -type l 2>/dev/null | wc -l)
    ok "$target ($count symlinks)"
  done
fi
echo ""
echo -e "${DIM}  Symlinks point to source → edits write through to PAI/Packs/ (git tracked).${RESET}"
echo -e "${DIM}  Pi config: remove customDirectories, add ~/.pi/agent/skills to skill paths.${RESET}"
