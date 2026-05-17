# FluentBit Lua Filter API

## cb_filter — The Core Function

```lua
function cb_filter(tag, timestamp, record)
    -- tag:       String, e.g. "access.nginx"
    -- timestamp: FluentBit timestamp (seconds since epoch)
    -- record:    Lua table with flat key-value pairs
    record["new_field"] = "value"
    return 2, 0, record
end
```

### Return Codes

| Code | Meaning | When to use |
|------|---------|-------------|
| **-1** | Drop record entirely | Filtering out unwanted records |
| **0** | Keep record unchanged | No modifications needed (**changes DISCARDED!**) |
| **1** | Record AND timestamp modified | When you also change the timestamp |
| **2** | Record modified, keep original timestamp | **Standard enrichment path** |

### cb_init — One-Time Initialization

```lua
local lookup = {}  -- module-level, persists between cb_filter calls

function cb_init()
    local f = io.open("/data/routes.json", "r")
    if f then lookup = parse(f:read("*a")); f:close() end
end

function cb_filter(tag, ts, record)
    -- lookup is available and already loaded
    if record["key"] and lookup[record["key"]] then
        record["result"] = lookup[record["key"]]
        return 2, 0, record
    end
    return 0, 0, {}
end
```

## THE #1 STRUCTURAL ERROR: Flat Keys

FluentBit records use **flat dot-notation strings** as keys. The dot is literal, NOT an object path.

```lua
-- CORRECT: Flat key
record["request.method"] = "GET"
record["source.region.code"] = "us-east-1"

-- WRONG: Nested table (silent Elasticsearch mapping conflict!)
record["request"] = { method = "GET" }
record["source"] = { region = { code = "us-east-1" } }
```

**Why dangerous:** No runtime error. Breaks silently in Elasticsearch with mapping conflicts.
**Why LLMs fail:** They see dots and infer object paths (correct in JS/Python, wrong here).

## FluentBit YAML Config

```yaml
service:
  flush: 1
  daemon: off
  log_level: info

pipeline:
  inputs:
    - name: tail
      path: /path/to/input.json
      parser: json
      tag: my_tag
      read_from_head: true
      exit_on_eof: true       # Batch mode — exit after processing

  filters:
    - name: lua
      match: my_tag
      script: /path/to/filter.lua
      call: cb_filter

  outputs:
    - name: stdout
      match: "*"
      format: json_lines
```

## Lua 5.1/LuaJIT Gotchas

| Gotcha | Detail |
|--------|--------|
| No `continue` | Use `goto continue` ... `::continue::` (LuaJIT extension) |
| 1-indexed arrays | `arr[1]` is first element, NOT `arr[0]` |
| `#table` unreliable | Only for contiguous arrays. Use `next(t) == nil` for empty |
| `pairs()` unordered | Key iteration order NOT guaranteed |
| No `+=` | Write `x = x + 1` |
| `0` is truthy | Only `nil` and `false` are falsy |
| `~=` not `!=` | Not-equal operator is `~=` |
| Strings immutable | Use `table.concat` in loops, not `s = s .. v` |
| No `require` | Sandboxed — self-contained scripts only |
| No `os.execute()` | No shell access from filters |

## CI with FluentBit

Standard image is **distroless** (no shell). Use `-debug` variant:

```yaml
.fluentbit_test:
  image:
    name: fluent/fluent-bit:4.2.2-debug
    entrypoint: ["/bin/sh", "-c"]
  before_script:
    - export PATH="/fluent-bit/bin:$PATH"
    - fluent-bit --version
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Nested tables in record | Always `record["a.b.c"]` not nested |
| Return 0 after modification | Changes **discarded**. Use return 2 |
| `io.open()` in cb_filter | Load in `cb_init`, store in module variable |
| Forgetting `exit_on_eof` | FluentBit runs forever as daemon |
| Standard image in CI | Use `-debug` variant (has shell) |
| `print()` for debugging | Use `io.stderr:write()` or `-vv` flag |

## References

- [FluentBit Lua Filter Docs](https://docs.fluentbit.io/manual/data-pipeline/filters/lua)
- [FluentBit Parsers](https://docs.fluentbit.io/manual/data-pipeline/parsers)
- [Lua 5.1 Manual](https://www.lua.org/manual/5.1/)
- [Lua PIL — Tables](https://www.lua.org/pil/2.5.html)
- Local knowledge base (if available): `${VAULT_PATH}/Areas/lua-fluentbit/`
