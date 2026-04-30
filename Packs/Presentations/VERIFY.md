# Presentations Verification

> **FOR AI AGENTS:** Complete this checklist AFTER installation.

---

## File Verification

```bash
CLAUDE_DIR="$HOME/.claude"

echo "=== Presentations Skill ==="
[ -f "$CLAUDE_DIR/skills/revealjs/SKILL.md" ] && echo "OK revealjs" || echo "MISSING revealjs"

echo ""
echo "=== Scripts ==="
[ -f "$CLAUDE_DIR/skills/revealjs/scripts/create-presentation.js" ] && echo "OK create-presentation.js" || echo "MISSING create-presentation.js"
[ -f "$CLAUDE_DIR/skills/revealjs/scripts/check-overflow.js" ] && echo "OK check-overflow.js" || echo "MISSING check-overflow.js"
[ -f "$CLAUDE_DIR/skills/revealjs/scripts/check-charts.js" ] && echo "OK check-charts.js" || echo "MISSING check-charts.js"
[ -f "$CLAUDE_DIR/skills/revealjs/scripts/edit-html.js" ] && echo "OK edit-html.js" || echo "MISSING edit-html.js"

echo ""
echo "=== References ==="
[ -f "$CLAUDE_DIR/skills/revealjs/references/base-styles.css" ] && echo "OK base-styles.css" || echo "MISSING base-styles.css"
[ -f "$CLAUDE_DIR/skills/revealjs/references/advanced-features.md" ] && echo "OK advanced-features.md" || echo "MISSING advanced-features.md"
[ -f "$CLAUDE_DIR/skills/revealjs/references/charts.md" ] && echo "OK charts.md" || echo "MISSING charts.md"

echo ""
echo "=== Dependencies ==="
[ -d "$CLAUDE_DIR/skills/revealjs/node_modules" ] && echo "OK node_modules installed" || echo "WARN node_modules missing — run: npm install --prefix $CLAUDE_DIR/skills/revealjs"
```
