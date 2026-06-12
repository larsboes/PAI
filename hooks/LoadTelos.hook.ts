#!/usr/bin/env bun
/**
 * LoadTelos.hook.ts — Inject the principal's private TELOS into context (SessionStart)
 *
 * WHY THIS EXISTS (vs CLAUDE.md @imports):
 * Claude Code's CLAUDE.md `@import` syntax does NOT expand environment variables,
 * so `@${VAULT_PATH}/Atlas/TELOS/IDENTITY.md` silently fails to load. This hook
 * reads `process.env.VAULT_PATH` (which works) and injects the TELOS files at
 * runtime. Benefits:
 *   - No personal/machine-specific paths baked into CLAUDE.md.
 *   - The LOADER is public + repo-tracked; the CONTENT stays private in the vault.
 *   - Portable: any harness with a SessionStart hook can run an equivalent loader.
 *
 * TRIGGER: SessionStart
 *
 * INPUT:
 * - Environment: VAULT_PATH (e.g. ~/Developer/knowledge-base)
 * - Files: $VAULT_PATH/Atlas/TELOS/*.md, $VAULT_PATH/Atlas/Personal/PERSONAL_CONTEXT.md
 *
 * OUTPUT:
 * - stdout: <system-reminder> containing TELOS identity + goals/challenges
 * - stderr: status / diagnostics
 * - exit(0): always (non-fatal — never blocks session startup)
 *
 * TOGGLE: settings.json `dynamicContext.telosContext: false` disables injection.
 * SUBAGENTS: skipped (they inherit task context, not principal identity).
 */

import { readFileSync, existsSync } from 'fs';
import { join } from 'path';
import { getSettingsPath } from './lib/paths';

interface DynamicContextConfig {
  telosContext?: boolean;
  [key: string]: unknown;
}

interface Settings {
  dynamicContext?: DynamicContextConfig;
  [key: string]: unknown;
}

/** Section toggle — defaults to enabled (only an explicit `false` disables). */
function isTelosEnabled(settings: Settings): boolean {
  if (!settings.dynamicContext) return true;
  return settings.dynamicContext.telosContext !== false;
}

function loadSettings(): Settings {
  const settingsPath = getSettingsPath();
  if (existsSync(settingsPath)) {
    try {
      return JSON.parse(readFileSync(settingsPath, 'utf-8'));
    } catch (err) {
      console.error(`⚠️ Failed to parse settings.json: ${err}`);
    }
  }
  return {};
}

// TELOS files to inject, in reading order. Relative to $VAULT_PATH.
// Identity first (who you are), then the planning frame (what you serve).
// Routing-only files (WISDOM/PREDICTIONS/PROJECTS/BOOKS) stay on-demand via CLAUDE.md.
const TELOS_FILES: Array<{ rel: string; label: string }> = [
  { rel: 'Atlas/TELOS/IDENTITY.md',          label: 'Identity' },
  { rel: 'Atlas/TELOS/SOUL.md',              label: 'Soul / Operating Protocol' },
  { rel: 'Atlas/Personal/PERSONAL_CONTEXT.md', label: 'Personal Context' },
  { rel: 'Atlas/TELOS/TELOS.md',             label: 'TELOS Index' },
  { rel: 'Atlas/TELOS/MISSION.md',           label: 'Mission' },
  { rel: 'Atlas/TELOS/GOALS.md',             label: 'Goals' },
  { rel: 'Atlas/TELOS/BELIEFS.md',           label: 'Beliefs' },
  { rel: 'Atlas/TELOS/CHALLENGES.md',        label: 'Challenges' },
  { rel: 'Atlas/TELOS/STRATEGIES.md',        label: 'Strategies' },
  { rel: 'Atlas/TELOS/STATUS.md',            label: 'Status' },
];

// Per-file safety cap so an unexpectedly huge vault file can't flood context.
const MAX_CHARS_PER_FILE = 8000;

/**
 * Read the TELOS files that exist and assemble a single markdown block.
 * Returns null if the vault or all files are missing.
 */
function loadTelosContext(vaultPath: string): string | null {
  const sections: string[] = [];
  const loaded: string[] = [];
  const missing: string[] = [];

  for (const { rel, label } of TELOS_FILES) {
    const full = join(vaultPath, rel);
    if (!existsSync(full)) { missing.push(label); continue; }
    try {
      let content = readFileSync(full, 'utf-8').trim();
      if (!content) { missing.push(label); continue; }
      if (content.length > MAX_CHARS_PER_FILE) {
        content = content.slice(0, MAX_CHARS_PER_FILE) + '\n…(truncated)';
      }
      sections.push(`### ${label}\n\n${content}`);
      loaded.push(label);
    } catch (err) {
      console.error(`⚠️ Failed to read ${rel}: ${err}`);
      missing.push(label);
    }
  }

  if (sections.length === 0) return null;

  console.error(`🧭 TELOS loaded: ${loaded.join(', ')}${missing.length ? ` | missing: ${missing.join(', ')}` : ''}`);

  return `
## TELOS — Who You Serve (auto-loaded from the private vault)

This is the principal's identity, mission, goals, beliefs, and current challenges.
Let it shape your judgment: align work to these goals, respect these beliefs, and
account for these challenges. Source of truth is the private Obsidian vault — never
copy this content into the repo. Deeper files (Wisdom, Predictions, Projects, Books)
are available on demand via the CLAUDE.md routing table.

${sections.join('\n\n')}
`;
}

function main(): void {
  try {
    // Subagents inherit task context, not principal identity — skip.
    const claudeProjectDir = process.env.CLAUDE_PROJECT_DIR || '';
    const isSubagent = claudeProjectDir.includes('/.claude/Agents/') ||
                      process.env.CLAUDE_AGENT_TYPE !== undefined;
    if (isSubagent) {
      console.error('🤖 Subagent session — skipping TELOS loading');
      process.exit(0);
    }

    const settings = loadSettings();
    if (!isTelosEnabled(settings)) {
      console.error('⏭️ Skipped TELOS context (disabled via dynamicContext.telosContext)');
      process.exit(0);
    }

    const vaultPath = process.env.VAULT_PATH;
    if (!vaultPath) {
      console.error('⏭️ VAULT_PATH unset — TELOS not loaded (set VAULT_PATH to your vault root)');
      process.exit(0);
    }
    if (!existsSync(vaultPath)) {
      console.error(`⏭️ VAULT_PATH does not exist: ${vaultPath} — TELOS not loaded`);
      process.exit(0);
    }

    const telos = loadTelosContext(vaultPath);
    if (telos) {
      console.log(`<system-reminder>\nPAI TELOS Context (Auto-loaded at Session Start)\n${telos}\n</system-reminder>`);
    } else {
      console.error(`⏭️ No TELOS files found under ${vaultPath}/Atlas — nothing injected`);
    }
    process.exit(0);
  } catch (error) {
    console.error('❌ Error in LoadTelos hook:', error);
    process.exit(0); // Non-fatal — never block session startup
  }
}

main();
