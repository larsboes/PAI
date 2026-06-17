import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

type SearchArgs = { command: "search"; query: string };
type BacklinksArgs = { command: "backlinks"; path: string };
type DailyArgs = { command: "daily" };
type ActiveArgs = { command: "active" };
type OpenArgs = { command: "open"; path: string };
type HealthArgs = { command: "health" };
type Args = SearchArgs | BacklinksArgs | DailyArgs | ActiveArgs | OpenArgs | HealthArgs;

const HEALTH_IGNORE_DIRS = new Set([".obsidian", ".git", "node_modules"]);
const HEALTH_IGNORE_FILES = new Set<string>();

function decodeUtf8Ignore(bytes: Uint8Array): string {
  let out = "";
  for (let i = 0; i < bytes.length;) {
    const b1 = bytes[i]!;
    if (b1 < 0x80) {
      out += String.fromCharCode(b1);
      i += 1;
    } else if (b1 >= 0xc2 && b1 <= 0xdf && i + 1 < bytes.length) {
      const b2 = bytes[i + 1]!;
      if ((b2 & 0xc0) === 0x80) {
        out += String.fromCodePoint(((b1 & 0x1f) << 6) | (b2 & 0x3f));
        i += 2;
      } else {
        i += 1;
      }
    } else if (b1 >= 0xe0 && b1 <= 0xef && i + 2 < bytes.length) {
      const b2 = bytes[i + 1]!;
      const b3 = bytes[i + 2]!;
      const valid = (b2 & 0xc0) === 0x80 && (b3 & 0xc0) === 0x80
        && !(b1 === 0xe0 && b2 < 0xa0)
        && !(b1 === 0xed && b2 >= 0xa0);
      if (valid) {
        out += String.fromCodePoint(((b1 & 0x0f) << 12) | ((b2 & 0x3f) << 6) | (b3 & 0x3f));
        i += 3;
      } else {
        i += 1;
      }
    } else if (b1 >= 0xf0 && b1 <= 0xf4 && i + 3 < bytes.length) {
      const b2 = bytes[i + 1]!;
      const b3 = bytes[i + 2]!;
      const b4 = bytes[i + 3]!;
      const valid = (b2 & 0xc0) === 0x80 && (b3 & 0xc0) === 0x80 && (b4 & 0xc0) === 0x80
        && !(b1 === 0xf0 && b2 < 0x90)
        && !(b1 === 0xf4 && b2 >= 0x90);
      if (valid) {
        out += String.fromCodePoint(((b1 & 0x07) << 18) | ((b2 & 0x3f) << 12) | ((b3 & 0x3f) << 6) | (b4 & 0x3f));
        i += 4;
      } else {
        i += 1;
      }
    } else {
      i += 1;
    }
  }
  return out;
}

function readTextIgnore(filePath: string): string {
  return decodeUtf8Ignore(fs.readFileSync(filePath));
}

function loadEnv(): void {
  const envPath = path.join(os.homedir(), ".env");
  if (!fs.existsSync(envPath)) return;
  const content = fs.readFileSync(envPath, "utf8");
  for (const rawLine of content.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#") || !line.includes("=")) continue;
    const idx = line.indexOf("=");
    const key = line.slice(0, idx).trim();
    const value = line.slice(idx + 1).trim();
    if (process.env[key] === undefined) process.env[key] = value;
  }
}

loadEnv();

const VAULT_ROOT = process.env.OBSIDIAN_VAULT_PATH ?? "";
const OBSIDIAN_BIN = process.env.OBSIDIAN_BIN ?? "";
const RG_PATH = Bun.which("rg") ?? "rg";

function requireVault(): string {
  if (!VAULT_ROOT) {
    console.error("Error: OBSIDIAN_VAULT_PATH not set in ~/.env");
    process.exit(1);
  }
  if (!fs.existsSync(VAULT_ROOT)) {
    console.error(`Error: Vault not found at ${VAULT_ROOT}`);
    process.exit(1);
  }
  return VAULT_ROOT;
}

function strip(text: string): string {
  return text.trim();
}

