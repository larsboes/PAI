#!/usr/bin/env bun
/**
 * Kai Bundle Installation Wizard
 *
 * Interactive CLI wizard for setting up the complete Kai bundle
 * with full identity and personalization configuration.
 *
 * Usage: bun run install.ts
 */

import { $ } from "bun";
import * as readline from "readline";

// =============================================================================
// TYPES
// =============================================================================

interface SystemConfig {
  paiDir: string;
  daName: string;
  timeZone: string;
  elevenLabsApiKey?: string;
  elevenLabsVoiceId?: string;
  shellProfile: string;
}

interface PersonalityTraits {
  humor: number;
  curiosity: number;
  precision: number;
  formality: number;
  playfulness: number;
  directness: number;
}

interface Contact {
  name: string;
  email: string;
  role: string;
  pronunciation?: string;
}

interface PersonalizationConfig {
  userName: string;
  userProfession: string;
  primaryPurpose: string;
  systemGoals: string[];
  fiveYearVision: string;
  employmentContext: "self-employed" | "employed" | "building-company" | "other";
  personalityMode: "generate" | "custom";
  personalityDescription?: string;
  personalityTraits?: PersonalityTraits;
  contacts: Contact[];
  technicalLevel: "beginner" | "intermediate" | "advanced" | "expert";
  isProgrammer: "yes" | "no" | "learning";
  primaryOS: "macos" | "windows" | "linux";
  preferredLanguages: string[];
  packageManager: "bun" | "npm" | "yarn" | "pnpm";
  serverRuntime: "bun" | "node" | "deno";
  usesCloudflare: boolean;
  backendPreference: string;
  databasePreference: string;
}

type WizardConfig = SystemConfig & PersonalizationConfig;

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

async function askNumber(question: string, min: number, max: number, defaultValue: number): Promise<number> {
  while (true) {
    const answer = await ask(`${question} (${min}-${max}) [${defaultValue}]: `);
    if (!answer) return defaultValue;
    const num = parseInt(answer, 10);
    if (!isNaN(num) && num >= min && num <= max) return num;
    console.log(`Please enter a number between ${min} and ${max}`);
  }
}

async function askChoice<T extends string>(question: string, options: T[], defaultOption?: T): Promise<T> {
  console.log(`\n${question}`);
  options.forEach((opt, i) => {
    const isDefault = opt === defaultOption ? " (default)" : "";
    console.log(`  ${i + 1}. ${opt}${isDefault}`);
  });

  while (true) {
    const answer = await ask("Enter number or value: ");
    if (!answer && defaultOption) return defaultOption;

    const num = parseInt(answer, 10);
    if (!isNaN(num) && num >= 1 && num <= options.length) {
      return options[num - 1];
    }

    const match = options.find(o => o.toLowerCase() === answer.toLowerCase());
    if (match) return match;

    console.log("Invalid choice, please try again.");
  }
}

async function askMultiSelect(question: string, options: string[]): Promise<string[]> {
  console.log(`\n${question} (enter numbers separated by commas, or 'done'):`);
  options.forEach((opt, i) => {
    console.log(`  ${i + 1}. ${opt}`);
  });

  const selected: string[] = [];
  while (true) {
    const answer = await ask("Add selection (or 'done'): ");
    if (answer.toLowerCase() === "done") break;

    const nums = answer.split(",").map(s => parseInt(s.trim(), 10));
    for (const num of nums) {
      if (!isNaN(num) && num >= 1 && num <= options.length) {
        const opt = options[num - 1];
        if (!selected.includes(opt)) {
          selected.push(opt);
          console.log(`  ✓ Added: ${opt}`);
        }
      }
    }
  }
  return selected;
}

function printHeader(title: string) {
  console.log("\n" + "=".repeat(60));
  console.log(`  ${title}`);
  console.log("=".repeat(60) + "\n");
}

function printSection(title: string) {
  console.log("\n" + "-".repeat(40));
  console.log(`  ${title}`);
  console.log("-".repeat(40) + "\n");
}

// =============================================================================
// WIZARD PHASES
// =============================================================================

