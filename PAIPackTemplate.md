# PAI Pack Template Specification

> **FOR AI AGENTS:** This document contains instructions for creating PAI Packs. When a user asks you to create a pack, follow this template exactly. Each section includes HTML comments with detailed instructions - read them carefully and replace the example content with your pack's actual content.

Each pack is a single flat markdown file with YAML frontmatter and structured sections.

**CRITICAL:** Packs must be COMPLETE. A pack must contain EVERYTHING needed to go from a fresh AI agent installation to a fully working system. No missing components, no "figure it out yourself," no snippets instead of full code.

---

## Frontmatter (Metadata)

```yaml
---
# name: (24 words max) Human-readable pack name
name: Kai History System

# pack-id: (format) {author}-{pack-name}-{variant}-v{version}
pack-id: danielmiessler-history-system-core-v1.0.0

# version: (format) SemVer major.minor.patch
version: 1.0.0

# author: (1 word) GitHub username or organization
author: danielmiessler

# description: (128 words max) One-line description
description: Granular context-tracking system for the entire AI infrastructure - captures all work, decisions, and learnings automatically

# type: (single) concept | skill | hook | plugin | agent | mcp | workflow | template | other
type: feature

# purpose-type: (multi) security | productivity | research | development | automation | integration | creativity | analysis | other
purpose-type: [productivity, automation, development]

# platform: (single) agnostic | claude-code | opencode | cursor | custom
platform: claude-code

# dependencies: (list) Required pack-ids, empty [] if none
dependencies: []

# keywords: (24 tags max) Searchable tags for discovery
keywords: [history, documentation, memory, capture, hooks, sessions, learnings, automation, context, recovery, debugging]
---
```

---

## Pack Icon (Required)

Every pack MUST have a 256x256 transparent PNG icon immediately after the frontmatter.

