# React Patterns

Component architecture, hooks, state management, performance, and testing patterns for modern React.

---

## Component Patterns

### Composition Over Props Drilling

```tsx
// BAD: prop drilling through 4 levels
<App user={user}>
  <Layout user={user}>
    <Sidebar user={user}>
      <UserBadge user={user} />

// GOOD: composition — pass the rendered component
<App>
  <Layout sidebar={<Sidebar badge={<UserBadge user={user} />} />}>
    {children}
  </Layout>
</App>
```

### Discriminated Union Props

```tsx
// BAD: impossible states representable
type ButtonProps = {
  variant: "link" | "button";
  href?: string;        // only for link
  onClick?: () => void; // only for button
};

// GOOD: each variant carries exactly its props
type ButtonProps =
  | { variant: "link"; href: string }
  | { variant: "button"; onClick: () => void };

function Button(props: ButtonProps) {
  if (props.variant === "link") {
    return <a href={props.href}>{children}</a>;  // href guaranteed
  }
  return <button onClick={props.onClick}>{children}</button>;
}
```

### Polymorphic `as` Prop

```tsx
type BoxProps<T extends React.ElementType = "div"> = {
  as?: T;
  children: React.ReactNode;
} & React.ComponentPropsWithoutRef<T>;

function Box<T extends React.ElementType = "div">({
  as, children, ...rest
}: BoxProps<T>) {
  const Component = as ?? "div";
  return <Component {...rest}>{children}</Component>;
}

// Usage
<Box as="section" id="main">content</Box>
<Box as="a" href="/about">link</Box>
<Box>default div</Box>
```

### Render Props (When Hooks Don't Fit)

```tsx
// For when you need to share behavior that involves rendering
type MouseTrackerProps = {
  children: (position: { x: number; y: number }) => React.ReactNode;
};

function MouseTracker({ children }: MouseTrackerProps) {
  const [pos, setPos] = useState({ x: 0, y: 0 });
  return (
    <div onMouseMove={(e) => setPos({ x: e.clientX, y: e.clientY })}>
      {children(pos)}
    </div>
  );
}

<MouseTracker>
  {({ x, y }) => <div>Mouse at {x}, {y}</div>}
</MouseTracker>
```

---

## Hooks

### Custom Hook Patterns

```tsx
// Data fetching with loading/error states
function useQuery<T>(url: string): {
  data: T | null;
  error: Error | null;
  isLoading: boolean;
} {
  const [state, setState] = useState<{
    data: T | null;
    error: Error | null;
    isLoading: boolean;
  }>({ data: null, error: null, isLoading: true });

  useEffect(() => {
    const controller = new AbortController();

    fetch(url, { signal: controller.signal })
      .then((res) => res.json())
      .then((data) => setState({ data, error: null, isLoading: false }))
      .catch((error) => {
        if (error.name !== "AbortError") {
          setState({ data: null, error, isLoading: false });
        }
      });

    return () => controller.abort();
  }, [url]);

  return state;
}
```

### useCallback / useMemo Decision

```tsx
// useMemo: expensive COMPUTATION
const sorted = useMemo(
  () => items.sort((a, b) => a.price - b.price),
  [items],
);

// useCallback: stable FUNCTION REFERENCE (for child memo)
const handleClick = useCallback(
  (id: string) => setSelected(id),
  [], // setSelected is stable
);

// DON'T useMemo/useCallback for cheap operations
// The overhead of memoization > the cost of re-computing
const fullName = `${first} ${last}`;  // just compute it, don't memo
```

### useRef for Mutable Values (Not Just DOM)

```tsx
// Track previous value
function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>();
  useEffect(() => { ref.current = value; });
  return ref.current;
}

// Stable callback that always uses latest state (no stale closure)
function useLatestCallback<T extends (...args: any[]) => any>(fn: T): T {
  const ref = useRef(fn);
  ref.current = fn;
  return useCallback((...args: any[]) => ref.current(...args), []) as T;
}

// Interval that doesn't go stale
function useInterval(callback: () => void, delay: number | null) {
  const saved = useRef(callback);
  saved.current = callback;

  useEffect(() => {
    if (delay === null) return;
    const id = setInterval(() => saved.current(), delay);
    return () => clearInterval(id);
  }, [delay]);
}
```

---

## State Management

### When to Use What

| State Type | Solution | Example |
|-----------|---------|---------|
| Local UI state | `useState` | Toggle, input value, open/close |
| Shared between siblings | Lift state to parent | Selected item in a list |
| Deep tree (avoid drilling) | Context | Theme, auth user, locale |
| Complex transitions | `useReducer` | Form with validation, wizard steps |
| Server state | React Query / SWR | API data with caching, revalidation |
| Global client state | Zustand / Jotai | Shopping cart, UI preferences |

