# Terminal Verification

> **FOR AI AGENTS:** Complete this checklist AFTER installation.

---

## File Verification

```bash
CLAUDE_DIR="$HOME/.claude"

echo "=== Terminal Skills ==="
for skill in tmux cmux; do
  [ -f "$CLAUDE_DIR/skills/$skill/SKILL.md" ] && echo "OK $skill" || echo "MISSING $skill"
done

echo ""
echo "=== Scripts ==="
[ -d "$CLAUDE_DIR/skills/tmux/scripts" ] && echo "OK tmux/scripts" || echo "WARN tmux/scripts missing"
```
