# PAI Package System Documentation

**Complete guide to creating, using, and contributing PAI packages**

Version: 1.0.0
Last updated: 2025-12-22

---

## Table of Contents

1. [What Are PAI Packages?](#what-are-pai-packages)
2. [Package Format Specification](#package-format-specification)
3. [Creating a Package](#creating-a-package)
4. [Installing Packages](#installing-packages)
5. [Package Lifecycle](#package-lifecycle)
6. [Quality Standards](#quality-standards)
7. [Security Guidelines](#security-guidelines)
8. [Contribution Process](#contribution-process)
9. [FAQs](#faqs)

---

## What Are PAI Packages?

PAI Packages are **self-contained functionality bundles** that contain everything your AI needs to implement a specific capability in your personal AI system.

### The Core Concept

```
Traditional approach:
"Here's our codebase, go figure out how to integrate it"
❌ Requires deep understanding of host system
❌ Prone to breaking changes
❌ All-or-nothing integration

PAI Package approach:
"Here's a complete solution with full context for your AI to integrate"
✅ AI reads the package and adapts it to YOUR system
✅ Self-contained with all dependencies documented
✅ Pick only what you need
```

### What's in a Package?

Every PAI package contains:

1. **Problem Statement** - What's broken or missing?
2. **Solution Overview** - How this package addresses it
3. **Complete Source Code** - All tools, scripts, CLIs embedded in the markdown
4. **Workflows** - Step-by-step processes and decision trees
5. **Context Files** - Guidelines, specifications, aesthetic rules
6. **Examples** - Real usage scenarios with expected outputs
7. **Installation Instructions** - Both AI-assisted and manual
8. **Testing Procedures** - How to verify it works
9. **Troubleshooting** - Common issues and fixes
10. **Credits & Resources** - Attribution and further reading

### Why Single Markdown Files?

**Portability** - Email it, version control it, share it as one file

**AI-Optimized** - Your AI can read the entire context at once without navigation

**Human-Readable** - Open in any text editor, searchable, transparent

**Self-Contained** - No external dependencies for the package itself (though it may call external tools)

**Easy Review** - See exactly what you're installing before you install it

---

## Package Format Specification

### File Naming Convention

```
PackageName-Package.md
```

Examples:
- `Art-Package.md`
- `Research-Package.md`
- `OSINT-Package.md`

**Rules:**
- Title Case for package name
- Always ends with `-Package.md`
- No spaces (use hyphens)
- Descriptive, not generic

### Package Structure

```markdown
# PackageName Package vX.Y.Z

**One-line description**

---

## Package Metadata

\```yaml
package:
  name: PackageName
  version: X.Y.Z (semantic versioning)
  category: visual-content | automation | research | security | etc
  author: Your Name
  license: MIT (or other open source license)

  requires:
    - CORE >= 1.0.0 (optional dependency on other packages)
    - OtherPackage >= 2.0.0

  platforms:
    - macos
    - linux
    - windows (note any platform-specific limitations)

  dependencies:
    tools:
      - bun
      - ImageMagick
      - jq
    api_keys:
      - PROVIDER_API_KEY
      - ANOTHER_SERVICE_KEY
\```

---

## The Problem

[2-4 paragraphs describing the problem this package solves]

What's broken? What's inefficient? What gap exists?

---

## The Solution

[2-4 paragraphs describing how this package addresses the problem]

What's the approach? What makes it better? What's the key insight?

---

## Quick Start

### 1. Install Dependencies

\```bash
[Installation commands for required tools]
\```

### 2. Set Up API Keys

\```bash
[How to configure environment variables]
\```

### 3. Create Your First [Thing]

\```bash
[Minimal working example that proves it works]
\```

---

## Package Contents

### Skill Definition (if applicable)

\```yaml
name: SkillName
description: When to use this skill
trigger_phrases: ["phrase1", "phrase2"]
routing:
  - pattern: "regex or keyword"
    workflow: WorkflowName
\```

### Workflows

#### WorkflowName

**Purpose:** [What this workflow does]

**When to use:** [Trigger conditions]

**Process:**

\```markdown
[Complete step-by-step workflow]
[Can be multi-page if needed]
\```

### Tools

#### ToolName.ts (or .py, .sh)

**Purpose:** [What this tool does]

**Usage:**

\```bash
[Command-line usage examples]
\```

**Full Source Code:**

\```typescript
[Complete, working, tested code]
[No placeholders, no TODOs]
\```

### Context Files

#### ContextFileName.md

**Purpose:** [What context this provides]

\```markdown
[Full context file content]
\```

### Hooks (if applicable)

#### hook-name.ts

**Event:** [When this hook fires]

**Purpose:** [What it does]

\```typescript
[Complete hook code]
\```

---

## Examples

### Example 1: [Common Use Case]

**Scenario:** [Description of the situation]

**Command:**

\```bash
[Actual command to run]
\```

**Expected Output:**

[What should happen]

### Example 2: [Another Use Case]

[Repeat pattern]

---

## Installation

### Option A: AI-Assisted Installation (Recommended)

Give this package to your AI and ask:

> "Install the PackageName package into my system. Verify dependencies, save the tools, and test it works."

Your AI will:
1. [Step 1]
2. [Step 2]
3. [etc]

### Option B: Manual Installation

**1. Install dependencies:**

\```bash
[Commands]
\```

**2. Save the tools:**

\```bash
[Where to save each tool]
\```

**3. Configure environment:**

\```bash
[Environment setup]
\```

**4. Test installation:**

\```bash
[Smoke test command]
\```

---

## Configuration

### Required Settings

[List of environment variables, config files, etc.]

### Optional Settings

[Additional configuration options]

### Recommended Defaults

[What settings work best]

---

## Testing

### Smoke Test

\```bash
[Quick test to verify basic functionality]
\```

**Success criteria:**
- ✅ [Criterion 1]
- ✅ [Criterion 2]

### Validation Checklist

For production use, verify:

- [ ] [Thing 1]
- [ ] [Thing 2]
- [ ] [etc]

---

## Troubleshooting

### Issue: [Common Problem]

**Cause:** [Why it happens]

**Fix:**

\```bash
[Solution]
\```

### Issue: [Another Problem]

[Repeat pattern for all common issues]

---

## Credits

**Original concept:** [Attribution]

**Influences:**
- [Person/Project 1]
- [Person/Project 2]

**Technical implementation:**
- [Tool/Service 1]
- [Tool/Service 2]

**Community contributions:**
- [Contributor 1]: [What they added]
- [Contributor 2]: [What they added]

---

## Resources

### Further Reading

- [Link 1] - [Description]
- [Link 2] - [Description]

### Related Packages

- **PackageName** - [How it relates]
- **AnotherPackage** - [How it relates]

### External Documentation

- [API docs]
- [Tool documentation]

---

## Version History

### vX.Y.Z (YYYY-MM-DD)
- [Change 1]
- [Change 2]

### vX.Y.Z (YYYY-MM-DD)
- Initial release

---

## License

[License text - typically MIT for PAI packages]

---

**End of PackageName Package vX.Y.Z**

For support, issues, or contributions, visit: [Repository URL]
```

---

## Creating a Package

### Step 1: Identify a Problem

Good packages solve real problems:

- ✅ "I kept manually doing X, so I automated it"
- ✅ "I needed Y capability and built a workflow"
- ✅ "Existing tools don't handle Z well"
- ❌ "I wrote some code once and thought I'd share"
- ❌ "Here's a wrapper around an existing tool with no added value"

**Ask yourself:**
1. Does this solve a real problem I've experienced?
2. Would others benefit from this solution?
3. Is this self-contained enough to be a package?

### Step 2: Extract the Functionality

If extracting from an existing system:

1. **Identify all dependencies** - What files, tools, APIs does it need?
2. **Document the workflows** - How do you actually use this?
3. **Create examples** - What are real usage scenarios?
4. **Write tests** - How do you know it works?

If building from scratch:

1. **Start with the problem statement** - Be specific
2. **Design the solution** - How will it work?
3. **Build incrementally** - Start simple, add features
4. **Test thoroughly** - On fresh systems if possible

### Step 3: Write the Package

Use the template above. Fill in every section:

- **Don't skip sections** - Even if brief, include them
- **Real examples, not placeholders** - `example.com` → actual URLs
- **Complete code** - No TODOs, no "implement this later"
- **Test your instructions** - Can someone actually follow them?

### Step 4: Test with AI

Before submitting:

1. Give the package to YOUR AI
2. Ask it to install the package
3. See if it works without your help
4. Fix any issues the AI encounters
5. Repeat until installation is smooth

### Step 5: Submit

See [Contribution Process](#contribution-process) below.

---

## Installing Packages

### Method 1: AI-Assisted (Recommended)

**For Claude Code users:**

1. Open the package markdown file
2. Copy the entire content
3. Paste into Claude Code and say:

```
Install this package into my system. Verify all dependencies,
save the tools to appropriate directories, set up any routing
or hooks needed, and test that it works.
```

Claude will:
- Parse the package
- Check for required tools/APIs
- Create necessary directories
- Save code to appropriate locations
- Configure any integrations
- Run tests to verify functionality

**For other AI platforms:**

The process is similar - give your AI the package and ask it to install. The AI should be able to read the package format and adapt it to your system structure.

### Method 2: Manual Installation

If you prefer manual control or don't have AI assistance:

1. **Read the package** - Understand what it does
2. **Check dependencies** - Install required tools
3. **Set up environment** - Configure API keys, env vars
4. **Save the code** - Copy tools to your directories
5. **Follow integration steps** - Skills, hooks, etc
6. **Run tests** - Verify it works

**Recommended directory structure:**

```
~/.your-ai-system/
├── Skills/
│   └── PackageName/
│       ├── Tools/
│       │   ├── tool1.ts
│       │   └── tool2.ts
│       ├── Workflows/
│       │   └── workflow.md
│       └── SKILL.md
├── .env (for API keys)
└── settings.json
```

### Method 3: Cherry-Pick

You don't have to install the whole package:

- **Copy just the code** you need
- **Adapt the workflow** to your process
- **Use as reference** documentation
- **Extract the concept** and implement differently

**Packages are not prescriptive. They're building blocks.**

---

## Package Lifecycle

### Versioning

PAI packages use [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH

1.0.0 → 1.0.1   (bug fix, backwards compatible)
1.0.1 → 1.1.0   (new feature, backwards compatible)
1.1.0 → 2.0.0   (breaking change)
```

**When to bump versions:**

- **PATCH** (1.0.0 → 1.0.1)
  - Bug fixes
  - Documentation improvements
  - Typo corrections

- **MINOR** (1.0.0 → 1.1.0)
  - New features (backwards compatible)
  - New workflows added
  - New optional parameters

- **MAJOR** (1.0.0 → 2.0.0)
  - Breaking changes to APIs
  - Removed features
  - Changed workflows that break existing usage

### Maintenance

**Package authors are responsible for:**

- Responding to issues about their package
- Fixing reported bugs
- Considering feature requests
- Updating for dependency changes
- Marking package as deprecated if abandoned

**If a package becomes unmaintained:**

- Community can fork and maintain separately
- Can be marked as "community maintained"
- Original author retains credit

### Deprecation

If a package becomes obsolete:

1. Mark it as `[DEPRECATED]` in the README
2. Explain why (replaced by X, no longer relevant, etc.)
3. Provide migration path if applicable
4. Keep the package available for reference

---

## Quality Standards

### Must Have (Required for Acceptance)

- ✅ **Clear problem statement** - What does this solve?
- ✅ **Complete working code** - Tested, no placeholders
- ✅ **Real examples** - Actual usage, not hypothetical
- ✅ **Installation instructions** - Both AI and manual
- ✅ **Testing procedure** - How to verify it works
- ✅ **Troubleshooting section** - Common issues
- ✅ **No hardcoded secrets** - Use environment variables
- ✅ **License specified** - MIT preferred for PAI

### Should Have (Strongly Recommended)

- Screenshots of output (for visual packages)
- Video demo or walkthrough
- Multiple examples for different use cases
- Integration notes for popular platforms
- Performance characteristics (if relevant)
- Known limitations documented

### Nice to Have

- Diagram of architecture/flow
- Comparison with alternatives
- Advanced usage patterns
- Customization options
- Related packages integration

### Code Quality

**All code in packages must:**

- Work as described (test it!)
- Follow reasonable conventions for the language
- Include error handling
- Have clear variable names
- Be reasonably efficient
- Be secure (no SQL injection, XSS, etc.)

**Code doesn't need to be:**

- Perfect
- Over-engineered
- Production-grade enterprise quality
- Optimized to death

**The standard:** Would you use this yourself? If yes, it's probably good enough.

---

## Security Guidelines

### API Keys and Secrets

**NEVER include in packages:**

- ❌ Actual API keys
- ❌ Passwords or tokens
- ❌ Private URLs or endpoints
- ❌ Personal data
- ❌ Internal system details

**Instead:**

- ✅ Use environment variable references (`$API_KEY`)
- ✅ Provide `.env.example` templates
- ✅ Document which keys are needed
- ✅ Link to where to get keys

### Code Security

**Check for:**

- SQL injection vulnerabilities
- Command injection risks
- XSS in generated output
- Path traversal issues
- Insecure deserial ization

**Best practices:**

- Validate all inputs
- Sanitize user data
- Use parameterized queries
- Escape shell commands
- Limit file system access

### Dependency Security

**For external dependencies:**

- Document what they are and why needed
- Check for known vulnerabilities
- Pin versions when possible
- Provide alternatives if available

---

## Contribution Process

### 1. Fork the Repository

```bash
git clone https://github.com/yourusername/PAI
cd PAI
```

### 2. Create a Branch

```bash
git checkout -b add-package-yourpackagename
```

### 3. Create Your Package

Save your package to `Packages/YourPackage-Package.md`

### 4. Test Thoroughly

- Install in a fresh system using the instructions
- Have your AI try to install it
- Fix any issues that come up
- Document troubleshooting steps

### 5. Submit a Pull Request

```bash
git add Packages/YourPackage-Package.md
git commit -m "Add YourPackage - one-line description"
git push origin add-package-yourpackagename
```

Then open a PR on GitHub with:

**Title:** `Add [PackageName] Package - [One-line description]`

**Description:**

```markdown
## Package: [PackageName]

### What It Does
[Brief description]

### Problem It Solves
[The problem statement]

### Testing Done
- [ ] Tested manual installation
- [ ] Tested AI-assisted installation
- [ ] All examples work as described
- [ ] Tested on [platforms]

### Screenshots/Demos
[If applicable]

### Checklist
- [ ] Package follows format specification
- [ ] All code is complete and tested
- [ ] No hardcoded secrets
- [ ] Real examples included
- [ ] Installation instructions work
- [ ] Troubleshooting section complete
- [ ] Credits and attribution included
```

### 6. Review Process

Maintainers will review for:

- **Completeness** - All sections present
- **Quality** - Code works, examples are real
- **Security** - No secrets, no vulnerabilities
- **Usefulness** - Solves a real problem

**Timeline:** Most PRs reviewed within 7 days

**Feedback:** Reviewers may request changes. This is normal and expected.

### 7. Merge and Publication

Once approved:
- PR is merged
- Package appears in catalog
- You're listed as a contributor
- You maintain the package going forward

---

## FAQs

### Can I submit a package that uses paid APIs?

**Yes!** Many useful packages require paid services (AI models, specialized APIs, etc.).

Just ensure:
- Clearly document the cost (approximate pricing)
- Provide free alternatives if they exist
- Make it clear it's not free to run

### My package depends on another package. Is that OK?

**Yes!** Specify dependencies in the metadata:

```yaml
requires:
  - CORE >= 1.0.0
  - Research >= 2.1.0
```

### Can I update my package after it's submitted?

**Absolutely!** Package authors maintain their packages:

1. Make changes
2. Update version number
3. Add to version history
4. Submit PR

### What if someone else submits a package similar to mine?

**That's fine!** Competition is healthy:

- Different approaches to same problem
- Different trade-offs (speed vs quality, cost vs features)
- Personal preference

Users can choose what works best for them.

### Can I sell premium versions of my package?

**Yes**, but the version in PAI must be:
- Functional and useful on its own
- MIT licensed
- Free and open-source

You can offer:
- Premium support
- Extended features
- Hosted versions
- Consulting

Just be transparent about what's free vs paid.

### What if my package breaks due to a dependency update?

**You're responsible for maintaining it:**

1. Update the code to work with new dependency
2. Or pin to older version and document limitation
3. Or mark as deprecated and provide migration path

This is part of being a package maintainer.

### Can I submit packages for non-Claude platforms?

**Absolutely!** PAI packages should work across platforms:

- OpenCode
- Custom AI systems
- Gemini Code
- GPT-Codex
- Homebrew setups

Just note any platform-specific quirks in the documentation.

---

## Package Submission Checklist

Before submitting, verify:

### Format

- [ ] File named `PackageName-Package.md`
- [ ] Metadata section complete
- [ ] All required sections present
- [ ] Follows template structure

### Content

- [ ] Problem clearly stated
- [ ] Solution explained
- [ ] Quick start works
- [ ] All code complete (no TODOs)
- [ ] Real examples (not placeholders)
- [ ] Installation instructions tested
- [ ] Troubleshooting section complete

### Quality

- [ ] Code tested and works
- [ ] No hardcoded secrets
- [ ] No personal data
- [ ] Dependencies documented
- [ ] Security considerations addressed

### Testing

- [ ] Manual installation tested
- [ ] AI-assisted installation tested (if possible)
- [ ] All examples run successfully
- [ ] Tested on claimed platforms

### Documentation

- [ ] Credits and attribution included
- [ ] License specified
- [ ] Resources and links provided
- [ ] Version history started

---

## Resources

### Templates

- [PACKAGE_TEMPLATE.md](PACKAGE_TEMPLATE.md) - Start here for new packages

### Examples

- [Art-Package.md](Packages/Art-Package.md) - Complete visual content system (good reference)

### Documentation

- [README.md](README.md) - PAI overview
- [SECURITY.md](SECURITY.md) - Security policies
- [LICENSE](LICENSE) - MIT license details

### Community

- [GitHub Discussions](https://github.com/danielmiessler/Personal_AI_Infrastructure/discussions) - Ask questions
- [Issue Tracker](https://github.com/danielmiessler/Personal_AI_Infrastructure/issues) - Report problems

---

**Questions? Open a discussion or issue on GitHub.**

**Ready to contribute? We can't wait to see what you build!**
