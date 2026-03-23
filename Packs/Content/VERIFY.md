# Content Verification

> **FOR AI AGENTS:** Complete this checklist AFTER installation.

---

## File Verification

```bash
CLAUDE_DIR="$HOME/.claude"

echo "=== Content Skills ==="
for skill in webfetch html-docs transcribe mermaid; do
  [ -f "$CLAUDE_DIR/skills/$skill/SKILL.md" ] && echo "OK $skill" || echo "MISSING $skill"
done

echo ""
echo "=== Supporting Files ==="
[ -f "$CLAUDE_DIR/skills/webfetch/webfetch.js" ] && echo "OK webfetch.js" || echo "WARN webfetch.js missing"
[ -f "$CLAUDE_DIR/skills/transcribe/transcribe.mjs" ] && echo "OK transcribe.mjs" || echo "WARN transcribe.mjs missing"
[ -d "$CLAUDE_DIR/skills/mermaid/tools" ] && echo "OK mermaid/tools" || echo "WARN mermaid/tools missing"
[ -d "$CLAUDE_DIR/skills/html-docs/scripts" ] && echo "OK html-docs/scripts" || echo "WARN html-docs/scripts missing"
```
