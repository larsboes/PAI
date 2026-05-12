# DeepScan — Comprehensive Blind Spot Analysis

Full structured analysis of what was missed, unconsidered, or implicitly assumed.

## Input

A completed design, decision, plan, architecture, or strategy to analyze.

## Process

### Step 1: Restate the Subject
Summarize what was decided/designed in 2-3 sentences. This anchors the analysis.

### Step 2: Five-Lens Deep Scan

For each lens, spend real time thinking. Don't settle for the obvious answer.

**Stakeholders**
- Who benefits from this? Who loses?
- Who was consulted? Who wasn't but should have been?
- Whose workflow changes? Who has to maintain this?
- Who can block adoption? Who needs to approve?
- Is there anyone downstream who'll be surprised?

**Failure Modes**
- What's the single point of failure?
- What happens if the happy path doesn't happen?
- What's the error recovery path?
- What breaks under 10x scale?
- What breaks if a key person leaves?
- What's the "2am on Saturday" scenario?

**Assumptions**
- What technical assumptions are implicit? (availability, latency, compatibility)
- What people assumptions? (skill level, motivation, availability)
- What market/environment assumptions? (pricing stays same, tool stays maintained, API stays available)
- What sequencing assumptions? (X happens before Y)
- Which assumptions, if wrong, invalidate the entire approach?

**Second-Order Effects**
- If this succeeds, what changes next?
- What incentives does this create?
- What does this make easier that might be problematic?
- What behavior will users/systems develop in response?
- What adjacent systems are affected?

**Temporal**
- What's the maintenance burden in 6 months?
- What technology shifts could obsolete this in 2 years?
- Does this scale to where we'll be in 12 months?
- What's the migration cost if we need to change this later?
- What decisions does this lock in?

### Step 3: Rank and Prioritize

From all findings, select the top 3 gaps ranked by:
1. **Impact** — how bad if this blind spot materializes?
2. **Probability** — how likely is it?
3. **Addressability** — can we do something about it now?

### Step 4: Recommend Actions

For each top gap, provide one concrete action:
- A question to ask someone
- A test to run
- A document to write
- A constraint to add
- A decision to revisit

## Output Format

```markdown
## 🔍 Deep Blind Spot Analysis: [subject]

### Context
[2-3 sentence summary of what we're analyzing]

### Stakeholders
[findings — bulleted]

### Failure Modes
[findings — bulleted]

### Assumptions
[findings — bulleted, flag critical ones with ⚠️]

### Second-Order Effects
[findings — bulleted]

### Temporal
[findings — bulleted]

---

### ⚠️ Top 3 Gaps

| # | Gap | Impact | Probability | Action |
|---|-----|--------|-------------|--------|
| 1 | [description] | [H/M/L] | [H/M/L] | [concrete step] |
| 2 | [description] | [H/M/L] | [H/M/L] | [concrete step] |
| 3 | [description] | [H/M/L] | [H/M/L] | [concrete step] |
```
