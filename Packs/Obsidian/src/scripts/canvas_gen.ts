import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

type FrontmatterValue = string | string[];
type Frontmatter = Record<string, FrontmatterValue>;
type NoteInfo = { path: string; name: string; frontmatter: Frontmatter };
type CanvasNode = Record<string, string | number | boolean>;
type CanvasEdge = Record<string, string>;
type Canvas = { nodes: CanvasNode[]; edges: CanvasEdge[] };

type KnowledgeMapArgs = { command: "knowledge-map"; folder: string; category: string | null; output: string | null };
type ProjectMapArgs = { command: "project-map"; output: string | null };
type FromLinksArgs = { command: "from-links"; notePath: string; depth: number; output: string | null };
type Args = KnowledgeMapArgs | ProjectMapArgs | FromLinksArgs;

const CARD_W = 300;
const CARD_H = 120;
const GAP_X = 60;
const GAP_Y = 40;
const GROUP_PAD = 40;

const KNOWLEDGE_COLORS: Record<string, string> = {
  mastered: "4",
  applied: "5",
  understood: "3",
  familiar: "2",
  reference: "1",
};

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

function uid(): string {
  return crypto.randomUUID().replaceAll("-", "").slice(0, 16);
}

function stripChars(value: string, char: string): string {
  let start = 0;
  let end = value.length;
  while (start < end && value[start] === char) start += 1;
  while (end > start && value[end - 1] === char) end -= 1;
  return value.slice(start, end);
}

function parseFrontmatter(filePath: string): Frontmatter {
  let text: string;
  try {
    text = readTextIgnore(filePath);
  } catch {
    return {};
  }
  if (!text.startsWith("---")) return {};
  const end = text.indexOf("\n---", 3);
  if (end === -1) return {};
  const fm: Frontmatter = {};
  let currentKey: string | null = null;
  let currentList: string[] | null = null;
  for (const line of text.slice(4, end).split("\n")) {
    if (!line.trim()) continue;
    if (line.startsWith("  - ") && currentKey) {
      let val = stripChars(stripChars(line.trim().slice(2).trim(), "\""), "'");
      const match = val.match(/\[\[([^\]|]+)(?:\|[^\]]+)?\]\]/);
      if (match) val = match[1]!;
      if (currentList === null) currentList = [];
      currentList.push(val);
      fm[currentKey] = currentList;
      continue;
    }
    if (line.includes(":") && !line.startsWith(" ")) {
      if (currentList !== null) currentList = null;
      const idx = line.indexOf(":");
      currentKey = line.slice(0, idx).trim();
      const val = stripChars(stripChars(line.slice(idx + 1).trim(), "\""), "'");
      if (val === "[]") fm[currentKey] = [];
      else if (val) fm[currentKey] = val;
      else fm[currentKey] = "";
    }
  }
  return fm;
}

