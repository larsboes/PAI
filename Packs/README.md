<div align="center">

<img src="pai-packs-icon.png" alt="PAI Packs" width="256">

# PAI Packs

</div>

Standalone, AI-installable capabilities for Claude Code and other AI agent systems.

Each pack is a directory containing everything needed for an AI agent to install it autonomously:

```
PackName/
├── README.md    # What it does, why it exists, how it works
├── INSTALL.md   # Step-by-step wizard for AI-assisted installation
├── VERIFY.md    # Post-install verification checklist
└── src/         # Source files to copy
    └── SkillName/
        ├── SKILL.md       # Core instructions (concise, <180 lines)
        ├── scripts/       # Executable automation (bash, python, ts)
        ├── references/    # Deep docs loaded on demand
        └── Workflows/     # Step-by-step procedures
```

## How to Install a Pack

Point your AI to the pack directory:

```
"Install the Research pack from PAI/Packs/Research/"
```

Your AI reads `INSTALL.md` and walks through a 5-phase wizard: system analysis, user questions, backup, installation, verification.

Or manually: read `INSTALL.md`, copy files from `src/` to the specified locations, run `VERIFY.md` checks.

## Available Packs

### Skills (12 packs, 45 skills)

| Pack | Skills | Description |
|------|--------|-------------|
| [Agents](Agents/) | 1 | Custom agent composition from traits, voices, and personalities |
| [ContentAnalysis](ContentAnalysis/) | 1 | Content-adaptive wisdom extraction from videos, podcasts, articles |
| [Investigation](Investigation/) | 2 | OSINT investigations and ethical people-finding |
| [Media](Media/) | 3 | Visual content (Art), programmatic video (Remotion), presentations (reveal.js) |
| [Research](Research/) | 1 | Multi-mode research: quick/standard/extensive/deep investigation |
| [Scraping](Scraping/) | 2 | Apify social media actors + BrightData progressive URL scraping |
| [Security](Security/) | 3 | Network recon, web app assessment, prompt injection testing |
| [Telos](Telos/) | 1 | Life OS — goals, beliefs, wisdom, projects, dashboards |
| [Thinking](Thinking/) | 6 | First principles, red team, council debates, science, creativity, world threat models |
| [Tooling](Tooling/) | 8 | API patterns, git, Docker, LLM APIs, system admin, Bazel, FluentBit, Logstash |
| [USMetrics](USMetrics/) | 1 | 68 US economic indicators with trend analysis |
| [Utilities](Utilities/) | 16 | Documents, browser, delegation, evals, CLI generation, and more |

### Commands

| Pack | Description |
|------|-------------|
| [ContextSearch](ContextSearch/) | `/context-search` and `/cs` — search prior work to add context |

## Skill Design Principles

All skills follow these patterns (see `ADDITIONS.md` for full rationale):

1. **Concise SKILL.md** — <180 lines. Routing, quick reference, output contract.
2. **Progressive disclosure** — Heavy content lives in `references/`, loaded on demand.
3. **Real scripts** — Executable bash/python/ts in `scripts/`. No wrappers.
4. **Natural descriptions** — "Use when..." not "USE WHEN keyword, keyword, keyword"
5. **Output contracts** — Every skill states what artifact it produces.
6. **Zero boilerplate** — No repeated notification blocks or customization checks.

## Creating a Pack

See [PAIPackTemplate.md](../Tools/PAIPackTemplate.md) for the full specification.
