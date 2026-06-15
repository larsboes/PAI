# PAI Good Skill Guide

This guide defines the context engineering standards and architectural best practices for creating high-quality, token-efficient, and highly functional PAI skills.

---

## 1. Context Engineering for AI Agents

Context Engineering (Anthropic, 2025) shifts the optimization target from individual prompt wording to the design of the entire information environment. It is defined as:
> "what configuration of context is most likely to generate our model's desired behavior?"

AI models are highly sensitive to their context window contents. Simply dumping instructions, API references, and checklists into a global configuration (like `CLAUDE.md`) causes:
1. **Context Pollution**: High token costs on every turn.
2. **Attention Degradation**: The model loses track of task details due to irrelevant standing instructions.
3. **Execution Slowdown**: Compaction triggers sooner, slicing critical conversation history.

### The Skill Primitive
Skills are PAI's ultimate context-engineering primitive. Unlike `CLAUDE.md` which loads on every single message:
- A skill's instructions **only load when invoked** (manually via a `/command` or automatically by the model).
- A skill can target specific directories or file extensions, only loading when editing matching files.
- A skill can override model parameters (like model type and effort level) for the duration of its task.

---

## 2. Progressive Disclosure & Dynamic Loading

Progressive disclosure is the practice of loading detailed information only when it is needed. For PAI skills, this means keeping the main `SKILL.md` file minimal and offloading heavy references.

```
┌────────────────────────────────────────────────────────┐
│               YAML Frontmatter (Level 1)               │
│  • Always loaded in system context. Triggers only.      │
└──────────────────────────┬─────────────────────────────┘
                           ▼
┌────────────────────────────────────────────────────────┐
│                 SKILL.md Body (Level 2)                │
│  • Loaded on invocation. Routing table + Gotchas.      │
└──────────────────────────┬─────────────────────────────┘
                           ▼
┌────────────────────────────────────────────────────────┐
│            References & Workflows (Level 3)            │
│  • Loaded on demand via SkillSearch or relative links.  │
└────────────────────────────────────────────────────────┘
```

### Structuring Levels
- **Level 1 (Frontmatter)**: Contains only the display `name`, argument hints, and a tight 1-2 sentence `description` with `USE WHEN` keywords. (Max 650 characters hard limit to prevent being dropped during listing).
- **Level 2 (`SKILL.md` body)**: Under 500 lines. Contains the workflow routing table, a quick reference, and a gotchas list.
- **Level 3 (Supporting Files)**: Detailed API documentation, templates, and large examples go into separate markdown files in the skill root or `References/` subdirectory.

> [!TIP]
> Keep `SKILL.md` under 500 lines. Use the `SkillSearch('<query>')` pattern or direct relative links in your instructions to tell the model to load specific reference files only when it needs them.

---

## 3. Advanced Frontmatter Configuration

Leverage Claude Code's frontmatter options to configure the execution sandbox:

| Field | Purpose | Example / Pattern |
|-------|---------|-------------------|
| `disable-model-invocation: true` | Prevents the model from running this skill automatically. Use for commands with side-effects or manual gates. | `/deploy`, `/commit`, `/send-slack` |
| `user-invocable: false` | Hides the skill from the user's `/` command menu. Use for passive domain knowledge loaded automatically by the model. | `legacy-database-context` |
| `allowed-tools` | Pre-approves tools so the model doesn't prompt the user for permission. Supports prefix wildcards. | `allowed-tools: [Read, Bash(git commit *)]` |
| `context: fork` | Spawns a clean subagent context to run the skill, isolating it from current conversation history. | `deep-research`, `/simplify` |
| `agent` | Selects which subagent type (e.g. `Explore`, `Plan`, `general-purpose`) runs the forked context. | `agent: Explore` |
| `effort` | Overrides the session effort level (e.g. `low`, `medium`, `high`, `xhigh`, `max`) for this skill's execution. | `effort: high` |
| `paths` | Glob patterns that limit when this skill is loaded automatically by the model. | `paths: ["src/auth/**/*.ts", "tests/auth/**/*.ts"]` |
| `shell` | Shell environment to run shell commands in. Defaults to `bash`. | `shell: bash` |

---

## 4. Parameterized Playbooks & Substitutions

Skills support dynamic string substitutions for parameterized automation.

### Available Substitution Variables

