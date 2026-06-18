---
name: Knowledge
description: "Operate the Obsidian work knowledge base through semantic-vault-mcp. Uses OBSIDIAN_VAULT_PATH plus dynamic VAULT_KNOWLEDGE / VAULT_KNOWLEDGE_FOLDERS scope from ~/.env or obsidian-mono/.env; missing configured folders are omitted during vault restructures. Commands: search/retrieve via hybrid MCP RAG, graph/related/traverse via MCP graph lookup, stats, contradictions, find category, add/develop notes using the vault's AGENTS conventions. USE WHEN knowledge, knowledge base, search knowledge, what do we know about, knowledge graph, graph, related notes, traverse, retrieve, contradictions, develop note, add to knowledge, find by category. NOT FOR session/ISA context recovery (use ContextSearch)."
argument-hint: [search|graph|related|traverse|retrieve|contradictions|find|add|develop|index-status|<query>]
effort: low
context: inline
---

# Knowledge Skill

Operate the **Obsidian vault knowledge area** as a navigable graph and RAG store. Read-heavy work
runs through `semantic-vault-mcp` via `Tools/KnowledgeMcp.ts`; direct file access is reserved for
creating or editing notes.

Configuration comes from `~/.env` and then `~/Developer/tmp/obsidian-mono/.env`:

```bash
OBSIDIAN_VAULT_PATH="C:\Users\A200274555\Developer\knowledge-base"
VAULT_KNOWLEDGE="Knowledge"
VAULT_KNOWLEDGE_FOLDERS="Areas,Resources"
```

`OBSIDIAN_VAULT_PATH` locates the vault. `VAULT_KNOWLEDGE` is the desired logical knowledge root.
`VAULT_KNOWLEDGE_FOLDERS` is optional transition scope for work vault structures that have not fully
moved into `Knowledge/` yet.

Scope resolution is dynamic:

- If `VAULT_KNOWLEDGE` is set to an existing vault-relative folder, MCP calls use it as `folderFilter`.
- If `VAULT_KNOWLEDGE_FOLDERS` contains existing vault-relative folders, MCP calls add them as `includeFolders`.
- If a configured folder is missing during a restructure, it is reported by `status` and omitted from MCP calls.
- Set `VAULT_KNOWLEDGE="*"` or leave it unset to query the whole vault, optionally narrowed by `VAULT_KNOWLEDGE_FOLDERS`.

**Schema is the vault's, not PAI's**: notes are keyed by title/filename, graph edges come from
`categories:`, `related:`, and body `[[wikilinks]]`. New notes follow the vault `AGENTS.md`
contract: `type`, `maturity`, `summary`, `categories`, and natural-title filenames.

## Command Routing

| Input | Command |
|-------|---------|
| `/knowledge` (no args) | **status** - lightweight MCP index + queue status |
| `/knowledge <query>` | **search** - ranked MCP vault search |
| `/knowledge graph` / `graph <title>` | **graph** stats / title traversal |
| `/knowledge related <title>` | **related** - 1-hop MCP neighbours |
| `/knowledge retrieve <query>` | **retrieve** - hybrid MCP fragments |
| `/knowledge contradictions` | **contradictions** - MCP candidate pairs |
| `/knowledge find <category>` | **find** - MCP category lookup |
| `/knowledge index-status` | **index-status** - MCP local index status |
| `/knowledge queue-status` | **queue-status** - MCP slow auto-index queue status |
| `/knowledge add` | **add** a note using vault conventions |
| `/knowledge develop` | **develop** seedlings |

Use one adapter for read operations:

```bash
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts <command> [args]
```

`Tools/KnowledgeGraph.ts` remains as a fallback only if Obsidian or the MCP server is unavailable.

---

## status / index-status

```bash
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts status
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts index-status --raw
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts queue-status
```

`status` shows the resolved dynamic scope, persistent local RAG index, vector coverage, and slow
auto-index queue state using MCP `index_status lightweight=true` plus `index_queue_status`.
Use this as the default `/knowledge` view because it is lightweight and safe during normal
Obsidian use. It does not run graph stats, hubs, PageRank, or note-content retrieval.
`index-status` shows the full index status, including stale-document hygiene, when a single raw MCP
result is needed.
`queue-status` shows whether the slow auto-index queue is enabled, delayed, running, or ready,
without reading notes or running graph work.

## stats

```bash
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts stats
```

`stats` shows graph counts, categories, orphans, and edge-type distribution. It is cached in MCP,
but it is still heavier than index status on large vaults.

## search <query>

```bash
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts search "<query>" --top 10
```

Use this for file-level ranked discovery. For compressed context snippets, use `retrieve`.

## retrieve <query>

```bash
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts retrieve "<query>" --top 5
```

Returns hybrid-ranked MCP fragments using lexical/semantic/vector/PageRank signals from the plugin
index. Use `--raw` when exact JSON fields are needed.

## graph / related / traverse / find / contradictions

```bash
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts graph "GraphRAG" --hops 2
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts related "Attention Mechanism"
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts traverse "GraphRAG" --hops 2
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts find "Large Language Models" --top 20
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts hubs --top 10 --force
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts contradictions --top 10
```

`contradictions` returns candidate pairs. Treat them as leads, then read only the specific notes
needed to judge the claims.

## add <title>

Create a note in the knowledge root following the vault contract:

1. Add `type:`, `maturity: seedling`, and a one-line `summary:`.
2. Connect it with `categories: ["[[Domain]]"]` and 2-4 `related:` links.
3. Find candidate links first:
   ```bash
   bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts retrieve "<topic>" --top 8
   ```
4. Weave 1-3 natural `[[Title]]` wikilinks into the body.
5. Filename is the concept in natural Title Case. Do not duplicate a note across folders.

## develop

The gardening pass surfaces seedlings and enriches them. Prefer MCP retrieval for neighbours and
context, then read/edit only the target note and the specific related notes needed:

```bash
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeMcp.ts retrieve "maturity seedling <topic>" --top 8
```

If exact frontmatter enumeration is required, resolve the root from `OBSIDIAN_VAULT_PATH` and
`VAULT_KNOWLEDGE`, then use a narrow `rg` over that folder.

## Gotchas

- **MCP first.** Use `KnowledgeMcp.ts` for graph, retrieve, search, stats, categories, and contradictions.
- **Obsidian must be running** with `semantic-vault-mcp` enabled for MCP commands.
- **Path comes from env, scope is dynamic.** Prefer `OBSIDIAN_VAULT_PATH` + `VAULT_KNOWLEDGE` + `VAULT_KNOWLEDGE_FOLDERS`; missing restructure folders are omitted instead of hard-failing. Keep `VAULT_PATH` only for legacy fallback tools.
- **Titles, not slugs.** Wikilinks are `[[Attention Mechanism]]`, matching the filename.
- **Categories are graph edges.** Do not create topic folders just to express membership.
- **Never delete notes without asking.**
