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

[![Version](https://img.shields.io/badge/version-1.0-blue?style=for-the-badge)](https://github.com/danielmiessler/Personal_AI_Infrastructure/releases)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)
[![Packs](https://img.shields.io/badge/packs-1-purple?style=for-the-badge)](Packs/)

<br/>

[**Browse Packs**](#-available-packs) · [**Quick Start**](#-quick-start) · [**Principles**](#the-14-founding-principles) · [**Community**](#-community)

<br/>

[![PAI Overview Video](https://img.youtube.com/vi/iKwRWwabkEc/maxresdefault.jpg)](https://youtu.be/iKwRWwabkEc)

**[Watch the full PAI walkthrough](https://youtu.be/iKwRWwabkEc)** | **[Read: The Real Internet of Things](https://danielmiessler.com/blog/real-internet-of-things)**

---

# The best AI in the world should be available to everyone

</div>

Right now the most powerful AI setups are being built inside companies for efficiency and profits.

That's all good, but I think the purpose of technology is to serve humans—not the other way around. These new AI frameworks should be available to everyone, including people not in technology, so that regular people can use it to help them flourish.

That's what PAI is. It's the foundation for building a Personal AI System that understands your larger goals and context, gets better over time, and that works for *you* because it's *yours*. Not some generic chatbot. Not some common assistant. A full platform for magnifying yourself and your impact on the world.

**Related reading:**
- [The Real Internet of Things](https://danielmiessler.com/blog/real-internet-of-things) — The vision behind PAI
- [AI's Predictable Path: 7 Components](https://danielmiessler.com/blog/ai-predictable-path-7-components-2024) — Visual walkthrough of where AI is heading

---

<div align="center">

# PAI v1.0: Functionality Packs

</div>

**PAI provides functionality packs** - self-contained bundles with everything your AI needs to implement a specific capability:

- **The problem** being solved
- **The solution** and how it works
- **All code** (tools, CLIs, scripts)
- **Workflows** (step-by-step processes)
- **Context files** (guidelines, aesthetics, specifications)
- **Examples** and usage patterns
- **Installation instructions** (for both AI and manual)
- **Testing procedures**
- **Troubleshooting guides**

### How It Works

```
┌─────────────────────────────────────────────────────────┐
│ PAI Pack (Single Markdown File)                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  📋 Pack Metadata (version, deps, platforms)        │
│  🔍 Problem Statement                                   │
│  ✅ Solution Overview                                   │
│  ⚡ Quick Start                                         │
│  📦 Complete Code (embedded in markdown)               │
│  📖 Workflows (step-by-step processes)                 │
│  🎯 Examples (real usage scenarios)                    │
│  🔧 Installation (AI-assisted + manual)                │
│  ✅ Testing & Validation                               │
│  🐛 Troubleshooting                                    │
│  📚 Credits & Resources                                │
│                                                         │
└─────────────────────────────────────────────────────────┘
                         │
                         ↓
      ┌──────────────────┴──────────────────┐
      │                                     │
      ↓                                     ↓
┌──────────────┐                    ┌──────────────┐
│  Claude Code │                    │  Other AI    │
│  Integration │                    │  Systems     │
└──────────────┘                    └──────────────┘
```

**The key insight:** Give your AI the complete context it needs, and it can integrate the pack into *your* system, whether that's Claude Code, OpenCode, Gemini Code, GPT-Codex, or a homebrew setup.

---

## 📦 Available Packs

### Skills (Action-Oriented Capabilities)

| Pack | Version | Category | Description |
|---------|---------|----------|-------------|
| [**Art**](Packs/Art-Pack.md) | 1.0.0 | Visual Content | Complete visual content system with charcoal architectural sketch aesthetic. Generate blog headers, technical diagrams, comparisons, and more with consistent branding. |

### Features (Architectural Systems)

| Pack | Version | Category | Description |
|---------|---------|----------|-------------|
| *Coming soon* | - | - | Infrastructure packs being extracted from Kai |

### Coming Soon

**Skills being packd:**
- **Research** - Multi-source research orchestration with parallel agents
- **Blogging** - Complete blog workflow (write, optimize, deploy)
- **Newsletter** - Email newsletter drafting and publishing
- **OSINT** - Open-source intelligence gathering
- **Metrics** - Analytics aggregation across properties
- **Security** - Vulnerability management and security workflows

**Features being packd:**
- **History System** - UOCS (Uniform Output Capture Standard) documentation system
- **Skill System** - Skill routing and workflow management
- **Agent Factory** - Custom agent creation and orchestration
- **Prompting System** - Meta-prompting and template framework

[**Submit your own pack**](#-contributing) →

---

## 🚀 Quick Start

### Option 1: AI-Assisted Installation (Recommended)

1. **Browse packs** - Find a pack you want in [Packs/](Packs/)
2. **Give it to your AI** - Provide the entire pack markdown file
3. **Ask your AI to install it:**

```
Install the Art pack into my system. Set up the skill routing,
save the tools, verify dependencies, and test it works.
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

**Examples:** History System (UOCS documentation), Skill System (routing and management), Agent Factory (custom agent creation), Prompting System (meta-prompting and templates)

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

**1. Choose your pack type and get the template:**

```bash
# For Skills (action-oriented capabilities)
curl -O https://raw.githubusercontent.com/danielmiessler/PAI/main/SKILL_PACKAGE_TEMPLATE.md

# For Features (architectural patterns/systems)
curl -O https://raw.githubusercontent.com/danielmiessler/PAI/main/FEATURE_PACKAGE_TEMPLATE.md
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

### The Philosophy

**Text is the interface.** Everything your AI needs to implement a capability should be in one readable file.

**Composability over monoliths.** Mix and match packs. Build your own stack.

**AI-first design.** Optimized for AI agents to read, understand, and implement - not just humans.

**Open contribution.** Anyone can submit a pack. The best ideas win.

**No vendor lock-in.** Packs describe *how to solve a problem*, not just "here's the code for our platform."

### The 14 Founding Principles

These principles guide how PAI packs are designed and built:

1. **Clear Thinking + Prompting is King** - The quality of your prompts determines the quality of your results
2. **Scaffolding > Model** - Good structure around the model matters more than the model itself
3. **As Deterministic as Possible** - Reduce randomness, increase predictability
4. **Code Before Prompts** - Solve with code when you can, prompts when you must
5. **Spec / Test / Evals First** - Define success criteria before building
6. **UNIX Philosophy (Modular Tooling)** - Small tools that do one thing well
7. **ENG / SRE Principles** - Build for reliability, observability, maintainability
8. **CLI as Interface** - Command line first, GUI optional
9. **Goal → Code → CLI → Prompts → Agents** - The hierarchy of implementation
10. **Meta / Self Update System** - Systems that improve themselves
11. **Custom Skill Management** - Modular capabilities that route intelligently
12. **Custom History System** - Memory that persists and learns
13. **Custom Agent Personalities / Voices** - Distinct agents with unique traits
14. **Science as Cognitive Loop** - Hypothesis → Experiment → Measure → Iterate

---

## 🤝 Contributing

### Submit a Pack

We welcome packs that solve real problems:

1. **Fork the repository**
2. **Create your pack** - Follow [PACKAGE_TEMPLATE.md](PACKAGE_TEMPLATE.md)
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
- [x] Art pack (visual content system)
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

<div align="center">

**Built with ❤️ by [Daniel Miessler](https://danielmiessler.com) and the PAI community**

*Augment yourself.*

</div>