| Variable | Description | Example / Usage |
|----------|-------------|-----------------|
| `$ARGUMENTS` | Expands to the full raw argument string typed after the command. | `/my-skill hello world` → `$ARGUMENTS` becomes `"hello world"` |
| `$ARGUMENTS[N]` or `$N` | Positional 0-indexed argument (uses shell-style quoting). | `/my-skill arg0 arg1` → `$0` is `"arg0"`, `$1` is `"arg1"` |
| `$name` | Named arguments mapped in the frontmatter `arguments` list. | `arguments: [issue, branch]` → `$issue` maps to arg0, `$branch` to arg1 |
| `${CLAUDE_SESSION_ID}` | Unique session identifier for the current run. | Useful for creating log files: `logs/${CLAUDE_SESSION_ID}.log` |
| `${CLAUDE_EFFORT}` | The current active model effort level. | `low`, `medium`, `high`, `xhigh`, or `max` |
| `${CLAUDE_SKILL_DIR}` | Absolute path to the skill directory on disk. | Used to run bundled scripts: `bun ${CLAUDE_SKILL_DIR}/Tools/helper.ts` |

### Positional vs Named Arguments Example
```yaml
---
name: create-branch
description: Creates a git branch.
arguments: [branch_name, source_branch]
---

Create a branch named $branch_name from $source_branch:
1. Run git checkout $source_branch
2. Run git pull origin $source_branch
3. Run git checkout -b $branch_name
```

---

## 5. Dynamic Context Preprocessing (Shell Injection)

Before the prompt goes to the model, you can inject fresh, dynamic system state using the `` !`<command>` `` syntax. The command runs locally, and its stdout replaces the block.

### Example: PR Summary Skill
```yaml
---
name: pr-summary
description: Summarizes a PR.
---
## Git PR Context
- Diff stats: !`git diff --stat`
- Active branch: !`git branch --show-current`

## Instructions
Summarize the changes listed above...
```

For multi-line commands, use the fenced ` ```! ` block:
```markdown
## System State
```!
node --version
npm --version
git status --short
```
```

> [!CAUTION]
> Shell execution can be disabled by policy via `"disableSkillShellExecution": true` in managed settings. Design skills with fallback guidelines in case command injection is disabled.

---

## 6. Model Interaction Lifecycle & Compaction

When a skill is invoked, its content enters the conversation history as a single message.
- Claude Code does **not** re-read the skill file on later turns, so write instructions as standing guidelines rather than one-time tasks.
- **Compaction**: When the context window fills up and triggers compaction, Claude Code preserves active skills by carrying forward the first **5,000 tokens** of the most recent invocation of each skill, sharing a combined carry-forward pool of **25,000 tokens**.
- If a skill stops influencing the model's behavior after compaction, strengthen its triggers or re-invoke it to restore its full instructions.

---

## 7. Minimalist Philosophy vs MCP

PAI adopts a strict minimalist and observable approach to developer tooling:
1. **Unrestricted Power (YOLO)**: Avoid security theater. Grant the model command execution and file edits, relying on native OS sandboxing or containers if isolation is needed.
2. **MCP Disincentive**: Model Context Protocol (MCP) servers are highly context-heavy (e.g. Playwright MCP dumps 21 tools and 13.7k tokens into the context prompt, consuming 7-9% of the window before work starts).
3. **CLI Tools + READMEs**: Instead of MCP servers, write clean CLI tools with simple instruction READMEs. The model reads the README on demand (progressive disclosure), pays the token cost only when needed, and executes the CLI via the bash tool. This allows Unix-style chaining and debugging.
4. **TMUX for long-running tasks**: Do not run background shell processes that hide output. Use TMUX sessions to orchestrate compilers, debuggers, and dev servers, allowing the model (and the developer) full scrollback and interactive inspection.

---

## 8. Critical Skill Sections

Every compliant PAI skill must include the following sections to maintain quality and reliability:

### 1. Examples Section (Mandatory)
Examples show the model *how* the skill behaves, improving selection accuracy from 72% to 90%. Keep examples to 2-3 concrete scenarios showing input -> action -> output.

```markdown
## Examples

**Example 1: Scaffolding a CLI**
User: "create a CLI tool for syncing notes called NoteSync"
→ Invokes CreateCli workflow
→ Creates NoteSync.ts and package.json
→ Verifies execution runs successfully
```

### 2. Gotchas Section (Mandatory)
Quirks, silent failure modes, and API oddities that Claude gets wrong by default. The gotchas section must be updated continuously after debugging sessions.
```markdown
## Gotchas
- The Bun database wrapper requires explicit closing, otherwise the process hangs.
- When staging git modifications, always run git status first to avoid staging temp files.
```

### 3. BPE (Bitter-Pill Engineering) Check
Before building a skill, evaluate if a smarter model will render the skill obsolete. Focus on encoding **knowledge** (custom API keys, internal org rules), **SOPs** (business processes), and **tools** (scripts, wrappers) rather than complex chain-of-thought orchestration patterns.
