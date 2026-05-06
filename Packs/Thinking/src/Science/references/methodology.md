# Scientific Method — Methodology Reference

## The Core Loop

```
OBSERVE → HYPOTHESIZE → PREDICT → EXPERIMENT → ANALYZE → CONCLUDE → ITERATE
```

### 1. Observe
- What is the current state?
- What measurements can you take RIGHT NOW?
- What has been tried before?

### 2. Hypothesize (Generate MULTIPLE)
Always generate 3+ hypotheses, ranked by:
- **Likelihood** — most probable explanation
- **Testability** — easiest to verify/falsify
- **Impact** — most consequential if true

### 3. Predict
For each hypothesis, what SPECIFIC, MEASURABLE outcome would confirm/deny it?

Bad: "It should work better"
Good: "Response time should drop below 200ms for 95th percentile"

### 4. Experiment
Design the MINIMUM VIABLE experiment:
- What's the smallest test that gives signal?
- What's the control?
- What variables are you changing?

### 5. Analyze
- Did the prediction match?
- What's the delta between expected and actual?
- What does this rule out?

### 6. Conclude
- Confirmed: Prediction matched within tolerance
- Refuted: Prediction was clearly wrong → UPDATE hypothesis
- Inconclusive: Need better experiment design

## Applying to Software

### Debugging
```
Observe:   "TypeError at line 42 when input is empty array"
Hypothesize: 
  H1: Missing null check before .length access
  H2: Function receives undefined, not empty array
  H3: Race condition — data hasn't loaded yet
Predict:   
  H1: Adding null check fixes it → test with empty []
  H2: console.log(typeof input) shows "undefined"
  H3: Only happens on slow network
Experiment: Add logging, test each scenario
```

### Performance
```
Observe:   "API response time increased from 50ms to 800ms after deploy"
Hypothesize:
  H1: New query hitting unindexed column
  H2: Connection pool exhaustion
  H3: Increased payload size
Predict:
  H1: EXPLAIN shows sequential scan
  H2: Connection count at max, queue growing
  H3: Response body >10x larger
Experiment: Check each metric independently
```

### Architecture Decisions
```
Observe:   "Users report slow page loads"
Hypothesize:
  H1: Too many API calls (N+1)
  H2: Large bundle size
  H3: Slow database queries
Predict:
  H1: Network tab shows >20 requests on load
  H2: main.js > 1MB
  H3: Server response > 500ms
Experiment: Measure each independently in DevTools
```

## Common Traps

| Trap | Symptom | Fix |
|------|---------|-----|
| Confirmation bias | Only testing the "obvious" hypothesis | Always test 3+ |
| Changing multiple variables | Can't isolate which change fixed it | One variable at a time |
| No baseline | "It's faster!" — compared to what? | Measure BEFORE and AFTER |
| Premature conclusion | First test "worked" so ship it | Reproduce 3+ times |
| Ignoring negative results | "That didn't work, so forget it" | Record ALL results |

## Timing and Iteration

| Scenario | Max iterations | Escalation |
|----------|---------------|------------|
| Quick diagnosis | 3 | If 3 fail, broaden hypothesis space |
| Standard investigation | 5-7 | If 5 fail, challenge your assumptions |
| Deep research | 10+ | Bring in outside perspectives |
