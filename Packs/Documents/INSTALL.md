# Documents — Installation Guide

**For AI agents installing this pack into a user's PAI infrastructure.**

---

## AI Agent Instructions

### Phase 1: System Analysis

```bash
CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/skills/Documents"

if [ -d "$SKILL_DIR" ]; then
  echo "EXISTING Documents skill found at $SKILL_DIR — will back up before install"
else
  echo "Clean install — no existing Documents skill"
fi
```

### Phase 2: Install

```bash
mkdir -p "$CLAUDE_DIR/skills"
cp -R src/ "$SKILL_DIR/"
echo "Installed to $SKILL_DIR"
```

### Phase 3: Verify

Run the checks in [VERIFY.md](VERIFY.md).
