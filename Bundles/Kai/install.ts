#!/usr/bin/env bun
/**
 * PAI Kai Bundle Interactive Installer
 *
 * A wizard-style installer that guides users through setting up the complete
 * Kai Personal AI Infrastructure bundle with conflict detection and resolution.
 *
 * Usage: bun run install.ts
 *
 * @author Daniel Miessler
 * @license MIT
 */

import { existsSync, readFileSync, writeFileSync, mkdirSync, readdirSync, statSync } from 'fs';
import { join, dirname, resolve } from 'path';
import { homedir } from 'os';
import { $ } from 'bun';

// ============================================================================
// Types and Interfaces
// ============================================================================

interface WizardConfig {
  paiDir: string;
  daName: string;
  timeZone: string;
  elevenLabsApiKey: string;
  elevenLabsVoiceId: string;
  observabilityUrl: string;
  shellProfile: string;
}

interface ConflictResult {
  type: 'none' | 'merge' | 'replace' | 'skip';
  details?: string;
}

interface PackInfo {
  id: string;
  name: string;
  file: string;
  description: string;
  dependencies: string[];
}

interface InstallResult {
  success: boolean;
  message: string;
  details?: string[];
}

// ============================================================================
// Constants
// ============================================================================

const COLORS = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m',
};

const PACKS: PackInfo[] = [
  {
    id: 'kai-hook-system',
    name: 'Hook System',
    file: '../../Packs/kai-hook-system.md',
    description: 'Event-driven automation foundation',
    dependencies: [],
  },
  {
    id: 'kai-history-system',
    name: 'History System',
    file: '../../Packs/kai-history-system.md',
    description: 'Memory and automatic capture',
    dependencies: ['kai-hook-system'],
  },
  {
    id: 'kai-skill-system',
    name: 'Skill System',
    file: '../../Packs/kai-skill-system.md',
    description: 'Capability routing',
    dependencies: ['kai-hook-system', 'kai-history-system'],
  },
  {
    id: 'kai-voice-system',
    name: 'Voice System',
    file: '../../Packs/kai-voice-system.md',
    description: 'Voice notifications via ElevenLabs',
    dependencies: ['kai-hook-system', 'kai-skill-system'],
  },
  {
    id: 'kai-identity',
    name: 'Identity',
    file: '../../Packs/kai-identity.md',
    description: 'Personality layer (CORE skill)',
    dependencies: ['kai-hook-system', 'kai-history-system', 'kai-skill-system', 'kai-voice-system'],
  },
];

const DEFAULT_CONFIG: WizardConfig = {
  paiDir: join(homedir(), '.config', 'pai'),
  daName: 'PAI',
  timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
  elevenLabsApiKey: '',
  elevenLabsVoiceId: 's3TPKV1kjDlVtZbl4Ksh',
  observabilityUrl: 'http://localhost:4000/events',
  shellProfile: '',
};

// ============================================================================
// Utility Functions
// ============================================================================

function c(color: keyof typeof COLORS, text: string): string {
  return `${COLORS[color]}${text}${COLORS.reset}`;
}

function log(message: string): void {
  console.log(message);
}

function logSection(title: string): void {
  log('');
  log(c('cyan', '━'.repeat(60)));
  log(c('bold', `  ${title}`));
  log(c('cyan', '━'.repeat(60)));
  log('');
}

function logSuccess(message: string): void {
  log(`${c('green', '✓')} ${message}`);
}

function logWarning(message: string): void {
  log(`${c('yellow', '⚠')} ${message}`);
}

function logError(message: string): void {
  log(`${c('red', '✗')} ${message}`);
}

function logInfo(message: string): void {
  log(`${c('blue', 'ℹ')} ${message}`);
}

async function prompt(question: string, defaultValue: string = ''): Promise<string> {
  const defaultDisplay = defaultValue ? c('dim', ` [${defaultValue}]`) : '';
  process.stdout.write(`${c('cyan', '?')} ${question}${defaultDisplay}: `);

  const reader = Bun.stdin.stream().getReader();
  const decoder = new TextDecoder();
  let input = '';

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;

    const chunk = decoder.decode(value);
    input += chunk;

    if (input.includes('\n')) {
      reader.releaseLock();
      break;
    }
  }

  const result = input.trim();
  return result || defaultValue;
}

async function promptYesNo(question: string, defaultYes: boolean = true): Promise<boolean> {
  const hint = defaultYes ? 'Y/n' : 'y/N';
  const answer = await prompt(`${question} (${hint})`, defaultYes ? 'yes' : 'no');
  return answer.toLowerCase().startsWith('y');
}

