# QuickScan — Fast Blind Spot Check

30-second check before committing to a decision or shipping work.

## Input

The decision, design, or plan to scan. Can be implicit (current conversation context) or explicit.

## Process

Run through all five lenses rapidly — one sentence per lens:

1. **Stakeholders**: Name one person/group affected who wasn't consulted.
2. **Failure Modes**: Name the single most likely failure point.
3. **Assumptions**: Name one thing we're assuming that might not be true.
4. **Second-Order**: Name one downstream consequence we haven't discussed.
5. **Temporal**: Name one thing that changes about this in 12 months.

## Output

```markdown
## ⚡ Quick Blind Spot Scan

| Lens | Gap |
|------|-----|
| Stakeholders | [one sentence] |
| Failure Modes | [one sentence] |
| Assumptions | [one sentence] |
| Second-Order | [one sentence] |
| Temporal | [one sentence] |

**Verdict:** [SHIP / PAUSE — address X first / RETHINK — fundamental gap found]
```

## Behavior

- If all five lenses return nothing concerning → "SHIP — no significant blind spots detected"
- If 1-2 lenses flag something → "PAUSE — address before committing"
- If 3+ lenses flag → "RETHINK — too many unconsidered angles"
- Be honest. "I don't see gaps" is valid. Don't manufacture concern for completeness.
