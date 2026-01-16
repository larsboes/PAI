<div align="center">

<img src="../release-icon.png" alt="PAI v2.3" width="200">

# PAI v2.3.0 — Full Releases Return

**The most significant release since v2.0**

[![GitHub Release](https://img.shields.io/badge/Release-v2.3.0-8B5CF6?style=flat&logo=github)](https://github.com/danielmiessler/PAI/releases/tag/v2.3.0)
[![Skills](https://img.shields.io/badge/Skills-20-22C55E?style=flat)](skills/)
[![Agents](https://img.shields.io/badge/Agents-11-F97316?style=flat)](agents/)
[![Hooks](https://img.shields.io/badge/Hooks-14-3B82F6?style=flat)](hooks/)

</div>

---

## What's New in v2.3

PAI v2.3 brings back **complete, functional releases** while maintaining the modular Packs system. This release addresses the most common feedback since v2.0: *"I love the modular approach, but I just want the whole thing."*

Now you have both options:
- **Full Release**: Copy the `.claude/` directory and start immediately
- **Individual Packs**: Install specific capabilities as needed

### Highlights

| Feature | Description |
|---------|-------------|
| **Full `.claude/` Directory** | Complete, functional PAI installation ready to copy |
| **Euphoric Surprise** | New north star philosophy embedded throughout |
| **Customization as Principle #1** | PAI exists to help YOU accomplish YOUR goals |
| **14 Lifecycle Hooks** | Voice, memory, security, sentiment, learning |
| **Responsive Status Line** | 4-mode adaptive display with learning signals |
| **11 Named Agents** | Persistent personalities for specialized work |
| **20 Production Skills** | Battle-tested capabilities from production PAI |
| **Observability Dashboard** | Real-time agent monitoring and analytics |

---

## Release Contents

```
.claude/
├── settings.json           # Pre-configured, works immediately
├── install.ts              # Interactive setup wizard
├── statusline-command.sh   # Responsive 4-mode status line
├── CLAUDE.md               # Entry point for Claude Code
├── INSTALL.md              # Installation guide
│
├── skills/                 # 20 production skills
│   ├── CORE/               # System foundation (auto-loads)
│   ├── THEALGORITHM/       # Universal execution engine
│   ├── Agents/             # Dynamic agent composition
│   ├── Art/                # Visual content creation
│   ├── Browser/            # Debug-first browser automation
│   ├── Research/           # Multi-source research system
│   └── ... (15 more)
│
├── agents/                 # 11 named agents with personalities
│   ├── Architect.md        # System design specialist
│   ├── Engineer.md         # Principal engineer patterns
│   ├── Artist.md           # Visual content creator
│   └── ... (8 more)
│
├── hooks/                  # 14 lifecycle hooks
│   ├── lib/                # Shared hook libraries
│   ├── handlers/           # Handler implementations
│   └── *.hook.ts           # Hook scripts
│
├── MEMORY/                 # Persistent memory system
│   ├── LEARNINGS/          # Captured insights
│   ├── SIGNALS/            # User feedback ratings
│   ├── SESSIONS/           # Session summaries
│   └── RESEARCH/           # Research artifacts
│
├── Observability/          # Agent monitoring dashboard
│   ├── apps/client/        # Vue.js dashboard
│   ├── apps/server/        # SQLite-backed server
│   └── Tools/              # Management scripts
│
├── USER/                   # Your customizations (private)
├── Plans/                  # Plan mode working files
└── lib/                    # Shared utilities
```

---

## Hook System (14 Hooks)

PAI's hook system extends Claude Code with voice feedback, automatic memory capture, security validation, sentiment tracking, and observability.

### Lifecycle Events

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Claude Code Session                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  SessionStart ──┬──► StartupGreeting (banner + stats)               │
│                 ├──► LoadContext (CORE skill injection)             │
│                 └──► CheckVersion (update notification)             │
│                                                                     │
│  UserPromptSubmit ──┬──► FormatEnforcer (response spec)             │
│                     ├──► AutoWorkCreation (work tracking)           │
│                     ├──► ExplicitRatingCapture (1-10 ratings)       │
│                     ├──► ImplicitSentimentCapture (mood detection)  │
│                     └──► UpdateTabTitle (tab + voice)               │
│                                                                     │
│  PreToolUse ──┬──► SecurityValidator (Bash/Edit/Write/Read)         │
│               └──► SetQuestionTab (teal state for questions)        │
│                                                                     │
│  SubagentStop ──► AgentOutputCapture (subagent results)             │
│                                                                     │
│  Stop ──► StopOrchestrator ──┬──► ResponseCapture                   │
│                              ├──► TabTitleReset                     │
│                              └──► VoiceCompletion                   │
│                                                                     │
│  SessionEnd ──┬──► WorkCompletionLearning (insight extraction)      │
│               └──► SessionSummary (work completion)                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Hook Registry

| Hook | Event | Purpose |
|------|-------|---------|
| `StartupGreeting` | SessionStart | Display PAI banner with system stats |
| `LoadContext` | SessionStart | Inject CORE skill into context |
| `CheckVersion` | SessionStart | Notify if Claude Code update available |
| `FormatEnforcer` | UserPromptSubmit | Inject response format specification |
| `AutoWorkCreation` | UserPromptSubmit | Create/update work directories |
| `ExplicitRatingCapture` | UserPromptSubmit | Capture explicit 1-10 ratings from user |
| `ImplicitSentimentCapture` | UserPromptSubmit | Detect emotional sentiment in messages |
| `UpdateTabTitle` | UserPromptSubmit | Set tab title + voice announcement |
| `SecurityValidator` | PreToolUse | Validate dangerous operations |
| `SetQuestionTab` | PreToolUse | Set teal tab state for questions |
| `AgentOutputCapture` | SubagentStop | Capture subagent outputs for memory |
| `StopOrchestrator` | Stop | Coordinate tab reset + voice completion |
| `WorkCompletionLearning` | SessionEnd | Extract learnings from completed work |
| `SessionSummary` | SessionEnd | Mark work as completed |

### Shared Libraries (hooks/lib/)

| Library | Purpose |
|---------|---------|
| `identity.ts` | Get DA name, principal from settings |
| `notifications.ts` | Voice server + push notification integration |
| `paths.ts` | Canonical path construction |
| `learning-utils.ts` | Learning categorization and storage |
| `response-format.ts` | Tab summary validation |
| `metadata-extraction.ts` | Parse assistant responses |
| `observability.ts` | Trace emitting for monitoring |
| `IdealState.ts` | ISC tracking for Algorithm integration |

---

## Memory System

PAI's memory system enables continuous learning—every session, insight, and signal is captured automatically.

```
MEMORY/
├── LEARNINGS/          # Insights extracted from sessions
│   └── *.md            # Categorized learnings
│
├── SIGNALS/            # User feedback for learning loop
│   └── ratings.jsonl   # Explicit + implicit ratings
│
├── SESSIONS/           # Session summaries
│   └── *.json          # Session metadata and outcomes
│
├── RESEARCH/           # Research artifacts
│   └── */              # Topic-organized research
│
└── PAISYSTEMUPDATES/   # System upgrade documentation
    └── *.md            # Upgrade notes and changelogs
```

### Learning Loop

```
User Interaction
      │
      ├─► Explicit Rating ("8 - great work")
      │         │
      │         └─► ExplicitRatingCapture ─► ratings.jsonl
      │
      └─► Implicit Sentiment ("this is amazing!")
                │
                └─► ImplicitSentimentCapture ─► ratings.jsonl
                              │
                              ▼
                    Status Line Display
                    (shows learning signal)
                              │
                              ▼
                    WorkCompletionLearning
                    (extracts insights at session end)
```

---

## Status Line

PAI includes a **responsive 4-mode status line** that adapts to terminal width:

| Mode | Width | Display |
|------|-------|---------|
| `nano` | <35 cols | Minimal single-line |
| `micro` | 35-54 | Compact with key metrics |
| `mini` | 55-79 | Balanced information |
| `normal` | 80+ | Full display with sparklines |

### Status Line Components

- **Greeting**: Time-based greeting with principal name
- **Wielding**: Current model being used
- **Git**: Repository and branch status
- **Learning**: Recent rating signal with trend
- **Context**: Token usage percentage
- **Quote**: Rotating inspirational quote

Example (normal mode):
```
Good evening, Daniel │ Wielding opus │ PAI main │ Learning: 8.2↑ │ Context: 42% │ "Ship it."
```

---

## Named Agents (11)

PAI includes 11 named agents with persistent personalities, each specialized for different tasks:

| Agent | Specialty | Description |
|-------|-----------|-------------|
| **Architect** | System Design | PhD-level distributed systems, Fortune 10 experience |
| **Engineer** | Implementation | Principal engineer patterns, TDD, constitutional principles |
| **Artist** | Visual Content | Prompt engineering, model selection, editorial standards |
| **Designer** | UX/UI | Design school pedigree, shadcn/ui, accessibility |
| **QATester** | Quality Assurance | Browser automation, Gate 4 verification |
| **Pentester** | Security Testing | Vulnerability assessment, ethical boundaries |
| **Intern** | General Purpose | 176 IQ genius, high-agency problem solver |
| **GeminiResearcher** | Multi-Perspective | Google Gemini, parallel investigations |
| **GrokResearcher** | Contrarian Analysis | xAI Grok, unbiased fact-based research |
| **CodexResearcher** | Technical Archaeology | O3/GPT-5-Codex, curiosity-driven exploration |
| **ClaudeResearcher** | Academic Research | Claude WebSearch, scholarly synthesis |

---

## Skills (20)

Production-tested skills extracted from active PAI systems:

### Core Infrastructure

| Skill | Purpose |
|-------|---------|
| **CORE** | System foundation, auto-loads at session start |
| **THEALGORITHM** | Universal execution engine (Current → Ideal) |
| **System** | Integrity checks, documentation, security scans |
| **PAIUpgrade** | Extract system improvements from content |

### Research & Intelligence

| Skill | Purpose |
|-------|---------|
| **Research** | Multi-source research with tiered depth |
| **OSINT** | Open source intelligence gathering |
| **PrivateInvestigator** | Ethical people-finding |
| **AnnualReports** | Security report aggregation and analysis |

### Creative & Content

| Skill | Purpose |
|-------|---------|
| **Art** | Complete visual content system |
| **Prompting** | Meta-prompting and template generation |
| **Council** | Multi-agent debate system |
| **RedTeam** | Adversarial analysis with 32 agents |

### Development & Testing

| Skill | Purpose |
|-------|---------|
| **Browser** | Debug-first browser automation |
| **CreateCLI** | Generate TypeScript CLIs |
| **CreateSkill** | Create and validate skills |
| **Agents** | Dynamic agent composition |

### Specialized

| Skill | Purpose |
|-------|---------|
| **Telos** | Life OS and project analysis |
| **FirstPrinciples** | Root cause analysis |
| **BrightData** | Progressive URL scraping |
| **Recon** | Security reconnaissance |

---

## Observability Dashboard

Real-time monitoring of PAI agent activity:

```
Observability/
├── apps/
│   ├── client/          # Vue.js dashboard
│   │   ├── src/
│   │   │   ├── composables/
│   │   │   │   ├── useAdvancedMetrics.ts
│   │   │   │   ├── useAgentChartData.ts
│   │   │   │   ├── useEventSearch.ts
│   │   │   │   ├── useHeatLevel.ts
│   │   │   │   ├── useTimelineIntelligence.ts
│   │   │   │   └── useWebSocket.ts
│   │   │   └── ...
│   │   └── ...
│   │
│   └── server/          # SQLite-backed server
│       ├── src/
│       │   ├── db.ts           # Database operations
│       │   ├── file-ingest.ts  # Log ingestion
│       │   ├── task-watcher.ts # Task monitoring
│       │   └── index.ts        # Server entry
│       └── ...
│
└── Tools/
    └── ManageServer.ts   # Start/stop/restart
```

### Dashboard Features

- **Real-time event timeline** with search and filtering
- **Agent heat level** visualization
- **Advanced metrics** with sparkline charts
- **HITL notifications** for human-in-the-loop events
- **Remote agent** monitoring
- **Theme support** (Tokyo Night, etc.)

---

## Security System

Multi-layer defense with pattern-based validation:

### Security Layers

| Layer | Component | Function |
|-------|-----------|----------|
| 1 | `settings.json` permissions | Tool-level allow/deny/ask |
| 2 | `SecurityValidator.hook.ts` | PreToolUse command filtering |
| 3 | `patterns.yaml` | Pattern-based security rules |
| 4 | `USER/PAISECURITYSYSTEM/` | Personal security policies |

### Protected Operations

```json
{
  "permissions": {
    "ask": [
      "Bash(rm -rf /)",
      "Bash(git push --force:*)",
      "Read(~/.ssh/id_*)",
      "Write(~/.claude/settings.json)"
    ]
  }
}
```

### Security Event Logging

All security decisions logged to `MEMORY/SECURITY/security-events.jsonl` for audit.

---

## Installation

### Quick Start (Full Installation)

```bash
# 1. Backup existing installation (if any)
mv ~/.claude ~/.claude-backup

# 2. Copy the release
cp -r .claude ~/

# 3. Run the setup wizard
cd ~/.claude
bun run install.ts

# 4. Start PAI
claude
```

### What the Wizard Does

1. **Fixes permissions** - Makes hooks executable
2. **Asks your name** - Personalizes the experience
3. **Configures voice** - Male/female/neutral options
4. **Tests voice server** - Verifies TTS works
5. **Sets up aliases** - Adds `pai` command to shell
6. **Validates installation** - Checks all components

### Prerequisites

- **Bun**: `curl -fsSL https://bun.sh/install | bash`
- **Claude Code**: `npm install -g @anthropic-ai/claude-code`
- **ElevenLabs API Key** (optional): For voice synthesis

---

## Configuration

### settings.json (Pre-configured)

The release includes a working `settings.json` with:

- Full tool permissions (no "dangerously skip" prompts)
- All 14 hooks configured
- Security policies for dangerous operations
- Voice synthesis settings
- Status line configuration

### Customization Points

| File | Purpose |
|------|---------|
| `settings.json` | Identity, permissions, hooks |
| `USER/` | Personal customizations (never overwritten) |
| `USER/PAISECURITYSYSTEM/` | Personal security rules |
| `USER/RESPONSEFORMAT.md` | Custom response format |

---

## What's Changed Since v2.1

### Major Changes

- **Full releases restored** - Complete `.claude/` directory
- **Euphoric Surprise** - New north star philosophy
- **Customization as Principle #1** - PAI exists for your goals
- **23 packs updated** - All packs refreshed for v2.3
- **Visual README redesign** - Technical diagrams and badges

### Infrastructure

- **Retired pai-history-system** - Migrated to MEMORY in core
- **Security system upgrade** - Directory-based architecture
- **Voice integration improvements** - Better reliability
- **AI wizard format** - Standardized pack installation

### New Hook Features

- **WorkCompletionLearning** - Extracts insights at session end
- **ImplicitSentimentCapture** - Mood detection from messages
- **ExplicitRatingCapture** - Captures 1-10 ratings

### Status Line Improvements

- **4-mode responsive display** - Adapts to terminal width
- **Learning signal** - Shows recent ratings with trends
- **Weather integration** - Optional location-based weather
- **Quote rotation** - Inspirational quotes from your collection

---

## Verification

After installation, verify everything works:

```bash
# Run validation
bun run install.ts --validate

# Expected output:
# ✓ settings.json: Valid
# ✓ CORE skill: Found
# ✓ Skills: 20 found
# ✓ Hooks: 14 found
# ✓ Agents: 11 found
# ✓ Bun runtime: v1.x
# ✓ Claude Code: Installed
```

### Quick Test

```bash
cd ~/.claude
claude
```

PAI should:
1. Display the startup banner with stats
2. Greet you by name (or "User" if not configured)
3. Show the status line with context percentage
4. Speak "PAI here, ready to go." (if voice configured)

---

## Resources

- **GitHub**: [github.com/danielmiessler/PAI](https://github.com/danielmiessler/PAI)
- **Video Walkthrough**: [PAI Overview](https://youtu.be/Le0DLrn7ta0)
- **Philosophy**: [The Real Internet of Things](https://danielmiessler.com/blog/real-internet-of-things)
- **Maturity Model**: [Personal AI Maturity Model](https://danielmiessler.com/blog/personal-ai-maturity-model)

---

<div align="center">

**PAI v2.3.0** — Magnifying human capabilities through personalized AI infrastructure.

*Everyone deserves AI that gets better at helping them over time.*

</div>