function runObsidianCli(args: string[]): string | null {
  if (!OBSIDIAN_BIN || !fs.existsSync(OBSIDIAN_BIN)) return null;
  try {
    const result = Bun.spawnSync([OBSIDIAN_BIN, ...args], { stdout: "pipe", stderr: "pipe" });
    const stdout = decodeUtf8Ignore(result.stdout);
    const lines = strip(stdout).split("\n");
    const clean = lines.filter((line) => !line.startsWith("202"));
    return clean.join("\n").trim();
  } catch (error) {
    console.error(`Obsidian CLI error: ${String(error)}`);
    return null;
  }
}

function walkMarkdown(root: string): string[] {
  const files: string[] = [];
  function visit(dir: string): void {
    let entries: fs.Dirent[];
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    // Sort by name for deterministic walk order. The legacy Python used
    // pathlib.rglob, whose order is filesystem-dependent — so duplicate-title
    // stem-index tie-breaks (and thus the orphan count) were non-reproducible.
    // Sorting makes the health report stable run-to-run.
    entries.sort((a, b) => (a.name < b.name ? -1 : a.name > b.name ? 1 : 0));
    for (const entry of entries) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        visit(full);
      } else if (entry.isFile() && entry.name.endsWith(".md")) {
        files.push(full);
      }
    }
  }
  visit(root);
  return files;
}

function relPath(root: string, full: string): string {
  return path.relative(root, full).split(path.sep).join("/");
}

function dirnameForRel(rel: string): string {
  const dir = path.posix.dirname(rel);
  return dir === "." ? "(root)" : dir;
}

function cmdSearch(args: SearchArgs): void {
  const vault = requireVault();
  console.log(`Searching for '${args.query}' in vault...`);
  try {
    const result = Bun.spawnSync([
      RG_PATH, "-i", "--no-heading", "--line-number",
      "--max-count", "3",
      "--glob", "!.git/*", "--glob", "!.obsidian/*",
      args.query, vault,
    ], { stdout: "pipe", stderr: "pipe" });
    const output = strip(decodeUtf8Ignore(result.stdout));
    if (!output) {
      console.log("No results found.");
      return;
    }
    const lines = output.split("\n");
    console.log(`Found ${lines.length} matches (showing top 20):`);
    for (let line of lines.slice(0, 20)) {
      if (line.startsWith(vault)) line = line.slice(vault.length + 1);
      console.log(`  ${line}`);
    }
    if (lines.length > 20) console.log(`  ... and ${lines.length - 20} more matches.`);
  } catch (error) {
    console.log(`Search failed: ${String(error)}`);
  }
}

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function cmdBacklinks(args: BacklinksArgs): void {
  const vault = requireVault();
  const basename = path.basename(args.path);
  const nameNoExt = basename.slice(0, basename.length - path.extname(basename).length);
  const pattern = String.raw`\[\[${escapeRegExp(nameNoExt)}(\|.*)?\]\]`;
  console.log(`Searching backlinks to '${nameNoExt}'...`);
  try {
    const result = Bun.spawnSync([
      RG_PATH, "-l",
      "--glob", "!.git/*", "--glob", "!.obsidian/*",
      pattern, vault,
    ], { stdout: "pipe", stderr: "pipe" });
    const output = strip(decodeUtf8Ignore(result.stdout));
    if (!output) {
      console.log("No backlinks found.");
      return;
    }
    const files = output.split("\n").filter((file) => path.basename(file) !== basename);
    console.log(`Found ${files.length} backlinks:`);
    for (let file of files) {
      if (file.startsWith(vault)) file = file.slice(vault.length + 1);
      console.log(`  - ${file}`);
    }
  } catch (error) {
    console.log(`Backlinks search failed: ${String(error)}`);
  }
}

