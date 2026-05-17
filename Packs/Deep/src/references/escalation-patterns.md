# DeepDebug Reference: Escalation Patterns

## When to Escalate (Decision Tree)

```
Failed 2 attempts?
├── YES → Do I understand the system?
│         ├── NO → Workflows/Understand.md
│         └── YES → Do I have enough information?
│                   ├── NO → ASK THE USER (be specific)
│                   └── YES → Do I have hypotheses?
│                             ├── NO → Research more (code_search, web_search, source)
│                             └── YES → Are my hypotheses testable?
│                                       ├── NO → Invoke FirstPrinciples (challenge assumptions)
│                                       └── YES → Test them (Science approach)
└── NO → Keep going (but be aware of the limit)
```

## Asking the User: Good vs Bad

### Good (specific, actionable)
- "The error comes from `processQueue()` in worker.ts. I see it expects a `JobPayload` type but receives `undefined`. When did you last change the queue producer?"
- "I've found 3 possible causes. The most likely is a race condition in the auth middleware. Can you confirm: does this happen on every request or intermittently?"
- "I need to understand your deploy setup. Is there a build step that transforms env vars, or are they injected at runtime?"

### Bad (vague, shifts work to user)
- "Can you help me debug this?"
- "Do you know what's wrong?"
- "Can you give me more context?"

## Honest Stuck Communication

When genuinely stuck, structure it as:

```markdown
## Investigation Status

**What I've tried:**
1. [Attempt 1] → [Result/why it didn't work]
2. [Attempt 2] → [Result/why it didn't work]

**What I've found:**
- [Fact 1 from research]
- [Fact 2 from code reading]

**What I think is happening:**
- [Best theory so far, with confidence level]

**What I'm missing:**
- [Specific gap 1]
- [Specific gap 2]

**What would help:**
- [Specific thing the user could provide/clarify]
```

## Invoking Other Skills

| Situation | Skill | How |
|-----------|-------|-----|
| Need 3+ hypotheses | Science/GenerateHypotheses | Form evidence-based theories |
| "It should work but doesn't" | FirstPrinciples/Challenge | Question your assumptions about the system |
| Architectural issue, unclear tradeoffs | Swarm (`/swarm quick`) | Get Tech Architect + Contrarian perspective |
| Problem is design-level, not a bug | Brainstorm | Collaborative redesign with user |
| Need deep library/API understanding | Research | Multi-source research on the technology |
| Need examples of correct usage | `code_search` | Find working examples and docs |

## Common Root Cause Categories

When hypothesizing, check against these common categories:

| Category | Examples | How to Verify |
|----------|----------|---------------|
| **State** | Race condition, stale cache, leaked state | Add logging at state transitions |
| **Data** | Wrong shape, null/undefined, encoding | Log actual data at boundaries |
| **Environment** | Missing env var, wrong version, path issue | Compare working vs broken env |
| **Timing** | Async ordering, timeout, event loop | Add timestamps to logs |
| **Types** | Runtime type mismatch, coercion | Add runtime type checks |
| **Config** | Wrong setting, override not applied | Print effective config at startup |
| **Dependencies** | Version mismatch, breaking change | Check lockfile, changelogs |
| **Permissions** | File access, network policy, auth | Test with elevated permissions |