async function promptChoice(question: string, choices: string[], defaultIndex: number = 0): Promise<number> {
  log(`${c('cyan', '?')} ${question}`);
  choices.forEach((choice, i) => {
    const marker = i === defaultIndex ? c('green', '●') : c('dim', '○');
    log(`  ${marker} ${i + 1}. ${choice}`);
  });

  const answer = await prompt('Enter number', String(defaultIndex + 1));
  const parsed = parseInt(answer, 10);

  if (isNaN(parsed) || parsed < 1 || parsed > choices.length) {
    return defaultIndex;
  }

  return parsed - 1;
}

function detectShellProfile(): string {
  const shell = process.env.SHELL || '/bin/zsh';
  const home = homedir();

  if (shell.includes('zsh')) {
    const zshrc = join(home, '.zshrc');
    if (existsSync(zshrc)) return zshrc;
    return join(home, '.zprofile');
  }

  if (shell.includes('bash')) {
    const bashrc = join(home, '.bashrc');
    if (existsSync(bashrc)) return bashrc;
    const profile = join(home, '.bash_profile');
    if (existsSync(profile)) return profile;
    return join(home, '.profile');
  }

  // Fallback
  return join(home, '.profile');
}

function detectExistingInstallation(paiDir: string): {
  exists: boolean;
  directories: string[];
  files: string[];
} {
  if (!existsSync(paiDir)) {
    return { exists: false, directories: [], files: [] };
  }

  const directories: string[] = [];
  const files: string[] = [];

  try {
    const entries = readdirSync(paiDir);
    for (const entry of entries) {
      const fullPath = join(paiDir, entry);
      const stat = statSync(fullPath);
      if (stat.isDirectory()) {
        directories.push(entry);
      } else {
        files.push(entry);
      }
    }
  } catch {
    // Directory exists but unreadable
  }

  return { exists: true, directories, files };
}

function detectClaudeSettings(): {
  exists: boolean;
  hasHooks: boolean;
  hookCount: number;
  path: string;
} {
  const claudeDir = join(homedir(), '.claude');
  const settingsPath = join(claudeDir, 'settings.json');

  if (!existsSync(settingsPath)) {
    return { exists: false, hasHooks: false, hookCount: 0, path: settingsPath };
  }

  try {
    const content = readFileSync(settingsPath, 'utf-8');
    const settings = JSON.parse(content);

    const hooks = settings.hooks || {};
    let hookCount = 0;

    for (const eventType of Object.keys(hooks)) {
      if (Array.isArray(hooks[eventType])) {
        hookCount += hooks[eventType].length;
      }
    }

    return {
      exists: true,
      hasHooks: hookCount > 0,
      hookCount,
      path: settingsPath,
    };
  } catch {
    return { exists: true, hasHooks: false, hookCount: 0, path: settingsPath };
  }
}

function detectEnvironmentVariables(): {
  paiDir?: string;
  daName?: string;
  timeZone?: string;
  elevenLabsKey?: string;
} {
  return {
    paiDir: process.env.PAI_DIR,
    daName: process.env.DA,
    timeZone: process.env.TIME_ZONE,
    elevenLabsKey: process.env.ELEVENLABS_API_KEY,
  };
}

// ============================================================================
// Wizard Steps
// ============================================================================

async function showWelcome(): Promise<void> {
  console.clear();
  log('');
  log(c('cyan', '  ╔═══════════════════════════════════════════════════════════╗'));
  log(c('cyan', '  ║') + c('bold', '        PAI Kai Bundle Installation Wizard             ') + c('cyan', '║'));
  log(c('cyan', '  ╚═══════════════════════════════════════════════════════════╝'));
  log('');
  log('  Welcome! This wizard will guide you through installing the complete');
  log('  Kai Personal AI Infrastructure bundle.');
  log('');
  log('  ' + c('bold', 'What you\'ll get:'));
  log('  • Hook System - Event-driven automation foundation');
  log('  • History System - Automatic memory and capture');
  log('  • Skill System - Modular capability routing');
  log('  • Voice System - Voice notifications (optional)');
  log('  • Identity - Personality layer and CORE skill');
  log('');
  log('  ' + c('dim', 'Press Enter to continue or Ctrl+C to exit...'));
  await prompt('');
}