function findNotes(folder = "Knowledge", category: string | null = null): NoteInfo[] {
  const vault = VAULT_ROOT;
  if (!fs.existsSync(vault)) {
    console.error(`Error: Vault not found at ${vault}`);
    process.exit(1);
  }
  const target = path.join(vault, folder);
  if (!fs.existsSync(target)) {
    console.error(`Error: Folder ${folder} not found`);
    process.exit(1);
  }
  const notes: NoteInfo[] = [];
  const entries = fs.readdirSync(target, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
    .map((entry) => path.join(target, entry.name))
    .sort();
  for (const md of entries) {
    const fm = parseFrontmatter(md);
    if (category) {
      let cats = fm.categories ?? [];
      if (typeof cats === "string") cats = [cats];
      if (!cats.some((cat) => cat.toLowerCase().includes(category.toLowerCase()))) continue;
    }
    notes.push({
      path: path.relative(vault, md).split(path.sep).join("/"),
      name: path.basename(md, path.extname(md)),
      frontmatter: fm,
    });
  }
  return notes;
}

function buildCanvas(nodes: CanvasNode[], edges: CanvasEdge[]): Canvas {
  return { nodes, edges };
}

function cmdKnowledgeMap(args: KnowledgeMapArgs): void {
  const notes = findNotes(args.folder, args.category);
  if (!notes.length) {
    console.log("No notes found matching criteria.");
    return;
  }

  const groups = new Map<string, NoteInfo[]>();
  for (const note of notes) {
    const cats = note.frontmatter.categories ?? [];
    const cat = Array.isArray(cats) && cats.length ? cats[0]! : "Uncategorized";
    const groupNotes = groups.get(cat) ?? [];
    groupNotes.push(note);
    groups.set(cat, groupNotes);
  }

  const canvasNodes: CanvasNode[] = [];
  const canvasEdges: CanvasEdge[] = [];
  let groupX = 0;

  for (const [groupName, groupNotes] of [...groups.entries()].sort((a, b) => a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0)) {
    const cols = Math.min(4, Math.max(1, groupNotes.length));
    const rows = Math.floor((groupNotes.length + cols - 1) / cols);
    const groupW = cols * (CARD_W + GAP_X) + GROUP_PAD;
    const groupH = rows * (CARD_H + GAP_Y) + GROUP_PAD + 60;

    canvasNodes.push({
      id: uid(),
      type: "group",
      x: groupX,
      y: 0,
      width: groupW,
      height: groupH,
      label: groupName,
      collapsed: false,
    });

    for (let i = 0; i < groupNotes.length; i += 1) {
      const note = groupNotes[i]!;
      const col = i % cols;
      const row = Math.floor(i / cols);
      const x = groupX + Math.floor(GROUP_PAD / 2) + col * (CARD_W + GAP_X);
      const y = 50 + row * (CARD_H + GAP_Y);
      const knowledge = note.frontmatter.knowledge;
      const color = KNOWLEDGE_COLORS[typeof knowledge === "string" ? knowledge : "reference"] ?? "1";
      canvasNodes.push({
        id: uid(),
        type: "file",
        file: note.path,
        x,
        y,
        width: CARD_W,
        height: CARD_H,
        color,
      });
    }
    groupX += groupW + GAP_X * 2;
  }

  const canvas = buildCanvas(canvasNodes, canvasEdges);
  const output = args.output ?? path.join(VAULT_ROOT, "Resources", "Canvas", "Knowledge Map.canvas");
  fs.mkdirSync(path.dirname(output), { recursive: true });
  fs.writeFileSync(output, JSON.stringify(canvas, null, 2), "utf8");
  console.log(`Canvas written to ${output}`);
  console.log(`  ${notes.length} notes in ${groups.size} groups`);
  console.log("  Color legend: red=reference, orange=familiar, yellow=understood, cyan=applied, green=mastered");
}

function cmdProjectMap(args: ProjectMapArgs): void {
  const notes = findNotes("Projects");
  if (!notes.length) {
    console.log("No projects found.");
    return;
  }
  const canvasNodes: CanvasNode[] = [];
  for (let i = 0; i < notes.length; i += 1) {
    const note = notes[i]!;
    const col = i % 5;
    const row = Math.floor(i / 5);
    canvasNodes.push({
      id: uid(),
      type: "file",
      file: note.path,
      x: col * (CARD_W + GAP_X),
      y: row * (CARD_H + GAP_Y),
      width: CARD_W,
      height: CARD_H,
    });
  }
  const canvas = buildCanvas(canvasNodes, []);
  const output = args.output ?? path.join(VAULT_ROOT, "Resources", "Canvas", "Project Map.canvas");
  fs.mkdirSync(path.dirname(output), { recursive: true });
  fs.writeFileSync(output, JSON.stringify(canvas, null, 2), "utf8");
  console.log(`Canvas written to ${output} (${notes.length} projects)`);
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
    for (const entry of entries) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) visit(full);
      else if (entry.isFile() && entry.name.endsWith(".md")) files.push(full);
    }
  }
  visit(root);
  return files;
}

