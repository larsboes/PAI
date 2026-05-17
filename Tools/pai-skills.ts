#!/usr/bin/env bun
/**
 * pai-skills — Interactive PAI skill activation manager
 *
 * Manages which packs in PAI/Packs/ get symlinked to ~/.claude/skills,
 * ~/.pi/agent/skills, ~/.gemini/skills via skills.yaml + sync-deploy.sh.
 *
 * Subcommands:
 *   pai-skills            interactive picker (default)
 *   pai-skills active     print active list
 *   pai-skills sync       run sync-deploy.sh --clean
 *   pai-skills audit      description sizes + token estimate
 *   pai-skills list       all packs with status
 *
 * Picker keys: ↑/↓ move, Space toggle, / filter, g group jump,
 *              a all-in-group, n none-in-group, Enter save, q cancel
 */

import { readFileSync, writeFileSync, readdirSync, statSync, existsSync } from "fs";
import { join, basename } from "path";
import { spawnSync } from "child_process";

// ── Paths ────────────────────────────────────────────────────────────
const SCRIPT_DIR = new URL("..", import.meta.url).pathname.replace(/\/$/, "");
const PAI_ROOT = SCRIPT_DIR;
const PACKS_DIR = join(PAI_ROOT, "Packs");
const SKILLS_YAML = join(PAI_ROOT, "skills.yaml");
const SYNC_DEPLOY = join(PAI_ROOT, "sync-deploy.sh");

// ── ANSI ────────────────────────────────────────────────────────────
const C = {
  reset: "\x1b[0m",
  bold: "\x1b[1m",
  dim: "\x1b[2m",
  inv: "\x1b[7m",
  red: "\x1b[31m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m",
  cyan: "\x1b[36m",
  gray: "\x1b[90m",
  brightGreen: "\x1b[92m",
};
const cls = "\x1b[2J\x1b[H";
const hideCursor = "\x1b[?25l";
const showCursor = "\x1b[?25h";
const altScreen = "\x1b[?1049h";
const exitAltScreen = "\x1b[?1049l";

// ── Types ────────────────────────────────────────────────────────────
interface Pack {
  name: string;            // entry as it appears in skills.yaml (flat or Pack/Sub)
  displayName: string;     // last segment for display
  description: string;     // first 200 chars of SKILL.md description
  fullDescription: string;
  descLen: number;         // raw char count
  category: string;
  isSubSkill: boolean;
  parent?: string;
  active: boolean;
}

interface YamlState {
  raw: string;
  active: Set<string>;     // entry names currently uncommented under `active:`
  knownGroups: { header: string; entries: string[] }[];
}

// ── YAML parsing (minimal, format-preserving for skills.yaml shape) ──

