# Knowledge - Installation Guide

**For AI agents installing this pack into a user's PAI infrastructure.**

---

## AI Agent Instructions

Use Claude Code's native tools (`AskUserQuestion`, `TodoWrite`, `Bash`, `Read`, `Write`) to walk
the user through this wizard.

### Welcome Message

```text
"I'm installing the Knowledge skill from the PAI v5.0.0 release, adapted for the Obsidian semantic-vault-mcp backend.

The skill keeps /knowledge as the interface. Graph, search, retrieve, contradictions, category lookup, and index status are served by the MCP/RAG plugin. Note creation and gardening still follow the vault AGENTS conventions.

Let me check your system and install."
```

---

## Phase 1: System Analysis

```bash
CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/skills/Knowledge"

if [ -d "$SKILL_DIR" ]; then
  echo "EXISTING Knowledge skill found at $SKILL_DIR - will back up before install"
else
  echo "Clean install - no existing Knowledge skill"
fi
```

Confirm these runtime prerequisites are configured:

```bash
grep -E '^(OBSIDIAN_VAULT_PATH|VAULT_KNOWLEDGE|VAULT_KNOWLEDGE_FOLDERS|OBSIDIAN_MONO_PATH|OBSIDIAN_MCP_PORT|OBSIDIAN_MCP_API_KEY)=' ~/.env 2>/dev/null || true
```

`OBSIDIAN_MCP_API_KEY` is optional when `OBSIDIAN_VAULT_PATH` or `OBSIDIAN_PLUGINS_PATH` points
at an enabled `semantic-vault-mcp` plugin settings file.

---

## Phase 2: Confirm with User

Ask the user (use `AskUserQuestion`):

1. "Install `Knowledge` into `~/.claude/skills/Knowledge/`? (yes/no)"
2. If existing skill found: "Back up the existing `Knowledge` to `~/.claude/skills/Knowledge.backup-{timestamp}/` first? (yes/no - recommend yes)"

---

## Phase 3: Backup (only if existing)

```bash
if [ -d "$SKILL_DIR" ]; then
  BACKUP="$SKILL_DIR.backup-$(date +%Y%m%d-%H%M%S)"
  mv "$SKILL_DIR" "$BACKUP"
  echo "Backed up to $BACKUP"
fi
```

---

## Phase 4: Install

```bash
mkdir -p "$CLAUDE_DIR/skills"
cp -R src/ "$SKILL_DIR/"
echo "Installed to $SKILL_DIR"
```

---

## Phase 5: Verify

Run the file and functional checks in [VERIFY.md](VERIFY.md). Confirm to the user when all checks
pass. Functional MCP checks require Obsidian to be running with `semantic-vault-mcp` enabled.