function localIsoDate(): string {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function cmdDaily(_args: DailyArgs): void {
  const vault = requireVault();
  const pathRel = runObsidianCli(["daily", "silent"]);
  if (pathRel) {
    console.log(path.join(vault, pathRel));
    return;
  }
  const today = localIsoDate();
  const candidates = [
    `Daily Notes/${today}.md`,
    `Journal/${today}.md`,
    `Journal/Daily/${today}.md`,
  ];
  for (const candidate of candidates) {
    const full = path.join(vault, candidate);
    if (fs.existsSync(full)) {
      console.log(full);
      return;
    }
  }
  console.log(`${vault}/Daily Notes/${today}.md`);
}

function cmdActive(_args: ActiveArgs): void {
  requireVault();
  const output = runObsidianCli(["file"]);
  if (!output) {
    console.log("Could not get active file (Obsidian might not be running or OBSIDIAN_BIN not set).");
    return;
  }
  const data: Record<string, string> = {};
  for (const line of output.split("\n")) {
    const idx = line.indexOf("\t");
    if (idx !== -1) data[line.slice(0, idx).trim()] = line.slice(idx + 1).trim();
  }
  if (data.path !== undefined) {
    console.log(`Active file: ${data.path}`);
    console.log(`Full path:   ${path.join(VAULT_ROOT, data.path)}`);
  } else {
    console.log("No active file info returned.");
  }
}

function cmdOpen(args: OpenArgs): void {
  let openPath = args.path;
  if (VAULT_ROOT && openPath.startsWith(VAULT_ROOT)) openPath = openPath.slice(VAULT_ROOT.length + 1);
  const result = runObsidianCli(["open", `path=${openPath}`]);
  if (result === null) {
    console.log("Cannot open file: OBSIDIAN_BIN not configured or not found.");
    return;
  }
  console.log(`Opened ${openPath}`);
}

function statSize(filePath: string): number {
  return fs.existsSync(filePath) ? fs.statSync(filePath).size : 0;
}

function fmtBytes(value: number): string {
  let b = Math.trunc(value);
  for (const unit of ["B", "KB", "MB", "GB"]) {
    if (b < 1024) return `${b.toFixed(1)} ${unit}`;
    b = Math.floor(b / 1024);
  }
  return `${b.toFixed(1)} TB`;
}

function cmdHealth(_args: HealthArgs): void {
  const vault = requireVault();
  const files: string[] = [];
  const duplicates = new Map<string, string[]>();
  for (const mdFile of walkMarkdown(vault)) {
    const parts = mdFile.split(path.sep);
    if (parts.some((part) => HEALTH_IGNORE_DIRS.has(part))) continue;
    if (HEALTH_IGNORE_FILES.has(path.basename(mdFile))) continue;
    const rel = relPath(vault, mdFile);
    files.push(rel);
    const stem = path.basename(mdFile, path.extname(mdFile));
    const dupFiles = duplicates.get(stem) ?? [];
    dupFiles.push(rel);
    duplicates.set(stem, dupFiles);
  }

  const fileStems = new Map<string, string>();
  const fileStrs = new Map<string, string>();
  for (const file of files) {
    fileStems.set(path.posix.basename(file, path.posix.extname(file)), file);
    fileStrs.set(file, file);
  }
  const wikilinks = new Map<string, Set<string>>();
  const references = new Map<string, Set<string>>();
  const brokenLinks: Array<[string, string]> = [];

  for (const filePath of files) {
    try {
      const content = readTextIgnore(path.join(vault, filePath));
      for (const match of content.matchAll(/\[\[([^\]]+)\]\]/g)) {
        const noteName = match[1]!.split("|")[0]!.trim();
        const outgoing = wikilinks.get(filePath) ?? new Set<string>();
        outgoing.add(noteName);
        wikilinks.set(filePath, outgoing);
        const target = fileStems.get(noteName) ?? fileStrs.get(noteName) ?? fileStrs.get(`${noteName}.md`);
        if (target) {
          const incoming = references.get(target) ?? new Set<string>();
          incoming.add(filePath);
          references.set(target, incoming);
        } else {
          brokenLinks.push([filePath, noteName]);
        }
      }
    } catch {
      // Python intentionally ignores per-file read errors in the health scan.
    }
  }

  const orphaned = files.filter((file) => !(references.get(file)?.size || wikilinks.get(file)?.size));
  const totalSize = files.reduce((sum, file) => sum + statSize(path.join(vault, file)), 0);
  const avgSize = Math.floor(totalSize / Math.max(1, files.length));
  const dirCounts = new Map<string, number>();
  for (const file of files) {
    const dir = dirnameForRel(file);
    dirCounts.set(dir, (dirCounts.get(dir) ?? 0) + 1);
  }

  console.log("\nObsidian Vault Health Report");
  console.log("=".repeat(40));
  console.log("\nStatistics");
  console.log(`  Total files: ${files.length}`);
  console.log(`  Vault size:  ${fmtBytes(totalSize)}`);
  console.log(`  Avg file:    ${fmtBytes(avgSize)}`);
  for (const [dir, count] of [...dirCounts.entries()].sort((a, b) => b[1] - a[1]).slice(0, 5)) {
    console.log(`    - ${dir}: ${count} files`);
  }

  if (orphaned.length) {
    console.log(`\n[!] Orphaned Notes (${orphaned.length} found)`);
    for (const note of [...orphaned].sort().slice(0, 10)) console.log(`  - ${note}`);
    if (orphaned.length > 10) console.log(`  ... and ${orphaned.length - 10} more`);
  } else {
    console.log("\n[OK] No orphaned notes");
  }

  if (brokenLinks.length) {
    const seen = new Set<string>();
    console.log(`\n[WARN] Broken Wikilinks (${brokenLinks.length} found)`);
    for (const [src, tgt] of brokenLinks.slice(0, 10)) {
      const key = `${src}\0${tgt}`;
      if (!seen.has(key)) {
        console.log(`  - ${src} -> [[${tgt}]]`);
        seen.add(key);
      }
    }
    if (brokenLinks.length > 10) console.log(`  ... and ${brokenLinks.length - 10} more`);
  } else {
    console.log("\n[OK] No broken wikilinks");
  }

  const dups = [...duplicates.entries()].filter(([, dupFiles]) => dupFiles.length > 1);
  if (dups.length) {
    console.log(`\n[WARN] Duplicate Titles (${dups.length} found)`);
    for (const [, dupFiles] of dups.slice(0, 5)) {
      for (const file of dupFiles) console.log(`  - ${file}`);
    }
    if (dups.length > 5) console.log(`  ... and ${dups.length - 5} more`);
  } else {
    console.log("\n[OK] No duplicate titles");
  }

  console.log("\nVault health check complete");
}

