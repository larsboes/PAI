---
name: focus-alignment
description: Meta skill for life focus areas. Check alignment, surface neglected areas, connect work to priorities.
allowed-tools: Read, Glob
---

# Focus Alignment Skill

Meta skill for working with life focus areas.

## Focus Areas

Located in `${VAULT_FOCUS}/`. For current status and priorities, load `${PROGRESSIVE_CURRENT}`.

Read the user's focus area files to discover their specific focuses. Each focus note contains priorities, vision, and action items.

## When to Use

- User proposes a new project/commitment → check focus alignment
- User feels scattered or overwhelmed → which focuses are neglected?
- Planning period (weekly/monthly) → balance check across focuses
- User asks "should I do X?" → evaluate against focus priorities

## Workflows

### 1. Alignment Check

When user proposes something new:

```
User: "I'm thinking of starting a blog"

1. Which focus(es) does this serve?
   → [Career focus] (public presence)
   → [Learning focus] (crystallize learning)

2. Does it compete with higher priorities?
   → Check current focus status in notes

3. Honest assessment:
   → "Serves 2 focuses well. BUT: you already have 17 projects.
      Is this higher priority than [existing commitment]?"
```

### 2. Neglect Scan

Check which focuses haven't had attention:

```
1. Read each focus note's "reviewed" date
2. Check for recent activity (projects, events, notes)
3. Flag focuses with:
   - 30+ days since review
   - No active projects
   - No upcoming events/commitments
```

### 3. Balance Assessment

For reviews or when feeling off:

```
Rate each focus (1-5) on recent investment:

| Focus | Investment | Notes |
|-------|------------|-------|
| [Focus 1] | 4 | Active projects |
| [Focus 2] | 5 | Strong momentum |
| [Focus 3] | 2 | Habits slipping |
| [Focus 4] | 3 | Some attention |
| [Focus 5] | 1 | Neglected |

→ "[Focus 3] and [Focus 5] are underinvested"
```

### 4. Decision Filter

When facing a choice:

```
Questions to ask:
1. Which focus does this serve?
2. Is that focus currently neglected or over-served?
3. What's the opportunity cost to other focuses?
4. Does this align with current season/priorities?

Output: Clear recommendation with reasoning
```

## Integration Points

- **review-workflow**: Balance assessment during reviews
- **application-writer**: Check if opportunity fits focus priorities
- **learning-planner**: Align learning with relevant focus area goals
- **trip-planning**: Check Experiences focus, balance with other commitments

## Principles

- **Brutal honesty**: Call out when something doesn't serve any focus
- **Opportunity cost**: Everything you say yes to means no to something else
- **Seasons matter**: Some periods emphasize certain focuses - that's okay
- **Progress not perfection**: Not all focuses need equal attention always

## Reading the Focus Notes

Each focus note contains:
- Current priorities/projects
- Vision and why it matters
- Action items
- Links to related projects

Before advising, load `${PROGRESSIVE_CURRENT}` for quick status, then read the relevant focus note(s) from `${VAULT_FOCUS}/` for full current context.
