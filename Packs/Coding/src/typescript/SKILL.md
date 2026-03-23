---
name: typescript
description: "TypeScript patterns, Bun runtime/tooling, and React component architecture — type-level programming, async patterns, tsconfig, monorepo, Bun as runtime/bundler/test/package manager, React hooks/state/performance. Use when TypeScript, TS, type gymnastics, generics, Bun, bunx, React, hooks, component patterns, tsconfig, monorepo, type-safe, discriminated union, conditional types, template literal types, Bun test, Bun build."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
---

# TypeScript + Bun + React

Deep reference for modern TypeScript development — the language, the runtime, and the framework.

## Sections

| Section | What It Covers |
|---------|---------------|
| [Type Patterns](#type-patterns) | Discriminated unions, conditional types, template literals, mapped types, infer |
| [Async Patterns](#async-patterns) | Error handling, cancellation, concurrency, retry, streaming |
| [tsconfig](#tsconfig-guide) | Strict mode, path aliases, composite projects, common gotchas |
| [References](#references) | Bun, React, Monorepo — deep dives in separate files |

$ARGUMENTS

---

## Type Patterns

### Discriminated Unions (The Most Important Pattern)

Model states that can't exist simultaneously. Replace `status: string` + optional fields with explicit variants.

```typescript
// BAD: impossible states are representable
type Request = {
  status: "idle" | "loading" | "success" | "error";
  data?: Response;    // when is this set? when is it null?
  error?: Error;      // same question
};

// GOOD: each state carries exactly its data
type Request =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: Response }
  | { status: "error"; error: Error };

// Exhaustive switch — compiler catches missing cases
function handle(req: Request) {
  switch (req.status) {
    case "idle": return null;
    case "loading": return <Spinner />;
    case "success": return <Data data={req.data} />;   // data is guaranteed here
    case "error": return <Error error={req.error} />;   // error is guaranteed here
  }
  // No default needed — TS errors if you miss a case (with `noUncheckedIndexedAccess`)
}
```

### Conditional Types

```typescript
// Extract return type of async functions
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;
type Result = UnwrapPromise<Promise<string>>;  // string

// Make certain keys required
type RequireKeys<T, K extends keyof T> = T & Required<Pick<T, K>>;
type UserWithEmail = RequireKeys<User, "email">;

// Filter union members
type Extract<T, U> = T extends U ? T : never;
type StringEvents = Extract<Event, { type: string }>;
```

### Template Literal Types

```typescript
// Type-safe event names
type EventName = `on${Capitalize<"click" | "hover" | "focus">}`;
// "onClick" | "onHover" | "onFocus"

// Type-safe route params
type Route = `/users/${string}` | `/users/${string}/posts/${string}`;

// API endpoint builder
type Method = "get" | "post" | "put" | "delete";
type Endpoint = `${Method} /api/${string}`;
```

### Mapped Types

```typescript
// Make all properties optional and nullable
type Partial<T> = { [K in keyof T]?: T[K] | null };

// Create a form state type from a model
type FormState<T> = {
  [K in keyof T]: {
    value: T[K];
    error: string | null;
    touched: boolean;
  };
};

// Readonly deeply
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
};
```

### The `infer` Keyword

```typescript
// Extract function parameters
type Params<T> = T extends (...args: infer P) => any ? P : never;
type LoginParams = Params<typeof login>;  // [email: string, password: string]

// Extract array element type
type Element<T> = T extends (infer E)[] ? E : never;
type User = Element<User[]>;  // User

// Extract props from a React component
type PropsOf<T> = T extends React.ComponentType<infer P> ? P : never;
```

### Branded Types (Nominal Typing)

TypeScript is structural — two types with the same shape are interchangeable. Use branding to prevent mixing.

```typescript
type UserId = string & { __brand: "UserId" };
type OrderId = string & { __brand: "OrderId" };

function createUserId(id: string): UserId { return id as UserId; }
function createOrderId(id: string): OrderId { return id as OrderId; }

function getUser(id: UserId) { /* ... */ }

const userId = createUserId("u-123");
const orderId = createOrderId("o-456");

getUser(userId);   // OK
getUser(orderId);  // ERROR: OrderId is not assignable to UserId
```

### `satisfies` Operator

Validate a value matches a type without widening it:

```typescript
type Color = "red" | "green" | "blue";
type ColorMap = Record<Color, string | number>;

// Without satisfies: type is Record<Color, string | number> — loses specificity
const colors: ColorMap = { red: "#ff0000", green: [0, 255, 0], blue: "blue" };
colors.red.toUpperCase(); // ERROR: might be number

// With satisfies: validates against ColorMap, keeps literal types
const colors = {
  red: "#ff0000",
  green: [0, 255, 0],
  blue: "blue",
} satisfies ColorMap;
colors.red.toUpperCase(); // OK — TS knows it's string
```

---

## Async Patterns

### Error Handling Without try/catch Soup

```typescript
// Result type for expected failures
type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E };

async function fetchUser(id: string): Promise<Result<User, ApiError>> {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) return { ok: false, error: new ApiError(res.status) };
  return { ok: true, value: await res.json() };
}

// Usage — forced to handle both paths
const result = await fetchUser("123");
if (!result.ok) return handleError(result.error);
console.log(result.value.name); // value is typed as User
```

### Cancellation with AbortController

```typescript
async function fetchWithTimeout(url: string, timeoutMs = 5000): Promise<Response> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);

  try {
    return await fetch(url, { signal: controller.signal });
  } finally {
    clearTimeout(timeout);
  }
}

// In React: cancel on unmount
useEffect(() => {
  const controller = new AbortController();
  fetchData(controller.signal);
  return () => controller.abort();
}, []);
```

### Controlled Concurrency

```typescript
// Process items with max N concurrent operations
async function mapConcurrent<T, R>(
  items: T[],
  fn: (item: T) => Promise<R>,
  concurrency: number,
): Promise<R[]> {
  const results: R[] = [];
  const executing = new Set<Promise<void>>();

  for (const item of items) {
    const p = fn(item).then(r => { results.push(r); });
    executing.add(p);
    p.finally(() => executing.delete(p));

    if (executing.size >= concurrency) {
      await Promise.race(executing);
    }
  }

  await Promise.all(executing);
  return results;
}

// Process 100 URLs, max 5 at a time
await mapConcurrent(urls, fetchUrl, 5);
```

### Retry with Exponential Backoff

```typescript
async function retry<T>(
  fn: () => Promise<T>,
  { maxRetries = 3, baseDelay = 1000 } = {},
): Promise<T> {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (e) {
      if (attempt === maxRetries) throw e;
      const delay = baseDelay * 2 ** attempt + Math.random() * 100;
      await new Promise(r => setTimeout(r, delay));
    }
  }
  throw new Error("unreachable");
}
```

---

## tsconfig Guide

### Strict Baseline

```jsonc
{
  "compilerOptions": {
    // Strict — non-negotiable
    "strict": true,
    "noUncheckedIndexedAccess": true,   // array[i] returns T | undefined
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true, // undefined !== optional

    // Module system
    "module": "ESNext",
    "moduleResolution": "bundler",      // for Bun/Vite/Next.js
    "target": "ESNext",
    "lib": ["ESNext", "DOM", "DOM.Iterable"],

    // Output
    "outDir": "dist",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,

    // Path aliases
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@/components/*": ["src/components/*"],
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

### Common tsconfig Gotchas

| Issue | Fix |
|-------|-----|
| Path aliases don't resolve at runtime | Bun handles them natively. Node needs `tsx` or `tsc-alias`. |
| `moduleResolution: "node"` misses `.ts` imports | Use `"bundler"` for Bun/Vite, `"node16"` for pure Node |
| `strict: true` but half the checks off | Don't set `strictNullChecks: false` — that defeats the purpose |
| `any` leaking everywhere | Enable `noImplicitAny`. Add `// @ts-expect-error` only with comments. |
| Declaration files not generated | Need `"declaration": true` AND `"declarationMap": true` |

---

## References

Deep dives in separate files:

- **[Bun](references/bun.md)** — Runtime, bundler, test runner, package manager, scripts, macros
- **[React](references/react.md)** — Component patterns, hooks, state management, performance, testing
- **[Monorepo](references/monorepo.md)** — Workspace setup, shared packages, build orchestration
