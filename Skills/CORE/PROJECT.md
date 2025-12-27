# PAI Pack System - Project Document

**Version:** 0.1.0
**Last Updated:** 2025-12-27
**Status:** Active Development

---

## Vision

PAI (Personal AI Infrastructure) provides modular "upgrade packs" that enhance AI agent systems. Like stim packs from sci-fi, each pack adds specific capabilities to a base system.

**Core Principles:**
- **Platform Agnostic** - Works with Claude Code, OpenCode, custom agent systems, or any future platform
- **Modular** - Each pack is self-contained and independently installable
- **Extracted from Production** - Packs are battle-tested features extracted from the Kai system

---

## Terminology

| Term | Definition |
|------|------------|
| **Pack** | Short for "package" - a self-contained upgrade unit |
| **Feature Pack** | The full name - a package that adds a specific feature |
| **Kai** | Daniel's private implementation (the source system) |
| **PAI** | Public template/framework for others to build their own |

---

## Pack Tiers (Stack Levels)

Packs exist at different levels of the stack:

### Tier 1: INFRASTRUCTURE
Foundation-level components that other packs may depend on.
- Security validation, recovery systems, session management
- History capture, context loading, file management

### Tier 2: FRAMEWORK
Structured methodologies and thinking patterns.
- Scientific method, prompting systems, evaluation frameworks
- Development methodologies, debate structures

### Tier 3: TOOL
Specific capabilities and utilities.
- CLI generators, browser automation, content parsers
- Research orchestration, web scraping

### Tier 4: AGENT
Personality definitions and orchestration patterns.
- Agent factories, personality rosters
- Delegation patterns, parallel execution

### Tier 5: INTEGRATION
Connections to external services and platforms.
- Voice systems, observability dashboards
- Deployment patterns, API integrations

### Tier 6: DOMAIN
Specialized knowledge for specific use cases.
- Blog workflows, newsletter systems
- Security assessment, content creation

---

## Potential Packs (Extracted from Kai)

### Tier 1: Infrastructure Packs

| Pack | Source | Description |
|------|--------|-------------|
| Security-Validator | Hooks/security-validator.ts | 10-category attack pattern detection (prompt injection, reverse shells, persona hijacking). Pre-compiled regex, <50ms execution. |
| Recovery-Journal | Hooks/recovery-journal.ts | Pre-execution file snapshots for destructive operations. Async, non-blocking recovery points. |
| Session-Progress | Tools/SessionProgress.ts | Multi-session work continuation with handoff artifacts. JSON-based state tracking. |
| Feature-Registry | Tools/FeatureRegistry.ts | Feature tracking with verification gates. Single-feature focus enforcement. |
| History-Capture | Hooks/capture-tool-output.ts | Daily JSONL logging of all tool executions. Organized by date. |
| History-Archive | Tools/Kai.ts | Compression and retention of history files. Monthly tar.gz archival. |
| Context-Loader | Hooks/load-core-context.ts | Inject custom context at session start. Bypasses activation logic. |
| Tab-Title-Manager | Hooks/update-tab-*.ts | Terminal tab title automation based on activity. |

### Tier 2: Framework Packs

| Pack | Source | Description |
|------|--------|-------------|
| Science-Method | Skills/Science/ | Universal cognitive loop: Goal → Hypothesis → Experiment → Measure → Analyze → Iterate |
| Prompting-System | Skills/Prompting/ | Meta-prompting with 5 primitives (Roster, Voice, Structure, Briefing, Gate). Template rendering. |
| Evals-Framework | Skills/Evals/ | LLM-as-Judge evaluation system. Multi-model panels, statistical rigor, A/B testing. |
| SDD-Methodology | Skills/Development/ | Spec-Driven Development with TDD. Constitution → Spec → Plan → Implement. |
| Council-Debate | Skills/Council/ | Multi-agent collaborative-adversarial debate. 3-round structured discussion. |
| RedTeam-Analysis | Skills/RedTeam/ | 32-perspective adversarial analysis. Atomic decomposition → parallel attack → synthesis. |
| First-Principles | Skills/FirstPrinciples/ | Fundamental decomposition and root cause analysis framework. |
| BeCreative-Thinking | Skills/BeCreative/ | UltraThink + Verbalized Sampling for enhanced creativity. |

### Tier 3: Tool Packs

| Pack | Source | Description |
|------|--------|-------------|
| CLI-Generator | Skills/CreateCLI/ | 3-tier TypeScript CLI generation (llcli → Commander → oclif) |
| Browser-Automation | Skills/BrowserAutomation/ | Natural language browser control via Stagehand. Navigate, act, extract, screenshot. |
| Content-Parser | Skills/Parser/ | Parse URLs/files/videos to structured JSON. Entity extraction with collision detection. |
| Skill-Discovery | Tools/SkillSearch.ts | Dynamic skill discovery and indexing system. |
| Research-Orchestrator | Skills/Research/ | Multi-source research with 3 tiers (quick/standard/extensive). Agent parallelization. |
| OSINT-Framework | Skills/OSINT/ | Open source intelligence with ethical framework. People/Company/Entity lookup. |
| Web-Scraping | Skills/BrightData/ | Progressive 4-tier scraping with escalation. |

