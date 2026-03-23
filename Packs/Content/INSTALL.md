# Content v1.0.0 - Installation Guide

**This guide is designed for AI agents installing this pack into a user's infrastructure.**

---

## AI Agent Instructions

### Welcome Message

```
"I'm installing Content v1.0.0 — content processing and extraction for Claude Code.

This pack adds 4 skills: webfetch, html-docs, transcribe, mermaid.

Let me analyze your system and guide you through installation."
```

---

## Phase 1: System Analysis

```bash
CLAUDE_DIR="$HOME/.claude"
echo "=== System Check ==="
[ -d "$CLAUDE_DIR" ] && echo "OK Claude Code directory" || echo "MISSING Claude Code directory"
command -v uvx &>/dev/null && echo "OK uvx available (markitdown)" || echo "WARN uvx not found"
command -v bun &>/dev/null && echo "OK bun available" || echo "WARN bun not found — some skills use bun"
```

---

## Phase 2: Installation

```bash
PACK_DIR="$(dirname "$0")"
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/skills"

for skill in webfetch html-docs transcribe mermaid; do
  if [ -d "$PACK_DIR/src/$skill" ]; then
    cp -r "$PACK_DIR/src/$skill" "$CLAUDE_DIR/skills/$skill"
    echo "Installed: $skill"
  fi
done
```

---

## Phase 3: Verification

Run VERIFY.md checks to confirm installation.
