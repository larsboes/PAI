#!/usr/bin/env bun
/**
 * PaiAnalytics.ts — Generate static HTML analytics report from PAI data
 *
 * Reads all PAI data sources (reflections, ratings, PRDs, hook health,
 * wisdom frames) and generates a single static HTML dashboard.
 *
 * Usage: bun run ~/.claude/PAI/TOOLS/PaiAnalytics.ts
 *        Opens the report in browser automatically.
 */

import { readFileSync, writeFileSync, existsSync, readdirSync, mkdirSync } from 'fs';
import { join } from 'path';
import { execSync } from 'child_process';

const BASE_DIR = process.env.PAI_DIR || join(process.env.HOME!, '.claude');
const STATE_DIR = join(BASE_DIR, 'MEMORY', 'STATE');
const OUTPUT_FILE = join(STATE_DIR, 'analytics-report.html');
const META_FILE = join(STATE_DIR, 'analytics-meta.json');

// ── Data Readers ──

interface Reflection {
  timestamp: string;
  effort_level: string;
  task_description: string;
  criteria_count: number;
  criteria_passed: number;
  implied_sentiment: number;
  within_budget: boolean;
  reflection_q1?: string;
}

interface Rating {
  timestamp: string;
  rating: number;
  source: 'explicit' | 'implicit';
  session_id?: string;
  sentiment_summary?: string;
}

interface SessionInfo {
  slug: string;
  effort: string;
  phase: string;
  progress: string;
  task: string;
  date: string;
}

interface HookEvent {
  ts: string;
  dep: string;
  event: string;
  failures?: number;
  reason?: string;
  downtime_s?: number;
}

interface DepState {
  status: string;
  consecutive_failures: number;
  last_checked: string;
  last_failure_reason?: string;
  down_since?: string;
}

interface WisdomTheme {
  name: string;
  confidence: number;
  domain: string;
}

function readJsonl<T>(path: string): { entries: T[]; parseErrors: number } {
  if (!existsSync(path)) return { entries: [], parseErrors: 0 };
  const content = readFileSync(path, 'utf-8').trim();
  if (!content) return { entries: [], parseErrors: 0 };
  let parseErrors = 0;
  const entries: T[] = [];
  for (const line of content.split('\n')) {
    try { entries.push(JSON.parse(line)); }
    catch { parseErrors++; }
  }
  return { entries, parseErrors };
}

function readReflections(): { entries: Reflection[]; parseErrors: number } {
  return readJsonl<Reflection>(join(BASE_DIR, 'MEMORY', 'LEARNING', 'REFLECTIONS', 'algorithm-reflections.jsonl'));
}

function readRatings(): { entries: Rating[]; parseErrors: number } {
  return readJsonl<Rating>(join(BASE_DIR, 'MEMORY', 'LEARNING', 'SIGNALS', 'ratings.jsonl'));
}

function readHookHealth(): { entries: HookEvent[]; parseErrors: number } {
  return readJsonl<HookEvent>(join(STATE_DIR, 'hook-health.jsonl'));
}

function readDepHealth(): Record<string, DepState> {
  const path = join(STATE_DIR, 'dep-health.json');
  if (!existsSync(path)) return {};
  try { return JSON.parse(readFileSync(path, 'utf-8')); }
  catch { return {}; }
}

