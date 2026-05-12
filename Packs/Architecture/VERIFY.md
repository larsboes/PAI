# Architecture — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/Architecture -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/architecture/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/Architecture/src/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/Architecture/src/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/Architecture/src/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Reference Files Check

```bash
for f in aggregate-design api-design application-services ddd-strategic ddd-tactical persistence-mapping testing; do
  [ -f ~/Developer/PAI/Packs/Architecture/src/references/$f.md ] && echo "OK $f.md" || echo "MISSING $f.md"
done

for f in check design-module design-workflow fix review; do
  [ -f ~/Developer/PAI/Packs/Architecture/src/references/modes/$f.md ] && echo "OK modes/$f.md" || echo "MISSING modes/$f.md"
done
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] All reference files present (7 references + 5 modes)
- [ ] Pi config.yml references PAI/Packs directory
- [ ] Skill responds to its trigger phrases in a new session
