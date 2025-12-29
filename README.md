<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./pai-logo.png">
  <source media="(prefers-color-scheme: light)" srcset="./pai-logo.png">
  <img alt="PAI Logo" src="./pai-logo.png" width="600">
</picture>

<br/>
<br/>

# Personal AI Infrastructure

### Open-source scaffolding for building your own AI-powered operating system

<br/>

[![Version](https://img.shields.io/badge/version-2.0-blue?style=for-the-badge)](https://github.com/danielmiessler/Personal_AI_Infrastructure/releases)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)
[![Packs](https://img.shields.io/badge/packs-1-purple?style=for-the-badge)](Packs/)

<br/>

[**Browse Packs**](#-available-packs) · [**Quick Start**](#-quick-start) · [**Principles**](#the-14-founding-principles) · [**Community**](#-community)

<br/>

[![PAI Overview Video](https://img.youtube.com/vi/Le0DLrn7ta0/maxresdefault.jpg)](https://youtu.be/Le0DLrn7ta0)

**[Watch the full PAI walkthrough](https://youtu.be/Le0DLrn7ta0)** | **[Read: The Real Internet of Things](https://danielmiessler.com/blog/real-internet-of-things)**

---

# The best AI in the world should be available to everyone

</div>

Right now the most powerful AI setups are being built inside companies for efficiency and profits.

That's all good, but I think the purpose of technology is to serve humans—not the other way around. These new AI frameworks should be available to everyone, including people not in technology, so that regular people can use it to help them flourish.

That's what PAI is. It's the foundation for building a Personal AI System that understands your larger goals and context, gets better over time, and that works for *you* because it's *yours*. Not some generic chatbot. Not some common assistant. A full platform for magnifying yourself and your impact on the world.

---

## What is PAI?

**PAI (Personal AI Infrastructure)** is a framework for building your own AI-powered operating system. It's built on top of AI coding agents like Claude Code, but personalized to *you* - your goals, your workflows, your context.

When you build a PAI system, you're creating what I call your own "Kai" - a personalized AI assistant that knows your preferences, remembers your history, and has specialized skills for the things you do most.

**PAI is:**
- **A philosophy** - The 14 Founding Principles that guide how to build AI systems
- **An architecture** - Skills, Hooks, History, Agents, and MCP integrations
- **A community** - Open-source packs that anyone can install or contribute

---

## The 14 Founding Principles

These principles guide how PAI systems are designed and built:

[![PAI System Principles](https://danielmiessler.com/images/pai-system-principles.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)

**[Read the full breakdown of each principle →](https://danielmiessler.com/blog/personal-ai-infrastructure)**

#### 1. Clear Thinking + Prompting is King
[![Clear Thinking](https://danielmiessler.com/images/pai-principle-01-clear-thinking.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
Good prompts come from clear thinking about what you actually need. Spend more time clarifying the problem than writing the prompt.

#### 2. Scaffolding > Model
[![Scaffolding](https://danielmiessler.com/images/pai-principle-02-scaffolding.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
The system architecture matters more than which model you use. Good scaffolding makes even smaller models perform well.

#### 3. As Deterministic as Possible
[![Deterministic](https://danielmiessler.com/images/pai-principle-03-deterministic.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
AI is probabilistic, but your infrastructure shouldn't be. Use templates and consistent patterns.

#### 4. Code Before Prompts
[![Code Before Prompts](https://danielmiessler.com/images/pai-principle-04-code-before-prompts.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
If you can solve it with a bash script, don't use AI. Only use AI for the parts that actually need intelligence.

#### 5. Spec / Test / Evals First
[![Spec Test Evals](https://danielmiessler.com/images/pai-principle-05-spec-test-evals.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
Before building anything complex, write specifications and tests. Use evals to measure if the system is actually working.

#### 6. UNIX Philosophy (Modular Tooling)
[![UNIX Philosophy](https://danielmiessler.com/images/pai-principle-06-unix-philosophy.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
Do one thing well. Make tools composable. Use text interfaces.

#### 7. ENG / SRE Principles
[![ENG SRE Principles](https://danielmiessler.com/images/pai-principle-07-eng-sre.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
Treat your AI infrastructure like production software: version control, automation, monitoring, rollback plans.

#### 8. CLI as Interface
[![CLI Interface](https://danielmiessler.com/images/pai-principle-08-cli-interface.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
Command-line interfaces are faster, more scriptable, and more reliable than GUIs.

#### 9. Goal → Code → CLI → Prompts → Agents
[![Goal to Agents](https://danielmiessler.com/images/pai-principle-09-goal-to-agents.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
The decision hierarchy: clarify the goal first, then try code, then CLI tools, then prompts, and only then agents.

#### 10. Meta / Self Update System
[![Meta Update](https://danielmiessler.com/images/pai-principle-10-meta-update.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
The system should be able to modify itself. Encode learnings so you never forget.

#### 11. Custom Skill Management
[![Skill Management](https://danielmiessler.com/images/pai-principle-11-skill-management.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
Skills are the foundation of personalization - modular capabilities that route intelligently.

#### 12. Custom History System
[![History System](https://danielmiessler.com/images/pai-principle-12-history-system.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
Everything worth knowing gets captured. History feeds back into context for future sessions.

#### 13. Custom Agent Personalities / Voices
[![Agent Personalities](https://danielmiessler.com/images/pai-principle-13-agent-personalities.png)](https://danielmiessler.com/blog/personal-ai-infrastructure)
Different work needs different approaches. Specialized agents with unique personalities and voices.

#### 14. Science as Cognitive Loop
The meta-principle: Hypothesis → Experiment → Measure → Iterate. Every decision follows this pattern.

---

<div align="center">

# PAI v2.0: PAI Packs

</div>

**PAI Packs** are modular upgrade packages for AI agent systems. Think of them like learning kung-fu in The Matrix - each pack is a complete, tested capability that you can download into your system.

**PAI Packs provide** self-contained bundles with everything your AI needs to implement a specific capability:

- **The problem** being solved
- **The solution** and how it works
- **All code** (tools, CLIs, scripts)
- **Workflows** (step-by-step processes)
- **Context files** (guidelines, aesthetics, specifications)
- **Examples** and usage patterns
- **Installation instructions** (for both AI and manual)
- **Testing procedures**
- **Troubleshooting guides**

**The key insight:** Give your AI the complete context it needs, and it can integrate the pack into *your* system, whether that's Claude Code, OpenCode, Gemini Code, GPT-Codex, or a homebrew setup.

---

## 📦 Available Packs

### Features (Architectural Systems)

| Pack | Version | Category | Description |
|---------|---------|----------|-------------|
| [**Kai History System**](Packs/history-system.md) | 1.0.0 | Infrastructure | Automatic context-tracking system that captures all work, decisions, and learnings with zero manual effort |

### Skills (Action-Oriented Capabilities)

| Pack | Version | Category | Description |
|---------|---------|----------|-------------|
| *Coming soon* | - | - | Skills being extracted and packaged |

### Coming Soon

**Features being packaged:**
- **Skill System** - Skill routing and workflow management
- **Agent Factory** - Custom agent creation and orchestration
- **Prompting System** - Meta-prompting and template framework

**Skills being packaged:**
- **Art** - Visual content generation system
- **Research** - Multi-source research orchestration with parallel agents
- **OSINT** - Open-source intelligence gathering

[**Submit your own pack**](#-contributing) →

---

## 🚀 Quick Start

### Option 1: AI-Assisted Installation (Recommended)

1. **Browse packs** - Find a pack you want in [Packs/](Packs/)
2. **Give it to your AI** - Provide the entire pack markdown file
3. **Ask your AI to install it:**

```
Install the History System pack into my system. Set up the hooks,
save the code, verify dependencies, and test it works.
```

Your AI will:
- Check for required dependencies
- Save code to appropriate directories
- Set up routing/hooks (if applicable)
- Validate the installation
- Run a test to ensure it works

### Option 2: Manual Installation

Each pack includes detailed manual installation instructions. Open the pack file and follow the "Installation → Manual" section.

### Option 3: Browse and Cherry-Pick

Packs are self-contained markdown files. You can:
- Read the code directly in the pack
- Copy specific functions or workflows
- Adapt the approach to your own system
- Use it as reference documentation

**No forced structure. No mandatory setup. Take what's useful, leave the rest.**

---

## 📖 How PAI Packs Work

PAI offers **two types of packs**, each with its own structure and purpose:

### Pack Type 1: Skills

**Skills** are action-oriented capabilities that your AI can invoke - things like generating visual content, conducting research, or processing data.

**Examples:** Art (visual content generation), Research (multi-source investigation), OSINT (intelligence gathering)

**Structure:**
1. **🤖 Assistant Install Prompt** - Step-by-step instructions for AI to autonomously install
2. **Pack Metadata** - Version, dependencies, API keys, platform support
3. **The Problem** - What's broken/missing?
4. **The Solution** - How this skill fixes it
5. **Quick Start** - Get running in 60 seconds
6. **Pack Contents** - Workflows, tools, context files (complete source code)
7. **Examples** - Real usage scenarios
8. **Installation** - AI-assisted + manual steps
9. **Testing** - Smoke tests and validation
10. **Troubleshooting** - Common issues and fixes
11. **Credits** - Attribution for ideas, influences, collaborators
12. **Resources** - Additional reading, related projects, external docs

### Pack Type 2: Features

**Features** are architectural patterns and systems - infrastructure pieces like custom history systems, skill routing, agent orchestration, or prompting frameworks.

**Examples:** History System (automatic context-tracking), Skill System (routing and management), Agent Factory (custom agent creation), Prompting System (meta-prompting and templates)

**Structure:**
1. **🤖 Assistant Install Prompt** - Step-by-step instructions for AI to autonomously install
2. **Pack Metadata** - Version, dependencies, platform support
3. **The Problem** - What architectural challenge exists?
4. **The Solution** - The design pattern and approach
5. **Implementation** - Complete code, configuration files, integration guides
6. **Examples** - Real-world usage patterns
7. **Installation** - AI-assisted + manual steps
8. **Testing** - Validation procedures
9. **Troubleshooting** - Common integration issues
10. **Credits** - Attribution for architectural ideas, influences
11. **Resources** - Additional reading, similar systems, theoretical background

### Universal Elements

**All packs include:**

```yaml
pack:
  name: PackName
  version: 1.0.0
  category: visual-content | infrastructure | research | automation
  type: skill | feature
  author: Contributor Name
  license: MIT
  requires:
    - Other-Pack >= 1.0.0 (optional dependencies)
  platforms: [macos, linux, windows]
  dependencies:
    tools: [bun, ImageMagick]
    api_keys: [REPLICATE_API_TOKEN]
```

**🤖 Assistant Install Prompt** - Every pack starts with instructions for AI assistants to autonomously install it. Your AI reads the pack, understands what it does, verifies dependencies, sets up the code, and validates it works - all without manual intervention.

### Why Single Files?

**Portability** - One file contains everything. Email it, share it, version control it.

**AI-Friendly** - Your AI can read the entire context at once. No navigation, no missing pieces.

**No Dependencies** - Packs are self-contained. They may *call* external tools, but the pack itself is complete.

**Easy Review** - See exactly what you're installing. No hidden files, no surprises.

**Version Control** - Simple to track changes, fork, and merge improvements.

---

## 🛠️ For Pack Developers

### Creating a PAI Pack

**1. Get the pack template:**

```bash
curl -O https://raw.githubusercontent.com/danielmiessler/PAI/main/PAIPackTemplate.md
```

**2. Fill in each section:**
- **Assistant Install Prompt** - Instructions for AI to install autonomously
- **Problem statement** - What's broken or missing?
- **Solution** - How your pack fixes it
- **Implementation/Contents** - All code (embedded in markdown code blocks)
- **Examples** - Real usage scenarios
- **Installation steps** - Both AI-assisted and manual
- **Testing procedures** - Smoke tests and validation
- **Credits** - Attribution for ideas and influences
- **Resources** - Additional reading and related projects

**3. Validate it:**

Test with your own AI:
```
Here's my pack. Install it into a fresh system and verify it works.
```

**4. Submit a PR:**

```bash
git checkout -b add-pack-name
cp MyPack.md Packs/
git add Packs/MyPack.md
git commit -m "Add MyPack - one-line description"
git push origin add-pack-name
```

Open a PR with:
- Pack description
- What problem it solves
- Testing you've done
- Screenshots/examples (if applicable)

### Pack Quality Standards

**Must have:**
- ✅ Clear problem statement
- ✅ Complete working code (tested)
- ✅ Real examples (not placeholders)
- ✅ Both AI and manual installation instructions
- ✅ Troubleshooting section
- ✅ No hardcoded personal data

**Nice to have:**
- Screenshots of output
- Video demo
- Multiple examples for different use cases
- Integration with other packs

---

## 🏗️ Platform Compatibility

PAI packs are designed to be **platform-agnostic**:

| Platform | Status | Notes |
|----------|--------|-------|
| **Claude Code** | ✅ Full support | Native integration, all features work |
| **OpenCode** | ✅ Compatible | Skills/hooks may need adaptation |
| **Custom systems** | ✅ Compatible | Extract code, adapt to your structure |
| **Gemini Code / Codex** | 🔄 Testing | Should work with minor tweaks |
| **Manual use** | ✅ Always works | Packs are documentation + code |

The code itself is platform-independent (TypeScript, Python, Bash). Integration points (skills, hooks) may vary by platform.

---

## 💡 Why Packs?

**Text is the interface.** Everything your AI needs to implement a capability should be in one readable file.

**Composability over monoliths.** Mix and match packs. Build your own stack.

**AI-first design.** Optimized for AI agents to read, understand, and implement - not just humans.

**Open contribution.** Anyone can submit a pack. The best ideas win.

**No vendor lock-in.** Packs describe *how to solve a problem*, not just "here's the code for our platform."

---

## 🤝 Contributing

### Submit a Pack

We welcome packs that solve real problems:

1. **Fork the repository**
2. **Create your pack** - Follow [PAIPackTemplate.md](PAIPackTemplate.md)
3. **Test it thoroughly** - Install in a fresh system with AI assistance
4. **Submit a PR** - Include examples and testing evidence

### Pack Review Process

Submitted packs are reviewed for:
- **Completeness** - All required sections present
- **Code quality** - Works as described, no obvious bugs
- **Security** - No hardcoded secrets, follows best practices
- **Usefulness** - Solves a real problem for users

**Review timeline:** Most packs reviewed within 7 days.

### Pack Maintenance

**Authors maintain their packs.** When you submit a pack, you're committing to:
- Respond to issues about your pack
- Fix bugs that are reported
- Consider feature requests
- Update for breaking changes in dependencies

If a pack becomes unmaintained, the community can fork and maintain a new version.

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [PACKS.md](PACKS.md) | Complete pack system documentation |
| [SECURITY.md](SECURITY.md) | Security policies and best practices |

---

## 🎯 Roadmap

### v1.0 (Current)

- [x] Pack format specification
- [x] History System pack (context-tracking)
- [x] Pack template
- [x] Installation documentation
- [ ] Pack discovery website
- [ ] 5+ core packs released

### v1.1 (Q1 2026)

- [ ] Pack dependency system
- [ ] Automated testing framework
- [ ] Pack marketplace
- [ ] Cross-pack integration examples
- [ ] 20+ packs available

### v1.2 (Q2 2026)

- [ ] Pack composition tools
- [ ] Version compatibility checker
- [ ] Community pack ratings
- [ ] Pack search/filter by category
- [ ] 50+ packs available

---

## 🌐 Community

**GitHub Discussions:** [Join the conversation](https://github.com/danielmiessler/Personal_AI_Infrastructure/discussions)

**Discord:** [PAI Community](https://discord.gg/danielmiessler) (coming soon)

**Twitter/X:** [@danielmiessler](https://twitter.com/danielmiessler)

**Blog:** [danielmiessler.com](https://danielmiessler.com)

### Recognition

**Top pack contributors** (packs submitted/maintained):
- (List will be populated as packs are submitted)

**Special thanks:**
- All early PAI users who provided feedback
- The Claude Code team for building an incredible platform

---

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

**TL;DR:** Do whatever you want with this. Build on it, sell it, modify it. Just don't blame us if something breaks. Attribution appreciated but not required.

---

## 🎁 Support PAI

PAI is **free and open-source forever.**

If you find it valuable:

- ⭐ **Star the repo** - Helps others discover it
- 📢 **Share your packs** - The more packs, the better PAI gets
- 💬 **Engage in discussions** - Help answer questions, share ideas
- 🐛 **Report issues** - Make PAI better for everyone
- ✍️ **Write about it** - Blog posts, videos, tutorials

**Premium support** coming soon for organizations.

---

## 📚 Related Reading

- [The Real Internet of Things](https://danielmiessler.com/blog/real-internet-of-things) — The vision behind PAI
- [AI's Predictable Path: 7 Components](https://danielmiessler.com/blog/ai-predictable-path-7-components-2024) — Visual walkthrough of where AI is heading
- [Building a Personal AI Infrastructure](https://danielmiessler.com/blog/personal-ai-infrastructure) — Full PAI walkthrough with examples

---

## 📜 Update History

<details open>
<summary><strong>v2.0.0 (2025-12-28) — PAI Packs System Launch</strong></summary>

<br/>

**Major Architecture Shift**
- Transitioned from "mirrored system" approach to modular **PAI Packs**
- Packs are self-contained, AI-installable capability bundles
- Platform-agnostic design: works with Claude Code, OpenCode, Gemini Code, GPT-Codex, or custom systems

**First Pack Released**
- **Kai History System** (v1.0.0) - Automatic context-tracking for entire AI infrastructure
- Complete implementation: 4 hooks, 3 library files, settings.json configuration

**New Documentation**
- `PAIPackTemplate.md` - Full pack template specification
- `PACKS.md` - Complete pack system documentation
- Updated README with 14 Founding Principles and full pack installation guide

**Why the Change?**
- v1.x tried to mirror the entire Kai system - too fragile, too many interdependencies
- v2.0 extracts battle-tested features as independent, installable modules
- Each pack is like learning kung-fu in The Matrix - a complete capability download

</details>

<details>
<summary><strong>v0.9.1 (2025-12-01) — Patch Release</strong></summary>

<br/>

**Fixes**
- `PAI_DIR` now auto-configures in settings.json during setup
- Platform-agnostic paths work across macOS, Linux, Windows
- Fixed timezone configuration in hooks

</details>

<details>
<summary><strong>v0.9.0 (2025-11-28) — Observability & Identity</strong></summary>

<br/>

**Observability Dashboard**
- Real-time agent monitoring with live charts
- Bun + Vue architecture for performance
- Multiple themes (Tokyo Night, Nord, Catppuccin, etc.)
- Security obfuscation for sensitive data

**Genericized Agent Identity**
- All agent references now use `process.env.DA || 'main'`
- No more hardcoded names — your DA name flows through the entire system
- Observability dashboard shows your configured identity

**Platform-Agnostic Configuration**
- Clear separation: `settings.json` for identity/paths, `.env` for API keys
- `DA` (Digital Assistant name) — your AI's identity
- `PAI_DIR` — root directory for all configuration
- `TIME_ZONE` — configurable timezone for timestamps

**Skill System Improvements**
- Canonical TitleCase file naming throughout
- Standardized skill-workflow-notification script for dashboard detection
- All paths use `${PAI_DIR}/` for location-agnostic installation

</details>

<details>
<summary><strong>v0.8.0 (2025-11-25) — Research & Documentation</strong></summary>

<br/>

**Research Skill**
- Comprehensive research skill with 10 specialized workflows
- Multi-source research with parallel agent execution
- Fabric pattern integration (242+ AI patterns)

**Infrastructure**
- Path standardization using `${PAI_DIR}/` throughout
- `PAI_CONTRACT.md` defining core guarantees
- Self-test validation system for health checks
- Protection system for PAI-specific files

</details>

<details>
<summary><strong>v0.7.0 (2025-11-20) — Protection & Clarity</strong></summary>

<br/>

**PAI Path Resolution System** (#112)
- Centralized `pai-paths.ts` library — single source of truth
- Smart detection with fallback to `~/.claude`
- Updated 7 hooks to use centralized paths

**PAI vs Kai Clarity** (#113)
- `PAI_CONTRACT.md` — official contract defining boundaries
- Self-test system (`bun ${PAI_DIR}/hooks/self-test.ts`)
- Clear README section distinguishing PAI from Kai

**Protection System**
- `.pai-protected.json` manifest of protected files
- `validate-protected.ts` script for pre-commit validation
- Pre-commit hook template for automated checks

</details>

<details>
<summary><strong>v0.6.5 (2025-11-18) — BrightData Integration</strong></summary>

<br/>

**Four-Tier Progressive Web Scraping**
- Tier 1: WebFetch (free, built-in)
- Tier 2: cURL with headers (free, more reliable)
- Tier 3: Playwright (free, JavaScript rendering)
- Tier 4: Bright Data MCP (paid, anti-bot bypass)

</details>

<details>
<summary><strong>v0.6.0 (2025-11-15) — Major Architecture Update</strong></summary>

<br/>

**Repository Restructure**
- Moved all configuration to `.claude/` directory
- Skills-as-containers architecture
- Three-tier progressive disclosure

**Skills System**
- Art skill with visual content generation
- Story-explanation skill for narrative summaries
- Create-skill and create-cli meta-skills

**Hook System**
- Comprehensive event capture system
- Session summary and tool output capture
- Tab title updates

**Voice Integration**
- Voice server with ElevenLabs TTS
- Session start notifications

</details>

<details>
<summary><strong>v0.5.0 and Earlier</strong></summary>

<br/>

**v0.5.0 — Foundation**
- CORE skill as central context loader
- Constitution defining system principles
- CLI-First Architecture pattern
- Initial skills: Fabric, FFUF, Alex Hormozi pitch

**Pre-v0.5.0 — Early Development**
- Initial repository setup
- Basic settings.json structure
- Agent personality definitions
- Foundational hook experiments

</details>

---

<div align="center">

**Built with ❤️ by [Daniel Miessler](https://danielmiessler.com) and the PAI community**

*Augment yourself.*

</div>
