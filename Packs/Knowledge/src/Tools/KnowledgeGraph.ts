#!/usr/bin/env bun
/**
 * KnowledgeGraph — graph navigation + retrieval over an Obsidian-vault knowledge base.
 *
 * Vault-native: nodes are markdown notes keyed by TITLE (filename), edges are the union of
 *   `categories:` ([[Domain]]) + `related:` ([[Title]]) frontmatter links + body [[wikilinks]].
 * No typed-link / kebab-slug assumptions — matches the AGENTS.md vault conventions.
 *
 * Root resolution (in order): $VAULT_PATH/$VAULT_KNOWLEDGE, $OBSIDIAN_VAULT_PATH/$VAULT_KNOWLEDGE,
 *   else the legacy PAI archive ($PAI_DIR/MEMORY/KNOWLEDGE). Reads ~/.env so the path is defined
 *   once, alongside the Obsidian path, exactly like the Obsidian skill.
 *
 * Commands:
 *   stats                          Graph summary: nodes, edges, hubs, orphans, top categories
 *   hubs [--top N]                 Most-connected notes
 *   related "<Title>"              Direct neighbours (1 hop), grouped by edge type
 *   traverse "<Title>" [--hops N]  BFS to N hops (default 2)
 *   find "<Category>"              Notes that belong to a category
 *   retrieve "<query>" [--top N]   BM25-lite ranked notes (summaries; --raw for excerpts)
 *   contradictions [--top N]       Note pairs with high category+link overlap (review candidates)
 */

import { parseArgs } from "util";
import * as fs from "fs";
import * as path from "path";

// ── Config / root resolution ────────────────────────────────────────────────
const HOME = process.env.HOME!;

