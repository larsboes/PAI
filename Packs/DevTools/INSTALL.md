# DevTools v1.0.0 - Installation Guide

**This guide is designed for AI agents installing this pack into a user's infrastructure.**

---

## AI Agent Instructions

### Welcome Message

```
"I'm installing DevTools v1.0.0 — developer productivity skills for Claude Code.

This pack adds 6 skills: debug, dev-workflow, design, context7, vscode, security-audit.

Let me analyze your system and guide you through installation."
```

---

## Phase 1: System Analysis

```bash
CLAUDE_DIR="$HOME/.claude"
echo "=== System Check ==="
[ -d "$CLAUDE_DIR" ] && echo "OK Claude Code directory" || echo "MISSING Claude Code directory"
[ -d "$CLAUDE_DIR/skills" ] && echo "OK skills directory" || echo "MISSING skills directory"
command -v c7 &>/dev/null && echo "OK c7 CLI (context7)" || echo "WARN c7 CLI not found — context7 skill needs it"
command -v uv &>/dev/null && echo "OK uv available" || echo "INFO uv not found (uv skill is in Coding pack)"
```

---

## Phase 2: Installation

```bash
PACK_DIR="$(dirname "$0")"
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/skills"

for skill in debug dev-workflow design context7 vscode security-audit; do
  if [ -d "$PACK_DIR/src/$skill" ]; then
    cp -r "$PACK_DIR/src/$skill" "$CLAUDE_DIR/skills/$skill"
    echo "Installed: $skill"
  fi
done
```

---

## Phase 3: Verification

Run VERIFY.md checks to confirm installation.
