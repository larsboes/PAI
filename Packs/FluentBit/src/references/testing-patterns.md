# Testing Patterns for FluentBit

In-pipeline assertion framework using FluentBit itself as the test runner.

## Core Concept: In-Band Assertions

Test expectations travel INSIDE the record through the pipeline:

```json
{
  "source_ip": "203.0.113.42",
  "_test_name": "EU-West 5-digit",
  "_test_expected_source.region.code": "EU-W1"
}
```

- `_test_name` — Human-readable test case identifier
- `_test_expected_<fieldname>` — Expected value after the filter runs
- The real filter ignores `_test_*` fields (unknown, passes through)
- The assert filter runs AFTER and compares

## Pipeline Assembly (3-Stage Assertion)

```yaml
pipeline:
  inputs:
    - name: tail
      path: test_input.jsonl
      parser: json
      tag: test
      read_from_head: true
      exit_on_eof: true

  filters:
    # Stage 1: The REAL filter (as in production)
    - name: lua
      match: test
      script: filters/enrich.lua
      call: cb_filter

    # Stage 2: Hierarchy invariant check
    - name: lua
      match: test
      script: tests/hierarchy_validator.lua
      call: cb_validate_hierarchy

    # Stage 3: Value assertions
    - name: lua
      match: test
      script: tests/assert_filter.lua
      call: cb_assert

  outputs:
    - name: stdout
      match: test
      format: json_lines
```

## Assert Filter Implementation

```lua
-- assert_filter.lua
local failures = {}
local sentinel = newproxy(true)
getmetatable(sentinel).__gc = function()
    if #failures > 0 then
        for _, msg in ipairs(failures) do
            io.stderr:write("FAIL: " .. msg .. "\n")
        end
        os.exit(1)
    end
end

function cb_assert(tag, ts, record)
    for key, expected in pairs(record) do
        if key:sub(1, 15) == "_test_expected_" then
            local actual_key = key:sub(16)
            local actual = record[actual_key]
            if tostring(actual) ~= tostring(expected) then
                local msg = string.format("[%s] %s: expected '%s', got '%s'",
                    record["_test_name"] or "?", actual_key,
                    tostring(expected), tostring(actual))
                table.insert(failures, msg)
            end
        end
    end

    -- Clean _test_* fields
    local clean = {}
    for k, v in pairs(record) do
        if k:sub(1, 6) ~= "_test_" then clean[k] = v end
    end
    return 1, ts, clean
end
```

**Why GC finalizer?** FluentBit has no "last record" callback. The `newproxy(true)` with `__gc` fires when Lua state tears down, propagating failures to exit code.

## Hierarchy Validator

Domain-specific invariant: Level N requires Level N-1 to be filled.

```lua
-- hierarchy_validator.lua
local rules = {
    {"service.platform",  "service.category"},
    {"service.name.0",    "service.platform"},
    {"service.name.1",    "service.name.0"},
    {"service.name.2",    "service.name.1"},
}
local prefixes = {"source_", "dest_", "session_source_", "session_dest_"}

function cb_validate_hierarchy(tag, ts, record)
    for _, prefix in ipairs(prefixes) do
        for _, rule in ipairs(rules) do
            local child = prefix .. rule[1]
            local parent = prefix .. rule[2]
            if record[child] and record[child] ~= ""
               and (not record[parent] or record[parent] == "") then
                io.stderr:write(string.format(
                    "HIERARCHY VIOLATION: %s set but %s empty (test: %s)\n",
                    child, parent, record["_test_name"] or "?"))
                os.exit(1)
            end
        end
    end
    return 1, ts, record
end
```

## Test Data Formats

### CSV (tabular, mass test data)

```csv
name, source_ip, expected_source.region.code, expected_source.region.name
"EU-West", "203.0.113.42", "EU-W1", "EU-West"
"US-East", "198.51.100.10", "US-E1", "US-East"
"Invalid IP", "123", "", ""
```

A build step (`luajit build.lua`) converts CSV → JSON-Lines with `_test_expected_` prefix.

### Lua Direct (programmatic, complex cases)

```lua
-- tests/data/sites_positions.lua
local positions = {
    {"request.upstream.host", "upstream"},
    {"request.origin.host", "origin"},
}
local cases = {}
for _, pos in ipairs(positions) do
    table.insert(cases, {
        name = string.format("Host on %s", pos[2]),
        input = { [pos[1]] = "api-gateway-01" },
        expected = { [pos[2] .. ".geo.lat"] = 37.7749 }
    })
end
return cases
```

## CI Pipeline

```yaml
.fluentbit_test:
  image:
    name: fluent/fluent-bit:4.2.2-debug
    entrypoint: ["/bin/sh", "-c"]

test-filters:
  extends: .fluentbit_test
  parallel:
    matrix:
      - FILTER: [enrich, normalize, transform, validate, route]
  script:
    - |
      FAILED=0
      for config in tests/configs/$FILTER/*.yaml; do
        echo "  $(basename $config)"
        fluent-bit -c "$config" || FAILED=1
      done
      [ "$FAILED" -eq 0 ] || exit 1
  artifacts:
    when: always
    paths:
      - tests/results/
```

**Key:** Let ALL tests run, report failures at the end. `artifacts: when: always` preserves output even on failure.

## Comparison: FluentBit vs Logstash Testing

| | FluentBit | Logstash |
|---|---|---|
| Startup | <100ms | ~12 seconds (JVM) |
| Test runner | FluentBit itself | Separate tool or hacky stdin |
| Assertions | In-pipeline (`assert_filter.lua`) | Post-hoc diff or external |
| Error messages | `[TestName] field: expected 'X', got 'Y'` | Line diff (which field?) |
| Mocking needed | No — real runtime | No — but slow |
| CI image | `fluent-bit:4.2.2-debug` (needs shell) | `logstash:8.10.0` (has shell) |