async function gatherSystemConfig(): Promise<SystemConfig> {
  printHeader("PHASE 1: SYSTEM SETUP");

  const paiDir = await askWithDefault(
    "Where should PAI be installed?",
    "~/.config/pai"
  );

  const daName = await askWithDefault(
    "What would you like to name your AI assistant?",
    "PAI"
  );

  const timeZone = await askWithDefault(
    "What's your timezone?",
    Intl.DateTimeFormat().resolvedOptions().timeZone
  );

  const wantsVoice = await askYesNo("Do you want voice notifications (requires ElevenLabs)?", false);

  let elevenLabsApiKey: string | undefined;
  let elevenLabsVoiceId: string | undefined;

  if (wantsVoice) {
    elevenLabsApiKey = await ask("Enter your ElevenLabs API key: ");
    elevenLabsVoiceId = await askWithDefault(
      "Enter your preferred voice ID",
      "s3TPKV1kjDlVtZbl4Ksh"
    );
  }

  // Detect shell profile
  const shell = process.env.SHELL || "/bin/zsh";
  const shellProfile = shell.includes("zsh") ? "~/.zshrc" : "~/.bashrc";

  return {
    paiDir,
    daName,
    timeZone,
    elevenLabsApiKey,
    elevenLabsVoiceId,
    shellProfile,
  };
}

async function gatherPersonalization(): Promise<PersonalizationConfig> {
  printHeader("PHASE 2: IDENTITY & PERSONALIZATION");

  // Section 1: DA Personality
  printSection("Section 1: DA Personality");

  const personalityMode = await askChoice<"generate" | "custom">(
    "How would you like to configure your AI's personality?",
    ["generate", "custom"],
    "generate"
  );

  let personalityDescription: string | undefined;
  let personalityTraits: PersonalityTraits | undefined;

  if (personalityMode === "generate") {
    console.log("\nDescribe your ideal AI assistant personality.");
    console.log("Example: 'Helpful and precise, with dry wit. Direct but friendly.'");
    personalityDescription = await ask("\nYour description: ");

    // Generate traits from description (simple heuristics, AI would do better)
    personalityTraits = generatePersonalityFromDescription(personalityDescription);
    console.log("\nGenerated personality calibration:");
    Object.entries(personalityTraits).forEach(([trait, value]) => {
      console.log(`  ${trait}: ${value}/100`);
    });
  } else {
    console.log("\nRate each trait from 0-100:");
    personalityTraits = {
      humor: await askNumber("Humor (0=serious, 100=witty)", 0, 100, 50),
      curiosity: await askNumber("Curiosity (0=focused, 100=exploratory)", 0, 100, 70),
      precision: await askNumber("Precision (0=approximate, 100=exact)", 0, 100, 80),
      formality: await askNumber("Formality (0=casual, 100=professional)", 0, 100, 60),
      playfulness: await askNumber("Playfulness (0=businesslike, 100=playful)", 0, 100, 50),
      directness: await askNumber("Directness (0=diplomatic, 100=blunt)", 0, 100, 70),
    };
  }

  // Section 2: About You
  printSection("Section 2: About You");

  const userName = await ask("What is your name? ");
  const userProfession = await ask("What is your profession or primary role? ");
  const primaryPurpose = await ask("What is the primary purpose you'll use this system for? ");

  console.log("\nWhat would you like to be able to do with this system? (enter goals, 'done' when finished)");
  const systemGoals: string[] = [];
  while (true) {
    const goal = await ask(`Goal ${systemGoals.length + 1} (or 'done'): `);
    if (goal.toLowerCase() === "done" || !goal) break;
    systemGoals.push(goal);
  }

  const fiveYearVision = await ask("Where do you see yourself in 5 years? ");

  const employmentContext = await askChoice<PersonalizationConfig["employmentContext"]>(
    "What's your work situation?",
    ["self-employed", "employed", "building-company", "other"],
    "employed"
  );

  // Section 3: Key Contacts
  printSection("Section 3: Key Contacts");

  const contacts: Contact[] = [];
  const wantsContacts = await askYesNo("Would you like to add key contacts now?", true);

  if (wantsContacts) {
    while (true) {
      const name = await ask("\nContact name (or 'done'): ");
      if (name.toLowerCase() === "done" || !name) break;

      const email = await ask("Email: ");
      const role = await ask("Role/Relationship: ");
      const pronunciation = await ask("Pronunciation (if unusual, or press Enter to skip): ");

      contacts.push({
        name,
        email,
        role,
        pronunciation: pronunciation || undefined,
      });
      console.log(`✓ Added ${name}`);
    }
  }

  // Section 4: Technical Preferences
  printSection("Section 4: Technical Preferences");

  const technicalLevel = await askChoice<PersonalizationConfig["technicalLevel"]>(
    "How technical are you?",
    ["beginner", "intermediate", "advanced", "expert"],
    "intermediate"
  );

  const isProgrammer = await askChoice<PersonalizationConfig["isProgrammer"]>(
    "Are you a programmer?",
    ["yes", "no", "learning"],
    "yes"
  );

  const primaryOS = await askChoice<PersonalizationConfig["primaryOS"]>(
    "What OS do you primarily use?",
    ["macos", "windows", "linux"],
    "macos"
  );

  const preferredLanguages = await askMultiSelect(
    "What programming languages do you prefer?",
    ["TypeScript", "Python", "Go", "Rust", "Java", "C#", "Ruby", "PHP", "Swift", "Kotlin"]
  );

  const packageManager = await askChoice<PersonalizationConfig["packageManager"]>(
    "Preferred package manager for JS/TS?",
    ["bun", "npm", "yarn", "pnpm"],
    "bun"
  );

  const serverRuntime = await askChoice<PersonalizationConfig["serverRuntime"]>(
    "Preferred server runtime?",
    ["bun", "node", "deno"],
    "bun"
  );

  const usesCloudflare = await askYesNo("Do you use Cloudflare?", true);

  const backendPreference = await askWithDefault(
    "Preferred backend infrastructure?",
    usesCloudflare ? "Cloudflare Workers" : "AWS"
  );

  const databasePreference = await askWithDefault(
    "Database preference?",
    "PostgreSQL"
  );

  return {
    userName,
    userProfession,
    primaryPurpose,
    systemGoals,
    fiveYearVision,
    employmentContext,
    personalityMode,
    personalityDescription,
    personalityTraits,
    contacts,
    technicalLevel,
    isProgrammer,
    primaryOS,
    preferredLanguages,
    packageManager,
    serverRuntime,
    usesCloudflare,
    backendPreference,
    databasePreference,
  };
}

