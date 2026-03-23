# Terminal v1.0.0 - Installation Guide

**This guide is designed for AI agents installing this pack into a user's infrastructure.**

---

## AI Agent Instructions

### Welcome Message

```
"I'm installing Terminal v1.0.0 — terminal multiplexer control for Claude Code.

This pack adds 2 skills: tmux, cmux.

Let me analyze your system and guide you through installation."
```

---

## Phase 1: System Analysis

```bash
echo "=== System Check ==="
command -v tmux &>/dev/null && echo "OK tmux available" || echo "WARN tmux not found"
command -v cmux &>/dev/null && echo "OK cmux available" || echo "WARN cmux not found"
```

---

## Phase 2: Installation

```bash
PACK_DIR="$(dirname "$0")"
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/skills"

for skill in tmux cmux; do
  if [ -d "$PACK_DIR/src/$skill" ]; then
    cp -r "$PACK_DIR/src/$skill" "$CLAUDE_DIR/skills/$skill"
    echo "Installed: $skill"
  fi
done
```

---

## Phase 3: Verification

Run VERIFY.md checks to confirm installation.
