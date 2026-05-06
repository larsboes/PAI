# PAI — Planned Work

*Last updated: 2026-05-06*

---

## ~~Unified Stats — Cross-Agent Usage Dashboard~~ ✅

**Done:** 2026-05-06
**Location:** `pi-mono/extensions/stats/`
**DB:** `~/.pai/stats.db`

Implemented as Option A — lives in pi-mono, DB at `~/.pai/stats.db`, both parsers active:
- `src/parsers/pi.ts` — reads `~/.pi/agent/sessions/*.jsonl`
- `src/parsers/claude-code.ts` — reads `~/.claude/projects/**/*.jsonl`

Results: 61.5k requests tracked, $3,996 total cost. Source breakdown in TUI (`/stats`) and web dashboard (`/stats dashboard`).

### Usage

In pi: `/stats`, `/stats 7d`, `/stats models`, `/stats dashboard`

Standalone: `cd pi-mono/extensions/stats && bun src/cli.ts`

---

## Future: Additional Agent Parsers

If Gemini Code or other AI coding tools get adopted, add a parser following the same pattern in `src/parsers/`. The aggregator calls all registered parsers during sync.
