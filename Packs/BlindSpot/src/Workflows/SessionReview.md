# SessionReview — Post-Session Blind Spot Check

End-of-session review: what did we miss in this conversation?

## When to Use

- End of a long session with many decisions
- After shipping something — quick retroactive check
- When the user asks "anything else?" or "what did we miss?"

## Process

### Step 1: Reconstruct What Happened
List the key decisions and actions taken this session (from conversation context).

### Step 2: Per-Decision Quick Lens

For each major decision/action, run the quick 5-lens check:
- Stakeholders: who's affected that we didn't discuss?
- Failure: what could break that we didn't test?
- Assumptions: what did we assume without verifying?
- Second-order: what downstream effect didn't we discuss?
- Temporal: what will need revisiting later?

### Step 3: Session-Level Gaps

Beyond individual decisions:
- Did we solve the *stated* problem or drift to a different one?
- Did we verify our work? Or just claim it works?
- Is there cleanup or follow-up we didn't discuss?
- Did we create technical debt we should document?
- Are there things we deferred that should be tracked?

## Output Format

```markdown
## 📋 Session Review — What Did We Miss?

### Decisions Made
1. [decision 1]
2. [decision 2]
...

### Gaps Found
- [gap 1 — which lens caught it]
- [gap 2]
- [gap 3]

### Follow-Up Items
- [ ] [thing to do next session]
- [ ] [thing to verify]
- [ ] [thing to revisit in N days/weeks]

### Verdict
[Clean session / Minor gaps — noted above / Significant gap — revisit X before proceeding]
```
