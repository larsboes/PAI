---
name: Tooling
pack-id: larsboes-tooling-v1.0.0
version: 2.0.0
author: larsboes
description: Direct CLI and API patterns for daily-use tools — no wrappers, no SDKs, just commands.
type: skill
platform: claude-code
dependencies: []
keywords: [api, curl, git, docker, llm, systemd, logstash, fluentbit, bazel, tooling]
---

# Tooling

> Direct CLI and API patterns. Teach the agent to interact with tools through their native interfaces — no wrappers, no SDKs, no abstraction layers.

---

## Design Philosophy

Every skill in this pack follows the same pattern:
- **SKILL.md** shows the most common commands you'll reach for immediately
- **`scripts/`** has real executable tools you can run right now
- **`references/`** goes deep when you need the full manual

The agent should be able to run `scripts/syscheck.sh` or `scripts/call-anthropic.sh` directly. No ceremony.

---

## Skills (8)

| Skill | Scripts | References | Purpose |
|-------|---------|-----------|---------|
| [ApiPatterns](src/ApiPatterns/) | 4 | 5 | Raw curl/fetch for OpenAI, Anthropic, GitHub. Skip SDKs. |
| [GitWorkflow](src/GitWorkflow/) | 3 | 2 | Worktrees, rebase, bisect, reflog, hooks. Power git. |
| [Docker](src/Docker/) | 3 | 1 | Build, compose, debug, optimize. Direct CLI. |
| [LlmApi](src/LlmApi/) | 5 | 0 | Call any LLM in one line. Batch, compare, stream. |
| [SystemAdmin](src/SystemAdmin/) | 4 | 1 | systemd, journalctl, networking, processes. |
| [Bazel](src/Bazel/) | 2 | 4 | MODULE.bazel, custom rules, CI, remote caching. |
| [FluentBit](src/FluentBit/) | 2 | 2 | Lua filter development, testing, CI patterns. |
| [Logstash](src/Logstash/) | 1 | 2 | Ruby filter development, CI pipeline patterns. |

## Quick Start

```bash
# Check system health
bash Tooling/src/SystemAdmin/scripts/syscheck.sh

# Call Claude directly
ANTHROPIC_API_KEY=sk-ant-... bash Tooling/src/LlmApi/scripts/call-anthropic.sh claude-sonnet-4-20250514 "Hello"

# Compare 3 models on same prompt
bash Tooling/src/LlmApi/scripts/compare-models.sh "Explain monads in one sentence"

# Clean up Docker
bash Tooling/src/Docker/scripts/docker-cleanup.sh --aggressive

# Show recent git branches
bash Tooling/src/GitWorkflow/scripts/git-recent.sh
```
