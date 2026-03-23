# Monorepo Patterns

Workspace setup, shared packages, and build orchestration for TypeScript monorepos with Bun.

---

## Structure

```
my-project/
  package.json              # root — workspaces config
  tsconfig.json             # root — shared compiler options
  bun.lockb                 # single lockfile
  packages/
    shared/                 # shared library
      package.json
      tsconfig.json
      src/
        index.ts
    ui/                     # shared components
      package.json
      tsconfig.json
      src/
        Button.tsx
  apps/
    web/                    # Next.js / Vite app
      package.json
      tsconfig.json
      src/
    api/                    # backend
      package.json
      tsconfig.json
      src/
```

---

## Root package.json

```jsonc
{
  "name": "my-project",
  "private": true,
  "workspaces": ["packages/*", "apps/*"],
  "scripts": {
    "dev": "bun run --filter 'apps/*' dev",
    "build": "bun run --filter '*' build",
    "test": "bun test --recursive",
    "lint": "bunx @biomejs/biome check .",
    "typecheck": "bunx tsc -b"   // project references build
  }
}
```

---

## Root tsconfig.json

```jsonc
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "composite": true,        // required for project references
    "skipLibCheck": true
  }
}
```

---

## Shared Package

```jsonc
// packages/shared/package.json
{
  "name": "@my-project/shared",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.ts"     // Bun resolves TS directly
  },
  "scripts": {
    "build": "bun build src/index.ts --outdir dist --target bun",
    "typecheck": "bunx tsc --noEmit"
  }
}
```

```jsonc
// packages/shared/tsconfig.json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"]
}
```

---

## Consuming Shared Packages

```jsonc
// apps/web/package.json
{
  "dependencies": {
    "@my-project/shared": "workspace:*",
    "@my-project/ui": "workspace:*"
  }
}
```

```typescript
// apps/web/src/app.ts
import { validateEmail } from "@my-project/shared";
import { Button } from "@my-project/ui";
```

Bun resolves `workspace:*` to the local package. No build step needed for development — it reads the TS source directly.

---

## Project References (Type Checking)

```jsonc
// apps/web/tsconfig.json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"],
  "references": [
    { "path": "../../packages/shared" },
    { "path": "../../packages/ui" }
  ]
}
```

```bash
# Type check entire project graph
bunx tsc -b          # builds in dependency order
bunx tsc -b --watch  # incremental watch
```

---

## Common Patterns

### Shared Types Package

```typescript
// packages/types/src/index.ts
export type User = {
  id: string;
  email: string;
  name: string;
};

export type ApiResponse<T> = {
  data: T;
  meta: { timestamp: number };
};

// Both apps/web and apps/api import from @my-project/types
```

### Shared Config

```typescript
// packages/config/src/env.ts
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  API_KEY: z.string().min(1),
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
});

export const env = envSchema.parse(process.env);
export type Env = z.infer<typeof envSchema>;
```

### Shared Test Utilities

```typescript
// packages/test-utils/src/index.ts
export function createTestUser(overrides?: Partial<User>): User {
  return {
    id: crypto.randomUUID(),
    email: "test@example.com",
    name: "Test User",
    ...overrides,
  };
}

// Both apps import for testing
import { createTestUser } from "@my-project/test-utils";
```

---

## Gotchas

| Issue | Fix |
|-------|-----|
| Changes in shared package not reflected | Bun resolves source directly — restart dev server if caching. |
| `tsc -b` fails on circular reference | Refactor: shared shouldn't import from apps. Dependencies flow downward. |
| Two packages depend on different versions of same dep | Bun dedupes by default. Pin versions in root if needed. |
| Tests in one package import from another's test utils | Make test-utils a separate package, add to devDependencies. |
| CI build order matters | `tsc -b` handles order via references. For Bun builds, use `--filter` with topological sort. |
