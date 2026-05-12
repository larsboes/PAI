# Mermaid — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/Mermaid -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/Mermaid/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/Mermaid/src/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/Mermaid/src/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/Mermaid/src/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Tools Check

```bash
for tool in export.sh extract-from-md.sh lint.sh validate-all.sh validate.sh; do
  [ -f ~/Developer/PAI/Packs/Mermaid/src/tools/$tool ] && echo "OK $tool" || echo "MISSING $tool"
done
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] Pi config.yml references PAI/Packs directory
- [ ] All 5 tools present in src/tools/
- [ ] Skill responds to its trigger phrases in a new session
