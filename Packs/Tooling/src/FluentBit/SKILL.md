---
name: FluentBit
description: "FluentBit Lua filter development, testing, and CI patterns with Lua 5.1/LuaJIT semantics. Use when writing Lua filters, testing FluentBit configs, or debugging flat-key issues."
---

# FluentBit + Lua

Lua filter development for FluentBit (LuaJIT 2.1 / Lua 5.1 semantics).

## Quick Reference

- **Entry point:** `function cb_filter(tag, ts, record)` — called per-record
- **Return codes:** -1=drop, 0=unchanged, **2=modified** (standard), 1=modified+new timestamp
- **#1 rule:** Flat dot-keys only (`record["a.b"] = x`), NEVER nested tables
- **Testing:** FluentBit itself as test runner (<100ms startup), `exit_on_eof: true`
- **CI image:** `fluent/fluent-bit:4.2.2-debug` (standard image has no shell)

## References

| Need | File |
|------|------|
| Filter API, return codes, lifecycle, config | [references/lua-filter-api.md](references/lua-filter-api.md) |
| In-pipeline assertion framework, CI | [references/testing-patterns.md](references/testing-patterns.md) |
| **Flat keys — the #1 error explained** | [references/flat-keys.md](references/flat-keys.md) |
| Ruby→Lua translation (20 patterns) | [references/rosetta-stone.md](references/rosetta-stone.md) |
| Curated bug collection (real errors) | [references/mistake-museum.md](references/mistake-museum.md) |
| Lua 5.1 gotchas for devs from other langs | [references/lua-gotchas.md](references/lua-gotchas.md) |
| Lua string patterns (NOT regex!) | [references/lua-string-patterns.md](references/lua-string-patterns.md) |
| FluentBit debugging techniques | [references/debugging.md](references/debugging.md) |
| CI pipeline patterns | [references/ci-pipeline.md](references/ci-pipeline.md) |

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/run-test.sh` | Run FluentBit test configs, report pass/fail per filter |
| `scripts/validate-flat-keys.lua` | Static check for nested table patterns in Lua files |

## External References

- [FluentBit Lua Filter Docs](https://docs.fluentbit.io/manual/data-pipeline/filters/lua)
- [FluentBit Expect Filter](https://docs.fluentbit.io/manual/data-pipeline/filters/expect)
- [FluentBit Parsers](https://docs.fluentbit.io/manual/data-pipeline/parsers)
- [Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/)
- [LuaJIT Extensions](https://luajit.org/extensions.html)
- Knowledge base (48 files): `~/Developer/knowledge-base/Areas/lua-fluentbit/`
