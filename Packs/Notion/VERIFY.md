# Notion — Verification

> **For AI agents:** Complete this checklist after installation. All file checks must pass before declaring the pack installed.

---

## File Verification

```bash
CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/skills/notion"

[ -d "$SKILL_DIR" ]                     && echo "OK directory exists"           || echo "MISSING directory"
[ -f "$SKILL_DIR/SKILL.md" ]            && echo "OK SKILL.md present"           || echo "MISSING SKILL.md"
[ -f "$SKILL_DIR/package.json" ]        && echo "OK package.json present"       || echo "MISSING package.json"
[ -f "$SKILL_DIR/tsconfig.json" ]       && echo "OK tsconfig.json present"      || echo "MISSING tsconfig.json"
[ -f "$SKILL_DIR/lib/notion-client.ts" ] && echo "OK notion-client.ts present"  || echo "MISSING lib/notion-client.ts"
[ -f "$SKILL_DIR/lib/notion-md.ts" ]    && echo "OK notion-md.ts present"       || echo "MISSING lib/notion-md.ts"
[ -f "$SKILL_DIR/scripts/notion.ts" ]   && echo "OK notion.ts present"          || echo "MISSING scripts/notion.ts"
[ -f "$SKILL_DIR/scripts/notion.sh" ]   && echo "OK notion.sh present"          || echo "MISSING scripts/notion.sh"
```

---

## Build Verification

```bash
CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/skills/notion"

[ -d "$SKILL_DIR/node_modules" ]        && echo "OK node_modules present"       || echo "RUN: cd $SKILL_DIR && npm install"
[ -d "$SKILL_DIR/dist" ]                && echo "OK dist/ built"                || echo "RUN: cd $SKILL_DIR && npm run build"
[ -f "$SKILL_DIR/dist/scripts/notion.js" ] && echo "OK CLI compiled"            || echo "ERROR CLI not compiled"
```

---

## Frontmatter Check

```bash
CLAUDE_DIR="$HOME/.claude"
head -1 "$CLAUDE_DIR/skills/notion/SKILL.md" | grep -q "^---" && echo "OK frontmatter delimited" || echo "ERROR missing frontmatter"
grep -q "^name:" "$CLAUDE_DIR/skills/notion/SKILL.md" && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" "$CLAUDE_DIR/skills/notion/SKILL.md" && echo "OK has description" || echo "ERROR missing description"
```

---

## Functional Test

```bash
CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/skills/notion"

# Verify CLI responds to help (no token needed)
node "$SKILL_DIR/dist/scripts/notion.js" help 2>/dev/null && echo "OK CLI responds" || echo "ERROR CLI broken"
```

If `NOTION_API_TOKEN` is set, test a live call:

```bash
node "$SKILL_DIR/dist/scripts/notion.js" search "test" 2>/dev/null && echo "OK API connection works" || echo "INFO API test skipped or failed (check token)"
```

---

## Installation Checklist

```markdown
## Notion Installation Verification

- [ ] Skill directory exists at ~/.claude/skills/notion/
- [ ] SKILL.md present with valid frontmatter
- [ ] package.json and tsconfig.json present
- [ ] npm install completed (node_modules exists)
- [ ] npm run build completed (dist/ exists)
- [ ] NOTION_API_TOKEN configured in environment
- [ ] CLI responds to `notion help`
- [ ] Restarted Claude Code after install
- [ ] Skill triggers on "notion" / "query database" / "read page" keywords
```