**Icon specs:**
- 256x256 pixels
- **ACTUAL transparent background** (not baked-in checkerboard)
- Blue (#4a90d9) primary color
- Purple (#8b5cf6) accent only (10-15%)
- Simple, recognizable at 64x64

**CRITICAL - Icon Generation:**

When generating icons, you MUST use the `--remove-bg` flag to ensure actual transparency:

```bash
bun run ~/.claude/Skills/Art/Tools/Generate.ts \
  --model nano-banana-pro \
  --prompt "[ICON_DESCRIPTION], simple flat icon design, 256x256 pixels. COLOR PALETTE: Background solid dark (#0a0a0f), Primary electric blue (#4a90d9), Accent purple (#8b5cf6). Simple enough to read at 64x64." \
  --size 1K \
  --aspect-ratio 1:1 \
  --remove-bg \
  --output ~/Downloads/pack-icon.png
```

**The `--remove-bg` flag is MANDATORY.** Without it, the image will have a baked-in checkerboard pattern instead of actual transparency.

After generation, verify transparency by viewing in a browser - the browser's background should show through, not a checkerboard pattern.

**Format in pack file:**
```markdown
---
name: Pack Name
...frontmatter...
---

<p align="center">
  <img src="icons/{pack-name}.png" alt="Pack Name" width="256">
</p>

# Pack Name
...
```

---

## Required Sections

> **FOR AI AGENTS:** Every pack file MUST include these sections in order. The HTML comments in each section contain detailed instructions - read them and follow them exactly. Replace the example content with your pack's actual content.

Below is the Kai History System pack as the reference implementation demonstrating COMPLETE pack structure.

```markdown
<p align="center">
  <img src="icons/history-system.png" alt="Kai History System" width="256">
</p>

# Kai History System

> Granular context-tracking system for the entire AI infrastructure - captures all work, decisions, and learnings automatically with zero manual effort

## Installation Prompt
<!--
(512 words max)

INSTRUCTIONS FOR AI: Write a brief context briefing for the AI that will receive and install this pack.
Include:
- What PAI is (link to README)
- What this specific pack does
- Why the user would want it
- A call to action to follow installation instructions

Keep it welcoming but concise. The receiving AI needs enough context to understand
what it's installing without reading the whole pack first.
-->

You are receiving a PAI Pack - a modular upgrade for AI agent systems.

**What is PAI?** See: [PAI Project Overview](../README.md#what-is-pai)

**What is a Pack?** See: [Pack System](../README.md#the-journey-pai-v1x--v20)

This pack adds automatic memory to your entire AI infrastructure. The Kai History System is not just about agent outputs - it's a granular context-tracking system for EVERYTHING that happens in your system:

- **Continuous Learning**: Capture insights as they happen
- **Bug Fixing**: Trace exactly what was done when debugging
- **Avoiding Mistakes**: Learn from past errors automatically
- **After-Action Reviews**: Analyze what worked and what didn't
- **Restoration Points**: Recover from data loss with historical snapshots

**Core principle:** Work normally, documentation handles itself.

No more forgotten context between sessions. No more lost learnings. Your AI remembers everything so you don't have to.

Please follow the installation instructions below to integrate this pack into your infrastructure.

---

## The Concept and/or Problem
<!--
(2048 words max)

INSTRUCTIONS FOR AI: Explain the problem this pack solves or the concept it implements.
Include:
- The core problem/challenge (be specific)
- Why this matters (consequences of not solving it)
- Who faces this problem
- Any relevant background context

Write for someone who may not be familiar with the domain. Make the problem
feel real and urgent enough that they want the solution.
-->

AI agents are powerful but forgetful. Each session starts fresh with no memory of:

- What you built last week
- Why you made certain architectural decisions
- What bugs you've already fixed (and might reintroduce)
- Lessons learned from debugging sessions
- Research you've already conducted
- What agents discovered during parallel execution

This creates cascading problems across your entire AI infrastructure:

**For Development Work:**
- You fix the same bug twice because you forgot the root cause
- Architectural decisions lack rationale when revisited months later
- Code reviews miss context because the "why" is lost

**For Agent Orchestration:**
- Parallel agents complete work that's never captured
- Background research disappears when the session ends
- Agent outputs aren't categorized or searchable

**For Operational Continuity:**
- Session handoffs require manual context transfer
- Multi-day projects need constant re-explanation
- Team members can't see what the AI worked on

**For Learning and Improvement:**
- Insights get lost in conversation history
- No after-action reviews are possible
- Mistakes repeat because there's no institutional memory

**The Fundamental Problem:**

Traditional AI systems treat each interaction as ephemeral. But real work is cumulative. Today's debugging session informs tomorrow's architecture decision. Last month's research prevents this month's repeated mistake.

Without a history system, your AI is brilliant but amnesiac. Every session is day one. Every context is fresh. Every lesson must be relearned.

## The Solution
<!--
(4096 words max)

INSTRUCTIONS FOR AI: Explain how this pack solves the problem.
Include:
- High-level approach (the "what")
- Key insights or innovations (the "why this works")
- Architecture overview if applicable
- Design principles that guided the implementation
- Trade-offs made and why

Don't include code here - that goes in Installation. Focus on helping the reader
understand the approach conceptually before diving into implementation.
-->

The Kai History System solves this through **automatic, hook-based documentation**. Instead of requiring manual effort, it captures work as a byproduct of doing the work.

**Core Architecture:**

```
$PAI_DIR/
├── hooks/                           # Hook implementations
│   ├── capture-all-events.ts        # Universal event capture (all hooks)
│   ├── stop-hook.ts                 # Main agent completion capture
│   ├── subagent-stop-hook.ts        # Subagent output routing
│   ├── capture-session-summary.ts   # Session end summarization
│   └── lib/                         # Shared libraries
│       ├── observability.ts         # Dashboard integration
│       └── metadata-extraction.ts   # Agent instance tracking
├── history/                         # Captured outputs
│   ├── sessions/YYYY-MM/            # Session summaries
│   ├── learnings/YYYY-MM/           # Problem-solving narratives
│   ├── research/YYYY-MM/            # Investigation reports
│   ├── decisions/YYYY-MM/           # Architectural decisions
│   ├── execution/
│   │   ├── features/YYYY-MM/        # Feature implementations
│   │   ├── bugs/YYYY-MM/            # Bug fixes
│   │   └── refactors/YYYY-MM/       # Code improvements
│   └── raw-outputs/YYYY-MM/         # JSONL event logs
└── settings.json                    # Hook configuration
```

**Four Hooks, Complete Coverage:**

1. **capture-all-events.ts** (Universal Event Capture)
   - Hooks: ALL events (PreToolUse, PostToolUse, Stop, SessionStart, SessionEnd, etc.)
   - Captures: Every event to daily JSONL logs with full payload
   - Output: `raw-outputs/YYYY-MM/YYYY-MM-DD_all-events.jsonl`
   - Purpose: Complete audit trail, debugging, analytics

2. **stop-hook.ts** (Main Agent Completion)
   - Hook: Stop
   - Captures: Main agent work summaries and learnings
   - Output: `learnings/` or `sessions/` based on content analysis
   - Purpose: Capture what was accomplished and what was learned

3. **subagent-stop-hook.ts** (Subagent Output Routing)
   - Hook: SubagentStop
   - Captures: All spawned agent outputs
   - Output: Routed to `research/`, `decisions/`, or `execution/` by agent type
   - Purpose: Never lose agent work, automatic categorization

4. **capture-session-summary.ts** (Session End)
   - Hook: SessionEnd
   - Captures: Session summary with files changed, commands run, tools used
   - Output: `sessions/YYYY-MM/timestamp_SESSION_focus.md`
   - Purpose: Know what happened in each session

**Design Principles:**

1. **Zero Overhead**: Hooks run silently, no action required from user
2. **Never Block**: All hooks fail gracefully - never interrupt work
3. **Future-Proof**: Generic payload capture means new fields are automatically stored
4. **Queryable**: Consistent file naming enables powerful search and filtering
5. **Categorized**: Different work types route to appropriate directories
6. **Complete**: Every component included - nothing left to figure out

**The Key Insight:**

Documentation is a byproduct, not a task. By instrumenting the work itself, you get perfect records without any effort. The history system sees everything because it's wired into the event stream.

## Why This Is Different
<!--
(128 words max)

INSTRUCTIONS FOR AI: Explain what makes this pack unique compared to similar solutions.
Format EXACTLY as follows:
1. Opening line: "This sounds similar to [ALTERNATIVE] which also does [CAPABILITY]. What makes this approach different?"
2. A 64-word paragraph explaining the key differentiator
3. Four bullets of exactly 8 words each

Example:
"This sounds similar to mem0 which also does AI memory. What makes this approach different?

[64-word paragraph explaining the unique value proposition]

- First eight-word bullet explaining a key difference
- Second eight-word bullet explaining another key difference
- Third eight-word bullet explaining another key difference
- Fourth eight-word bullet explaining another key difference"
-->

This sounds similar to [ALTERNATIVE] which also does [CAPABILITY]. What makes this approach different?

[64-word paragraph answering the question - what makes your approach fundamentally different from existing solutions? Focus on the architectural insight, the unique methodology, or the problem framing that sets this apart.]

- [First eight-word bullet explaining a key difference]
- [Second eight-word bullet explaining another key difference]
- [Third eight-word bullet explaining another key difference]
- [Fourth eight-word bullet explaining another key difference]

---

## Installation
<!--
(16384 words max)

INSTRUCTIONS FOR AI: Provide step-by-step installation instructions.
Include:
- Prerequisites (dependencies, API keys, system requirements)
- Numbered steps with clear actions
- All code needed (use fenced code blocks with language tags)
- Code languages: typescript (bun), bash, python (uv), json, html
- Configuration file locations
- How to verify installation succeeded

Write for an AI assistant that will execute these steps. Be explicit about file
paths, commands to run, and expected outputs. Include ALL code - no snippets,
no "add more patterns here", no placeholders.
-->

### Prerequisites

- **Bun runtime**: `curl -fsSL https://bun.sh/install | bash`
- **Claude Code** (or compatible agent system with hook support)
- **Write access** to `$PAI_DIR/` (or your PAI directory)

### Step 1: Create Directory Structure

```bash
# Create all required directories
mkdir -p $PAI_DIR/hooks/lib
mkdir -p $PAI_DIR/history/{sessions,learnings,research,decisions,raw-outputs}
mkdir -p $PAI_DIR/history/execution/{features,bugs,refactors}

# Verify structure
ls -la $PAI_DIR/
ls -la $PAI_DIR/history/
```

Expected output: All directories created with no errors.

---

### Step 2: Create Library Files

These shared libraries are used by multiple hooks.

#### 2.1: Create observability.ts

```typescript
// $PAI_DIR/hooks/lib/observability.ts
// Dashboard integration for real-time monitoring

export interface ObservabilityEvent {
  source_app: string;
  session_id: string;
  hook_event_type: string;
  timestamp: string;
  transcript_path?: string;
  summary?: string;
  tool_name?: string;
  tool_input?: any;
  tool_output?: any;
  agent_type?: string;
  [key: string]: any;
}

/**
 * Send event to observability dashboard (optional)
 * Fails silently if dashboard is not running
 */
export async function sendEventToObservability(event: ObservabilityEvent): Promise<void> {
  try {
    const response = await fetch('http://localhost:4000/events', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'PAI-Hook/1.0'
      },
      body: JSON.stringify(event),
    });
    // Silently ignore failures - dashboard may be offline
  } catch (error) {
    // Fail silently - hooks should never fail due to observability issues
  }
}

export function getCurrentTimestamp(): string {
  return new Date().toISOString();
}

export function getSourceApp(): string {
  return process.env.PAI_SOURCE_APP || process.env.DA || 'PAI';
}
```

#### 2.2: Create metadata-extraction.ts

```typescript
// $PAI_DIR/hooks/lib/metadata-extraction.ts
// Extract agent instance metadata from Task tool calls

export interface AgentInstanceMetadata {
  agent_instance_id?: string;
  agent_type?: string;
  instance_number?: number;
  parent_session_id?: string;
  parent_task_id?: string;
}

/**
 * Extract agent instance ID from Task tool input
 */
export function extractAgentInstanceId(
  toolInput: any,
  description?: string
): AgentInstanceMetadata {
  const result: AgentInstanceMetadata = {};

  // Strategy 1: Extract from description [agent-type-N]
  if (description) {
    const descMatch = description.match(/\[([a-z-]+-researcher)-(\d+)\]/);
    if (descMatch) {
      result.agent_type = descMatch[1];
      result.instance_number = parseInt(descMatch[2], 10);
      result.agent_instance_id = `${result.agent_type}-${result.instance_number}`;
    }
  }

  // Strategy 2: Extract from prompt [AGENT_INSTANCE: ...]
  if (!result.agent_instance_id && toolInput?.prompt && typeof toolInput.prompt === 'string') {
    const promptMatch = toolInput.prompt.match(/\[AGENT_INSTANCE:\s*([^\]]+)\]/);
    if (promptMatch) {
      result.agent_instance_id = promptMatch[1].trim();
      const parts = result.agent_instance_id.match(/^([a-z-]+)-(\d+)$/);
      if (parts) {
        result.agent_type = parts[1];
        result.instance_number = parseInt(parts[2], 10);
      }
    }
  }

  // Strategy 3: Fallback to subagent_type
  if (!result.agent_type && toolInput?.subagent_type) {
    result.agent_type = toolInput.subagent_type;
  }

  return result;
}

/**
 * Enrich event with agent metadata
 */
export function enrichEventWithAgentMetadata(
  event: any,
  toolInput: any,
  description?: string
): any {
  const metadata = extractAgentInstanceId(toolInput, description);
  const enrichedEvent = { ...event };

  if (metadata.agent_instance_id) enrichedEvent.agent_instance_id = metadata.agent_instance_id;
  if (metadata.agent_type) enrichedEvent.agent_type = metadata.agent_type;
  if (metadata.instance_number !== undefined) enrichedEvent.instance_number = metadata.instance_number;

  return enrichedEvent;
}

/**
 * Check if a tool call is spawning a subagent
 */
export function isAgentSpawningCall(toolName: string, toolInput: any): boolean {
  return toolName === 'Task' && toolInput?.subagent_type !== undefined;
}
```

---

### Step 3: Create Hook Files

> **FOR AI AGENTS:** Create each of these files exactly as shown. All four hooks are required for full functionality.

[Include all 4 hook files here - capture-all-events.ts, stop-hook.ts, subagent-stop-hook.ts, capture-session-summary.ts - with complete code]

---

### Step 4: Register Hooks in settings.json

Claude Code looks for settings in `~/.claude/settings.json`. Add or merge the following hook configuration:

**File location:** `~/.claude/settings.json`

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bun run $PAI_DIR/hooks/capture-all-events.ts --event-type PreToolUse"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bun run $PAI_DIR/hooks/capture-all-events.ts --event-type PostToolUse"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bun run $PAI_DIR/hooks/stop-hook.ts"
          },
          {
            "type": "command",
            "command": "bun run $PAI_DIR/hooks/capture-all-events.ts --event-type Stop"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bun run $PAI_DIR/hooks/subagent-stop-hook.ts"
          },
          {
            "type": "command",
            "command": "bun run $PAI_DIR/hooks/capture-all-events.ts --event-type SubagentStop"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bun run $PAI_DIR/hooks/capture-session-summary.ts"
          },
          {
            "type": "command",
            "command": "bun run $PAI_DIR/hooks/capture-all-events.ts --event-type SessionEnd"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bun run $PAI_DIR/hooks/capture-all-events.ts --event-type SessionStart"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bun run $PAI_DIR/hooks/capture-all-events.ts --event-type UserPromptSubmit"
          }
        ]
      }
    ]
  }
}
```

**Important:** If you already have a settings.json, merge the hooks section with your existing configuration.

---

### Step 5: Verify Installation

```bash
# 1. Check all hooks exist
ls -la $PAI_DIR/hooks/*.ts
# Should show 4 hook files

# 2. Check lib files exist
ls -la $PAI_DIR/hooks/lib/*.ts
# Should show 2 lib files

# 3. Check directory structure
ls -la $PAI_DIR/history/
# Should show: sessions, learnings, research, decisions, execution, raw-outputs

# 4. Verify Bun can run the hooks
bun run $PAI_DIR/hooks/capture-all-events.ts --event-type Test <<< '{"test": true}'
# Should create an entry in raw-outputs

# 5. Restart Claude Code to activate hooks
```

## Invocation Scenarios
<!--
(8192 words max)

INSTRUCTIONS FOR AI: Document when and how this pack gets triggered.
Include:
- Trigger conditions (what causes it to activate)
- Event hooks or entry points
- Input/output flow diagrams if helpful
- Table of scenarios with triggers and actions
- Edge cases and how they're handled

Help users understand the pack's behavior in their system so they can
predict when it will activate and what it will do.
-->

The history system triggers automatically on Claude Code events:

| Event | Hook | Output Location | Captured Data |
|-------|------|-----------------|---------------|
| Any tool starts | PreToolUse | `raw-outputs/` | Tool name, input, session |
| Any tool completes | PostToolUse | `raw-outputs/` | Tool name, input, output |
| Main agent finishes | Stop | `learnings/` or `sessions/` | Full response, categorized |
| Subagent completes | SubagentStop | `research/`, `decisions/`, or `execution/` | Agent output, routed by type |
| User quits session | SessionEnd | `sessions/` | Files changed, tools used |

## Example Usage
<!--
(8192 words max)

INSTRUCTIONS FOR AI: Show concrete examples of the pack in action.
Include:
- 2-4 realistic usage scenarios
- For each: user input, system behavior, output
- Both success cases AND failure/edge cases
- Exact commands, responses, or outputs shown
-->

### Example 1: Searching Past Work

```bash
# User: "Have we worked on authentication before?"
grep -r "authentication" $PAI_DIR/history/

# Results show files with dates and categories
```

### Example 2: Reviewing Session Activity

```bash
ls -lt $PAI_DIR/history/sessions/2025-12/ | head -5
# Shows recent session files with their focus
```

## Configuration
<!--
(512 words max)

INSTRUCTIONS FOR AI: Document configuration options.
If no configuration is needed, write "No configuration required."
-->

**Environment variables:**

```bash
export PAI_DIR="$HOME/.config/pai"
export TIME_ZONE="America/Los_Angeles"
export DA="MyAI"
```

## Credits
<!--
(256 words max)
INSTRUCTIONS FOR AI: Attribution for ideas, inspiration, and contributions.
-->

- **Original concept**: Daniel Miessler - developed as part of Kai personal AI infrastructure
- **Inspired by**: Git's version history, engineering logbooks, Zettelkasten method

## Related Work
<!--
(256 words max)
INSTRUCTIONS FOR AI: DO NOT FABRICATE. Leave empty or ask the maintainer.
Only fill in if the maintainer provides specific projects to link.
-->

*None specified - maintainer to provide if applicable.*

## Works Well With
<!--
(256 words max)
INSTRUCTIONS FOR AI: DO NOT FABRICATE. Leave empty or ask the maintainer.
Only fill in if the maintainer specifies which packs complement this one.
-->

*None specified - maintainer to provide if applicable.*

## Recommended
<!--
(256 words max)
INSTRUCTIONS FOR AI: DO NOT FABRICATE. Leave empty or ask the maintainer.
Only fill in if the maintainer specifies recommended companion packs.
-->

*None specified - maintainer to provide if applicable.*

## Relationships
<!--
(512 words max total)
INSTRUCTIONS FOR AI: DO NOT FABRICATE. Leave empty or ask the maintainer.
These relationships must be REAL, verified connections to other packs.
Only fill in if the maintainer provides specific pack relationships.
-->

### Parent Of
*None specified.*

### Child Of
*None specified.*

### Sibling Of
*None specified.*

### Part Of Collection
*None specified.*

## Changelog
<!--
INSTRUCTIONS FOR AI: Document version history.
Format: ### {version} - {YYYY-MM-DD}
-->

### 1.0.0 - 2025-12-28
- Initial release
- Four hooks for complete event capture
- Automatic categorization by content and agent type
```

---

## Section Summary Table

| Section | Word Limit | Purpose |
|---------|------------|---------|
| `## Installation Prompt` | 512 | Context briefing for receiving AI |
| `## The Concept and/or Problem` | 2048 | What problem does this solve? |
| `## The Solution` | 4096 | How does this pack solve it? |
| `## Why This Is Different` | 128 | Differentiation from similar solutions |
| `## Installation` | 16384 | Step-by-step with ALL code |
| `## Invocation Scenarios` | 8192 | When/how it triggers |
| `## Example Usage` | 8192 | Concrete examples |
| `## Configuration` | 512 | Options and customization |
| `## Credits` | 256 | Attribution |
| `## Related Work` | 256 | Similar projects |
| `## Works Well With` | 256 | Complementary packs |
| `## Recommended` | 256 | Suggested companions |
| `## Relationships` | 512 | Parent Of, Child Of, Sibling Of, Part Of Collection |
| `## Changelog` | - | Version history |

---

## Pack Completeness Checklist

> **FOR AI AGENTS:** Before publishing, verify your pack includes ALL of these:

- [ ] **Why Different**: 64-word paragraph + 4 eight-word bullets
- [ ] **Full context**: What, why, who needs it
- [ ] **All code**: Complete, working implementations (no snippets, no placeholders)
- [ ] **File locations**: Exact paths for every file
- [ ] **Directory structure**: Commands to create directories
- [ ] **Hook code**: If hooks required, full implementations
- [ ] **Library dependencies**: All lib/ files included
- [ ] **settings.json**: Exact JSON configuration with file location
- [ ] **Environment variables**: Required vars and where to set them
- [ ] **Verification steps**: How to confirm success
- [ ] **256x256 icon**: Transparent PNG in blue/purple palette (generated with `--remove-bg` flag)

**The test:** Can someone go from fresh Claude Code to fully working system using ONLY this pack?

---

## File Naming Convention

- Flat files in `Packs/` directory
- kebab-case: `history-system.md`, `session-progress.md`
- No subdirectories per pack

---

## Versioning

- SemVer: `major.minor.patch`
- Major: Breaking changes
- Minor: New features, backwards compatible
- Patch: Bug fixes
