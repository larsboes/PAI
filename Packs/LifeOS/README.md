---
name: LifeOS
pack-id: larsboes-lifeos-v1.0.0
version: 1.0.0
author: larsboes
description: Life management workflows — learning paths, trip planning, periodic reviews, and inbox processing with Obsidian vault integration
type: skill
purpose-type: [life, productivity, obsidian, learning, travel, reviews]
platform: claude-code
dependencies: []
keywords: [learn, trip, review, inbox, obsidian, vault, daily, weekly, monthly]
---

# LifeOS

> Life management skills — structured learning, trip planning, periodic reviews, and inbox processing. Integrates with Obsidian vaults via `${VAULT_*}` env vars.

---

## Skills

| Skill | What It Does |
|-------|-------------|
| **learn** | Two-phase: design learning paths + build interactive HTML modules |
| **trip-planning** | Research, decision framework, vault notes, checklists for travel |
| **review-workflow** | Weekly/monthly/yearly review process with reflection prompts |
| **inbox** | Process accumulated vault inbox items with smart routing |

---

## Configuration

Skills reference vault paths via `${VAULT_*}` environment variables. Set these in your `.env`:

```bash
VAULT_PATH=~/path/to/your/vault
VAULT_DAILY_NOTES=Atlas/Daily Notes
VAULT_TEMPLATES=Resources/Templates
VAULT_INBOX=Resources/Inbox
# ... see pai-personal/.env for full list
```
