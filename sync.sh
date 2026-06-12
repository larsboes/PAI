#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  sync.sh — the single PAI sync entrypoint (repo = source of truth)
#
#  Supersedes three older scripts:
#    • sync-deploy.sh   (Claude symlinks to Packs)        → folded in
#    • sync-agents.sh   (decoupled engine+skill copies)   → folded in
#    • pai-sync.sh      (@sync tag routing per agent)      → folded in
#
#  MODEL
#  ─────
#  This repo (Developer/PAI) is the SINGLE SOURCE OF TRUTH:
#      PAI/         → the engine (Algorithm, Tools, DOCUMENTATION, doctrine …)
#      Packs/*/src  → skills (one Pack = one skill dir containing SKILL.md)
#
#  Every agent is a DEPLOY TARGET. None is the source.
#
#      claude  (~/.claude)  skills = SYMLINK → repo/Packs/*/src   (write-through edits)
#                           engine = rsync overlay (no --delete; keeps USER/MEMORY/PULSE)
#      gemini  (~/.gemini)  skills = COPY + ref-rewrite           (fully decoupled)
#                           engine = COPY + ref-rewrite
#      pi      (~/.pi)      skills = COPY + ref-rewrite
#                           engine = COPY + ref-rewrite
#
#  Unified mutable data (MEMORY, TELOS) stays single-source in the Obsidian
#  vault via symlinks under each agent's PAI/ — this script never touches it.
#
#  @sync ROUTING  (frontmatter line in each Pack's src/SKILL.md)
#      # @sync: private          → pi only
#      # @sync: public|personal  → claude + gemini + pi   (default = public)
#
#  USAGE
#      ./sync.sh                 # dry run, all agents
#      ./sync.sh --confirm       # apply
#      ./sync.sh --confirm gemini# one agent only
#      ./sync.sh --status        # compact drift summary
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKS_DIR="$SCRIPT_DIR/Packs"
ENGINE_SRC="$SCRIPT_DIR/PAI"          # repo IS the source now (was ~/.claude/PAI)
SKILLS_YAML="$SCRIPT_DIR/skills.yaml"
TEMPLATES_DIR="$ENGINE_SRC/TEMPLATES/AgentConfig"  # CLAUDE.md / GEMINI.md templates

# agent spec:  name | tilde-home | skills-dir | engine-dir | mode(symlink|copy)
AGENTS=(
  "claude|~/.claude|$HOME/.claude/skills|$HOME/.claude/PAI|symlink"
  "gemini|~/.gemini|$HOME/.gemini/skills|$HOME/.gemini/PAI|copy"
  "pi|~/.pi|$HOME/.pi/skills|$HOME/.pi/PAI|copy"
)

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; DIM='\033[2m'; RESET='\033[0m'; BOLD='\033[1m'
ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
info() { echo -e "  ${BLUE}ℹ${RESET} $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; exit 1; }

CONFIRM=false
STATUS_ONLY=false
ONLY_AGENT=""
for arg in "$@"; do
  case "$arg" in
    --confirm)        CONFIRM=true ;;
    --dry-run)        CONFIRM=false ;;
    --status)         STATUS_ONLY=true ;;
    -h|--help)        sed -n '2,45p' "$0"; exit 0 ;;
    claude|gemini|pi) ONLY_AGENT="$arg" ;;
    *)                fail "unknown arg: $arg" ;;
  esac
done

[ -d "$ENGINE_SRC" ] || fail "engine source not found: $ENGINE_SRC (run the engine capture first)"
[ -d "$PACKS_DIR" ]  || fail "Packs/ not found: $PACKS_DIR"

RSYNC_EXCLUDES=(--exclude 'USER' --exclude 'MEMORY' --exclude 'PULSE' --exclude 'node_modules'
                --exclude '.git' --exclude 'dist' --exclude '*.log' --exclude '.cursor'
                --exclude '.DS_Store' --exclude '.env' --exclude '*.env' --exclude '*.key' --exclude '*.pem')

# get_sync_tag <skill_md>  → private | personal | public (default public)
get_sync_tag() {
  local tag; tag=$(grep -o '# @sync: [a-z]*' "$1" 2>/dev/null | sed 's/# @sync: //' | head -1 || true)
  echo "${tag:-public}"
}

# agent_gets_tag <agent> <tag>  → 0 (yes) / 1 (no)
agent_gets_tag() {
  local agent="$1" tag="$2"
  case "$tag" in
    private) [ "$agent" = "pi" ] ;;
    *)       return 0 ;;
  esac
}

