---
name: inbox
description: "Process accumulated items in Inbox - smart categorization and routing with vault awareness."
allowed-tools: Read, Write, Glob
---

# /inbox — Process Inbox Items

Helps process accumulated items in the Inbox folder with vault-aware routing.

## Process

### 1. Scan the Inbox

List all items in `${VAULT_INBOX}/`. For each item, identify:
- **What is it?** (link, idea, task, reference, event, resource)
- **Is it still relevant?** (some items go stale)
- **Where does it belong?**

### 2. Load Context for Smart Routing

Read `${PROGRESSIVE_VAULT_STRUCTURE}` for routing destinations.
Read `${PROGRESSIVE_CURRENT}` for active projects — items may belong to existing projects.

### 3. Process Each Item

For each item, suggest one of:

| Item Type | Destination | Action |
|-----------|------------|--------|
| Link/URL | `${VAULT_LINK_LIBRARY}` or new Resource note | Add to library or create note |
| Idea | Proper folder based on type | Create structured note from template |
| Task | `${VAULT_TASKS}/` or daily note | Create task note or add to today's tasks |
| Reference | `${VAULT_RESOURCES}/` | Create Resource note with template |
| Event | `${VAULT_EVENTS}/` | Create Event note from template |
| Project idea | `${VAULT_PROJECTS}/` | Create Project note from template |
| Person info | `${VAULT_PEOPLE}/` | Create or update People note |
| Stale/irrelevant | Delete | Confirm with user, then remove |

**Present items in batches** (3-5 at a time), not all at once. Let the user decide before moving to the next batch.

### 4. Execute Decisions

For each decision:
- Read the relevant template before creating any new note
- Follow naming conventions from `${PROGRESSIVE_VAULT_STRUCTURE}`
- Use `[[wikilinks]]` to connect new notes to existing vault content
- If creating an event note, check if it belongs to an existing trip

### 5. Summary

After processing, report:
```
Processed: X items
  → Moved to [locations]: N items
  → Created new notes: N items
  → Discarded: N items
  → Remaining in Inbox: N items
```

## Principles

- **Batch processing** — don't overwhelm with all items at once
- **User decides** — suggest routing, don't auto-route
- **Connect to context** — if an item relates to an active project, say so
- **Templates first** — always read template before creating structured notes
- **Stale is OK** — not everything captured needs to become a note. Discarding is a valid outcome.

## Integration

- **progressive-context**: For vault structure and active project awareness
- **daily**: Run `/daily` first to see today's context, then `/inbox` to process
- **trip-planning**: If inbox items are trip-related, suggest using trip-planning skill instead
