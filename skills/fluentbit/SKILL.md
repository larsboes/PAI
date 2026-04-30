---
name: fluentbit
description: "Use when writing or editing FluentBit configs (YAML/conf), Lua filters for FluentBit, FluentBit CI pipelines, or testing Lua filters with FluentBit. Also use when debugging FluentBit Lua filter behavior, return codes, or field mapping issues."
---

# FluentBit + Lua

FluentBit Lua filter development, testing, and CI patterns. Lua 5.1/LuaJIT semantics.

## Lua Filter API

Every FluentBit Lua filter needs at minimum a `cb_filter` function:

```lua
function cb_filter(tag, timestamp, record)
    -- record is a Lua table (flat key-value pairs)
    -- Modify record as needed
    record["new_field"] = "value"

    -- Return: code, timestamp, record
    return 1, timestamp, record
end
```

### Return Codes (critical - get these wrong and records vanish or stay stale)

| Code | Meaning | When to use |
|------|---------|-------------|
| **0** | Keep record unchanged | No modifications needed |
| **1** | Record modified, use new record | Standard enrichment path |
| **2** | Drop record entirely | Filtering out unwanted records |

### Lifecycle Callbacks

```lua
-- Called once when FluentBit loads the filter (optional)
function cb_init()
    -- Load lookup tables, parse JSON files, initialize state
    return 0  -- 0 = success
end

-- Called on FluentBit shutdown (optional, rarely needed)
function cb_exit()
end
```

## The #1 Structural Error: Flat Keys vs. Nested Tables

**This is the most dangerous mistake when writing FluentBit Lua filters.**

FluentBit records use **flat dot-notation strings** as keys. These are NOT nested Lua tables - the dot is part of the key string.

```lua
-- CORRECT: Flat key (how Elasticsearch/FluentBit works)
record["calling_party.vorwahl"] = "49221"
record["calling_party.ortsnetzname"] = "Köln"

-- WRONG: Nested table (looks right, breaks everything)
record["calling_party"] = { vorwahl = "49221", ortsnetzname = "Köln" }
-- This creates ONE key "calling_party" with a table value,
-- NOT two flat keys. Elasticsearch will reject or mismap this.
```

**Why this happens**: LLMs see `calling_party.vorwahl` and infer an object path (correct in JavaScript, Python dicts). In FluentBit/Elasticsearch, the dot is literal.

**How to catch it**: Assert against the exact flat key strings in tests. If `record["calling_party.vorwahl"]` is nil but the filter "worked", it probably created a nested table instead.

## FluentBit YAML Config Structure

```yaml
service:
  flush: 1
  daemon: off
  log_level: info

pipeline:
  inputs:
    - name: tail           # or stdin, dummy, kafka, etc.
      path: /path/to/input.json
      parser: json
      tag: my_tag
      read_from_head: true
      exit_on_eof: true    # Exit after processing all input (for testing/batch)

  filters:
    - name: lua
      match: my_tag        # Which tagged records to process
      script: /path/to/filter.lua
      call: cb_filter      # Function name to call

    - name: expect         # Built-in assertion filter
      match: my_tag
      key_exists: some_field
      action: exit         # exit = non-zero exit code on failure

  outputs:
    - name: stdout
      match: "*"
      format: json_lines
```

## Testing with FluentBit

Use FluentBit itself as the test runner - no mocks, no shims. FluentBit starts in < 100ms (not a JVM).

### Key Patterns

**`exit_on_eof: true`** - Makes FluentBit process all input then exit. Turns a daemon into a batch tool.

**`expect` filter** - Built-in assertions:
```yaml
- name: expect
  match: test
  key_exists: field_name      # Field must exist
  key_not_exists: bad_field   # Field must NOT exist
  key_val_eq: field_name 42   # Field must equal number (numbers only!)
  action: exit                # exit = fail pipeline, warn = log only
```