function parserError(message: string): never {
  console.error(`client.ts: error: ${message}`);
  process.exit(2);
}

function requireNoExtra(rest: string[]): void {
  if (rest.length) parserError(`unrecognized arguments: ${rest.join(" ")}`);
}

function parseArgs(argv: string[]): Args {
  const command = argv[0];
  if (!command) parserError("the following arguments are required: command");
  const rest = argv.slice(1);
  switch (command) {
    case "search":
      if (!rest[0]) parserError("the following arguments are required: query");
      requireNoExtra(rest.slice(1));
      return { command, query: rest[0] };
    case "backlinks":
      if (!rest[0]) parserError("the following arguments are required: path");
      requireNoExtra(rest.slice(1));
      return { command, path: rest[0] };
    case "daily":
      requireNoExtra(rest);
      return { command };
    case "active":
      requireNoExtra(rest);
      return { command };
    case "open":
      if (!rest[0]) parserError("the following arguments are required: path");
      requireNoExtra(rest.slice(1));
      return { command, path: rest[0] };
    case "health":
      requireNoExtra(rest);
      return { command };
    default:
      parserError(`argument command: invalid choice: '${command}' (choose from 'search', 'backlinks', 'daily', 'active', 'open', 'health')`);
  }
}

export function main(): void {
  const args = parseArgs(Bun.argv.slice(2));
  switch (args.command) {
    case "search":
      cmdSearch(args);
      break;
    case "backlinks":
      cmdBacklinks(args);
      break;
    case "daily":
      cmdDaily(args);
      break;
    case "active":
      cmdActive(args);
      break;
    case "open":
      cmdOpen(args);
      break;
    case "health":
      cmdHealth(args);
      break;
  }
}

if (import.meta.main) main();
