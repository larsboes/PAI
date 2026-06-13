#!/usr/bin/env bun
/**
 * SynthesizeWisdom.ts - Process algorithm reflections into crystallized wisdom frames
 *
 * Reads algorithm-reflections.jsonl, clusters by theme, and writes
 * WISDOM/FRAMES/*.md files that loadWisdomFrames() reads at session start.
 *
 * USAGE:
 *   bun run ~/.claude/PAI/Tools/SynthesizeWisdom.ts
 *
 * Can be run manually, via cron, or from a SessionEnd hook.
 * Idempotent — overwrites existing frames with latest synthesis.
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';

const BASE_DIR = process.env.PAI_DIR || join(process.env.HOME!, '.claude');
const JSONL_PATH = join(BASE_DIR, 'MEMORY', 'LEARNING', 'REFLECTIONS', 'algorithm-reflections.jsonl');
const FRAMES_DIR = join(BASE_DIR, 'MEMORY', 'WISDOM', 'FRAMES');

interface Reflection {
  timestamp: string;
  effort_level: string;
  task_description: string;
  implied_sentiment: number;
  reflection_q1: string;
  reflection_q2: string;
  reflection_q3: string;
  within_budget: boolean;
}

interface ThemeConfig {
  name: string;
  keywords: RegExp[];
  description: string;
}

interface ThemeMatch {
  theme: ThemeConfig;
  evidence: { reflection: string; task: string; timestamp: string }[];
}

// Theme definitions — each maps keywords to a behavioral domain
const THEMES: ThemeConfig[] = [
  {
    name: 'Verify Before Asserting',
    keywords: [/verif|assert|claim|fetch.*before|check.*before|confirm.*before|wrong.*assessment/i],
    description: 'Always verify state (git, files, APIs) before making claims about it.',
  },
  {
    name: 'Parallelize Early',
    keywords: [/parallel|background.*agent|concurrent|simultaneous|spawn.*earlier/i],
    description: 'Launch parallel agents/work as early as possible instead of sequential.',
  },
  {
    name: 'Pivot Fast on Failures',
    keywords: [/pivot.*fast|wasted.*round|retry|webfetch.*fail|should have pivoted|wasted.*minute/i],
    description: 'When a tool or approach fails, pivot immediately instead of retrying.',
  },
  {
    name: 'Front-Load Investigation',
    keywords: [/front.?load|read.*first|started.*with|pre.?valid|investigation.*complete.*before/i],
    description: 'Read existing files, state, and context before launching work.',
  },
  {
    name: 'Right-Size Effort',
    keywords: [/too thorough|overkill|standard.*task|effort.*level|fast.?track|calibrat/i],
    description: 'Match investigation depth to effort level. Skip ceremony for simple tasks.',
  },
  {
    name: 'Agent Constraints',
    keywords: [/agent.*fail|agent.*timeout|aws.*auth|subagent|agent.*constraint|lost.*time.*agent/i],
    description: 'Validate agent prerequisites (auth, permissions) before launching them.',
  },
  {
    name: 'Simplify and Review',
    keywords: [/simplify|review.*immediately|review.*earlier|quality.*check/i],
    description: 'Invoke /simplify and review passes early, not as an afterthought.',
  },
  {
    name: 'Data Before Docs',
    keywords: [/data.*file|empiric|actual.*data|ratings\.jsonl|read.*actual|ground.*in/i],
    description: 'Read actual runtime data (logs, metrics, JSONL) before documentation.',
  },
  {
    name: 'Competing Hypotheses',
    keywords: [/hypothesis|hypotheses|root cause|single.*cause|assuming.*single|multiple.*cause/i],
    description: 'Use competing hypotheses for debugging instead of assuming single root cause.',
  },
];

function loadReflections(): Reflection[] {
  if (!existsSync(JSONL_PATH)) {
    console.error('No algorithm-reflections.jsonl found');
    process.exit(0);
  }

  const content = readFileSync(JSONL_PATH, 'utf-8').trim();
  if (!content) return [];

  const reflections: Reflection[] = [];
  for (const line of content.split('\n')) {
    try {
      reflections.push(JSON.parse(line));
    } catch { /* skip malformed */ }
  }
  return reflections;
}

function clusterByTheme(reflections: Reflection[]): ThemeMatch[] {
  const matches: ThemeMatch[] = THEMES.map(theme => ({ theme, evidence: [] }));

  for (const r of reflections) {
    const text = `${r.reflection_q1} ${r.reflection_q2} ${r.reflection_q3}`;

    for (const match of matches) {
      const matched = match.theme.keywords.some(kw => kw.test(text));
      if (matched) {
        match.evidence.push({
          reflection: r.reflection_q1?.substring(0, 120) || '',
          task: r.task_description?.substring(0, 60) || '',
          timestamp: r.timestamp?.substring(0, 10) || '',
        });
      }
    }
  }

  return matches.filter(m => m.evidence.length > 0);
}

function calculateConfidence(evidenceCount: number): number {
  // Confidence grows with evidence, capped at 98%
  // 1 = 60%, 2 = 75%, 3 = 85%, 4 = 88%, 5 = 91%, 6 = 94%, 7+ = 97-98%
  if (evidenceCount >= 7) return 98;
  if (evidenceCount >= 3) return 85 + (evidenceCount - 3) * 3;
  if (evidenceCount >= 2) return 75;
  return 60;
}

function writeFrameFile(domain: string, themeMatches: ThemeMatch[], reflectionCount: number): void {
  const lines: string[] = [
    `# Wisdom Frame: ${domain}`,
    '',
    `*Auto-synthesized from ${reflectionCount} algorithm reflections.*`,
    `*Last updated: ${new Date().toISOString().split('T')[0]}*`,
    '',
  ];

  for (const match of themeMatches) {
    const confidence = calculateConfidence(match.evidence.length);
    lines.push(`### ${match.theme.name} [CRYSTAL: ${confidence}%]`);
    lines.push('');
    lines.push(match.theme.description);
    lines.push('');
    lines.push(`**Evidence (${match.evidence.length} sessions):**`);
    // Show up to 3 most recent pieces of evidence
    const recentEvidence = match.evidence.slice(-3);
    for (const e of recentEvidence) {
      lines.push(`- [${e.timestamp}] ${e.task}: "${e.reflection}"`);
    }
    lines.push('');
  }

  const content = lines.join('\n');
  const filePath = join(FRAMES_DIR, `${domain}.md`);
  writeFileSync(filePath, content);
  console.error(`  Wrote ${filePath} (${themeMatches.length} principles)`);
}

function main() {
  console.error('🧠 SynthesizeWisdom: Processing algorithm reflections...');

  const reflections = loadReflections();
  if (reflections.length === 0) {
    console.error('  No reflections to process');
    process.exit(0);
  }

  console.error(`  Found ${reflections.length} reflections`);

  // Cluster all reflections by theme
  const clustered = clusterByTheme(reflections);
  console.error(`  Matched ${clustered.length} themes`);

  if (clustered.length === 0) {
    console.error('  No themes matched — check keyword patterns');
    process.exit(0);
  }

  // Create WISDOM/FRAMES directory
  if (!existsSync(FRAMES_DIR)) {
    mkdirSync(FRAMES_DIR, { recursive: true });
    console.error(`  Created ${FRAMES_DIR}`);
  }

  // Group themes by domain for file organization
  // For now, all go into a single "algorithm-patterns" file
  // Can be split into multiple files as themes grow
  writeFrameFile('algorithm-patterns', clustered, reflections.length);

  console.error(`✅ SynthesizeWisdom: Done. ${clustered.length} patterns crystallized.`);
}

main();
