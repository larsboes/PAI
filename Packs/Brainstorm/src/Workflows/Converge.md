# Converge Workflow

Running the **Converge** workflow in the **Brainstorm** skill to synthesize and reach a decision...

## Overview

The exploration is done. Now synthesize everything into a clear recommendation. Rank options, surface tradeoffs, stress-test the favorite, and help the user commit.

---

## Step 1: Summarize the Journey

Briefly recap what was explored:

```markdown
## Brainstorm Summary

**Started with:** [Original question/problem]
**Explored:** [N ideas across M rounds]
**Dropped:** [Ideas rejected and why — this reveals criteria]
**Still alive:** [2-3 remaining options]
**User's criteria (revealed):** [What they're actually optimizing for]
```

---

## Step 2: Comparison Matrix

Make the decision visual:

```markdown
| Criteria | Option A | Option B | Option C |
|----------|----------|----------|----------|
| [User's top priority] | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| [Second priority] | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| [Third priority] | ⭐ | ⭐⭐ | ⭐⭐⭐ |
| Effort/Cost | [Low/Med/High] | ... | ... |
| Risk | [What could go wrong] | ... | ... |
```

---

## Step 3: Stress-Test the Favorite

If a clear favorite has emerged, challenge it:

**Quick stress-test (do this always):**
- "What's the one thing that would make this fail?"
- "What are you giving up by choosing this?"
- "In 3 months, what might you regret about this choice?"

**Full stress-test (for important decisions):**
- Invoke **RedTeam** on the top choice
- Or `/swarm quick "Should we go with [option]? Concerns?"` for multi-perspective

---

## Step 4: Clear Recommendation

Don't hedge. Make a recommendation with reasoning:

```markdown
## Recommendation

**Go with: [Option X]**

**Why:** [2-3 sentences. What makes this the best fit for YOUR criteria.]

**Main risk:** [The biggest thing that could go wrong]
**Mitigation:** [How to reduce that risk]

**What you're giving up:** [Be honest about the tradeoff]
**Why that's acceptable:** [Why the tradeoff is worth it given your priorities]
```

---

## Step 5: Decision Point

Ask the user to commit or redirect:

> "This is my recommendation. Three options:
> 1. ✅ Commit — I'll break this into action steps
> 2. 🔄 Explore more — Tell me what's not sitting right
> 3. ↩️ Restart — We're asking the wrong question"

---

## If User Commits → Transition to ACT

Break the decision into concrete next steps:

```markdown
## Next Steps

1. **First action (do now):** [Smallest concrete step]
2. **This week:** [2-3 follow-up actions]
3. **Decide later:** [Questions that don't need answers yet]
4. **Watch for:** [Signals that the approach isn't working]
```

Create todos if the user wants task tracking.

---

## If User Hesitates

Common hesitation patterns and responses:

| Signal | Response |
|--------|----------|
| "I'm not sure..." | "What specifically doesn't feel right? Let's name it." |
| "What about [new angle]?" | Back to Explore for that specific thread |
| "Can we do both?" | "Here's what a hybrid looks like: [sketch]. Tradeoff: [complexity]." |
| "I need to think about it" | "Makes sense. Here's a summary to come back to: [brief recap]." |
| "What would you do?" | Give a direct opinion with reasoning. Don't dodge. |
