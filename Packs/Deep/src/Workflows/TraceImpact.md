# TraceImpact Workflow

Running the **TraceImpact** workflow in the **DeepAnalysis** skill to trace implications of this change...

## Overview

Analyze the ripple effects of a change, decision, or event. Trace causality through multiple orders — what changes directly, what changes as a consequence, and what breaks silently.

---

## When to Use

- "What happens if we change X?"
- "What are the implications of this decision?"
- "What could go wrong if we do this?"
- "What else is affected by this change?"

---

## The Causality Trace

### Order 0: The Change Itself
What's being changed? State it precisely:
- What's the BEFORE state?
- What's the AFTER state?
- What's the boundary of the change? (files, APIs, contracts, data)

### Order 1: Direct Effects
What IMMEDIATELY changes as a consequence?
- What calls this? (consumers break)
- What does this call? (different downstream behavior)
- What reads this data? (consumers see different data)
- What writes this data? (writers may conflict)

```bash
# For code changes:
rg "functionName\|ClassName\|importPath" --type ts -l  # Who uses this?
rg "from.*module" --type ts -l                         # Who imports this?
git log --all --format="%H %s" -- <changed-file>       # What touched this before?
```

### Order 2: Indirect Effects
What changes because Order 1 changed?
- If API response shape changes → What clients parse that shape?
- If performance changes → What has timeouts depending on current speed?
- If behavior changes → What tests/monitoring assume old behavior?
- If access changes → What workflows depend on current access?

### Order 3: Emergent Effects
What changes at a system/organizational level?
- Does this change team workflows?
- Does this create new coordination requirements?
- Does this shift where complexity lives?
- Does this change the system's failure modes?

---

## Impact Dimensions

For each affected area, assess:

| Dimension | Question |
|-----------|----------|
| **Correctness** | Does existing functionality still work correctly? |
| **Performance** | Does anything get slower? Different resource usage? |
| **Security** | New attack surface? Changed trust boundaries? |
| **Observability** | Do logs/metrics/alerts still make sense? |
| **Operations** | Does deployment/rollback change? New runbook needed? |
| **Data** | Is existing data still valid? Migration needed? |
| **Contracts** | Do any external APIs/interfaces change? |
| **Tests** | What tests break? What's newly untested? |

---

## Output Format

```markdown
## Impact Analysis: [Change Description]

### The Change
- **Before:** [state]
- **After:** [state]
- **Scope:** [what files/systems/contracts are directly modified]

### Impact Map

| Order | What's Affected | How | Severity | Action Needed |
|-------|----------------|-----|----------|---------------|
| 1 | [Direct] | [How it changes] | 🔴/🟡/🟢 | [Fix/Monitor/None] |
| 2 | [Indirect] | [Consequence of Order 1] | ... | ... |
| 3 | [Emergent] | [System-level shift] | ... | ... |

### Risk Assessment
- **Highest risk:** [The thing most likely to break/cause problems]
- **Silent failures:** [Things that won't error but will be wrong]
- **Reversibility:** [Can we undo this? How quickly? What's the cost?]

### Recommended Approach
- [How to make this change safely]
- [What to monitor after the change]
- [What to test before shipping]
```

---

## Common Impact Patterns

### API/Interface Changes
```
Change shape → Break consumers → Break their consumers → Silent data corruption
```
Check: All callers, all parsers, all serializers, all tests that mock this.

### Database/Schema Changes
```
Change schema → Migration needed → Downtime window → Rollback complexity
Change data semantics → Old code misinterprets → Silent wrong behavior
```
Check: All queries, all ORMs, all raw SQL, all caches, all analytics.

### Dependency Updates
```
Update library → API changes → Compilation breaks (visible) + behavior changes (invisible)
```
Check: Changelog for breaking changes, behavior changes, deprecated features used.

### Config/Environment Changes
```
Change config → Different behavior in all environments → Works locally, breaks in prod
```
Check: All environments, all deploy scripts, all docker files, all CI.

### Permission/Auth Changes
```
Change access → Existing workflows break → Users locked out OR escalated
```
Check: All roles, all routes, all UI conditionals, all downstream services.

---

## Verification Questions

After tracing, verify completeness:
- [ ] Did I check who CALLS this? (upstream)
- [ ] Did I check what this CALLS? (downstream)
- [ ] Did I check who READS the data this produces? (consumers)
- [ ] Did I check what TESTS assume about this? (assertions)
- [ ] Did I check OTHER ENVIRONMENTS? (prod, staging, CI)
- [ ] Did I consider TIME? (caches, eventual consistency, queued jobs)
- [ ] Did I consider PEOPLE? (team workflows, documentation, runbooks)