### useReducer for Complex State

```tsx
type FormState = {
  values: Record<string, string>;
  errors: Record<string, string>;
  touched: Record<string, boolean>;
  isSubmitting: boolean;
};

type FormAction =
  | { type: "SET_FIELD"; field: string; value: string }
  | { type: "SET_ERROR"; field: string; error: string }
  | { type: "TOUCH"; field: string }
  | { type: "SUBMIT" }
  | { type: "SUBMIT_SUCCESS" }
  | { type: "SUBMIT_ERROR"; errors: Record<string, string> };

function formReducer(state: FormState, action: FormAction): FormState {
  switch (action.type) {
    case "SET_FIELD":
      return {
        ...state,
        values: { ...state.values, [action.field]: action.value },
        errors: { ...state.errors, [action.field]: "" },
      };
    case "SUBMIT":
      return { ...state, isSubmitting: true };
    case "SUBMIT_SUCCESS":
      return { ...state, isSubmitting: false };
    case "SUBMIT_ERROR":
      return { ...state, isSubmitting: false, errors: action.errors };
    // ...
  }
}
```

### Context Without Re-render Hell

```tsx
// Split context by update frequency
const ThemeContext = createContext<Theme>(defaultTheme);         // rarely changes
const UserContext = createContext<User | null>(null);            // changes on login
const NotificationContext = createContext<Notification[]>([]);   // changes often

// DON'T put everything in one context — every consumer re-renders on any change

// Zustand for high-frequency shared state (no re-render problem)
import { create } from "zustand";

const useStore = create<Store>((set) => ({
  count: 0,
  increment: () => set((s) => ({ count: s.count + 1 })),
}));

// Components only re-render when their selected slice changes
const count = useStore((s) => s.count);
```

---

## Performance

### React.memo — When and How

```tsx
// Memo a component that receives stable or primitive props
const ExpensiveList = React.memo(function ExpensiveList({
  items,
  onSelect,
}: {
  items: Item[];
  onSelect: (id: string) => void;
}) {
  return items.map((item) => (
    <ExpensiveItem key={item.id} item={item} onSelect={onSelect} />
  ));
});

// Parent MUST stabilize props for memo to work
function Parent() {
  const [items] = useState(initialItems);
  const onSelect = useCallback((id: string) => { /* ... */ }, []);

  return <ExpensiveList items={items} onSelect={onSelect} />;
  // If onSelect recreates every render, memo is useless
}
```

### Virtualization for Long Lists

```tsx
// Don't render 10,000 DOM nodes
import { useVirtualizer } from "@tanstack/react-virtual";

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50, // px per row
  });

  return (
    <div ref={parentRef} style={{ height: 400, overflow: "auto" }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map((virtual) => (
          <div
            key={virtual.key}
            style={{
              position: "absolute",
              top: virtual.start,
              height: virtual.size,
            }}
          >
            {items[virtual.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

### Lazy Loading

```tsx
// Code split heavy components
const HeavyChart = lazy(() => import("./HeavyChart"));
const AdminPanel = lazy(() => import("./AdminPanel"));

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      {showChart && <HeavyChart data={data} />}
      {isAdmin && <AdminPanel />}
    </Suspense>
  );
}
```

---

## Testing

### Component Testing (Bun + Testing Library)

```tsx
import { render, screen, fireEvent } from "@testing-library/react";
import { describe, it, expect } from "bun:test";

describe("Counter", () => {
  it("increments on click", () => {
    render(<Counter />);

    expect(screen.getByText("Count: 0")).toBeDefined();
    fireEvent.click(screen.getByRole("button", { name: "Increment" }));
    expect(screen.getByText("Count: 1")).toBeDefined();
  });
});
```

### Hook Testing

```tsx
import { renderHook, act } from "@testing-library/react";

describe("useCounter", () => {
  it("increments", () => {
    const { result } = renderHook(() => useCounter());

    act(() => result.current.increment());
    expect(result.current.count).toBe(1);
  });
});
```

### What to Test

| Test | Why | How |
|------|-----|-----|
| User interactions | Core value | Click, type, submit → assert visible result |
| Conditional rendering | Logic correctness | Pass different props → assert what's shown |
| Error states | Resilience | Mock fetch failure → assert error UI |
| Accessibility | Inclusivity | `getByRole`, `getByLabelText` (not `getByTestId`) |
| **Don't test** | Implementation details | Don't assert state values, internal methods, render count |
