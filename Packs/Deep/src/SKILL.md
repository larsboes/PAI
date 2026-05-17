---
name: Deep
description: "Deep investigation and comprehension — two modes: Analyse (understand complex systems, codebases, architectures, decisions before acting) and Debug (systematic bug investigation using the 2-strike rule: stop guessing, gather evidence, hypothesise, verify, fix). USE WHEN deep analysis, understand codebase, map system, trace impact, analyse architecture, deep dive, hard bug, stuck on problem, investigate failure, complex issue, multi-system failure, root cause, understand before acting, what am I missing."
allowed-tools: Bash
---

# Deep

Two modes for when shallow isn't enough.

## Workflow Routing

| Trigger | Workflow |
|---------|----------|
| Understand a codebase or architecture | `Workflows/MapSystem.md` |
| Analyse implications of a change or decision | `Workflows/TraceImpact.md` |
| Understand a problem space or domain | `Workflows/MapDomain.md` |
| Compare approaches, map tradeoff landscape | `Workflows/Tradeoffs.md` |
| Hard bug, code doesn't work as expected | `Workflows/Investigate.md` |
| Multi-system failure, unclear where the problem is | `Workflows/Isolate.md` |
| Need to understand unfamiliar code/system before fixing | `Workflows/Understand.md` |

## Mode Selector

```
Something is BROKEN and I need to fix it   → Debug (Investigate / Isolate)
Something is COMPLEX and I need to act on it → Analyse (MapSystem / TraceImpact / MapDomain)
Something is UNFAMILIAR and I'm lost        → Understand (bridges both)
```

## Debug: Core Rule

**2-Strike Rule:** Tried 2 things, neither worked → STOP. Switch to investigation mode.

```
NEVER: guess → fail → guess → fail → apologise
ALWAYS: stop → gather evidence → hypothesise → verify → fix
```

## Analyse: Core Rule

**Don't summarise. Comprehend.** Surface what's NOT obvious — hidden dependencies, contradictions, evolution pressure.

```
Surface:   "It's a microservices system with a React frontend"
Deep:      "There are 3 hidden coupling points, the auth service is a SPOF,
            data flows contradict the stated architecture"
```

## Quick Reference: Debug Investigation

```bash
git log --oneline -20          # what changed recently?
git blame <file>               # who wrote this line?
rg "pattern" --type ts         # where else is this used?
# Read source that PRODUCES the error, not just the error message
# web_search: error + library + version
```

## Quick Reference: Analyse Dimensions

1. **Structure** — components, boundaries, interfaces
2. **Flow** — data flow, event chains, lifecycles
3. **Dependencies** — what relies on what, SPOFs
4. **Tensions** — contradictions, stated vs actual design
5. **Evolution** — what will break first at 10x scale

## References

| File | Purpose |
|------|---------|
| `references/analysis-lenses.md` | 5 dimensions + depth selector |
| `references/output-formats.md` | Structured output templates |
| `references/question-bank.md` | Questions to ask per dimension |
| `references/anti-patterns.md` | Common mistakes for both modes |
| `references/root-cause-tracing.md` | Root cause tracing patterns |
| `references/escalation-patterns.md` | When and how to escalate |
| `references/stack-patterns.md` | Stack-specific debug patterns |
| `references/logging-strategies.md` | Logging for investigation |
| `references/defense-in-depth.md` | Defence-in-depth debugging |