function generatePersonalityFromDescription(description: string): PersonalityTraits {
  const lower = description.toLowerCase();

  // Simple keyword-based heuristics
  const traits: PersonalityTraits = {
    humor: 50,
    curiosity: 70,
    precision: 75,
    formality: 60,
    playfulness: 50,
    directness: 65,
  };

  // Humor
  if (lower.includes("witty") || lower.includes("funny") || lower.includes("humor")) {
    traits.humor = 80;
  } else if (lower.includes("serious") || lower.includes("professional")) {
    traits.humor = 30;
  }

  // Curiosity
  if (lower.includes("curious") || lower.includes("exploratory") || lower.includes("creative")) {
    traits.curiosity = 85;
  } else if (lower.includes("focused") || lower.includes("efficient")) {
    traits.curiosity = 50;
  }

  // Precision
  if (lower.includes("precise") || lower.includes("exact") || lower.includes("detailed")) {
    traits.precision = 95;
  } else if (lower.includes("flexible") || lower.includes("casual")) {
    traits.precision = 60;
  }

  // Formality
  if (lower.includes("formal") || lower.includes("professional")) {
    traits.formality = 85;
  } else if (lower.includes("casual") || lower.includes("friendly") || lower.includes("relaxed")) {
    traits.formality = 40;
  }

  // Playfulness
  if (lower.includes("playful") || lower.includes("fun") || lower.includes("energetic")) {
    traits.playfulness = 80;
  } else if (lower.includes("businesslike") || lower.includes("serious")) {
    traits.playfulness = 30;
  }

  // Directness
  if (lower.includes("direct") || lower.includes("blunt") || lower.includes("honest")) {
    traits.directness = 85;
  } else if (lower.includes("diplomatic") || lower.includes("gentle") || lower.includes("careful")) {
    traits.directness = 45;
  }

  return traits;
}

