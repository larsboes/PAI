# Brainstorm — Installation Guide

**For AI agents installing this pack.**

---

## Welcome

```
Installing Brainstorm — Iterative collaborative ideation — diverge, explore, converge across multiple rounds
```

---

## Phase 1: Verify PAI is configured

### Pi (primary)
```bash
grep -r "Brainstorm" ~/.pi/agent/config.yml 2>/dev/null && echo "OK config references PAI Packs dir" || echo "Check ~/.pi/agent/config.yml"

# config.yml should contain:
# skills:
#   customDirectories:
#     - ~/Developer/PAI/Packs
grep "customDirectories" ~/.pi/agent/config.yml && echo "OK" || echo "Add PAI/Packs to customDirectories in ~/.pi/agent/config.yml"
```

### Claude Code (alternative)
```bash
SKILL_DIR="$HOME/.claude/skills/Brainstorm"
[ -d "$SKILL_DIR" ] && echo "Already installed" || echo "Run Phase 4 (Claude Code install)"
```

---
## Phase 2: Install (Claude Code only)

Pi discovers skills automatically via `customDirectories` — no copy needed.

For Claude Code:
```bash
mkdir -p ~/.claude/skills
cp -r "$(pwd)/." ~/.claude/skills/Brainstorm/
echo "Installed to ~/.claude/skills/Brainstorm/"
```

---

## Phase 3: Verify

Run the checks in [VERIFY.md](VERIFY.md).
