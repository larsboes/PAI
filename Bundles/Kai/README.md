<p align="center">
  <img src="kai.png" alt="The Official PAI (Kai) Bundle" width="256">
</p>

# The Official PAI (Kai) Bundle

> **FOR AI AGENTS:** Install each Pack listed below by reading its file and following the installation instructions.

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

## Installation

### Prerequisites

- [Bun](https://bun.sh): `curl -fsSL https://bun.sh/install | bash`
- [Claude Code](https://claude.com/claude-code) or compatible AI coding assistant

### How It Works

**The entire installation is AI-driven.** Give each pack file to your AI agent, and it reads the instructions and installs everything autonomously. No scripts to run—just hand over the markdown files.

### Configuration Variables

Before starting, decide on these values:

| Variable | Default | Description |
|----------|---------|-------------|
| `PAI_DIR` | `~/.config/pai` | Where PAI stores files (hooks, history, skills) |
| `DA` | `PAI` | Your AI assistant's name (e.g., Kai, Atlas, Nova) |
| `TIME_ZONE` | System default | Timezone for timestamps |
| `ELEVENLABS_API_KEY` | - | Optional: For voice notifications |
| `ELEVENLABS_VOICE_ID` | Default voice | Optional: Which voice to use |

### Step-by-Step Installation

#### Step 1: System Analysis (REQUIRED)

Before installing, analyze your current system state:

```bash
# 1. Check existing PAI installation
PAI_CHECK="${PAI_DIR:-$HOME/.config/pai}"
echo "=== PAI Installation Check ==="
echo "PAI_DIR: ${PAI_DIR:-'NOT SET - will use ~/.config/pai'}"

if [ -d "$PAI_CHECK" ]; then
  echo "⚠️  PAI directory EXISTS at: $PAI_CHECK"
  echo "Contents:"
  ls -la "$PAI_CHECK" 2>/dev/null
else
  echo "✓ Clean install - no existing PAI directory"
fi

# 2. Check Claude settings for existing hooks
echo ""
echo "=== Claude Settings Check ==="
if [ -f "$HOME/.claude/settings.json" ]; then
  if grep -q '"hooks"' "$HOME/.claude/settings.json"; then
    echo "⚠️  Existing hooks found in settings.json:"
    grep -A 10 '"hooks"' "$HOME/.claude/settings.json" | head -15
  else
    echo "✓ No existing hooks in settings.json"
  fi
else
  echo "✓ No settings.json (will be created)"
fi

# 3. Check environment
echo ""
echo "=== Environment Check ==="
echo "DA (AI name): ${DA:-'NOT SET'}"
echo "TIME_ZONE: ${TIME_ZONE:-'NOT SET'}"
echo "ELEVENLABS_API_KEY: ${ELEVENLABS_API_KEY:+'SET'}${ELEVENLABS_API_KEY:-'NOT SET'}"
```

#### Step 2: Backup (If Conflicts Detected)

```bash
BACKUP_DIR="$HOME/.pai-backup/$(date +%Y%m%d-%H%M%S)"
PAI_CHECK="${PAI_DIR:-$HOME/.config/pai}"

# Backup existing PAI directory
if [ -d "$PAI_CHECK" ]; then
  mkdir -p "$BACKUP_DIR"
  cp -r "$PAI_CHECK" "$BACKUP_DIR/pai"
  echo "✓ Backed up PAI to $BACKUP_DIR/pai"
fi

# Backup Claude settings
if [ -f "$HOME/.claude/settings.json" ]; then
  mkdir -p "$BACKUP_DIR"
  cp "$HOME/.claude/settings.json" "$BACKUP_DIR/settings.json"
  echo "✓ Backed up settings.json to $BACKUP_DIR/"
fi
```

#### Step 3: Set Up Environment

```bash
# Add to your shell profile (~/.zshrc or ~/.bashrc)
export PAI_DIR="$HOME/.config/pai"
export DA="YourAIName"  # Your AI's name
export TIME_ZONE="America/Los_Angeles"  # Your timezone
export PAI_SOURCE_APP="$DA"

# Reload shell
source ~/.zshrc  # or ~/.bashrc
```

#### Step 4: Create Directory Structure

```bash
mkdir -p $PAI_DIR/{hooks/lib,History/{Sessions,Learnings,Research,Decisions},Skills/CORE,Tools,voice}
```

#### Step 5: Install Packs In Order

Give each pack file to your AI with the context:
```
Install this pack using PAI_DIR="[your path]" and DA="[your AI name]".
Run the Pre-Installation System Analysis section first to check for conflicts.
```

### Pack Installation Sequence

Install each pack in order by giving your AI the pack file:

| # | Pack | Command | Verification |
|---|------|---------|--------------|
| 1 | Hook System | Give AI: `Packs/kai-hook-system.md` | `ls $PAI_DIR/hooks/` |
| 2 | History System | Give AI: `Packs/kai-history-system.md` | `ls $PAI_DIR/History/` |
| 3 | Skill System | Give AI: `Packs/kai-skill-system.md` | `bun run $PAI_DIR/Tools/SkillSearch.ts --list` |
| 4 | Voice System | Give AI: `Packs/kai-voice-system.md` | Check stop-hook.ts exists |
| 5 | Identity | Give AI: `Packs/kai-identity.md` | `ls $PAI_DIR/Skills/CORE/` |

**For each pack, tell your AI:**
```
Install this pack using:
- PAI_DIR: [your configured path]
- DA: [your AI name]
```

### Verify Bundle

After installing all packs:

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

# Check skills are indexed
bun run $PAI_DIR/Tools/SkillSearch.ts --list

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
