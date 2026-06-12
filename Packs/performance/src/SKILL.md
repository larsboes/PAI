---
name: performance
description: "Performance profiling and optimization — systematic methodology for identifying bottlenecks in web apps, APIs, databases, and infrastructure. CPU/memory/IO profiling, flame graphs, load testing, and common bottleneck patterns. Use when performance, slow, profiling, bottleneck, latency, throughput, memory leak, CPU spike, load test, flame graph, optimize, benchmark."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
---

# Performance Profiling & Optimization

Guessing at performance problems wastes time and often makes things worse. Optimizing the wrong layer is the most common performance anti-pattern.

**Iron Law: MEASURE BEFORE YOU OPTIMIZE. NO EXCEPTIONS.**

If you haven't profiled, you cannot propose optimizations. Intuition about performance is wrong more often than it's right.

## Methodology: The Performance Cycle

Every performance investigation follows this loop:

```
MEASURE → PROFILE → IDENTIFY → FIX → VERIFY
   ↑                                    |
   └────────────────────────────────────┘
```

1. **Measure** — establish a baseline. Numbers, not feelings. Latency percentiles (p50/p95/p99), throughput (req/s), resource utilization (CPU/mem/disk IO).
2. **Profile** — instrument the specific layer under suspicion. Use the right tool for the right layer.
3. **Identify** — find the actual bottleneck. One bottleneck at a time. The system has ONE primary bottleneck — find it.
4. **Fix** — change ONE thing. Smallest possible change.
5. **Verify** — re-measure with the SAME methodology. Compare against baseline. Did p95 improve? Did throughput increase? If not measurable, it didn't help.

## Profiling by Layer

### Frontend

**Core Web Vitals** (the metrics that matter):

| Metric | What | Good | Tool |
|--------|------|------|------|
| LCP | Largest Contentful Paint | < 2.5s | Lighthouse, WebPageTest |
| INP | Interaction to Next Paint | < 200ms | Chrome DevTools Performance |
| CLS | Cumulative Layout Shift | < 0.1 | Lighthouse, Layout Shift Debugger |

**Common frontend bottlenecks:**
- Bundle size — `npx webpack-bundle-analyzer`, `npx vite-bundle-visualizer`
- Render blocking resources — check Network waterfall, defer/async scripts
- Excessive re-renders — React DevTools Profiler, `why-did-you-render`
- Unoptimized images — missing srcset, no lazy loading, wrong format (use WebP/AVIF)
- Layout thrashing — reading then writing DOM in loops (batch reads, then batch writes)

### API / Backend

**Request lifecycle profiling:**

```
Client → DNS → TCP → TLS → Server Processing → DB → Response → Client
         ↑ Network latency ↑   ↑ Your code ↑
```

**Common backend bottlenecks:**
- **N+1 queries** — single request triggers N database calls. Check query count per request. Fix with eager loading / DataLoader / batch queries.
- **Connection pool exhaustion** — requests queue waiting for DB/HTTP connections. Monitor pool size vs active connections.
- **Serialization overhead** — large JSON payloads, unnecessary fields. Profile with timing middleware.
- **Async bottlenecks** — awaiting sequentially when calls are independent. Use `Promise.all` / `asyncio.gather` / equivalent.
- **Missing caching** — repeated identical expensive computations. Add cache at the right layer (application > HTTP > CDN).
- **Slow middleware** — auth, logging, validation running on every request. Profile middleware chain individually.

**Diagnostic approach:**
1. Add timing middleware to measure total request duration
2. Log time spent in each phase (auth, validation, business logic, DB, serialization)
3. Check query count and query time per request
4. Profile connection pool utilization under load

### Database

**First steps for any slow query investigation:**

1. Enable slow query log (MySQL: `slow_query_log`, Postgres: `log_min_duration_statement`)
2. Run `EXPLAIN ANALYZE` on suspect queries — read the output carefully
3. Check for sequential scans on large tables
4. Look at lock contention (`pg_stat_activity`, `SHOW PROCESSLIST`)

**Common database bottlenecks:**

| Symptom | Likely Cause | Diagnostic | Fix |
|---------|-------------|------------|-----|
| Single slow query | Missing index | `EXPLAIN ANALYZE` | Add targeted index |
| All queries slow | Connection pool exhausted | Monitor active connections | Increase pool / fix leaks |
| Intermittent slowness | Lock contention | Check waiting queries | Reduce transaction scope |
| Slow writes | Too many indexes | Check index count per table | Remove unused indexes |
| Growing latency over time | Table bloat / stale stats | Check table size, `ANALYZE` | Vacuum / rebuild stats |
| High CPU on DB server | Full table scans | Slow query log + EXPLAIN | Add indexes, rewrite queries |

### Infrastructure

**System-level profiling:**

| Resource | Check | Tool |
|----------|-------|------|
| CPU | Utilization, steal time, context switches | `top`, `htop`, `mpstat`, `perf top` |
| Memory | Usage, swap, OOM kills | `free -h`, `vmstat`, `dmesg \| grep oom` |
| Disk IO | IOPS, latency, queue depth | `iostat -x`, `iotop` |
| Network | Bandwidth, latency, packet loss | `ss -s`, `nethogs`, `mtr` |
| Containers | Resource limits vs actual usage | `docker stats`, `kubectl top` |

**Container-specific gotchas:**
- CPU throttling from low limits — check `nr_throttled` in cgroup stats
- Memory limits causing OOM kills — `kubectl describe pod` or `docker inspect`
- nofile limits too low — connection-heavy apps hit fd limits silently

## Tools Quick Reference

