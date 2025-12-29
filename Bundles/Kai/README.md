<p align="center">
  <img src="icon.png" alt="Kai Bundle" width="256">
</p>

# Kai Bundle

> **FOR AI AGENTS:** Install each pack listed below by reading its file and following the installation instructions.

The official PAI bundle - complete personal AI infrastructure extracted from Daniel Miessler's production Kai system.

---

## What You Get

When fully installed, the Kai Bundle gives you an AI system that:

- **Remembers everything** - Every decision, learning, and session captured automatically
- **Protects you** - Security hooks blocking prompt injection and dangerous operations
- **Scales with delegation** - Spawn specialized agents for parallel work
- **Improves itself** - Meta-systems that capture and encode learnings
- **Works your way** - Customizable skills, personalities, and workflows

---

## Packs

| # | Pack | Purpose |
|---|------|---------|
| 1 | [kai-history-system](../../Packs/kai-history-system.md) | Automatic memory - captures all work, decisions, learnings |

*More packs added as they're extracted from the Kai system.*

---

## Installation

### Prerequisites

- [Bun](https://bun.sh): `curl -fsSL https://bun.sh/install | bash`
- [Claude Code](https://claude.com/claude-code) installed

### Install

```
Give your AI: ~/Projects/PAI/Packs/kai-history-system.md
Say: "Install this pack into my system"
```

### Verify

```bash
ls ~/.config/pai/history/
# Should show: sessions, learnings, research, decisions, execution, raw-outputs
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
