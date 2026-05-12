# Swift — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/Swift -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/Swift/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/Swift/src/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/Swift/src/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/Swift/src/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Content Check

```bash
for ref in dependency-injection.md macos-windowing.md plugin-architecture.md; do
  [ -f ~/Developer/PAI/Packs/Swift/src/references/$ref ] && echo "OK $ref" || echo "MISSING $ref"
done
[ -f ~/Developer/PAI/Packs/Swift/src/scripts/lsp.ts ] && echo "OK lsp.ts" || echo "MISSING lsp.ts"
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] Pi config.yml references PAI/Packs directory
- [ ] references/ directory with 3 reference files
- [ ] scripts/ directory with lsp.ts
- [ ] Skill responds to its trigger phrases in a new session
