---
name: Kai Core Install
pack-id: danielmiessler-pai-core-install-v1.1.0
version: 1.1.0
author: danielmiessler
description: Complete PAI core installation - skill routing, identity system, USER/SYSTEM configuration architecture. The foundation pack that makes everything else work.
type: feature
purpose-type: [productivity, automation, development]
platform: claude-code
dependencies:
  - pai-hook-system (required) - Hooks enable session context loading and events
  - pai-history-system (optional) - History capture for skill usage and learnings
keywords: [core, identity, skills, routing, architecture, installation, foundation, personality, response-format, principles, user-config, system-config]
---

<p align="center">
  <img src="../icons/pai-core-install.png" alt="Kai Core Install" width="256">
</p>

# Kai Core Install (pai-core-install)

> The complete foundation for Personal AI Infrastructure - skill routing, identity framework, USER/SYSTEM configuration, and architecture tracking in one unified pack.

> **Installation:** This pack is designed for AI-assisted installation. Give this directory to your AI and ask it to install using the wizard in `INSTALL.md`. The installation dynamically adapts to your system state. See [AI-First Installation Philosophy](../../README.md#ai-first-installation-philosophy) for details.

---

## What This Pack Provides

**Part 1: Skill System**
- **SKILL.md Format**: Standardized structure for all capabilities
- **Intent Matching**: AI activates skills based on natural language triggers
- **Workflow Routing**: Skills route to specific step-by-step procedures
- **Dynamic Loading**: Only load context when actually needed
- **Skill Discovery**: Search and browse available skills

**Part 2: Identity Framework**
- **Mandatory Response Format**: Structured output with emoji sections
- **Personality Calibration**: Numeric precision for traits (enthusiasm, precision, etc.)
- **Operating Constitution**: Core values and non-negotiable principles
- **15 Founding Principles**: Architectural philosophy for building AI infrastructure
- **First-Person Voice**: Natural, embodied communication

**Part 3: USER/SYSTEM Configuration Architecture** (NEW in v1.1.0)
- **USER/ Directory**: Personal configuration (identity, contacts, preferences)
- **SYSTEM/ Directory**: System architecture (skill system, hooks, memory, delegation)
- **Separation of Concerns**: User data stays private, system config is shareable
- **Extensive Documentation**: Every file has comprehensive headers

**Part 4: Architecture Tracking**
- **PAI Architecture.md**: Auto-generated tracking of installed packs, bundles, plugins
- **Upgrade History**: Running record of all changes to your PAI system
- **System Health**: Status checks for all installed components

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│              PAI CORE STRUCTURE                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  skills/CORE/                                                   │
│  ├── SKILL.md              # Main entry point                   │
│  ├── USER/                 # Personal configuration (v1.1.0)    │
│  │   ├── BASICINFO.md      # Name, email, social handles        │
│  │   ├── CONTACTS.md       # Contact directory                  │
│  │   ├── IDENTITY.md       # AI name and personality            │
│  │   ├── TECHSTACKPREFERENCES.md  # Tech preferences            │
│  │   ├── ASSETMANAGEMENT.md       # Digital assets              │
│  │   ├── SECURITYSYSTEM.md        # Security protocols          │
│  │   └── ...               # More user config                   │
│  └── SYSTEM/               # System architecture (v1.1.0)       │
│      ├── PAISYSTEMARCHITECTURE.md  # 15 Founding Principles     │
│      ├── SKILLSYSTEM.md    # Skill configuration                │
│      ├── MEMORYSYSTEM.md   # Memory architecture                │
│      ├── THEHOOKSYSTEM.md  # Hook lifecycle                     │
│      ├── AGENTS.md         # Agent trait system                 │
│      └── ...               # More system docs                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Skill Loading Tiers

```
┌─────────────────────────────────────────────────────────────────┐
│              SKILL LOADING TIERS                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TIER 0: CORE (Automatic)                                       │
│  ════════════════════════                                       │
│  • Loads at session start                                       │
│  • NO trigger required                                          │
│  • ALWAYS present                                               │
│                                                                 │
│─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│
│                                                                 │
│  TIER 1: Frontmatter Only (System Prompt)                       │
│  ════════════════════════════════════════                       │
│  • SKILL.md frontmatter always in context                       │
│  • USE WHEN triggers enable intent routing                      │
│  • Minimal token cost                                           │
│                                                                 │
│─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│
│                                                                 │
│  TIER 2: Full Skill (On Invoke)                                 │
│  ════════════════════════════════                               │
│  • SKILL.md body loads when triggered                           │
│  • Workflow routing table available                             │
│                                                                 │
│─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│
│                                                                 │
│  TIER 3: Workflow (On Route)                                    │
│  ════════════════════════════                                   │
│  • Specific workflow.md loads on routing                        │
│  • Step-by-step instructions                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## What's Included

### Core Files

| Component | File | Purpose |
|-----------|------|---------|
| CORE skill template | `src/skills/CORE/SKILL.md` | Main identity and routing hub |
| CreateSkill skill | `src/skills/CreateSkill/SKILL.md` | Meta-skill for creating skills |
| UpdateDocumentation | `src/skills/CORE/Workflows/UpdateDocumentation.md` | Architecture refresh workflow |

### USER/ Templates (v1.1.0)

| File | Purpose |
|------|---------|
| `README.md` | Directory overview |
| `BASICINFO.md` | Name, email, social handles |
| `CONTACTS.md` | Contact directory |
| `IDENTITY.md` | AI name and personality configuration |
| `TECHSTACKPREFERENCES.md` | Tech stack preferences |
| `ASSETMANAGEMENT.md` | Digital assets registry |
| `SECURITYSYSTEM.md` | Security protocols |
| `DEFINITIONS.md` | Canonical definitions |
| `CORECONTENT.md` | Essential content registry |
| `RESUME.md` | Professional background |
| `REMINDERS.md` | Reminder system |
| `ALGOPREFS.md` | AI behavior customizations |
| `ART.md` | Visual style guidelines |
| `ABOUTME.md` | Personal background |
| `TELOS.md` | Life operating system |

### SYSTEM/ Templates (v1.1.0)

| File | Purpose |
|------|---------|
| `README.md` | Directory overview |
| `PAISYSTEMARCHITECTURE.md` | 15 Founding Principles |
| `SKILLSYSTEM.md` | Skill configuration system |
| `MEMORYSYSTEM.md` | Memory architecture |
| `THEHOOKSYSTEM.md` | Hook lifecycle |
| `THEDELEGATIONSYSTEM.md` | Delegation patterns |
| `THENOTIFICATIONSYSTEM.md` | Notification channels |
| `AGENTS.md` | Agent trait system |
| `ACTIONS.md` | Multi-step workflows |
| `PIPELINES.md` | Pipeline orchestration |
| `TOOLS.md` | CLI utilities reference |
| `CLIFIRSTARCHITECTURE.md` | CLI-First pattern |
| `THEFABRICSYSTEM.md` | Fabric patterns |
| `SCRAPINGREFERENCE.md` | Web scraping |
| `TERMINALTABS.md` | Terminal management |
| `DOCUMENTATIONINDEX.md` | Documentation index |
| `BACKUPS.md` | Backup strategies |

### Tools

| Tool | Purpose |
|------|---------|
| `SkillSearch.ts` | Search skill index |
| `GenerateSkillIndex.ts` | Build skill index |
| `PaiArchitecture.ts` | Generate architecture tracking |

**Summary:**
- **USER/ files:** 15 templates
- **SYSTEM/ files:** 17 templates
- **Total files created:** 40+
- **Hooks registered:** 0 (uses hook system from pai-hook-system)
- **Dependencies:** pai-hook-system (required), pai-history-system (optional)

## The 15 Founding Principles

1. **Clear Thinking + Prompting is King** - Good prompts come from clear thinking
2. **Scaffolding > Model** - Architecture matters more than which model
3. **As Deterministic as Possible** - Same input → Same output
4. **Code Before Prompts** - Use AI only for what needs intelligence
5. **Spec / Test / Evals First** - Define expected behavior before building
6. **UNIX Philosophy** - Do one thing well, compose tools
7. **ENG / SRE Principles** - Apply software engineering to AI systems
8. **CLI as Interface** - Every operation accessible via command line
9. **Goal → Code → CLI → Prompts → Agents** - The proper pipeline
10. **Meta / Self Update System** - System should improve itself
11. **Custom Skill Management** - Skills are the organizational unit
12. **Custom History System** - Automatic capture of valuable work
13. **Custom Agent Personalities** - Different voices for different tasks
14. **Science as Cognitive Loop** - Hypothesis → Experiment → Measure → Iterate
15. **Permission to Fail** - Uncertainty is honest, guessing is not

## Credits

- **Author:** Daniel Miessler
- **Origin:** Extracted from production Kai system (2024-2026)
- **License:** MIT

## Works Well With

- **pai-hook-system** (required) - Enables automatic CORE loading at session start
- **pai-history-system** - Skills can reference past learnings and capture new ones
- **pai-voice-system** - Response format drives voice output

## Changelog

### 1.1.0 - 2026-01-08
- **NEW: USER/ directory** - 15 personal configuration templates
- **NEW: SYSTEM/ directory** - 17 system architecture templates
- Added extensive documentation headers to all files
- Files include customization checklists and related file references
- Separation of personal data (USER/) from system architecture (SYSTEM/)
- Updated installation and verification guides

### 1.0.1 - 2026-01-03
- Fixed CreateSkill SKILL.md - removed broken workflow references, now points to SkillSystem.md
- Improved skill validation compliance

### 1.0.0 - 2025-12-29
- Initial release
