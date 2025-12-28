# PAI Pack Template Specification

Each pack is a single flat markdown file with YAML frontmatter and structured sections.

---

## Frontmatter (Metadata)

```yaml
---
# name: (24 words max) Human-readable pack name
name: History System

# pack-id: (format) {author}-{pack-name}-{variant}-v{version}
pack-id: danielmiessler-history-system-core-v1.0.0

# version: (format) SemVer major.minor.patch
version: 1.0.0

# author: (1 word) GitHub username or organization
author: danielmiessler

# description: (128 words max) One-line description
description: Automatic documentation system that captures all AI agent work through hooks with zero manual effort

# type: (single) concept | skill | hook | plugin | agent | mcp | workflow | template | other
type: feature

# purpose-type: (multi) security | productivity | research | development | automation | integration | creativity | analysis | other
purpose-type: [productivity, automation]

# platform: (single) agnostic | claude-code | opencode | cursor | custom
platform: claude-code

# dependencies: (list) Required pack-ids, empty [] if none
dependencies: []

# keywords: (24 tags max) Searchable tags for discovery
keywords: [history, documentation, memory, capture, hooks, sessions, learnings, automation]
---
```

---

## Required Sections (with Example)

Every pack file MUST include these sections in order. Below is the History System pack as reference:

```markdown
# History System

> Automatic documentation system that captures all AI agent work through hooks with zero manual effort

## Installation Prompt
<!--
(512 words max)

INSTRUCTIONS: Write a brief context briefing for the AI that will receive and install this pack.
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

**What is a Pack?** See: [Pack System](../README.md#pack-system)

This pack adds automatic memory to your AI system. The History System automatically documents every feature you build, bug you fix, decision you make, and lesson you learn - all through hooks that run silently in the background.

**Core principle:** Work normally, documentation handles itself.

No more forgotten context between sessions. No more lost learnings. Your AI remembers everything so you don't have to.

Please follow the installation instructions below to integrate this pack into your infrastructure.

---

## The Concept and/or Problem
<!--
(2048 words max)

INSTRUCTIONS: Explain the problem this pack solves or the concept it implements.
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

This creates several problems:

**Repeated mistakes**: Without history, you'll solve the same problems multiple times, each time from scratch.

**Lost context**: "Why did we do it this way?" becomes unanswerable when you can't trace decisions back to their rationale.

**Manual documentation burden**: If you want records, you have to manually write them - which means you won't, because you're busy doing actual work.

**Session discontinuity**: Each conversation is isolated. Multi-day projects require constant re-explanation of context.

The result? Your AI is brilliant but has permanent amnesia. Every session is day one.

## The Solution
<!--
(4096 words max)

INSTRUCTIONS: Explain how this pack solves the problem.
Include:
- High-level approach (the "what")
- Key insights or innovations (the "why this works")
- Architecture overview if applicable
- Design principles that guided the implementation
- Trade-offs made and why

Don't include code here - that goes in Installation. Focus on helping the reader
understand the approach conceptually before diving into implementation.
-->

The History System solves this through **automatic, hook-based documentation**. Instead of requiring manual effort, it captures work as a byproduct of doing the work.

**Architecture:**

```
~/.config/pai/history/
├── sessions/YYYY-MM/          # Session summaries (SessionEnd hook)
├── learnings/YYYY-MM/         # Problem-solving narratives (Stop hook)
├── research/YYYY-MM/          # Investigation reports (Agent hooks)
├── decisions/YYYY-MM/         # Architectural decisions (Agent hooks)
├── execution/
│   ├── features/YYYY-MM/      # Feature implementations
│   ├── bugs/YYYY-MM/          # Bug fixes
│   └── refactors/YYYY-MM/     # Code improvements
└── raw-outputs/YYYY-MM/       # JSONL logs (PostToolUse hook)
```

**Five Hooks, Complete Coverage:**

1. **PostToolUse Hook** - Captures every tool execution (Bash, Edit, Write, etc.) as raw JSONL logs
2. **Stop Hook** - Analyzes completed work and categorizes as LEARNING or SESSION
3. **SubagentStop Hook** - Routes agent outputs to appropriate directories by agent type
4. **SessionEnd Hook** - Creates session summaries when you quit
5. **SessionStart Hook** - Loads context and prepares the environment

**Design Principles:**

- **Zero overhead**: Hooks run silently, no action required from user
- **Future-proof**: Generic payload capture means new fields are automatically stored
- **Queryable**: Standard file naming enables powerful search and filtering
- **Categorized**: Different work types route to appropriate directories

**The Key Insight:**

Documentation is a byproduct, not a task. By instrumenting the work itself, you get perfect records without any effort.

## Installation
<!--
(16384 words max)

INSTRUCTIONS: Provide step-by-step installation instructions.
Include:
- Prerequisites (dependencies, API keys, system requirements)
- Numbered steps with clear actions
- All code needed (use fenced code blocks with language tags)
- Code languages: typescript (bun), bash, python (uv), json, html
- Configuration file locations
- How to verify installation succeeded

Write for an AI assistant that will execute these steps. Be explicit about file
paths, commands to run, and expected outputs.
-->

### Prerequisites

- Bun runtime installed (`curl -fsSL https://bun.sh/install | bash`)
- Claude Code or compatible agent system with hook support