function cmdFromLinks(args: FromLinksArgs): void {
  const vault = VAULT_ROOT;
  let notePath = args.notePath;
  if (!path.isAbsolute(notePath)) notePath = path.join(vault, notePath);
  if (!fs.existsSync(notePath)) {
    console.error(`Error: ${notePath} not found`);
    process.exit(1);
  }

  const depth = args.depth;
  const visited = new Set<string>();
  const toVisit: Array<[string, number]> = [[path.relative(vault, notePath).split(path.sep).join("/"), 0]];
  const allNotes = new Map<string, NoteInfo>();
  const allEdges: Array<[string, string]> = [];

  const stemIndex = new Map<string, string>();
  for (const md of walkMarkdown(vault)) {
    const parts = md.split(path.sep);
    if (parts.includes(".git") || parts.includes(".obsidian")) continue;
    const rel = path.relative(vault, md).split(path.sep).join("/");
    stemIndex.set(path.basename(md, path.extname(md)), rel);
  }

  while (toVisit.length) {
    const [relPath, d] = toVisit.shift()!;
    if (visited.has(relPath)) continue;
    visited.add(relPath);
    const full = path.join(vault, relPath);
    if (!fs.existsSync(full)) continue;
    const fm = parseFrontmatter(full);
    allNotes.set(relPath, { name: path.basename(full, path.extname(full)), path: relPath, frontmatter: fm });
    if (d >= depth) continue;
    let text: string;
    try {
      text = readTextIgnore(full);
    } catch {
      continue;
    }
    for (const match of text.matchAll(/\[\[([^\]|]+)(?:\|[^\]]+)?\]\]/g)) {
      const targetName = match[1]!.trim();
      const targetPath = stemIndex.get(targetName);
      if (targetPath) {
        allEdges.push([relPath, targetPath]);
        if (!visited.has(targetPath)) toVisit.push([targetPath, d + 1]);
      }
    }
  }

  const canvasNodes: CanvasNode[] = [];
  const canvasEdges: CanvasEdge[] = [];
  const nodeIds = new Map<string, string>();
  const noteList = [...allNotes.keys()];
  const center = path.isAbsolute(args.notePath) ? path.relative(vault, notePath).split(path.sep).join("/") : args.notePath;

  for (let i = 0; i < noteList.length; i += 1) {
    const relPath = noteList[i]!;
    const nid = uid();
    nodeIds.set(relPath, nid);
    let x: number;
    let y: number;
    let w: number;
    let h: number;
    if (relPath === center || (i === 0 && !noteList.includes(center))) {
      x = 0;
      y = 0;
      w = CARD_W + 100;
      h = CARD_H + 40;
    } else {
      const angle = 2 * Math.PI * (i - 1) / Math.max(1, noteList.length - 1);
      const radius = 400;
      x = Math.trunc(radius * Math.cos(angle));
      y = Math.trunc(radius * Math.sin(angle));
      w = CARD_W;
      h = CARD_H;
    }
    const note = allNotes.get(relPath)!;
    const knowledge = note.frontmatter.knowledge;
    const color = KNOWLEDGE_COLORS[typeof knowledge === "string" ? knowledge : "reference"] ?? "1";
    canvasNodes.push({
      id: nid,
      type: "file",
      file: relPath,
      x,
      y,
      width: w,
      height: h,
      color,
    });
  }

  for (const [src, dst] of allEdges) {
    const fromNode = nodeIds.get(src);
    const toNode = nodeIds.get(dst);
    if (fromNode && toNode) {
      canvasEdges.push({
        id: uid(),
        fromNode,
        fromSide: "right",
        toNode,
        toSide: "left",
      });
    }
  }

  const canvas = buildCanvas(canvasNodes, canvasEdges);
  const output = args.output ?? path.join(VAULT_ROOT, "Resources", "Canvas", `${path.basename(notePath, path.extname(notePath))} Map.canvas`);
  fs.mkdirSync(path.dirname(output), { recursive: true });
  fs.writeFileSync(output, JSON.stringify(canvas, null, 2), "utf8");
  console.log(`Canvas written to ${output}`);
  console.log(`  ${canvasNodes.length} nodes, ${canvasEdges.length} edges (depth=${depth})`);
}

function parserError(message: string): never {
  console.error(`canvas_gen.ts: error: ${message}`);
  process.exit(2);
}

function optionValue(argv: string[], index: number, option: string): string {
  const value = argv[index + 1];
  if (value === undefined) parserError(`argument ${option}: expected one argument`);
  return value;
}

function parseOptions(argv: string[], allowed: Set<string>): { options: Map<string, string>; positionals: string[] } {
  const options = new Map<string, string>();
  const positionals: string[] = [];
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i]!;
    if (token.startsWith("--")) {
      if (!allowed.has(token)) parserError(`unrecognized arguments: ${token}`);
      options.set(token, optionValue(argv, i, token));
      i += 1;
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
    case "knowledge-map": {
      const { options, positionals } = parseOptions(rest, new Set(["--folder", "--category", "--output"]));
      if (positionals.length) parserError(`unrecognized arguments: ${positionals.join(" ")}`);
      return {
        command,
        folder: options.get("--folder") ?? "Knowledge",
        category: options.get("--category") ?? null,
        output: options.get("--output") ?? null,
      };
    }
    case "project-map": {
      const { options, positionals } = parseOptions(rest, new Set(["--output"]));
      if (positionals.length) parserError(`unrecognized arguments: ${positionals.join(" ")}`);
      return { command, output: options.get("--output") ?? null };
    }
    case "from-links": {
      const { options, positionals } = parseOptions(rest, new Set(["--depth", "--output"]));
      if (!positionals[0]) parserError("the following arguments are required: note_path");
      if (positionals.length > 1) parserError(`unrecognized arguments: ${positionals.slice(1).join(" ")}`);
      const depthRaw = options.get("--depth") ?? "1";
      if (!/^[+-]?\d+$/.test(depthRaw)) parserError(`argument --depth: invalid int value: '${depthRaw}'`);
      const depth = Number.parseInt(depthRaw, 10);
      return { command, notePath: positionals[0], depth, output: options.get("--output") ?? null };
    }
    default:
      parserError(`argument command: invalid choice: '${command}' (choose from 'knowledge-map', 'project-map', 'from-links')`);
  }
}

export function main(): void {
  const args = parseArgs(Bun.argv.slice(2));
  switch (args.command) {
    case "knowledge-map":
      cmdKnowledgeMap(args);
      break;
    case "project-map":
      cmdProjectMap(args);
      break;
    case "from-links":
      cmdFromLinks(args);
      break;
  }
}

if (import.meta.main) main();
