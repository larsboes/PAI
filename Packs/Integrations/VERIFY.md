# Integrations Verification

> **FOR AI AGENTS:** Complete this checklist AFTER installation.

---

## File Verification

### Check all skills exist

```bash
CLAUDE_DIR="$HOME/.claude"

echo "=== Integrations Skills ==="
for skill in gmcli gccli gdcli github notion obsidian zotero; do
  [ -f "$CLAUDE_DIR/skills/$skill/SKILL.md" ] && echo "OK $skill" || echo "MISSING $skill"
done
```

**Expected:** All 9 skills present.

### Check obsidian subdirectories

```bash
CLAUDE_DIR="$HOME/.claude"

echo "=== Obsidian Structure ==="
[ -d "$CLAUDE_DIR/skills/obsidian/scripts" ] && echo "OK obsidian/scripts" || echo "MISSING obsidian/scripts"
[ -d "$CLAUDE_DIR/skills/obsidian/data" ] && echo "OK obsidian/data" || echo "MISSING obsidian/data"
[ -d "$CLAUDE_DIR/skills/obsidian/references" ] && echo "OK obsidian/references" || echo "MISSING obsidian/references"
[ -f "$CLAUDE_DIR/skills/obsidian/INTEGRATIONS.md" ] && echo "OK INTEGRATIONS.md" || echo "WARN INTEGRATIONS.md missing"
```

### Check script executability

```bash
CLAUDE_DIR="$HOME/.claude"

echo "=== Script Permissions ==="
for script in "$CLAUDE_DIR/skills/obsidian/scripts/"*.py; do
  [ -f "$script" ] && echo "OK $(basename "$script")" || echo "WARN no Python scripts found"
done
```
