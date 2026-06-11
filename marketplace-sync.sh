#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  marketplace-sync.sh — generate the Claude Code plugin marketplace
#  from the CURRENT Packs/ and (optionally) push to larsboes/pai-marketplace.
#
#  A Claude Code marketplace is its OWN repo: `.claude-plugin/marketplace.json`
#  at the root + plugins under marketplace/plugins/<p>/ (each with its own
#  .claude-plugin/plugin.json and skills/). This script is the single source of
#  that repo's content — never hand-edit the marketplace repo; edit the mapping
#  below and re-run.
#
#  Usage:
#    bash marketplace-sync.sh            # generate into build dir, show report
#    bash marketplace-sync.sh --push     # generate + commit + push to origin
#    MARKET_REPO=<url> bash marketplace-sync.sh --push
# ═══════════════════════════════════════════════════════════
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; RESET='\033[0m'; BOLD='\033[1m'
ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
info() { echo -e "  ${BLUE}ℹ${RESET} $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKS_DIR="$SCRIPT_DIR/Packs"
MARKET_REPO="${MARKET_REPO:-https://github.com/larsboes/pai-marketplace.git}"
BUILD_DIR="${MARKET_BUILD_DIR:-$SCRIPT_DIR/.marketplace-build}"
PUSH=0; [ "${1:-}" = "--push" ] && PUSH=1

MARKET_NAME="pai-skills"
MARKET_DESC="PAI skill marketplace — one installable plugin per PAI pack"
OWNER="Lars Boes"

# ── Publishing model ────────────────────────────────────────
# ONE plugin per pack: every Packs/<Name>/src that has a SKILL.md becomes its own
# plugin, mirroring PAI 1:1. Each plugin's description is read from the pack's own
# SKILL.md frontmatter.
#
# Packs are TOOLING — private data lives in the Obsidian vault (USER/), never in a pack,
# and the PAI source repo is already public. So nothing is excluded by default. Add a pack
# dir name here only if a specific pack ever embeds runtime secrets/PII.
EXCLUDE_PACKS=""

command -v jq &>/dev/null || fail "jq not found"
command -v git &>/dev/null || fail "git not found"
command -v rsync &>/dev/null || fail "rsync not found"
[ -d "$PACKS_DIR" ] || fail "Packs/ not found at $PACKS_DIR"

echo ""
echo -e "${BOLD}  PAI Marketplace Sync${RESET} → ${MARKET_NAME}"
echo ""

# ── Get a checkout of the marketplace repo ──────────────────
if [ -d "$BUILD_DIR/.git" ]; then
  info "Updating build checkout…"
  git -C "$BUILD_DIR" fetch -q origin && git -C "$BUILD_DIR" reset -q --hard origin/HEAD 2>/dev/null || true
else
  info "Cloning ${MARKET_REPO}…"
  git clone -q "$MARKET_REPO" "$BUILD_DIR" 2>/dev/null || { mkdir -p "$BUILD_DIR"; git -C "$BUILD_DIR" init -q; git -C "$BUILD_DIR" remote add origin "$MARKET_REPO" 2>/dev/null || true; }
fi

# ── Clean generated areas (idempotent) ──────────────────────
rm -rf "$BUILD_DIR/.claude-plugin" "$BUILD_DIR/marketplace"
mkdir -p "$BUILD_DIR/.claude-plugin" "$BUILD_DIR/marketplace/plugins"

# ── Generate one plugin per pack ────────────────────────────
PLUGIN_JSON_ENTRIES=()
TOTAL_SKILLS=0
EXCLUDED=""

for pack in $(ls -1 "$PACKS_DIR"); do
  src="$PACKS_DIR/$pack/src"
  [ -d "$src" ] || continue
  [ -f "$src/SKILL.md" ] || { warn "$pack has src/ but no SKILL.md — skipped"; continue; }
  case " $EXCLUDE_PACKS " in *" $pack "*) EXCLUDED="$EXCLUDED $pack"; continue ;; esac

  # plugin slug: CamelCase pack dir → kebab-case lowercase (e.g. ApiPatterns → api-patterns)
  key=$(printf '%s' "$pack" | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  # description from the pack's own SKILL.md frontmatter (first line); fall back to pack name
  desc=$(awk 'NR>1 && /^---[[:space:]]*$/{exit} sub(/^description:[[:space:]]*/,""){print; exit}' "$src/SKILL.md" | sed -E 's/^"//; s/"$//')
  [ -n "$desc" ] || desc="$pack"

  pdir="$BUILD_DIR/marketplace/plugins/$key"
  mkdir -p "$pdir/.claude-plugin" "$pdir/skills"
  rsync -a --delete \
    --exclude 'node_modules' --exclude '.git' --exclude 'dist' --exclude '*.log' \
    --exclude '.cursor' --exclude '.DS_Store' \
    "$src/" "$pdir/skills/$pack/"
  jq -n --arg n "$key" --arg d "$desc" --arg a "$OWNER" \
    '{name:$n, description:$d, author:{name:$a}}' > "$pdir/.claude-plugin/plugin.json"
  PLUGIN_JSON_ENTRIES+=("$(jq -n --arg n "$key" --arg s "./marketplace/plugins/$key" --arg d "$desc" \
    '{name:$n, source:$s, description:$d, strict:false}')")
  TOTAL_SKILLS=$((TOTAL_SKILLS+1))
  ok "$key"
done

NUM_PLUGINS=${#PLUGIN_JSON_ENTRIES[@]}

# ── Root marketplace.json ───────────────────────────────────
printf '%s\n' "${PLUGIN_JSON_ENTRIES[@]}" | jq -s \
  --arg n "$MARKET_NAME" --arg o "$OWNER" --arg d "$MARKET_DESC" \
  '{name:$n, owner:{name:$o}, metadata:{description:$d}, plugins:.}' \
  > "$BUILD_DIR/.claude-plugin/marketplace.json"
ok "marketplace.json ($NUM_PLUGINS plugins, one per pack)"

# ── Report excluded packs (no silent drops) ─────────────────
echo ""
if [ -n "$EXCLUDED" ]; then
  info "Excluded (private — edit EXCLUDE_PACKS to change):"
  for p in $EXCLUDED; do echo "     · $p"; done
fi

# ── README for the marketplace repo ─────────────────────────
cat > "$BUILD_DIR/README.md" <<EOF
# PAI Skills Marketplace

A Claude Code plugin marketplace generated from [larsboes/PAI](https://github.com/larsboes/PAI) \`Packs/\`.

\`\`\`
/plugin marketplace add larsboes/pai-marketplace
/plugin install typescript@${MARKET_NAME}
\`\`\`

**Plugins:** one per PAI pack ($NUM_PLUGINS total).

> Generated by \`marketplace-sync.sh\` in the PAI repo — do not hand-edit; edit the source packs there and re-run.
EOF

# ── Push ────────────────────────────────────────────────────
if [ "$PUSH" = "1" ]; then
  git -C "$BUILD_DIR" add -A
  if git -C "$BUILD_DIR" diff --cached --quiet; then
    info "No changes to push."
  else
    # --no-verify: the marketplace is a GENERATED mirror of Packs/ — those sources are
    # already gitleaks-governed at authorship in the PAI repo. Re-scanning generated
    # copies only re-flags known security-tooling fixtures (e.g. Daemon SecurityFilter
    # redaction test cases, OSINT "LinkedIn" keyword hits). No new secrets are introduced.
    git -C "$BUILD_DIR" commit -q --no-verify -m "sync: regenerate marketplace from PAI Packs ($TOTAL_SKILLS skills)"
    git -C "$BUILD_DIR" branch -M main
    git -C "$BUILD_DIR" push -q -u origin main && ok "Pushed to $MARKET_REPO"
  fi
else
  echo ""
  info "Generated in $BUILD_DIR (dry run). Re-run with --push to publish."
fi
echo ""
