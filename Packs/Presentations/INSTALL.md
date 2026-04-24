# Presentations v1.0.0 - Installation Guide

**This guide is designed for AI agents installing this pack into a user's infrastructure.**

---

## AI Agent Instructions

### Welcome Message

```
"I'm installing Presentations v1.0.0 — reveal.js presentation creation for Claude Code.

This pack adds 1 skill: revealjs (with 4 scripts and 3 reference files).

Let me analyze your system and guide you through installation."
```

---

## Phase 1: System Analysis

```bash
CLAUDE_DIR="$HOME/.claude"
echo "=== System Check ==="
[ -d "$CLAUDE_DIR" ] && echo "OK Claude Code directory" || echo "MISSING Claude Code directory"
command -v node &>/dev/null && echo "OK node available" || echo "MISSING node (required for scripts)"
command -v npx &>/dev/null && echo "OK npx available (decktape)" || echo "WARN npx not found"
```

---

## Phase 2: Installation

```bash
PACK_DIR="$(dirname "$0")"
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/skills"

if [ -d "$PACK_DIR/src/revealjs" ]; then
  cp -r "$PACK_DIR/src/revealjs" "$CLAUDE_DIR/skills/revealjs"
  echo "Installed: revealjs"
fi
```

### Post-copy: Install npm dependencies

```bash
cd "$CLAUDE_DIR/skills/revealjs" && npm install
```

This installs Playwright (overflow checking) and Cheerio (chart validation).

---

## Phase 3: Verification

Run VERIFY.md checks to confirm installation.
