---
name: skill-forge
description: "Use when you need deep knowledge about skill quality standards, the skill-vs-extension decision, or how to structure skills for maximum effectiveness. NOT needed for routine skill creation."
---

<!--
🌐 COMMUNITY SKILL

Part of the PAI open skills collection.
- License: MIT

Contributions welcome via GitHub issues and PRs.
-->

# Skill Forge — Quality Reference

Deep knowledge for crafting high-quality skills and deciding between skills vs extensions. This is a **knowledge reference** — read it when you need to think deeply about skill quality, not for routine creation.

## When to Read This

- Designing a complex skill with multiple workflows
- Deciding whether something should be a skill or an extension
- Reviewing/upgrading an existing skill's quality
- Understanding the quality rubric for skill auditing

## Skill vs Extension Decision

| Build a **Skill** when... | Build an **Extension** when... |
|---------------------------|-------------------------------|
| Providing workflow guidance or domain knowledge | Need lifecycle hooks (before_agent_start, agent_end) |
| Task-specific instructions loaded on-demand | Registering LLM-callable tools |
| Reference documentation for a tool/library | Modifying system prompt dynamically |
| Decision trees, checklists, patterns | Intercepting/modifying tool calls |
| One file (SKILL.md) is sufficient | Custom UI widgets or commands |
| No runtime code needed | Cross-session state or persistence |

**Hybrid pattern:** Extension provides runtime (tools, hooks), skill provides deep knowledge reference. The extension loads the skill's docs when needed.

## Quality Rubric

Score = weighted sum / max possible × 100%.

| Criterion | Weight | 0 (Bad) | 1 (OK) | 2 (Good) |
|-----------|--------|---------|--------|----------|
| **Trigger clarity** | 3× | Vague description | Decent triggers | Specific symptoms + contexts |
| **Context efficiency** | 3× | >500 lines, verbose | Reasonable | Lean, progressive disclosure |
| **Actionability** | 2× | Theory/narrative | Some guidance | Clear imperative steps |
| **Freedom calibration** | 2× | Wrong level | Acceptable | Matched to task fragility |
| **Discoverability** | 1× | No keywords | Some keywords | Rich symptom/error coverage |
| **Red flags** | 1× | Missing | Basic | Comprehensive with counters |
| **Examples** | 1× | None or bad | Acceptable | One excellent, runnable |

**Interpretation:** 80%+ production-ready, 60-79% needs work, <60% rewrite.

## Structural Best Practices

### Directory Structure
```
skill-name/
├── SKILL.md                # Required. Core instructions (<500 lines)
├── references/             # Optional. Heavy docs, loaded as-needed
│   ├── deep-ref.md
│   └── examples.md
├── scripts/                # Optional. Executable code
└── assets/                 # Optional. Templates, images (not loaded)
```

### SKILL.md Skeleton
```yaml
---
name: kebab-case-name
description: "Use when [specific triggers]. NOT what it does."
---
# Name

## Overview
One sentence: what problem it solves.

## When to Use
- Situation A (symptom/error pattern)
- Situation B (keyword trigger)

## Core Pattern
Imperative steps. Do X, then Y.

## Quick Reference
Table or decision tree for scanning.

## Common Mistakes
What goes wrong + fix.

## Red Flags
Discipline checks — rationalizations that mean "use properly."
```

### Critical Rules
- **Description = WHEN** to use (triggers only), NOT what it does
- Start with "Use when..."
- **Imperative voice** (do X, then Y), not explanatory
- **One excellent example** > many mediocre ones
- No narrative filler, README, CHANGELOG
- **Keywords** help discovery: error messages, tool names, domain terms
- Cross-reference other skills by name
- Body **<500 lines, <5k words** — move detail to `references/`

## Anti-Patterns

| Smell | Fix |
|-------|-----|
| >500 lines in SKILL.md | Extract to `references/`, keep SKILL.md lean |
| Description says "Helps with X" | Rewrite as "Use when [triggers]" |
| No red flags section | Run pressure test, capture rationalizations |
| All instructions, no structure | Add `## When to Use`, `## Quick Reference` |
| Duplicates another skill | Merge — retire one |
| Never loaded (30+ days) | Audit first — may need better description for discovery |

## Retirement Criteria

A skill should be retired when:
- >60% overlap with another skill → **merge**
- Superseded by a better alternative → **deprecate**
- Not loaded in 60+ days and no clear use case → **delete**
- Functionality moved into an extension tool → **delete skill, keep extension**

## Runtime Memory Tools

Agent memory systems can provide runtime complements to this knowledge reference:

| Tool | Purpose |
|------|---------|
| `crystallize_skill` | Create a skill from a workflow pattern. Runs quality gates before writing. |
| `audit_skill` | Score a skill against the rubric above. Returns score (0-100%) + specific improvements. |
| `create_extension` | Template-based extension creation (tool, context-injector, command, event-logger). |

Agent memory systems may also provide:
- **Pattern detection** — Tracks repeated tool sequences across sessions, suggests crystallization when a pattern hits 3+ occurrences
- **Skill usage tracking** — Records which skills are loaded, surfaces stale skills (unused >30 days)
- **System prompt injection** — Auto-injects crystallization candidates and stale skill warnings into context

**Architecture:** This skill = deep knowledge (loaded on-demand). Memory extension = runtime engine (when available). Together they form a closed self-extension loop.

## References

- [skill-anatomy.md](references/skill-anatomy.md) — Full specification and directory structure details
- [lifecycle.md](references/lifecycle.md) — Deep dive into audit, upgrade, and retire workflows
- [patterns.md](references/patterns.md) — Battle-tested patterns from production skills
- [self-extending.md](references/self-extending.md) — The self-extending loop philosophy
- [cross-platform.md](references/cross-platform.md) — Cross-platform skill compatibility (Claude Code, Pi, Codex, etc.)
