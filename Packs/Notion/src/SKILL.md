---
name: notion
description: "Use when interacting with Notion workspaces - reading pages, writing content, querying databases, and basic page/database operations via the Notion API."
---

<!--
COMMUNITY SKILL

Part of the PAI open skills collection.
- License: MIT

Contributions welcome via GitHub issues and PRs.
-->

# Notion Skill

Production-ready Notion CLI and Library for reading, writing, exporting, and schema inspection.

## Overview

- **TypeScript CLI** for all CRUD operations
- **Auto-Token-Load** from `.zshrc` / `.bashrc`
- **Automatic Pagination** (no 100-entry limit)
- **Markdown Export** with attachments
- **CSV Export** for databases
- **Schema Inspection** for database structure

## Requirements

- Node.js >= 18
- `NOTION_API_TOKEN` in environment or shell config
- Notion Integration with workspace access

### Setup

```bash
# 1. Set token (auto-detected from shell config)
echo 'export NOTION_API_TOKEN=secret_xxx' >> ~/.zshrc

# 2. Build
cd ${CLAUDE_SKILL_DIR} && npm install && npm run build

# 3. Alias (optional)
alias notion='node ${CLAUDE_SKILL_DIR}/dist/scripts/notion.js'
```

## CLI Usage

### Read (Markdown Export)

```bash
notion read <page-id-or-url>
notion read <id> --children                    # With nested blocks
notion read <id> --download=./images           # Download attachments
```

### Query Database

```bash
notion query <database-id-or-url>
notion query <id> --filter="Status=Done"
notion query <id> --format=json --limit=50
```

### Search

```bash
notion search "Keyword"
notion search "Project" --filter=page
notion search "Tasks" --filter=database
```

### Create

```bash
# As child page
notion create --parent=<page-id> --title="New Page"

# As database entry
notion create --database=<db-id> --props="Name=Task,Status=To Do,Priority=High"
```

### Update

```bash
notion update <page-id> --props="Status=Done,Priority=Low"
```

### Schema (Database Structure)

```bash
notion schema <database-id-or-url>
# Shows: Properties, Types, Select options, Formulas
```

### Export (CSV)

```bash
notion export <database-id-or-url>
notion export <id> --output=mydata.csv
```

## Rich Page Building (Block API)

For complex pages (columns, callouts, toggles, nested content), the CLI isn't enough.
Use the **Block API directly** via Python or curl.

**Full reference:** `references/block-building.md`

Key capabilities:
- **Column layouts** (`column_list`) — side-by-side comparisons
- **Callouts** with emoji icons and colored backgrounds
- **Toggles** with nested children (collapsible content)
- **Insert after** specific blocks (surgical placement)
- **Nested children** in callouts/toggles (up to 2 levels)

Quick example — two-column comparison:
```python
column_list(
    [callout("A", [rt("Concept A", bold=True)], "red_background"),
     bullet(rt("Property 1")), bullet(rt("Property 2"))],
    [callout("B", [rt("Concept B", bold=True)], "orange_background"),
     bullet(rt("Property 1")), bullet(rt("Property 2"))],
)
```

**Workflow:** Read page > scan block IDs > build blocks with helpers > PATCH append/insert

## Library Usage

```typescript
import { NotionClient } from "./lib/notion-client.js";

const client = new NotionClient({ token: process.env.NOTION_API_TOKEN });

// Create page
const page = await client.createPage({
  parent: { database_id: "db-id" },
  properties: {
    Name: { title: [{ text: { content: "New Task" } }] },
    Status: { select: { name: "To Do" } },
  },
});

// Update page
await client.updatePage("page-id", {
  Status: { select: { name: "Done" } },
});

// Get file URL
const url = await client.getFileUrl("block-id");
```

## IDs

### Page/Database ID from URL
```
https://www.notion.so/Workspace/Title-1a2b3c4d5e6f7g8h9i0j1k2l
                        ^^^^^^^^^^^^^^^^^^^^^^^^
                        ID (32 chars)
```

### Granting Integration Access
1. Open page/database
2. Share > Add connections
3. Select your integration

## Error Handling

| Status | Meaning | Solution |
|--------|---------|----------|
| 401 | Invalid token | Check `NOTION_API_TOKEN` |
| 403 | No access | Connect integration to page |
| 404 | Not found | Check ID |
| 429 | Rate limit | Auto-retry after 1s, 2s, 4s |
| 400 | Validation Error | Check property names (case-sensitive!) |

## Project Structure

```
${CLAUDE_SKILL_DIR}/
├── docs/
│   ├── prd.md              # Product Requirements
│   └── plan.md             # Implementation Plan
├── lib/
│   ├── notion-client.ts    # HTTP client + retry logic
│   └── notion-md.ts        # Markdown converter
├── scripts/
│   └── notion.ts           # CLI entry point
├── references/
│   ├── notion-types.ts     # Complete API types
│   └── block-building.md   # Block construction reference (columns, callouts, toggles)
├── package.json
└── tsconfig.json
```

## Development

```bash
cd ${CLAUDE_SKILL_DIR}
npm run dev      # Watch mode
npm run build    # Compile
```


## References

- Notion API Docs: https://developers.notion.com/reference/intro
- Integration Setup: https://www.notion.so/my-integrations
