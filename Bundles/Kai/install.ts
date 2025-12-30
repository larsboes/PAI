#!/usr/bin/env bun
/**
 * Kai Bundle Installation Wizard v1.1.0
 *
 * Simplified interactive CLI wizard for setting up the Kai bundle.
 * Installs directly to ~/.claude with automatic backup.
 *
 * Usage: bun run install.ts
 */

import { $ } from "bun";
import * as readline from "readline";
import { existsSync } from "fs";

// =============================================================================
// TYPES
// =============================================================================

interface WizardConfig {
  daName: string;
  timeZone: string;
  userName: string;
  elevenLabsApiKey?: string;
  elevenLabsVoiceId?: string;
}

// =============================================================================
// UTILITIES
// =============================================================================

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function ask(question: string): Promise<string> {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer.trim());
    });
  });
}

async function askWithDefault(question: string, defaultValue: string): Promise<string> {
  const answer = await ask(`${question} [${defaultValue}]: `);
  return answer || defaultValue;
}

async function askYesNo(question: string, defaultYes = true): Promise<boolean> {
  const defaultStr = defaultYes ? "Y/n" : "y/N";
  const answer = await ask(`${question} [${defaultStr}]: `);
  if (!answer) return defaultYes;
  return answer.toLowerCase().startsWith("y");
}

function printHeader(title: string) {
  console.log("\n" + "=".repeat(60));
  console.log(`  ${title}`);
  console.log("=".repeat(60) + "\n");
}

// =============================================================================
// BACKUP
// =============================================================================

async function createBackup(): Promise<boolean> {
  const claudeDir = `${process.env.HOME}/.claude`;
  const backupDir = `${process.env.HOME}/.claude-BACKUP`;

  if (!existsSync(claudeDir)) {
    console.log("No existing ~/.claude directory found. Fresh install.");
    return true;
  }

  if (existsSync(backupDir)) {
    console.log(`\nExisting backup found at ${backupDir}`);
    const overwrite = await askYesNo("Overwrite existing backup?", false);
    if (!overwrite) {
      console.log("Please manually remove or rename the existing backup first.");
      return false;
    }
    await $`rm -rf ${backupDir}`;
  }

  console.log(`\nBacking up ~/.claude to ~/.claude-BACKUP...`);
  await $`cp -r ${claudeDir} ${backupDir}`;
  console.log("Backup complete.");
  return true;
}

// =============================================================================
// MAIN WIZARD
// =============================================================================

async function gatherConfig(): Promise<WizardConfig> {
  printHeader("KAI BUNDLE SETUP");

  console.log("This wizard will configure your AI assistant.\n");
  console.log("Installation directory: ~/.claude (standard Claude Code location)\n");

  // Essential questions only
  const userName = await ask("What is your name? ");

  const daName = await askWithDefault(
    "What would you like to name your AI assistant?",
    "Kai"
  );

  const timeZone = await askWithDefault(
    "What's your timezone?",
    Intl.DateTimeFormat().resolvedOptions().timeZone
  );

  // Voice is optional
  const wantsVoice = await askYesNo("\nDo you want voice notifications? (requires ElevenLabs API key)", false);

  let elevenLabsApiKey: string | undefined;
  let elevenLabsVoiceId: string | undefined;

  if (wantsVoice) {
    elevenLabsApiKey = await ask("Enter your ElevenLabs API key: ");
    elevenLabsVoiceId = await askWithDefault(
      "Enter your preferred voice ID",
      "s3TPKV1kjDlVtZbl4Ksh"
    );
  }

  return {
    daName,
    timeZone,
    userName,
    elevenLabsApiKey,
    elevenLabsVoiceId,
  };
}

// =============================================================================
// FILE GENERATION
// =============================================================================

