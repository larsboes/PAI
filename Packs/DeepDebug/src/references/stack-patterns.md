# Stack-Specific Debugging Patterns

Common failure modes and debugging strategies per technology stack.

---

## Node.js / TypeScript / Bun

### Common Failure Modes

| Symptom | Likely Cause | Investigation |
|---------|-------------|---------------|
| `TypeError: Cannot read properties of undefined` | Accessing nested property on null/undefined | Trace backward: which variable is undefined? Check API response shape, optional chaining missed |
| `ECONNREFUSED` / `ENOTFOUND` | Service not running, wrong host/port, DNS | `curl` the endpoint directly. Check `docker ps`. Check `.env` host/port. |
| `ERR_MODULE_NOT_FOUND` | Import path wrong, missing extension, CJS/ESM mismatch | Check `"type": "module"` in package.json. Check file extension (.js vs .mjs vs .ts). |
| Unhandled promise rejection (silent) | Missing `.catch()` or `try/catch` on async | Add `process.on('unhandledRejection', console.error)` at entry. Trace which promise. |
| Memory leak / OOM | Event listeners not cleaned up, unbounded cache, closure holding references | `--inspect` + Chrome DevTools heap snapshot. Check `EventEmitter` listener counts. |
| Test passes alone, fails in suite | Shared mutable state, missing cleanup, port conflicts | Run with `--serial`. Add `afterEach` cleanup. Check for global/module-level state. |
| `ETIMEOUT` on HTTP requests | DNS resolution slow, connection pool exhausted, server overloaded | Set explicit timeout. Check `keepAlive` agent. Try IP instead of hostname. |
| Build works, runtime crashes | TypeScript type erasure hiding runtime issue | Check `as` casts — they don't validate at runtime. Add runtime validation at boundaries. |

### Debugging Toolkit

```bash
# Node inspector (Chrome DevTools)
node --inspect-brk script.js
# Open chrome://inspect

# Bun debugger
bun --inspect script.ts

# Trace async operations
node --trace-warnings script.js

# Memory debugging
node --max-old-space-size=512 --expose-gc script.js

# Find what's listening on a port
lsof -i :3000

# Trace DNS resolution
node -e "require('dns').resolve('hostname', console.log)"
```

### Async Debugging

```typescript
// Tag promises to trace which one fails
const results = await Promise.allSettled([
  fetchUsers().then(r => ({ source: 'users', data: r })),
  fetchOrders().then(r => ({ source: 'orders', data: r })),
]);
const failures = results.filter(r => r.status === 'rejected');
// Now you know WHICH promise failed, not just "one of them"
```

---

## Python

### Common Failure Modes

| Symptom | Likely Cause | Investigation |
|---------|-------------|---------------|
| `ImportError: No module named X` | Wrong venv, missing dependency, circular import | `which python`, `pip list`, check `sys.path` |
| `AttributeError: 'NoneType'` | Function returned None unexpectedly | Check every function in the chain — which one returns None? |
| `asyncio.TimeoutError` | Await never completes, deadlock | Add timeout to individual awaits. Check if task is blocked on sync I/O. |
| Silent data corruption | Mutable default arguments, shared state | `def f(items=[])` — the list is shared across calls. Use `None` default. |
| `RecursionError` | Circular references, missing base case | `sys.setrecursionlimit()` won't fix a real bug. Find the cycle. |
| SQLAlchemy lazy load outside session | Detached instance accessed after session close | Use `eager_load`, `joinedload()`, or access within session context. |
| Tests pass locally, fail in CI | Different Python version, missing env vars, file path differences | Check `python --version`, env vars, `/tmp` vs local paths. |

### Debugging Toolkit

```bash
# Interactive debugger
python -m pdb script.py
# Or insert: import pdb; pdb.set_trace()

# Better debugger
pip install ipdb
# Insert: import ipdb; ipdb.set_trace()

# Trace all function calls
python -m trace --trace script.py

# Profile performance
python -m cProfile -s cumulative script.py

# Memory profiling
pip install memory-profiler
python -m memory_profiler script.py

# Check what's in a venv
pip list --format=columns
python -c "import sys; print(sys.prefix)"
```

---

## React / Frontend

### Common Failure Modes

| Symptom | Likely Cause | Investigation |
|---------|-------------|---------------|
| Infinite re-render loop | useEffect dependency array wrong, state set in render | React DevTools Profiler. Check useEffect deps. Check if setState is called unconditionally in render. |
| Stale closure | useState value captured in old closure | Use `useRef` for mutable values, or functional setState `setState(prev => prev + 1)`. |
| Hydration mismatch (SSR) | Client renders different content than server | Check `Date.now()`, `Math.random()`, `window` access during SSR. Use `useEffect` for client-only. |
| "Cannot update unmounted component" | Async operation completes after unmount | Abort controller in useEffect cleanup. Check race conditions. |
| CSS not applying | Specificity war, wrong selector, CSS modules scope | DevTools Elements panel → Computed styles. Check class name is correct (CSS modules hash). |
| Build succeeds, blank page | JS error in render, missing environment variable | Browser console. Check `NEXT_PUBLIC_` / `VITE_` env var prefix. |
| API call fires twice | React StrictMode double-render in dev | Normal in dev. Check useEffect cleanup function. |