function readSessions(): SessionInfo[] {
  const workDir = join(BASE_DIR, 'MEMORY', 'WORK');
  if (!existsSync(workDir)) return [];
  const sessions: SessionInfo[] = [];
  try {
    const dirs = readdirSync(workDir, { withFileTypes: true })
      .filter(d => d.isDirectory() && /^\d{8}-\d{6}_/.test(d.name))
      .map(d => d.name)
      .sort()
      .reverse();
    for (const dir of dirs) {
      const prdPath = join(workDir, dir, 'PRD.md');
      if (!existsSync(prdPath)) continue;
      try {
        const head = readFileSync(prdPath, 'utf-8').substring(0, 500);
        const effort = head.match(/^effort:\s*(.+)$/m)?.[1]?.trim() || 'unknown';
        const phase = head.match(/^phase:\s*(.+)$/m)?.[1]?.trim() || 'unknown';
        const progress = head.match(/^progress:\s*(.+)$/m)?.[1]?.trim() || '0/0';
        const task = head.match(/^task:\s*(.+)$/m)?.[1]?.trim() || dir;
        const dateMatch = dir.match(/^(\d{4})(\d{2})(\d{2})/);
        const date = dateMatch ? `${dateMatch[1]}-${dateMatch[2]}-${dateMatch[3]}` : '';
        sessions.push({ slug: dir, effort, phase, progress, task, date });
      } catch { /* skip */ }
    }
  } catch { /* skip */ }
  return sessions;
}

