# Isolate Workflow

Running the **Isolate** workflow in the **DeepDebug** skill to narrow down the failure point...

## Overview

For multi-system failures where it's unclear WHERE the problem lives. Binary search through the stack until you find the layer that's broken.

---

## When to Use

- Error could be in frontend, backend, database, network, config, infra...
- Multiple systems interact and the failure point is unclear
- "It worked yesterday" but multiple things changed
- The error message is misleading or generic

---

## The Binary Search Method

The goal: narrow from "somewhere in the system" to "this exact layer/component."

### Step 1: Map the Request Path

Draw the full path from trigger to effect:

```
User Action → Frontend → API Gateway → Backend → Database → Response
     or
Event → Queue → Worker → External Service → Callback → State Update
```

### Step 2: Test at the Midpoint

Pick the middle of the chain and verify:
- Is the data correct AT THIS POINT?
- Is the request reaching this point?
- Is the response from this point correct?

### Step 3: Binary Narrow

- If midpoint is correct → problem is AFTER (narrow to second half)
- If midpoint is wrong → problem is BEFORE or AT (narrow to first half)
- Repeat until you find the exact boundary

---

## Isolation Techniques

| Layer | How to Test |
|-------|-------------|
| Frontend → API | Check network tab / curl the endpoint directly |
| API → Backend logic | Add logging at handler entry, check request shape |
| Backend → Database | Log the query, run it manually |
| Backend → External service | Mock the service, check what you're sending |
| Config/Environment | Compare working vs broken env, check env vars |
| Build/Deploy | Compare built artifacts, check deploy logs |

---

## Common Isolation Patterns

### "Works locally, fails in CI/prod"
```
1. Environment variables? → Compare .env files
2. Dependency versions? → Check lockfile differences  
3. File system assumptions? → Paths, permissions, temp dirs
4. Network access? → DNS, firewalls, timeouts
5. Resource limits? → Memory, disk, file descriptors
```

### "Works for me, fails for user"
```
1. Auth/permissions difference? → Check user's token/role
2. Data difference? → Check user's specific data shape
3. Browser/client difference? → Check user agent, versions
4. Timing/race condition? → Check if it's intermittent
5. Cache state? → Clear and retry
```

### "Worked yesterday, broken today"
```
1. git log --since="yesterday" → What changed?
2. Dependency update? → Check lockfile diff
3. External service change? → Check their status/changelog
4. Data migration? → Check DB schema/data
5. Infrastructure change? → Check deploy logs, config changes
```

---

## Isolation Checklist

For each suspected layer:

- [ ] Can I verify input TO this layer is correct?
- [ ] Can I verify output FROM this layer is correct?
- [ ] Can I bypass this layer entirely?
- [ ] Can I test this layer in isolation (mock inputs)?
- [ ] What changed in this layer recently?

---

## When Isolated → Switch to Investigate

Once you've found the exact layer/component that's broken:
→ Switch to `Workflows/Investigate.md` focused on that specific component.

The isolation workflow's job is ONLY to find WHERE. The investigate workflow finds WHY.
