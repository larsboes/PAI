
# FluentBit Production Debugging

## The Problem

When a FluentBit pipeline breaks in production, you are often blind: records disappear silently, memory grows without explanation, or outputs fail intermittently. Standard logging is not enough. You need specialized tools to trace records through the pipeline, inspect buffer state at runtime, and preserve failed records for post-mortem analysis. Without these tools, debugging a production incident means guessing. See FluentBit Threading for the threading model that affects where bottlenecks occur and Monitoring for how to detect problems before they become incidents.

When a FluentBit pipeline breaks in production, you have three specialized tools — Tap (record tracing), Dump (buffer inspection), and DLQ (failed record preservation) — plus deep networking and buffering knowledge. This doc covers all of them.

Assumes familiarity with pipeline architecture, Lua filter API, the threading model, and ES output configuration. See also Advanced Patterns for production-grade filter patterns.


### Dump Internals — Buffer and Chunk Inspection

Dump Internals gives you a runtime snapshot: chunks in memory, overlimit inputs, task queue depth. The tool for diagnosing backpressure, memory growth, and stuck chunks.

**Triggering a dump:**

```bash
# On the host
kill -CONT $(pidof fluent-bit)

# In Docker (PID 1 is always fluent-bit)
docker exec <container> kill -CONT 1

# In Kubernetes
kubectl exec <pod> -- kill -CONT 1
```

> [!info] Output Location
> The dump appears in FluentBit's standard output (stdout), not in a separate file. If running as a systemd service, check `journalctl -u fluent-bit`. In Docker, check `docker logs <container>`.

**Example dump output (annotated):**

```
===== Input =====
tail.0 (tail)                          # plugin instance (plugin type)
├─ status
│  └─ overlimit: no                    # is mem_buf_limit exceeded?
│     ├─ mem size: 2.4M (2516582b)     # current memory usage
│     └─ mem limit: 10.0M (10485760b)  # configured mem_buf_limit
├─ tasks
│  ├─ total tasks: 3                   # chunks assigned to output
│  ├─ new: 1                           # waiting to be flushed
│  ├─ running: 2                       # actively flushing
│  └─ size: 1.8M (1887436b)           # total task memory
└─ chunks
   └─ total chunks: 5                  # chunks in this input's buffer
      ├─ up: 3                         # "up" = loaded in memory
      ├─ down: 2                       # "down" = on filesystem only
      └─ busy: 1                       # locked by an active flush

===== Storage Layer =====
total chunks: 12                       # across all inputs
├─ mem: 8                              # memory-only chunks
└─ fs: 4                               # filesystem-backed chunks
```

**What to look for:**

| Signal | Meaning | Action |
|--------|---------|--------|
| `overlimit: yes` | Input hit `mem_buf_limit`, is paused | Check output health, increase limit or add filesystem storage |
| High `down` chunks | Many chunks on disk, not in memory | Output is slow — chunks queue faster than they flush |
| `busy` chunks growing | Flushes are taking too long | Check network, output plugin config, increase workers |
| `new` tasks accumulating | Scheduler can't flush fast enough | Output is bottleneck — check connectivity and retry state |


## 2. Networking Internals

These settings control how FluentBit connects to outputs (especially ES). They apply per-output plugin.

### Connection Management

| Setting | Default | Description |
|---------|---------|-------------|
| `net.connect_timeout` | `10s` | Max time to establish a connection (includes TLS handshake) |
| `net.connect_timeout_log_error` | `true` | Log connection timeouts as errors (set `false` for noisy environments) |
| `net.io_timeout` | `0s` (disabled) | Max idle time for an assigned connection |
| `net.keepalive` | `true` | Reuse TCP connections across flushes |
| `net.keepalive_idle_timeout` | `30s` | Drop idle keepalive connections after this duration |
| `net.keepalive_max_recycle` | `2000` | Retire a connection after N reuses |
| `net.max_worker_connections` | `0` (unlimited) | Max TCP connections **per worker** |

> [!warning] Connection Multiplication
> `net.max_worker_connections` is **per worker**. If you configure 5 output workers and set `net.max_worker_connections: 10`, FluentBit opens up to **50 total connections** to that destination. Size your connection pools and load balancer limits accordingly. See FluentBit Threading for how workers relate to threads.

