# Coding Verification

> **FOR AI AGENTS:** Complete this checklist AFTER installation.

---

## File Verification

```bash
CLAUDE_DIR="$HOME/.claude"

echo "=== Coding Skills ==="
for skill in architecture data-engineer typescript swift uv fluentbit; do
  [ -f "$CLAUDE_DIR/skills/$skill/SKILL.md" ] && echo "OK $skill" || echo "MISSING $skill"
done

echo ""
echo "=== Subdirectories ==="
[ -d "$CLAUDE_DIR/skills/architecture/references" ] && echo "OK architecture/references" || echo "WARN architecture/references missing"
[ -d "$CLAUDE_DIR/skills/data-engineer/references" ] && echo "OK data-engineer/references" || echo "WARN data-engineer/references missing"
[ -d "$CLAUDE_DIR/skills/typescript/references" ] && echo "OK typescript/references" || echo "WARN typescript/references missing"
[ -d "$CLAUDE_DIR/skills/swift/scripts" ] && echo "OK swift/scripts" || echo "WARN swift/scripts missing"
[ -d "$CLAUDE_DIR/skills/uv/scripts" ] && echo "OK uv/scripts" || echo "WARN uv/scripts missing"
[ -d "$CLAUDE_DIR/skills/fluentbit/references" ] && echo "OK fluentbit/references" || echo "WARN fluentbit/references missing"
```
