---
name: DeepDebug
description: "Systematic deep investigation for hard bugs — research before guessing, ask user when stuck, escalate methodically. Use when stuck on a problem after initial attempts fail, or facing complex multi-system issues."
---

# DeepDebug — The Long Route

**When quick fixes fail, slow down. Research. Ask. Think. Don't spiral.**

This skill changes your operating mode from "guess and retry" to "investigate and understand." It's for problems where the answer isn't obvious and random attempts waste time.

---

## Core Philosophy

```
NEVER:  guess → fail → guess → fail → guess → fail → apologize
ALWAYS: stop → gather → understand → hypothesize → verify → fix
```

**The 2-Strike Rule:** If you've tried 2 things and neither worked, STOP. You don't understand the problem yet. Switch to investigation mode.

**The Honesty Rule:** When you don't have enough information, SAY SO. "I don't know why this is happening. I need to understand X before I can fix it. Can you tell me about Y?" is always better than a 5th wrong guess.

---

## Workflow Routing

| Trigger | Workflow |
|---------|----------|
| Hard bug, code doesn't work as expected | `Workflows/Investigate.md` |
| Multi-system failure, unclear where the problem is | `Workflows/Isolate.md` |
| Problem is architectural/design-level, not a simple bug | → Invoke **Brainstorm** skill |
| Need to understand unfamiliar code/system | `Workflows/Understand.md` |

---

## The Investigation Flow

```
┌─────────────────────────────────────────────────────────┐
│  1. STOP — Don't try another random fix                 │
│     "I've failed twice. I need to understand first."    │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  2. GATHER — Research before hypothesizing              │
│     • Read the actual source code (not just the error)  │
│     • Check git blame/log — what changed recently?      │
│     • code_search for similar patterns/known issues     │
│     • web_search for the exact error + library version  │
│     • Read docs for the specific API/feature            │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  3. ASK — Tell the user what you're missing             │
│     "I've found X and Y. But I need to know:           │
│      - When did this start happening?                   │
│      - Does it reproduce in [context]?                  │
│      - What changed recently in [area]?"                │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  4. HYPOTHESIZE — Form theories from evidence           │
│     → Invoke Science/GenerateHypotheses (minimum 3)     │
│     → Rank by: evidence strength × cost to verify       │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  5. VERIFY — Confirm root cause BEFORE fixing           │
│     • Add logging/prints to confirm the theory          │
│     • Reproduce minimally                               │
│     • Check: does the theory explain ALL symptoms?      │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  6. FIX — Now (and only now) write the fix              │
│     • Fix the root cause, not the symptom               │
│     • Verify the fix actually resolves it               │
│     • Check for regressions                             │
└─────────────────────────────────────────────────────────┘
```

---

## Escalation Paths

When investigation stalls, escalate — don't loop:

| Stuck At | Escalate To |
|----------|-------------|
| Can't reproduce | Ask user for exact steps, environment, versions |
| Unfamiliar library/API | `code_search` + `web_search` for docs and examples |
| Hypothesis keeps failing | `FirstPrinciples` — challenge your assumptions about how it works |
| Architectural confusion | `/swarm quick "this problem..."` for multi-perspective analysis |
| Design-level problem | → **Brainstorm** skill for collaborative solution design |
| Truly stuck, no leads | Tell user: "I'm stuck. Here's what I've tried and what I know. What am I missing?" |

---

## Anti-Patterns (What NOT To Do)

| Bad | Good |
|-----|------|
| Try 5 random fixes hoping one works | Stop at 2 failures, investigate |
| Read only the error message | Read the source that PRODUCES the error |
| Assume you know the cause without evidence | Form hypothesis, then verify BEFORE fixing |
| Stay silent while confused | Tell user: "I don't understand X yet" |
| Fix the symptom | Fix the root cause |
| Ignore what changed recently | Always check git log/blame first |
| Google the error message only | Also search for the library + version + feature |
| Keep going when stuck | Escalate: ask user, research, invoke other skills |

---

## Research Toolkit

Use these **before** hypothesizing, not after failing:

| Tool | When |
|------|------|
| `read` (source code) | ALWAYS — read the code that's failing, not just the error |
| `bash: git log --oneline -20` | What changed recently? |
| `bash: git blame <file>` | Who/when was this line written? |
| `code_search` | How does this API/library/pattern work? |
| `web_search` | Known issues, version-specific bugs, migration guides |
| `bash: rg "pattern"` | Where else is this used? What's the convention? |
| `read` (tests) | What was the INTENDED behavior? |
| `read` (docs/README) | What does the author say about this? |

---

## Integration Points

| Phase | Invoke |
|-------|--------|
| Hypothesis generation | **Science** (GenerateHypotheses — minimum 3) |
| Assumption challenging | **FirstPrinciples** (when "it should work but doesn't") |
| Architectural perspective | **Swarm** (`/swarm quick "..."`) |
| Design-level rethink | **Brainstorm** (when the fix needs collaborative design) |
| Research depth | **Research** skill (when you need deep context on a topic) |

---

## Key Phrases to Use

When switching to DeepDebug mode, communicate clearly:

- "I've tried X and Y without success. Let me investigate properly."
- "I need to understand how [system] works before I can fix this."
- "I don't have enough information. Specifically, I need to know: ..."
- "My hypothesis is [X] because [evidence]. Let me verify before fixing."
- "This is a deeper issue than I initially thought. Here's what I've found so far: ..."
- "I'm stuck. Here's my investigation so far and what I think is missing: ..."

---

## Output Contract

- **Always produces:** Root cause analysis + fix (or explicit "here's where I'm stuck and why")
- **Shows:** Investigation trail — what was checked, what was found, what was ruled out
- **Never:** Silently retries without telling the user what's happening