| Tool | Language/Domain | What It Profiles | When to Use |
|------|----------------|------------------|-------------|
| `node --prof` | Node.js | CPU time per function | CPU-bound Node apps |
| `clinic.js` | Node.js | Doctor (overview), Flame (CPU), Bubbleprof (async) | First-pass Node profiling |
| `0x` | Node.js | Flame graphs from V8 profiler | Detailed Node CPU analysis |
| `cProfile` | Python | Function call counts and time | First-pass Python profiling |
| `py-spy` | Python | Sampling profiler, flame graphs | Production Python profiling (low overhead) |
| `memory_profiler` | Python | Line-by-line memory usage | Python memory leak hunting |
| `pprof` | Go | CPU, memory, goroutine, block | Go application profiling |
| `perf` | Linux | System-wide CPU, cache misses | Low-level system profiling |
| `wrk` | HTTP | Throughput, latency distribution | Quick HTTP load testing |
| `k6` | HTTP/WebSocket | Scriptable load tests with thresholds | Realistic load scenarios |
| `Lighthouse` | Browser | Performance, accessibility, SEO | Frontend audit |
| `Chrome DevTools` | Browser | Flame chart, memory, network | Interactive frontend profiling |
| `async-profiler` | JVM | CPU, allocation, lock, wall-clock | Java/Kotlin profiling |

## Common Bottleneck Patterns

| Symptom | Likely Cause | Diagnostic | Fix |
|---------|-------------|------------|-----|
| Latency increases linearly with data size | O(n) or worse algorithm | Profile hot path, check complexity | Better algorithm/data structure |
| Latency spikes every N minutes | GC pauses | GC logs, heap profiling | Tune GC, reduce allocation rate |
| High CPU, low throughput | Single-threaded bottleneck | Flame graph — find wide bars | Parallelize or offload to worker |
| Latency increases under load | Resource contention (locks, pools) | Monitor pool usage, lock waits | Increase pool, reduce lock scope |
| Memory grows over time | Memory leak | Heap snapshots at intervals | Find and fix retained references |
| First request slow, rest fast | Cold start / missing warmup | Time first vs subsequent requests | Add warmup, preload caches |
| Intermittent timeouts | Downstream dependency | Distributed tracing, timeout logs | Circuit breaker, retry with backoff |
| High disk IO, low CPU | Logging/disk writes on hot path | `iotop`, check write patterns | Async logging, buffer writes |
| Everything slow after deploy | Regression | Compare metrics before/after deploy | Bisect the deploy, rollback |

## Load Testing

### Test Types

| Type | Duration | Load Pattern | Purpose |
|------|----------|-------------|---------|
| **Smoke** | 1-2 min | Minimal load (1-5 VUs) | Verify test works, baseline |
| **Load** | 10-30 min | Expected traffic | Confirm SLOs under normal load |
| **Stress** | 10-30 min | Ramp beyond capacity | Find breaking point |
| **Spike** | 5-10 min | Sudden burst | Test auto-scaling, error handling |
| **Soak** | 1-4 hours | Sustained normal load | Find memory leaks, resource exhaustion |

### k6 Pattern

```javascript
// k6 load test skeleton
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 50 },   // ramp up
    { duration: '5m', target: 50 },   // hold
    { duration: '2m', target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests under 500ms
    http_req_failed: ['rate<0.01'],    // less than 1% failure rate
  },
};

export default function () {
  const res = http.get('http://localhost:3000/api/endpoint');
  check(res, {
    'status 200': (r) => r.status === 200,
    'body not empty': (r) => r.body.length > 0,
  });
  sleep(1); // think time — simulate real user pauses
}
```

### Load Testing Rules

1. **Test from outside your app** — not localhost-to-localhost in production
2. **Include think time** — real users pause between actions
3. **Use realistic data** — not the same request every time
4. **Monitor the system under test** — not just the load generator output
5. **Run multiple times** — single runs are noisy. Compare medians across runs.
6. **Set thresholds** — define pass/fail criteria before running

## Anti-Patterns

### Premature Optimization

Optimizing without profiling data. You think the bottleneck is in function X, but it's actually in the database call inside function Y. Profile first. Always.

### Optimizing the Wrong Layer

Your API is slow because of N+1 queries, but you're optimizing the JSON serialization. Check where time is actually spent before optimizing.

### Micro-Benchmarks That Lie

Benchmarking `Array.map` vs `for` loop in isolation tells you nothing about production performance. JIT warmup, GC pressure, cache effects, and real data sizes change everything. Benchmark at the integration level.

### Caching Without Invalidation Strategy

Adding a cache speeds things up until stale data causes bugs. Every cache needs: TTL, invalidation trigger, and a plan for cache stampede.

### Over-Indexing

Adding indexes for every slow query without checking existing ones. Each index slows writes and uses memory. Profile write patterns too.

### Ignoring Tail Latency

p50 looks great, p99 is 10x worse. Tail latency affects your most engaged users and cascades through microservices. Always check p95 and p99, not just averages.

## Quick Reference: Where to Start

| Scenario | First Step |
|----------|-----------|
| "The app is slow" | Add request timing middleware, identify slowest endpoints |
| "The page is slow" | Run Lighthouse, check Network waterfall |
| "The query is slow" | `EXPLAIN ANALYZE`, check for seq scans |
| "Memory keeps growing" | Heap snapshots at 1min intervals, compare retained objects |
| "CPU is high" | Flame graph — find the widest bars |
| "It's slow under load" | Load test with k6, monitor resource utilization simultaneously |
| "It was fast yesterday" | Compare metrics/deploys, `git log --since=yesterday` |
