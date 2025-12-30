<p align="center">
  <img src="kai.png" alt="The Official PAI (Kai) Bundle" width="256">
</p>

# The Official PAI (Kai) Bundle

> **FOR AI AGENTS:** You are about to install the complete Kai bundle. Walk your principal through an interactive wizard to configure their system, then install each pack in order.

## AI Installation Wizard

**Start by asking your principal these questions:**

1. **Where should PAI be installed?** (default: `~/.config/pai`)
2. **What would you like to name your AI assistant?** (e.g., Kai, Atlas, Nova, Jarvis)
3. **What's your timezone?** (e.g., America/Los_Angeles, Europe/London)
4. **Do you have an ElevenLabs API key for voice notifications?** (optional - skip if no)
5. **If yes, what's your preferred ElevenLabs voice ID?** (optional)

**After gathering answers, set these variables:**
```bash
export PAI_DIR="[their answer or ~/.config/pai]"
export DA="[their AI name]"
export TIME_ZONE="[their timezone]"
export ELEVENLABS_API_KEY="[if provided]"
export ELEVENLABS_VOICE_ID="[if provided]"
```

**Then proceed through each pack in the Installation Order section, reading each pack file and installing it with the configured variables.**

---

## About This Bundle

This is *a highly opinionated* bundle of PAI Packs that gets near feature parity to my (Daniel's) own, active Kai system I use every day, and that started the project. I have replicated most of the functionality of my system into individual Packs, which are all contained within this bundle.

## Why This Is Different

This sounds similar to custom ChatGPT configurations or AI assistant presets, which also enhance AI capabilities. What makes this approach different?

Custom configurations are static and monolithic—everything loads every time. The Kai Bundle is a modular, layered system where each Pack builds on the previous, creating emergent capabilities through composition. Hook events trigger history capture which feeds skill context which drives voice output. Each layer works independently, but together they create an AI infrastructure that feels like a production system, not a chatbot with extra prompts.

- Modular composition creates emergent capabilities through layering
- Each Pack works independently but integrates seamlessly
- Event-driven architecture enables real-time intelligent automation
- Production infrastructure patterns not chatbot configuration hacks

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
| 5 | [kai-identity](../../Packs/kai-identity.md) | Personality layer | All above |

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
| kai-identity | **Available** |

*All Packs are now available. Install in order to get the complete Kai experience.*

---

## Prerequisites

- [Bun](https://bun.sh): `curl -fsSL https://bun.sh/install | bash`
- [Claude Code](https://claude.com/claude-code) or compatible AI coding assistant

---

## Verification

After installing all packs, verify the bundle:

```bash
# Check complete directory structure
ls -la $PAI_DIR/

# Expected directories:
# hooks/       - Event-driven automation
# History/     - Sessions, Learnings, Research, Decisions
# Skills/      - CORE and other skills
# Tools/       - CLI utilities
# voice/       - Voice server files

# Check hooks are registered
cat ~/.claude/settings.json | grep -A 5 "hooks"

# Restart Claude Code to activate all hooks
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