# rewrite_refs <dir> <tilde-home>  — fully decouple copies from ~/.claude (copy agents only)
# Blanket-rewrites EVERY ~/.claude reference (hooks, Bin, settings.json, agents,
# commands, PAI, skills, …) to the agent's own home, so no deployed file ever
# reaches back into Claude's home. MEMORY is special-cased: it lives under PAI/.
rewrite_refs() {
  local dir="$1" tilde="$2" real files
  real="${tilde/#\~/$HOME}"
  files=$(grep -rIl -e '~/.claude' -e "$HOME/.claude" "$dir" 2>/dev/null || true)
  [ -z "$files" ] && return 0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    [ -L "$f" ] && continue
    sed -i '' \
      -e "s#~/.claude/MEMORY#${tilde}/PAI/MEMORY#g" \
      -e "s#${HOME}/.claude/MEMORY#${real}/PAI/MEMORY#g" \
      -e "s#~/.claude#${tilde}#g" \
      -e "s#${HOME}/.claude#${real}#g" \
      "$f"
  done <<< "$files"
}

# identity_block <ident-dir>  — concatenate the vault identity files into one block
identity_block() {
  local ident="$1" f
  echo "## Identity & Operating Profile"
  echo ""
  echo "> Single-source: Obsidian vault \`PAI/Identity/\` (symlinked into \`PAI/USER/\`). Edit there, not here."
  for f in DAIDENTITY.md ABOUTME.md AISTEERINGRULES.md; do
    [ -f "$ident/$f" ] || continue
    echo ""; echo "---"; echo ""
    cat "$ident/$f"
  done
}

# deploy_config <agent> <tilde-home>  — render the agent's CLAUDE.md/GEMINI.md
# from the repo template, injecting the vaulted identity at the PAI:IDENTITY marker.
deploy_config() {
  local agent="$1" tilde="$2" real tmpl dst inject ident
  real="${tilde/#\~/$HOME}"
  case "$agent" in
    claude) tmpl="$TEMPLATES_DIR/CLAUDE.md";  dst="$real/CLAUDE.md";  inject=false ;;
    gemini) tmpl="$TEMPLATES_DIR/GEMINI.md";  dst="$real/GEMINI.md";  inject=true  ;;
    *)      return 0 ;;
  esac
  [ -f "$tmpl" ] || { warn "no config template for $agent"; return 0; }
  if $inject; then
    # derive the canonical vault identity dir from this agent's USER symlink
    ident="$(dirname "$(readlink "$real/PAI/USER/ABOUTME.md" 2>/dev/null)" 2>/dev/null)"
    if [ -n "$ident" ] && [ -d "$ident" ]; then
      local blk; blk="$(mktemp)"; identity_block "$ident" > "$blk"
      awk '
        /<!-- PAI:IDENTITY -->/      { while ((getline l < BF) > 0) print l; close(BF); skip=1; next }
        /<!-- \/PAI:IDENTITY -->/    { skip=0; next }
        skip!=1                      { print }
      ' BF="$blk" "$tmpl" > "$dst"
      rm -f "$blk"
      ok "config → $dst (identity injected from vault)"
    else
      warn "vault identity dir not found for $agent — deploying template verbatim"; cp "$tmpl" "$dst"
    fi
  else
    # Claude: render via BuildCLAUDE.ts — resolves {{PAI_VERSION}}, {{ALGO_PATH}},
    # {DAIDENTITY.NAME} from settings.json + Algorithm/LATEST (the canonical renderer,
    # also run by the SessionStart hook). Reads the deployed repo template.
    local builder="$real/PAI/Tools/BuildCLAUDE.ts"
    if [ -f "$builder" ] && command -v bun >/dev/null 2>&1; then
      ( bun "$builder" >/dev/null 2>&1 ) && ok "config → $dst (rendered via BuildCLAUDE.ts)" \
        || { warn "BuildCLAUDE.ts failed — copying template raw"; cp "$tmpl" "$dst"; }
    else
      warn "bun/BuildCLAUDE unavailable — copying template raw (may contain placeholders)"; cp "$tmpl" "$dst"
    fi
  fi
}

echo ""
echo -e "${BOLD}  PAI Sync — repo is source of truth${RESET}"
$CONFIRM || info "DRY RUN — no changes (pass --confirm to apply)"
echo ""

