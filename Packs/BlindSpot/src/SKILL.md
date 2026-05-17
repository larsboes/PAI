---
name: BlindSpot
description: "Surface what was missed, unconsidered, or assumed in any decision, design, or plan — five lenses: Stakeholders, Failure Modes, Assumptions, Second-Order Effects, Temporal. USE WHEN what did we miss, blind spot, what didn't we consider, premortem, assumption check, second-order effects, failure modes, sanity check before shipping."
---

# BlindSpot — What Didn't We Consider?

Structured blind spot analysis for decisions, designs, plans, and completed work. Surfaces what was missed, unconsidered, or implicitly assumed.

## When to Use

- After completing a design or plan (before committing)
- When a decision feels "too clean" — suspiciously few tradeoffs
- Before shipping — final sanity check
- When you can't name what's bothering you about a solution
- After any multi-step session — "what did we miss?"

## The Five Lenses

| Lens | Core Question | Surfaces |
|------|---------------|----------|
| **Stakeholders** | Who wasn't consulted? Who's affected but silent? | Missing perspectives, political risk, adoption barriers |
| **Failure Modes** | What breaks first? What's the weakest link? | Single points of failure, untested paths, error cascades |
| **Assumptions** | What are we taking for granted? | Implicit dependencies, market conditions, team capability |
| **Second-Order** | What happens *after* the first effect? | Unintended consequences, feedback loops, behavioral shifts |
| **Temporal** | What changes in 6mo / 2yr / 5yr? | Decay, scaling limits, tech shifts, life changes |

## Workflow Routing

| Pattern | Workflow |
|---------|----------|
| Quick check before committing | `Workflows/QuickScan.md` |
| Deep analysis of a completed design | `Workflows/DeepScan.md` |
| Post-session "what did we miss today?" | `Workflows/SessionReview.md` |

## Integration with Other Skills

- **After RedTeam**: RedTeam attacks the argument. BlindSpot finds what was *never argued*.
- **After IterativeDepth**: ID surfaces requirements from multiple lenses. BlindSpot asks "which lenses were missing?"
- **After FirstPrinciples**: FP challenges assumptions explicitly. BlindSpot finds the *unexamined* assumptions.
- **After Council**: Council debates paths. BlindSpot asks "what paths were never raised?"

## Output Format

```markdown
## Blind Spot Analysis: [subject]

### 🔍 Lens Results

**Stakeholders** — [who was missed]
**Failure Modes** — [what breaks]
**Assumptions** — [what's implicit]
**Second-Order** — [downstream effects]
**Temporal** — [what decays or shifts]

### ⚠️ Top 3 Gaps (ranked by impact)
1. [highest-impact blind spot]
2. [second]
3. [third]

### → Recommended Actions
- [concrete next step for each gap]
```
