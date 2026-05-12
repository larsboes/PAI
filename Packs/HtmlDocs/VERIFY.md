# HtmlDocs — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/HtmlDocs -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/HtmlDocs/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/HtmlDocs/src/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/HtmlDocs/src/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/HtmlDocs/src/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Content Check

```bash
[ -f ~/Developer/PAI/Packs/HtmlDocs/src/references/content-patterns.md ] && echo "OK content-patterns.md" || echo "MISSING content-patterns.md"
[ -f ~/Developer/PAI/Packs/HtmlDocs/src/references/templates/shared.css ] && echo "OK shared.css" || echo "MISSING shared.css"
[ -f ~/Developer/PAI/Packs/HtmlDocs/src/references/templates/shared.js ] && echo "OK shared.js" || echo "MISSING shared.js"
[ -f ~/Developer/PAI/Packs/HtmlDocs/src/scripts/scaffold.sh ] && echo "OK scaffold.sh" || echo "MISSING scaffold.sh"
[ -f ~/Developer/PAI/Packs/HtmlDocs/src/scripts/validate.sh ] && echo "OK validate.sh" || echo "MISSING validate.sh"
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] Pi config.yml references PAI/Packs directory
- [ ] references/ directory with content-patterns.md and templates/
- [ ] scripts/ directory with scaffold.sh and validate.sh
- [ ] Skill responds to its trigger phrases in a new session