### Debugging Toolkit

```bash
# React DevTools (Chrome/Firefox extension)
# Components tab: inspect props, state, hooks
# Profiler tab: find unnecessary re-renders

# Why did this render?
# React DevTools → Profiler → "Record why each component rendered"

# Network debugging
# DevTools → Network → filter by XHR/Fetch → check request/response
```

```typescript
// Debug re-renders
import { useRef, useEffect } from 'react';

function useWhyDidYouRender(name: string, props: Record<string, any>) {
  const prev = useRef(props);
  useEffect(() => {
    const changes: Record<string, { from: any; to: any }> = {};
    for (const key of Object.keys({ ...prev.current, ...props })) {
      if (prev.current[key] !== props[key]) {
        changes[key] = { from: prev.current[key], to: props[key] };
      }
    }
    if (Object.keys(changes).length) {
      console.log(`[${name}] re-rendered:`, changes);
    }
    prev.current = props;
  });
}
```

---

## Docker / Infrastructure

### Common Failure Modes

| Symptom | Likely Cause | Investigation |
|---------|-------------|---------------|
| Container exits immediately | Entrypoint crashes, missing env var | `docker logs <container>`. Check `CMD` vs `ENTRYPOINT`. |
| Port not accessible | Port not published, firewall, wrong bind address | `docker port <container>`. Check `-p` flag. Check `0.0.0.0` vs `127.0.0.1`. |
| "Permission denied" in container | File ownership mismatch, read-only filesystem | Check `USER` in Dockerfile. Check volume mount permissions. |
| Build cache not working | Layer ordering wrong, COPY before dependency install | Put `COPY package.json` + `RUN install` before `COPY . .` |
| DNS resolution fails between containers | Not on same network, using localhost instead of service name | `docker network ls`. Use service name, not localhost. Check `docker-compose` network. |
| Works in docker-compose, fails in prod | Missing env vars, different network topology, volume paths | Compare env vars, network config, volume mounts between environments. |

### Debugging Toolkit

```bash
# Shell into running container
docker exec -it <container> /bin/sh

# Check container logs
docker logs -f --tail 100 <container>

# Inspect container config
docker inspect <container> | jq '.[0].Config.Env'
docker inspect <container> | jq '.[0].NetworkSettings'

# Check what's using a port
docker ps --format "{{.Names}}: {{.Ports}}"

# Debug network between containers
docker exec <container> ping <other-container>
docker exec <container> nslookup <service-name>
```

---

## Database / SQL

### Common Failure Modes

| Symptom | Likely Cause | Investigation |
|---------|-------------|---------------|
| Query slow (>1s) | Missing index, full table scan, N+1 | `EXPLAIN ANALYZE`. Check index usage. Look for sequential scans on large tables. |
| Deadlock | Competing transactions lock rows in different order | Check lock ordering. Use consistent access patterns. Smaller transactions. |
| Connection pool exhausted | Connections not returned, pool too small, long transactions | Check pool `max` size. Check for leaked connections (missing `.release()`). |
| Data appears stale | Read replica lag, caching, transaction isolation | Check `READ COMMITTED` vs `REPEATABLE READ`. Check if reading from replica. |
| Migration fails | Column already exists, data constraint violation | Run migration in transaction. Check for existing data that violates new constraint. |

### Debugging Toolkit

```sql
-- Explain query plan
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT ...;

-- Find slow queries (Postgres)
SELECT query, mean_exec_time, calls FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 10;

-- Check active connections
SELECT pid, state, query, query_start FROM pg_stat_activity WHERE state != 'idle';

-- Check locks
SELECT pid, relation::regclass, mode, granted FROM pg_locks WHERE NOT granted;

-- Index usage
SELECT relname, idx_scan, seq_scan FROM pg_stat_user_tables ORDER BY seq_scan DESC;
```

---

## General: The Bisection Method

When you can't trace the bug, bisect it:

```bash
# Git bisect: find which commit introduced the bug
git bisect start
git bisect bad              # current commit is broken
git bisect good abc123      # this commit was working
# Git checks out middle commit — test it, mark good/bad, repeat
git bisect good  # or  git bisect bad
# Repeat until git finds the exact commit

# Automated bisect
git bisect run npm test     # runs test at each commit automatically
```

### Manual bisection (non-git):
1. Comment out half the code/config
2. Does it still fail? → bug is in the remaining half
3. Doesn't fail? → bug is in the removed half
4. Repeat on the half that has the bug
5. 10 iterations covers 1024 possibilities → you'll find it