function parseYaml(): YamlState {
  const raw = readFileSync(SKILLS_YAML, "utf8");
  const lines = raw.split("\n");
  const active = new Set<string>();
  const groups: { header: string; entries: string[] }[] = [];
  let inActive = false;
  let currentHeader = "Uncategorized";
  let currentGroup: string[] = [];

  const pushGroup = () => {
    if (currentGroup.length) {
      groups.push({ header: currentHeader, entries: [...currentGroup] });
      currentGroup = [];
    }
  };

  for (const line of lines) {
    if (/^active:/.test(line)) { inActive = true; continue; }
    if (inActive && /^[a-z_-]+:\s*$/.test(line)) { inActive = false; pushGroup(); continue; }
    if (!inActive) continue;

    const headerMatch = line.match(/^\s*#\s*──+\s*(.+?)\s*──+/);
    if (headerMatch) {
      pushGroup();
      currentHeader = headerMatch[1].trim();
      continue;
    }

    // Active entry: `  - Name` (optional inline comment)
    const activeMatch = line.match(/^\s*-\s*([A-Za-z0-9_/-]+)\s*(?:#.*)?$/);
    if (activeMatch) {
      const name = activeMatch[1];
      active.add(name);
      currentGroup.push(name);
      continue;
    }

    // Commented entry: `  #- Name # comment`
    const commentedMatch = line.match(/^\s*#-\s*([A-Za-z0-9_/-]+)\s*(?:#.*)?$/);
    if (commentedMatch) {
      currentGroup.push(commentedMatch[1]);
      continue;
    }
  }
  pushGroup();
  return { raw, active, knownGroups: groups };
}

// Write skills.yaml. Preserves comments, headers, inline annotations.
// Strategy: parse into segments, regenerate `active:` block, leave rest untouched.
function writeYaml(state: YamlState, newActive: Set<string>): void {
  const lines = state.raw.split("\n");
  const out: string[] = [];
  let inActive = false;
  let activeBlockDone = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    if (/^active:/.test(line)) {
      out.push(line);
      inActive = true;
      continue;
    }

    if (inActive && /^[a-z_-]+:\s*$/.test(line)) {
      inActive = false;
      activeBlockDone = true;
      out.push(line);
      continue;
    }

    if (!inActive) {
      out.push(line);
      continue;
    }

    // Inside active block — rewrite entry lines, preserve everything else
    const headerMatch = line.match(/^\s*#\s*──+/);
    const blank = line.trim() === "";

    if (headerMatch || blank) {
      out.push(line);
      continue;
    }

    // Match either active or commented entry; preserve the indent + trailing comment
    const m = line.match(/^(\s*)(?:-|#-)\s*([A-Za-z0-9_/-]+)(\s*#.*)?$/);
    if (!m) {
      // Unknown line — preserve as-is to avoid clobbering
      out.push(line);
      continue;
    }

    const [, indent, name, trailingComment = ""] = m;
    const wantActive = newActive.has(name);
    const prefix = wantActive ? "- " : "#- ";
    out.push(`${indent}${prefix}${name}${trailingComment}`);
  }

  if (!activeBlockDone) {
    // Defensive: never reached the next top-level key. Still safe — we wrote what we got.
  }

  writeFileSync(SKILLS_YAML, out.join("\n"));
}

// ── Pack discovery ───────────────────────────────────────────────────

function readSkillMd(skillMdPath: string): { description: string; descLen: number } {
  if (!existsSync(skillMdPath)) return { description: "(no SKILL.md)", descLen: 0 };
  const content = readFileSync(skillMdPath, "utf8");
  // Pull description out of YAML frontmatter (single line — these all are)
  const fmMatch = content.match(/^---\n([\s\S]*?)\n---/);
  if (!fmMatch) return { description: "(no frontmatter)", descLen: 0 };
  const descMatch = fmMatch[1].match(/^description:\s*(.*?)$/m);
  if (!descMatch) return { description: "(no description)", descLen: 0 };
  const full = descMatch[1].replace(/^["']|["']$/g, "");
  return { description: full, descLen: full.length };
}

function discoverPacks(state: YamlState): Pack[] {
  const packs: Pack[] = [];
  const groupByEntry = new Map<string, string>();
  for (const g of state.knownGroups) {
    for (const e of g.entries) groupByEntry.set(e, g.header);
  }

  const entries = readdirSync(PACKS_DIR);
  for (const entry of entries) {
    const packDir = join(PACKS_DIR, entry);
    if (!statSync(packDir).isDirectory()) continue;

    const srcDir = join(packDir, "src");
    if (!existsSync(srcDir)) continue;

    const flatSkill = join(srcDir, "SKILL.md");
    if (existsSync(flatSkill)) {
      const { description, descLen } = readSkillMd(flatSkill);
      packs.push({
        name: entry,
        displayName: entry,
        description: description.slice(0, 200),
        fullDescription: description,
        descLen,
        category: groupByEntry.get(entry) ?? "Other / unsorted",
        isSubSkill: false,
        active: state.active.has(entry),
      });
      continue;
    }

    // Meta-pack: enumerate subdirs
    let foundSub = false;
    const subs = readdirSync(srcDir);
    for (const sub of subs) {
      const subDir = join(srcDir, sub);
      if (!existsSync(subDir) || !statSync(subDir).isDirectory()) continue;
      const subSkill = join(subDir, "SKILL.md");
      if (!existsSync(subSkill)) continue;
      foundSub = true;
      const subEntry = `${entry}/${sub}`;
      const { description, descLen } = readSkillMd(subSkill);
      // Active if either the bare meta-pack OR the granular sub is listed
      const active = state.active.has(entry) || state.active.has(subEntry);
      packs.push({
        name: subEntry,
        displayName: sub,
        description: description.slice(0, 200),
        fullDescription: description,
        descLen,
        category: groupByEntry.get(entry) ?? groupByEntry.get(subEntry) ?? "Personal / meta-packs",
        isSubSkill: true,
        parent: entry,
        active,
      });
    }
    if (!foundSub) {
      // Empty pack — still surface so user can see it exists
      packs.push({
        name: entry,
        displayName: entry,
        description: "(no SKILL.md found)",
        fullDescription: "",
        descLen: 0,
        category: groupByEntry.get(entry) ?? "Other / unsorted",
        isSubSkill: false,
        active: state.active.has(entry),
      });
    }
  }

  return packs;
}

// ── Subcommands ──────────────────────────────────────────────────────

function cmdActive(): void {
  const state = parseYaml();
  for (const name of [...state.active].sort()) {
    console.log(name);
  }
}

function cmdList(): void {
  const state = parseYaml();
  const packs = discoverPacks(state);
  packs.sort((a, b) => a.name.localeCompare(b.name));
  for (const p of packs) {
    const mark = p.active ? `${C.green}●${C.reset}` : `${C.gray}○${C.reset}`;
    console.log(`${mark} ${p.name.padEnd(28)} ${C.dim}${p.descLen}c${C.reset}  ${p.description.slice(0, 70)}`);
  }
  const activeCount = packs.filter(p => p.active).length;
  console.log(`\n${C.bold}${activeCount}${C.reset} active / ${packs.length} total`);
}

function cmdAudit(): void {
  const state = parseYaml();
  const packs = discoverPacks(state).filter(p => p.active);
  packs.sort((a, b) => b.descLen - a.descLen);
  const totalChars = packs.reduce((s, p) => s + p.descLen, 0);
  const estTokens = Math.ceil(totalChars / 4); // rough approximation

  console.log(`${C.bold}── Active skill description audit ──${C.reset}\n`);
  console.log(`${"chars".padStart(6)}  ${"target".padStart(6)}  pack`);
  console.log(`${"─".repeat(6)}  ${"─".repeat(6)}  ────`);
  for (const p of packs) {
    let target = "";
    if (p.descLen > 1500) target = `${C.red}≤500${C.reset}`;
    else if (p.descLen > 800) target = `${C.yellow}≤500${C.reset}`;
    else if (p.descLen > 400) target = `${C.dim}ok${C.reset}`;
    else target = `${C.dim}—${C.reset}`;
    const colored = p.descLen > 1500 ? C.red : p.descLen > 800 ? C.yellow : C.reset;
    console.log(`${colored}${String(p.descLen).padStart(6)}${C.reset}  ${target.padStart(15)}  ${p.name}`);
  }
  console.log(`\n${C.bold}Total:${C.reset} ${totalChars} chars  ~${estTokens} tokens (≈ ${packs.length} active skills)`);
  console.log(`${C.dim}Note: source SKILL.md kept verbose for routing fidelity. Trim only if dropping skills.${C.reset}`);
}

function cmdSync(args: string[]): void {
  const cleanFlag = args.includes("--clean") ? "--clean" : null;
  const dryRun = args.includes("--dry-run") ? "--dry-run" : null;
  const flags = [cleanFlag, dryRun].filter(Boolean) as string[];
  console.log(`${C.cyan}→ Running ${SYNC_DEPLOY} ${flags.join(" ")}${C.reset}\n`);
  const r = spawnSync("bash", [SYNC_DEPLOY, ...flags], { stdio: "inherit" });
  process.exit(r.status ?? 1);
}

// ── Interactive picker ───────────────────────────────────────────────

interface PickerState {
  packs: Pack[];           // visible (after filter)
  allPacks: Pack[];
  cursor: number;
  viewportTop: number;     // sticky top row of visible window (flat-index space)
  filter: string;
  selected: Set<string>;
  origSelected: Set<string>;
  message: string;
}

function applyFilter(allPacks: Pack[], filter: string): Pack[] {
  if (!filter.trim()) return allPacks;
  const q = filter.toLowerCase();
  return allPacks.filter(p =>
    p.name.toLowerCase().includes(q) ||
    p.fullDescription.toLowerCase().includes(q) ||
    p.category.toLowerCase().includes(q)
  );
}

function groupedPacks(packs: Pack[]): { header: string; items: Pack[] }[] {
  const map = new Map<string, Pack[]>();
  for (const p of packs) {
    const arr = map.get(p.category) ?? [];
    arr.push(p);
    map.set(p.category, arr);
  }
  // Preserve order of first appearance
  const order: string[] = [];
  for (const p of packs) if (!order.includes(p.category)) order.push(p.category);
  return order.map(h => ({ header: h, items: map.get(h)! }));
}

function flattenWithHeaders(grouped: { header: string; items: Pack[] }[]): (Pack | string)[] {
  const out: (Pack | string)[] = [];
  for (const g of grouped) {
    out.push(`__HEADER__:${g.header}`);
    for (const p of g.items) out.push(p);
  }
  return out;
}

function render(state: PickerState): void {
  const cols = process.stdout.columns ?? 100;
  const rows = process.stdout.rows ?? 30;
  const grouped = groupedPacks(state.packs);
  const flat = flattenWithHeaders(grouped);

  // Move cursor on grouped list — skip headers
  // state.cursor indexes into a "selectable items" list; convert to flat index for display
  const selectable: Pack[] = state.packs;
  const cursorPack = selectable[state.cursor];

  const selCount = state.selected.size;
  const totalCount = state.allPacks.length;
  const dirty = selCount !== state.origSelected.size ||
    [...state.selected].some(n => !state.origSelected.has(n));

  let out = cls;
  out += `${C.bold}${C.magenta}── pai-skills ──${C.reset}  ${selCount}/${totalCount} active`;
  if (dirty) out += `  ${C.yellow}(unsaved changes)${C.reset}`;
  if (state.filter) out += `  ${C.cyan}filter: "${state.filter}"${C.reset}`;
  out += `\n${C.dim}↑↓ move · Space toggle · / filter · g jump-group · A all · N none · Enter save · q cancel${C.reset}\n\n`;

  // Layout: list (60%) | preview (40%)
  const listWidth = Math.floor(cols * 0.55);
  const previewWidth = cols - listWidth - 3;

  // Sticky viewport: only scroll when the cursor reaches the top/bottom margin.
  // Margin = 2 rows so movement near edges still gives some context.
  const listRows = rows - 8;
  const cursorFlat = flat.findIndex(x => x === cursorPack);
  const margin = 2;
  let top = state.viewportTop;
  if (cursorFlat < top + margin) top = Math.max(0, cursorFlat - margin);
  if (cursorFlat >= top + listRows - margin) top = cursorFlat - listRows + margin + 1;
  if (top + listRows > flat.length) top = Math.max(0, flat.length - listRows);
  if (top < 0) top = 0;
  state.viewportTop = top;

  const lines: string[] = [];
  for (let i = top; i < Math.min(flat.length, top + listRows); i++) {
    const item = flat[i];
    if (typeof item === "string" && item.startsWith("__HEADER__:")) {
      const h = item.slice("__HEADER__:".length);
      lines.push(`${C.dim}${C.bold}── ${h} ──${C.reset}`);
      continue;
    }
    const p = item as Pack;
    const isCursor = p === cursorPack;
    const checked = state.selected.has(p.name);
    const box = checked ? `${C.green}[x]${C.reset}` : `${C.gray}[ ]${C.reset}`;
    const subMark = p.isSubSkill ? `${C.dim}└${C.reset} ` : "  ";
    const nameCol = p.name.padEnd(Math.max(20, listWidth - 18));
    const len = `${C.dim}${p.descLen}c${C.reset}`;
    let line = `${box} ${subMark}${nameCol} ${len}`;
    if (isCursor) line = `${C.inv}${stripAnsi(line).padEnd(listWidth)}${C.reset}`;
    lines.push(line.slice(0, cols));
  }

  // Preview pane — wrap description
  const preview: string[] = [];
  if (cursorPack) {
    preview.push(`${C.bold}${cursorPack.name}${C.reset}`);
    preview.push(`${C.dim}${cursorPack.category}  ·  ${cursorPack.descLen} chars${C.reset}`);
    preview.push("");
    const wrapped = wrap(cursorPack.fullDescription, previewWidth);
    for (const w of wrapped) preview.push(w);
  }

  // Side-by-side
  const maxRows = Math.max(lines.length, preview.length);
  for (let i = 0; i < maxRows; i++) {
    const left = (lines[i] ?? "").padEnd(listWidth + ansiOverhead(lines[i] ?? ""));
    const right = preview[i] ?? "";
    out += `${left} ${C.dim}│${C.reset} ${right}\n`;
  }

  if (state.message) out += `\n${state.message}\n`;
  process.stdout.write(out);
}

function ansiOverhead(s: string): number {
  // count ANSI escape characters so padEnd math stays sane
  const m = s.match(/\x1b\[[0-9;]*m/g);
  if (!m) return 0;
  return m.reduce((n, x) => n + x.length, 0);
}

function stripAnsi(s: string): string {
  return s.replace(/\x1b\[[0-9;]*m/g, "");
}

function wrap(s: string, width: number): string[] {
  const words = s.split(/\s+/);
  const out: string[] = [];
  let cur = "";
  for (const w of words) {
    if ((cur + " " + w).trim().length > width) {
      if (cur) out.push(cur);
      cur = w;
    } else {
      cur = (cur ? cur + " " : "") + w;
    }
  }
  if (cur) out.push(cur);
  return out;
}

async function picker(): Promise<void> {
  const state = parseYaml();
  let allPacks = discoverPacks(state);

  // Sort to match rendered grouped order so cursor stride aligns with visual stride.
  // Category order = yaml `knownGroups` order, with unknowns appended in stable order.
  const categoryOrder = new Map<string, number>();
  for (const g of state.knownGroups) {
    if (!categoryOrder.has(g.header)) categoryOrder.set(g.header, categoryOrder.size);
  }
  for (const p of allPacks) {
    if (!categoryOrder.has(p.category)) categoryOrder.set(p.category, categoryOrder.size);
  }
  allPacks.sort((a, b) => {
    const ca = categoryOrder.get(a.category) ?? 999;
    const cb = categoryOrder.get(b.category) ?? 999;
    if (ca !== cb) return ca - cb;
    // Sub-skills follow their parent; sort all by display name otherwise
    return a.name.localeCompare(b.name);
  });

  const initialActive = new Set<string>();
  for (const p of allPacks) if (p.active) initialActive.add(p.name);

  const ps: PickerState = {
    packs: allPacks,
    allPacks,
    cursor: 0,
    viewportTop: 0,
    filter: "",
    selected: new Set(initialActive),
    origSelected: new Set(initialActive),
    message: "",
  };

  process.stdout.write(altScreen + hideCursor);
  const cleanup = () => process.stdout.write(showCursor + exitAltScreen);

  const stdin = process.stdin;
  if (!stdin.isTTY) {
    cleanup();
    console.error("pai-skills: not a TTY — picker requires an interactive terminal.");
    console.error("Use `pai-skills list` or `pai-skills active` for non-interactive use.");
    process.exit(1);
  }
  stdin.setRawMode(true);
  stdin.resume();
  stdin.setEncoding("utf8");

  let inFilter = false;

  const refilter = () => {
    ps.packs = applyFilter(ps.allPacks, ps.filter);
    if (ps.cursor >= ps.packs.length) ps.cursor = Math.max(0, ps.packs.length - 1);
    ps.viewportTop = 0; // filter changes the flat list — reset the window
  };

  return new Promise(resolve => {
    const onData = (key: string) => {
      // Filter mode — capture printable + backspace + Enter/Esc to exit
      if (inFilter) {
        if (key === "\r" || key === "\x1b") {
          inFilter = false;
        } else if (key === "\x7f" || key === "\b") {
          ps.filter = ps.filter.slice(0, -1);
          refilter();
        } else if (key.length === 1 && key >= " " && key <= "~") {
          ps.filter += key;
          refilter();
        }
        render(ps);
        return;
      }

      // Normal mode
      if (key === "\x03" || key === "q") { // Ctrl-C or q → cancel
        cleanup();
        console.log(`${C.dim}cancelled (no changes saved)${C.reset}`);
        stdin.setRawMode(false);
        stdin.pause();
        stdin.removeListener("data", onData);
        resolve();
        return;
      }
      if (key === "\r") { // Enter → save
        const newActive = new Set<string>();
        for (const name of ps.selected) {
          // Only persist names that map to a real entry (so we don't write phantoms)
          if (ps.allPacks.find(p => p.name === name)) newActive.add(name);
        }
        // Convert sub-skills back to entries: if user selected ALL subs of a meta-pack
        // AND the parent name was originally listed bare, prefer the bare parent.
        const metaParents = new Map<string, Pack[]>();
        for (const p of ps.allPacks) {
          if (p.isSubSkill && p.parent) {
            const arr = metaParents.get(p.parent) ?? [];
            arr.push(p);
            metaParents.set(p.parent, arr);
          }
        }
        for (const [parent, subs] of metaParents) {
          const allSelected = subs.every(s => newActive.has(s.name));
          const wasBareInOrig = state.knownGroups.some(g => g.entries.includes(parent));
          if (allSelected && wasBareInOrig) {
            // Replace fine-grained subs with bare parent name
            for (const s of subs) newActive.delete(s.name);
            newActive.add(parent);
          }
        }

        try {
          writeYaml(state, newActive);
          cleanup();
          console.log(`${C.green}✓${C.reset} skills.yaml updated  (${newActive.size} active)`);
          // Offer to sync now
          stdin.setRawMode(false);
          stdin.pause();
          stdin.removeListener("data", onData);
          process.stdout.write(`${C.cyan}Run sync-deploy.sh --clean now? [y/N] ${C.reset}`);
          stdin.setRawMode(true);
          stdin.resume();
          stdin.once("data", (ans: string) => {
            stdin.setRawMode(false);
            stdin.pause();
            console.log(ans);
            if (ans.toLowerCase() === "y") {
              const r = spawnSync("bash", [SYNC_DEPLOY, "--clean"], { stdio: "inherit" });
              process.exit(r.status ?? 0);
            } else {
              console.log(`${C.dim}Skipped — run \`pai-skills sync\` when ready.${C.reset}`);
              resolve();
            }
          });
        } catch (e: any) {
          ps.message = `${C.red}save failed: ${e.message}${C.reset}`;
          render(ps);
        }
        return;
      }
      if (key === "\x1b[A" || key === "k") { ps.cursor = Math.max(0, ps.cursor - 1); render(ps); return; }
      if (key === "\x1b[B" || key === "j") { ps.cursor = Math.min(ps.packs.length - 1, ps.cursor + 1); render(ps); return; }
      if (key === "\x1b[5~") { ps.cursor = Math.max(0, ps.cursor - 10); render(ps); return; } // PageUp
      if (key === "\x1b[6~") { ps.cursor = Math.min(ps.packs.length - 1, ps.cursor + 10); render(ps); return; } // PageDn
      if (key === " ") {
        const p = ps.packs[ps.cursor];
        if (!p) return;
        if (ps.selected.has(p.name)) ps.selected.delete(p.name); else ps.selected.add(p.name);
        render(ps); return;
      }
      if (key === "/") {
        inFilter = true;
        ps.filter = "";
        refilter();
        render(ps); return;
      }
      if (key === "g") {
        // Jump to next group header
        const grouped = groupedPacks(ps.packs);
        const flat = flattenWithHeaders(grouped);
        const cursorFlat = flat.findIndex(x => x === ps.packs[ps.cursor]);
        for (let i = cursorFlat + 1; i < flat.length; i++) {
          const item = flat[i];
          if (typeof item !== "string") {
            ps.cursor = ps.packs.indexOf(item as Pack);
            break;
          }
        }
        render(ps); return;
      }
      if (key === "A") {
        // Select all in current group
        const cur = ps.packs[ps.cursor];
        if (!cur) return;
        for (const p of ps.packs) if (p.category === cur.category) ps.selected.add(p.name);
        render(ps); return;
      }
      if (key === "N") {
        // Deselect all in current group
        const cur = ps.packs[ps.cursor];
        if (!cur) return;
        for (const p of ps.packs) if (p.category === cur.category) ps.selected.delete(p.name);
        render(ps); return;
      }
    };
    stdin.on("data", onData);
    render(ps);
  });
}

// ── Main ─────────────────────────────────────────────────────────────

async function main() {
  const [, , cmd, ...rest] = process.argv;
  switch (cmd) {
    case undefined:
    case "pick":
      await picker();
      break;
    case "active":
      cmdActive();
      break;
    case "list":
      cmdList();
      break;
    case "audit":
      cmdAudit();
      break;
    case "sync":
      cmdSync(rest);
      break;
    case "-h":
    case "--help":
    case "help":
      console.log(`pai-skills — manage active PAI skills

  pai-skills              interactive picker
  pai-skills list         all packs with active status
  pai-skills active       print active list (one per line)
  pai-skills audit        active skill description sizes
  pai-skills sync         run sync-deploy.sh
  pai-skills sync --clean wipe + rebuild all symlinks

Picker keys:
  ↑/↓ or j/k  move
  Space       toggle current
  /           filter (Esc to exit filter)
  g           jump to next group header
  A / N       select all / none in current group
  Enter       save & offer to sync
  q / Ctrl-C  cancel without saving`);
      break;
    default:
      console.error(`unknown command: ${cmd}`);
      console.error(`run \`pai-skills help\``);
      process.exit(1);
  }
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});
