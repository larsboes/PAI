---
name: Obsidian
description: "Full Obsidian vault integration — search notes, generate canvas files, manage bases, bulk property operations, structure validation, and vault diagnostics. USE WHEN search obsidian, find note, obsidian vault, canvas, create canvas, obsidian search, note properties, bulk update frontmatter, validate vault structure, obsidian diagnostics, find notes by tag, search knowledge base."
argument-hint: "[search query]"
allowed-tools: Bash(bun run *)
user-invocable: true
---

# Obsidian Skill

Vault integration via ripgrep + Obsidian CLI + advanced scripts for canvas, bases, and bulk ops. Config from `~/.env`.

> **Runtime:** the scripts are bun/TypeScript. First run in `scripts/` needs `bun install` once (pulls the `yaml` dep); after that every command runs directly via `bun run`.

## Configuration (`~/.env`)

```env
OBSIDIAN_VAULT_PATH=/path/to/your/vault
OBSIDIAN_BIN=/path/to/obsidian/binary
```

## Tools — Core (client.ts)

### obsidian_search
Search the vault using `ripgrep` (fast, exact keyword or regex).

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/client.ts search "{query}"
```

### obsidian_backlinks
Find notes that link to or mention a specific file.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/client.ts backlinks "{path}"
```

### obsidian_daily_note_path
Get the absolute path for today's daily note.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/client.ts daily
```

### obsidian_active_file
Get the file currently open in the Obsidian UI.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/client.ts active
```

### obsidian_open
Open a specific note in the Obsidian UI.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/client.ts open "{path}"
```

### obsidian_health
Vault diagnostics — orphaned notes, broken wikilinks, duplicate titles.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/client.ts health
```

## Tools — Canvas Generation (canvas_gen.ts)

### canvas_knowledge_map
Generate a canvas grouping notes by category, color-coded by knowledge level.
Colors: red=reference, orange=familiar, yellow=understood, cyan=applied, green=mastered.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/canvas_gen.ts knowledge-map --folder Knowledge --category "Kubernetes"
```

### canvas_project_map
Generate a canvas layout of all projects.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/canvas_gen.ts project-map
```

### canvas_from_links
Generate a canvas from a note's wikilink neighborhood (radial layout).

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/canvas_gen.ts from-links "path/to/note.md" --depth 2
```

## Tools — Bases Management (base_gen.ts)

### base_from_template
Create a .base file from built-in templates. Templates: knowledge, knowledge-by-category, knowledge-work, projects, learning, people, tasks, recent, journal.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/base_gen.ts from-template knowledge
```

### base_create
Create a custom .base file with parameters.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/base_gen.ts create --name "Active Projects" --folder Resources/Bases --view table --filter 'note.status == "active"' --sort note.priority --sort-dir desc
```

### base_list
List all .base files in the vault with their views.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/base_gen.ts list
```

### base_validate
Validate .base file syntax (YAML structure, view types).

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/base_gen.ts validate
```

### base_templates
Show all available built-in templates.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/base_gen.ts templates
```

## Tools — Vault Operations (vault_ops.ts)

### vault_property_set
Bulk-set a frontmatter property on notes. Supports folder filtering and property-based filtering.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.ts property-set knowledge familiar --folder Knowledge --filter "scope=work"
```

### vault_property_remove
Remove a property from all notes in a folder.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.ts property-remove reviewed --folder Knowledge
```

### vault_property_stats
Show property usage statistics — coverage, top values.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.ts property-stats --folder Knowledge
```

### vault_link_graph
Generate link graph in DOT (Graphviz) or JSON format.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.ts link-graph --folder Knowledge --format dot
```

### vault_structure_check
Validate vault structure against conventions (loose files, missing properties, empty dirs, nested .obsidian). Expected top-level folders are configurable via `--expected` flag.

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.ts structure-check
```

### vault_frontmatter_fix
Find and optionally fix frontmatter issues (unclosed, missing, malformed).

```bash
bun run ${CLAUDE_SKILL_DIR}/scripts/vault_ops.ts frontmatter-fix --folder Knowledge --dry-run
```

## References

- [Obsidian MCP Integration](references/mcp.md) — Architecture, local daemon setup, secure client config, and iOS mTLS setup
- [Obsidian CLI](references/obsidian-cli.md) — CLI commands for vault control
- [Bases](references/bases.md) — .base syntax, filters, formulas, functions, views, CSS variables, **gotchas & patterns**
- [Canvas](references/canvas.md) — JSON Canvas v1.0 spec, node/edge types, shortcuts, CSS variables
- [Properties](references/properties.md) — frontmatter types, YAML rules, CSS variables
- [Formatting](references/formatting.md) — Markdown extensions, wikilinks, embeds, callouts, Mermaid, LaTeX
- [CSS Foundations](references/css-foundations.md) — colors, typography, spacing, theming, snippets