function loadDotEnv(): void {
  const envPath = path.join(HOME, ".env");
  if (!fs.existsSync(envPath)) return;
  for (const line of fs.readFileSync(envPath, "utf-8").split("\n")) {
    const t = line.trim();
    if (!t || t.startsWith("#")) continue;
    const eq = t.indexOf("=");
    if (eq < 1) continue;
    const key = t.slice(0, eq).trim();
    let val = t.slice(eq + 1).trim().replace(/^["']|["']$/g, "");
    if (process.env[key] === undefined) process.env[key] = val;
  }
}

function resolveRoot(): string {
  loadDotEnv();
  const vk = process.env.VAULT_KNOWLEDGE || "Knowledge";
  for (const base of [process.env.VAULT_PATH, process.env.OBSIDIAN_VAULT_PATH]) {
    if (base) {
      const p = path.join(base, vk);
      if (fs.existsSync(p)) return p;
    }
  }
  return path.join(process.env.PAI_DIR || path.join(HOME, ".claude", "PAI"), "MEMORY", "KNOWLEDGE");
}

const ROOT = resolveRoot();

// ── Types ───────────────────────────────────────────────────────────────────
interface Node { title: string; key: string; summary: string; maturity: string; categories: string[]; path: string; }
type EdgeType = "category" | "related" | "wikilink";
interface Edge { from: string; to: string; type: EdgeType; weight: number; }
interface Graph { nodes: Map<string, Node>; edges: Edge[]; adj: Map<string, Edge[]>; }

const norm = (s: string) => s.toLowerCase().trim();

// ── Parsing ─────────────────────────────────────────────────────────────────
function splitFrontmatter(content: string): { fm: string; body: string } {
  const m = content.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
  return m ? { fm: m[1], body: m[2] } : { fm: "", body: content };
}

function scalarField(fm: string, field: string): string {
  const m = fm.match(new RegExp(`^${field}\\s*:\\s*(.+)$`, "m"));
  return m ? m[1].trim().replace(/^["']|["']$/g, "") : "";
}

/** Collect every [[Target]] under a frontmatter key — handles inline arrays and block lists. */
function wikilinkField(fm: string, field: string): string[] {
  const lines = fm.split("\n");
  const out: string[] = [];
  let inBlock = false;
  for (const line of lines) {
    const head = line.match(new RegExp(`^${field}\\s*:(.*)$`));
    if (head) {
      inBlock = true;
      out.push(...wikilinksIn(head[1])); // inline array form
      continue;
    }
    if (inBlock) {
      // continuation = indented or list item
      if (/^\s+\S/.test(line) || /^\s*-/.test(line)) { out.push(...wikilinksIn(line)); continue; }
      if (line.trim() === "") continue;
      inBlock = false; // a new top-level key ends the block
    }
  }
  return out;
}

function wikilinksIn(s: string): string[] {
  const out: string[] = [];
  const re = /\[\[([^\]|#]+)(?:[#|][^\]]*)?\]\]/g;
  let m;
  while ((m = re.exec(s)) !== null) {
    let t = m[1].trim();
    if (t.includes("/")) t = t.split("/").pop()!.replace(/\.md$/, ""); // strip path prefixes
    if (t && !t.startsWith("_")) out.push(t);
  }
  return out;
}

// ── Graph construction ──────────────────────────────────────────────────────
function walk(dir: string): string[] {
  const out: string[] = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".")) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...walk(full));
    else if (entry.name.endsWith(".md") && !entry.name.startsWith("_")) out.push(full);
  }
  return out;
}

function buildGraph(): Graph {
  const nodes = new Map<string, Node>();
  const edges: Edge[] = [];
  const adj = new Map<string, Edge[]>();
  const files = fs.existsSync(ROOT) ? walk(ROOT) : [];

  // Phase 1 — nodes
  const raw = new Map<string, { categories: string[]; related: string[]; body: string }>();
  for (const file of files) {
    const title = path.basename(file, ".md");
    const key = norm(title);
    if (nodes.has(key)) continue; // first wins on dup titles
    const content = fs.readFileSync(file, "utf-8");
    const { fm, body } = splitFrontmatter(content);
    nodes.set(key, {
      title, key,
      summary: scalarField(fm, "summary"),
      maturity: scalarField(fm, "maturity"),
      categories: wikilinkField(fm, "categories"),
      path: file,
    });
    raw.set(key, { categories: wikilinkField(fm, "categories"), related: wikilinkField(fm, "related"), body });
  }

  const ensure = (k: string) => { if (!adj.has(k)) adj.set(k, []); };
  const addEdge = (fromKey: string, toTitle: string, type: EdgeType, weight: number) => {
    const toKey = norm(toTitle);
    if (!nodes.has(toKey) || toKey === fromKey) return;
    const e: Edge = { from: fromKey, to: toKey, type, weight };
    edges.push(e); ensure(fromKey); adj.get(fromKey)!.push(e);
  };

  // Phase 2 — edges
  for (const [key, r] of raw) {
    for (const c of r.categories) addEdge(key, c, "category", 4);
    for (const rel of r.related) addEdge(key, rel, "related", 5);
    for (const w of wikilinksIn(r.body)) addEdge(key, w, "wikilink", 3);
  }
  return { nodes, edges, adj };
}

// ── Helpers ─────────────────────────────────────────────────────────────────
function resolve(g: Graph, q: string): string | null {
  const k = norm(q);
  if (g.nodes.has(k)) return k;
  const cands = [...g.nodes.keys()].filter((s) => s.includes(k));
  if (cands.length) return cands.sort((a, b) => a.length - b.length)[0];
  return null;
}

function neighbours(g: Graph, key: string): Map<string, Edge> {
  const best = new Map<string, Edge>();
  const consider = (e: Edge, other: string) => {
    const cur = best.get(other);
    if (!cur || e.weight > cur.weight) best.set(other, e);
  };
  for (const e of g.adj.get(key) || []) consider(e, e.to);
  for (const e of g.edges) if (e.to === key) consider({ ...e, to: e.from }, e.from);
  return best;
}

function degreeMap(g: Graph): Map<string, Set<string>> {
  const d = new Map<string, Set<string>>();
  const link = (a: string, b: string) => { if (!d.has(a)) d.set(a, new Set()); d.get(a)!.add(b); };
  for (const e of g.edges) { link(e.from, e.to); link(e.to, e.from); }
  return d;
}

const tokenize = (s: string) => (s.toLowerCase().match(/[a-z0-9]+/g) || []).filter((t) => t.length > 2);

// ── Commands ────────────────────────────────────────────────────────────────
function cmdStats(): void {
  const g = buildGraph();
  const et: Record<string, number> = { category: 0, related: 0, wikilink: 0 };
  for (const e of g.edges) et[e.type]++;
  const deg = degreeMap(g);
  const isolated = [...g.nodes.keys()].filter((k) => !deg.has(k));
  const avg = (([...deg.values()].reduce((a, s) => a + s.size, 0)) / Math.max(g.nodes.size, 1)).toFixed(1);
  const hubs = [...deg.entries()].map(([k, s]) => ({ k, n: s.size })).sort((a, b) => b.n - a.n).slice(0, 8);
  const cat = new Map<string, number>();
  for (const n of g.nodes.values()) for (const c of n.categories) cat.set(c, (cat.get(c) || 0) + 1);
  const topCats = [...cat.entries()].sort((a, b) => b[1] - a[1]).slice(0, 10);

  console.log(`\n📊 Knowledge Graph — ${ROOT}`);
  console.log("─".repeat(60));
  console.log(`  Nodes: ${g.nodes.size}`);
  console.log(`  Edges: ${g.edges.length} (category:${et.category}, related:${et.related}, wikilink:${et.wikilink})`);
  console.log(`  Avg connections/node: ${avg}`);
  console.log(`  Isolated notes: ${isolated.length}`);
  console.log(`\n  Top hubs:`);
  for (const h of hubs) console.log(`    ${g.nodes.get(h.k)!.title} — ${h.n} connections`);
  console.log(`\n  Top categories:`);
  for (const [c, n] of topCats) console.log(`    ${c} — ${n} notes`);
  console.log("─".repeat(60));
}

function cmdHubs(top: number): void {
  const g = buildGraph();
  const deg = degreeMap(g);
  const ranked = [...deg.entries()].map(([k, s]) => ({ k, n: s.size })).sort((a, b) => b.n - a.n).slice(0, top);
  console.log(`\n🔗 Top ${top} hubs`);
  console.log("─".repeat(60));
  ranked.forEach((h, i) => console.log(`  ${String(i + 1).padStart(2)}. ${g.nodes.get(h.k)!.title} (${h.n})`));
  console.log("─".repeat(60));
}

function cmdRelated(query: string): void {
  const g = buildGraph();
  const key = resolve(g, query);
  if (!key) { console.error(`Not found: "${query}"`); process.exit(1); }
  const node = g.nodes.get(key)!;
  const nb = neighbours(g, key);
  console.log(`\n🔗 Related to "${node.title}"`);
  console.log("─".repeat(60));
  if (node.categories.length) console.log(`  Categories: ${node.categories.join(", ")}`);
  const byType: Record<string, string[]> = { related: [], category: [], wikilink: [] };
  for (const [k, e] of nb) byType[e.type].push(g.nodes.get(k)!.title);
  for (const t of ["related", "category", "wikilink"] as const) {
    if (byType[t].length) console.log(`\n  ${t}:\n    ${byType[t].sort().join("\n    ")}`);
  }
  console.log("─".repeat(60));
  console.log(`  ${nb.size} direct connections`);
}

function cmdTraverse(query: string, hops: number): void {
  const g = buildGraph();
  const start = resolve(g, query);
  if (!start) { console.error(`Not found: "${query}"`); process.exit(1); }
  const visited = new Set([start]);
  const byHop = new Map<number, string[]>();
  let frontier = [start];
  for (let h = 1; h <= hops; h++) {
    const next: string[] = [];
    for (const k of frontier) for (const [to] of neighbours(g, k)) {
      if (!visited.has(to)) { visited.add(to); next.push(to); (byHop.get(h) || byHop.set(h, []).get(h)!).push(to); }
    }
    frontier = next;
  }
  console.log(`\n🗺️  Traverse from "${g.nodes.get(start)!.title}" (${hops} hops)`);
  console.log("─".repeat(60));
  for (let h = 1; h <= hops; h++) {
    const ns = byHop.get(h) || [];
    if (ns.length) console.log(`\n  Hop ${h} (${ns.length}):\n    ${ns.map((k) => g.nodes.get(k)!.title).sort().join("\n    ")}`);
  }
  console.log("─".repeat(60));
  console.log(`  ${visited.size - 1} notes reached`);
}

function cmdFind(category: string): void {
  const g = buildGraph();
  const q = norm(category);
  const hits = [...g.nodes.values()].filter((n) => n.categories.some((c) => norm(c).includes(q)));
  console.log(`\n🏷️  Notes in category "${category}"`);
  console.log("─".repeat(60));
  hits.sort((a, b) => a.title.localeCompare(b.title)).forEach((n) => console.log(`  ${n.title}`));
  console.log("─".repeat(60));
  console.log(`  ${hits.length} notes`);
}

function cmdRetrieve(query: string, top: number, raw: boolean): void {
  const g = buildGraph();
  const qTerms = [...new Set(tokenize(query))];
  const N = g.nodes.size;
  // df per term
  const df = new Map<string, number>();
  const docTokens = new Map<string, string[]>();
  for (const n of g.nodes.values()) {
    const text = `${n.title} ${n.title} ${n.summary} ${n.categories.join(" ")}`; // title weighted
    const toks = tokenize(text);
    docTokens.set(n.key, toks);
    for (const t of new Set(toks)) if (qTerms.includes(t)) df.set(t, (df.get(t) || 0) + 1);
  }
  const scored = [...g.nodes.values()].map((n) => {
    const toks = docTokens.get(n.key)!;
    let score = 0;
    for (const t of qTerms) {
      const tf = toks.filter((x) => x === t).length;
      if (tf === 0) continue;
      const idf = Math.log(1 + N / ((df.get(t) || 0) + 1));
      score += (tf / (tf + 1.5)) * idf; // BM25-lite saturation
    }
    return { n, score };
  }).filter((x) => x.score > 0).sort((a, b) => b.score - a.score).slice(0, top);

  console.log(`\n📥 Retrieve: "${query}" (top ${top})`);
  console.log("─".repeat(60));
  if (!scored.length) { console.log("  No matches."); return; }
  for (const { n, score } of scored) {
    console.log(`\n  • ${n.title}  [${score.toFixed(2)}]${n.maturity ? "  " + n.maturity : ""}`);
    if (raw) {
      const body = splitFrontmatter(fs.readFileSync(n.path, "utf-8")).body.replace(/\n+/g, " ").trim();
      console.log(`    ${body.slice(0, 240)}…`);
    } else if (n.summary) {
      console.log(`    ${n.summary}`);
    }
  }
  console.log("\n" + "─".repeat(60));
}

function cmdContradictions(top: number): void {
  const g = buildGraph();
  // candidate pairs = notes sharing ≥2 categories OR a related+shared category; rank by overlap
  const byCat = new Map<string, string[]>();
  for (const n of g.nodes.values()) for (const c of n.categories) {
    const ck = norm(c); if (!byCat.has(ck)) byCat.set(ck, []); byCat.get(ck)!.push(n.key);
  }
  const pairOverlap = new Map<string, number>();
  for (const members of byCat.values()) {
    if (members.length < 2 || members.length > 60) continue; // skip huge generic cats
    for (let i = 0; i < members.length; i++) for (let j = i + 1; j < members.length; j++) {
      const [a, b] = [members[i], members[j]].sort();
      const key = `${a}|||${b}`;
      pairOverlap.set(key, (pairOverlap.get(key) || 0) + 1);
    }
  }
  const ranked = [...pairOverlap.entries()].filter(([, n]) => n >= 2).sort((a, b) => b[1] - a[1]).slice(0, top);
  console.log(`\n🔍 Contradiction candidates (high category overlap — review semantically)`);
  console.log("─".repeat(60));
  if (!ranked.length) { console.log("  No high-overlap pairs found."); return; }
  for (const [key, n] of ranked) {
    const [a, b] = key.split("|||");
    console.log(`  ${n} shared · "${g.nodes.get(a)!.title}"  ⇄  "${g.nodes.get(b)!.title}"`);
  }
  console.log("─".repeat(60));
  console.log(`  ${ranked.length} candidate pairs — read both and check for conflicting claims.`);
}

// ── CLI ─────────────────────────────────────────────────────────────────────
const { values, positionals } = parseArgs({
  args: process.argv.slice(2),
  options: { hops: { type: "string" }, top: { type: "string" }, raw: { type: "boolean" } },
  allowPositionals: true, strict: false,
});
const cmd = positionals[0];
const top = values.top ? parseInt(values.top as string) : 10;

switch (cmd) {
  case "stats": cmdStats(); break;
  case "hubs": cmdHubs(top); break;
  case "related": cmdRelated(positionals[1] || ""); break;
  case "traverse": cmdTraverse(positionals[1] || "", values.hops ? parseInt(values.hops as string) : 2); break;
  case "find": cmdFind(positionals[1] || ""); break;
  case "retrieve": cmdRetrieve(positionals.slice(1).join(" "), top, !!values.raw); break;
  case "contradictions": cmdContradictions(top); break;
  default:
    console.log("Commands: stats | hubs | related <title> | traverse <title> [--hops N] | find <category> | retrieve <query> [--top N] [--raw] | contradictions [--top N]");
    console.log(`Root: ${ROOT}`);
}