### Step 1: Create directory structure

```bash
mkdir -p ~/.config/pai/history/{sessions,learnings,research,decisions,raw-outputs}
mkdir -p ~/.config/pai/history/execution/{features,bugs,refactors}
mkdir -p ~/.config/pai/hooks
```

### Step 2: Create the PostToolUse capture hook

```typescript
// ~/.config/pai/hooks/capture-tool-output.ts
// Captures every tool execution to daily JSONL logs

import { appendFileSync, mkdirSync } from "fs";
import { join } from "path";

const historyDir = process.env.PAI_HISTORY || join(process.env.HOME!, ".config/pai/history");

interface HookPayload {
  hook_type: string;
  tool_name: string;
  tool_input: Record<string, unknown>;
  tool_output: string;
  timestamp: string;
  session_id?: string;
}

function getDatePath(): string {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  return `${year}-${month}`;
}

function getTodayFilename(): string {
  const now = new Date();
  return now.toISOString().split("T")[0];
}

export function captureToolOutput(payload: HookPayload): void {
  const datePath = getDatePath();
  const outputDir = join(historyDir, "raw-outputs", datePath);

  mkdirSync(outputDir, { recursive: true });

  const filename = `${getTodayFilename()}_all-events.jsonl`;
  const filepath = join(outputDir, filename);

  const record = {
    ...payload,
    captured_at: new Date().toISOString(),
  };

  appendFileSync(filepath, JSON.stringify(record) + "\n");
}

// Main execution
const input = JSON.parse(process.argv[2] || "{}");
captureToolOutput(input);
```

### Step 3: Create the Stop hook for learning capture

```typescript
// ~/.config/pai/hooks/stop-hook.ts
// Captures session work and learnings when main agent completes

import { writeFileSync, mkdirSync } from "fs";
import { join } from "path";

const historyDir = process.env.PAI_HISTORY || join(process.env.HOME!, ".config/pai/history");

interface StopPayload {
  stop_hook_active: boolean;
  transcript_path?: string;
  response?: string;
}

function hasLearningIndicators(text: string): boolean {
  const indicators = ["problem", "solved", "discovered", "fixed", "learned", "realized"];
  const matches = indicators.filter(i => text.toLowerCase().includes(i));
  return matches.length >= 2;
}

function generateFilename(type: string, description: string): string {
  const now = new Date();
  const timestamp = now.toISOString().replace(/[-:]/g, "").split(".")[0];
  const kebab = description.toLowerCase().replace(/[^a-z0-9]+/g, "-").slice(0, 60);
  return `${timestamp}_${type}_${kebab}.md`;
}

export function captureStop(payload: StopPayload): void {
  if (!payload.response) return;

  const isLearning = hasLearningIndicators(payload.response);
  const type = isLearning ? "LEARNING" : "SESSION";
  const subdir = isLearning ? "learnings" : "sessions";

  const datePath = new Date().toISOString().slice(0, 7); // YYYY-MM
  const outputDir = join(historyDir, subdir, datePath);

  mkdirSync(outputDir, { recursive: true });

  const filename = generateFilename(type, payload.response.slice(0, 100));
  const filepath = join(outputDir, filename);

  const content = `---
capture_type: ${type}
timestamp: ${new Date().toISOString()}
---

${payload.response}
`;

  writeFileSync(filepath, content);
}

const input = JSON.parse(process.argv[2] || "{}");
captureStop(input);
```

### Step 4: Register hooks in settings

