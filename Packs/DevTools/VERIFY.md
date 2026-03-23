# DevTools Verification

> **FOR AI AGENTS:** Complete this checklist AFTER installation.

---

## File Verification

```bash
CLAUDE_DIR="$HOME/.claude"

echo "=== DevTools Skills ==="
for skill in debug dev-workflow design context7 vscode security-audit; do
  [ -f "$CLAUDE_DIR/skills/$skill/SKILL.md" ] && echo "OK $skill" || echo "MISSING $skill"
done

echo ""
echo "=== Subdirectories ==="
for skill in debug design dev-workflow pdf pi-extender skill-forge; do
  [ -d "$CLAUDE_DIR/skills/$skill/references" ] && echo "OK $skill/references"
done
[ -d "$CLAUDE_DIR/skills/context7/scripts" ] && echo "OK context7/scripts" || echo "WARN context7/scripts missing"
[ -d "$CLAUDE_DIR/skills/security-audit/scripts" ] && echo "OK security-audit/scripts" || echo "WARN security-audit/scripts missing"
```
