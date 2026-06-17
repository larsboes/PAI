---
name: Knowledge
description: "Operate the knowledge base as a graph — search, navigate, retrieve, and grow it. Points at the Obsidian vault's Knowledge/ folder (path read from ~/.env: $VAULT_PATH/$VAULT_KNOWLEDGE), falling back to the legacy PAI archive if unset. Commands: search (3-pass lexical+frontmatter+wikilink), graph/related/traverse (KnowledgeGraph.ts over categories+related+body wikilinks), retrieve (BM25-lite ranked context), contradictions (category-overlap candidate pairs), find (notes in a category), add/develop (create + grow notes per the vault's AGENTS conventions). USE WHEN knowledge, knowledge base, search knowledge, what do we know about, knowledge graph, graph, related notes, traverse, retrieve, contradictions, develop note, add to knowledge, find by category. NOT FOR session/ISA context recovery (use ContextSearch)."
argument-hint: [search|graph|related|traverse|retrieve|contradictions|find|add|develop|<query>]
effort: low
context: fork
---

# Knowledge Skill

Operate the **Obsidian vault's `Knowledge/` folder** as a navigable graph. The path is read from
`~/.env` (`VAULT_PATH` + `VAULT_KNOWLEDGE`, same place the Obsidian skill reads it), so the store is
defined once. If those are unset it falls back to the legacy PAI archive — no hardcoded paths.

**Schema is the vault's, not PAI's** (see `AGENTS.md` in the vault): notes are keyed by **title**
(filename), graph edges are `categories:` (`[[Domain]]`) + `related:` (`[[Title]]`) + body `[[wikilinks]]`.
There are **no kebab slugs and no typed-link `{slug,type}`** here. Maturity uses the vault's scale
(`seedling` → `🌱/🌿/🌲/🗺️`). New notes follow `type`/`maturity`/`categories` at birth.

```bash
# resolve the knowledge root from ~/.env (used by the rg commands below)
KB="$(grep '^VAULT_PATH=' ~/.env | cut -d= -f2-)/$(grep '^VAULT_KNOWLEDGE=' ~/.env | cut -d= -f2-)"
```

## Command Routing

| Input | Command |
|-------|---------|
| `/knowledge` (no args) | **status** — graph stats dashboard |
| `/knowledge <query>` | **search** (default) |
| `/knowledge graph` / `graph <title>` | **graph** stats / traverse |
| `/knowledge related <title>` | **related** — 1-hop neighbours |
| `/knowledge retrieve <query>` | **retrieve** — BM25-lite ranked |
| `/knowledge contradictions` | **contradictions** |
| `/knowledge find <category>` | **find** |
| `/knowledge add` | **add** a note (vault conventions) |
| `/knowledge develop` | **develop** seedlings |

The graph/retrieve/contradiction commands run one tool:
```bash
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeGraph.ts <command> [args]
```

---

## status (default, no args)
```bash
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeGraph.ts stats
```
Shows node/edge counts, top hubs, isolated notes, top categories. Present in NATIVE mode.

## search <query>
Three passes against `$KB`, deduplicated:
```bash
rg -i "$ARGUMENTS" "$KB" --type md -l                                  # lexical
rg -i "summary:.*$ARGUMENTS|categories:.*$ARGUMENTS" "$KB" --type md -l # frontmatter
rg "\[\[.*$ARGUMENTS.*\]\]" "$KB" --type md -l                          # wikilink
```
For each hit, read the frontmatter (`summary`, `categories`, `maturity`). Present as a table.
For ranked/compressed results instead of a file list, use **retrieve**.

## graph / related / traverse / find / retrieve / contradictions
```bash
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeGraph.ts stats
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeGraph.ts related "Attention Mechanism"
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeGraph.ts traverse "GraphRAG" --hops 2
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeGraph.ts find "Large Language Models"
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeGraph.ts retrieve "<query>" --top 5     # --raw for excerpts
bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeGraph.ts contradictions --top 10
```
`contradictions` returns high category-overlap *candidate pairs* — read both notes and judge the
claims semantically; the tool only narrows the search space.

## add <title>
Create a note in `$KB` following the vault contract (`AGENTS.md`):
1. **Type at birth:** `type:` + `maturity: seedling` + a one-line `summary:`.
2. **Connect it:** `categories: ["[[Domain]]"]` (membership) + `related: ["[[Title]]", …]` (2-4 links).
   Find candidates first: `bun run ${CLAUDE_SKILL_DIR}/Tools/KnowledgeGraph.ts retrieve "<topic>" --top 8`.
3. Weave 1-3 `[[Title]]` wikilinks into the body where natural.
4. Filename = the concept in natural Title Case (`Attention Mechanism.md`) — the title IS the link target.
5. Never duplicate a note across folders; cross-membership is `categories:`, connections are `[[links]]`.

## develop
The gardening pass — surface seedlings and enrich them:
```bash
rg -l "^maturity:\s*(seedling|🌱)" "$KB" --type md
```
For each: read it + its `related:`/`retrieve` neighbours, enrich, promote maturity, update, present the diff.

## Gotchas
- **Path comes from `~/.env`.** `VAULT_PATH` + `VAULT_KNOWLEDGE`. Change the vault → change one line.
- **Titles, not slugs.** Wikilinks are `[[Attention Mechanism]]`, matching the filename. No kebab-case.
- **Categories ARE the domains.** The `Knowledge/AI`, `/Engineering`, … folders are currently empty —
  domain membership lives in `categories:`, not folders. Don't create topic folders.
- **Future graph backend:** `~/Developer/obsidian-mono/obsidian-mcp` (not ready yet) will eventually
  back graph/traverse; until then `Tools/KnowledgeGraph.ts` is the engine.
- **Never delete notes without asking.**
