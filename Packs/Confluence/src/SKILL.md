---
name: Confluence
description: "Confluence REST API wrapper — search pages with CQL, read/create/update/delete pages, manage labels, comments, and attachments. Reads CONFLUENCE_URL + CONFLUENCE_EMAIL + CONFLUENCE_TOKEN from env. USE WHEN confluence, wiki, pages, CQL, create page, update wiki, search confluence, page content, space, labels, attachments, documentation wiki."
allowed-tools: Bash
---

# Confluence

REST API wrapper for Confluence Server/Cloud. Config from `~/.env`.

## Configuration (`~/.env`)

```env
CONFLUENCE_URL=https://your-confluence.example.com
CONFLUENCE_EMAIL=your.email@example.com
CONFLUENCE_TOKEN=your-api-token
```

## Usage

```bash
{baseDir}/scripts/confluence.sh <command> [args...]
```

## Quick Reference

| Task | Command |
|------|---------|
| Search pages | `confluence.sh search "type=page AND space=MYSPACE AND title~'topic'"` |
| Full-text search | `confluence.sh search-text "keyword" --space MYSPACE` |
| Get page | `confluence.sh page 123456` |
| Find by title | `confluence.sh page-by-title MYSPACE "Page Title"` |
| Create page | `confluence.sh create MYSPACE "Title" "<p>Content</p>"` |
| Update page | `confluence.sh update 123456 "New Title" "<p>New content</p>"` |
| Append to page | `confluence.sh append 123456 "<h2>Section</h2><p>Content</p>"` |
| Add comment | `confluence.sh comment 123456 "<p>My comment</p>"` |
| List spaces | `confluence.sh spaces` |
| List attachments | `confluence.sh attachments 123456` |
| Download attachment | `confluence.sh attachment-download 123456 "diagram.png"` |

## CQL Examples

```bash
confluence.sh search "space=MYSPACE AND type=page AND lastmodified > now('-7d')"
confluence.sh search "label=architecture AND type=page"
confluence.sh search "creator=currentUser() AND type=page ORDER BY lastmodified DESC"
confluence.sh search "type=page AND text~'keyword'"
```

## Body Format

Confluence uses XHTML storage format:
- `<p>Paragraph</p>`, `<h2>Heading</h2>`
- Code: `<ac:structured-macro ac:name="code"><ac:plain-text-body><![CDATA[code]]></ac:plain-text-body></ac:structured-macro>`
- Link: `<ac:link><ri:page ri:content-title="Page Title"/></ac:link>`

## Red Flags

- **401**: Token expired — regenerate
- **Body format errors**: Must be valid XHTML storage format
- **Version conflicts on update**: Use `--version N` or let auto-version handle it
- **Large pages**: `page` command returns full body — pipe to file if needed