async function gatherConfiguration(): Promise<WizardConfig> {
  logSection('Configuration');

  const config = { ...DEFAULT_CONFIG };
  const existingEnv = detectEnvironmentVariables();

  // PAI Directory
  log(c('bold', 'PAI Directory'));
  log(c('dim', 'Where should PAI store its files (hooks, history, skills)?'));
  if (existingEnv.paiDir) {
    logInfo(`Detected existing PAI_DIR: ${existingEnv.paiDir}`);
  }
  config.paiDir = await prompt('PAI directory', existingEnv.paiDir || DEFAULT_CONFIG.paiDir);
  log('');

  // AI Assistant Name
  log(c('bold', 'AI Assistant Name'));
  log(c('dim', 'What should your AI be called? (e.g., Kai, Atlas, Nova, Jarvis)'));
  if (existingEnv.daName) {
    logInfo(`Detected existing DA name: ${existingEnv.daName}`);
  }
  config.daName = await prompt('Assistant name', existingEnv.daName || DEFAULT_CONFIG.daName);
  log('');

  // Timezone
  log(c('bold', 'Timezone'));
  log(c('dim', 'Your timezone for accurate timestamps'));
  const detectedTz = Intl.DateTimeFormat().resolvedOptions().timeZone;
  config.timeZone = await prompt('Timezone', existingEnv.timeZone || detectedTz);
  log('');

  // Shell Profile
  log(c('bold', 'Shell Profile'));
  log(c('dim', 'Which shell profile should we add environment variables to?'));
  const detectedProfile = detectShellProfile();
  config.shellProfile = await prompt('Shell profile', detectedProfile);
  log('');

  // Voice System (Optional)
  log(c('bold', 'Voice System (Optional)'));
  log(c('dim', 'The voice system uses ElevenLabs for text-to-speech notifications.'));
  log(c('dim', 'You can skip this and add it later.'));

  const setupVoice = await promptYesNo('Configure voice system now?', false);

  if (setupVoice) {
    config.elevenLabsApiKey = await prompt('ElevenLabs API key', existingEnv.elevenLabsKey || '');
    if (config.elevenLabsApiKey) {
      config.elevenLabsVoiceId = await prompt('Voice ID', DEFAULT_CONFIG.elevenLabsVoiceId);
    }
  }
  log('');

  return config;
}

async function checkForConflicts(config: WizardConfig): Promise<{
  hasConflicts: boolean;
  paiDirConflict: boolean;
  settingsConflict: boolean;
  envConflict: boolean;
  details: string[];
}> {
  logSection('Checking for Conflicts');

  const details: string[] = [];
  let hasConflicts = false;

  // Check PAI directory
  const paiStatus = detectExistingInstallation(config.paiDir);
  const paiDirConflict = paiStatus.exists && (paiStatus.directories.length > 0 || paiStatus.files.length > 0);

  if (paiDirConflict) {
    hasConflicts = true;
    logWarning(`Existing PAI installation found at ${config.paiDir}`);
    details.push(`PAI directory has ${paiStatus.directories.length} directories and ${paiStatus.files.length} files`);
    paiStatus.directories.forEach(d => details.push(`  - ${d}/`));
  } else if (paiStatus.exists) {
    logSuccess('PAI directory exists but is empty');
  } else {
    logSuccess('PAI directory does not exist (will be created)');
  }

  // Check Claude settings
  const claudeStatus = detectClaudeSettings();
  const settingsConflict = claudeStatus.hasHooks;

  if (settingsConflict) {
    hasConflicts = true;
    logWarning(`Existing hooks found in Claude settings (${claudeStatus.hookCount} hooks)`);
    details.push(`Claude settings has ${claudeStatus.hookCount} existing hooks`);
  } else if (claudeStatus.exists) {
    logSuccess('Claude settings exists but has no hooks');
  } else {
    logSuccess('Claude settings does not exist (will be created)');
  }

  // Check environment variables
  const envVars = detectEnvironmentVariables();
  const envConflict = !!(envVars.paiDir || envVars.daName);

  if (envConflict) {
    logInfo('Existing environment variables detected (will update)');
    if (envVars.paiDir) details.push(`PAI_DIR=${envVars.paiDir}`);
    if (envVars.daName) details.push(`DA=${envVars.daName}`);
  } else {
    logSuccess('No existing PAI environment variables');
  }

  return { hasConflicts, paiDirConflict, settingsConflict, envConflict, details };
}

