# Tmux — Installation Guide

**For AI agents installing this pack.**

---

## Welcome

```
Installing Tmux — Remote control tmux sessions for interactive CLIs by sending keystrokes and scraping pane output
```

---

## Phase 1: Verify PAI is configured

### Pi (primary)
```bash
grep -r "Tmux" ~/.pi/agent/config.yml 2>/dev/null && echo "OK config references PAI Packs dir" || echo "Check ~/.pi/agent/config.yml"

# config.yml should contain:
# skills:
#   customDirectories:
#     - ~/Developer/PAI/Packs
grep "customDirectories" ~/.pi/agent/config.yml && echo "OK" || echo "Add PAI/Packs to customDirectories in ~/.pi/agent/config.yml"
```

### Claude Code (alternative)
```bash
SKILL_DIR="$HOME/.claude/skills/tmux"
[ -d "$SKILL_DIR" ] && echo "Already installed" || echo "Run Phase 2 (Claude Code install)"
```

---

## Phase 2: Install (Claude Code only)

Pi discovers skills automatically via `customDirectories` — no copy needed.

For Claude Code:
```bash
mkdir -p ~/.claude/skills
cp -r "$(pwd)/src/." ~/.claude/skills/tmux/
chmod +x ~/.claude/skills/tmux/scripts/*.sh
echo "Installed to ~/.claude/skills/tmux/"
```

---

## Phase 3: Verify

Run the checks in [VERIFY.md](VERIFY.md).
