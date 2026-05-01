<div align="center">

<img src="pai-packs-icon.png" alt="PAI Packs" width="256">

# PAI Packs

</div>

Standalone, AI-installable capabilities for Claude Code and other AI agent systems. Each pack is a self-contained prompt — point your DA at a directory and say "install this," and it sets everything up.

Two install paths exist:

- **Individual skills** — Every v5.0.0 skill ships as a standalone capability. Point your DA at the skill directory in the v5.0.0 release and ask it to install just that one.
- **Curated bundles** — Pre-built combinations with their own `INSTALL.md` and `VERIFY.md` wizards (in this directory).

## How to Install

```
"Install the Research skill from PAI/Releases/v5.0.0/.claude/skills/Research/"
```

or for a curated bundle:

```
"Install the ContextSearch pack from PAI/Packs/ContextSearch/"
```

Your DA reads the contents and walks through a 5-phase wizard: system analysis, user questions, backup, installation, verification.

---

## All Skills (v5.0.0 — 45)

| Skill | What it does |
|-------|--------------|
| [Agents](../Releases/v5.0.0/.claude/skills/Agents/) | Compose custom agents from base traits, voice, and specialization; manage functional teams |
| [ApertureOscillation](../Releases/v5.0.0/.claude/skills/ApertureOscillation/) | 3-pass scope oscillation: narrow tactical, wide strategic, then synthesis to surface design tensions |
| [Aphorisms](../Releases/v5.0.0/.claude/skills/Aphorisms/) | Curated aphorism collection with content matching, themed search, thinker research |
| [Apify](../Releases/v5.0.0/.claude/skills/Apify/) | Scrape Instagram, LinkedIn, TikTok, YouTube, Facebook, Google Maps, e-commerce via Apify actors |
| [Art](../Releases/v5.0.0/.claude/skills/Art/) | Static visual content across 20+ formats via Flux, Nano Banana Pro, GPT-Image-1 |
| [ArXiv](../Releases/v5.0.0/.claude/skills/ArXiv/) | Search and retrieve arXiv academic papers with AlphaXiv-enriched AI summaries |
| [AudioEditor](../Releases/v5.0.0/.claude/skills/AudioEditor/) | Whisper transcription → Claude classification → ffmpeg cuts for audio/video editing |
| [BeCreative](../Releases/v5.0.0/.claude/skills/BeCreative/) | Divergent ideation via Verbalized Sampling and extended thinking |
| [BitterPillEngineering](../Releases/v5.0.0/.claude/skills/BitterPillEngineering/) | Audit AI instruction sets for over-prompting; classify rules CUT/RESOLVE/MERGE/KEEP |
| [BrightData](../Releases/v5.0.0/.claude/skills/BrightData/) | 4-tier progressive scraping with auto-escalation through WebFetch, curl, browser, MCP proxy |
| [Browser](../Releases/v5.0.0/.claude/skills/Browser/) | Headless browser automation via agent-browser Rust CLI for batch and parallel work |
| [ContextSearch](../Releases/v5.0.0/.claude/skills/ContextSearch/) | 2-phase context search across session registry, work directories, and ISAs for cold-start recovery |
| [Council](../Releases/v5.0.0/.claude/skills/Council/) | Multi-agent collaborative debate with round-by-round transcripts and intellectual friction |
| [CreateCLI](../Releases/v5.0.0/.claude/skills/CreateCLI/) | Generate production TypeScript CLIs via 3-tier template system (manual, Commander, oclif) |
| [CreateSkill](../Releases/v5.0.0/.claude/skills/CreateSkill/) | Complete PAI skill development lifecycle — scaffold, validate, canonicalize, evaluate |
| [Daemon](../Releases/v5.0.0/.claude/skills/Daemon/) | Manage public daemon profile — living digital presence with deterministic security filtering |
| [Delegation](../Releases/v5.0.0/.claude/skills/Delegation/) | Six parallelization patterns: built-in agents, worktrees, background tasks, custom agents |
| [Evals](../Releases/v5.0.0/.claude/skills/Evals/) | Agent evaluation framework with code-based, model-based, and human graders; pass@k scoring |
| [ExtractWisdom](../Releases/v5.0.0/.claude/skills/ExtractWisdom/) | Content-adaptive wisdom extraction that detects domains and builds custom sections |
| [Fabric](../Releases/v5.0.0/.claude/skills/Fabric/) | Execute any of 240+ Fabric prompt patterns natively across extraction, analysis, creation |
| [FirstPrinciples](../Releases/v5.0.0/.claude/skills/FirstPrinciples/) | Physics-based reasoning that deconstructs problems to irreducible truths |
| [Ideate](../Releases/v5.0.0/.claude/skills/Ideate/) | Evolutionary ideation engine — 9-phase loop for novel solution generation |
| [Interceptor](../Releases/v5.0.0/.claude/skills/Interceptor/) | Real Chrome browser automation with zero CDP fingerprint; mandatory for visual verification |
| [Interview](../Releases/v5.0.0/.claude/skills/Interview/) | Phased conversational interview across all PAI context files (TELOS first) |
| [ISA](../Releases/v5.0.0/.claude/skills/ISA/) | Owns the Ideal State Artifact primitive — articulate "done" for any kind of work |
| [IterativeDepth](../Releases/v5.0.0/.claude/skills/IterativeDepth/) | Multi-angle exploration through 2-8 sequential passes from different scientific lenses |
| [Knowledge](../Releases/v5.0.0/.claude/skills/Knowledge/) | Manage typed Knowledge Archive across People, Companies, Ideas, Research with 8 link types |
| [Loop](../Releases/v5.0.0/.claude/skills/Loop/) | Iterative improvement loop — refine a target across multiple Algorithm cycles |
| [Migrate](../Releases/v5.0.0/.claude/skills/Migrate/) | Intake external content (Obsidian, Notion, Apple Notes, journals) and classify into PAI taxonomy |
| [Optimize](../Releases/v5.0.0/.claude/skills/Optimize/) | Autonomous optimization loop — hill-climb any target with metrics or LLM-as-judge eval |
| [PAIUpgrade](../Releases/v5.0.0/.claude/skills/PAIUpgrade/) | Generate prioritized PAI upgrade recommendations via 4 parallel research threads |
| [PrivateInvestigator](../Releases/v5.0.0/.claude/skills/PrivateInvestigator/) | Ethical people-finding and identity verification via 15 parallel research agents |
| [Prompting](../Releases/v5.0.0/.claude/skills/Prompting/) | Meta-prompting standard library — generate, optimize, and compose prompts programmatically |
| [RedTeam](../Releases/v5.0.0/.claude/skills/RedTeam/) | Adversarial analysis via 32 parallel expert agents to stress-test ideas, strategies, plans |
| [Remotion](../Releases/v5.0.0/.claude/skills/Remotion/) | Programmatic video with React via Remotion — compositions, sequences, motion graphics to MP4 |
| [Research](../Releases/v5.0.0/.claude/skills/Research/) | Multi-agent research with 4 depth modes (quick, standard, extensive, deep investigation) |
| [RootCauseAnalysis](../Releases/v5.0.0/.claude/skills/RootCauseAnalysis/) | Structured incident investigation: 5 Whys, Fishbone, Postmortem, Fault Tree, Kepner-Tregoe |
| [Sales](../Releases/v5.0.0/.claude/skills/Sales/) | Transform product docs into sales narratives with charcoal sketch art and talking points |
| [Science](../Releases/v5.0.0/.claude/skills/Science/) | Scientific method as a universal problem-solving algorithm — goal, hypotheses, experiments |
| [SystemsThinking](../Releases/v5.0.0/.claude/skills/SystemsThinking/) | Structural analysis via Iceberg, Causal Loop, Archetypes, Leverage Points, Concept Map |
| [Telos](../Releases/v5.0.0/.claude/skills/Telos/) | Dual-context Life OS — read and update goals, beliefs, wisdom, missions, mental models |
| [USMetrics](../Releases/v5.0.0/.claude/skills/USMetrics/) | 68 US economic indicators from FRED, EIA, Treasury, BLS, Census APIs |
| [Webdesign](../Releases/v5.0.0/.claude/skills/Webdesign/) | Web/UI design via Anthropic's Claude Design (claude.ai/design) with frontend handoff |
| [WorldThreatModel](../Releases/v5.0.0/.claude/skills/WorldThreatModel/) | Stress-test ideas, strategies, investments against 11 time horizons from 6 months to 50 years |
| [WriteStory](../Releases/v5.0.0/.claude/skills/WriteStory/) | Fiction across seven narrative layers — Storr, Pressfield, Forsyth |

