# Bun

All-in-one JavaScript/TypeScript runtime — replaces Node, npm, webpack, and Jest in one binary.

---

## Quick Reference

| npm/node | bun equivalent |
|----------|---------------|
| `npm install` | `bun install` |
| `npm run dev` | `bun run dev` |
| `npx create-next-app` | `bunx create-next-app` |
| `node script.ts` | `bun script.ts` (native TS, no build step) |
| `jest` / `vitest` | `bun test` |
| `webpack` / `esbuild` | `bun build` |
| `npm init` | `bun init` |
| `npm publish` | `bun publish` |

---

## Package Management

```bash
# Init project
bun init

# Install dependencies (reads package.json)
bun install

# Add dependency
bun add express
bun add -d typescript @types/node   # dev dependency
bun add -g serve                     # global

# Remove
bun remove express

# Update
bun update           # all
bun update express   # specific

# Why is this installed?
bun pm ls            # list all
bun pm cache         # cache info
```

### Lockfile

Bun uses `bun.lockb` (binary, fast). To inspect:

```bash
bun install --yarn   # generate yarn.lock for readability
```

### Workspace (Monorepo)

```jsonc
// package.json
{
  "workspaces": ["packages/*", "apps/*"]
}
```

```bash
# Install all workspace deps
bun install

# Run script in specific workspace
bun run --filter 'packages/shared' build

# Add dep to specific workspace
cd packages/shared && bun add zod
```

---

## Runtime

### Native TypeScript

```bash
# No build step, no ts-node, no tsx
bun run server.ts
bun run script.tsx

# Watch mode
bun --watch run server.ts

# Hot reload (preserves state)
bun --hot run server.ts
```

### Environment Variables

```bash
# .env files loaded automatically (no dotenv needed)
# Supports: .env, .env.local, .env.development, .env.production
bun run server.ts   # reads .env automatically
```

```typescript
// Access
const port = Bun.env.PORT ?? "3000";
// Or standard
const key = process.env.API_KEY;
```

### File I/O (Fast)

```typescript
// Read file (returns string)
const text = await Bun.file("data.json").text();
const json = await Bun.file("data.json").json();
const bytes = await Bun.file("data.bin").arrayBuffer();

// Write file
await Bun.write("output.txt", "hello");
await Bun.write("data.json", JSON.stringify(data, null, 2));

// Check existence
const exists = await Bun.file("path").exists();

// File metadata
const file = Bun.file("data.json");
console.log(file.size, file.type);  // bytes, MIME type
```

### HTTP Server

```typescript
Bun.serve({
  port: 3000,
  fetch(req) {
    const url = new URL(req.url);

    if (url.pathname === "/api/health") {
      return Response.json({ status: "ok" });
    }

    if (url.pathname === "/api/data" && req.method === "POST") {
      const body = await req.json();
      return Response.json({ received: body });
    }

    return new Response("Not Found", { status: 404 });
  },
});
```

### Shell (Subprocess)

```typescript
import { $ } from "bun";

// Simple command
const result = await $`ls -la`.text();

// With variables (auto-escaped)
const dir = "/tmp/test";
await $`mkdir -p ${dir}`;

// Pipe
const count = await $`cat file.txt | wc -l`.text();

// Check exit code
const { exitCode } = await $`git status`.quiet();

// Capture stderr
const { stderr } = await $`npm run build`.quiet();
```

### SQLite (Built-in)

```typescript
import { Database } from "bun:sqlite";

const db = new Database("app.db");

// Create table
db.run(`CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE
)`);

// Prepared statements (safe from injection)
const insert = db.prepare("INSERT INTO users (name, email) VALUES (?, ?)");
insert.run("Alice", "alice@example.com");

// Query
const users = db.prepare("SELECT * FROM users WHERE name = ?").all("Alice");

// Transaction
const insertMany = db.transaction((users) => {
  for (const user of users) insert.run(user.name, user.email);
});
insertMany([{ name: "Bob", email: "bob@x.com" }, { name: "Carol", email: "carol@x.com" }]);
```

---

## Test Runner

```bash
# Run all tests
bun test

# Specific file
bun test src/utils.test.ts

# Watch mode
bun test --watch

# With pattern
bun test --grep "should handle errors"

# Coverage
bun test --coverage
```

```typescript
// src/utils.test.ts
import { describe, it, expect, beforeEach, mock, spyOn } from "bun:test";

describe("calculateTotal", () => {
  it("sums line items", () => {
    const result = calculateTotal([
      { price: 10, qty: 2 },
      { price: 5, qty: 3 },
    ]);
    expect(result).toBe(35);
  });

  it("returns 0 for empty array", () => {
    expect(calculateTotal([])).toBe(0);
  });
});

// Mocking
describe("fetchUser", () => {
  it("handles API errors", async () => {
    const fetchMock = spyOn(global, "fetch").mockResolvedValue(
      new Response("Not Found", { status: 404 }),
    );

    const result = await fetchUser("bad-id");
    expect(result.ok).toBe(false);

    fetchMock.mockRestore();
  });
});

// Snapshot testing
it("renders correctly", () => {
  const output = renderToString(<Component />);
  expect(output).toMatchSnapshot();
});
```

---

## Bundler

```bash
# Bundle for browser
bun build src/index.ts --outdir dist --target browser

# Bundle for Node/Bun
bun build src/server.ts --outdir dist --target bun

# Minified production build
bun build src/index.ts --outdir dist --minify

# Watch mode
bun build src/index.ts --outdir dist --watch
```

```typescript
// Programmatic API
await Bun.build({
  entrypoints: ["src/index.ts"],
  outdir: "dist",
  target: "browser",
  minify: true,
  splitting: true,       // code splitting
  sourcemap: "external",
  external: ["react", "react-dom"],  // don't bundle these
});
```

---

## Scripts & CLI

### package.json Scripts

```jsonc
{
  "scripts": {
    "dev": "bun --hot run src/server.ts",
    "build": "bun build src/index.ts --outdir dist --minify",
    "test": "bun test",
    "lint": "bunx @biomejs/biome check src/",
    "format": "bunx @biomejs/biome format --write src/",
    "typecheck": "bunx tsc --noEmit"
  }
}
```

### Standalone Executable

```bash
# Compile to single binary (no Bun runtime needed to run)
bun build --compile src/cli.ts --outfile mycli
./mycli --help
```

---

## Common Gotchas

| Issue | Fix |
|-------|-----|
| Package not compatible with Bun | Check `bun.sh/docs/ecosystem`. Use `--backend=copyfile` for native modules. |
| `__dirname` not defined | Use `import.meta.dir` (Bun) or `import.meta.dirname` (Node 21+) |
| `require()` in ESM | Bun supports it, but prefer `import`. Check if library needs CJS. |
| Types not found for Bun APIs | `bun add -d @types/bun` |
| Bun.serve not restarting | Use `bun --hot` not `bun --watch` for servers (hot preserves connections) |
