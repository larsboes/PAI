# Mermaid — Installation Guide

**For AI agents installing this pack.**

---

## Welcome

```
Installing Mermaid — Create, validate, and export Mermaid diagrams. Extract from Markdown, batch validate, export to images, and lint for best practices.
```

---

## Phase 1: Verify PAI is configured

### Pi (primary)
```bash
grep -r "Mermaid" ~/.pi/agent/config.yml 2>/dev/null && echo "OK config references PAI Packs dir" || echo "Check ~/.pi/agent/config.yml"

# config.yml should contain:
# skills:
#   customDirectories:
#     - ~/Developer/PAI/Packs
grep "customDirectories" ~/.pi/agent/config.yml && echo "OK" || echo "Add PAI/Packs to customDirectories in ~/.pi/agent/config.yml"
```

### Claude Code (alternative)
```bash
SKILL_DIR="$HOME/.claude/skills/Mermaid"
[ -d "$SKILL_DIR" ] && echo "Already installed" || echo "Run Phase 2 (Claude Code install)"
```

---
## Phase 2: Install (Claude Code only)

Pi discovers skills automatically via `customDirectories` — no copy needed.

For Claude Code:
```bash
mkdir -p ~/.claude/skills
cp -r "$(pwd)/src/." ~/.claude/skills/Mermaid/
echo "Installed to ~/.claude/skills/Mermaid/"
```

---

## Phase 3: Verify

Run the checks in [VERIFY.md](VERIFY.md).
