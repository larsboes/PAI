# Notion Block Building Reference

## Block Construction via API

When the CLI isn't enough (rich layouts, columns, nested content), use the Notion API directly via Python/curl.
The CLI handles read/search/create basics. This reference covers **advanced page construction**.

## API Essentials

```bash
# Auth header (token from ~/.bashrc or ~/.zshrc)
NOTION_TOKEN=$(grep NOTION_API_TOKEN ~/.bashrc | head -1 | sed "s/.*=//;s/['\"]//g")

# Create page
curl -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{"parent":{"page_id":"<id>"},"properties":{"title":{"title":[{"text":{"content":"Title"}}]}},"children":[...]}'

# Append blocks to page/block (max 100 per request)
curl -X PATCH "https://api.notion.com/v1/blocks/<page-or-block-id>/children" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{"children":[...]}'

# Insert after specific block
curl -X PATCH "https://api.notion.com/v1/blocks/<page-id>/children" \
  -d '{"children":[...],"after":"<block-id-to-insert-after>"}'

# Get block children (to find block IDs)
curl "https://api.notion.com/v1/blocks/<page-id>/children?page_size=100" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2022-06-28"
```

## Python Block Helpers

Preferred approach for complex pages — use Python with `urllib` (no dependencies):

```python
import json, time, urllib.request

TOKEN = "secret_..."  # from env
BASE = "https://api.notion.com/v1"

def api(method, url, body=None):
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(url, data=data, method=method, headers={
        "Authorization": f"Bearer {TOKEN}",
        "Content-Type": "application/json",
        "Notion-Version": "2022-06-28",
    })
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read())

def append(page_id, blocks, after_id=None):
    """Append blocks to page. Optional: insert after specific block."""
    for i in range(0, len(blocks), 100):
        body = {"children": blocks[i:i+100]}
        if after_id and i == 0:
            body["after"] = after_id
        api("PATCH", f"{BASE}/blocks/{page_id}/children", body)
        time.sleep(0.35)  # rate limit
```

## Block Type Reference

### Rich Text (used inside all blocks)

```python
def rt(text, bold=False, italic=False, code=False, color=None):
    r = {"type": "text", "text": {"content": text}}
    ann = {}
    if bold: ann["bold"] = True
    if italic: ann["italic"] = True
    if code: ann["code"] = True
    if color: ann["color"] = color  # e.g. "red", "blue", "orange"
    if ann: r["annotations"] = ann
    return r
```

### Basic Blocks

```python
# Headings
def h1(text): return {"object":"block","type":"heading_1","heading_1":{"rich_text":[rt(text)]}}
def h2(text): return {"object":"block","type":"heading_2","heading_2":{"rich_text":[rt(text)]}}
def h3(text): return {"object":"block","type":"heading_3","heading_3":{"rich_text":[rt(text)]}}

# Paragraph (supports multiple rich_text segments)
def p(*parts): return {"object":"block","type":"paragraph","paragraph":{"rich_text":list(parts)}}

# Divider
def div(): return {"object":"block","type":"divider","divider":{}}

# Lists
def bullet(*parts): return {"object":"block","type":"bulleted_list_item","bulleted_list_item":{"rich_text":list(parts)}}
def num(*parts): return {"object":"block","type":"numbered_list_item","numbered_list_item":{"rich_text":list(parts)}}

# Quote
def quote(*parts): return {"object":"block","type":"quote","quote":{"rich_text":list(parts)}}

# Table of contents
def toc(): return {"object":"block","type":"table_of_contents","table_of_contents":{"color":"default"}}
```

### Callout (colored box with emoji icon)

```python
def callout(emoji, rich_text, color="default", children=None):
    c = {"rich_text": rich_text, "icon": {"type":"emoji","emoji":emoji}, "color": color}
    if children: c["children"] = children
    return {"object":"block","type":"callout","callout":c}

# Colors: "default", "blue_background", "red_background", "yellow_background",
#          "green_background", "orange_background", "purple_background", "gray_background"
```

**Example:**
```python
callout("⚠️", [rt("Important: ", bold=True), rt("Don't forget this!")], "red_background")
```

### Toggle (collapsible content)

```python
def toggle(summary_parts, children):
    return {"object":"block","type":"toggle","toggle":{
        "rich_text": summary_parts,
        "children": children
    }}
```

