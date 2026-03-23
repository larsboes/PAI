# FluentBit Testing Patterns

Detailed patterns for testing Lua filters with FluentBit. Read when building a test setup or writing custom assertion filters.

## Custom Lua Assert Filter

FluentBit's `expect` filter can't do per-record string value assertions. Solution: a Lua filter that reads `_test_expected_*` fields from the record and compares them.

### Convention

Test input records carry their own expectations as fields:

```json
{
  "first_leg_calling_party_number": "4922112345678",
  "_test_name": "Köln 5-stellig",
  "_test_expected_calling_party.vorwahl": "49221",
  "_test_expected_calling_party.ortsnetzname": "Köln"
}
```

- `_test_name` — Human-readable test case identifier
- `_test_expected_<fieldname>` — Expected value for `<fieldname>` after the filter runs
- The real filter ignores `_test_*` fields (unknown fields pass through)
- The assert filter runs AFTER the real filter and compares

### Assert Filter Implementation

```lua
-- assert_filter.lua
-- Runs after the real filter in the FluentBit pipeline.
-- Compares _test_expected_* fields against actual values.

local failures = {}

function cb_assert(tag, ts, record)
  for key, value in pairs(record) do
    if key:sub(1, 15) == "_test_expected_" then
      local actual_key = key:sub(16)
      local actual = record[actual_key]
      if tostring(actual) ~= tostring(value) then
        local msg = string.format("[%s] %s: expected '%s', got '%s'",
          record._test_name or "?", actual_key,
          tostring(value), tostring(actual))
        table.insert(failures, msg)
        print("FAIL: " .. msg)
      end
    end
  end

  -- Clean up _test_* fields from the record
  local clean = {}
  for k, v in pairs(record) do
    if k:sub(1, 6) ~= "_test_" then clean[k] = v end
  end

  -- Exit with failure if assertions failed
  if #failures > 0 then
    os.exit(1)
  end

  return 1, ts, clean
end
```

### Pipeline Assembly

```yaml
pipeline:
  inputs:
    - name: tail
      path: test_input.json
      parser: json
      tag: test
      read_from_head: true
      exit_on_eof: true

  filters:
    # 1. The real filter (as in production)
    - name: lua
      match: test
      script: filters/geolocation.lua
      call: cb_filter

    # 2. Value assertions (our framework)
    - name: lua
      match: test
      script: tests/framework/assert_filter.lua
      call: cb_assert

    # 3. Structural checks (FluentBit built-in)
    - name: expect
      match: test
      key_exists: calling_party.vorwahl
      action: exit

  outputs:
    - name: stdout
      match: test
      format: json_lines
```

## Hierarchy Validator

For domain-specific invariants that apply to ALL records (not per-test-case). Example: the 5-level service hierarchy where level N requires level N-1 to be filled.

```lua
-- hierarchy_validator.lua

local rules = {
  {"service.platform",  "service.category"},
  {"service.name.0",    "service.platform"},
  {"service.name.1",    "service.name.0"},
  {"service.name.2",    "service.name.1"},
}
local prefixes = {"calling_", "called_", "reg_calling_", "reg_called_"}

function cb_validate_hierarchy(tag, ts, record)
  for _, prefix in ipairs(prefixes) do
    for _, rule in ipairs(rules) do
      local child = prefix .. rule[1]
      local parent = prefix .. rule[2]
      if record[child] and record[child] ~= ""
         and (not record[parent] or record[parent] == "") then
        print(string.format("HIERARCHY VIOLATION: %s set but %s empty", child, parent))
        os.exit(1)
      end
    end
  end
  return 1, ts, record
end
```

Insert as a filter between the real filter and the assert filter in the pipeline config.

## Test Data Formats

### CSV (for tabular, mass test data)

```csv
# tests/data/geolocation/onkz_basic.csv
# Geolocation: Vorwahl-Erkennung für verschiedene Längen
#
name, first_leg_calling_party_number, expected_calling_party.vorwahl, expected_calling_party.ortsnetzname
"Köln 5-stellig", "4922112345678", "49221", "Köln"
"Berlin 4-stellig", "493012345678", "4930", "Berlin"
"Empty Input", "", "", ""
```

Convention: `expected_` prefix marks output fields. A build step converts CSV to JSON-Lines input with `_test_expected_` prefix fields.

### Lua Direct (for programmatic, complex test data)

```lua
-- tests/data/geolocation/sites_positions.lua
local positions = {
  {"common_first_leg_destination_network_element",  "first_leg"},
  {"common_last_leg_source_network_element",        "last_leg"},
}

local cases = {}
for _, pos in ipairs(positions) do
  table.insert(cases, {
    name = string.format("Site auf %s", pos[2]),
    input = { [pos[1]] = "hmb022-sbc-01" },
    expected = { [pos[2] .. ".geo"] = {10.0153, 53.5879} }
  })
end
return cases
```

Use Lua when: loops over positions, conditional logic, bug-history context in comments, cross-module tests.

## Build Step

A build script converts test data (CSV/Lua) into:
1. **JSON-Lines input files** — for FluentBit `tail` input
2. **FluentBit YAML configs** — pipeline definition with real filter + assert + expect

The build step is the only place where format conversion happens. No abstract converter architecture needed.