async function resolveConflicts(
  config: WizardConfig,
  conflicts: Awaited<ReturnType<typeof checkForConflicts>>
): Promise<{
  proceed: boolean;
  mergeSettings: boolean;
  backupExisting: boolean;
}> {
  if (!conflicts.hasConflicts) {
    return { proceed: true, mergeSettings: false, backupExisting: false };
  }

  logSection('Conflict Resolution');

  log('The installer found existing configurations that may conflict.');
  log('');
  conflicts.details.forEach(d => log(`  ${c('dim', '•')} ${d}`));
  log('');

  const choiceIndex = await promptChoice('How would you like to proceed?', [
    'Merge - Add PAI hooks alongside existing hooks (recommended)',
    'Replace - Remove existing configuration and start fresh',
    'Cancel - Exit without making changes',
  ], 0);

  if (choiceIndex === 2) {
    return { proceed: false, mergeSettings: false, backupExisting: false };
  }

  const mergeSettings = choiceIndex === 0;

  let backupExisting = false;
  if (conflicts.paiDirConflict || conflicts.settingsConflict) {
    log('');
    backupExisting = await promptYesNo('Create backup of existing files before proceeding?', true);
  }

  return { proceed: true, mergeSettings, backupExisting };
}

async function createBackup(config: WizardConfig): Promise<void> {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
  const backupDir = join(homedir(), '.pai-backup', timestamp);

  logInfo(`Creating backup at ${backupDir}`);
  mkdirSync(backupDir, { recursive: true });

  // Backup PAI directory if exists
  if (existsSync(config.paiDir)) {
    await $`cp -r ${config.paiDir} ${join(backupDir, 'pai')}`.quiet();
    logSuccess('Backed up PAI directory');
  }

  // Backup Claude settings if exists
  const claudeSettings = join(homedir(), '.claude', 'settings.json');
  if (existsSync(claudeSettings)) {
    mkdirSync(join(backupDir, 'claude'), { recursive: true });
    await $`cp ${claudeSettings} ${join(backupDir, 'claude', 'settings.json')}`.quiet();
    logSuccess('Backed up Claude settings');
  }
}

async function createDirectoryStructure(config: WizardConfig): Promise<void> {
  logSection('Creating Directory Structure');

  const directories = [
    config.paiDir,
    join(config.paiDir, 'hooks'),
    join(config.paiDir, 'hooks', 'lib'),
    join(config.paiDir, 'History'),
    join(config.paiDir, 'History', 'Sessions'),
    join(config.paiDir, 'History', 'Learnings'),
    join(config.paiDir, 'History', 'Research'),
    join(config.paiDir, 'History', 'Decisions'),
    join(config.paiDir, 'Skills'),
    join(config.paiDir, 'Skills', 'CORE'),
    join(config.paiDir, 'Tools'),
    join(config.paiDir, 'voice'),
  ];

  for (const dir of directories) {
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
      logSuccess(`Created ${dir.replace(homedir(), '~')}`);
    } else {
      logInfo(`Exists: ${dir.replace(homedir(), '~')}`);
    }
  }
}

async function writeEnvironmentVariables(config: WizardConfig): Promise<void> {
  logSection('Configuring Environment');

  const envBlock = `
# PAI Configuration (added by Kai Bundle installer)
export PAI_DIR="${config.paiDir}"
export DA="${config.daName}"
export TIME_ZONE="${config.timeZone}"
export PAI_SOURCE_APP="${config.daName}"
${config.elevenLabsApiKey ? `export ELEVENLABS_API_KEY="${config.elevenLabsApiKey}"` : '# export ELEVENLABS_API_KEY="your-key-here"'}
${config.elevenLabsVoiceId ? `export ELEVENLABS_VOICE_ID="${config.elevenLabsVoiceId}"` : ''}
export PAI_OBSERVABILITY_URL="${config.observabilityUrl}"
# End PAI Configuration
`;

  if (!existsSync(config.shellProfile)) {
    writeFileSync(config.shellProfile, envBlock);
    logSuccess(`Created ${config.shellProfile}`);
  } else {
    const existing = readFileSync(config.shellProfile, 'utf-8');

    // Check if PAI config already exists
    if (existing.includes('# PAI Configuration')) {
      // Replace existing block
      const updated = existing.replace(
        /# PAI Configuration.*# End PAI Configuration\n?/s,
        envBlock
      );
      writeFileSync(config.shellProfile, updated);
      logSuccess(`Updated PAI configuration in ${config.shellProfile}`);
    } else {
      // Append new block
      writeFileSync(config.shellProfile, existing + '\n' + envBlock);
      logSuccess(`Added PAI configuration to ${config.shellProfile}`);
    }
  }

  // Also write to ~/.env for tools that read from there
  const envFile = join(homedir(), '.env');
  const envContent = `# PAI Environment Variables
PAI_DIR=${config.paiDir}
DA=${config.daName}
TIME_ZONE=${config.timeZone}
${config.elevenLabsApiKey ? `ELEVENLABS_API_KEY=${config.elevenLabsApiKey}` : ''}
${config.elevenLabsVoiceId ? `ELEVENLABS_VOICE_ID=${config.elevenLabsVoiceId}` : ''}
`;

  if (existsSync(envFile)) {
    const existing = readFileSync(envFile, 'utf-8');
    if (!existing.includes('PAI_DIR=')) {
      writeFileSync(envFile, existing + '\n' + envContent);
      logSuccess('Added PAI variables to ~/.env');
    }
  } else {
    writeFileSync(envFile, envContent);
    logSuccess('Created ~/.env with PAI variables');
  }
}