**Example:**
```python
toggle([rt("Click to expand", bold=True)], [
    p(rt("Hidden content here")),
    bullet(rt("Item 1")),
    bullet(rt("Item 2")),
])
```

### Column Layout (side-by-side blocks)

This is the key pattern for visual comparisons — like the BWL page style.

```python
def column_list(col1_blocks, col2_blocks):
    return {
        "object": "block",
        "type": "column_list",
        "column_list": {
            "children": [
                {"object":"block","type":"column","column":{"children": col1_blocks}},
                {"object":"block","type":"column","column":{"children": col2_blocks}},
            ]
        }
    }
```

**3-column variant:**
```python
def column_list_3(col1, col2, col3):
    return {
        "object": "block",
        "type": "column_list",
        "column_list": {
            "children": [
                {"object":"block","type":"column","column":{"children": col1}},
                {"object":"block","type":"column","column":{"children": col2}},
                {"object":"block","type":"column","column":{"children": col3}},
            ]
        }
    }
```

**Example — comparison layout:**
```python
column_list(
    [  # Left column
        callout("📜", [rt("Concept A", bold=True)], "blue_background"),
        bullet(rt("Property 1")),
        bullet(rt("Property 2")),
    ],
    [  # Right column
        callout("🔑", [rt("Concept B", bold=True)], "orange_background"),
        bullet(rt("Property 1")),
        bullet(rt("Property 2")),
    ],
)
```

### Nested Children

Callouts, toggles, and column blocks support nested children (up to 2 levels):

```python
callout("📋", [rt("Parent callout", bold=True)], "green_background", children=[
    num(rt("Step 1", bold=True), rt(" — do this")),
    num(rt("Step 2", bold=True), rt(" — then this")),
    num(rt("Step 3", bold=True), rt(" — finally this")),
])
```

### Create Page with Icon

```python
api("POST", f"{BASE}/pages", {
    "parent": {"page_id": parent_id},
    "icon": {"type": "emoji", "emoji": "⚖️"},
    "properties": {
        "title": {"title": [{"text": {"content": "Page Title"}}]}
    },
    "children": blocks[:100]  # first 100 blocks
})
# Then append remaining with PATCH
```

## Common Patterns

### Study Notes Page (university style)

```python
blocks = [
    callout("💡", [rt("Key quote or motto", italic=True)], "purple_background"),
    p(),
    toc(),
    p(),
    h1("📐 Section Title"),
    div(),
    h2("Subsection"),
    div(),
    callout("⚖️", [rt("Definition: ", bold=True), rt("explanation...")], "blue_background"),
    p(),
    column_list(
        [callout("🔴", [rt("Concept A", bold=True)], "red_background"), ...],
        [callout("🟠", [rt("Concept B", bold=True)], "orange_background"), ...],
    ),
    p(),
    callout("📋", [rt("Checklist:", bold=True)], "green_background", children=[
        num(rt("Step 1", bold=True), rt(" — details")),
        num(rt("Step 2", bold=True), rt(" — details")),
    ]),
    p(),
    toggle([rt("Case Study", bold=True)], [
        callout("📝", [rt("Facts:", bold=True)], "gray_background", [p(rt("..."))]),
        callout("❓", [rt("Question: ", bold=True), rt("...")], "default"),
        toggle([rt("Solution", bold=True)], [...]),
        callout("✅", [rt("Result: ", bold=True), rt("...")], "green_background"),
    ]),
]
```

### Workflow

1. **Read** existing page: `notion read <id> --children` or API GET blocks
2. **Scan block IDs**: API GET children, parse JSON for IDs + types
3. **Build blocks**: Use Python helpers above
4. **Append/Insert**: PATCH children (with optional `after` for positioning)
5. **Rate limit**: 0.3-0.5s between requests, max 100 blocks per PATCH

### Gotchas

- **Max 100 blocks per PATCH** — batch in chunks
- **Max 2 nesting levels** — callout > bullet works, callout > callout > bullet doesn't
- **Rich text max 2000 chars** per segment — split long text into multiple paragraphs
- **Node fetch can timeout** on some networks — use Python `urllib` or `curl` as fallback
- **Block IDs needed for insert-after** — scan page children first via GET
- **Column blocks can't be nested** inside other columns
- **Emoji icons** only for callout and page icons, not headings
