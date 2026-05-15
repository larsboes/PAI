---
name: pai-memory
description: "Unified memory system. Static context (identity, patterns, relationships) + semantic markdown search + knowledge graph. Use when loading context, searching past sessions, storing new facts, or querying entity relationships."
user-invocable: true
argument-hint: "[search query | add <text> | graph <command>]"
---

# Memory

Three-layer memory system. Loads context progressively — don't pre-load everything.

---

## Layer 1: Static Context (Always Available)

Load personal context from `${VAULT_PATH}/${VAULT_PERSONAL}/PERSONAL_CONTEXT.md`. This contains:
- Identity (name, age, location, education, role, timeline, stack)
- Career goals and target path
- Focus areas and life priorities
- Key people and relationships
- Behavioral patterns to flag (with signals and responses)
- Communication style and interaction rules
- Language preferences

For the full pattern index: read `${PROGRESSIVE_PATTERNS}`
Full relationships index: `${PROGRESSIVE_RELATIONSHIPS}`

---

## Layer 2: Progressive Disclosure

Load supporting files only when the conversation touches that area:

| Conversation touches | Load |
|---------------------|------|
| Emotional processing, brain-dump | `${PROGRESSIVE_PATTERNS}` → relevant `${VAULT_REFLECTIONS}/` files |
| A specific person | Their `${VAULT_PEOPLE}/` note |
| Career or life decisions | Relevant `${VAULT_FOCUS}/` note |
| Planning, reviews, "what's happening" | `${PROGRESSIVE_CURRENT}` |
| Creating notes or navigating vault | `${PROGRESSIVE_VAULT_STRUCTURE}` |

Never pre-load everything. Only load what the conversation needs.

---

## Layer 3: Semantic Search (Markdown Memory)

Full-text + vector search over `~/.pai/memory/`.

```bash
# Search past context
cd ~/.pai/memory && node ${PAI_SKILLS_DIR}/memory-manager/src/cli.js search "<query>"

# Add to long-term memory
cd ~/.pai/memory && node ${PAI_SKILLS_DIR}/memory-manager/src/cli.js add "<text>"

# Add to today's daily log
cd ~/.pai/memory && node ${PAI_SKILLS_DIR}/memory-manager/src/cli.js add --daily "<text>"

# Read a memory file
cd ~/.pai/memory && node ${PAI_SKILLS_DIR}/memory-manager/src/cli.js get <filename>
# Files: MEMORY.md, IDENTITY.md, USER.md, daily/YYYY-MM-DD.md

# List all memory files
cd ~/.pai/memory && node ${PAI_SKILLS_DIR}/memory-manager/src/cli.js list

# Check status
cd ~/.pai/memory && node ${PAI_SKILLS_DIR}/memory-manager/src/cli.js status
```

**Storage:** `~/.pai/memory/` — MEMORY.md, IDENTITY.md, USER.md, `daily/YYYY-MM-DD.md`

---

## Layer 4: Knowledge Graph (Structured Entities)

For complex relational queries — people, projects, connections across time.

```bash
# Create entity
ai-memory graph entity "MyProject" "project"

# Add observation
ai-memory graph observe "MyProject" "Started 2025-01, Status: active"

# Create relation
ai-memory graph relate "User_Name" "works_on" "MyProject"

# Search graph
ai-memory graph search "AI projects"

# Multi-hop query
ai-memory graph query --type person --relation works_on --target-type project

# Read full graph
ai-memory graph read
```

**Storage:** `~/.pai/memory/graph/memory.jsonl`

---

## Routing: When to Use Which Layer

| Need | Layer |
|------|-------|
| Understand who the user is, flag patterns | Layer 1 (static) |
| "What did we discuss about X?" | Layer 3 (semantic search) |
| "What's in my daily log?" | Layer 3 (daily) |
| "What projects am I working on?" | Layer 4 (graph search) |
| Track a new person with multiple facts | Layer 4 (graph entity) |
| Save a quick fact or preference | Layer 3 (add) |
| Complex: "Who connected to AI started in 2024?" | Layer 4 (graph query) |
| Active life context right now | Layer 2 → `current-context.md` |