function generateSkillMd(config: WizardConfig): string {
  return `---
name: CORE
description: Personal AI Infrastructure core. AUTO-LOADS at session start. USE WHEN any session begins OR user asks about identity, response format, contacts, stack preferences.
---

# CORE - Personal AI Infrastructure

**Auto-loads at session start.** This skill defines your AI's identity, response format, and core operating principles.

## Identity

**Assistant:**
- Name: ${config.daName}
- Role: ${config.userName}'s AI assistant
- Operating Environment: Personal AI infrastructure built on Claude Code

**User:**
- Name: ${config.userName}

---

## First-Person Voice (CRITICAL)

Your AI should speak as itself, not about itself in third person.

**Correct:**
- "for my system" / "in my architecture"
- "I can help" / "my delegation patterns"
- "we built this together"

**Wrong:**
- "for ${config.daName}" / "for the ${config.daName} system"
- "the system can" (when meaning "I can")

---

## Stack Preferences

Default preferences (customize in CoreStack.md):

- **Language:** TypeScript preferred over Python
- **Package Manager:** bun (NEVER npm/yarn/pnpm)
- **Runtime:** Bun
- **Markup:** Markdown (NEVER HTML for basic content)

---

## Response Format (Optional)

Define a consistent response format for task-based responses:

\`\`\`
📋 SUMMARY: [One sentence]
🔍 ANALYSIS: [Key findings]
⚡ ACTIONS: [Steps taken]
✅ RESULTS: [Outcomes]
➡️ NEXT: [Recommended next steps]
\`\`\`

Customize this format in SKILL.md to match your preferences.

---

## Quick Reference

**Full documentation available in context files:**
- Contacts: \`Contacts.md\`
- Stack preferences: \`CoreStack.md\`
- Security protocols: \`SecurityProtocols.md\`
`;
}

function generateContactsMd(config: WizardConfig): string {
  return `# Contact Directory

Quick reference for frequently contacted people.

---

## Contacts

| Name | Role | Email | Notes |
|------|------|-------|-------|
| [Add contacts here] | [Role] | [email] | [Notes] |

---

## Adding Contacts

To add a new contact, edit this file following the table format above.

---

## Usage

When asked about someone:
1. Check this directory first
2. Return the relevant contact information
3. If not found, ask for details
`;
}

function generateCoreStackMd(config: WizardConfig): string {
  return `# Core Stack Preferences

Technical preferences for code generation and tooling.

Generated: ${new Date().toISOString().split("T")[0]}

---

## Language Preferences

| Priority | Language | Use Case |
|----------|----------|----------|
| 1 | TypeScript | Primary for all new code |
| 2 | Python | Data science, ML, when required |

---

## Package Managers

| Language | Manager | Never Use |
|----------|---------|-----------|
| JavaScript/TypeScript | bun | npm, yarn, pnpm |
| Python | uv | pip, pip3 |

---

## Runtime

| Purpose | Tool |
|---------|------|
| JavaScript Runtime | Bun |
| Serverless | Cloudflare Workers |

---

## Markup Preferences

| Format | Use | Never Use |
|--------|-----|-----------|
| Markdown | All content, docs, notes | HTML for basic content |
| YAML | Configuration, frontmatter | - |
| JSON | API responses, data | - |

---

## Code Style

- Prefer explicit over clever
- No unnecessary abstractions
- Comments only where logic isn't self-evident
- Error messages should be actionable
`;
}

// =============================================================================
// MAIN
// =============================================================================

