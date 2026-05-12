---
name: Notion
pack-id: pai-notion-v1.0.0
version: 1.0.0
author: larsboes
description: Production-ready Notion API integration — TypeScript CLI and library for reading pages, querying databases, searching workspaces, creating/updating entries, exporting to Markdown/CSV, and constructing rich block layouts (columns, callouts, toggles). Auto-pagination, exponential backoff retry, proxy support, and comprehensive type definitions for the Notion API v2022-06-28.
type: skill
platform: pi,claude-code
source: PAI Community
---

# Notion

Production-ready Notion API integration — TypeScript CLI and library for reading pages, querying databases, searching workspaces, creating/updating entries, exporting to Markdown/CSV, and constructing rich block layouts (columns, callouts, toggles). Auto-pagination, exponential backoff retry, proxy support, and comprehensive type definitions for the Notion API v2022-06-28.

## Installation

This pack is designed for AI-assisted installation. Point your AI at this directory and ask it to install using `INSTALL.md`.

```
"Install the Notion pack from PAI/Packs/Notion/"
```

Your AI walks through a 5-phase wizard: system analysis, user questions, backup, installation, verification.

## What's Included

```
  lib/
    notion-client.ts    # HTTP client with retry logic + proxy support
    notion-md.ts        # Block-to-Markdown converter
  scripts/
    notion.ts           # CLI entry point
    notion.sh           # Lightweight bash/curl helper
  references/
    notion-types.ts     # Complete Notion API type definitions
    block-building.md   # Rich block construction reference
  docs/
    prd.md              # Product requirements
    plan.md             # Implementation plan
  SKILL.md
  package.json
  tsconfig.json
```

The full skill source lives under `src/`. Read `src/SKILL.md` for detailed capabilities, workflows, and usage.

## License

MIT — see [PAI LICENSE](../../LICENSE).
