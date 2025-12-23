# [PackageName] Package v1.0.0

**[One-line description of what this skill does]**

---

## 🤖 Assistant Install Prompt

**For AI Assistants: When your user asks you to install this package, follow these steps:**

```
ASSISTANT INSTALLATION INSTRUCTIONS

1. READ this entire package file to understand what you're installing

2. EXPLAIN to the user:
   - What this package does ([brief description])
   - What dependencies are required ([list tools])
   - What API keys they'll need (if any)
   - Ask if they want to proceed

3. VERIFY dependencies:
   - Check if required tools are installed
   - Run: which [tool1], which [tool2], etc.
   - If missing, provide installation commands for their platform

4. SET UP API keys (if required):
   - Check if ~/.claude/.env exists (or equivalent for their system)
   - Prompt user for required API keys
   - Add keys to environment file

5. SAVE the tools:
   - Create directory: ~/.claude/Skills/[PackageName]/Tools/ (or equivalent)
   - Extract all tool code from this package
   - Save each tool to appropriate location
   - Make executable if needed

6. CONFIGURE skill routing (if user has a skill system):
   - Add [PackageName] skill routing to their CORE/routing configuration
   - Use the skill definition from this package

7. TEST the installation:
   - Run the smoke test from this package
   - Verify outputs are created correctly
   - Show user the test results

8. REPORT completion:
   - Summarize what was installed
   - Show the user how to use it (basic command example)
   - Mention where to find full documentation (this package file)

If you encounter errors at any step, stop and report the issue to the user.
Don't proceed until the issue is resolved.
```

---

## Package Metadata

```yaml
package:
  name: PackageName
  version: 1.0.0
  category: [skill-category]  # e.g., automation, research, visual-content, security
  author: Your Name
  license: MIT

  requires:
    - CORE >= 1.0.0 (optional - if depends on other packages)
    - Claude Code or compatible AI assistant platform

  platforms:
    - macos
    - linux
    - windows (note any platform-specific limitations)

  dependencies:
    tools:
      - tool1 (what it's for)
      - tool2 (what it's for)

    api_keys:
      - SERVICE_API_KEY (what it's for)
      - ANOTHER_API_KEY (optional - what it's for)
```

---

## The Problem

[2-4 paragraphs describing the problem this skill solves]

What's broken? What's inefficient? What gap exists in current workflows?

Be specific about the pain point this addresses.

---

## The Solution

[2-4 paragraphs describing how this skill addresses the problem]

What's the approach? What makes it better than alternatives? What's the key insight or innovation?

How does this skill improve the user's workflow or capabilities?

---

## Quick Start

### 1. Install Dependencies

```bash
# macOS
brew install [tool1] [tool2]

# Linux
sudo apt-get install [tool1] [tool2]

# Or other installation method
curl -fsSL https://example.com/install | bash
```

### 2. Set Up API Keys (if required)

Add to your `~/.claude/.env` or equivalent:

```bash
# Required
SERVICE_API_KEY=your_key_here       # Get from: https://service.com

# Optional
ANOTHER_API_KEY=your_key_here       # Get from: https://another.com
```

### 3. Use the Skill

[Minimal working example that proves it works]

```bash
# Example command
command --option value
```

---

## Package Contents

### Skill Definition

When integrated into a Personal AI system, this skill routes requests to appropriate workflows:

```yaml
name: PackageName
description: USE WHEN [trigger conditions]. [What this skill does]

trigger_phrases:
  - "phrase 1"
  - "phrase 2"
  - "phrase 3"

routing:
  - pattern: "keyword1|keyword2|phrase"
    workflow: WorkflowName1
  - pattern: "keyword3|keyword4"
    workflow: WorkflowName2
```

---

### Workflows

#### WorkflowName1 - [Purpose]

**Purpose:** [What this workflow does]

**When to use:** [Trigger conditions]

**Process:**

```markdown
# Step-by-step workflow

1. STEP 1 - [Action]
   - [Detail 1]
   - [Detail 2]

2. STEP 2 - [Action]
   - [Detail 1]
   - [Detail 2]

3. STEP 3 - [Action]
   [etc.]
```

**Output:**
- [What this workflow produces]

**Example:**
```
[Concrete usage example]
```

---

#### WorkflowName2 - [Purpose]

[Repeat pattern for each workflow]

---

### Tools

#### ToolName.ts (or .py, .sh)

**Purpose:** [What this tool does]

**Usage:**

```bash
# Basic usage
tool-name --option value

# Common patterns
tool-name --flag1 --flag2 output.txt
```

**Full Source Code:**

```typescript
#!/usr/bin/env bun

/**
 * [Tool Name] - [Brief description]
 *
 * [Longer description of what this tool does]
 *
 * Usage:
 *   tool-name --option value
 */

// [COMPLETE, WORKING, TESTED CODE]
// [NO PLACEHOLDERS]
// [NO TODOS]

// ... full implementation ...
```

