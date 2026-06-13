#!/usr/bin/env bun
/**
 * verify-claims — check that a document's references actually exist in code.
 *
 * Pulls every concrete reference a Markdown doc makes — `path/to/file.ext` and
 * `Identifier` names — and confirms each resolves against a real source tree.
 * Reports an accuracy score and lists the references that don't resolve (the
 * things a generative pass tends to invent). Pure Bun, no deps, read-only.
 *
 * Verification strategy: one pass over the source tree builds (a) a set of
 * relative paths, (b) a filename index, and (c) a set of every identifier token
 * found in source — so path and symbol checks are O(1) set lookups rather than
 * re-grepping per claim.
 *
 *   bun verify-claims.ts <doc.md | dir> [--source DIR] [--ext .ts,.py]
 *                        [--samples N] [--min PCT]
 */
import { Glob } from "bun";
import { readFileSync, existsSync, statSync } from "node:fs";
import { resolve, basename } from "node:path";

const IGNORE =
  /(^|\/)(\.git|node_modules|\.venv|venv|__pycache__|dist|build|\.next|target|vendor|\.cache|graphify-out|\.idea|\.vscode|coverage)(\/|$)/;
const DEFAULT_EXTS = "ts tsx js jsx py go rs java rb c cc cpp h hpp cs kt scala php swift lua sh sql proto vue svelte".split(" ");
const STOP = new Set(
  "the this that with from should could would might true false none null void api url http https json xml yaml csv sql todo unknown unclear legacy custom various multiple several deprecated".split(" "),
);

type Claim = { kind: "path" | "name"; text: string; line: number; doc: string };

function arg(flag: string, def = ""): string {
  const i = Bun.argv.indexOf(flag);
  return i > -1 && Bun.argv[i + 1] ? Bun.argv[i + 1] : def;
}

function indexSource(root: string, exts: Set<string>) {
  const paths = new Set<string>();
  const byName = new Map<string, string[]>();
  const idents = new Set<string>();
  let budget = 200_000_000;
  for (const rel of new Glob("**/*").scanSync({ cwd: root, onlyFiles: true })) {
    const norm = rel.replaceAll("\\", "/");
    if (IGNORE.test("/" + norm)) continue;
    if (!exts.has(norm.split(".").pop()!.toLowerCase())) continue;
    paths.add(norm);
    const fn = basename(norm).toLowerCase();
    const list = byName.get(fn) ?? [];
    list.push(norm);
    byName.set(fn, list);
    if (budget > 0) {
      try {
        const txt = readFileSync(resolve(root, rel), "utf8");
        budget -= txt.length;
        for (const tok of txt.match(/[A-Za-z_][A-Za-z0-9_]{2,}/g) ?? []) idents.add(tok);
      } catch {
        /* unreadable — skip content, keep path */
      }
    }
  }
  return { paths, byName, idents };
}

function resolvesAsPath(value: string, idx: ReturnType<typeof indexSource>): boolean {
  const clean = value.replace(/:\d+(-\d+)?$/, "").replace(/\s*\(.*\)\s*$/, "").trim();
  if (!clean) return false;
  const low = clean.toLowerCase();
  if (idx.paths.has(clean)) return true;
  for (const p of idx.paths) if (p.toLowerCase() === low) return true;
  const fn = clean.split("/").pop()!.toLowerCase();
  for (const p of idx.paths) {
    const pl = p.toLowerCase();
    if (pl.endsWith(low) || pl.endsWith("/" + fn)) return true;
  }
  return false;
}

function resolvesAsName(value: string, idx: ReturnType<typeof indexSource>): boolean {
  if (idx.idents.has(value)) return true;
  const low = value.toLowerCase();
  for (const p of idx.paths) if (p.toLowerCase().includes(low)) return true;
  return false;
}

