# SkillsMeta Verification

> **FOR AI AGENTS:** Complete this checklist AFTER installation.

---

## File Verification

```bash
CLAUDE_DIR="$HOME/.claude"

echo "=== SkillsMeta Skills ==="
for skill in skill-forge skill-sync pi-extender; do
  [ -f "$CLAUDE_DIR/skills/$skill/SKILL.md" ] && echo "OK $skill" || echo "MISSING $skill"
done

echo ""
echo "=== Subdirectories ==="
[ -d "$CLAUDE_DIR/skills/skill-forge/references" ] && echo "OK skill-forge/references" || echo "WARN missing"
[ -d "$CLAUDE_DIR/skills/skill-sync/scripts" ] && echo "OK skill-sync/scripts" || echo "WARN missing"
[ -d "$CLAUDE_DIR/skills/skill-sync/adapters" ] && echo "OK skill-sync/adapters" || echo "WARN missing"
[ -d "$CLAUDE_DIR/skills/pi-extender/references" ] && echo "OK pi-extender/references" || echo "WARN missing"
```
