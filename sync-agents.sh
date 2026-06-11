#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  sync-agents.sh — deploy a fully DECOUPLED PAI to non-Claude agents
#
#  Each non-Claude agent (Gemini/Antigravity, pi) gets its OWN copy of:
#    • the PAI engine        → ~/<agent>/PAI/   (Algorithm, TOOLS, docs, …)
#    • every active skill     → ~/<agent>/skills/<name>/  (full dir, not symlink)
#  with all `~/.claude/{PAI,skills,MEMORY}` references rewritten to that
#  agent's own home. The agents never read ~/.claude.
#
#  Shared MUTABLE data stays single-source in the Obsidian vault:
#    ~/.claude/PAI/USER/TELOS  and  MEMORY  are symlinks → vault, and they
#    ride along in the engine copy, so every agent points at the same vault.
#
#  Claude itself is untouched — it IS ~/.claude.
#
#  Usage:
#    ./sync-agents.sh            # deploy to all agents
#    ./sync-agents.sh --dry-run  # show what would happen
#    ./sync-agents.sh gemini     # one agent only
# ═══════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKS_DIR="$SCRIPT_DIR/Packs"
ENGINE_SRC="$HOME/.claude/PAI"   # canonical engine (Claude's) doubles as the source

# agent spec:  name | tilde-home (for path rewrites) | skills dir
AGENTS=(
  "gemini|~/.gemini|$HOME/.gemini/skills"
  "pi|~/.pi|$HOME/.pi/skills"
)

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; RESET='\033[0m'; BOLD='\033[1m'
ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
info() { echo -e "  ${BLUE}ℹ${RESET} $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; exit 1; }

DRY_RUN=false
ONLY_AGENT=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    gemini|pi) ONLY_AGENT="$arg" ;;
    *) fail "unknown arg: $arg" ;;
  esac
done

[ -d "$ENGINE_SRC" ] || fail "engine source not found: $ENGINE_SRC"
[ -d "$PACKS_DIR" ]  || fail "Packs/ not found: $PACKS_DIR"

# rewrite_refs <dir> <tilde-home>
# Rewrite every ~/.claude/{PAI,skills,MEMORY} ref → the agent's own home,
# in text files only (grep -I skips binaries), never following symlinks.
rewrite_refs() {
  local dir="$1" tilde="$2" files
  files=$(grep -rIl -e '~/.claude/PAI' -e '~/.claude/skills' -e '~/.claude/MEMORY' "$dir" 2>/dev/null || true)
  [ -z "$files" ] && return 0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    [ -L "$f" ] && continue
    sed -i '' \
      -e "s#~/.claude/PAI#${tilde}/PAI#g" \
      -e "s#~/.claude/skills#${tilde}/skills#g" \
      -e "s#~/.claude/MEMORY#${tilde}/PAI/MEMORY#g" \
      "$f"
  done <<< "$files"
}

RSYNC_EXCLUDES=(--exclude 'PULSE' --exclude 'node_modules' --exclude '.git'
                --exclude 'dist' --exclude '*.log' --exclude '.cursor' --exclude '.DS_Store')

echo ""
echo -e "${BOLD}  PAI Agent Decouple Sync${RESET}"
$DRY_RUN && info "DRY RUN — no changes"
echo ""

for spec in "${AGENTS[@]}"; do
  IFS='|' read -r name tilde skills_dir <<< "$spec"
  [ -n "$ONLY_AGENT" ] && [ "$ONLY_AGENT" != "$name" ] && continue
  real_home="${tilde/#\~/$HOME}"
  engine_dst="$real_home/PAI"

  echo -e "${BOLD}── $name ──────────────────────────────────────${RESET}"

  if $DRY_RUN; then
    info "would replicate engine → $engine_dst (rewrite ~/.claude→$tilde)"
    n=$(find "$PACKS_DIR" -maxdepth 2 -name SKILL.md -path '*/src/SKILL.md' | wc -l | tr -d ' ')
    info "would deploy $n+ skills → $skills_dir (full copies, rewritten)"
    echo ""
    continue
  fi

  # ── Engine ──────────────────────────────────────────────
  mkdir -p "$engine_dst"
  rsync -a --delete "${RSYNC_EXCLUDES[@]}" "$ENGINE_SRC/" "$engine_dst/"
  rewrite_refs "$engine_dst" "$tilde"
  ok "engine → $engine_dst ($(du -sh "$engine_dst" 2>/dev/null | awk '{print $1}'))"

  # ── Skills (full copies) ────────────────────────────────
  mkdir -p "$skills_dir"
  count=0
  for pack in "$PACKS_DIR"/*/; do
    src="${pack}src"
    [ -f "$src/SKILL.md" ] || continue
    sname=$(basename "${pack%/}")
    dst="$skills_dir/$sname"
    # CRITICAL: drop any existing symlink first so rsync can't write through it into the source repo
    [ -L "$dst" ] && rm -f "$dst"
    rsync -a --delete "${RSYNC_EXCLUDES[@]}" "$src/" "$dst/"
    rewrite_refs "$dst" "$tilde"
    count=$((count+1))
  done
  ok "$count skills → $skills_dir (decoupled copies)"

  # Sweep the whole skills dir so pre-existing orphans (nested sub-skills from
  # older deploy mechanisms) are decoupled too, not just the 89 managed packs.
  rewrite_refs "$skills_dir" "$tilde"

  # ── Verify ──────────────────────────────────────────────
  leak=$( { grep -rIl -e '~/.claude/PAI' -e '~/.claude/skills' -e '~/.claude/MEMORY' "$engine_dst" "$skills_dir" 2>/dev/null || true; } | wc -l | tr -d ' ')
  if [ "$leak" -eq 0 ]; then ok "0 residual ~/.claude/{PAI,skills,MEMORY} refs"
  else warn "$leak files still reference ~/.claude/{PAI,skills,MEMORY}"; fi
  echo ""
done

echo -e "${BOLD}── done ───────────────────────────────────────${RESET}"
info "Claude untouched. Other agents self-serve PAI from their own home; TELOS/MEMORY shared via vault."
echo ""
