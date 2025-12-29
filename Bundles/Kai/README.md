<p align="center">
  <img src="kai.png" alt="The Official PAI (Kai) Bundle" width="256">
</p>

# The Official PAI (Kai) Bundle

> **FOR AI AGENTS:** Install each Pack listed below by reading its file and following the installation instructions.

This is *a highly opinionated* bundle of PAI Packs that gets near feature parity to my (Daniel's) own, active Kai system I use every day, and that started the project. I have replicated most of the functionality of my system into individual Packs, which are all contained within this bundle.

---

## What This Bundle Provides

When fully installed, the Kai bundle gives you a number of features that elevate Claude Code, or whatever underlying system you are using, with fundamental enhancements that make everything about your AI experience better:

- A custom **History system** - Automatically captures sessions, decisions, learnings, and research so your AI never forgets important context
- A custom set of **Hooks** - Event-driven automation that triggers on session start, tool use, and task completion
- A custom **Skill system** - Modular capabilities that route based on intent, with dynamic loading to minimize context usage
- A custom **Voice notification system** - Spoken updates via ElevenLabs when tasks complete, with prosody enhancement for natural speech
- A custom **Agent swarm creation system** - Spawn parallel agents for concurrent work, with personality templates and voice assignments
- A custom **Security control system** - Protection against prompt injection, dangerous operations, and accidental exposure of sensitive data
- And many more

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
| kai-hook-system | **Available** |
| kai-history-system | **Available** |
| kai-skill-system | **Available** |
| kai-voice-system | **Available** |
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
# Step 1: Hook System (available) - Foundation
Give AI: ~/Projects/PAI/Packs/kai-hook-system.md
# Verify: ls ~/.config/pai/hooks/

# Step 2: History System (available)
Give AI: ~/Projects/PAI/Packs/kai-history-system.md
# Verify: ls ~/.config/pai/history/

# Step 3: Skill System (available)
Give AI: ~/Projects/PAI/Packs/kai-skill-system.md
# Verify: ls ~/.config/pai/skills/ && bun run ~/.config/pai/tools/SkillSearch.ts --list

# Step 4: Voice System (available)
Give AI: ~/Projects/PAI/Packs/kai-voice-system.md
# Verify: Check stop-hook.ts exists and notification server pattern is configured
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
