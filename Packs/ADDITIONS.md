# ADDITIONS.md — Restructure Changelog & Design Decisions

Last updated: 2026-05-06

## Summary

Full restructure of PAI Packs to align with Anthropic's skill best practices (January 2026 guide). Emphasis on: concise SKILL.md bodies, progressive disclosure via `references/`, real executable `scripts/`, natural descriptions, and tangible output contracts.

---

## What Changed

### Skills Removed (4)
| Skill | Pack | Reason |
|-------|------|--------|
| **Fabric** | Utilities | Just a wrapper around reading prompt files. Research already uses patterns internally. `Patterns/` dir kept as raw reference data. |
| **IterativeDepth** | Thinking | 40 lines, no tools. Abstract "run N lenses" technique — the agent can do this without a skill. |
| **SECUpdates** | Security | RSS feed checking doesn't need a skill. Convert to a script if needed. |
| **AnnualReports** | Security | "Fetch PDFs and summarize" is a Research workflow, not a standalone skill. |

### Skills Added (5) — Tooling Pack
| Skill | Scripts | References | Purpose |
|-------|---------|-----------|---------|
| **ApiPatterns** | 4 | 5 | Direct curl/fetch for OpenAI, Anthropic, GitHub APIs. Skip SDKs. |
| **GitWorkflow** | 3 | 2 | Worktrees, rebase, bisect, reflog recovery, hooks. |
| **Docker** | 3 | 1 | Build, compose, debug, optimize containers. |
| **LlmApi** | 5 | 0 | Call any LLM in one line. Batch, compare, stream. |
| **SystemAdmin** | 4 | 1 | systemd, journalctl, networking, processes, diagnostics. |

### Structural Changes
| Change | Impact |
|--------|--------|
| Killed 7 router SKILL.md files | Agent routes directly to leaf skills via description matching |
| Merged Presentations pack into Media | revealjs lives alongside Art and Remotion |
| Merged PythonPptx into Pptx | Eliminated 3rd-level nesting, now a reference file |
| Stripped boilerplate from 35 skills | ~850 lines / 27KB of dead context removed |
| Rewrote 44 descriptions | Natural language instead of keyword stuffing |
| Added output contracts | Skills now declare what they produce |
| Toned down enforcement language | Removed MANDATORY/CRITICAL/🚨 where not warranted |
| Refactored 8 oversized SKILL.md files | Moved heavy content to `references/` |

---

## Design Decisions (for future sessions)

### Why natural descriptions matter
The agent reads ALL skill descriptions to decide routing. Keyword-stuffed descriptions like `"USE WHEN red team, attack idea, counterarguments, critique, stress test, poke holes, devil's advocate, find weaknesses, break this"` waste tokens and don't help the model distinguish between similar skills. A natural description like `"Attack arguments from 32 expert perspectives to find fatal flaws. Use when stress-testing proposals or playing devil's advocate."` gives the model MEANING, not just keywords.

### Why router skills are anti-pattern
The agent already sees all skill descriptions. A parent "Thinking" skill that just routes to "FirstPrinciples", "RedTeam", etc. adds an unnecessary indirection — the agent loads the router, then has to load the sub-skill anyway. Direct routing via good descriptions is one step, not two.

### Why scripts matter
A skill without scripts is just "here's how to think about this" — which is what the system prompt is for. Skills that bundle real executable code (like `scripts/call-anthropic.sh` or `scripts/syscheck.sh`) teach the agent to USE TOOLS, not just reason. The agent can `bash scripts/syscheck.sh` and get immediate value.

### Why <180 lines for SKILL.md
Per Anthropic: "Every line is a recurring token cost." Once a skill loads, its FULL content stays in context. Heavy reference docs should live in `references/` and only load when explicitly needed. The SKILL.md should be: routing + quick reference + output contract.

### When enforcement language IS appropriate
- Security skills (PromptInjection) — authorization warnings are warranted
- Technical constraints (Xlsx "always use formulas") — these are real requirements
- Everything else — trust the agent to follow instructions without yelling

---

## Remaining Intentionally Large Skills (>200 lines)

| Skill | Lines | Why It's OK |
|-------|-------|-------------|
| Telos | 369 | Personal life OS with state — needs depth |
| Aphorisms | 340 | Data collection with search — could refactor |
| CreateCLI | 320 | Template system — could extract templates to refs |
| Agents | 276 | Trait composition system — complex by nature |
| PromptInjection | 237 | Security methodology — appropriate depth |
| CreateSkill | 237 | Meta-skill — teaches skill creation |
| ExtractWisdom | 232 | Tone/voice system — the examples ARE the skill |

These are legitimately complex. Don't refactor them just to hit a number.

---

## File Structure Pattern (Gold Standard)

```
SkillName/
├── SKILL.md              # ≤180 lines
│   ├── Frontmatter       # name + description (natural language)
│   ├── Quick Reference   # Most-used commands/patterns
│   ├── Workflow Routing   # Trigger → workflow table
│   ├── References Table   # What's in references/
│   ├── Scripts Table      # What's in scripts/
│   └── Output Contract    # What artifact this produces
├── scripts/              # Real executable code
│   ├── main-tool.sh      # Primary automation
│   └── helper.sh         # Supporting utilities
├── references/           # Deep docs (loaded on demand)
│   ├── patterns.md       # Detailed patterns/examples
│   └── api-reference.md  # Full API docs
└── Workflows/            # Step-by-step procedures
    ├── MainWorkflow.md
    └── AlternateWorkflow.md
```

---

## Quick Stats

| Metric | Before (2026-05-05) | After (2026-05-06) |
|--------|---------------------|---------------------|
| Total SKILL.md | 51 | 45 |
| Executable scripts | 5 | 28 |
| Reference documents | ~3 | 51 |
| Router/meta skills | 7 | 0 |
| Avg top-10 SKILL.md size | 470 lines | 175 lines |
| Boilerplate lines | ~850 | 0 |
| Packs | 13 | 12 |
| Max nesting depth | 3 | 2 |