Limitations of `expect`: No string comparison, no per-record different expectations. For value assertions per record, use a custom Lua assert filter (see [references/testing-patterns.md](references/testing-patterns.md)).

**Test execution**: `fluent-bit -c test_config.yaml` — Exit code 0 = pass, non-zero = fail.

## CI with FluentBit

FluentBit ships as a **distroless Docker image** (no shell). Use the `-debug` variant for CI:

```yaml
# GitLab CI
variables:
  FLUENT_BIT_VERSION: 4.2.2

.fluentbit_test:
  image:
    name: fluent/fluent-bit:$FLUENT_BIT_VERSION-debug
    entrypoint: ["/bin/sh", "-c"]
  before_script:
    - export PATH="/fluent-bit/bin:$PATH"
    - fluent-bit --version

test:
  extends: .fluentbit_test
  script:
    - fluent-bit -c test_config.yaml
```

## Lua 5.1/LuaJIT Gotchas in FluentBit

FluentBit embeds LuaJIT 2.1 which implements **Lua 5.1** semantics:

| Gotcha | Detail |
|--------|--------|
| **No `continue`** | Use `goto` (LuaJIT extension) or restructure with `if` |
| **1-indexed** | Arrays start at 1, not 0 |
| **`#table` unreliable** | Only works for sequence tables (no gaps). Use `next(t) == nil` for empty check |
| **`pairs()` unordered** | Key iteration order is not guaranteed |
| **No `+=`** | Write `x = x + 1` |
| **`0` is truthy** | Only `nil` and `false` are falsy |
| **No bitwise operators** | Use `bit` library: `bit.band()`, `bit.bor()`, `bit.lshift()` |
| **String immutable** | `string.gsub()` returns new string, doesn't modify in place |
| **No `os.execute()` in FluentBit** | Sandboxed - no shell access from filters |

### JSON handling in FluentBit Lua

FluentBit doesn't provide a JSON library in Lua. For loading JSON reference files:

```lua
-- Option 1: Use cjson if available (often included in OpenResty/LuaJIT)
local cjson = require("cjson")
local data = cjson.decode(json_string)

-- Option 2: Read file and use FluentBit's record parsing
-- (load JSON as input, process in filter)
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Nested tables instead of flat dot-keys | Always use `record["a.b.c"]` not `record.a.b.c` |
| Return code 0 when record was modified | Return 1 (modified) or record changes are lost |
| Forgetting `exit_on_eof` in test configs | FluentBit runs forever as daemon without it |
| Using standard FluentBit image in CI | Use `-debug` variant (has shell) |
| Loading large files in `cb_filter` | Load once in `cb_init`, store in module-level variable |
| Assuming `pairs()` order | Lua tables are unordered - don't depend on iteration order |
| Using `#record` to count fields | `#` only works on sequences. Use explicit counter |

## Red Flags

If you catch yourself thinking any of these, stop and re-read this skill:

- "I'll structure the record as a nested object" → **NO.** Flat dot-notation keys.
- "Return 0 should be fine, I modified the record" → **NO.** Return 1 for modifications.
- "I'll just use `require('json')`" → **Check** if cjson is available in the FluentBit build.
- "Let me mock FluentBit in pure Lua for faster tests" → **Don't.** FluentBit starts fast enough. Test through the real runtime.
- "The `-debug` image is just for debugging" → **No.** It's required for CI (distroless base has no shell).

## References

- [**references/testing-patterns.md**](references/testing-patterns.md) — Custom Lua assert filter, hierarchy validator, test data patterns (CSV + Lua), build step details
- [FluentBit Lua Filter Docs](https://docs.fluentbit.io/manual/data-pipeline/filters/lua)
- [FluentBit Expect Filter Docs](https://docs.fluentbit.io/manual/data-pipeline/filters/expect)
- [FluentBit Local Testing Guide](https://docs.fluentbit.io/manual/local-testing/validating-your-data-and-structure)
