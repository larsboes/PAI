# PAI — Planned Work

---

## Unified Stats — Cross-Agent Usage Dashboard

**Status:** Planned
**Priority:** Medium
**Effort:** Extended (~4h)

### Problem

`extensions/stats` (in pi-mono) only parses pi agent sessions (`~/.pi/agent/sessions/`). Claude Code stores sessions in a different format at `~/.claude/projects/*/`. Both are JSONL but with different schemas. There's no unified view of AI usage across tools.

### Goal

Move stats to the PAI layer (`~/.pai/`) so it aggregates usage from all AI agents: pi, Claude Code, and any future tool. One dashboard, one DB, one CLI.

### Design

```
~/.pai/stats.db              ← unified SQLite database
~/.pai/stats/                ← parsers + server (standalone Bun CLI)
  parsers/
    pi.ts                    ← current parser (reads ~/.pi/agent/sessions/)
    claude-code.ts           ← NEW: reads ~/.claude/projects/*/*.jsonl
  aggregator.ts
  server.ts
  client/                    ← React dashboard (unchanged)
```

### Claude Code Session Format

```jsonl
{"type":"assistant","message":{"model":"claude-haiku-4-5-20251001","usage":{"input_tokens":415,"cache_read_input_tokens":0,"output_tokens":10},"stop_reason":"end_turn"},"timestamp":...}
```

Field mapping: `input_tokens` → `input`, `output_tokens` → `output`, `cache_read_input_tokens` → `cacheRead`. No `duration`/`ttft`/`cost` fields in CC — duration calculable from timestamp deltas, cost derivable from model pricing table.

### Steps

1. Create `parsers/claude-code.ts` — walks `~/.claude/projects/*/`, parses `assistant` type entries, maps to `MessageStats`
2. Move stats from `pi-mono/extensions/stats/` to `~/.pai/stats/` (or keep in pi-mono but point DB to `~/.pai/stats.db`)
3. Update `aggregator.ts` — call both parsers during sync
4. Add model pricing table for cost estimation (CC doesn't report cost, pi does via provider)
5. Dashboard: add "Source" column (pi / claude-code) to models table and folder view
6. Update `link-extensions.sh` to handle stats DB path

### Decision: Where Does Stats Live?

**Option A:** Keep in `pi-mono/extensions/stats/`, just move DB to `~/.pai/stats.db` and add CC parser. Stats is still a Bun CLI, just reads from two sources.

**Option B:** Move stats entirely to `~/.pai/stats/` as a standalone PAI tool. Not tied to pi-mono at all.

Recommendation: **Option A** — simpler, stats is already working in pi-mono, just needs a second parser and DB path change. Avoids creating yet another repo/install target.

---

## Future: Gemini Code Session Parsing

If Gemini Code (or other AI coding tools) get adopted, add a parser following the same pattern. The aggregator is designed for N parsers.
