---
name: zotero
description: Zotero citation library — search items, get metadata, and retrieve full-text content from PDFs/documents via the Zotero Web API.
---

# Zotero Skill

Access your Zotero library via the Web API. Reads credentials from `~/.env`.

## Config (`~/.env`)

```env
ZOTERO_API_KEY=your-api-key
ZOTERO_LIBRARY_ID=your-library-id
```

## Tools

### zotero_search
Search items by keyword. Returns titles, authors, keys, item types.

```bash
curl -s -H "Zotero-API-Key: $ZOTERO_API_KEY" \
  "https://api.zotero.org/users/$ZOTERO_LIBRARY_ID/items?q={query}&limit=10&format=json" \
  | python3 -c "
import sys, json
items = json.load(sys.stdin)
for i in items:
    d = i['data']
    authors = ', '.join(c.get('lastName','') for c in d.get('creators',[])[:2])
    print(f\"[{i['key']}] {d.get('title','?')} — {authors} ({d.get('date','')[:4]})\")
"
```

### zotero_metadata
Get full metadata for a specific item by key.

```bash
curl -s -H "Zotero-API-Key: $ZOTERO_API_KEY" \
  "https://api.zotero.org/users/$ZOTERO_LIBRARY_ID/items/{item_key}?format=json" \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)['data']
print(json.dumps({k: d[k] for k in ['title','creators','date','abstractNote','DOI','url','tags','itemType'] if k in d}, indent=2))
"
```

### zotero_fulltext
Get full-text content of an item's PDF attachment (if indexed by Zotero).

```bash
curl -s -H "Zotero-API-Key: $ZOTERO_API_KEY" \
  "https://api.zotero.org/users/$ZOTERO_LIBRARY_ID/items/{item_key}/children?format=json" \
  | python3 -c "
import sys, json
children = json.load(sys.stdin)
for c in children:
    if c['data'].get('itemType') == 'attachment':
        key = c['key']
        print(f'Attachment key: {key}')
"
# Then fetch fulltext:
# curl -s -H "Zotero-API-Key: $ZOTERO_API_KEY" \
#   "https://api.zotero.org/users/$ZOTERO_LIBRARY_ID/items/{attachment_key}/fulltext"
```

### zotero_collections
List all collections in the library.

```bash
curl -s -H "Zotero-API-Key: $ZOTERO_API_KEY" \
  "https://api.zotero.org/users/$ZOTERO_LIBRARY_ID/collections?format=json" \
  | python3 -c "
import sys, json
cols = json.load(sys.stdin)
for c in cols:
    print(f\"[{c['key']}] {c['data']['name']}\")
"
```

### zotero_collection_items
Get items in a specific collection.

```bash
curl -s -H "Zotero-API-Key: $ZOTERO_API_KEY" \
  "https://api.zotero.org/users/$ZOTERO_LIBRARY_ID/collections/{collection_key}/items?format=json&limit=25" \
  | python3 -c "
import sys, json
items = json.load(sys.stdin)
for i in items:
    d = i['data']
    print(f\"[{i['key']}] {d.get('title','?')}\")
"
```
