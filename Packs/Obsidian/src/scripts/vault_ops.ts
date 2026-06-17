import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

type PropertySetArgs = { command: "property-set"; property: string; value: string; folder: string | null; filter: string | null };
type PropertyRemoveArgs = { command: "property-remove"; property: string; folder: string | null };
type PropertyStatsArgs = { command: "property-stats"; folder: string | null };
type LinkGraphArgs = { command: "link-graph"; folder: string | null; format: "dot" | "json" };
type StructureCheckArgs = { command: "structure-check"; expected: string | null };
type FrontmatterFixArgs = { command: "frontmatter-fix"; folder: string | null; dryRun: boolean };
type Args = PropertySetArgs | PropertyRemoveArgs | PropertyStatsArgs | LinkGraphArgs | StructureCheckArgs | FrontmatterFixArgs;

const IGNORE_DIRS = new Set([".obsidian", ".git", ".archive", ".trash", ".claude", ".vscode", ".docs", "node_modules"]);

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

function decodeUtf8Ignore(bytes: Uint8Array): string {
  let out = "";
  for (let i = 0; i < bytes.length;) {
    const b1 = bytes[i]!;
    if (b1 < 0x80) {
      out += String.fromCharCode(b1);
      i += 1;
    } else if (b1 >= 0xc2 && b1 <= 0xdf && i + 1 < bytes.length && (bytes[i + 1]! & 0xc0) === 0x80) {
      out += String.fromCodePoint(((b1 & 0x1f) << 6) | (bytes[i + 1]! & 0x3f));
      i += 2;
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

loadEnv();

const VAULT_ROOT = process.env.OBSIDIAN_VAULT_PATH ?? "";

function relPath(full: string): string {
  return path.relative(VAULT_ROOT, full).split(path.sep).join("/");
}

function iterNotes(folder: string | null = null): string[] {
  const root = folder ? path.join(VAULT_ROOT, folder) : VAULT_ROOT;
  const notes: string[] = [];
  function visit(dir: string): void {
    let entries: fs.Dirent[];
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        visit(full);
      } else if (entry.isFile() && entry.name.endsWith(".md")) {
        const parts = relPath(full).split("/");
        if (parts.some((part) => IGNORE_DIRS.has(part))) continue;
        notes.push(full);
      }
    }
  }
  visit(root);
  return notes.sort();
}

function parseFrontmatterRaw(filePath: string): [string | null, string | null, string | null] {
  const text = readTextIgnore(filePath);
  if (!text.startsWith("---")) return [null, null, text];
  const end = text.indexOf("\n---", 3);
  if (end === -1) return [null, null, text];
  const pre = "---\n";
  const fm = text.slice(4, end);
  const post = text.slice(end + 4);
  return [pre, fm, post];
}

function writeFrontmatter(filePath: string, pre: string, fm: string, post: string): void {
  fs.writeFileSync(filePath, pre + fm + "\n---" + post, "utf8");
}

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function cmdPropertySet(args: PropertySetArgs): void {
  const notes = iterNotes(args.folder);
  const prop = args.property;
  const value = args.value;
  let updated = 0;
  let skipped = 0;

  for (const note of notes) {
    let [pre, fm, post] = parseFrontmatterRaw(note);
    if (fm === null) {
      const pathContent = post ?? "";
      fs.writeFileSync(note, `---\n${prop}: ${value}\n---\n${pathContent}`, "utf8");
      updated += 1;
      continue;
    }

    if (args.filter) {
      const idx = args.filter.indexOf("=");
      const fkey = idx === -1 ? args.filter : args.filter.slice(0, idx);
      const fval = idx === -1 ? "" : args.filter.slice(idx + 1);
      const pattern = new RegExp(`^${escapeRegExp(fkey.trim())}:\\s*${escapeRegExp(fval.trim())}`, "m");
      if (!pattern.test(fm)) {
        skipped += 1;
        continue;
      }
    }

    const propPattern = new RegExp(`^${escapeRegExp(prop)}:.*$`, "m");
    if (propPattern.test(fm)) {
      fm = fm.replace(propPattern, `${prop}: ${value}`);
    } else {
      fm = fm.replace(/\n+$/g, "") + `\n${prop}: ${value}`;
    }
    writeFrontmatter(note, pre!, fm, post!);
    updated += 1;
  }

  console.log(`Updated: ${updated}, Skipped: ${skipped}`);
}

function cmdPropertyRemove(args: PropertyRemoveArgs): void {
  const notes = iterNotes(args.folder);
  const prop = args.property;
  let removed = 0;
  for (const note of notes) {
    const [pre, fm, post] = parseFrontmatterRaw(note);
    if (fm === null) continue;
    const propPattern = new RegExp(`^${escapeRegExp(prop)}:.*\\n?`, "gm");
    const newFm = fm.replace(propPattern, "");
    if (newFm !== fm) {
      writeFrontmatter(note, pre!, newFm, post!);
      removed += 1;
    }
  }
  console.log(`Removed '${prop}' from ${removed} notes`);
}

function increment(map: Map<string, number>, key: string): void {
  map.set(key, (map.get(key) ?? 0) + 1);
}

function mostCommon(map: Map<string, number>, limit: number): Array<[string, number]> {
  return [...map.entries()].sort((a, b) => b[1] - a[1]).slice(0, limit);
}

function cmdPropertyStats(args: PropertyStatsArgs): void {
  const notes = iterNotes(args.folder);
  const propCounts = new Map<string, number>();
  const propValues = new Map<string, Map<string, number>>();
  let total = 0;

  for (const note of notes) {
    const [_pre, fm, _post] = parseFrontmatterRaw(note);
    if (fm === null) continue;
    total += 1;
    for (const line of fm.split("\n")) {
      if (line.includes(":") && !line.startsWith(" ") && !line.startsWith("-")) {
        const idx = line.indexOf(":");
        const key = line.slice(0, idx).trim();
        let val = line.slice(idx + 1).trim();
        val = stripChars(stripChars(val, "\""), "'");
        increment(propCounts, key);
        if (val && val !== "[]") {
          const values = propValues.get(key) ?? new Map<string, number>();
          increment(values, val);
          propValues.set(key, values);
        }
      }
    }
  }

  console.log(`\nProperty stats (${total} notes in ${args.folder ?? "vault"}):`);
  console.log(`${"Property".padEnd(25, " ")} ${"Count".padStart(6, " ")} ${"Coverage".padStart(8, " ")}  Top values`);
  console.log("-".repeat(80));
  for (const [prop, count] of mostCommon(propCounts, 20)) {
    const coverage = total ? `${(count / total * 100).toFixed(0)}%` : "0%";
    const values = propValues.get(prop);
    const top = values ? mostCommon(values, 3) : [];
    const topStr = top.length ? top.map(([value, valueCount]) => `${value}(${valueCount})`).join(", ") : "(empty)";
    console.log(`  ${prop.padEnd(23, " ")} ${String(count).padStart(6, " ")} ${coverage.padStart(8, " ")}  ${topStr.slice(0, 50)}`);
  }
}

function stripChars(value: string, char: string): string {
  let start = 0;
  let end = value.length;
  while (start < end && value[start] === char) start += 1;
  while (end > start && value[end - 1] === char) end -= 1;
  return value.slice(start, end);
}

function asciiJson(value: unknown): string {
  return JSON.stringify(value, null, 2).replace(/[^\x00-\x7F]/g, (char) => {
    const code = char.charCodeAt(0);
    return `\\u${code.toString(16).padStart(4, "0")}`;
  });
}

function cmdLinkGraph(args: LinkGraphArgs): void {
  const notes = iterNotes(args.folder);
  const stemToPath = new Map<string, string>();
  const edges: Array<[string, string]> = [];

  for (const note of notes) {
    stemToPath.set(path.basename(note, path.extname(note)), relPath(note));
  }

  for (const note of notes) {
    const rel = relPath(note);
    let text: string;
    try {
      text = readTextIgnore(note);
    } catch {
      continue;
    }
    for (const match of text.matchAll(/\[\[([^\]|]+)(?:\|[^\]]+)?\]\]/g)) {
      const target = match[1]!.trim();
      const dst = stemToPath.get(target);
      if (dst) edges.push([rel, dst]);
    }
  }

  if (args.format === "dot") {
    console.log("digraph vault {");
    console.log("  rankdir=LR;");
    const seenNodes = new Set<string>();
    for (const [src, dst] of edges) {
      for (const node of [src, dst]) {
        if (!seenNodes.has(node)) {
          const label = path.posix.basename(node, path.posix.extname(node));
          console.log(`  "${node}" [label="${label}"];`);
          seenNodes.add(node);
        }
      }
      console.log(`  "${src}" -> "${dst}";`);
    }
    console.log("}");
  } else {
    const graph = { nodes: [...stemToPath.values()], edges: edges.map(([from, to]) => ({ from, to })) };
    console.log(asciiJson(graph));
  }

  console.error(`\n# ${stemToPath.size} nodes, ${edges.length} edges`);
}

