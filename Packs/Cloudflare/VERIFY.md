# Cloudflare — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/Cloudflare -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/Cloudflare/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/Cloudflare/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/Cloudflare/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/Cloudflare/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Dependency Check

```bash
wrangler --version && echo "OK Wrangler CLI available" || echo "MISSING Wrangler CLI"
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] Pi config.yml references PAI/Packs directory
- [ ] Wrangler CLI installed and accessible
- [ ] Skill responds to its trigger phrases in a new session
