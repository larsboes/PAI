# Knowledge - Verification

> **For AI agents:** Complete this checklist after installation. File checks must pass before
> declaring the pack installed. MCP checks require Obsidian to be running with `semantic-vault-mcp`
> enabled.

---

## File Verification

```bash
CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/skills/Knowledge"

[ -d "$SKILL_DIR" ]                      && echo "OK directory exists"        || echo "MISSING directory"
[ -f "$SKILL_DIR/SKILL.md" ]             && echo "OK SKILL.md present"        || echo "MISSING SKILL.md"
[ -f "$SKILL_DIR/Tools/KnowledgeMcp.ts" ] && echo "OK KnowledgeMcp.ts present" || echo "MISSING KnowledgeMcp.ts"
```

```bash
# Optional fallback/tooling substructure
[ -f "$SKILL_DIR/Tools/KnowledgeGraph.ts" ] && echo "OK fallback KnowledgeGraph.ts present" || echo "INFO no fallback KnowledgeGraph.ts"
[ -d "$SKILL_DIR/Workflows" ]               && echo "OK Workflows/ present"                 || echo "INFO no Workflows/"
[ -d "$SKILL_DIR/References" ]              && echo "OK References/ present"                || echo "INFO no References/"
```

---

## Frontmatter Check

```bash
CLAUDE_DIR="$HOME/.claude"
head -1 "$CLAUDE_DIR/skills/Knowledge/SKILL.md" | grep -q "^---" && echo "OK frontmatter delimited" || echo "ERROR missing frontmatter"
grep -q "^name:" "$CLAUDE_DIR/skills/Knowledge/SKILL.md" && echo "OK has name" || echo "ERROR missing name"
grep -q "^description:" "$CLAUDE_DIR/skills/Knowledge/SKILL.md" && echo "OK has description" || echo "ERROR missing description"
grep -q "KnowledgeMcp.ts" "$CLAUDE_DIR/skills/Knowledge/SKILL.md" && echo "OK routes through MCP adapter" || echo "ERROR MCP adapter missing from skill"
```

---

## Environment Check

```bash
grep -E '^(OBSIDIAN_VAULT_PATH|VAULT_KNOWLEDGE|VAULT_KNOWLEDGE_FOLDERS|OBSIDIAN_MONO_PATH|OBSIDIAN_MCP_PORT|OBSIDIAN_MCP_API_KEY)=' ~/.env 2>/dev/null || true
```

At minimum, `OBSIDIAN_VAULT_PATH` should be available either in `~/.env` or
in `~/Developer/tmp/obsidian-mono/.env`. `VAULT_KNOWLEDGE` and `VAULT_KNOWLEDGE_FOLDERS`
are optional dynamic scope hints. `VAULT_KNOWLEDGE="*"` means whole vault; missing configured
folders are reported by `status` and omitted from MCP calls during restructures.

---

## MCP Smoke Tests

Run these from the installed skill directory, or replace `$SKILL_DIR` with the source `src/`
directory during development:

```bash
bun run "$SKILL_DIR/Tools/KnowledgeMcp.ts" index-status --raw
bun run "$SKILL_DIR/Tools/KnowledgeMcp.ts" status
bun run "$SKILL_DIR/Tools/KnowledgeMcp.ts" queue-status
```

`status` should print the resolved scope before index health, for example `Scope: Areas, Resources`
during a transition or `Scope: whole vault` when no folder scope is active.

Plugin safe-startup smoke from `obsidian-mono`:

```bash
node scripts/safe-startup-smoke.js
```

This checks only MCP `index_status lightweight=true` and `index_queue_status`.

Optional content test, only when note reads are acceptable:

```bash
bun run "$SKILL_DIR/Tools/KnowledgeMcp.ts" retrieve "Fluentbit Lua" --top 3
```

---

## Functional Test

After install, restart Claude Code (or open a new session) and trigger the skill via:

```text
/knowledge
/knowledge index-status
/knowledge queue-status
/knowledge retrieve Fluentbit Lua
/knowledge related <known title>
/knowledge contradictions
```

---

## Installation Checklist

```markdown
## Knowledge Installation Verification

- [ ] Skill directory exists at ~/.claude/skills/Knowledge/
- [ ] SKILL.md present with valid frontmatter
- [ ] KnowledgeMcp.ts present
- [ ] Frontmatter has name and description fields
- [ ] MCP adapter smoke test passes with Obsidian running
- [ ] Restarted Claude Code after install
- [ ] Skill triggers on its declared USE WHEN keywords
```
