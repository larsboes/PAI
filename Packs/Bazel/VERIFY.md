# Bazel — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/Bazel -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/Bazel/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/Bazel/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/Bazel/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/Bazel/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Dependency Check

```bash
bazelisk version 2>/dev/null || bazel version 2>/dev/null && echo "OK Bazel/Bazelisk available" || echo "MISSING Bazel/Bazelisk"
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] Pi config.yml references PAI/Packs directory
- [ ] Bazel/Bazelisk installed and accessible
- [ ] Skill responds to its trigger phrases in a new session