// =============================================================================
// FILE GENERATION
// =============================================================================

function generateSkillMd(config: WizardConfig): string {
  const traits = config.personalityTraits!;

  const languageList = config.preferredLanguages.length > 0
    ? config.preferredLanguages.map((l, i) => `${i + 1}. ${l}`).join("\n")
    : "1. TypeScript";

  const contactsList = config.contacts.length > 0
    ? config.contacts.map(c => `- **${c.name}** (${c.role}): ${c.email}`).join("\n")
    : "No contacts added yet.";

  const goalsList = config.systemGoals.length > 0
    ? config.systemGoals.map((g, i) => `${i + 1}. ${g}`).join("\n")
    : "Not specified";

  return `---
name: CORE
description: Personal AI Infrastructure core. AUTO-LOADS at session start. USE WHEN any session begins OR user asks about identity, response format, contacts, stack preferences.
---

# CORE - Personal AI Infrastructure

**Auto-loads at session start.** This skill defines your AI's identity, response format, and core operating principles.

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **UpdateIdentity** | "update identity", "change personality" | \`Workflows/UpdateIdentity.md\` |
| **AddContact** | "add contact", "new contact" | \`Workflows/AddContact.md\` |
| **UpdateAssets** | "update assets", "add property" | \`Workflows/UpdateAssets.md\` |

## Examples

**Example 1: Check contact information**
\`\`\`
User: "What's ${config.contacts[0]?.name || 'Alex'}'s email?"
→ Reads Contacts.md
→ Returns contact information
\`\`\`

---

## Identity

**Assistant:**
- Name: ${config.daName}
- Role: ${config.userName}'s AI assistant
- Operating Environment: Personal AI infrastructure built on Claude Code

**User:**
- Name: ${config.userName}
- Profession: ${config.userProfession}
- Work Situation: ${config.employmentContext}

---

## Purpose & Goals

**Primary Purpose:** ${config.primaryPurpose}

**System Goals:**
${goalsList}

**5-Year Vision:**
${config.fiveYearVision}

---

## Personality Calibration

${config.personalityMode === "generate" ? `**Generated from description:** "${config.personalityDescription}"` : "**Custom configuration:**"}

| Trait | Value | Description |
|-------|-------|-------------|
| Humor | ${traits.humor}/100 | ${traits.humor > 60 ? "Witty and playful" : traits.humor > 40 ? "Moderate wit" : "Serious and focused"} |
| Curiosity | ${traits.curiosity}/100 | ${traits.curiosity > 60 ? "Exploratory" : "Task-focused"} |
| Precision | ${traits.precision}/100 | ${traits.precision > 70 ? "Highly exact" : "Flexible"} |
| Formality | ${traits.formality}/100 | ${traits.formality > 60 ? "Professional" : "Casual and friendly"} |
| Playfulness | ${traits.playfulness}/100 | ${traits.playfulness > 60 ? "Playful" : "Businesslike"} |
| Directness | ${traits.directness}/100 | ${traits.directness > 60 ? "Direct and blunt" : "Diplomatic"} |

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

## Technical Stack Preferences

**Technical Level:** ${config.technicalLevel}
**Programmer:** ${config.isProgrammer}

**Platform:**
- OS: ${config.primaryOS}
- Runtime: ${config.serverRuntime}
- Package Manager: ${config.packageManager}

**Languages (in order of preference):**
${languageList}

**Infrastructure:**
- Cloudflare: ${config.usesCloudflare ? "Yes" : "No"}
- Backend: ${config.backendPreference}
- Database: ${config.databasePreference}

---

## Stack Rules

Based on your preferences, always follow these rules:

${generateStackRules(config)}

---

## Contacts (Quick Reference)

${contactsList}

📚 Full contact directory: \`Contacts.md\`

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

Customize this format to match your preferences.

---

## Quick Reference

**Full documentation available in context files:**
- Contacts: \`Contacts.md\`
- Assets: \`AssetManagement.md\`
- Stack preferences: \`CoreStack.md\`
- Security protocols: \`SecurityProtocols.md\`
`;
}

