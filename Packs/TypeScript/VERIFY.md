# TypeScript — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/TypeScript -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/typescript/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/TypeScript/src/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/TypeScript/src/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/TypeScript/src/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Reference Files Check

```bash
[ -f ~/Developer/PAI/Packs/TypeScript/src/references/bun.md ] && echo "OK bun.md" || echo "MISSING bun.md"
[ -f ~/Developer/PAI/Packs/TypeScript/src/references/react.md ] && echo "OK react.md" || echo "MISSING react.md"
[ -f ~/Developer/PAI/Packs/TypeScript/src/references/monorepo.md ] && echo "OK monorepo.md" || echo "MISSING monorepo.md"
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] All reference files present (bun.md, react.md, monorepo.md)
- [ ] Pi config.yml references PAI/Packs directory
- [ ] Skill responds to its trigger phrases in a new session
