# PRD: Notion Skill

## Problem

Basic Notion integrations typically offer only curl examples without functioning tools. For productive work, the following are needed:
- Pagination for large databases
- Markdown/Notion conversion
- Error handling / retry logic
- TypeScript types

## Solution

Production-ready Notion skill with:
1. **TypeScript CLI** (`scripts/notion.ts`) — replaces raw curl
2. **Markdown Export** — Page to Markdown with correct formatting
3. **Database Query** — with pagination, filter, sort
4. **Type-Safe API** — Notion API types
5. **Robust Error Handling** — rate limits, retries

## Scope

### In Scope
- `scripts/notion.ts` — CLI for read/query/create
- `lib/notion-client.ts` — HTTP client with retry logic
- `lib/notion-md.ts` — Block to Markdown conversion
- `references/notion-types.ts` — API type definitions
- Pagination for database queries
- Environment check (NOTION_API_TOKEN)

### Out of Scope
- Two-way sync (Notion <- Markdown import)
- Real-time webhooks
- Database schema management
- Rich-text editing in Notion

## Success Criteria
- [ ] `notion read <page-id>` outputs Markdown
- [ ] `notion query <db-id> --filter "Status=Done"` outputs JSON/Table
- [ ] Pagination automatic (no 100-entry limit)
- [ ] Clear error messages for 401/403/404
- [ ] TypeScript strict mode, no `any`

## Non-Goals
- No GUI/Interactive mode
- No backup/restore functionality
- No complex filter syntax (only simple Key=Value)

## Constraints
- Node.js + TypeScript
- Zero external runtime dependencies (only dev deps + undici for proxy)
- Custom code instead of `notion-to-md` library

## Open Questions
- Should the CLI serve as a globally installable binary or only local?