function extractClaims(doc: string, name: string): Claim[] {
  const text = readFileSync(doc, "utf8");
  const lineAt = (i: number) => text.slice(0, i).split("\n").length;
  const out: Claim[] = [];
  const seen = new Set<string>();
  const push = (kind: Claim["kind"], text2: string, i: number) => {
    const key = kind + ":" + text2;
    if (!seen.has(key)) {
      seen.add(key);
      out.push({ kind, text: text2, line: lineAt(i), doc: name });
    }
  };
  for (const m of text.matchAll(/`([^`]+)`/g)) {
    const body = m[1].trim();
    const isPathish = body.includes("/") && /\.\w{1,6}(:\d+(-\d+)?)?$/.test(body) && !/[*?\[]/.test(body);
    if (isPathish) {
      push("path", body, m.index!);
      continue;
    }
    const fnCall = body.match(/^([A-Za-z_]\w{2,})\(\)?$/);
    const tok = (fnCall?.[1] ?? body).trim();
    const looksSymbol =
      /^[A-Za-z_]\w{2,}$/.test(tok) &&
      (fnCall ||
        /(?:Controller|Service|Repository|Manager|Handler|Factory|Model|Entity|Dto|Component|Provider|Store|Hook)$/.test(tok) ||
        (/^[A-Z]/.test(tok) && /[a-z]/.test(tok) && /[A-Z]/.test(tok.slice(1))));
    if (looksSymbol && !STOP.has(tok.toLowerCase())) push("name", tok, m.index!);
  }
  for (const m of text.matchAll(/(?:depends on|calls|imports|references|uses)\s+`?([A-Za-z_]\w{2,})`?/gi)) {
    if (!STOP.has(m[1].toLowerCase())) push("name", m[1], m.index!);
  }
  return out;
}

function main(): number {
  const target = Bun.argv[2];
  if (!target || target.startsWith("--")) {
    console.error("usage: bun verify-claims.ts <doc.md|dir> [--source DIR] [--ext .ts,.py] [--samples N] [--min PCT]");
    return 2;
  }
  const sourceRoot = resolve(arg("--source", "."));
  const samples = Number(arg("--samples", "50"));
  const min = Number(arg("--min", "80"));
  const extArg = arg("--ext", "");
  const exts = new Set((extArg ? extArg.split(",") : DEFAULT_EXTS).map((e) => e.replace(/^\./, "").toLowerCase()));

  // resolve docs: a directory → every *.md under it; a file → just that file
  const st = existsSync(target) ? statSync(target) : null;
  let docList = st?.isDirectory()
    ? [...new Glob("**/*.md").scanSync({ cwd: target, onlyFiles: true })].map((p) => resolve(target, p))
    : [resolve(target)];
  docList = docList.filter(existsSync);
  if (!docList.length) {
    console.error("ERROR: no doc(s) found at", target);
    return 1;
  }

  const claims = docList.flatMap((d) => extractClaims(d, basename(d)));
  if (!claims.length) {
    console.log("WARNING: no verifiable references found — the doc may be too abstract to check (it should cite concrete `path/file.ext` and `Identifier` names).");
    return 0;
  }

  process.stderr.write("Indexing source...\n");
  const idx = indexSource(sourceRoot, exts);
  process.stderr.write(`  ${idx.paths.size} files, ${idx.idents.size} identifiers.\n`);

  let pool = claims;
  if (claims.length > samples) {
    // deterministic stride sample (seedless, reproducible)
    const step = claims.length / samples;
    pool = Array.from({ length: samples }, (_, i) => claims[Math.floor(i * step)]);
  }

  const failed: Claim[] = [];
  let ok = 0;
  for (const c of pool) {
    const good = c.kind === "path" ? resolvesAsPath(c.text, idx) : resolvesAsName(c.text, idx);
    good ? ok++ : failed.push(c);
  }
  const acc = pool.length ? (ok / pool.length) * 100 : 0;

  console.log("# Claim Verification Report\n");
  console.log(`- **Source**: ${basename(sourceRoot)}`);
  console.log(`- **Checked**: ${pool.length} of ${claims.length} references`);
  console.log(`- **Verified**: ${ok}  |  **Unresolved**: ${failed.length}  |  **Accuracy**: ${acc.toFixed(1)}%\n`);
  if (failed.length) {
    console.log("## Unresolved references (likely fabricated)\n");
    const byDoc = new Map<string, Claim[]>();
    for (const c of failed) (byDoc.get(c.doc) ?? byDoc.set(c.doc, []).get(c.doc)!).push(c);
    for (const [doc, cs] of [...byDoc].sort()) {
      console.log(`### ${doc}`);
      for (const c of cs) console.log(`  - [${c.kind}] \`${c.text}\` (line ${c.line})`);
      console.log();
    }
  }
  const verdict = acc >= 95 ? "✓ reliable" : acc >= 80 ? "⚠️ review the unresolved refs" : "✗ significant fabrication — regenerate";
  console.log(`## Verdict\n${verdict} (${acc.toFixed(0)}%)`);
  return acc >= min ? 0 : 1;
}

process.exit(main());