function generatePackInstallPrompt(pack: PackInfo, config: WizardConfig): string {
  return `You are receiving Pack ${pack.id} from the PAI Kai Bundle.

INSTALLATION CONTEXT:
- PAI_DIR: ${config.paiDir}
- DA (AI Name): ${config.daName}
- TIME_ZONE: ${config.timeZone}

IMPORTANT: Replace all instances of $PAI_DIR with "${config.paiDir}" in the code files.
Replace all instances of "PAI" with "${config.daName}" where it refers to the assistant name.

Please read the Pack file and install it by:
1. Creating all required files in their correct locations
2. The files should use the configured PAI_DIR path: ${config.paiDir}
3. Update settings.json with the required hooks (merge with existing if present)
4. Run the verification steps to confirm installation

Pack file location: ${resolve(dirname(import.meta.path), pack.file)}`;
}

async function showPackInstallInstructions(config: WizardConfig): Promise<void> {
  logSection('Pack Installation');

  log('The directory structure and environment are configured.');
  log('');
  log('Now you need to install each Pack. Give these prompts to your AI in order:');
  log('');

  for (let i = 0; i < PACKS.length; i++) {
    const pack = PACKS[i];
    log(c('bold', `${i + 1}. ${pack.name}`));
    log(c('dim', `   ${pack.description}`));
    log('');
    log(c('cyan', '   Prompt to give your AI:'));
    log('');
    log(c('dim', '   ─────────────────────────────────────────────────────'));
    log(`   Install the ${pack.name} pack from:`);
    log(`   ${resolve(dirname(import.meta.path), pack.file)}`);
    log('');
    log(`   Use PAI_DIR="${config.paiDir}" and DA="${config.daName}"`);
    log(c('dim', '   ─────────────────────────────────────────────────────'));
    log('');

    if (i < PACKS.length - 1) {
      log(c('yellow', '   ⚠ Verify this pack works before installing the next one!'));
      log('');
    }
  }
}

async function showCompletion(config: WizardConfig): Promise<void> {
  logSection('Setup Complete!');

  log(c('green', '✓ Directory structure created'));
  log(c('green', '✓ Environment variables configured'));
  log('');
  log(c('bold', 'Next Steps:'));
  log('');
  log(`1. ${c('cyan', 'Restart your terminal')} to load the new environment variables`);
  log('   Or run: source ${config.shellProfile}');
  log('');
  log(`2. ${c('cyan', 'Install each Pack')} by giving your AI the Pack files in order:`);

  for (let i = 0; i < PACKS.length; i++) {
    const pack = PACKS[i];
    log(`   ${i + 1}. ${pack.name} - ${resolve(dirname(import.meta.path), pack.file)}`);
  }

  log('');
  log(`3. ${c('cyan', 'Restart Claude Code')} after installing all packs to activate hooks`);
  log('');
  log(c('dim', '─'.repeat(60)));
  log('');
  log(`Your AI assistant ${c('bold', config.daName)} is being set up at:`);
  log(`  ${c('cyan', config.paiDir)}`);
  log('');
  log(c('dim', 'For help, see: https://github.com/danielmiessler/PAI'));
  log('');
}

// ============================================================================
// Main Entry Point
// ============================================================================

async function main(): Promise<void> {
  try {
    // Welcome
    await showWelcome();

    // Gather configuration
    const config = await gatherConfiguration();

    // Check for conflicts
    const conflicts = await checkForConflicts(config);

    // Resolve conflicts if any
    const resolution = await resolveConflicts(config, conflicts);

    if (!resolution.proceed) {
      log('');
      log(c('yellow', 'Installation cancelled. No changes were made.'));
      process.exit(0);
    }

    // Create backup if requested
    if (resolution.backupExisting) {
      await createBackup(config);
    }

    // Create directory structure
    await createDirectoryStructure(config);

    // Write environment variables
    await writeEnvironmentVariables(config);

    // Show pack installation instructions
    await showPackInstallInstructions(config);

    // Show completion
    await showCompletion(config);

  } catch (error) {
    if (error instanceof Error && error.message.includes('EOF')) {
      log('');
      log(c('yellow', 'Installation cancelled.'));
      process.exit(0);
    }
    throw error;
  }
}

// Run
main().catch(console.error);
