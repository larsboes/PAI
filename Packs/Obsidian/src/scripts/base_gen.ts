import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { parse, stringify } from "yaml";

type ViewType = "table" | "cards" | "list" | "map";
type SortDir = "asc" | "desc";

type CreateArgs = {
  command: "create";
  name: string;
  folder: string;
  view: ViewType;
  filter: string | null;
  groupBy: string | null;
  sort: string | null;
  sortDir: SortDir;
};
type FromTemplateArgs = { command: "from-template"; template: string; name: string | null; folder: string | null };
type ListArgs = { command: "list" };
type ValidateArgs = { command: "validate"; basePath: string | null };
type TemplatesArgs = { command: "templates" };
type Args = CreateArgs | FromTemplateArgs | ListArgs | ValidateArgs | TemplatesArgs;

type BaseView = {
  type: string;
  name: string;
  order?: Array<{ property: string; direction: string }>;
  groupBy?: { property: string; direction: string };
  filters?: string;
  limit?: number;
};

type Template = {
  description: string;
  filter: string | { and: string[] };
  formulas?: Record<string, string>;
  views: BaseView[];
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

const TEMPLATES: Record<string, Template> = {
  "knowledge": {
    description: "Knowledge notes filtered by knowledge level",
    filter: 'file.inFolder("Knowledge")',
    formulas: {
      status: 'if(note.knowledge == "mastered", icon("check-circle"), if(note.knowledge == "applied", icon("zap"), if(note.knowledge == "understood", icon("brain"), if(note.knowledge == "familiar", icon("eye"), icon("book-open")))))',
    },
    views: [{
      type: "table",
      name: "All Knowledge",
      order: [{ property: "note.knowledge", direction: "desc" }],
    }, {
      type: "cards",
      name: "Gallery",
      groupBy: { property: "note.knowledge", direction: "desc" },
    }],
  },
  "knowledge-by-category": {
    description: "Knowledge notes grouped by category",
    filter: 'file.inFolder("Knowledge")',
    views: [{
      type: "table",
      name: "By Category",
      groupBy: { property: "note.categories", direction: "asc" },
      order: [{ property: "note.maturity", direction: "desc" }],
    }],
  },
  "knowledge-work": {
    description: "Work-scoped Knowledge notes",
    filter: {
      and: [
        'file.inFolder("Knowledge")',
        'note.scope == "work"',
      ],
    },
    views: [{
      type: "table",
      name: "Work Knowledge",
      order: [{ property: "note.knowledge", direction: "desc" }],
    }],
  },
  projects: {
    description: "Project tracker",
    filter: 'file.inFolder("Projects")',
    views: [{
      type: "table",
      name: "All Projects",
      order: [{ property: "note.status", direction: "asc" }],
    }, {
      type: "cards",
      name: "Board",
      groupBy: { property: "note.status", direction: "asc" },
    }],
  },
  learning: {
    description: "Learning modules tracker",
    filter: 'file.path.contains("Learning/")',
    formulas: {
      progress: 'if(note.status == "completed", "Done", if(note.status == "in-progress", "Active", "Not started"))',
    },
    views: [{
      type: "table",
      name: "Modules",
      order: [{ property: "note.course", direction: "asc" }],
      groupBy: { property: "note.course", direction: "asc" },
    }],
  },
  people: {
    description: "People directory",
    filter: 'file.inFolder("People")',
    views: [{
      type: "table",
      name: "Directory",
      order: [{ property: "file.name", direction: "asc" }],
    }],
  },
  tasks: {
    description: "Task tracker",
    filter: 'file.inFolder("Tasks")',
    views: [{
      type: "table",
      name: "All Tasks",
      order: [{ property: "note.priority", direction: "desc" }],
    }, {
      type: "table",
      name: "Active",
      filters: 'note.status != "done"',
      order: [{ property: "note.priority", direction: "desc" }],
    }],
  },
  recent: {
    description: "Recently modified notes",
    filter: 'file.mtime > now() - "7d"',
    views: [{
      type: "table",
      name: "Last 7 Days",
      order: [{ property: "file.mtime", direction: "desc" }],
      limit: 50,
    }],
  },
  journal: {
    description: "Journal entries",
    filter: 'file.inFolder("Journal")',
    views: [{
      type: "table",
      name: "All Entries",
      order: [{ property: "file.name", direction: "desc" }],
    }],
  },
};

function dumpYaml(value: unknown): string {
  return stringify(value, { indent: 2, indentSeq: false });
}

function outputPath(folder: string, filename: string): string {
  return path.isAbsolute(folder) ? path.join(folder, filename) : path.join(VAULT_ROOT, folder, filename);
}

function cmdCreate(args: CreateArgs): void {
  const base: Record<string, unknown> = {};
  if (args.filter) base.filter = args.filter;
  const view: BaseView = { type: args.view, name: args.name };
  if (args.sort) view.order = [{ property: args.sort, direction: args.sortDir }];
  if (args.groupBy) view.groupBy = { property: args.groupBy, direction: "asc" };
  base.views = [view];

  const output = outputPath(args.folder, `${args.name}.base`);
  fs.mkdirSync(path.dirname(output), { recursive: true });
  fs.writeFileSync(output, dumpYaml(base), "utf8");
  console.log(`Created ${output}`);
}

function titleFromTemplateName(templateName: string): string {
  return templateName.split("-").map((part) => part.charAt(0).toUpperCase() + part.slice(1)).join(" ");
}

function cmdFromTemplate(args: FromTemplateArgs): void {
  const templateName = args.template;
  const template = TEMPLATES[templateName];
  if (!template) {
    console.log(`Unknown template: ${templateName}`);
    console.log(`Available: ${Object.keys(TEMPLATES).join(", ")}`);
    process.exit(1);
  }
  const name = args.name ?? titleFromTemplateName(templateName);
  const folder = args.folder ?? "Resources/Bases";
  const { description: _description, ...base } = template;
  const output = outputPath(folder, `${name}.base`);
  fs.mkdirSync(path.dirname(output), { recursive: true });
  fs.writeFileSync(output, dumpYaml(base), "utf8");
  console.log(`Created ${output} (template: ${templateName})`);
  console.log(`  ${template.description}`);
}

function walkByExtension(root: string, ext: string): string[] {
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
      else if (entry.isFile() && entry.name.endsWith(ext)) files.push(full);
    }
  }
  visit(root);
  return files.sort();
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return value !== null && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : null;
}

