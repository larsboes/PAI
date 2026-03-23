# SkillsMeta v1.0.0 - Installation Guide

**This guide is designed for AI agents installing this pack into a user's infrastructure.**

---

## AI Agent Instructions

### Welcome Message

```
"I'm installing SkillsMeta v1.0.0 — skill lifecycle management for Claude Code.

This pack adds 3 skills: skill-forge, skill-sync, pi-extender.

Let me analyze your system and guide you through installation."
```

---

## Phase 1: System Analysis

```bash
CLAUDE_DIR="$HOME/.claude"
echo "=== System Check ==="
[ -d "$CLAUDE_DIR" ] && echo "OK Claude Code directory" || echo "MISSING Claude Code directory"
[ -f "$HOME/.pai/sources.conf" ] && echo "OK sources.conf exists" || echo "WARN sources.conf missing — skill-sync needs it"
```

---

## Phase 2: Installation

```bash
PACK_DIR="$(dirname "$0")"
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/skills"

for skill in skill-forge skill-sync pi-extender; do
  if [ -d "$PACK_DIR/src/$skill" ]; then
    cp -r "$PACK_DIR/src/$skill" "$CLAUDE_DIR/skills/$skill"
    echo "Installed: $skill"
  fi
done
```

---

## Phase 3: Verification

Run VERIFY.md checks to confirm installation.