function generateStackRules(config: WizardConfig): string {
  const rules: string[] = [];

  // Language preference
  if (config.preferredLanguages.length > 0) {
    rules.push(`- **Primary Language:** Use ${config.preferredLanguages[0]} for all new code unless explicitly requested otherwise`);
    if (config.preferredLanguages.includes("TypeScript") && config.preferredLanguages.includes("Python")) {
      rules.push(`- **TypeScript > Python:** Prefer TypeScript over Python when both would work`);
    }
  }

  // Package manager
  const wrongManagers = ["npm", "yarn", "pnpm"].filter(m => m !== config.packageManager);
  rules.push(`- **Package Manager:** Use ${config.packageManager} (NEVER ${wrongManagers.join("/")})`);

  // Runtime
  rules.push(`- **Runtime:** Use ${config.serverRuntime} as the default JavaScript runtime`);

  // Infrastructure
  if (config.usesCloudflare) {
    rules.push(`- **Deployment:** Default to Cloudflare Workers for serverless functions`);
  }
  rules.push(`- **Backend:** Prefer ${config.backendPreference} for backend infrastructure`);
  rules.push(`- **Database:** Default to ${config.databasePreference} for data storage`);

  // Markup
  rules.push(`- **Markdown:** Use markdown for all documentation. NEVER use HTML for basic content.`);

  return rules.join("\n");
}

function generateContactsMd(config: WizardConfig): string {
  const contactsTable = config.contacts.length > 0
    ? config.contacts.map(c => {
        const notes = c.pronunciation ? `Pronunciation: ${c.pronunciation}` : "";
        return `| ${c.name} | ${c.role} | ${c.email} | ${notes} |`;
      }).join("\n")
    : "| [Name] | [Role] | [email@example.com] | [Any notes] |";

  return `# Contact Directory

Quick reference for frequently contacted people.

---

## Contacts

| Name | Role | Email | Notes |
|------|------|-------|-------|
${contactsTable}

---

## Adding Contacts

To add a new contact:

1. Use the AddContact workflow: "Add [Name] as a contact"
2. Or manually edit this file following the table format

---

## Usage

When the user asks about someone:
1. Check this directory first
2. Return the relevant contact information
3. If not found, ask the user for details
`;
}