function cmdList(_args: ListArgs): void {
  const vault = VAULT_ROOT;
  if (!fs.existsSync(vault)) {
    console.error(`Error: Vault not found at ${vault}`);
    process.exit(1);
  }
  const bases = walkByExtension(vault, ".base");
  if (!bases.length) {
    console.log("No .base files found in vault.");
    return;
  }
  console.log(`Found ${bases.length} base files:`);
  for (const basePath of bases) {
    const rel = path.relative(vault, basePath).split(path.sep).join("/");
    const size = fs.statSync(basePath).size;
    try {
      const content = asRecord(parse(readTextIgnore(basePath)));
      if (!content) throw new Error("parse error");
      const viewsRaw = content.views;
      const views = Array.isArray(viewsRaw) ? viewsRaw : [];
      const viewNames = views.map((view) => {
        const record = asRecord(view);
        const name = record?.name;
        const type = record?.type;
        return typeof name === "string" ? name : typeof type === "string" ? type : "?";
      });
      console.log(`  ${rel} (${size}B) — views: ${viewNames.join(", ")}`);
    } catch {
      console.log(`  ${rel} (${size}B) — parse error`);
    }
  }
}

function displayPathForBase(basePath: string, vault: string): string {
  return basePath.startsWith(vault) ? path.relative(vault, basePath).split(path.sep).join("/") : basePath;
}

function cmdValidate(args: ValidateArgs): void {
  const vault = VAULT_ROOT;
  const bases = args.basePath ? [args.basePath] : walkByExtension(vault, ".base");
  let errors = 0;
  for (const basePath of bases) {
    const rel = displayPathForBase(basePath, vault);
    try {
      const content = asRecord(parse(readTextIgnore(basePath)));
      if (!content) {
        console.log(`  FAIL ${rel}: root is not a mapping`);
        errors += 1;
        continue;
      }
      const viewsRaw = content.views;
      const views = viewsRaw === undefined ? [] : viewsRaw;
      if (views && !Array.isArray(views)) {
        console.log(`  FAIL ${rel}: 'views' is not a list`);
        errors += 1;
        continue;
      }
      const validTypes = new Set(["table", "cards", "list", "map"]);
      const viewList = Array.isArray(views) ? views : [];
      for (let i = 0; i < viewList.length; i += 1) {
        const view = asRecord(viewList[i]);
        const vtype = typeof view?.type === "string" ? view.type : "";
        if (!validTypes.has(vtype)) console.log(`  WARN ${rel}: view[${i}] has unknown type '${vtype}'`);
      }
      console.log(`  OK   ${rel} (${viewList.length} views)`);
    } catch (error) {
      const name = error instanceof Error ? error.name : "";
      const message = error instanceof Error ? error.message : String(error);
      if (name.includes("YAML") || name.includes("YAMLParseError")) {
        console.log(`  FAIL ${rel}: YAML error — ${message}`);
      } else {
        console.log(`  FAIL ${rel}: ${message}`);
      }
      errors += 1;
    }
  }
  console.log(`\nValidated ${bases.length} files, ${errors} errors`);
}

