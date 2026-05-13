# Test Lua Filter

Run FluentBit itself as the test runner — no external test framework needed.

## Approach

FluentBit starts in <100ms. Use it directly with `exit_on_eof: true` to process a test input file and compare output against expected.

## Test Config Template

```yaml
service:
  flush: 1
  daemon: off
  log_level: info
  exit_on_eof: true

pipeline:
  inputs:
    - name: tail
      path: /fluent-bit/tests/input.ndjson
      parser: json
      tag: test
      read_from_head: true

  filters:
    - name: lua
      match: test
      script: /fluent-bit/scripts/your_filter.lua
      call: cb_filter

  outputs:
    - name: stdout
      match: "*"
      format: json_lines
```

## Test Input Format

One JSON object per line (NDJSON):
```json
{"source.field": "value1", "other.field": "data"}
{"source.field": "value2", "other.field": "more"}
```

## Running Tests Locally

```bash
# Docker (matches CI exactly)
docker run --rm \
  -v $(pwd)/scripts:/fluent-bit/scripts:ro \
  -v $(pwd)/tests:/fluent-bit/tests:ro \
  -v $(pwd)/configs/test.yaml:/fluent-bit/etc/fluent-bit.yaml:ro \
  fluent/fluent-bit:4.2.2-debug \
  /fluent-bit/bin/fluent-bit -c /fluent-bit/etc/fluent-bit.yaml

# Or use the helper script
./scripts/run-test.sh configs/test.yaml tests/input.ndjson
```

## Evaluating Output

Compare stdout JSON against expected:
```bash
# Pipe output to jq for field extraction
docker run ... | jq -r '.["target.field"]'

# Or diff against expected output
docker run ... > actual.ndjson
diff <(jq -S . expected.ndjson) <(jq -S . actual.ndjson)
```

## CI Image

Always use `fluent/fluent-bit:4.2.2-debug` — the standard image has no shell and can't be debugged.

## Debugging Test Failures

1. Set `log_level: debug` in service section
2. Add a stdout output with `format: json_lines` to see intermediate state
3. Check for flat-key violations: `scripts/validate-flat-keys.lua`
4. Common issue: field doesn't exist at filter stage (check pipeline ordering)