function generateCoreStackMd(config: WizardConfig): string {
  const languageTable = config.preferredLanguages.length > 0
    ? config.preferredLanguages.map((lang, i) => {
        let useCase = "General purpose";
        if (lang === "TypeScript") useCase = "Primary for all new code";
        if (lang === "Python") useCase = "Data science, ML, when required";
        if (lang === "Go") useCase = "Performance-critical services";
        if (lang === "Rust") useCase = "Systems programming, WASM";
        return `| ${i + 1} | ${lang} | ${useCase} |`;
      }).join("\n")
    : "| 1 | TypeScript | Primary for all new code |";

  return `# Core Stack Preferences

Technical preferences for code generation and tooling.

Generated from setup wizard: ${new Date().toISOString().split("T")[0]}

---

## Language Preferences

| Priority | Language | Use Case |
|----------|----------|----------|
${languageTable}

---

## Package Managers

| Language | Manager | Never Use |
|----------|---------|-----------|
| JavaScript/TypeScript | ${config.packageManager} | ${["npm", "yarn", "pnpm"].filter(m => m !== config.packageManager).join(", ")} |
| Python | uv | pip, pip3 |

---

## Runtime

| Purpose | Tool |
|---------|------|
| JavaScript Runtime | ${config.serverRuntime} |
| Serverless | ${config.usesCloudflare ? "Cloudflare Workers" : config.backendPreference} |

---

## Infrastructure

| Component | Preference |
|-----------|------------|
| Backend | ${config.backendPreference} |
| Database | ${config.databasePreference} |
| Cloudflare | ${config.usesCloudflare ? "Yes - use for Workers, Pages, R2, KV" : "No"} |

---

## Markup Preferences

| Format | Use | Never Use |
|--------|-----|-----------|
| Markdown | All content, docs, notes | HTML for basic content |
| YAML | Configuration, frontmatter | JSON for config files |
| JSON | API responses, data | YAML for data |

---

## File Naming

| Type | Convention | Example |
|------|------------|---------|
| Skill directories | TitleCase | \`Research\`, \`Art\` |
| Workflow files | TitleCase.md | \`Create.md\`, \`Update.md\` |
| Tool files | TitleCase.ts | \`Generate.ts\` |
| Config files | lowercase | \`settings.json\` |

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
║           Personal AI Infrastructure Installation Wizard          ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
  `);

  try {
    // Phase 1: System Setup
    const systemConfig = await gatherSystemConfig();

    // Phase 2: Personalization
    const personalizationConfig = await gatherPersonalization();

    // Combine configs
    const config: WizardConfig = {
      ...systemConfig,
      ...personalizationConfig,
    };

    // Phase 3: Generate Files
    printHeader("PHASE 3: GENERATING CONFIGURATION");

    const paiDir = config.paiDir.replace("~", process.env.HOME || "~");

    // Create directory structure
    console.log("Creating directory structure...");
    await $`mkdir -p ${paiDir}/Skills/CORE/Workflows`;
    await $`mkdir -p ${paiDir}/Skills/CORE/Tools`;
    await $`mkdir -p ${paiDir}/History/{Sessions,Learnings,Research,Decisions}`;
    await $`mkdir -p ${paiDir}/hooks/lib`;
    await $`mkdir -p ${paiDir}/Tools`;
    await $`mkdir -p ${paiDir}/voice`;

    // Generate files
    console.log("Generating SKILL.md...");
    const skillMd = generateSkillMd(config);
    await Bun.write(`${paiDir}/Skills/CORE/SKILL.md`, skillMd);

    console.log("Generating Contacts.md...");
    const contactsMd = generateContactsMd(config);
    await Bun.write(`${paiDir}/Skills/CORE/Contacts.md`, contactsMd);

    console.log("Generating CoreStack.md...");
    const coreStackMd = generateCoreStackMd(config);
    await Bun.write(`${paiDir}/Skills/CORE/CoreStack.md`, coreStackMd);

    // Set environment variables
    console.log("\nSetting environment variables...");
    const envExports = `
# PAI Configuration (added by Kai Bundle installer)
export PAI_DIR="${config.paiDir}"
export DA="${config.daName}"
export TIME_ZONE="${config.timeZone}"
export PAI_SOURCE_APP="$DA"
${config.elevenLabsApiKey ? `export ELEVENLABS_API_KEY="${config.elevenLabsApiKey}"` : ""}
${config.elevenLabsVoiceId ? `export ELEVENLABS_VOICE_ID="${config.elevenLabsVoiceId}"` : ""}
`;

    const shellProfile = config.shellProfile.replace("~", process.env.HOME || "~");
    const existingProfile = await Bun.file(shellProfile).text().catch(() => "");
    if (!existingProfile.includes("PAI_DIR")) {
      await Bun.write(shellProfile, existingProfile + "\n" + envExports);
      console.log(`✓ Added environment variables to ${config.shellProfile}`);
    } else {
      console.log(`ℹ PAI environment variables already exist in ${config.shellProfile}`);
    }

    // Summary
    printHeader("INSTALLATION COMPLETE");

    console.log(`
Your Kai system is configured with:

  📁 PAI Directory: ${config.paiDir}
  🤖 Assistant Name: ${config.daName}
  👤 User: ${config.userName} (${config.userProfession})
  🎯 Purpose: ${config.primaryPurpose}
  💻 Stack: ${config.preferredLanguages.join(", ")} + ${config.packageManager}
  👥 Contacts: ${config.contacts.length} added

Next steps:

  1. Reload your shell: source ${config.shellProfile}
  2. Install the packs in order:
     - kai-hook-system
     - kai-history-system
     - kai-skill-system
     - kai-voice-system
     - kai-identity
  3. Restart Claude Code to activate hooks

Files created:
  - ${paiDir}/Skills/CORE/SKILL.md
  - ${paiDir}/Skills/CORE/Contacts.md
  - ${paiDir}/Skills/CORE/CoreStack.md
`);

  } catch (error) {
    console.error("\n❌ Installation failed:", error);
    process.exit(1);
  } finally {
    rl.close();
  }
}

main();
