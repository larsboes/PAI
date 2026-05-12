# Explore Workflow

Running the **Explore** workflow in the **Brainstorm** skill to go deeper on promising threads...

## Overview

The user has reacted to ideas from the diverge phase. Now go DEEP on the ones that resonated. Challenge them, combine them, research feasibility, and surface what's hidden beneath the surface.

---

## Inputs

From the diverge phase (or user's direction):
- **Promising ideas:** Which ones the user liked or was curious about
- **Rejection reasons:** WHY they didn't like others (reveals hidden criteria)
- **Questions raised:** What the user is uncertain about

---

## Exploration Techniques

### 1. Feasibility Deep-Dive

For each promising idea, answer:
- **Can we actually do this?** (Technical feasibility)
- **What would it take?** (Resources, time, dependencies)
- **What's the hardest part?** (Identify the risk)
- **Has someone done this before?** (Use `code_search`, `web_search`)

### 2. Assumption Challenge

Invoke **FirstPrinciples** thinking:
- "What would need to be true for this to work?"
- "What are we assuming about [user behavior / technology / market]?"
- "Is this constraint real or inherited?"

### 3. Combination Experiments

Try merging ideas:
- "What if we took Idea 2's approach but with Idea 5's simplicity?"
- "Could we START with Idea 1 and EVOLVE toward Idea 4?"
- "What's the minimal version that captures the essence of Idea 3?"

### 4. Probing Questions

Ask the user questions that reveal deeper thinking:
- "What would make you nervous about committing to this?"
- "If this succeeded perfectly, what does it look like in 6 months?"
- "What's the one thing that would kill this idea?"
- "Is this solving the problem or is it solving a symptom?"

### 5. Tradeoff Surfacing

For the top 2-3 ideas, make tradeoffs explicit:

```markdown
| Idea | You Gain | You Lose | Biggest Risk |
|------|----------|----------|--------------|
| A    | Speed    | Flexibility | Lock-in |
| B    | Quality  | Time     | Over-engineering |
| C    | Learning | Speed    | Not shipping |
```

---

## Research When Needed

If feasibility is unclear:
- `code_search "pattern/library/approach"` — Find working examples
- `web_search "approach + constraints"` — Find case studies, pitfalls
- Check existing codebase — `rg "similar pattern"` — leverage what exists

Share findings with the user:
> "I looked into [X]. Here's what I found: [evidence]. This changes the picture because [insight]."

---

## Output Format

After exploring, present a synthesis:

```markdown
## Exploration Summary

### [Idea A] — Deeper Look
- **Feasibility:** [High/Medium/Low] — because [reason]
- **Key insight:** [Something non-obvious discovered during exploration]
- **Main risk:** [What could go wrong]
- **Would need:** [Resources/prerequisites]

### [Idea B] — Deeper Look
...

### New Direction: [Hybrid/New Idea]
- Emerged from combining [X] and [Y]: [Description]

---

**What changed:** [How has the landscape shifted from what we knew before?]
**Open question:** [The key question we still need to answer]
**My lean:** [Where I think this is heading, tentatively]

Want to explore further, or ready to converge?
```

---

## Phase Transition Signals

**Stay in Explore when:**
- User has new questions
- A combination idea emerged that needs development
- Feasibility is still unclear on the top option

**Move to Converge when:**
- User says "ok let's decide" or "which should we pick?"
- A clear favorite has emerged with known tradeoffs
- Exploration is producing diminishing returns (same insights repeating)

**Push back if:**
- User wants to converge but hasn't explored tradeoffs: "Before we commit, let me surface what you'd be giving up."
- Only one idea was explored: "We've gone deep on A but haven't stress-tested it against B. Worth 2 minutes?"