---

## Curated Bundles

Pre-built combinations with their own install wizards. Useful when you want a thematic grouping installed in one shot.

| Bundle | What's inside |
|--------|---------------|
| [ContextSearch](ContextSearch/) | `/context-search` and `/cs` slash commands |
| [Agents](Agents/) | Custom agent composition |
| [ContentAnalysis](ContentAnalysis/) | Wisdom extraction from videos, podcasts, articles, YouTube |
| [Investigation](Investigation/) | People search and identity verification |
| [Media](Media/) | Visual and video content — illustrations, diagrams, Remotion |
| [Research](Research/) | Multi-agent research with quick/standard/extensive/deep modes |
| [Scraping](Scraping/) | Bright Data + Apify scraping bundle |
| [Telos](Telos/) | Life OS goals, beliefs, wisdom, dashboards |
| [Thinking](Thinking/) | First principles, council, red team, science, brainstorming |
| [USMetrics](USMetrics/) | 68 US economic indicators |
| [Utilities](Utilities/) | Developer tools — CLI generation, skill scaffolding, Fabric, browser automation |

---

## Pack Structure

```
PackName/
├── README.md    # What it does and why
├── INSTALL.md   # Step-by-step wizard for AI-assisted installation
├── VERIFY.md    # Post-install verification checklist
└── src/         # Source files to copy
```