**Note:** [Any important notes about usage, limitations, or dependencies]

---

### Context Files (if applicable)

#### ContextFileName.md

**Purpose:** [What context this provides]

**Content:**

```markdown
[Full context file content]
[Guidelines, specifications, rules, etc.]
```

---

### Hooks (if applicable)

#### hook-name.ts

**Event:** [When this hook fires]

**Purpose:** [What it does]

```typescript
#!/usr/bin/env bun

// Hook: hook-name
// Fires when: [event description]

// [COMPLETE HOOK CODE]
```

---

## Examples

### Example 1: [Common Use Case]

**Scenario:** [Description of the situation]

**Command:**

```bash
[Actual command to run]
```

**Expected Output:**

```
[What should happen]
```

**Result:**
- [File 1 created]
- [Output shown]
- [etc.]

---

### Example 2: [Another Use Case]

[Repeat pattern for multiple examples]

---

### Example 3: [Advanced Use Case]

[Include at least one advanced/complex example]

---

## Installation

### Option A: AI-Assisted Installation (Recommended)

Give this package file to your AI assistant and ask:

> "Install the [PackageName] package into my system. Set up the skill routing, save the tools, verify dependencies, and test it works."

Your AI will:
1. Read and understand the package
2. Check for required dependencies
3. Prompt you for API keys (if needed)
4. Save tools to appropriate directories
5. Set up skill routing (if applicable)
6. Run tests to verify functionality
7. Report completion and show you how to use it

### Option B: Manual Installation

**1. Install dependencies:**

```bash
# macOS
brew install [dependencies]

# Linux
sudo apt-get install [dependencies]
```

**2. Save the tools:**

```bash
# Create directory
mkdir -p ~/.claude/Skills/[PackageName]/Tools

# Save each tool
# Copy code from Tools section above to:
# ~/.claude/Skills/[PackageName]/Tools/ToolName.ts
```

**3. Configure environment:**

Add to `~/.claude/.env`:

```bash
SERVICE_API_KEY=your_key
```

**4. Set up skill routing (if applicable):**

Add to your skill routing configuration:
```yaml
[Copy skill definition from above]
```

**5. Test installation:**

```bash
[Run smoke test command]
```

---

## Configuration

### Required Settings

[List of environment variables, config files, paths, etc.]

| Setting | Purpose | Default | Required |
|---------|---------|---------|----------|
| `SERVICE_API_KEY` | [Purpose] | None | Yes |
| `SETTING_NAME` | [Purpose] | `value` | No |

### Optional Settings

[Additional configuration options]

### Recommended Defaults

[What settings work best for typical usage]

---

## Testing

### Smoke Test

Verify the package works end-to-end:

```bash
# 1. [Test step 1]
command1

# 2. [Test step 2]
command2

# 3. [Verify results]
ls -lh output.txt
```

**Success criteria:**
- ✅ [Criterion 1]
- ✅ [Criterion 2]
- ✅ [Criterion 3]

### Validation Checklist

For production use, verify:

```bash
# [Validation check 1]
- [ ] [Thing to check]

# [Validation check 2]
- [ ] [Thing to check]

# [Validation check 3]
- [ ] [Thing to check]
```

---

## Troubleshooting

### Issue: [Common Problem 1]

**Cause:** [Why it happens]

**Fix:**

```bash
[Solution commands or steps]
```

---

### Issue: [Common Problem 2]

**Cause:** [Why it happens]

**Fix:**

```bash
[Solution commands or steps]
```

---

### Issue: [Common Problem 3]

[Repeat pattern for all common issues you've encountered]

[Include at least 4-6 common issues]

---

## Credits

**Original concept:** [Attribution]

**Influences:**
- [Person/Project 1] - [What they contributed]
- [Person/Project 2] - [What they contributed]

**Technical implementation:**
- [Tool/Service 1] - [What it does]
- [Tool/Service 2] - [What it does]

**Community contributions:**
- [Contributor 1]: [What they added]
- (More contributions will be listed as package evolves)

---

## Resources

### Further Reading

- [Link 1] - [Description]
- [Link 2] - [Description]

### Related Packages

- **[PackageName]** - [How it relates to this package]
- **[AnotherPackage]** - [How they work together]

### External Documentation

- [API docs link]
- [Tool documentation]
- [Relevant articles/tutorials]

---

## Version History

### v1.0.0 (YYYY-MM-DD)
- Initial package release
- [Feature 1]
- [Feature 2]
- [Feature 3]

---

## License

MIT License

Copyright (c) [Year] [Author Name]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

**End of [PackageName] Package v1.0.0**

For support, issues, or contributions, visit: https://github.com/danielmiessler/PAI

Generated with Personal AI Infrastructure (PAI) Package System