Add to your Claude Code settings (`.claude/settings.json` or equivalent):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "command": "bun run ~/.config/pai/hooks/capture-tool-output.ts"
      }
    ],
    "Stop": [
      {
        "command": "bun run ~/.config/pai/hooks/stop-hook.ts"
      }
    ]
  }
}
```

### Step 5: Verify installation

```bash
# Check directory structure exists
ls -la ~/.config/pai/history/

# Run a test command in your AI agent, then verify capture
ls ~/.config/pai/history/raw-outputs/
```

## Invocation Scenarios
<!--
(8192 words max)

INSTRUCTIONS: Document when and how this pack gets triggered.
Include:
- Trigger conditions (what causes it to activate)
- Event hooks or entry points
- Input/output flow diagrams if helpful
- Table of scenarios with triggers and actions
- Edge cases and how they're handled

Help users understand the pack's behavior in their system so they can
predict when it will activate and what it will do.
-->

The history system triggers automatically - no user action required:

| Scenario | Hook | Output Location |
|----------|------|-----------------|
| Any tool executes (Bash, Edit, etc.) | PostToolUse | `raw-outputs/YYYY-MM/` |
| Main agent completes a task | Stop | `learnings/` or `sessions/` |
| Subagent finishes work | SubagentStop | Varies by agent type |
| User quits session | SessionEnd | `sessions/` |
| User starts new session | SessionStart | Loads context |

**Automatic Categorization:**

The Stop hook analyzes response content for learning indicators:
- 2+ indicators (problem, solved, discovered, fixed, learned) → `learnings/`
- Fewer indicators → `sessions/`

**Example Flow:**

1. User: "Fix the authentication bug"
2. Agent investigates, edits files, runs tests
3. PostToolUse captures each tool call to JSONL
4. Agent completes with "Fixed the bug by..."
5. Stop hook detects "fixed" + "problem" → saves to `learnings/`

## Example Usage
<!--
(8192 words max)

INSTRUCTIONS: Show concrete examples of the pack in action.
Include:
- 2-4 realistic usage scenarios
- For each: user input, system behavior, output
- Both success cases AND failure/edge cases
- Exact commands, responses, or outputs shown
- Formatted as clear before/after or input/output pairs

Examples should be copy-pasteable and demonstrate the pack's value.
Show the pack doing what it's designed to do.
-->

### Example 1: Searching Past Work

**User asks:**
```
Have we worked on authentication before?
```

**Agent searches:**
```bash
grep -r "authentication" ~/.config/pai/history/
```

**Result:**
```
learnings/2025-10/20251013_LEARNING_jwt-token-refresh.md
execution/features/2025-09/20250928_FEATURE_user-login.md
decisions/2025-09/20250925_DECISION_auth-strategy.md
```

### Example 2: Reviewing a Session

**User asks:**
```
What did we do last session?
```

**Agent reads:**
```bash
ls -lt ~/.config/pai/history/sessions/2025-12/ | head -1
# Returns: 20251228_SESSION_feature-implementation.md
```

**Session file contains:**
```markdown
---
capture_type: SESSION
timestamp: 2025-12-28T15:30:00-08:00
---

Implemented the new dashboard feature including:
- Database schema updates
- API endpoints for data retrieval
- Frontend components with charts
- Unit tests for all new functions
```

### Example 3: Finding Why a Decision Was Made

**User asks:**
```
Why did we choose PostgreSQL over MongoDB?
```

**Agent searches:**
```bash
grep -l "PostgreSQL\|MongoDB" ~/.config/pai/history/decisions/
```

**Returns decision document with full rationale.**

## Configuration
<!--
(512 words max)

INSTRUCTIONS: Document configuration options.
Include:
- All configurable parameters with descriptions
- Default values
- Valid value ranges or options
- Example configuration snippets
- Where configuration files live

If no configuration is needed, write "No configuration required." and briefly
explain why (e.g., "Works out of the box with sensible defaults.").
-->

```bash
# Environment variables (optional)

# Override default history location
export PAI_HISTORY="$HOME/.config/pai/history"

