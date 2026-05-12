# Tmux — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/Tmux -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/tmux/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/Tmux/src/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/Tmux/src/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/Tmux/src/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Scripts Check

```bash
[ -x ~/Developer/PAI/Packs/Tmux/src/scripts/python-session.sh ] && echo "OK python-session.sh" || echo "ERROR not executable"
[ -x ~/Developer/PAI/Packs/Tmux/src/scripts/gdb-session.sh ] && echo "OK gdb-session.sh" || echo "ERROR not executable"
[ -x ~/Developer/PAI/Packs/Tmux/src/scripts/node-session.sh ] && echo "OK node-session.sh" || echo "ERROR not executable"
[ -x ~/Developer/PAI/Packs/Tmux/src/scripts/save-session.sh ] && echo "OK save-session.sh" || echo "ERROR not executable"
[ -x ~/Developer/PAI/Packs/Tmux/src/scripts/restore-session.sh ] && echo "OK restore-session.sh" || echo "ERROR not executable"
[ -x ~/Developer/PAI/Packs/Tmux/src/scripts/find-sessions.sh ] && echo "OK find-sessions.sh" || echo "ERROR not executable"
[ -x ~/Developer/PAI/Packs/Tmux/src/scripts/wait-for-text.sh ] && echo "OK wait-for-text.sh" || echo "ERROR not executable"
[ -x ~/Developer/PAI/Packs/Tmux/src/scripts/capture-json.sh ] && echo "OK capture-json.sh" || echo "ERROR not executable"
```

## Dependency Check

```bash
command -v tmux >/dev/null && echo "OK tmux installed" || echo "ERROR tmux not found"
command -v jq >/dev/null && echo "OK jq installed" || echo "WARNING jq not found (needed for save/restore/capture-json)"
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] All scripts present and executable
- [ ] tmux binary available in PATH
- [ ] Pi config.yml references PAI/Packs directory
- [ ] Skill responds to its trigger phrases in a new session
