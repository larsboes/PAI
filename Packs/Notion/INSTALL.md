# Notion — Installation Guide

**For AI agents installing this pack into a user's PAI infrastructure.**

---

## AI Agent Instructions

Use Claude Code's native tools (`AskUserQuestion`, `TodoWrite`, `Bash`, `Read`, `Write`) to walk the user through this wizard.

### Welcome Message

```
"I'm installing the Notion skill from the PAI community pack.

Production-ready Notion API integration — TypeScript CLI and library for reading
pages, querying databases, searching workspaces, creating/updating entries,
exporting to Markdown/CSV, and constructing rich block layouts.

Let me check your system and install."
```

---

## Phase 1: System Analysis

```bash
CLAUDE_DIR="$HOME/.claude"
SKILL_DIR="$CLAUDE_DIR/skills/notion"

if [ -d "$SKILL_DIR" ]; then
  echo "EXISTING notion skill found at $SKILL_DIR — will back up before install"
else
  echo "Clean install — no existing notion skill"
fi

# Check Node.js
node --version 2>/dev/null || echo "WARNING: Node.js not found — required for build"
```

---

## Phase 2: Confirm with User

Ask the user (use `AskUserQuestion`):

1. "Install `notion` into `~/.claude/skills/notion/`? (yes/no)"
2. If existing skill found: "Back up the existing `notion` to `~/.claude/skills/notion.backup-{timestamp}/` first? (yes/no — recommend yes)"

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

## Phase 5: Build

```bash
cd "$SKILL_DIR"
npm install
npm run build
echo "Build complete"
```

---

## Phase 6: Environment

The user needs a Notion API token:

```bash
# Check if token is already set
if [ -n "$NOTION_API_TOKEN" ]; then
  echo "OK: NOTION_API_TOKEN is set"
else
  echo "REQUIRED: Set NOTION_API_TOKEN"
  echo "  1. Go to https://www.notion.so/my-integrations"
  echo "  2. Create a new integration"
  echo "  3. Copy the Internal Integration Token"
  echo "  4. Add to shell config: echo 'export NOTION_API_TOKEN=secret_xxx' >> ~/.zshrc"
fi
```

---

## Phase 7: Verify

Run the file and functional checks in [VERIFY.md](VERIFY.md). Confirm to the user when all checks pass.
