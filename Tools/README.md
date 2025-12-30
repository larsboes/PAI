<p align="center">
  <img src="tools-icon.png" alt="PAI Tools" width="128">
</p>

# Tools

Utilities and templates for building and maintaining your PAI installation.

This directory contains two types of resources:

- **Tools** - Diagnostic utilities you run to check, analyze, or manage your PAI installation
- **Templates** - Specifications for creating new packs and bundles

---

## Tools

### CheckPAIState.md

**PAI Installation Diagnostic**

A comprehensive diagnostic workflow for assessing your PAI installation health. Give this file to your AI and ask it to check your system.

**What it does:**
- Inventories installed packs and their status
- Verifies core systems are working (hooks, history, skills)
- Detects broken, misconfigured, or missing dependencies
- Compares your installation to the latest Kai bundle
- Provides actionable recommendations for improvements

**Usage:**
```
Give your AI this file and say: "Check my PAI state and give me recommendations."
```

**Output:** A health report with installed packs, issues found, and suggested next steps.

---

## Templates

### PAIPackTemplate.md

**Pack Creation Specification**

The complete specification for creating PAI packs. A pack is a single markdown file containing everything needed to add a capability to an AI agent system.

**What it covers:**
- YAML frontmatter schema (metadata, versioning, dependencies)
- Required sections and their purposes
- Icon generation requirements (256x256 transparent PNG)
- End-to-end completeness requirements
- Pre-installation system analysis
- Verification and testing guidance

**Key principle:** Packs must be COMPLETE. Everything needed to go from fresh AI agent to fully working system must be in the pack - no missing components, no "figure it out yourself."

---

### PAIBundleTemplate.md

**Bundle Creation Specification**

The complete specification for creating PAI bundles. A bundle is a curated collection of packs designed to work together as a cohesive system.

**What it covers:**
- Bundle directory structure
- AI Installation Wizard section (interactive setup)
- Architecture documentation (how packs work together)
- Installation order and dependencies
- Bundle-level verification
- Tier system (starter, intermediate, advanced, complete)

**Key principle:** Bundles document COMPLETE systems. They explain not just what packs to install, but WHY they work together and what emergent capabilities arise from the combination.

---

## Quick Reference

| File | Type | Purpose |
|------|------|---------|
| CheckPAIState.md | Tool | Diagnose your PAI installation health |
| PAIPackTemplate.md | Template | Create new packs |
| PAIBundleTemplate.md | Template | Create new bundles |

---

*Part of the [PAI (Personal AI Infrastructure)](https://github.com/danielmiessler/PAI) project.*
