# Uv — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/Uv -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/uv/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/Uv/src/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/Uv/src/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/Uv/src/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Scripts Check

```bash
[ -x ~/Developer/PAI/Packs/Uv/src/scripts/init-lib.sh ] && echo "OK init-lib.sh executable" || echo "ERROR init-lib.sh not executable"
[ -x ~/Developer/PAI/Packs/Uv/src/scripts/init-app.sh ] && echo "OK init-app.sh executable" || echo "ERROR init-app.sh not executable"
[ -x ~/Developer/PAI/Packs/Uv/src/scripts/init-script.sh ] && echo "OK init-script.sh executable" || echo "ERROR init-script.sh not executable"
```

## Reference Files Check

```bash
[ -f ~/Developer/PAI/Packs/Uv/src/references/workspaces.md ] && echo "OK workspaces.md" || echo "MISSING"
[ -f ~/Developer/PAI/Packs/Uv/src/references/migrations/from-poetry.md ] && echo "OK from-poetry.md" || echo "MISSING"
[ -f ~/Developer/PAI/Packs/Uv/src/references/migrations/from-pip.md ] && echo "OK from-pip.md" || echo "MISSING"
[ -f ~/Developer/PAI/Packs/Uv/src/references/migrations/from-pipenv.md ] && echo "OK from-pipenv.md" || echo "MISSING"
[ -f ~/Developer/PAI/Packs/Uv/src/references/ci-cd/github-actions.md ] && echo "OK github-actions.md" || echo "MISSING"
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] All scripts present and executable
- [ ] All reference/migration files present
- [ ] Pi config.yml references PAI/Packs directory
- [ ] Skill responds to its trigger phrases in a new session
