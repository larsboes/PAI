<p align="center">
  <img src="kai.png" alt="The Official PAI (Kai) Bundle" width="256">
</p>

# The Official PAI (Kai) Bundle

> **FOR AI AGENTS:** Install each Pack listed below by reading its file and following the installation instructions.

This is the bundle of Packs that gets near feature parity to my own Kai system I use every day, and that started the project. I have replicated most of the functionality of my system into individual Packs, which are all contained within this bundle.

---

## What You Get

When fully installed, The Official PAI (Kai) Bundle gives you:

- **History System** - Automatic capture of sessions, decisions, learnings, and research
- **Security Hooks** - Protection against prompt injection and dangerous operations
- **Skill System** - Modular capabilities with intent-based routing
- **Voice Notifications** - Spoken updates when tasks complete
- **Agent Delegation** - Spawn parallel agents for concurrent work

---

## Installation Order (CRITICAL)

**Install Packs in this exact order** - each depends on the previous:

| # | Pack | Purpose | Dependencies |
|---|------|---------|--------------|
| 1 | [kai-hook-system](../../Packs/kai-hook-system.md) | Event-driven automation | None |
| 2 | [kai-history-system](../../Packs/kai-history-system.md) | Memory and capture | Hooks |
| 3 | [kai-skill-system](../../Packs/kai-skill-system.md) | Capability routing | Hooks, History |
| 4 | [kai-voice-system](../../Packs/kai-voice-system.md) | Voice notifications | Hooks, Skills |
| 5 | [kai-da-identity](../../Packs/kai-da-identity.md) | Personality layer | All above |

### Why Order Matters

- **Hooks** are the foundation - they enable all event-driven automation
- **History** uses hooks to capture events and context
- **Skills** use hooks for invocation and history for logging
- **Voice** uses hooks for completion events and integrates with skills
- **Identity** is the CORE skill that ties everything together

### Pack Availability

| Pack | Status |
|------|--------|
| kai-hook-system | Coming Soon |
| kai-history-system | **Available** |
| kai-skill-system | **Available** |
| kai-voice-system | Coming Soon |
| kai-da-identity | Coming Soon |

*Install available Packs first. Others will be added as they're extracted from the Kai system.*

---

## Installation

### Prerequisites

- [Bun](https://bun.sh): `curl -fsSL https://bun.sh/install | bash`
- [Claude Code](https://claude.com/claude-code) installed

### Install (AI-Assisted)

For each available Pack in order:

```
1. Give your AI the Pack file
2. Say: "Install this Pack into my system"
3. Verify installation before proceeding to next Pack
```

**Current installation sequence:**

```bash
# Step 1: History System (available)
Give AI: ~/Projects/PAI/Packs/kai-history-system.md
# Verify: ls ~/.config/pai/History/

# Step 2: Skill System (available)
Give AI: ~/Projects/PAI/Packs/kai-skill-system.md
# Verify: ls ~/.config/pai/Skills/ && bun run ~/.config/pai/Tools/SkillSearch.ts --list
```

### Verify Bundle

After installing available Packs:

```bash
# Check History
ls ~/.config/pai/History/
# Should show: Sessions/, Learnings/, Research/, Decisions/

# Check Skills
ls ~/.config/pai/Skills/
# Should show: CORE/, CreateSkill/, skill-index.json

# Search capabilities
bun run ~/.config/pai/Tools/SkillSearch.ts --list
```

---

## The 14 Founding Principles

The Kai system embeds these principles from [PAI](https://danielmiessler.com/blog/personal-ai-infrastructure):

1. **Clear Thinking + Prompting is King** - Good prompts come from clear thinking
2. **Scaffolding > Model** - Architecture matters more than which model
3. **As Deterministic as Possible** - Templates and consistent patterns
4. **Code Before Prompts** - Use AI only for what actually needs intelligence
5. **Spec / Test / Evals First** - Write specifications and tests before building
6. **UNIX Philosophy** - Do one thing well, make tools composable
7. **ENG / SRE Principles** - Treat AI infrastructure like production software
8. **CLI as Interface** - Command-line is faster and more reliable
9. **Goal → Code → CLI → Prompts → Agents** - The decision hierarchy
10. **Meta / Self Update System** - Encode learnings so you never forget
11. **Custom Skill Management** - Modular capabilities that route intelligently
12. **Custom History System** - Everything worth knowing gets captured
13. **Custom Agent Personalities** - Different work needs different approaches
14. **Science as Cognitive Loop** - Hypothesis → Experiment → Measure → Iterate

---

## Credits

**Author:** Daniel Miessler
**Origin:** Extracted from production Kai system (2024-2025)