# Override timezone for timestamps (default: system timezone)
export PAI_TIMEZONE="America/Los_Angeles"
```

**Directory structure is fixed** - the categorization system depends on consistent paths. Customize only the root location if needed.

## Credits
<!--
(256 words max)

INSTRUCTIONS: Attribution for ideas, inspiration, and contributions.
Include:
- Original author(s)
- Contributors
- Inspiration sources (papers, projects, people)
- Acknowledgments

Be generous with credit. Link to profiles/projects where appropriate.
-->

- **Original concept**: Daniel Miessler - developed as part of Kai personal AI infrastructure
- **Contributors**: The PAI community
- **Inspired by**: Git's approach to version history, engineering logbooks, the Zettelkasten method

## Related Work
<!--
(256 words max)

INSTRUCTIONS: Link to similar or related projects.
Include:
- Alternative solutions to the same problem
- Complementary tools or libraries
- Academic papers or blog posts
- Standards or specifications

Help users understand the ecosystem and find additional resources.
-->

- **mem0**: https://github.com/mem0ai/mem0 - AI memory layer
- **Obsidian**: https://obsidian.md - Knowledge management with linking
- **Logseq**: https://logseq.com - Outliner with git-based storage

## Works Well With
<!--
(256 words max)

INSTRUCTIONS: List packs that complement this one.
Include:
- Pack name and brief explanation of synergy
- Why they work well together
- Any integration notes

Focus on functional combinations, not just related packs.
-->

- **session-progress**: Track multi-session work with handoff artifacts - history provides the searchable archive, session-progress provides active state
- **agent-factory**: Custom agents get their outputs automatically categorized by the SubagentStop hook

## Recommended
<!--
(256 words max)

INSTRUCTIONS: Packs you recommend using alongside this one.
Include:
- Pack name and why it's recommended
- Priority level (essential vs nice-to-have)
- Brief reasoning

This is your "if you install this, also consider..." section.
-->

- **session-progress**: Essential for multi-session work - provides the "current state" complement to history's "past record"
- **observability-server**: Nice-to-have - visualize history data in a dashboard

## Relationships
<!--
(512 words max total for all subsections)

INSTRUCTIONS: Document how this pack relates to others in the ecosystem.
Use the four relationship types below. Each is optional - include only those
that apply. This helps users understand the pack hierarchy and find related packs.
-->

### Parent Of
<!--
(128 words max, optional)
INSTRUCTIONS: List packs that extend or depend on this pack.
These are more specialized versions or add-ons.
-->

- **history-analytics**: Analyzes history data to surface patterns and insights
- **history-search**: Advanced semantic search across all captured history

### Child Of
<!--
(128 words max, optional)
INSTRUCTIONS: List packs this pack extends or depends on.
These are prerequisites or base packs.
-->

None - this is a foundational infrastructure pack.

### Sibling Of
<!--
(128 words max, optional)
INSTRUCTIONS: List packs at the same level with common purpose.
These solve similar problems or share architectural patterns.
-->

- **session-progress**: Both address continuity, history captures past, session-progress tracks present
- **context-loader**: Both are infrastructure packs that operate via hooks

### Part Of Collection
<!--
(128 words max, optional)
INSTRUCTIONS: List author collections or themed pack groups this belongs to.
-->

- **danielmiessler's Infrastructure Suite**: Core packs for AI agent memory and continuity

## Changelog
<!--
INSTRUCTIONS: Document version history.
Format: ### {version} - {YYYY-MM-DD}
Include: bullet points of changes for each version
Start with most recent version at top.
-->

### 1.0.0 - 2025-12-28
- Initial release
- PostToolUse hook for raw capture
- Stop hook for learning/session categorization
- Directory structure for organized storage
- Search patterns for retrieval
```

---

## Section Summary Table

| Section | Word Limit | Purpose |
|---------|------------|---------|
| `## Installation Prompt` | 512 | Context briefing for receiving AI |
| `## The Concept and/or Problem` | 2048 | What problem does this solve? |
| `## The Solution` | 4096 | How does this pack solve it? |
| `## Installation` | 16384 | Step-by-step with code snippets |
| `## Invocation Scenarios` | 8192 | When/how it triggers |
| `## Example Usage` | 8192 | Concrete examples |
| `## Configuration` | 512 | Options and customization |
| `## Credits` | 256 | Attribution |
| `## Related Work` | 256 | Similar projects |
| `## Works Well With` | 256 | Complementary packs |
| `## Recommended` | 256 | Suggested companions |
| `## Relationships` | 512 | Parent Of, Child Of, Sibling Of, Part Of Collection (128 each) |
| `## Changelog` | - | Version history |

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
