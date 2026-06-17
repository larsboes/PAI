# Obsidian — Verification

---

## File Check

```bash
# Pi — skill discovered via config
find ~/Developer/PAI/Packs/Obsidian -name "SKILL.md" && echo "OK SKILL.md present" || echo "MISSING"

# Claude Code install (if applicable)
[ -f ~/.claude/skills/obsidian/SKILL.md ] && echo "OK CC install present" || echo "INFO not installed to CC"
```

## Frontmatter Check

```bash
head -1 ~/Developer/PAI/Packs/Obsidian/src/SKILL.md | grep -q "^---" && echo "OK frontmatter" || echo "ERROR missing frontmatter"
grep -q "^name:" ~/Developer/PAI/Packs/Obsidian/src/SKILL.md && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" ~/Developer/PAI/Packs/Obsidian/src/SKILL.md && echo "OK has description" || echo "ERROR missing description"
```

## Environment Check

```bash
# Check vault path is configured
grep -q "OBSIDIAN_VAULT_PATH" ~/.env && echo "OK vault path in ~/.env" || echo "ERROR: OBSIDIAN_VAULT_PATH not set"

# Check vault exists
VAULT=$(grep "OBSIDIAN_VAULT_PATH" ~/.env | cut -d= -f2)
[ -d "$VAULT" ] && echo "OK vault exists at $VAULT" || echo "ERROR vault not found at $VAULT"

# Check rg is available
which rg >/dev/null 2>&1 && echo "OK ripgrep available" || echo "ERROR ripgrep not installed"

# Check bun is available (TypeScript runtime)
which bun >/dev/null 2>&1 && echo "OK bun available" || echo "ERROR bun not installed"

# Check script deps are installed (yaml)
[ -d ~/Developer/PAI/Packs/Obsidian/src/scripts/node_modules ] && echo "OK deps installed" || echo "ERROR run: (cd src/scripts && bun install)"
```

## Functional Check

```bash
# Quick search test
bun run ~/Developer/PAI/Packs/Obsidian/src/scripts/client.ts search "test" 2>&1 | head -3 && echo "OK search works" || echo "ERROR search failed"
```

## Checklist

- [ ] SKILL.md present with valid frontmatter
- [ ] OBSIDIAN_VAULT_PATH set in ~/.env and vault exists
- [ ] ripgrep installed
- [ ] bun installed
- [ ] script deps installed (`cd src/scripts && bun install`)
- [ ] Pi config.yml references PAI/Packs directory
- [ ] Skill responds to its trigger phrases in a new session