for spec in "${AGENTS[@]}"; do
  IFS='|' read -r name tilde skills_dir engine_dst mode <<< "$spec"
  [ -n "$ONLY_AGENT" ] && [ "$ONLY_AGENT" != "$name" ] && continue

  echo -e "${BOLD}── $name ($mode) ──────────────────────────────${RESET}"

  # ── Engine ────────────────────────────────────────────────────────────────
  if $CONFIRM; then
    mkdir -p "$engine_dst"
    if [ "$mode" = "symlink" ]; then
      # Claude: overlay engine files, NEVER --delete (preserves live USER/MEMORY/PULSE)
      rsync -a "${RSYNC_EXCLUDES[@]}" "$ENGINE_SRC/" "$engine_dst/"
    else
      # gemini/pi: full decoupled replica, then rewrite refs
      rsync -a --delete "${RSYNC_EXCLUDES[@]}" "$ENGINE_SRC/" "$engine_dst/"
      rewrite_refs "$engine_dst" "$tilde"
    fi
    ok "engine → $engine_dst"
  else
    info "would deploy engine → $engine_dst ($mode)"
  fi

  real_home="${tilde/#\~/$HOME}"

  # ── commands/ + lib/ (cross-agent — skills invoke them) ───────────────────
  if $CONFIRM; then
    for sub in commands lib; do
      [ -d "$SCRIPT_DIR/$sub" ] || continue
      sub_dst="$real_home/$sub"; mkdir -p "$sub_dst"
      if [ "$mode" = "symlink" ]; then
        rsync -a "${RSYNC_EXCLUDES[@]}" "$SCRIPT_DIR/$sub/" "$sub_dst/"
      else
        rsync -a --delete "${RSYNC_EXCLUDES[@]}" "$SCRIPT_DIR/$sub/" "$sub_dst/"
        rewrite_refs "$sub_dst" "$tilde"
      fi
      ok "$sub → $sub_dst"
    done
  fi

  # ── agents/ + hooks/ + VoiceServer/ (Claude-specific — Claude only, overlay) ─
  if $CONFIRM && [ "$name" = "claude" ]; then
    for sub in agents hooks VoiceServer; do
      [ -d "$SCRIPT_DIR/$sub" ] || continue
      mkdir -p "$real_home/$sub"
      rsync -a "${RSYNC_EXCLUDES[@]}" "$SCRIPT_DIR/$sub/" "$real_home/$sub/"
      ok "$sub → $real_home/$sub"
    done
  fi

  # ── Skills (tag-routed) ───────────────────────────────────────────────────
  mkdir -p "$skills_dir" 2>/dev/null || true
  count=0; skipped=0
  for pack in "$PACKS_DIR"/*/; do
    src="${pack}src"
    [ -f "$src/SKILL.md" ] || continue
    sname=$(basename "${pack%/}")
    tag=$(get_sync_tag "$src/SKILL.md")
    if ! agent_gets_tag "$name" "$tag"; then
      skipped=$((skipped+1)); continue
    fi
    dst="$skills_dir/$sname"
    if $CONFIRM; then
      if [ "$mode" = "symlink" ]; then
        # Claude: symlink → repo source (edits write through to SOT)
        [ -e "$dst" ] || [ -L "$dst" ] && rm -rf "$dst"
        ln -sfn "$src" "$dst"
      else
        # gemini/pi: drop any symlink first so rsync can't write through into the repo
        [ -L "$dst" ] && rm -f "$dst"
        rsync -a --delete "${RSYNC_EXCLUDES[@]}" "$src/" "$dst/"
        rewrite_refs "$dst" "$tilde"
      fi
    fi
    count=$((count+1))
  done
  if $CONFIRM; then ok "$count skills → $skills_dir (${skipped} skipped by @sync tag)"
  else info "would deploy ~$count skills (${skipped} private-skipped) → $skills_dir ($mode)"; fi

  # ── Orphan sweep (copy agents only) ───────────────────────────────────────
  # Remove any top-level skill dir not backed by a deployed Pack. Symlink-mode
  # (Claude) is swept separately at cutover; we never auto-delete real dirs there.
  if $CONFIRM && [ "$mode" = "copy" ] && [ -d "$skills_dir" ]; then
    swept=0
    for d in "$skills_dir"/*/; do
      [ -d "$d" ] || continue
      dn=$(basename "${d%/}")
      [ -f "$PACKS_DIR/$dn/src/SKILL.md" ] && continue
      rm -rf "$d"; swept=$((swept+1))
    done
    [ "$swept" -gt 0 ] && ok "swept $swept orphan skill dirs (no source Pack)"
  fi

  # ── Verify (copy agents: zero residual ~/.claude refs anywhere) ───────────
  if $CONFIRM && [ "$mode" = "copy" ]; then
    leak=$( { grep -rIl -e '~/.claude' -e "$HOME/.claude" "$engine_dst" "$skills_dir" 2>/dev/null || true; } | wc -l | tr -d ' ')
    [ "$leak" -eq 0 ] && ok "0 residual ~/.claude refs" || warn "$leak files still reference ~/.claude"
  fi

  # ── Agent config (CLAUDE.md / GEMINI.md from repo template + vault identity) ─
  if $CONFIRM; then deploy_config "$name" "$tilde"
  else info "would deploy config from $TEMPLATES_DIR ($name)"; fi
  echo ""
done

echo -e "${BOLD}── done ──────────────────────────────────${RESET}"
info "Repo = source of truth. claude/gemini/pi are deploy targets. MEMORY+TELOS shared via vault."
echo ""