When `net.max_worker_connections` is reached, the output plugin does not open new connections — it queues the flush and retries when a connection becomes available.

Additionally, OS-level TCP keepalive probes (separate from FluentBit's application keepalive) are controlled by `net.tcp_keepalive` (default: `off`), `net.tcp_keepalive_time`, `net.tcp_keepalive_interval`, and `net.tcp_keepalive_probes`. Enable these when connecting through load balancers or firewalls that silently drop idle connections.

### DNS Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `net.dns.mode` | (none) | Transport protocol for DNS queries: `TCP` or `UDP` |
| `net.dns.resolver` | (none) | Resolver implementation: `LEGACY` or `ASYNC` |
| `net.dns.prefer_ipv4` | `false` | Prioritize IPv4 results |
| `net.dns.prefer_ipv6` | `false` | Prioritize IPv6 results |

> [!warning] LEGACY Resolver Blocks the Event Loop
> The `LEGACY` resolver performs **synchronous, blocking** DNS lookups. On a slow or unreliable DNS server, this blocks the entire worker thread — no records are processed until the lookup completes. Always use `ASYNC` in production.

```yaml
outputs:
  - name: es
    match: "*"
    net.dns.resolver: ASYNC
    net.dns.mode: UDP
    net.dns.prefer_ipv4: true
```

### TLS Configuration

| Setting | Description |
|---------|-------------|
| `tls` | Enable TLS (`on` / `off`) |
| `tls.verify` | Verify server certificate (`on` / `off`) |
| `tls.ca_file` | Path to CA certificate file |
| `tls.crt_file` | Path to client certificate (mutual TLS) |
| `tls.key_file` | Path to client private key (mutual TLS) |
| `tls.vhost` | Virtual hostname for SNI (Server Name Indication) |

> [!danger] Never Disable TLS Verification in Production
> Setting `tls.verify: off` in production exposes you to man-in-the-middle attacks. Use it only for local development with self-signed certificates.

**Other networking options:** `net.source_address` binds to a specific interface (multi-homed servers), `net.backlog` (default: `128`) sets the pending connection queue, and `net.proxy_env_ignore` (default: `false`) bypasses `HTTP_PROXY`/`HTTPS_PROXY`/`NO_PROXY` environment variables.


## 4. Scheduling and Retries

When a flush fails, the scheduler uses **exponential backoff with jitter** to prevent thundering herd problems.

**Service-level scheduler settings:**

| Setting | Default | Description |
|---------|---------|-------------|
| `scheduler.base` | `5` | Base seconds for backoff calculation |
| `scheduler.cap` | `2000` | Maximum wait time in seconds (~33 minutes) |

**Per-output retry settings:**

| Setting | Behavior |
|---------|----------|
| `retry_limit: N` | Retry up to N times (default: `1`) |
| `retry_limit: false` / `no_limits` | Retry indefinitely |
| `retry_limit: no_retries` | Never retry — fail immediately |

**Backoff formula:** `wait = random(base, min(base * 2^N, cap))`. With defaults: retry 1 waits 5-10s, retry 2 waits 5-20s, retry 4 waits 5-80s, retry 9+ caps at 5-2000s (~33 min max).

**What happens when retries are exhausted:**

1. If DLQ is enabled (`storage.keep.rejected: on`): chunk is written to the rejected directory
2. If DLQ is not enabled: chunk is **permanently dropped** — data is lost

> [!danger] Default Retry Limit Is 1
> With the default `retry_limit: 1`, a single transient failure causes permanent data loss (unless DLQ is enabled). For production, either set `retry_limit: false` for indefinite retries, or set a generous limit combined with DLQ.


## 6. Diagnostic Decision Tree

### Records Disappearing

```
Records missing from output
├─ Check Lua filter return codes
│  ├─ Returning 0? → Changes are silently discarded (return 1 for modifications)
│  ├─ Returning 2 or -1? → Records are explicitly dropped
│  └─ Return codes correct?
│     ├─ Use TAP to trace records through each pipeline stage
│     │  ├─ Type 1 present, Type 2 missing? → Filter is dropping the record
│     │  ├─ Type 1 = Type 2? → Filter isn't modifying (wrong match pattern?)
│     │  └─ Type 2 present, Type 3 missing? → Output match pattern issue
│     └─ Check `match` patterns on filters and outputs
│        └─ Records may not match any output (silently undelivered)
```

### Memory Growing Unbounded

```
Memory usage climbing
├─ Run DUMP (kill -CONT) to inspect chunks
│  ├─ overlimit: yes on inputs? → Output is slow, chunks accumulate
│  │  ├─ Check output connectivity and error logs
│  │  └─ Add filesystem storage to offload memory
│  ├─ High "up" chunk count? → storage.max_chunks_up too high
│  ├─ Many "busy" chunks? → Flushes are stuck (network issue)
│  └─ No obvious issue in dump?
│     ├─ Check mem_buf_limit on each input (is it set?)
│     ├─ Check output memory (JSON serialization doubles memory)
│     └─ Consider jemalloc (build with -DFLB_JEMALLOC=On)
```

### Output Errors

```
Output returning errors
├─ Check FluentBit logs for status codes
│  ├─ 400 Bad Request → Payload issue (ES mapping conflict, malformed JSON)
│  │  ├─ Enable DLQ to capture rejected records
│  │  ├─ Inspect DLQ files — correlate tag + status in filename
│  │  └─ For ES: check suppress_type_name, index template version
│  ├─ 401/403 → Authentication failure
│  │  └─ Check TLS certs, API keys, index permissions
│  ├─ 429 Too Many Requests → Rate limiting
│  │  └─ Reduce workers, increase flush interval, add backoff
│  └─ 503 Service Unavailable → Destination is down
│     ├─ Filesystem storage keeps data safe during outage
│     └─ Set retry_limit: false for indefinite retries
```

### CPU Bottleneck

```
CPU at 100% on FluentBit process
├─ Are Lua filters the bottleneck?
│  ├─ Filters run on the main pipeline thread (single-threaded)
│  ├─ Consider migrating heavy Lua to processors (if available)
│  └─ Optimize Lua: load files in cb_init, avoid string concat in loops
├─ Is multiline parsing expensive?
│  ├─ Complex regex patterns burn CPU on every line
│  └─ Simplify patterns or pre-process with a lighter tool
├─ Are inputs CPU-bound?
│  └─ Use threaded: on for CPU-intensive inputs (tail with heavy parsing)
└─ Profile with perf or strace to identify the hot path
```

### High Latency (Records Arrive Late)

```
Records delayed between ingestion and output
├─ Check flush interval
│  ├─ Default is 1 second — increase for throughput, decrease for latency
│  └─ flush: 0.5 for sub-second delivery (increases CPU)
├─ Check output worker count
│  ├─ Default is 0 (engine thread) — set workers: 2+ for parallelism
│  └─ More workers = more connections (see net.max_worker_connections)
├─ Check network and DNS
│  ├─ Use net.dns.resolver: ASYNC (LEGACY blocks event loop)
│  ├─ Check net.connect_timeout (default 10s may be too long)
│  └─ Enable net.tcp_keepalive through firewalls
└─ Consider compression
   └─ compress: gzip reduces transfer time on slow/congested links
```


## Key Takeaways

> [!tip] The Three Tools
> - **Tap** answers "what happened to my record?" — trace through input, filter, output stages
> - **Dump** answers "what's happening inside right now?" — chunk counts, memory, backpressure state
> - **DLQ** answers "what failed and why?" — preserves rejected records for analysis

> [!tip] Production Defaults Worth Changing
> - `retry_limit: 1` is too aggressive — set to `5+` or `false` with DLQ enabled
> - `net.dns.resolver` unset means LEGACY (blocking) — always set `ASYNC`
> - `storage.type: memory` loses data on crash — use `filesystem` for critical pipelines
> - `mem_buf_limit` unset means no limit — always set one to prevent OOM

> [!tip] The Debug Sequence
> 1. Check logs first (cheapest signal)
> 2. Dump internals for buffer state (no restart needed)
> 3. Tap for record tracing (requires restart with `-Z`)
> 4. DLQ for post-mortem on failed records (requires config change + restart)

