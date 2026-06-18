---
name: Knowledge
pack-id: pai-knowledge-v1.0.0
version: 1.0.0
author: danielmiessler
description: Operate the Obsidian work knowledge base through semantic-vault-mcp. Graph, search, retrieve, category lookup, contradictions, queue status, and index status run through the MCP/RAG plugin with dynamic vault scope; note creation and gardening still follow the vault AGENTS conventions. Legacy KnowledgeGraph.ts remains available as a fallback when Obsidian or MCP is unavailable.
type: skill
platform: claude-code
source: PAI v5.0.0
---

# Knowledge

Operate the Obsidian work knowledge base through `semantic-vault-mcp`.

The pack keeps the user-facing `/knowledge` workflow, but read-heavy operations now go through
`src/Tools/KnowledgeMcp.ts`:

- graph stats, related notes, traversal, category lookup, and contradiction candidates
- hybrid RAG retrieval and ranked search
- local index status for the MCP plugin
- slow auto-index queue status
- dynamic scope resolution from `OBSIDIAN_VAULT_PATH`, `VAULT_KNOWLEDGE`, and `VAULT_KNOWLEDGE_FOLDERS`

Direct vault reads/writes are reserved for note creation and gardening workflows where the agent
must edit specific notes. `KnowledgeGraph.ts` remains in the pack as a recoverable fallback.

## Scope

The adapter does not assume the work vault already has a `Knowledge/` folder. It checks configured
vault-relative folder roots before calling MCP:

```env
OBSIDIAN_VAULT_PATH="C:\Users\A200274555\Developer\knowledge-base"
VAULT_KNOWLEDGE="Knowledge"
VAULT_KNOWLEDGE_FOLDERS="Areas,Resources"
```

If `Knowledge/` is missing during a restructure, `status` reports it and sends only existing
include folders such as `Areas` and `Resources`. Set `VAULT_KNOWLEDGE="*"` or leave it unset for
whole-vault behavior.

## Quick Checks

```powershell
bun run C:\Users\A200274555\Developer\tmp\PAI\Packs\Knowledge\src\Tools\KnowledgeMcp.ts status
bun run C:\Users\A200274555\Developer\tmp\PAI\Packs\Knowledge\src\Tools\KnowledgeMcp.ts status --raw
bun run C:\Users\A200274555\Developer\tmp\PAI\Packs\Knowledge\src\Tools\KnowledgeMcp.ts queue-status
```

## Installation

This pack is designed for AI-assisted installation. Point your AI at this directory and ask it to
install using `INSTALL.md`.

```text
"Install the Knowledge pack from PAI/Packs/Knowledge/"
```

Your AI walks through a 5-phase wizard: system analysis, user questions, backup, installation,
verification.

## What's Included

```text
src/SKILL.md
src/Tools/KnowledgeMcp.ts
src/Tools/KnowledgeGraph.ts
```

The full skill source lives under `src/`. Read `src/SKILL.md` for detailed capabilities,
workflows, and usage.

## Source

Built from the PAI v5.0.0 release skill at `Releases/v5.0.0/.claude/skills/Knowledge/`, then
adapted to use the Obsidian `semantic-vault-mcp` backend.

## License

MIT - see [PAI LICENSE](../../LICENSE).