function readWisdomThemes(): WisdomTheme[] {
  const framesDir = join(BASE_DIR, 'MEMORY', 'WISDOM', 'FRAMES');
  if (!existsSync(framesDir)) return [];
  const themes: WisdomTheme[] = [];
  try {
    for (const file of readdirSync(framesDir).filter(f => f.endsWith('.md'))) {
      const content = readFileSync(join(framesDir, file), 'utf-8');
      const domain = file.replace('.md', '');
      const matches = content.matchAll(/^### (.+?) \[CRYSTAL: (\d+)%\]/gm);
      for (const m of matches) {
        themes.push({ name: m[1], confidence: parseInt(m[2], 10), domain });
      }
    }
  } catch { /* skip */ }
  return themes;
}

// ── SVG Charts ──

function barChart(data: { label: string; value: number }[], color = '#3b82f6'): string {
  if (data.length === 0) return '<p class="empty">No data</p>';
  const w = 400, h = 140;
  const max = Math.max(...data.map(d => d.value), 1);
  const barW = Math.max(Math.floor(w / data.length) - 2, 4);
  const bars = data.map((d, i) => {
    const bh = Math.max((d.value / max) * (h - 24), 1);
    const x = i * (barW + 2);
    const y = h - bh - 20;
    return `<rect x="${x}" y="${y}" width="${barW}" height="${bh}" fill="${color}" rx="2"/>
      <text x="${x + barW / 2}" y="${h - 4}" text-anchor="middle" fill="#888" font-size="8">${d.label}</text>
      <text x="${x + barW / 2}" y="${y - 3}" text-anchor="middle" fill="#ccc" font-size="9">${d.value}</text>`;
  }).join('\n');
  return `<svg width="${w}" height="${h}" xmlns="http://www.w3.org/2000/svg">${bars}</svg>`;
}

function horizontalBar(items: { label: string; value: number; max: number }[], color = '#3b82f6'): string {
  if (items.length === 0) return '<p class="empty">No data</p>';
  return items.map(d => {
    const pct = Math.round((d.value / Math.max(d.max, 1)) * 100);
    return `<div class="hbar"><span class="hbar-label">${d.label}</span>
      <div class="hbar-track"><div class="hbar-fill" style="width:${pct}%;background:${color}"></div></div>
      <span class="hbar-value">${d.value}</span></div>`;
  }).join('\n');
}

// ── HTML Generation ──

interface GenerateResult {
  html: string;
  meta: { reflections: number; ratings: number; sessions: number; hookEvents: number; wisdomFrames: number; parseErrors: number };
}

function generateHTML(): GenerateResult {
  const reflections = readReflections();
  const ratings = readRatings();
  const hookHealth = readHookHealth();
  const depHealth = readDepHealth();
  const sessions = readSessions();
  const wisdomThemes = readWisdomThemes();
  const usageCache = existsSync(join(STATE_DIR, 'usage-cache.json'))
    ? JSON.parse(readFileSync(join(STATE_DIR, 'usage-cache.json'), 'utf-8')) : null;

  const now = new Date();
  const totalParseErrors = reflections.parseErrors + ratings.parseErrors + hookHealth.parseErrors;

  // ── Panel 1: System Health ──
  const depRows = Object.entries(depHealth).map(([name, s]) => {
    const icon = s.status === 'up' ? '🟢' : s.status === 'probing' ? '🟡' : '🔴';
    return `<tr><td>${icon} ${name}</td><td>${s.status}</td><td>${s.consecutive_failures}</td>
      <td>${s.last_failure_reason || '—'}</td></tr>`;
  }).join('') || '<tr><td colspan="4">No dependency data yet</td></tr>';

  const tripCount = hookHealth.entries.filter(e => e.event === 'trip').length;
  const recoverCount = hookHealth.entries.filter(e => e.event === 'recover').length;
  const apiUtil = usageCache?.five_hour?.utilization ?? '—';

  // ── Panel 2: Session Activity ──
  const dateMap = new Map<string, number>();
  for (const s of sessions) { if (s.date) dateMap.set(s.date, (dateMap.get(s.date) || 0) + 1); }
  const sortedDates = [...dateMap.entries()].sort((a, b) => a[0].localeCompare(b[0])).slice(-14);
  const sessionChart = barChart(sortedDates.map(([d, v]) => ({ label: d.slice(5), value: v })));

  const effortCounts: Record<string, number> = {};
  const phaseCounts: Record<string, number> = {};
  for (const s of sessions) {
    effortCounts[s.effort] = (effortCounts[s.effort] || 0) + 1;
    phaseCounts[s.phase] = (phaseCounts[s.phase] || 0) + 1;
  }
  const effortMax = Math.max(...Object.values(effortCounts), 1);
  const effortBars = horizontalBar(
    Object.entries(effortCounts).sort((a, b) => b[1] - a[1]).map(([k, v]) => ({ label: k, value: v, max: effortMax })),
    '#8b5cf6'
  );
  const completeCount = sessions.filter(s => s.phase === 'complete').length;
  const completionRate = sessions.length > 0 ? Math.round((completeCount / sessions.length) * 100) : 0;

  // ── Panel 3: Learning Loop ──
  const refs = reflections.entries;
  const avgCriteria = refs.length > 0 ? Math.round(refs.reduce((s, r) => s + (r.criteria_count || 0), 0) / refs.length) : 0;
  const avgSentiment = refs.length > 0 ? (refs.reduce((s, r) => s + (r.implied_sentiment || 0), 0) / refs.length).toFixed(1) : '—';
  const withinBudgetPct = refs.length > 0 ? Math.round((refs.filter(r => r.within_budget).length / refs.length) * 100) : 0;

  const wisdomBars = horizontalBar(
    wisdomThemes.sort((a, b) => b.confidence - a.confidence).map(t => ({
      label: t.name, value: t.confidence, max: 100,
    })),
    '#10b981'
  );

  // ── Panel 4: Performance ──
  const ratingDist: Record<number, number> = {};
  for (const r of ratings.entries) { ratingDist[r.rating] = (ratingDist[r.rating] || 0) + 1; }
  const ratingChartData = Array.from({ length: 10 }, (_, i) => ({
    label: String(i + 1), value: ratingDist[i + 1] || 0,
  }));
  const ratingChart = barChart(ratingChartData, '#ef4444');

  // Effort level vs avg criteria
  const effortCriteriaMap: Record<string, number[]> = {};
  for (const r of refs) {
    if (!effortCriteriaMap[r.effort_level]) effortCriteriaMap[r.effort_level] = [];
    effortCriteriaMap[r.effort_level].push(r.criteria_count || 0);
  }
  const effortCriteriaRows = Object.entries(effortCriteriaMap).map(([e, counts]) => {
    const avg = Math.round(counts.reduce((a, b) => a + b, 0) / counts.length);
    return `<tr><td>${e}</td><td>${counts.length}</td><td>${avg}</td></tr>`;
  }).join('');

  // ── Panel 5: Data Quality ──
  const dataFiles = [
    { name: 'algorithm-reflections.jsonl', count: reflections.entries.length, errors: reflections.parseErrors },
    { name: 'ratings.jsonl', count: ratings.entries.length, errors: ratings.parseErrors },
    { name: 'hook-health.jsonl', count: hookHealth.entries.length, errors: hookHealth.parseErrors },
    { name: 'WORK/ sessions', count: sessions.length, errors: 0 },
    { name: 'WISDOM/FRAMES themes', count: wisdomThemes.length, errors: 0 },
  ];
  const dataRows = dataFiles.map(f =>
    `<tr><td>${f.name}</td><td>${f.count}</td><td>${f.errors > 0 ? `⚠️ ${f.errors}` : '✅ 0'}</td></tr>`
  ).join('');

  // ── Staleness ──
  let stalenessBanner = '';
  if (existsSync(META_FILE)) {
    try {
      const meta = JSON.parse(readFileSync(META_FILE, 'utf-8'));
      const lastGen = new Date(meta.generated_at);
      const daysOld = Math.floor((now.getTime() - lastGen.getTime()) / 86400000);
      if (daysOld > 7) {
        stalenessBanner = `<div class="banner warn">This report was last generated ${daysOld} days ago. Run <code>bun run ~/.claude/PAI/TOOLS/PaiAnalytics.ts</code> to refresh.</div>`;
      }
    } catch { /* skip */ }
  }

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PAI Analytics</title>
<style>
  :root { --bg: #0f172a; --card: #1e293b; --border: #334155; --text: #e2e8f0; --muted: #94a3b8; --accent: #3b82f6; }
  @media (prefers-color-scheme: light) { :root { --bg: #f8fafc; --card: #fff; --border: #e2e8f0; --text: #1e293b; --muted: #64748b; } }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: var(--bg); color: var(--text); padding: 24px; }
  h1 { font-size: 1.5rem; margin-bottom: 4px; }
  .subtitle { color: var(--muted); margin-bottom: 20px; font-size: 0.85rem; }
  .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; max-width: 900px; }
  .panel { background: var(--card); border: 1px solid var(--border); border-radius: 8px; padding: 16px; }
  .panel h2 { font-size: 1rem; margin-bottom: 12px; color: var(--accent); }
  .panel.full { grid-column: 1 / -1; }
  table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
  th, td { padding: 4px 8px; text-align: left; border-bottom: 1px solid var(--border); }
  th { color: var(--muted); font-weight: 500; }
  .stat { display: inline-block; margin-right: 16px; margin-bottom: 8px; }
  .stat-value { font-size: 1.4rem; font-weight: 700; }
  .stat-label { font-size: 0.75rem; color: var(--muted); }
  .empty { color: var(--muted); font-style: italic; font-size: 0.85rem; }
  .banner { padding: 10px 16px; border-radius: 6px; margin-bottom: 16px; font-size: 0.85rem; }
  .banner.warn { background: #78350f; color: #fbbf24; border: 1px solid #92400e; }
  .banner.ok { background: #064e3b; color: #6ee7b7; border: 1px solid #065f46; }
  code { background: var(--border); padding: 2px 6px; border-radius: 3px; font-size: 0.8rem; }
  svg { display: block; margin: 8px 0; }
  .hbar { display: flex; align-items: center; gap: 8px; margin: 4px 0; font-size: 0.82rem; }
  .hbar-label { min-width: 120px; text-align: right; color: var(--muted); }
  .hbar-track { flex: 1; height: 16px; background: var(--border); border-radius: 4px; overflow: hidden; }
  .hbar-fill { height: 100%; border-radius: 4px; transition: width 0.3s; }
  .hbar-value { min-width: 30px; }
</style>
</head>
<body>
<h1>PAI Analytics Dashboard</h1>
<p class="subtitle">Generated ${now.toISOString().split('T')[0]} ${now.toTimeString().split(' ')[0]} · ${reflections.entries.length} reflections · ${sessions.length} sessions · ${ratings.entries.length} ratings</p>

${stalenessBanner}
${totalParseErrors > 0 ? `<div class="banner warn">⚠️ ${totalParseErrors} parse errors detected across data files. Check Panel 5 for details.</div>` : ''}

<div class="grid">

<div class="panel">
<h2>1. System Health</h2>
<div class="stat"><div class="stat-value">${apiUtil}%</div><div class="stat-label">API Utilization</div></div>
<div class="stat"><div class="stat-value">${tripCount}</div><div class="stat-label">CB Trips</div></div>
<div class="stat"><div class="stat-value">${recoverCount}</div><div class="stat-label">Recoveries</div></div>
<table><tr><th>Dependency</th><th>Status</th><th>Failures</th><th>Reason</th></tr>${depRows}</table>
</div>

<div class="panel">
<h2>2. Session Activity</h2>
<div class="stat"><div class="stat-value">${sessions.length}</div><div class="stat-label">Total Sessions</div></div>
<div class="stat"><div class="stat-value">${completionRate}%</div><div class="stat-label">Completion Rate</div></div>
${sessionChart}
<h3 style="margin-top:12px;font-size:0.85rem;color:var(--muted)">By Effort Level</h3>
${effortBars}
</div>

<div class="panel">
<h2>3. Learning Loop</h2>
<div class="stat"><div class="stat-value">${reflections.entries.length}</div><div class="stat-label">Reflections</div></div>
<div class="stat"><div class="stat-value">${avgCriteria}</div><div class="stat-label">Avg Criteria/Session</div></div>
<div class="stat"><div class="stat-value">${avgSentiment}</div><div class="stat-label">Avg Sentiment</div></div>
<div class="stat"><div class="stat-value">${withinBudgetPct}%</div><div class="stat-label">Within Budget</div></div>
<h3 style="margin-top:12px;font-size:0.85rem;color:var(--muted)">Wisdom Frames</h3>
${wisdomBars}
</div>

<div class="panel">
<h2>4. Performance</h2>
<h3 style="font-size:0.85rem;color:var(--muted)">Rating Distribution</h3>
${ratingChart}
<h3 style="margin-top:12px;font-size:0.85rem;color:var(--muted)">Effort vs Avg Criteria</h3>
<table><tr><th>Effort</th><th>Sessions</th><th>Avg Criteria</th></tr>${effortCriteriaRows}</table>
</div>

<div class="panel full">
<h2>5. Data Quality</h2>
<table><tr><th>Source</th><th>Entries</th><th>Parse Errors</th></tr>${dataRows}</table>
</div>

</div>
</body>
</html>`;

  return {
    html,
    meta: {
      reflections: reflections.entries.length,
      ratings: ratings.entries.length,
      sessions: sessions.length,
      hookEvents: hookHealth.entries.length,
      wisdomFrames: wisdomThemes.length,
      parseErrors: totalParseErrors,
    },
  };
}

// ── Main ──

function main() {
  console.error('📊 PaiAnalytics: Generating report...');

  if (!existsSync(STATE_DIR)) mkdirSync(STATE_DIR, { recursive: true });

  const { html, meta } = generateHTML();
  writeFileSync(OUTPUT_FILE, html);
  console.error(`  Wrote ${OUTPUT_FILE} (${html.length} chars)`);

  writeFileSync(META_FILE, JSON.stringify({
    generated_at: new Date().toISOString(),
    data_counts: {
      reflections: meta.reflections,
      ratings: meta.ratings,
      sessions: meta.sessions,
      hook_events: meta.hookEvents,
      wisdom_frames: meta.wisdomFrames,
    },
    parse_errors: meta.parseErrors,
  }, null, 2));

  // Open in browser
  try {
    execSync(`open "${OUTPUT_FILE}"`, { stdio: 'ignore' });
    console.error('  Opened in browser');
  } catch {
    console.error(`  Open manually: ${OUTPUT_FILE}`);
  }

  console.error('✅ PaiAnalytics: Done.');
}

main();