async function main() {
  console.log(`
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   ██╗  ██╗ █████╗ ██╗    ██████╗ ██╗   ██╗███╗   ██╗██████╗ ██╗   ║
║   ██║ ██╔╝██╔══██╗██║    ██╔══██╗██║   ██║████╗  ██║██╔══██╗██║   ║
║   █████╔╝ ███████║██║    ██████╔╝██║   ██║██╔██╗ ██║██║  ██║██║   ║
║   ██╔═██╗ ██╔══██║██║    ██╔══██╗██║   ██║██║╚██╗██║██║  ██║██║   ║
║   ██║  ██╗██║  ██║██║    ██████╔╝╚██████╔╝██║ ╚████║██████╔╝███████╗
║   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚══════╝
║                                                                   ║
║              Personal AI Infrastructure - v1.1.0                  ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
  `);

  try {
    // Step 1: Create backup
    printHeader("STEP 1: BACKUP");
    const backupOk = await createBackup();
    if (!backupOk) {
      console.log("\nInstallation cancelled.");
      process.exit(1);
    }

    // Step 2: Gather configuration
    printHeader("STEP 2: CONFIGURATION");
    const config = await gatherConfig();

    // Step 3: Install
    printHeader("STEP 3: INSTALLATION");

    const claudeDir = `${process.env.HOME}/.claude`;

    // Create directory structure
    console.log("Creating directory structure...");
    await $`mkdir -p ${claudeDir}/Skills/CORE/Workflows`;
    await $`mkdir -p ${claudeDir}/Skills/CORE/Tools`;
    await $`mkdir -p ${claudeDir}/History/{Sessions,Learnings,Research,Decisions}`;
    await $`mkdir -p ${claudeDir}/hooks/lib`;
    await $`mkdir -p ${claudeDir}/Tools`;
    await $`mkdir -p ${claudeDir}/voice`;

    // Generate files
    console.log("Generating SKILL.md...");
    const skillMd = generateSkillMd(config);
    await Bun.write(`${claudeDir}/Skills/CORE/SKILL.md`, skillMd);

    console.log("Generating Contacts.md...");
    const contactsMd = generateContactsMd(config);
    await Bun.write(`${claudeDir}/Skills/CORE/Contacts.md`, contactsMd);

    console.log("Generating CoreStack.md...");
    const coreStackMd = generateCoreStackMd(config);
    await Bun.write(`${claudeDir}/Skills/CORE/CoreStack.md`, coreStackMd);

    // Create .env file
    console.log("Creating .env file...");
    const envFileContent = `# PAI Environment Configuration
# Created by Kai Bundle installer - ${new Date().toISOString().split("T")[0]}

DA="${config.daName}"
TIME_ZONE="${config.timeZone}"
${config.elevenLabsApiKey ? `ELEVENLABS_API_KEY="${config.elevenLabsApiKey}"` : "# ELEVENLABS_API_KEY="}
${config.elevenLabsVoiceId ? `ELEVENLABS_VOICE_ID="${config.elevenLabsVoiceId}"` : "# ELEVENLABS_VOICE_ID="}
`;
    await Bun.write(`${claudeDir}/.env`, envFileContent);

    // Add to shell profile
    console.log("Updating shell profile...");
    const shell = process.env.SHELL || "/bin/zsh";
    const shellProfile = shell.includes("zsh")
      ? `${process.env.HOME}/.zshrc`
      : `${process.env.HOME}/.bashrc`;

    const envExports = `
# PAI Configuration (added by Kai Bundle installer)
export DA="${config.daName}"
export TIME_ZONE="${config.timeZone}"
export PAI_SOURCE_APP="$DA"
${config.elevenLabsApiKey ? `export ELEVENLABS_API_KEY="${config.elevenLabsApiKey}"` : ""}
${config.elevenLabsVoiceId ? `export ELEVENLABS_VOICE_ID="${config.elevenLabsVoiceId}"` : ""}
`;

    const existingProfile = await Bun.file(shellProfile).text().catch(() => "");
    if (!existingProfile.includes("PAI Configuration")) {
      await Bun.write(shellProfile, existingProfile + "\n" + envExports);
      console.log(`Added environment variables to ${shellProfile}`);
    } else {
      console.log(`PAI environment variables already exist in ${shellProfile}`);
    }

    // Source the shell profile to make variables available
    console.log("Sourcing shell profile...");
    try {
      // Export to current process
      process.env.DA = config.daName;
      process.env.TIME_ZONE = config.timeZone;
      process.env.PAI_SOURCE_APP = config.daName;
      if (config.elevenLabsApiKey) process.env.ELEVENLABS_API_KEY = config.elevenLabsApiKey;
      if (config.elevenLabsVoiceId) process.env.ELEVENLABS_VOICE_ID = config.elevenLabsVoiceId;
      console.log("Environment variables set for current session.");
    } catch (e) {
      // Silently continue - environment is exported to file
    }

    // Summary
    printHeader("INSTALLATION COMPLETE");

    console.log(`
Your Kai system is configured:

  📁 Installation: ~/.claude
  💾 Backup: ~/.claude-BACKUP
  🤖 Assistant Name: ${config.daName}
  👤 User: ${config.userName}
  🌍 Timezone: ${config.timeZone}
  🔊 Voice: ${config.elevenLabsApiKey ? "Enabled" : "Disabled"}

Files created:
  - ~/.claude/Skills/CORE/SKILL.md
  - ~/.claude/Skills/CORE/Contacts.md
  - ~/.claude/Skills/CORE/CoreStack.md
  - ~/.claude/.env

Next steps:

  1. Install the packs IN ORDER by giving each pack file to your AI:
     - kai-hook-system.md
     - kai-history-system.md
     - kai-core-install.md
     - kai-voice-system.md (optional, requires ElevenLabs)

  2. Restart Claude Code to activate hooks

Your backup is at ~/.claude-BACKUP if you need to restore.
`);

  } catch (error) {
    console.error("\n❌ Installation failed:", error);
    process.exit(1);
  } finally {
    rl.close();
  }
}

main();
