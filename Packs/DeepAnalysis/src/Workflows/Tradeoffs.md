# Tradeoffs Workflow

Running the **Tradeoffs** workflow in the **DeepAnalysis** skill to map the tradeoff landscape...

## Overview

When facing multiple approaches/options, don't just list pros/cons. Map the full tradeoff landscape — what dimensions matter, where each option sits, what you gain AND lose with each choice, and what the non-obvious consequences are.

---

## When to Use

- "Should we use X or Y?"
- "What are the tradeoffs between these approaches?"
- "Help me compare these options"
- "What am I giving up if I choose X?"

**Note:** This is ANALYSIS, not decision-making. For decisions, use **Council**/Swarm after this analysis informs the picture. For brainstorming options, use **Brainstorm** first, then this to compare the finalists.

---

## Step 1: Define the Options Clearly

For each option, state in one sentence:
- What IS this approach? (not why it's good — just what it is)
- What does it optimize for? (its core bet)
- What does it sacrifice? (its core cost)

```markdown
| Option | What It Is | Optimizes For | Sacrifices |
|--------|-----------|---------------|------------|
| A | [description] | [core bet] | [core cost] |
| B | [description] | [core bet] | [core cost] |
| C | [description] | [core bet] | [core cost] |
```

---

## Step 2: Identify the Dimensions

What axes actually matter for this decision? Don't use generic dimensions — extract from context.

**Bad** (generic, unhelpful):
- Quality, Speed, Cost

**Good** (specific, revealing):
- Time-to-first-value, Long-term maintenance burden, Team learning curve, Vendor lock-in risk

### How to Find Dimensions
1. What did the user mention as important?
2. What do the options differ MOST on?
3. What would make someone regret a choice in 6 months?
4. What constraints are non-negotiable? (these aren't dimensions — they're filters)

Aim for 4-7 dimensions. Fewer = too shallow. More = noise.

---

## Step 3: Position Each Option

### Comparison Matrix

| Dimension | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| [Dim 1] | [How it performs] | ... | ... |
| [Dim 2] | ... | ... | ... |
| [Dim 3] | ... | ... | ... |
| [Dim 4] | ... | ... | ... |

Use specific, concrete assessments — not just "good/bad":
- ❌ "Good performance" 
- ✅ "~50ms p99 latency, scales linearly to 10K RPS"
- ❌ "Easy to use"
- ✅ "5-minute quickstart, but config becomes complex past basic use case"

---

## Step 4: Trace Second-Order Effects

For each option, ask: "If we choose this, what ELSE becomes true?"

```markdown
### Option A: Second-Order Effects
- **Team:** [How does this affect team skills, hiring, onboarding?]
- **Architecture:** [What does this lock in or preclude?]
- **Operations:** [What becomes easier/harder to operate?]
- **Evolution:** [What's the upgrade path? What happens in 2 years?]
- **Reversibility:** [How hard to switch away? What's the exit cost?]
```

---

## Step 5: Identify the Real Tradeoff

Often, a multi-option comparison boils down to 1-2 core tensions:

```markdown
### The Core Tradeoff

This decision is fundamentally about:

**[Short-term X] vs [Long-term Y]**

- Option A bets on [X]: [why that's compelling + when it fails]
- Option B bets on [Y]: [why that's compelling + when it fails]

The right choice depends on: [what condition makes X vs Y the right bet]
```

---

## Step 6: Produce the Analysis

```markdown
## Tradeoff Analysis: [Subject]

### Options at a Glance
| Option | Core Bet | Core Cost | Best When |
|--------|----------|-----------|-----------|
| A | ... | ... | [Scenario where A wins] |
| B | ... | ... | [Scenario where B wins] |

### Detailed Comparison
[Matrix from Step 3]

### Second-Order Effects
[Key consequences beyond the obvious for each option]

### The Core Tension
[What this really comes down to — 2-3 sentences]

### Non-Obvious Insights
- [Something not obvious from surface comparison]
- [A hidden risk or hidden benefit]
- [A combination/hybrid nobody considered]

### My Assessment
[Given what I know about your situation: where I'd lean and why.
 Be direct. Flag what I'm uncertain about.]
```

---

## Common Tradeoff Patterns in Software

| Pattern | Tension | Classic Manifestations |
|---------|---------|----------------------|
| Build vs Buy | Control + fit vs Speed + maintenance | Library vs framework, self-host vs SaaS |
| Monolith vs Distributed | Simplicity vs Scale independence | Monolith vs microservices, mono vs polyrepo |
| Strict vs Flexible | Safety + predictability vs Speed + adaptability | TypeScript strict vs loose, schema-first vs schema-last |
| Fast vs Right | Ship now vs Ship correctly | Prototype vs production code, quick hack vs proper design |
| Simple vs Complete | Easy to start vs Handles all cases | Minimal API vs full-featured, opinionated vs configurable |
