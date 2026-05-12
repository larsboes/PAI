# Investigate Workflow

Running the **Investigate** workflow in the **DeepDebug** skill to systematically find the root cause...

## Overview

Full investigation for a bug or unexpected behavior where initial attempts have failed. This is the "long route" — methodical, research-heavy, no guessing.

---

## Pre-Check: Should You Be Here?

- [ ] You've tried at least 1-2 obvious fixes and they didn't work
- [ ] The problem is NOT trivial (if it is, just fix it)
- [ ] You don't fully understand WHY it's broken

If you haven't tried anything yet and the fix is obvious, just do it. This workflow is for when you're stuck.

---

## Phase 1: STOP and Acknowledge

**Say out loud (to the user):**
> "I've tried [X] without success. This needs a proper investigation. Let me dig deeper."

This is not weakness — it's professionalism. The user would rather you investigate than guess 10 more times.

---

## Phase 2: GATHER Context

Spend 5-10 minutes purely reading and researching. No fixing yet.

### 2.1 Read the Source
- Read the file(s) where the error occurs — not just the line, the surrounding context
- Read the function that calls it
- Read the tests for this code (if any)

### 2.2 Check History
```bash
git log --oneline -20 <file>        # What changed recently?
git blame <file> | grep -A5 <area>  # When was this written?
git log --all --oneline --since="3 days ago"  # Recent changes anywhere?
```

### 2.3 Search for Context
- `code_search`: How does this API/library feature work?
- `web_search`: Known issues with this library + version?
- `rg "pattern"`: Where else is this pattern used in the codebase?

### 2.4 Check Related Systems
- Environment variables, config files
- Dependencies and their versions
- Build output, compiled artifacts vs source

---

## Phase 3: ASK the User (if needed)

After gathering, assess what you're missing. If gaps remain:

> "I've investigated and found [X, Y, Z]. But I still need to understand:
> 1. [Specific question about context/history]
> 2. [Specific question about expected behavior]
> 3. [Specific question about environment/reproduction]"

**Good questions:**
- "When did this start happening? Did anything change recently?"
- "Does this happen every time or intermittently?"
- "What's the expected behavior vs. what you're seeing?"
- "Are there any environment differences (local vs CI, versions, etc.)?"

**Bad questions (too vague):**
- "Can you give me more context?" → Ask for SPECIFIC context
- "What should I do?" → You're the investigator, propose hypotheses

---

## Phase 4: HYPOTHESIZE from Evidence

Now (and only now) form theories. Use the Science skill's approach:

**Minimum 3 hypotheses, ranked by evidence strength:**

```markdown
## Hypotheses

### H1: [Most likely — supported by evidence from Phase 2]
- Evidence for: [what you found]
- Evidence against: [if any]
- Verify by: [cheapest test]

### H2: [Second most likely]
- Evidence for: ...
- Verify by: ...

### H3: [Dark horse — less obvious but possible]
- Evidence for: ...
- Verify by: ...
```

**Key:** Each hypothesis must be FALSIFIABLE. If you can't think of how to disprove it, it's too vague.

---

## Phase 5: VERIFY Before Fixing

For the top hypothesis, CONFIRM it before writing a fix:

- Add a log/print that would prove the hypothesis true or false
- Create a minimal reproduction
- Check: does this theory explain ALL the symptoms?

```markdown
## Verification: Testing H1

**Test:** [What I'm checking]
**Expected if H1 is correct:** [Observable outcome]
**Expected if H1 is wrong:** [Different outcome]
**Result:** [What actually happened]
**Verdict:** H1 [CONFIRMED/REFUTED]
```

If refuted → move to H2. If all refuted → back to Phase 2 with new knowledge.

---

## Phase 6: FIX (Root Cause)

Only after verification:

1. Fix the ROOT CAUSE, not the symptom
2. Verify the fix resolves the original problem
3. Check for regressions (run tests, check related functionality)
4. Explain to the user what was wrong and why

---

## Phase 7: Retrospective (30 seconds)

After fixing:
- Why didn't the initial attempts work?
- What was the key insight that led to the fix?
- Could this have been found faster? How?

Share this with the user — it builds trust and helps them next time.

---

## Escalation Triggers

If at any phase you're stuck for more than 5 minutes:

| Signal | Action |
|--------|--------|
| All hypotheses exhausted | Tell user: "I've tested X theories and none explain it. Here's what I know..." |
| Unfamiliar territory | `code_search` + `web_search` for the specific technology |
| Assumptions seem wrong | Invoke **FirstPrinciples** — "Is this actually how it works?" |
| Multi-system interaction | Switch to `Workflows/Isolate.md` |
| Need architectural rethink | Invoke **Brainstorm** skill |
| Truly stuck, no progress | Honest escalation: "I'm stuck. Here's my full investigation. What am I missing?" |
