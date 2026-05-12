---
name: obsidian
description: Full Obsidian vault integration — search, canvas generation, base management, bulk property ops, structure validation, and vault diagnostics.
argument-hint: "[search query]"
allowed-tools: Bash(uv run *)
user-invocable: true
---

# Obsidian Skill

Vault integration via ripgrep + Obsidian CLI + advanced scripts for canvas, bases, and bulk ops. Config from `~/.env`.


## Configuration (`~/.env`)

```env
OBSIDIAN_VAULT_PATH=/path/to/your/vault
OBSIDIAN_BIN=/path/to/obsidian/binary
```

## Tools — Core (client.py)

### obsidian_search
Search the vault using `ripgrep` (fast, exact keyword or regex).

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/client.py search "{query}"
```

### obsidian_backlinks
Find notes that link to or mention a specific file.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/client.py backlinks "{path}"
```

### obsidian_daily_note_path
Get the absolute path for today's daily note.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/client.py daily
```

### obsidian_active_file
Get the file currently open in the Obsidian UI.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/client.py active
```

### obsidian_open
Open a specific note in the Obsidian UI.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/client.py open "{path}"
```

### obsidian_health
Vault diagnostics — orphaned notes, broken wikilinks, duplicate titles.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/client.py health
```

## Tools — Canvas Generation (canvas_gen.py)

### canvas_knowledge_map
Generate a canvas grouping notes by category, color-coded by knowledge level.
Colors: red=reference, orange=familiar, yellow=understood, cyan=applied, green=mastered.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/canvas_gen.py knowledge-map --folder Areas --category "Kubernetes"
```

### canvas_project_map
Generate a canvas layout of all projects.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/canvas_gen.py project-map
```

### canvas_from_links
Generate a canvas from a note's wikilink neighborhood (radial layout).

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/canvas_gen.py from-links "path/to/note.md" --depth 2
```

## Tools — Bases Management (base_gen.py)

### base_from_template
Create a .base file from built-in templates. Templates: areas-knowledge, areas-by-category, areas-work, projects, learning, people, tasks, recent, journal.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/base_gen.py from-template areas-knowledge
```

### base_create
Create a custom .base file with parameters.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/base_gen.py create --name "Active Projects" --folder Resources/Bases --view table --filter 'note.status == "active"' --sort note.priority --sort-dir desc
```

### base_list
List all .base files in the vault with their views.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/base_gen.py list
```

### base_validate
Validate .base file syntax (YAML structure, view types).

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/base_gen.py validate
```

### base_templates
Show all available built-in templates.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/base_gen.py templates
```

## Tools — Vault Operations (vault_ops.py)

### vault_property_set
Bulk-set a frontmatter property on notes. Supports folder filtering and property-based filtering.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.py property-set knowledge familiar --folder Areas --filter "scope=work"
```

### vault_property_remove
Remove a property from all notes in a folder.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.py property-remove reviewed --folder Areas
```

### vault_property_stats
Show property usage statistics — coverage, top values.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.py property-stats --folder Areas
```

### vault_link_graph
Generate link graph in DOT (Graphviz) or JSON format.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.py link-graph --folder Areas --format dot
```

### vault_structure_check
Validate vault structure against conventions (loose files, missing properties, empty dirs, nested .obsidian). Expected top-level folders are configurable via `--expected` flag.

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.py structure-check
```

### vault_frontmatter_fix
Find and optionally fix frontmatter issues (unclosed, missing, malformed).

```bash
uv run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.py frontmatter-fix --folder Areas --dry-run
```

## References

- [Obsidian CLI](references/obsidian-cli.md) — CLI commands for vault control
- [Bases](references/bases.md) — .base syntax, filters, formulas, functions, views, CSS variables
- [Canvas](references/canvas.md) — JSON Canvas v1.0 spec, node/edge types, shortcuts, CSS variables
- [Properties](references/properties.md) — frontmatter types, YAML rules, CSS variables
- [Formatting](references/formatting.md) — Markdown extensions, wikilinks, embeds, callouts, Mermaid, LaTeX
- [CSS Foundations](references/css-foundations.md) — colors, typography, spacing, theming, snippets
