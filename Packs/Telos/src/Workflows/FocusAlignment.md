# FocusAlignment Workflow

Check life-focus-area alignment, surface neglected areas, and filter decisions against priorities. (Merged in from the former standalone `focus-alignment` skill.)

## Focus Areas

Focus notes live in `${VAULT_FOCUS}/`. For current status and priorities, load `${PROGRESSIVE_CURRENT}` first, then read the relevant focus note(s) — each contains priorities, vision, and action items.

## When to use

- User proposes a new project/commitment → run **Alignment Check**.
- User feels scattered/overwhelmed → run **Neglect Scan**.
- Weekly/monthly/yearly review (invoked by the `review-workflow` skill) → run **Balance Assessment**.
- User asks "should I do X?" → run **Decision Filter**.

## 1. Alignment Check

When the user proposes something new:

1. Which focus(es) does this serve? (name them)
2. Does it compete with higher current priorities? (check focus status in notes)
3. Honest assessment — e.g. *"Serves 2 focuses well. BUT you already have N active projects. Is this higher priority than [existing commitment]?"*

## 2. Neglect Scan

Flag focuses that haven't had attention:

1. Read each focus note's "reviewed" date.
2. Check for recent activity (projects, events, notes).
3. Flag focuses with: 30+ days since review, no active projects, or no upcoming commitments.

## 3. Balance Assessment

For reviews or when feeling off — rate each focus (1–5) on recent investment:

| Focus | Investment | Notes |
|-------|------------|-------|
| [Focus 1] | 4 | Active projects |
| [Focus 2] | 2 | Habits slipping |

→ Name the under-invested focuses explicitly.

## 4. Decision Filter

When facing a choice, ask:

1. Which focus does this serve?
2. Is that focus currently neglected or over-served?
3. What's the opportunity cost to other focuses?
4. Does it align with the current season/priorities?

Output: a clear recommendation with reasoning.

## Principles

- **Brutal honesty** — call out when something serves no focus.
- **Opportunity cost** — every yes is a no to something else.
- **Seasons matter** — some periods emphasize certain focuses; that's fine.
- **Progress not perfection** — not all focuses need equal attention always.
