#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  PAI Fork Install — larsboes/PAI
#  Installs the latest PAI release (auto-detected from Releases/) to ~/.claude/
#  and deploys skill Packs. Override the release with PAI_RELEASE=vX.Y.Z.
#
#  Usage: bash install.sh
# ═══════════════════════════════════════════════════════════
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; RESET='\033[0m'; BOLD='\033[1m'
ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
info() { echo -e "  ${BLUE}ℹ${RESET} $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Auto-detect the newest Releases/vX.Y.Z dir (semver order) so install always ships
# the latest release + the Algorithm version it carries. Override: PAI_RELEASE=v5.0.0
RELEASE_VER="${PAI_RELEASE:-$(ls -1d "$SCRIPT_DIR"/Releases/v*/ 2>/dev/null | xargs -n1 basename | sort -V | tail -1)}"
[ -n "$RELEASE_VER" ] || fail "No Releases/v* directory found"
RELEASE_DIR="$SCRIPT_DIR/Releases/$RELEASE_VER/.claude"
[ -d "$RELEASE_DIR" ] || fail "Release dir missing: $RELEASE_DIR"
CLAUDE_DIR="$HOME/.claude"
ALGO_VERSION="$(cat "$RELEASE_DIR/PAI/ALGORITHM/LATEST" 2>/dev/null || echo '?.?.?')"

echo ""
echo -e "${BOLD}  PAI — Personal AI Infrastructure${RESET}"
echo -e "  Fork: larsboes/PAI | Algorithm v${ALGO_VERSION}"
echo ""

# ── Prerequisites ──────────────────────────────────────────
command -v bun &>/dev/null && ok "bun $(bun --version)" || fail "bun not found — install: curl -fsSL https://bun.sh/install | bash"
command -v git &>/dev/null && ok "git" || fail "git not found"

# ── Backup ─────────────────────────────────────────────────
if [ -d "$CLAUDE_DIR/PAI" ]; then
  BACKUP="$CLAUDE_DIR/.pai-backup-$(date +%Y%m%d-%H%M%S)"
  info "Backing up existing PAI/ → $BACKUP"
  cp -r "$CLAUDE_DIR/PAI" "$BACKUP"
  ok "Backup created"
fi

# ── Install system from release ────────────────────────────
info "Installing PAI system from Releases/${RELEASE_VER}..."

mkdir -p "$CLAUDE_DIR/PAI/Algorithm"
cp -r "$RELEASE_DIR/PAI/ALGORITHM/"* "$CLAUDE_DIR/PAI/Algorithm/"
ok "Algorithm v${ALGO_VERSION}"

mkdir -p "$CLAUDE_DIR/PAI/DOCUMENTATION"
cp -r "$RELEASE_DIR/PAI/DOCUMENTATION/"* "$CLAUDE_DIR/PAI/DOCUMENTATION/"
ok "Documentation"

mkdir -p "$CLAUDE_DIR/PAI/PULSE"
cp -r "$RELEASE_DIR/PAI/PULSE/"* "$CLAUDE_DIR/PAI/PULSE/"
ok "Pulse"

mkdir -p "$CLAUDE_DIR/PAI/Tools" "$CLAUDE_DIR/PAI/TEMPLATES" "$CLAUDE_DIR/PAI/bin"
cp -r "$RELEASE_DIR/PAI/TOOLS/"* "$CLAUDE_DIR/PAI/Tools/" 2>/dev/null || true
cp -r "$RELEASE_DIR/PAI/TEMPLATES/"* "$CLAUDE_DIR/PAI/TEMPLATES/" 2>/dev/null || true
cp -r "$RELEASE_DIR/PAI/bin/"* "$CLAUDE_DIR/PAI/bin/" 2>/dev/null || true
cp "$RELEASE_DIR/PAI/PAI_SYSTEM_PROMPT.md" "$CLAUDE_DIR/PAI/" 2>/dev/null || true
cp "$RELEASE_DIR/PAI/statusline-command.sh" "$CLAUDE_DIR/PAI/" 2>/dev/null || true
ok "Tools, Templates, bin"

cp "$RELEASE_DIR/ISA.md" "$CLAUDE_DIR/ISA.md"
ok "ISA.md"

# Hooks (copies all upstream — custom hooks in ~/.claude/hooks/ are preserved)
mkdir -p "$CLAUDE_DIR/hooks/handlers" "$CLAUDE_DIR/hooks/lib"
for hook in "$RELEASE_DIR/hooks/"*.ts "$RELEASE_DIR/hooks/"*.sh; do
  [ -f "$hook" ] || continue
  cp "$hook" "$CLAUDE_DIR/hooks/"
done
cp -r "$RELEASE_DIR/hooks/handlers/"* "$CLAUDE_DIR/hooks/handlers/" 2>/dev/null || true
cp -r "$RELEASE_DIR/hooks/lib/"* "$CLAUDE_DIR/hooks/lib/" 2>/dev/null || true
cp -r "$RELEASE_DIR/hooks/security" "$CLAUDE_DIR/hooks/" 2>/dev/null || true
ok "Hooks ($(ls "$CLAUDE_DIR/hooks/"*.ts "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null | wc -l) total)"

mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands"
cp "$RELEASE_DIR/agents/"* "$CLAUDE_DIR/agents/" 2>/dev/null || true
cp "$RELEASE_DIR/commands/"* "$CLAUDE_DIR/commands/" 2>/dev/null || true
ok "Agents + Commands"

# ── Unified data layer bridge (private vault → USER/ + MEMORY) ─
# The whole USER data layer (TELOS, identity, MEMORY, SECURITY) lives once in the
# private Obsidian vault at $VAULT_PATH/Resources/PAI (upstream USER convention) and
# is bridged into the engine via two whole-folder symlinks:
#   PAI/USER   → vault/Resources/PAI         (identity, Telos/, Beliefs.md, …)
#   PAI/MEMORY → vault/Resources/PAI/MEMORY  (so engine MEMORY/* refs resolve into vault)
# Identity/TELOS edited once in the vault → every agent sees it. LoadTelos guards absence.
if [ -n "${VAULT_PATH:-}" ] && [ -d "$VAULT_PATH/Resources/PAI" ]; then
  ln -sfn "$VAULT_PATH/Resources/PAI"        "$CLAUDE_DIR/PAI/USER"
  ln -sfn "$VAULT_PATH/Resources/PAI/MEMORY" "$CLAUDE_DIR/PAI/MEMORY"
  ok "Data-layer vault bridge (USER + MEMORY → \$VAULT_PATH/Resources/PAI)"
else
  info "VAULT_PATH unset / no Resources/PAI — skipping vault bridge (LoadTelos guards this)"
fi

# ── Deploy engine + skills to all agents ───────────────────
info "Deploying PAI engine + skill Packs (repo = source of truth)..."
if [ -x "$SCRIPT_DIR/sync.sh" ]; then
  "$SCRIPT_DIR/sync.sh" --confirm && ok "Engine + skills deployed to claude/gemini/pi"
else
  warn "sync.sh not found — run ./sync.sh --confirm manually"
fi

# ── Summary ────────────────────────────────────────────────
echo ""
SKILL_COUNT=$(find "$SCRIPT_DIR/Packs" -name "SKILL.md" 2>/dev/null | wc -l)
ok "PAI installed: Algorithm v${ALGO_VERSION}, ${SKILL_COUNT} packs, Pulse, ISA"
echo ""
echo -e "  ${BOLD}Configure:${RESET} Edit ${BLUE}~/.env${RESET} for service URLs + credentials"
echo -e "  ${BOLD}Identity:${RESET}  Edit ${BLUE}\${VAULT_PATH}/Resources/PAI/${RESET} for personal context"
echo ""