function cmdStructureCheck(args: StructureCheckArgs): void {
  const vault = VAULT_ROOT;
  const issues: string[] = [];
  const expected = args.expected ? new Set(args.expected.split(",")) : new Set<string>();
  const actual = new Set(
    fs.readdirSync(vault, { withFileTypes: true })
      .filter((entry) => entry.isDirectory() && !entry.name.startsWith("."))
      .map((entry) => entry.name),
  );

  if (expected.size) {
    const missing = [...expected].filter((entry) => !actual.has(entry)).sort();
    const extra = [...actual].filter((entry) => !expected.has(entry)).sort();
    if (missing.length) issues.push(`Missing expected folders: ${missing.join(", ")}`);
    if (extra.length) issues.push(`Extra top-level folders: ${extra.join(", ")}`);
  }

  const rootFiles = fs.readdirSync(vault, { withFileTypes: true })
    .filter((entry) => entry.isFile() && !entry.name.startsWith("."))
    .map((entry) => entry.name);
  if (rootFiles.length) issues.push(`Loose files at root: ${rootFiles.join(", ")}`);

  for (const folderName of ["Knowledge", "Projects"]) {
    const folder = path.join(vault, folderName);
    if (fs.existsSync(folder)) {
      let noFm = 0;
      for (const entry of fs.readdirSync(folder, { withFileTypes: true })) {
        if (entry.isFile() && entry.name.endsWith(".md")) {
          const text = readTextIgnore(path.join(folder, entry.name));
          if (!text.startsWith("---")) noFm += 1;
        }
      }
      if (noFm) issues.push(`${folderName}: ${noFm} notes without frontmatter`);
    }
  }

  for (const dir of walkDirs(vault)) {
    if (dir === vault) continue;
    const parts = path.relative(vault, dir).split(path.sep);
    if (parts.some((part) => IGNORE_DIRS.has(part))) continue;
    if (!fs.readdirSync(dir).length) issues.push(`Empty folder: ${path.relative(vault, dir).split(path.sep).join("/")}`);
  }

  for (const obs of walkDirs(vault).filter((dir) => path.basename(dir) === ".obsidian")) {
    if (path.dirname(obs) !== vault) issues.push(`Nested .obsidian config: ${path.relative(vault, obs).split(path.sep).join("/")}`);
  }

  if (issues.length) {
    console.log(`Found ${issues.length} issues:`);
    for (const issue of issues) console.log(`  - ${issue}`);
  } else {
    console.log("Vault structure OK");
  }
}

