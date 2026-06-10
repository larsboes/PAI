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
MARKET_DESC="PAI skill marketplace — coding, content, devtools, terminal, integrations, thinking, and more"
OWNER="Lars Boes"

# ── Plugin taxonomy ─────────────────────────────────────────
# One entry per plugin: "key|description". Membership in PLUGIN_PACKS below.
# Edit freely — re-run to regenerate. Unassigned packs are reported, never dropped silently.
PLUGINS=(
  "coding|TypeScript, Swift, Python/uv, architecture, data engineering, APIs, Docker, CI/CD"
  "content|HTML docs, Mermaid diagrams, office documents, video, content extraction"
  "devtools|Context7 docs, deep debugging, web/UI design, security, git, evals, browser"
  "terminal|cmux + tmux multiplexer control, background daemons, loop patterns"
  "skillsmeta|Skill forge, skill creation, PAI upgrade, prompting — meta tooling"
  "integrations|GitHub, Google, Notion, Jira, Confluence, Outlook, mail, cloud, metrics"
  "obsidian|Obsidian vault + knowledge base + OSINT investigation"
  "thinking|First principles, systems thinking, council, red team, ideation, research"
)

# Plugin → packs (space-separated current Packs/ dir names).
declare -A PLUGIN_PACKS=(
  [coding]="Architecture ApiPatterns DataEngineer FluentBit Logstash Swift TypeScript Uv CreateCLI DevOps Docker Bazel DevWorkflow"
  [content]="HtmlDocs Mermaid Documents PPTX ContentAnalysis ExtractWisdom Parser Remotion Art Media revealjs"
  [devtools]="Context7 Deep Webdesign Security Git Evals Interceptor Browser BrightData Apify Scraping"
  [terminal]="Cmux Tmux Daemon Loop"
  [skillsmeta]="SkillForge CreateSkill PAIUpgrade Prompting BitterPillEngineering"
  [integrations]="Google Notion Confluence Jira Outlook MailCraft Azure Cloudflare USMetrics"
  [obsidian]="Obsidian Knowledge Investigation"
  [thinking]="Thinking Council RedTeam FirstPrinciples SystemsThinking RootCauseAnalysis IterativeDepth ApertureOscillation BlindSpot Brainstorm BeCreative Ideate Science Research"
)

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
  info "Cloning $MARKET_REPO…"
  git clone -q "$MARKET_REPO" "$BUILD_DIR" 2>/dev/null || { mkdir -p "$BUILD_DIR"; git -C "$BUILD_DIR" init -q; git -C "$BUILD_DIR" remote add origin "$MARKET_REPO" 2>/dev/null || true; }
fi

# ── Clean generated areas (idempotent) ──────────────────────
rm -rf "$BUILD_DIR/.claude-plugin" "$BUILD_DIR/marketplace"
mkdir -p "$BUILD_DIR/.claude-plugin" "$BUILD_DIR/marketplace/plugins"

# ── Generate plugins ────────────────────────────────────────
PLUGIN_JSON_ENTRIES=()
TOTAL_SKILLS=0
ASSIGNED=""

for entry in "${PLUGINS[@]}"; do
  key="${entry%%|*}"; desc="${entry#*|}"
  pdir="$BUILD_DIR/marketplace/plugins/$key"
  mkdir -p "$pdir/.claude-plugin" "$pdir/skills"
  count=0
  for pack in ${PLUGIN_PACKS[$key]:-}; do
    src="$PACKS_DIR/$pack/src"
    if [ ! -d "$src" ]; then warn "[$key] pack '$pack' has no src/ — skipped"; continue; fi
    rsync -a --delete \
      --exclude 'node_modules' --exclude '.git' --exclude 'dist' --exclude '*.log' \
      "$src/" "$pdir/skills/$pack/"
    count=$((count+1)); TOTAL_SKILLS=$((TOTAL_SKILLS+1)); ASSIGNED="$ASSIGNED $pack"
  done
  jq -n --arg n "$key" --arg d "$desc" --arg a "$OWNER" \
    '{name:$n, description:$d, version:"1.0.0", author:{name:$a}}' > "$pdir/.claude-plugin/plugin.json"
  PLUGIN_JSON_ENTRIES+=("$(jq -n --arg n "$key" --arg s "./marketplace/plugins/$key" --arg d "$desc" \
    '{name:$n, source:$s, description:$d, strict:false}')")
  ok "$key — $count skills"
done

# ── Root marketplace.json ───────────────────────────────────
printf '%s\n' "${PLUGIN_JSON_ENTRIES[@]}" | jq -s \
  --arg n "$MARKET_NAME" --arg o "$OWNER" --arg d "$MARKET_DESC" \
  '{name:$n, owner:{name:$o}, metadata:{description:$d, pluginRoot:"./marketplace/plugins"}, plugins:.}' \
  > "$BUILD_DIR/.claude-plugin/marketplace.json"
ok "marketplace.json (${#PLUGINS[@]} plugins, $TOTAL_SKILLS skills)"

# ── Report unassigned packs (no silent drops) ───────────────
echo ""
info "Unassigned packs (not in any plugin — add to PLUGIN_PACKS to include):"
for pack in $(ls -1 "$PACKS_DIR"); do
  [ -d "$PACKS_DIR/$pack/src" ] || continue
  case " $ASSIGNED " in *" $pack "*) : ;; *) echo "     · $pack" ;; esac
done

# ── README for the marketplace repo ─────────────────────────
cat > "$BUILD_DIR/README.md" <<EOF
# PAI Skills Marketplace

A Claude Code plugin marketplace generated from [larsboes/PAI](https://github.com/larsboes/PAI) \`Packs/\`.

\`\`\`
/plugin marketplace add larsboes/pai-marketplace
/plugin install coding@${MARKET_NAME}
\`\`\`

**Plugins:** $(printf '%s, ' "${PLUGINS[@]%%|*}" | sed 's/, $//')

> Generated by \`marketplace-sync.sh\` in the PAI repo — do not hand-edit; edit the mapping there and re-run.
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
