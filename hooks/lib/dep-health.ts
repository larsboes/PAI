/**
 * dep-health.ts — Dependency health tracking with circuit breaker pattern
 *
 * Tracks 3 external dependencies: haiku-api, voice-server, kitty-terminal.
 * Hooks call isDependencyUp() before making external calls. Failed deps
 * are cached as "down" and fast-failed until recovery window.
 *
 * State machine: UP → DOWN (threshold failures) → PROBING (after reset) → UP/DOWN
 * State: in-memory Map (fast reads), JSON checkpoint on transitions.
 * Telemetry: hook-health.jsonl on trip/probe/recover events only.
 */

import { readFileSync, writeFileSync, appendFileSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';

const BASE_DIR = process.env.PAI_DIR || join(process.env.HOME!, '.claude');
const STATE_DIR = join(BASE_DIR, 'MEMORY', 'STATE');
const STATE_FILE = join(STATE_DIR, 'dep-health.json');
const TELEMETRY_FILE = join(STATE_DIR, 'hook-health.jsonl');

export type DependencyName = 'haiku-api' | 'voice-server' | 'kitty-terminal';
export type DepStatus = 'up' | 'down' | 'probing';

export interface DepState {
  status: DepStatus;
  consecutive_failures: number;
  last_checked: string;
  last_failure_reason?: string;
  down_since?: string;
  last_transition?: string;
}

interface DepConfig {
  failureThreshold: number;
  resetTimeout: number; // ms
}

const CONFIG: Record<DependencyName, DepConfig> = {
  'haiku-api':      { failureThreshold: 3, resetTimeout: 300_000 },  // 5 min
  'voice-server':   { failureThreshold: 1, resetTimeout: 300_000 },  // 1 fail = trip
  'kitty-terminal': { failureThreshold: 1, resetTimeout: 600_000 },  // 10 min
};

const ALL_DEPS: DependencyName[] = ['haiku-api', 'voice-server', 'kitty-terminal'];

// In-memory state — lazy-loaded from disk only once per process.
// Each hook is a separate process, so stateMap starts null.
// Optimization: isDependencyUp() skips file read when no state file exists (dep is assumed up).
let stateMap: Map<DependencyName, DepState> | null = null;
let stateLoaded = false;

function defaultState(): DepState {
  return {
    status: 'up',
    consecutive_failures: 0,
    last_checked: new Date().toISOString(),
  };
}

function loadState(): Map<DependencyName, DepState> {
  if (stateMap) return stateMap;

  stateMap = new Map();
  if (!stateLoaded) {
    stateLoaded = true;
    try {
      if (existsSync(STATE_FILE)) {
        const data = JSON.parse(readFileSync(STATE_FILE, 'utf-8'));
        for (const dep of ALL_DEPS) {
          stateMap.set(dep, data[dep] || defaultState());
        }
        return stateMap;
      }
    } catch { /* fall through to defaults */ }
  }

  for (const dep of ALL_DEPS) {
    stateMap.set(dep, defaultState());
  }
  return stateMap;
}

/**
 * Fast path: check if state file exists at all. If not, all deps are up.
 * Avoids JSON parse on the happy path (deps up, no state file).
 */
function hasStateFile(): boolean {
  return existsSync(STATE_FILE);
}

function persistState(): void {
  const map = loadState();
  const obj: Record<string, DepState> = {};
  for (const [k, v] of map) obj[k] = v;
  if (!existsSync(STATE_DIR)) mkdirSync(STATE_DIR, { recursive: true });
  writeFileSync(STATE_FILE, JSON.stringify(obj, null, 2));
}

function logTelemetry(dep: DependencyName, event: string, extra?: Record<string, unknown>): void {
  const entry = {
    ts: new Date().toISOString(),
    dep,
    event,
    ...extra,
  };
  try {
    if (!existsSync(STATE_DIR)) mkdirSync(STATE_DIR, { recursive: true });
    appendFileSync(TELEMETRY_FILE, JSON.stringify(entry) + '\n');
  } catch { /* telemetry is best-effort */ }
}

/**
 * Fast check — returns true if dependency is available.
 * When status is "down", checks if reset timeout has elapsed → moves to "probing".
 */
export function isDependencyUp(name: DependencyName): boolean {
  // Fast path: no state file means no deps have ever tripped → all up
  if (!stateMap && !hasStateFile()) return true;

  const map = loadState();
  const state = map.get(name) || defaultState();
  const config = CONFIG[name];

  if (state.status === 'up') return true;

  if (state.status === 'down' && state.down_since) {
    const elapsed = Date.now() - new Date(state.down_since).getTime();
    if (elapsed >= config.resetTimeout) {
      state.status = 'probing';
      state.last_transition = new Date().toISOString();
      map.set(name, state);
      logTelemetry(name, 'probe');
      persistState();
      return true; // Allow one test call
    }
  }

  if (state.status === 'probing') {
    // Already probing — another hook asking. Allow it through.
    return true;
  }

  return false;
}

/**
 * Record a successful call — resets failure count, marks UP.
 */
export function recordSuccess(name: DependencyName): void {
  const map = loadState();
  const state = map.get(name) || defaultState();

  const wasDown = state.status !== 'up';
  if (wasDown && state.down_since) {
    const downtime = Math.round((Date.now() - new Date(state.down_since).getTime()) / 1000);
    logTelemetry(name, 'recover', { downtime_s: downtime });
  }

  state.status = 'up';
  state.consecutive_failures = 0;
  state.last_failure_reason = undefined;
  state.down_since = undefined;
  state.last_checked = new Date().toISOString();
  if (wasDown) state.last_transition = new Date().toISOString();
  map.set(name, state);

  if (wasDown) persistState();
}

/**
 * Record a failed call — increments counter, trips breaker at threshold.
 */
export function recordFailure(name: DependencyName, reason: string): void {
  const map = loadState();
  const state = map.get(name) || defaultState();
  const config = CONFIG[name];

  state.consecutive_failures++;
  state.last_failure_reason = reason.substring(0, 200);
  state.last_checked = new Date().toISOString();

  if (state.status === 'probing') {
    // Probe failed — back to down, reset timer
    state.status = 'down';
    state.down_since = new Date().toISOString();
    state.last_transition = new Date().toISOString();
    logTelemetry(name, 'probe_fail', { reason: state.last_failure_reason });
    persistState();
  } else if (state.consecutive_failures >= config.failureThreshold && state.status === 'up') {
    state.status = 'down';
    state.down_since = new Date().toISOString();
    state.last_transition = new Date().toISOString();
    logTelemetry(name, 'trip', {
      failures: state.consecutive_failures,
      reason: state.last_failure_reason,
    });
    persistState();
  }

  map.set(name, state);
}

/**
 * Get all dependency states for diagnostics.
 */
export function getAllStates(): Record<DependencyName, DepState> {
  const map = loadState();
  const result = {} as Record<DependencyName, DepState>;
  for (const dep of ALL_DEPS) {
    result[dep] = map.get(dep) || defaultState();
  }
  return result;
}
