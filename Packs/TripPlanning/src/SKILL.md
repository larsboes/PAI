---
name: trip-planning
description: "Use when planning trips, conferences, travel, or events. Orchestrates research, note creation, and structured decision-making for travel."
---

# Trip Planning

Workflow for planning trips with structured research, decisions, and execution.

## When to Use

- User mentions upcoming trip or conference
- User forwards event invitations or travel info
- User wants to plan vacation, personal travel, or work travel
- User says "help me plan", "when should I go?", "what should I do?"

## Workflow

### 1. Clarify Context & Constraints

From system instructions and vault:
- Check your current schedule (google-calendar)
- Read system instructions for focus areas
- Check vault (`${VAULT_PROJECTS}/`, `${VAULT_EVENTS}/`) for ongoing work

Ask:
- **Purpose:** Work conference? Leisure? Mix? Specific events?
- **Dates:** Hard deadline or flexible?
- **Solo or group?** Impacts scheduling, cost, pacing
- **Work while there?** How many hours/day?
- **Budget:** Rough cap? Travel style preference?

### 2. Research the Trip

Use `references/research-brief.md` to structure research:
- Transport options (flights, trains, cost, time)
- Accommodation areas (neighborhoods, price, wifi/work setup)
- Events/activities (conferences, meetups, must-dos)
- Weather and practical logistics
- Your schedule constraints vs destination constraints

### 3. Make Decisions

Use `references/decision-framework.md`:
- Structure each decision (options → criteria → choice → deadline)
- Log decisions in a Decision Log (don't relitigate)
- Decide transport + dates first, activities later
- Key principle: **Once decided, don't bring it back up**

### 4. Create Vault Notes

Following obsidian-vault rules:
1. Read templates first
2. Create trip note in `${VAULT_TRIPS}/` (name: `YYYY-MM Location.md`)
3. Create event notes in `${VAULT_EVENTS}/` if specific events/conferences
4. Link between trip and events using `[[wikilinks]]`
5. Include decision log in trip note

### 5. Build Timeline & Checklists

Use `references/checklists.md`:
- Pre-trip checklist (bookings, registrations, notifications)
- Work setup (hours, timezone, coverage)
- Packing checklist
- Return checklist

For each action item: **Add a real deadline, not "soon"**

### 6. Itinerary

Block your time realistically:
- 20% buffer on all time estimates
- Mark work commitments clearly
- Include travel time between locations
- Don't over-schedule — leave 20% unplanned for serendipity

## Principles

- **Gather enough to decide** — Don't research forever
- **Decide quickly** — Most travel decisions are reversible
- **Plan loosely** — Detailed itinerary by day is overkill
- **Work constraints matter** — Be explicit about them
- **Treat decisions as final** — Don't relitigate once decided
- **Real deadlines** — Specific dates, not "soon"

## Red Flags

- Analysis paralysis → Gather 70% of info, decide now
- Over-scheduling → Leave 20% of time unplanned
- Ignoring work constraints → Will burnout
- Forgetting to budget time → Will rush
- No clear purpose → Trip will feel scattered

## References

- [research-brief.md](references/research-brief.md) — What to research: transport, accommodation, activities, weather, constraints
- [decision-framework.md](references/decision-framework.md) — How to structure decisions and decision logs cleanly
- [checklists.md](references/checklists.md) — Actionable checklists with real deadlines (pre-trip, bookings, packing, return)
