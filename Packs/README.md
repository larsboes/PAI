<p align="center">
  <img src="icons/packs-v2.png" alt="PAI Packs" width="256">
</p>

# PAI Packs

> The best AI in the world should be available to everyone

Right now the most powerful AI setups are being built inside companies for efficiency and profits. But the purpose of technology is to serve humans—not the other way around.

**PAI Packs** are how we make that happen. Each pack is a battle-tested capability extracted from a production AI system, packaged so anyone can install it. Think of them like learning kung-fu in The Matrix—complete, tested capabilities you can download directly into your system.

These aren't theoretical examples or proof-of-concepts. They're the actual tools and systems running in production every day, now available to you. A full platform for magnifying yourself and your impact on the world.

---

## Why Packs?

The old approach was "here's my whole system—clone it and customize." That created a Jenga tower of dependencies where changing one piece broke three others.

**Packs are different:**
- **Self-contained** - Works without understanding the rest of the system
- **Independently installable** - Add what you need, skip what you don't
- **Platform-agnostic** - Works with Claude Code, OpenCode, Cursor, or custom systems
- **AI-installable** - Give your AI the pack file, it handles the rest

**The key insight:** Give your AI the complete context it needs, and it can integrate the pack into *your* system autonomously.

---

## System Architecture

<p align="center">
  <img src="icons/pai-system-architecture.png" alt="PAI System Architecture" width="800">
</p>

**PAI organizes capabilities in a clear hierarchy:**

```
PAI System
    └── Bundles (curated collections for specific goals)
            └── Packs (individual capabilities)
                    └── Contents (code, hooks, tools, workflows, config)
```

- **Bundles** group related packs that work well together
- **Packs** are self-contained capabilities you can install independently
- **Contents** are the actual code, hooks, tools, and configuration inside each pack

---

## What's in a Pack?

Each pack is a single markdown file containing everything needed to go from zero to working:

- **The Problem** - What challenge this pack solves
- **The Solution** - How it solves it (with architecture diagrams)
- **Complete Code** - All hooks, tools, libraries, and configuration
- **Installation Instructions** - Step-by-step for both AI and manual installation
- **Verification Steps** - How to confirm it's working
- **Examples** - Real usage scenarios

**Key principle:** Give your AI the pack file, and it can install the entire capability into your system autonomously.

---

## Available Packs

| Pack | Version | Category | Bundle | Description |
|------|---------|----------|--------|-------------|
| [**kai-hook-system**](kai-hook-system.md) | 1.0.0 | Foundation | [Kai](../Bundles/Kai/) | Event-driven automation framework - the foundation for all hook-based capabilities |
| [**kai-history-system**](kai-history-system.md) | 1.0.0 | Infrastructure | [Kai](../Bundles/Kai/) | Granular context-tracking that captures all work, decisions, and learnings automatically |
| [**kai-skill-system**](kai-skill-system.md) | 1.0.0 | Routing | [Kai](../Bundles/Kai/) | Capability routing through standardized SKILL.md format with dynamic loading |
| [**kai-voice-system**](kai-voice-system.md) | 1.1.0 | Notifications | [Kai](../Bundles/Kai/) | Voice notifications with ElevenLabs TTS and prosody enhancement for natural speech |
| [**kai-identity**](kai-identity.md) | 1.0.0 | Personality | [Kai](../Bundles/Kai/) | Personal AI identity with response format, calibration, constitution, and 14 principles |

---

## Installation Order

Packs have dependencies. Install in this order:

```
1. kai-hook-system     ← Foundation (no dependencies)
2. kai-history-system  ← Depends on hooks
3. kai-skill-system    ← Depends on hooks, history
4. kai-voice-system    ← Depends on hooks, skills
5. kai-identity        ← Depends on all above
```

**Or install the complete [Kai Bundle](../Bundles/Kai/)** which handles ordering automatically.

---

## How to Install a Pack

### Option 1: AI-Assisted (Recommended)

Give the pack file to your AI agent:

```
Install this pack into my system. Use PAI_DIR="~/.config/pai" and DA="MyAI".
```

Your AI will:
1. Check dependencies
2. Create directories
3. Save all code files
4. Configure hooks
5. Verify installation

### Option 2: Manual

Open any pack file and follow the "Installation" section step by step.

---

## Pack Categories

| Category | Purpose | Examples |
|----------|---------|----------|
| **Foundation** | Core infrastructure that other packs depend on | Hook System |
| **Infrastructure** | Systems that run automatically in the background | History System |
| **Routing** | Intent detection and capability dispatch | Skill System |
| **Notifications** | User feedback and accessibility | Voice System |
| **Personality** | Identity, response format, principles | Identity |

---

## Creating Your Own Pack

See [PAIPackTemplate.md](../PAIPackTemplate.md) for the complete pack specification.

**Quick checklist:**
- [ ] Single markdown file with YAML frontmatter
- [ ] 256x256 transparent icon in `icons/`
- [ ] Complete, working code (no snippets or placeholders)
- [ ] End-to-end implementation (no "beyond scope" gaps)
- [ ] Both AI-assisted and manual installation instructions
- [ ] Verification commands to confirm success

---

## Pack Quality Standards

Every pack in this directory must be:

1. **Complete** - Everything needed to install, no missing components
2. **Self-contained** - Works without external documentation
3. **Tested** - Verified working in production (extracted from Kai)
4. **Sanitized** - No personal data, credentials, or hardcoded paths
5. **Documented** - Clear problem statement, solution, and examples

---

## Related

- [**Bundles/**](../Bundles/) - Curated collections of packs
- [**PAIPackTemplate.md**](../PAIPackTemplate.md) - Full pack specification
- [**README.md**](../README.md) - PAI project overview

---

*Each pack is extracted from Daniel Miessler's production Kai system - battle-tested capabilities packaged for anyone to use.*
