---
name: obsidian
description: Integration with your local Obsidian vault — fast keyword search, backlinks, UI control, and vault health diagnostics.
argument-hint: "[search query]"
allowed-tools: Bash(uv run *)
user-invocable: true
---

# Obsidian Skill

Fast, reliable Obsidian vault integration via ripgrep + Obsidian CLI. Reads all config from `~/.env`.


## Configuration (`~/.env`)

```env
OBSIDIAN_VAULT_PATH=/path/to/your/vault
OBSIDIAN_BIN=/Applications/Obsidian.app/Contents/MacOS/Obsidian
```

## Quick Start

- **Keyword search:** `search "terms"` — fast ripgrep, regex supported
- **Find backlinks:** `backlinks "note name"` — what links to this note
- **Get daily note:** `daily` — path to today's daily note
- **See active file:** `active` — what's open in Obsidian right now
- **Open a note:** `open "path"` — open in Obsidian UI
- **Vault diagnostics:** `health` — orphaned notes, broken links, duplicates

## Tools

### obsidian_search
Search the vault using `ripgrep` (fast, exact keyword or regex).
Use for known terms, filenames, dates (e.g. "FluentBit", "2026-02-17", "GraphRAG").

- `query`: Search string (supports regex).

```bash
uv run ${CLAUDE_PLUGIN_ROOT}/scripts/client.py search "{query}"
```

### obsidian_backlinks
Find notes that link to or mention a specific file.
Essential for understanding a note's position in the knowledge graph.

- `path`: Filename or path to find backlinks for.

```bash
uv run ${CLAUDE_PLUGIN_ROOT}/scripts/client.py backlinks "{path}"
```

### obsidian_daily_note_path
Get the absolute path for today's daily note.
Use this to read/write the daily note with standard file tools.

```bash
uv run ${CLAUDE_PLUGIN_ROOT}/scripts/client.py daily
```

### obsidian_active_file
Get the file currently open in the Obsidian UI.

```bash
uv run ${CLAUDE_PLUGIN_ROOT}/scripts/client.py active
```

### obsidian_open
Open a specific note in the Obsidian UI.

- `path`: Path to the file to open.

```bash
uv run ${CLAUDE_PLUGIN_ROOT}/scripts/client.py open "{path}"
```

### obsidian_health
Vault diagnostics — orphaned notes, broken wikilinks, duplicate titles, file statistics.
Run weekly or after bulk imports.

```bash
uv run ${CLAUDE_PLUGIN_ROOT}/scripts/client.py health
```

## References

- [Obsidian CLI](references/obsidian-cli.md)