function walkDirs(root: string): string[] {
  const dirs: string[] = [];
  function visit(dir: string): void {
    dirs.push(dir);
    let entries: fs.Dirent[];
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries) {
      if (entry.isDirectory()) visit(path.join(dir, entry.name));
    }
  }
  visit(root);
  return dirs.sort();
}

function cmdFrontmatterFix(args: FrontmatterFixArgs): void {
  const notes = iterNotes(args.folder);
  const issues: Array<[string, string]> = [];
  for (const note of notes) {
    const rel = relPath(note);
    const text = readTextIgnore(note);
    if (!text.startsWith("---")) {
      if (text.trim().startsWith("---")) issues.push([rel, "frontmatter preceded by whitespace"]);
      else if (text.slice(0, 200).includes("---")) issues.push([rel, "frontmatter not on line 1"]);
      else issues.push([rel, "no frontmatter"]);
      continue;
    }

    const end = text.indexOf("\n---", 3);
    if (end === -1) {
      issues.push([rel, "unclosed frontmatter (no closing ---)"]);
      if (!args.dryRun) {
        const lines = text.split("\n");
        let yamlEnd = 1;
        for (let i = 1; i < lines.length; i += 1) {
          const line = lines[i]!;
          if (/^(\w[\w\s-]*:.*|\s+-\s+.*|\s+.*|\s*)$/.test(line)) yamlEnd = i + 1;
          else break;
        }
        lines.splice(yamlEnd, 0, "---");
        fs.writeFileSync(note, lines.join("\n"), "utf8");
        issues[issues.length - 1] = [rel, "unclosed frontmatter — FIXED"];
      }
    }
  }

  if (issues.length) {
    console.log(`Found ${issues.length} frontmatter issues:`);
    for (const [rel, issue] of issues) console.log(`  ${rel}: ${issue}`);
  } else {
    console.log("All frontmatter OK");
  }
}

