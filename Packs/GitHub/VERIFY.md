# GitHub — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/GitHub -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/GitHub/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/GitHub/src/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/GitHub/src/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/GitHub/src/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Scripts Check

```bash
for script in ci-logs.sh ci-status.sh pr-create.sh pr-review.sh release.sh; do
  [ -f ~/Developer/PAI/Packs/GitHub/src/scripts/$script ] && echo "OK $script" || echo "MISSING $script"
done
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] Pi config.yml references PAI/Packs directory
- [ ] All 5 scripts present in src/scripts/
- [ ] Skill responds to its trigger phrases in a new session
