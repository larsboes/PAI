# Full Session Workflow

Running the **FullSession** workflow in the **Brainstorm** skill for a complete brainstorming session...

## Overview

A complete brainstorming session from open question to concrete action. Runs through all phases with the user.

---

## Session Structure

```
Round 1: FRAME   → Understand the problem, clarify criteria
Round 2: DIVERGE → Generate wide range of ideas
Round 3: REACT   → User responds, you note patterns
Round 4: EXPLORE → Deep-dive on promising threads
Round 5: CONVERGE → Rank, recommend, decide
Round 6: ACT     → Concrete next steps
```

Rounds 3-5 may repeat multiple times. That's the point — iteration produces better thinking.

---

## Round 1: Frame the Problem

Before generating ideas, understand what you're solving:

1. **Restate the problem** in your own words (check understanding)
2. **Ask 2-3 framing questions:**
   - "What does success look like?"
   - "What constraints are non-negotiable?"
   - "What have you already considered or tried?"
3. **Identify the real question** (sometimes the stated problem isn't the actual problem)

Don't skip this. Bad framing → irrelevant ideas.

---

## Round 2: Diverge

→ Follow `Workflows/Diverge.md`

Generate 7-10 diverse ideas. Present them. Ask for reaction.

---

## Round 3+: React & Iterate

When the user responds:

1. **Note preferences** — What they liked (and WHY)
2. **Note rejections** — What they didn't like (and WHY — reveals criteria)
3. **Note questions** — What they're curious about (signals interest)
4. **Update state:**

```markdown
**Alive:** [Ideas still in play]
**Dropped:** [Rejected, with reason]
**Criteria revealed:** [What matters to them]
**Next:** [Explore deeper / Generate more / Converge]
```

5. **Decide next move:**
   - User wants more options → Generate more (Diverge again, different angle)
   - User wants depth on favorites → Explore those threads
   - User seems ready to decide → Suggest convergence
   - User is stuck/confused → Ask a clarifying question

---

## Round 4+: Explore

→ Follow `Workflows/Explore.md`

Go deep on 2-3 promising threads. Research, challenge, combine.

---

## Round 5+: Converge

→ Follow `Workflows/Converge.md`

Synthesize, rank, recommend. Get user to commit or redirect.

---

## Round 6: Act

Once committed:
- Break into concrete tasks
- Identify first action
- Create todos if appropriate
- Offer to start executing

---

## Session Management Rules

1. **Don't rush phases.** Stay in diverge/explore as long as it's productive.
2. **Do nudge if stuck.** If 4+ rounds of explore produce no new insight, suggest converging.
3. **Summarize between rounds.** Brief state update so nothing gets lost.
4. **User controls pace.** They decide when to go deeper or when to stop.
5. **Be opinionated.** You're a thinking partner, not a menu. Share your views.
6. **Track explicitly.** Keep a running list of what's alive, dead, and why.

---

## End Signals

The session ends when:
- User commits to an option → Transition to ACT
- User says "let me think about it" → Provide summary, offer to revisit
- User changes topic → Acknowledge the brainstorm state, move on
- The problem was reframed entirely → May need a fresh session