function parserError(message: string): never {
  console.error(`vault_ops.ts: error: ${message}`);
  process.exit(2);
}

function optionValue(argv: string[], index: number, option: string): string {
  const value = argv[index + 1];
  if (value === undefined) parserError(`argument ${option}: expected one argument`);
  return value;
}

function parseOptions(argv: string[], allowedValueOptions: Set<string>, allowedBooleans = new Set<string>()): { options: Map<string, string | boolean>; positionals: string[] } {
  const options = new Map<string, string | boolean>();
  const positionals: string[] = [];
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i]!;
    if (token.startsWith("--")) {
      if (allowedBooleans.has(token)) {
        options.set(token, true);
      } else if (allowedValueOptions.has(token)) {
        options.set(token, optionValue(argv, i, token));
        i += 1;
      } else {
        parserError(`unrecognized arguments: ${token}`);
      }
    } else {
      positionals.push(token);
    }
  }
  return { options, positionals };
}

function parseArgs(argv: string[]): Args {
  const command = argv[0];
  if (!command) parserError("the following arguments are required: command");
  const rest = argv.slice(1);
  switch (command) {
    case "property-set": {
      const { options, positionals } = parseOptions(rest, new Set(["--folder", "--filter"]));
      if (positionals.length < 2) parserError("the following arguments are required: property, value");
      if (positionals.length > 2) parserError(`unrecognized arguments: ${positionals.slice(2).join(" ")}`);
      return {
        command,
        property: positionals[0]!,
        value: positionals[1]!,
        folder: (options.get("--folder") as string | undefined) ?? null,
        filter: (options.get("--filter") as string | undefined) ?? null,
      };
    }
    case "property-remove": {
      const { options, positionals } = parseOptions(rest, new Set(["--folder"]));
      if (!positionals[0]) parserError("the following arguments are required: property");
      if (positionals.length > 1) parserError(`unrecognized arguments: ${positionals.slice(1).join(" ")}`);
      return { command, property: positionals[0], folder: (options.get("--folder") as string | undefined) ?? null };
    }
    case "property-stats": {
      const { options, positionals } = parseOptions(rest, new Set(["--folder"]));
      if (positionals.length) parserError(`unrecognized arguments: ${positionals.join(" ")}`);
      return { command, folder: (options.get("--folder") as string | undefined) ?? null };
    }
    case "link-graph": {
      const { options, positionals } = parseOptions(rest, new Set(["--folder", "--format"]));
      if (positionals.length) parserError(`unrecognized arguments: ${positionals.join(" ")}`);
      const format = (options.get("--format") ?? "json") as string;
      if (!["dot", "json"].includes(format)) parserError(`argument --format: invalid choice: '${format}' (choose from 'dot', 'json')`);
      return { command, folder: (options.get("--folder") as string | undefined) ?? null, format: format as "dot" | "json" };
    }
    case "structure-check": {
      const { options, positionals } = parseOptions(rest, new Set(["--expected"]));
      if (positionals.length) parserError(`unrecognized arguments: ${positionals.join(" ")}`);
      return { command, expected: (options.get("--expected") as string | undefined) ?? null };
    }
    case "frontmatter-fix": {
      const { options, positionals } = parseOptions(rest, new Set(["--folder"]), new Set(["--dry-run"]));
      if (positionals.length) parserError(`unrecognized arguments: ${positionals.join(" ")}`);
      return { command, folder: (options.get("--folder") as string | undefined) ?? null, dryRun: options.get("--dry-run") === true };
    }
    default:
      parserError(`argument command: invalid choice: '${command}' (choose from 'property-set', 'property-remove', 'property-stats', 'link-graph', 'structure-check', 'frontmatter-fix')`);
  }
}

export function main(): void {
  const args = parseArgs(Bun.argv.slice(2));
  switch (args.command) {
    case "property-set":
      cmdPropertySet(args);
      break;
    case "property-remove":
      cmdPropertyRemove(args);
      break;
    case "property-stats":
      cmdPropertyStats(args);
      break;
    case "link-graph":
      cmdLinkGraph(args);
      break;
    case "structure-check":
      cmdStructureCheck(args);
      break;
    case "frontmatter-fix":
      cmdFrontmatterFix(args);
      break;
  }
}

if (import.meta.main) main();
