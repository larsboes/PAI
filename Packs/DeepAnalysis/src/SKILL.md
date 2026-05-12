---
name: DeepAnalysis
description: "Multi-dimensional comprehension of complex systems — map structure, trace causality, surface hidden dependencies, and produce structured insights. Use when needing to deeply understand a codebase, architecture, system, plan, or problem space before acting."
---

# DeepAnalysis — Understand Before You Act

**Don't summarize. Comprehend. Map the full picture — structure, connections, implications, and what's not obvious.**

This skill is for when you need to UNDERSTAND something complex, not fix it (DeepDebug), decide on it (Council), or challenge it (RedTeam). Pure comprehension. The output is a mental model that makes everything else easier.

---

## Core Philosophy

```
Surface:   "It's a microservices system with a React frontend"
Deep:      "There are 3 hidden coupling points, the auth service is a SPOF,
            data flows contradict the stated architecture, and the team structure
            means changes to X always require coordination with Y"
```

**The job is to surface what's NOT obvious.** Anyone can describe what they see. Deep analysis reveals what they'd MISS.

---

## Workflow Routing

| Trigger | Workflow |
|---------|----------|
| Understand a codebase or architecture | `Workflows/MapSystem.md` |
| Analyze implications of a change/decision | `Workflows/TraceImpact.md` |
| Understand a problem space or domain | `Workflows/MapDomain.md` |
| Compare approaches, map tradeoff landscape | `Workflows/Tradeoffs.md` |

---

## The Analysis Framework

Every deep analysis operates on 5 dimensions:

```
┌─────────────────────────────────────────────────────────┐
│  1. STRUCTURE — What is this made of?                   │
│     Components, boundaries, interfaces, layers          │
│     → "Here are the pieces and how they connect"        │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  2. FLOW — How does it move?                            │
│     Data flow, control flow, event chains, lifecycles   │
│     → "Here's what happens when X triggers"             │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  3. DEPENDENCIES — What relies on what?                 │
│     Hard deps, implicit coupling, shared state, SPOFs   │
│     → "If this breaks, these 5 things break too"        │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  4. TENSIONS — Where does it fight itself?              │
│     Contradictions, tradeoffs, tech debt, design smells │
│     → "The stated goal is X but the implementation      │
│        actually optimizes for Y"                        │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  5. EVOLUTION — How will this change over time?         │
│     Growth pressure, scaling limits, likely next states  │
│     → "This works now but will break when Z happens"    │
└─────────────────────────────────────────────────────────┘
```

---

## Depth Levels

Not every analysis needs full depth. Match effort to stakes:

| Level | When | Effort | Output |
|-------|------|--------|--------|
| **Quick Map** | Need orientation, not deep understanding | 5-10 min | Structure + key flows |
| **Standard** | Making decisions that depend on understanding | 15-30 min | All 5 dimensions |
| **Deep Dive** | High-stakes, complex system, unfamiliar territory | 30-60 min | Full analysis + diagrams + implications |

---

## Investigation Techniques

### For Code/Architecture
```bash
# Structure
find . -type f -name "*.ts" | head -40    # What files exist?
cat package.json                           # Dependencies?
rg "import.*from" --type ts | sort        # Internal dependency graph?
rg "export" src/index.ts                   # Public API surface?

# Flow
rg "async\|await\|Promise\|emit\|on\(" --type ts -l  # Async/event patterns?
rg "fetch\|axios\|http" --type ts -l      # External calls?

# Dependencies
rg "process.env" --type ts                 # Environment coupling?
rg "import.*config\|require.*config"       # Config dependencies?

# Tensions
rg "TODO\|HACK\|FIXME\|XXX" --type ts     # Known debt?
rg "deprecated\|legacy" --type ts          # Evolution signals?
```

### For Systems/Architectures
- Read docs/READMEs for STATED design
- Read code for ACTUAL design
- Compare the two — gaps reveal tensions
- Check git history for evolution patterns

### For Problem Spaces/Domains
- `web_search` for landscape understanding
- `code_search` for prior art and patterns
- Map stakeholders and their competing needs
- Identify the core tension that makes the problem hard

---

## Output Format

Every analysis produces structured output. Never a wall of text.

```markdown
## Deep Analysis: [Subject]

### One-Sentence Summary
[What this IS in one sentence a junior could understand]

### Structure Map
[Components and their relationships — ASCII diagram, table, or list]

### Key Flows
[2-3 most important paths through the system]

### Dependency Graph
[What depends on what — highlight SPOFs and hidden coupling]

### Tensions & Contradictions
[Where the system fights itself — stated vs actual, tradeoffs embedded in design]

### Evolution Trajectory
[Where this is heading, what will break first, scaling limits]

### Non-Obvious Insights
[The 2-3 things someone new would miss — this is the real value]

### Implications for [User's Goal]
[How does this analysis affect what they're trying to do?]
```

---

## Integration Points

| Need | Invoke |
|------|--------|
| Want to challenge findings | **FirstPrinciples** — are my conclusions based on assumptions? |
| Want to stress-test a conclusion | **RedTeam** — attack my analysis |
| Want multi-perspective on findings | **Council** or `/swarm quick` |
| Need empirical verification | **Science** — design experiment to test a claim |
| Found a problem during analysis | **DeepDebug** — investigate it |
| Analysis reveals design decision needed | **Brainstorm** — explore options collaboratively |

---

## Anti-Patterns

| Bad | Good |
|-----|------|
| Surface-level description ("it has 3 services") | Reveal connections and implications |
| Only describe what's there | Also note what's MISSING or contradictory |
| Wall of prose | Structured output: maps, tables, diagrams |
| Stop at first layer | Trace causality: "because of X, therefore Y, which means Z" |
| Analyze in isolation | Consider context: team, timeline, constraints |
| Present findings as facts | Distinguish observed vs inferred, flag uncertainty |

---

## Key Questions to Always Ask

1. "What would someone NEW to this miss?" (surfaces implicit knowledge)
2. "What depends on this that isn't obvious?" (finds hidden coupling)
3. "What's the gap between stated design and actual behavior?" (finds tensions)
4. "If this grows 10x, what breaks first?" (reveals scaling limits)
5. "What's the one thing that, if it fails, takes everything down?" (finds SPOFs)

---

## Output Contract

- **Always produces:** Structured multi-dimensional analysis (not prose summary)
- **Includes:** At minimum: structure map + key insights + implications for user's goal
- **Distinguishes:** Observed facts vs inferences vs open questions
- **Surfaces:** The non-obvious — hidden dependencies, contradictions, evolution pressure
