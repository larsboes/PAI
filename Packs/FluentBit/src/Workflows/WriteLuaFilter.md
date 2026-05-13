# Write Lua Filter

Guided workflow for writing a new FluentBit Lua filter from requirements.

## Steps

1. **Clarify the requirement** — What fields need to be read, transformed, or created?
2. **Scaffold the filter** using the template below
3. **Write the logic** following flat-key rules
4. **Write the test config** (inline, not separate test framework)
5. **Run and verify** using `scripts/run-test.sh`

## Filter Template

```lua
function cb_filter(tag, ts, record)
    -- Read fields (flat dot-key access)
    local value = record["source.field"]

    -- Guard: return unchanged if field missing
    if value == nil then
        return 0, 0, 0
    end

    -- Transform
    local result = value  -- your logic here

    -- Write result (flat dot-key)
    record["target.field"] = result

    -- Return: 2 = modified, 0 = keep timestamp, record
    return 2, 0, record
end
```

## Critical Rules

1. **Flat keys only** — `record["a.b.c"]`, never `record.a.b.c` or `record["a"]["b"]["c"]`
2. **Return code 2** for modifications — not 1 (that changes timestamp)
3. **Return 0, 0, 0** to pass through unchanged — not `return 0`
4. **nil check before operations** — missing fields in FluentBit return nil, not empty string
5. **No `require()`** — FluentBit sandbox doesn't support loading external modules
6. **String patterns, not regex** — Lua uses `%d`, `%a`, `%w` not `\d`, `\w`

## Config Integration

```yaml
pipeline:
  filters:
    - name: lua
      match: "your.tag.*"
      script: /fluent-bit/scripts/your_filter.lua
      call: cb_filter
```

## Common Patterns

### Split a field by delimiter
```lua
local parts = {}
for part in string.gmatch(record["source.field"], "([^|]+)") do
    parts[#parts + 1] = part
end
record["target.first"] = parts[1]
record["target.second"] = parts[2]
```

### Conditional field mapping
```lua
local mapping = {
    ["APP"] = "call_detail_record",
    ["SVC"] = "registration",
}
record["target.type"] = mapping[record["source.type"]] or "unknown"
```

### Delete a field
```lua
record["field.to.remove"] = nil
```

### Rename a field
```lua
record["new.name"] = record["old.name"]
record["old.name"] = nil
```
