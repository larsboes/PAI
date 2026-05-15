---
name: daily
description: "Open today's daily note with rich context - priorities, calendar, patterns to watch, and unfinished business from yesterday."
allowed-tools: Read, Write, Glob, Bash(gccli *)
---

# /daily — Daily Briefing

Opens today's daily note and provides a context-rich daily briefing with recent history, calendar, and active themes.

## Process

### 1. Check/Create Today's Note

- Path: `${VAULT_DAILY_NOTES}/YYYY-MM-DD.md`
- If missing: Read `${VAULT_DAILY_TEMPLATE}`, then create from template
- If exists: Read current content

### 2. Yesterday's Carryover

Read yesterday's daily note (or the most recent one if yesterday is missing):
- Check the **Tomorrow > Top 3** section — these carry forward as today's starting priorities
- Check **Wins & Challenges** for ongoing blockers
- Note any unfinished threads or open questions

### 3. Calendar Check

Use the `google-calendar/list-events` MCP tool to pull:
- **Today's events** with times and locations
- **Tomorrow's events** (for prep awareness)

Also check `${VAULT_EVENTS}/` for any vault event notes matching this week — they may have prep notes, goals, or agendas that the calendar doesn't capture.

### 4. Active Themes

Load `progressive-context` skill for:
- Read `${PROGRESSIVE_CURRENT}` for active emotional themes and work context
- Pick one pattern from `${PROGRESSIVE_PATTERNS}` to watch for today (rotate — don't always suggest the same one)

### 5. Present the Briefing

Output a concise summary (not a wall of text):

```markdown
## Today: YYYY-MM-DD (Day of Week)

### Carried Over
- [Unfinished items from yesterday's Tomorrow section]
- [Open blockers]

### Today's Schedule
- HH:MM — [Event/meeting]
- [Events from calendar + vault event notes]

### Active Themes
- [From current-context.md — what's on the user's mind this period]

### Pattern to Watch Today
- [One pattern from patterns-index.md with a brief reminder]

### Suggested Focus
- [Based on priorities, deadlines, and what's been happening]
- [Flag anything time-sensitive]
```

### 6. Daily Note State

If the daily note already has content:
- Summarize what's there rather than duplicating
- Highlight which sections are still empty (prompt to fill later or via `/brain-dump`)

If the daily note is fresh/empty:
- Don't pre-fill sections — that's for brain-dump or manual entry
- Just present the briefing and offer: "Want to `/brain-dump` anything to start the day?"

## Integration

- **progressive-context**: Loaded for themes and pattern suggestion
- **brain-dump**: Offer as follow-up if the user wants to process thoughts
- **google-calendar MCP**: For real-time calendar data
- **review-workflow**: During review weeks, flag that a review is due

## Important

- Keep the briefing **concise** — scannable, not a lecture
- **Flag time-sensitive items** prominently
- If yesterday had heavy emotional content, acknowledge it briefly ("Yesterday was intense — how are you today?")
- Don't pre-fill the daily note — the briefing is separate from the journal
- This skill **replaces** the old `/daily` command with richer functionality
