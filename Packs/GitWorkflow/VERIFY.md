# GitWorkflow — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/GitWorkflow -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/GitWorkflow/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/GitWorkflow/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/GitWorkflow/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/GitWorkflow/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Dependency Check

```bash
git --version && echo "OK Git available" || echo "MISSING Git"
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] Pi config.yml references PAI/Packs directory
- [ ] Git installed and accessible
- [ ] Skill responds to its trigger phrases in a new session
