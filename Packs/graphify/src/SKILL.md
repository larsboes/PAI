---
name: graphify
description: "Turn a codebase or folder into a queryable knowledge graph instead of grepping — build the graph once, then ask natural-language questions, trace what-calls-what, find blast radius before a refactor, and export call-flow / tree visualizations. Wraps the graphify (PyPI: graphifyy) CLI: tree-sitter AST extraction (free, no API key) plus optional LLM semantic enrichment. USE WHEN graphify, code graph, knowledge graph, dependency graph, build graph, index codebase, query codebase, how does X work, what calls X, what depends on X, who uses X, impact analysis, blast radius, call flow, architecture map, god nodes, code communities, visualize codebase, understand large/unfamiliar codebase, where is X used. NOT FOR a quick grep on a small repo or reading one known file (use Grep/Read); NOT FOR drawing diagrams from scratch (use Mermaid or Art); NOT FOR web/document research (use Research/Parser)."
allowed-tools: Bash, Read, Glob
---

# graphify — graph-first codebase understanding

You are a code-graph operator. On a large or unfamiliar codebase, **prefer the graph over grep**: build it once, then `query` / `explain` / `affected` instead of reading dozens of files. The graph answers "how does this work / what depends on this" in one call at a fraction of the tokens.

`graphify` (binary) ships from the PyPI package **`graphifyy`** (double-y — easy to typo). It is a Python CLI; this skill drives the CLI verbs directly. **Never run `graphify install`** — that writes graphify's own competing skill/hooks into the host and fights PAI's layout.

## Cost model — read this before choosing a verb

| Operation | Verbs | Needs LLM key? | Cost |
|-----------|-------|----------------|------|
| **Build** semantic graph | `extract` | yes (else AST-only) | $ + time |
| **Update** after edits | `update` | no (AST only) | free |
| **Read** the graph | `query` `explain` `path` `affected` | no | free |
| **Visualize / export** | `tree` `export` | no | free |

Build is the only expensive step. Once `graphify-out/graph.json` exists, everything else is free — bias toward reading the existing graph.

## Preflight (always)

1. Resolve the binary via the bundled wrapper: `bash Tools/graphify.sh --version`. If it prints an install hint, stop and surface `INSTALL.md` to the user — do not try to build from source.
2. Check for an existing graph: `test -f graphify-out/graph.json`. If present, default to the **read** workflows (free). If absent, you need **BuildGraph** first.
3. For BuildGraph only: check an LLM key is set (`ANTHROPIC_API_KEY`, `GEMINI_API_KEY`/`GOOGLE_API_KEY`, `OPENAI_API_KEY`, `DEEPSEEK_API_KEY`, `MOONSHOT_API_KEY`, or `OLLAMA_BASE_URL`). No key → tell the user you'll build an **AST-only** graph (code structure, free) and that semantic/doc edges and community names will be missing.

All commands below go through `bash Tools/graphify.sh <args>` so binary resolution stays in one place.

## Workflows

### 1. BuildGraph — index a directory or repo (run once)
Use when there is no `graphify-out/graph.json` yet, or the codebase changed structurally.
```bash
# local path
bash Tools/graphify.sh extract . --mode deep
# a github repo (clones first, then extract)
bash Tools/graphify.sh clone https://github.com/owner/repo
```
- No API key → append nothing; graphify falls back to AST-only and may exit non-zero only on hard errors. Warn the user about reduced richness.
- Pick a backend explicitly with `--backend gemini|claude|openai|kimi|deepseek|ollama` if multiple keys are set.
- After it finishes, **read `graphify-out/GRAPH_REPORT.md`** first — it lists god nodes (most-connected), communities, and surprising connections, and is the best orientation for a new codebase.

### 2. QueryGraph — ask questions without re-reading files (free, high-frequency)
Gate: requires `graphify-out/graph.json`. This is the default workflow once a graph exists.
```bash
bash Tools/graphify.sh query "how does authentication work" --budget 4000   # BFS; add --dfs for deep chains
bash Tools/graphify.sh explain "PaymentService"                              # node + neighbors in plain language
bash Tools/graphify.sh path "LoginController" "Database"                     # shortest path between two nodes
bash Tools/graphify.sh affected "User" --depth 3                            # reverse impact / blast radius
```
- Surface edge confidence honestly: graphify labels edges `EXTRACTED | INFERRED | AMBIGUOUS`. Do not present `INFERRED`/`AMBIGUOUS` edges as established fact.
- **Graph memory (feedback loop):** after a useful answer, persist it so the graph accumulates Q&A — `bash Tools/graphify.sh save-result "<question>" --answer "<answer>" --type query` (stored under `graphify-out/memory/`). Re-querying later benefits from saved results.

### 3. UpdateGraph — keep the graph fresh after code edits (free, AST-only)
```bash
bash Tools/graphify.sh update .            # re-extract changed code files only
bash Tools/graphify.sh update . --force    # after deletions/renames, rebuild from scratch (still no LLM)
```
Cheap enough to run after a batch of edits before querying again.

### 4. VisualizeExport — shareable artifacts
```bash
bash Tools/graphify.sh export callflow-html     # Mermaid architecture / call-flow HTML
bash Tools/graphify.sh tree                      # D3 collapsible-tree HTML
```
Also supports `--svg`, `--graphml`, and Neo4j/FalkorDB `cypher.txt` export flags. Outputs land under `graphify-out/`.

### (Optional) ServeMCP — structured tools for a heavy interactive session
For long sessions, launch the MCP server so the agent gets typed `query_graph` / `god_nodes` / `shortest_path` tools instead of parsing CLI text:
```bash
bash Tools/graphify.sh --mcp     # runs `graphify-mcp` (stdio). Background it; don't block.
```

## Gotchas

- **Install name ≠ run name**: `uv tool install graphifyy` → binary `graphify`. See `INSTALL.md`.
- **All read verbs default to `graphify-out/graph.json` relative to CWD.** Run from the project root, or pass `--graph <path>`.
- **Build needs a key; reads don't.** If a "query" fails because no graph exists, build first — don't fall back to grep silently.
- **Clustering quality** drops without the `leiden` extra (graspologic, Python <3.13). Community labels may be coarse.
- If graphify errors or produces an empty graph, say so and fall back to normal Grep/Read exploration — never fabricate graph results.

## Rules

- Prefer the graph on any codebase large enough that grep would mean reading 5+ files; for a one-file lookup, just use Read.
- Never run `graphify install`. Never edit graphify's own source.
- Report edge-confidence labels. Distinguish `EXTRACTED` fact from `INFERRED` guess.
- The expensive verb is `extract`; everything else is free — don't rebuild when `update` or a read suffices.

## Supporting files
- `Tools/graphify.sh` — binary resolver (uv tool → pipx → PATH → uvx) + arg passthrough; prints an install hint if graphify is absent. READ/run this for every invocation.
- `INSTALL.md` — one-time install steps and the package-name gotcha.
