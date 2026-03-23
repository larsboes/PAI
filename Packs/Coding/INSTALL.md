# Coding v1.0.0 - Installation Guide

**This guide is designed for AI agents installing this pack into a user's infrastructure.**

---

## AI Agent Instructions

### Welcome Message

```
"I'm installing Coding v1.0.0 — language-specific and architecture skills for Claude Code.

This pack adds 6 skills: architecture, data-engineer, typescript, swift, uv, fluentbit.

Let me analyze your system and guide you through installation."
```

---

## Phase 1: System Analysis

```bash
CLAUDE_DIR="$HOME/.claude"
echo "=== System Check ==="
[ -d "$CLAUDE_DIR" ] && echo "OK Claude Code directory" || echo "MISSING Claude Code directory"
[ -d "$CLAUDE_DIR/skills" ] && echo "OK skills directory" || echo "MISSING skills directory"
command -v uv &>/dev/null && echo "OK uv available" || echo "WARN uv not found — uv skill needs it"
command -v swift &>/dev/null && echo "OK swift available" || echo "WARN swift not found — swift skill needs it"
```

---

## Phase 2: Installation

```bash
PACK_DIR="$(dirname "$0")"
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/skills"

for skill in architecture data-engineer typescript swift uv fluentbit; do
  if [ -d "$PACK_DIR/src/$skill" ]; then
    cp -r "$PACK_DIR/src/$skill" "$CLAUDE_DIR/skills/$skill"
    echo "Installed: $skill"
  fi
done
```

---

## Phase 3: Verification

Run VERIFY.md checks to confirm installation.
