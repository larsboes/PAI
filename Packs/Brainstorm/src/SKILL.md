---
name: Brainstorm
description: "Iterative collaborative ideation with the user — diverge, explore, converge, act. Multi-round sessions that build on reactions and push past surface-level thinking. Use when thinking through ideas together, exploring options, or designing solutions collaboratively."
---

# Brainstorm — Iterative Collaborative Thinking

**Not one-shot answers. Build ideas together across rounds. Push for depth. Challenge premature convergence.**

This skill runs a multi-round ideation session where you and the user think together. Each round builds on the previous — reactions, challenges, new angles, deeper exploration. The goal is better thinking through iteration, not a perfect answer on the first try.

---

## Core Philosophy

```
One-shot: User asks → Agent answers → Done (often shallow)
Brainstorm: User asks → Ideas → User reacts → Deeper → User steers → Converge → Act
```

**Push back.** If the user converges too early, say so. If they're stuck in one frame, offer another. If an idea needs stress-testing, do it before they commit.

**Track state.** Know what's on the table, what's been rejected, what's promising. Summarize between rounds.

---

## Workflow Routing

| Trigger | Workflow |
|---------|----------|
| Open-ended ideation, exploring possibilities | `Workflows/Diverge.md` |
| Deep-dive on a specific thread, feasibility check | `Workflows/Explore.md` |
| Ready to decide, need to synthesize and rank | `Workflows/Converge.md` |
| Full session (all phases) | `Workflows/FullSession.md` |

---

## The Session Flow

```
┌─────────────────────────────────────────────────────────┐
│  DIVERGE — Expand the possibility space                 │
│  • Generate many ideas (quantity > quality)             │
│  • No judgment yet                                      │
│  • Use BeCreative for diversity                         │
│  • Cross-domain analogies, wild ideas welcome           │
│  → Present 5-10 options, ask user to react              │
└────────────────────────┬────────────────────────────────┘
                         ↓ user reacts (likes, dislikes, questions)
┌─────────────────────────────────────────────────────────┐
│  EXPLORE — Go deeper on promising threads               │
│  • Research feasibility of top ideas                    │
│  • Challenge assumptions (FirstPrinciples)              │
│  • Combine ideas — what if X + Y?                       │
│  • Ask probing questions back to user                   │
│  → Surface tradeoffs, constraints, new angles           │
└────────────────────────┬────────────────────────────────┘
                         ↓ user steers (picks direction, adds constraints)
┌─────────────────────────────────────────────────────────┐
│  CONVERGE — Synthesize and rank                         │
│  • Rank remaining options by user's criteria            │
│  • Stress-test top pick (invoke RedTeam if needed)      │
│  • Identify risks and mitigations                       │
│  • Present clear recommendation with reasoning          │
│  → User decides (or requests another round)             │
└────────────────────────┬────────────────────────────────┘
                         ↓ user commits
┌─────────────────────────────────────────────────────────┐
│  ACT — Turn decision into concrete next steps           │
│  • Break into tasks/todos                               │
│  • Identify first action                                │
│  • Flag open questions for later                        │
└─────────────────────────────────────────────────────────┘
```

**The user controls phase transitions.** Don't rush to converge. Stay in diverge/explore as long as the user is finding value there. But DO nudge if they're looping without progress.

---

## Behaviors Per Phase

### During DIVERGE
- Generate at least 5-8 genuinely different ideas (not variations of the same idea)
- Include at least 1 "wild" idea that breaks assumptions
- Use **BeCreative** (verbalized sampling) for diversity
- Present as a numbered list with 1-2 sentence descriptions
- End with: "What catches your eye? What's missing?"

### During EXPLORE
- Go deep on 2-3 threads the user reacted to
- Research feasibility: `code_search`, `web_search` if needed
- Challenge: "What would need to be true for this to work?"
- Combine: "What if we took X's approach but with Y's constraint?"
- Ask probing questions: "What's the real constraint here?" / "What would change if [X]?"
- End with: "Here's what I've found. Does this change your thinking?"

### During CONVERGE
- Synthesize: Create a comparison table (options × criteria)
- Rank explicitly with reasoning
- Stress-test the top pick (invoke **RedTeam** for important decisions)
- Present: "My recommendation is X because [reasons]. The main risk is [Y]."
- End with: "Ready to commit, or want to explore further?"

### During ACT
- Break the decision into concrete tasks
- Identify the FIRST action (smallest step to start)
- Create todos if appropriate
- Flag questions that will need answers later
- "Here's the plan. Want me to start with [first action]?"

---

## Push-Back Patterns

When to challenge the user (respectfully):

| Signal | Push-Back |
|--------|-----------|
| Converging too early (< 3 ideas explored) | "We've only explored one direction. Let me offer 2-3 more before we commit." |
| Stuck in one frame | "You keep coming back to [X]. What if we approached this from [different angle]?" |
| Ignoring tradeoffs | "That approach is strong on [A] but what about [B]? Is that acceptable?" |
| Analysis paralysis (5+ rounds, no progress) | "We've been exploring for a while. Let me summarize what we know and force-rank." |
| Vague criteria | "What does 'good' look like here? Help me understand what you're optimizing for." |
| Solution before problem | "What's the actual problem we're solving? Let's nail that before picking solutions." |

---

## Between-Round Summaries

After each user response, briefly surface the state:

```markdown
**On the table:** [Ideas still alive]
**Dropped:** [Ideas rejected and why]
**Emerging favorite:** [If one is pulling ahead]
**Open questions:** [What we still need to figure out]
```

Keep this short (3-5 lines). It's a checkpoint, not a report.

---

## Integration Points

| Need | Invoke |
|------|--------|
| Divergent ideation (quantity, diversity) | **BeCreative** (verbalized sampling) |
| Multi-perspective evaluation | **Council** or **Swarm** (`/swarm quick`) |
| Stress-test a favorite | **RedTeam** (find fatal flaws before committing) |
| Feasibility check | `code_search`, `web_search`, **Research** |
| Assumption challenging | **FirstPrinciples** |
| Deep technical problem embedded in brainstorm | **DeepDebug** (switch modes) |

---

## Anti-Patterns

| Bad | Good |
|-----|------|
| One-shot answer with 10 ideas, no follow-up | Present ideas, ask for reaction, iterate |
| All ideas are variations of the same approach | Use BeCreative, force cross-domain thinking |
| Let user converge on first idea without exploring | Push back: "Let's explore 2 more directions first" |
| Endless exploration with no synthesis | After 3-4 rounds, nudge toward convergence |
| Generic ideas without user's context | Ask clarifying questions early: "What matters most to you here?" |
| Treat brainstorm as decision-making | Brainstorm expands; Council/Swarm decides |

---

## Output Contract

- **Always produces:** Ideas that build across rounds (not reset each time)
- **Between rounds:** Brief state summary (what's alive, what's dropped, open questions)
- **At convergence:** Ranked options with reasoning + clear recommendation
- **At action:** Concrete next steps / todos
- **Never:** One-shot dump of ideas with no iteration
