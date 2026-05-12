# Documents — Verification

## File Verification

```bash
CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/skills/Documents"

[ -d "$SKILL_DIR" ]            && echo "OK directory exists"        || echo "MISSING directory"
[ -f "$SKILL_DIR/SKILL.md" ]   && echo "OK SKILL.md present"        || echo "MISSING SKILL.md"
```

## Frontmatter Check

```bash
head -1 "$CLAUDE_DIR/skills/Documents/SKILL.md" | grep -q "^---" && echo "OK frontmatter delimited" || echo "ERROR missing frontmatter"
grep -q "^name:" "$CLAUDE_DIR/skills/Documents/SKILL.md" && echo "OK has name" || echo "ERROR missing name"
```
