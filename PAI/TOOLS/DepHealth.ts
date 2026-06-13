#!/usr/bin/env bun
/**
 * DepHealth.ts — CLI to show current dependency health states
 *
 * Usage: bun run ~/.claude/PAI/TOOLS/DepHealth.ts
 */

import { getAllStates } from '../../hooks/lib/dep-health';
import { existsSync, readFileSync } from 'fs';
import { join } from 'path';

const BASE_DIR = process.env.PAI_DIR || join(process.env.HOME!, '.claude');
const TELEMETRY_FILE = join(BASE_DIR, 'MEMORY', 'STATE', 'hook-health.jsonl');

const states = getAllStates();

console.log('\n  Dependency Health Status\n  ========================\n');

for (const [name, state] of Object.entries(states)) {
  const icon = state.status === 'up' ? '🟢' : state.status === 'probing' ? '🟡' : '🔴';
  const status = state.status.toUpperCase().padEnd(7);
  console.log(`  ${icon} ${name.padEnd(18)} ${status}  failures: ${state.consecutive_failures}`);
  if (state.down_since) {
    const downtime = Math.round((Date.now() - new Date(state.down_since).getTime()) / 1000);
    console.log(`     ↳ down for ${downtime}s (since ${state.down_since})`);
  }
  if (state.last_failure_reason) {
    console.log(`     ↳ reason: ${state.last_failure_reason}`);
  }
}

// Show recent telemetry
if (existsSync(TELEMETRY_FILE)) {
  const lines = readFileSync(TELEMETRY_FILE, 'utf-8').trim().split('\n');
  const recent = lines.slice(-5);
  if (recent.length > 0 && recent[0]) {
    console.log('\n  Recent Events (last 5)\n  ----------------------');
    for (const line of recent) {
      try {
        const e = JSON.parse(line);
        console.log(`  ${e.ts?.substring(0, 19)} | ${e.dep?.padEnd(16)} | ${e.event}`);
      } catch { /* skip */ }
    }
  }
}

console.log('');
