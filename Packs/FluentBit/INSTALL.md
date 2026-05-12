# FluentBit — Installation Guide

**For AI agents installing this pack.**

---

## Welcome

```
Installing FluentBit — FluentBit Lua filter development, testing, CI patterns
```

---

## Phase 1: Verify PAI is configured

### Pi (primary)
```bash
grep -r "FluentBit" ~/.pi/agent/config.yml 2>/dev/null && echo "OK config references PAI Packs dir" || echo "Check ~/.pi/agent/config.yml"

# config.yml should contain:
# skills:
#   customDirectories:
#     - ~/Developer/PAI/Packs
grep "customDirectories" ~/.pi/agent/config.yml && echo "OK" || echo "Add PAI/Packs to customDirectories in ~/.pi/agent/config.yml"
```

### Claude Code (alternative)
```bash
SKILL_DIR="$HOME/.claude/skills/FluentBit"
[ -d "$SKILL_DIR" ] && echo "Already installed" || echo "Run Phase 4 (Claude Code install)"
```

---
## Phase 2: Check Dependencies

```bash
fluent-bit --version && echo "OK FluentBit available" || echo "MISSING FluentBit — install from: https://docs.fluentbit.io/manual/installation/getting-started-with-fluent-bit"
```

---

## Phase 3: Install (Claude Code only)

Pi discovers skills automatically via `customDirectories` — no copy needed.

For Claude Code:
```bash
mkdir -p ~/.claude/skills
cp -r "$(pwd)/." ~/.claude/skills/FluentBit/
echo "Installed to ~/.claude/skills/FluentBit/"
```

---

## Phase 4: Verify

Run the checks in [VERIFY.md](VERIFY.md).
