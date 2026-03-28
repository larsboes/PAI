---
name: notebooklm
description: Use when interacting with NotebookLM — querying sources, creating notebooks, adding URLs/text/Drive docs, generating audio/video/reports/flashcards, or running web research via the notebooklm MCP server.
---

# NotebookLM

Reference guide for the `notebooklm` MCP server (31 tools).

## Auth

Tokens stored at `${NOTEBOOKLM_AUTH_DIR}/`. Cookies stable for weeks; CSRF + session auto-refreshed on init.

**When 401/403:** Re-extract cookies from Chrome DevTools → `save_auth_tokens(cookies=<cookie_header>)` or run `notebooklm-mcp-auth` CLI.

## Tools

### Notebooks

| Tool | Purpose |
|------|---------|
| `notebook_list` | List all notebooks |
| `notebook_create` | Create new notebook |
| `notebook_get` | Get details + sources |
| `notebook_describe` | AI summary of notebook content |
| `notebook_rename` | Rename |
| `notebook_delete` | Delete (**requires `confirm=True`**) |

### Sources

| Tool | Purpose |
|------|---------|
| `notebook_add_url` | Add URL or YouTube video |
| `notebook_add_text` | Add pasted text |
| `notebook_add_drive` | Add Google Drive doc |
| `source_describe` | AI summary + keywords for a source |
| `source_get_content` | Raw text content (no AI) |
| `source_list_drive` | List sources + Drive freshness |
| `source_sync_drive` | Sync stale Drive sources (**requires `confirm=True`**) |
| `source_delete` | Delete source (**requires `confirm=True`**) |

### Query & Chat

| Tool | Purpose |
|------|---------|
| `notebook_query` | Ask questions — AI answers grounded in sources |
| `chat_configure` | Set goal, style, response length |

### Research

| Tool | Purpose |
|------|---------|
| `research_start` | Start Web or Drive research (`type="web"` or `"drive"`) |
| `research_status` | Poll progress (built-in wait) |
| `research_import` | Import discovered sources into notebook |

### Studio — Content Generation

All require `confirm=True`. Always show settings to user and get approval first.

| Tool | Output |
|------|--------|
| `audio_overview_create` | Podcast |
| `video_overview_create` | Video overview |
| `infographic_create` | Infographic |
| `slide_deck_create` | Slide deck |
| `report_create` | Briefing doc / study guide / blog post / custom |
| `flashcards_create` | Flashcards (with difficulty) |
| `quiz_create` | Interactive quiz |
| `data_table_create` | Data table |
| `mind_map_create` | Mind map (saved to file) |
| `studio_status` | Check generation status |
| `studio_delete` | Delete artifact (**requires `confirm=True`**) |

### Auth Management

| Tool | Purpose |
|------|---------|
| `save_auth_tokens` | Save cookies (+ optional `request_body`, `request_url` for faster init) |
| `refresh_auth` | Reload from disk or trigger headless re-auth |

## Rules

- **Irreversible ops** (`notebook_delete`, `source_delete`, `studio_delete`): always list first, require `confirm=True`
- **Studio generation**: show type + settings, get explicit user approval before `confirm=True`
- **Rate limit**: ~50 queries/day on free tier

## Common Workflows

**Query a notebook:**
```
notebook_list → find key
notebook_query(notebook_id=key, query="...")
```

**Add sources then query:**
```
notebook_create (or use existing)
notebook_add_url / notebook_add_text / notebook_add_drive
notebook_query
```

**Web research workflow:**
```
research_start(notebook_id=key, type="web", query="...")
research_status  ← poll until complete
research_import(notebook_id=key, source_ids=[...])
```

**Generate content:**
```
Show user: type + settings
Get confirm → call studio tool
studio_status  ← poll until complete
```
