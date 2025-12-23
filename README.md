<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./pai-logo.png">
  <source media="(prefers-color-scheme: light)" srcset="./pai-logo.png">
  <img alt="PAI Logo" src="./pai-logo.png" width="600">
</picture>

<br/>
<br/>

# Personal AI Infrastructure

### Self-contained functionality packages for building your own AI-powered system

<br/>

[![Version](https://img.shields.io/badge/version-0.1--alpha-blue?style=for-the-badge)](https://github.com/danielmiessler/Personal_AI_Infrastructure/releases)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)
[![Packages](https://img.shields.io/badge/skills-1-purple?style=for-the-badge)](Packages/)
[![Features](https://img.shields.io/badge/features-0-orange?style=for-the-badge)](Packages/)

<br/>

[**Browse Packages**](#-available-packages) · [**Quick Start**](#-quick-start) · [**Submit a Package**](#-contributing) · [**Community**](#-community)

<br/>

---

# The New PAI: Functionality Packages

</div>

**PAI has fundamentally changed.** Instead of a fragile mirrored system that requires constant synchronization, PAI is now a **collection of self-contained functionality packages** that your AI can integrate into any system.

## The Problem with Mirroring

The old PAI tried to maintain a complete, synchronized copy of a rapidly-evolving personal AI infrastructure (Kai). This created:

- **Constant breakage** - Changes in one system broke the other
- **Security risks** - Easy to accidentally leak private data during sync
- **Integration friction** - All-or-nothing approach, couldn't pick individual features
- **Maintenance burden** - Manual work to keep 747,211 interconnected pieces aligned

**This was 2025 thinking.**

## 2026 Thinking: PAI Packages

Instead of mirroring an entire system, PAI now provides **functionality packages** - self-contained bundles with everything your AI needs to implement a specific capability:

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
│ PAI Package (Single Markdown File)                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  📋 Package Metadata (version, deps, platforms)        │
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

**The key insight:** Give your AI the complete context it needs, and it can integrate the package into *your* system, whether that's Claude Code, OpenCode, Gemini Code, GPT-Codex, or a homebrew setup.

---

## 📦 Available Packages

### Skills (Action-Oriented Capabilities)

| Package | Version | Category | Description |
|---------|---------|----------|-------------|
| [**Art**](Packages/Art-Package.md) | 1.0.0 | Visual Content | Complete visual content system with charcoal architectural sketch aesthetic. Generate blog headers, technical diagrams, comparisons, and more with consistent branding. |

### Features (Architectural Systems)

| Package | Version | Category | Description |
|---------|---------|----------|-------------|
| *Coming soon* | - | - | Infrastructure packages being extracted from Kai |

### Coming Soon

**Skills being packaged:**
- **Research** - Multi-source research orchestration with parallel agents
- **Blogging** - Complete blog workflow (write, optimize, deploy)
- **Newsletter** - Email newsletter drafting and publishing
- **OSINT** - Open-source intelligence gathering
- **Metrics** - Analytics aggregation across properties
- **Security** - Vulnerability management and security workflows

**Features being packaged:**
- **History System** - UOCS (Uniform Output Capture Standard) documentation system
- **Skill System** - Skill routing and workflow management
- **Agent Factory** - Custom agent creation and orchestration
- **Prompting System** - Meta-prompting and template framework

[**Submit your own package**](#-contributing) →

---

## 🚀 Quick Start

### Option 1: AI-Assisted Installation (Recommended)

1. **Browse packages** - Find a package you want in [Packages/](Packages/)
2. **Give it to your AI** - Provide the entire package markdown file
3. **Ask your AI to install it:**

```
Install the Art package into my system. Set up the skill routing,
save the tools, verify dependencies, and test it works.
```

Your AI will:
- Check for required dependencies
- Save code to appropriate directories
- Set up routing/hooks (if applicable)
- Validate the installation
- Run a test to ensure it works

### Option 2: Manual Installation

Each package includes detailed manual installation instructions. Open the package file and follow the "Installation → Manual" section.

### Option 3: Browse and Cherry-Pick

Packages are self-contained markdown files. You can:
- Read the code directly in the package
- Copy specific functions or workflows
- Adapt the approach to your own system
- Use it as reference documentation

**No forced structure. No mandatory setup. Take what's useful, leave the rest.**

---

## 📖 How PAI Packages Work

PAI offers **two types of packages**, each with its own structure and purpose:

### Package Type 1: Skills

**Skills** are action-oriented capabilities that your AI can invoke - things like generating visual content, conducting research, or processing data.

**Examples:** Art (visual content generation), Research (multi-source investigation), OSINT (intelligence gathering)

**Structure:**
1. **🤖 Assistant Install Prompt** - Step-by-step instructions for AI to autonomously install
2. **Package Metadata** - Version, dependencies, API keys, platform support
3. **The Problem** - What's broken/missing?
4. **The Solution** - How this skill fixes it
5. **Quick Start** - Get running in 60 seconds
6. **Package Contents** - Workflows, tools, context files (complete source code)
7. **Examples** - Real usage scenarios
8. **Installation** - AI-assisted + manual steps
9. **Testing** - Smoke tests and validation
10. **Troubleshooting** - Common issues and fixes
11. **Credits** - Attribution for ideas, influences, collaborators
12. **Resources** - Additional reading, related projects, external docs

### Package Type 2: Features

**Features** are architectural patterns and systems - infrastructure pieces like custom history systems, skill routing, agent orchestration, or prompting frameworks.

**Examples:** History System (UOCS documentation), Skill System (routing and management), Agent Factory (custom agent creation), Prompting System (meta-prompting and templates)

**Structure:**
1. **🤖 Assistant Install Prompt** - Step-by-step instructions for AI to autonomously install
2. **Package Metadata** - Version, dependencies, platform support
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

**All packages include:**

```yaml
package:
  name: PackageName
  version: 1.0.0
  category: visual-content | infrastructure | research | automation
  type: skill | feature
  author: Contributor Name
  license: MIT
  requires:
    - Other-Package >= 1.0.0 (optional dependencies)
  platforms: [macos, linux, windows]
  dependencies:
    tools: [bun, ImageMagick]
    api_keys: [REPLICATE_API_TOKEN]
```

**🤖 Assistant Install Prompt** - Every package starts with instructions for AI assistants to autonomously install it. Your AI reads the package, understands what it does, verifies dependencies, sets up the code, and validates it works - all without manual intervention.

### Why Single Files?

**Portability** - One file contains everything. Email it, share it, version control it.

**AI-Friendly** - Your AI can read the entire context at once. No navigation, no missing pieces.

**No Dependencies** - Packages are self-contained. They may *call* external tools, but the package itself is complete.

**Easy Review** - See exactly what you're installing. No hidden files, no surprises.

**Version Control** - Simple to track changes, fork, and merge improvements.

---

## 🛠️ For Package Developers

### Creating a PAI Package

**1. Choose your package type and get the template:**

```bash
# For Skills (action-oriented capabilities)
curl -O https://raw.githubusercontent.com/danielmiessler/PAI/main/SKILL_PACKAGE_TEMPLATE.md

# For Features (architectural patterns/systems)
curl -O https://raw.githubusercontent.com/danielmiessler/PAI/main/FEATURE_PACKAGE_TEMPLATE.md
```

**2. Fill in each section:**
- **Assistant Install Prompt** - Instructions for AI to install autonomously
- **Problem statement** - What's broken or missing?
- **Solution** - How your package fixes it
- **Implementation/Contents** - All code (embedded in markdown code blocks)
- **Examples** - Real usage scenarios
- **Installation steps** - Both AI-assisted and manual
- **Testing procedures** - Smoke tests and validation
- **Credits** - Attribution for ideas and influences
- **Resources** - Additional reading and related projects

**3. Validate it:**

Test with your own AI:
```
Here's my package. Install it into a fresh system and verify it works.
```

**4. Submit a PR:**

```bash
git checkout -b add-package-name
cp MyPackage.md Packages/
git add Packages/MyPackage.md
git commit -m "Add MyPackage - one-line description"
git push origin add-package-name
```

Open a PR with:
- Package description
- What problem it solves
- Testing you've done
- Screenshots/examples (if applicable)

### Package Quality Standards

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
- Integration with other packages

---

## 🏗️ Platform Compatibility

PAI packages are designed to be **platform-agnostic**:

| Platform | Status | Notes |
|----------|--------|-------|
| **Claude Code** | ✅ Full support | Native integration, all features work |
| **OpenCode** | ✅ Compatible | Skills/hooks may need adaptation |
| **Custom systems** | ✅ Compatible | Extract code, adapt to your structure |
| **Gemini Code / Codex** | 🔄 Testing | Should work with minor tweaks |
| **Manual use** | ✅ Always works | Packages are documentation + code |

The code itself is platform-independent (TypeScript, Python, Bash). Integration points (skills, hooks) may vary by platform.

---

## 💡 Why This Approach?

### What Changed from Old PAI

| Old PAI (Mirror) | New PAI (Packages) |
|------------------|--------------------|
| Mirrored entire system | Self-contained functionality bundles |
| Broke constantly | Stable, versioned releases |
| All-or-nothing | Pick what you need |
| Manual synchronization | AI-assisted installation |
| Security risks | Each package reviewed |
| Platform-locked | Platform-agnostic |

### The Philosophy

**Text is the interface.** Everything your AI needs to implement a capability should be in one readable file.

**Composability over monoliths.** Mix and match packages. Build your own stack.

**AI-first design.** Optimized for AI agents to read, understand, and implement - not just humans.

**Open contribution.** Anyone can submit a package. The best ideas win.

**No vendor lock-in.** Packages describe *how to solve a problem*, not just "here's the code for our platform."

---

## 🤝 Contributing

### Submit a Package

We welcome packages that solve real problems:

1. **Fork the repository**
2. **Create your package** - Follow [PACKAGE_TEMPLATE.md](PACKAGE_TEMPLATE.md)
3. **Test it thoroughly** - Install in a fresh system with AI assistance
4. **Submit a PR** - Include examples and testing evidence

### Package Review Process

Submitted packages are reviewed for:
- **Completeness** - All required sections present
- **Code quality** - Works as described, no obvious bugs
- **Security** - No hardcoded secrets, follows best practices
- **Usefulness** - Solves a real problem for users

**Review timeline:** Most packages reviewed within 7 days.

### Package Maintenance

**Authors maintain their packages.** When you submit a package, you're committing to:
- Respond to issues about your package
- Fix bugs that are reported
- Consider feature requests
- Update for breaking changes in dependencies

If a package becomes unmaintained, the community can fork and maintain a new version.

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [PACKAGES.md](PACKAGES.md) | Complete package system documentation |
| [SKILL_PACKAGE_TEMPLATE.md](SKILL_PACKAGE_TEMPLATE.md) | Template for creating skill packages |
| [FEATURE_PACKAGE_TEMPLATE.md](FEATURE_PACKAGE_TEMPLATE.md) | Template for creating feature packages |
| [MIGRATION_TO_PACKAGES.md](MIGRATION_TO_PACKAGES.md) | Migration guide from old mirror system |
| [SECURITY.md](SECURITY.md) | Security policies and best practices |

**Previous documentation** (pre-1.0 mirror system) is in [Docs/Archive/](Docs/Archive/).

---

## 🎯 Roadmap

### v1.0 (Current)

- [x] Package format specification
- [x] Art package (visual content system)
- [x] Package template
- [x] Installation documentation
- [ ] Package discovery website
- [ ] 5+ core packages released

### v1.1 (Q1 2026)

- [ ] Package dependency system
- [ ] Automated testing framework
- [ ] Package marketplace
- [ ] Cross-package integration examples
- [ ] 20+ packages available

### v1.2 (Q2 2026)

- [ ] Package composition tools
- [ ] Version compatibility checker
- [ ] Community package ratings
- [ ] Package search/filter by category
- [ ] 50+ packages available

---

## 🌐 Community

**GitHub Discussions:** [Join the conversation](https://github.com/danielmiessler/Personal_AI_Infrastructure/discussions)

**Discord:** [PAI Community](https://discord.gg/danielmiessler) (coming soon)

**Twitter/X:** [@danielmiessler](https://twitter.com/danielmiessler)

**Blog:** [danielmiessler.com](https://danielmiessler.com)

### Recognition

**Top package contributors** (packages submitted/maintained):
- (List will be populated as packages are submitted)

**Special thanks:**
- All early PAI users who provided feedback on the mirror system
- Contributors who helped identify pain points
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
- 📢 **Share your packages** - The more packages, the better PAI gets
- 💬 **Engage in discussions** - Help answer questions, share ideas
- 🐛 **Report issues** - Make PAI better for everyone
- ✍️ **Write about it** - Blog posts, videos, tutorials

**Premium support** coming soon for organizations.

---

<div align="center">

**Built with ❤️ by [Daniel Miessler](https://danielmiessler.com) and the PAI community**

*Augment yourself.*

</div>