### Tier 4: Agent Packs

| Pack | Source | Description |
|------|--------|-------------|
| Agent-Factory | Skills/Agents/ | Dynamic agent composition from traits (expertise + personality + approach). |
| Agent-Roster | Skills/Agents/ | Pre-defined agent personalities (Intern, Engineer, Architect, etc.) |
| Parallel-Delegation | Skills/CORE/Workflows/ | Patterns for spawning multiple agents in parallel. |
| Background-Agents | Skills/CORE/Workflows/ | Non-blocking background agent execution with status polling. |

### Tier 5: Integration Packs

| Pack | Source | Description |
|------|--------|-------------|
| Voice-Notifications | Hooks/stop-hook.ts | ElevenLabs TTS integration with personality-specific prosody. |
| Observability-Server | Observability/ | Multi-agent monitoring dashboard (Bun + Vue). |
| MCP-Profiles | Tools/Kai.ts | MCP configuration profile switching (minimal, full, research, etc.) |
| Cloudflare-Deploy | Skills/Cloudflare/ | Cloudflare Workers/Pages deployment patterns. |

### Tier 6: Domain Packs

| Pack | Source | Description |
|------|--------|-------------|
| Blog-Workflow | Skills/Blogging/ | VitePress blog management, deployment, analytics. |
| Newsletter-System | Skills/Newsletter/ | Beehiiv newsletter drafting, stats, quality checking. |
| Art-Generation | Skills/Art/ | Visual content system with multiple output types. |
| Social-Content | Skills/SocialPost/ | Social media content creation with technical diagrams. |
| Vuln-Management | Skills/VulnManagement/ | CVE tracking, security advisory management. |

---

## Packs NOT for Public Release

Too personal/sensitive:

- Personal/Telos - Daniel's philosophy, goals, beliefs
- Contacts - Personal contact directory
- Metrics - Tied to specific business properties
- Lifelog - Personal pendant recordings
- Gmail/Communication - Personal email
- ClickUp - Personal task management
- UL/Sales/ULCommunity - Business-specific

---

## Template System (To Be Designed)

### Pack Metadata (Draft)

```yaml
name: [pack-name]
version: [semver]
author: [github-username]
description: [one-line description]
tier: [infrastructure|framework|tool|agent|integration|domain]
platform: [agnostic|claude-code|opencode|custom]
dependencies: []
keywords: []
```

### File Structure (Draft)

```
Packs/
├── Pack-Name/
│   ├── README.md          # Documentation
│   ├── PACK.yaml          # Metadata
│   ├── install.md         # Installation instructions
│   └── [implementation files]
```

### Naming Convention

**TBD** - Options:
- kebab-case: `security-validator`
- Title-Case: `Security-Validator`
- PascalCase: `SecurityValidator`

### Versioning

**TBD** - Options:
- SemVer: `1.0.0`
- Date-based: `2025.12.27`
- Simple: `v1`, `v2`

---

## Priority Packs (First Wave)

Recommended for initial development:

1. **Security-Validator** - High value, clean extraction, universal need
2. **Science-Method** - Well-documented methodology, widely applicable
3. **Agent-Factory** - High interest, demonstrates agent patterns
4. **Session-Progress** - Solves common multi-session problem
5. **Prompting-System** - Core capability for any AI system

---

## Development Notes

### Current State
- Branch: `PAI-packages-0.1`
- Cleaned up: .deprecated folder, Docs folder, obsolete files
- Renamed: Packages → Packs

### What Kai Provides Beyond Default Claude Code

1. **60 Specialized Skills** - Domain expertise routing
2. **12+ Agent Personalities** - Named agents with voices
3. **Hooks System** - Event-driven automation
4. **Voice System** - ElevenLabs TTS integration
5. **History System (UOCS)** - Session/learning capture
6. **Two-Tier MCP** - Profile-based configuration
7. **Session Continuity** - Handoff artifacts
8. **Constitutional Framework** - Operating rules
9. **Observability Dashboard** - Agent monitoring
10. **14 Founding Principles** - Architectural philosophy

### The 14 Founding Principles

1. Clear Thinking + Prompting is King
2. Scaffolding > Model
3. As Deterministic as Possible
4. Code Before Prompts
5. Spec / Test / Evals First
6. UNIX Philosophy (Modular Tooling)
7. ENG / SRE Principles
8. CLI as Interface
9. Goal → Code → CLI → Prompts → Agents
10. Meta / Self Update System
11. Custom Skill Management
12. Custom History System
13. Custom Agent Personalities / Voices
14. Science as Cognitive Loop

---

## Open Questions

- [ ] Final naming convention for packs?
- [ ] Versioning scheme?
- [ ] Pack file structure?
- [ ] Installation mechanism?
- [ ] Dependency resolution?
- [ ] Platform compatibility indicators?

---

## Changelog

### 2025-12-27
- Initial project document created
- Identified 45+ potential packs across 6 tiers
- Cleaned up repository structure
- Renamed Packages → Packs