function cmdTemplates(_args: TemplatesArgs): void {
  console.log("Available templates:");
  for (const [name, tmpl] of Object.entries(TEMPLATES)) {
    const vtypes = tmpl.views.map((view) => view.type);
    console.log(`  ${name.padEnd(25, " ")} — ${tmpl.description} [${vtypes.join(", ")}]`);
  }
}

function parserError(message: string): never {
  console.error(`base_gen.ts: error: ${message}`);
  process.exit(2);
}

function takeOption(argv: string[], index: number, option: string): string {
  const value = argv[index + 1];
  if (value === undefined) parserError(`argument ${option}: expected one argument`);
  return value;
}

function parseOptions(argv: string[], allowed: Set<string>): { options: Map<string, string | boolean>; positionals: string[] } {
  const options = new Map<string, string | boolean>();
  const positionals: string[] = [];
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i]!;
    if (token.startsWith("--")) {
      if (!allowed.has(token)) parserError(`unrecognized arguments: ${token}`);
      const value = takeOption(argv, i, token);
      options.set(token, value);
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
    case "create": {
      const { options, positionals } = parseOptions(rest, new Set(["--name", "--folder", "--view", "--filter", "--group-by", "--sort", "--sort-dir"]));
      if (positionals.length) parserError(`unrecognized arguments: ${positionals.join(" ")}`);
      const name = options.get("--name");
      if (typeof name !== "string") parserError("the following arguments are required: --name");
      const view = (options.get("--view") ?? "table") as string;
      if (!["table", "cards", "list", "map"].includes(view)) parserError(`argument --view: invalid choice: '${view}' (choose from 'table', 'cards', 'list', 'map')`);
      const sortDir = (options.get("--sort-dir") ?? "asc") as string;
      if (!["asc", "desc"].includes(sortDir)) parserError(`argument --sort-dir: invalid choice: '${sortDir}' (choose from 'asc', 'desc')`);
      return {
        command,
        name,
        folder: (options.get("--folder") as string | undefined) ?? "Resources/Bases",
        view: view as ViewType,
        filter: (options.get("--filter") as string | undefined) ?? null,
        groupBy: (options.get("--group-by") as string | undefined) ?? null,
        sort: (options.get("--sort") as string | undefined) ?? null,
        sortDir: sortDir as SortDir,
      };
    }
    case "from-template": {
      const { options, positionals } = parseOptions(rest, new Set(["--name", "--folder"]));
      if (!positionals[0]) parserError("the following arguments are required: template");
      if (positionals.length > 1) parserError(`unrecognized arguments: ${positionals.slice(1).join(" ")}`);
      return {
        command,
        template: positionals[0],
        name: (options.get("--name") as string | undefined) ?? null,
        folder: (options.get("--folder") as string | undefined) ?? null,
      };
    }
    case "list":
      if (rest.length) parserError(`unrecognized arguments: ${rest.join(" ")}`);
      return { command };
    case "validate": {
      const { options, positionals } = parseOptions(rest, new Set());
      if (options.size) parserError("unrecognized arguments");
      if (positionals.length > 1) parserError(`unrecognized arguments: ${positionals.slice(1).join(" ")}`);
      return { command, basePath: positionals[0] ?? null };
    }
    case "templates":
      if (rest.length) parserError(`unrecognized arguments: ${rest.join(" ")}`);
      return { command };
    default:
      parserError(`argument command: invalid choice: '${command}' (choose from 'create', 'from-template', 'list', 'validate', 'templates')`);
  }
}

export function main(): void {
  const args = parseArgs(Bun.argv.slice(2));
  switch (args.command) {
    case "create":
      cmdCreate(args);
      break;
    case "from-template":
      cmdFromTemplate(args);
      break;
    case "list":
      cmdList(args);
      break;
    case "validate":
      cmdValidate(args);
      break;
    case "templates":
      cmdTemplates(args);
      break;
  }
}

if (import.meta.main) main();
