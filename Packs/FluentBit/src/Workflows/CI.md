# FluentBit CI Pipeline

GitLab CI patterns for testing Lua filters in a FluentBit container.

## Pipeline Structure

```yaml
stages:
  - validate
  - test

validate:lua:
  stage: validate
  image: alpine:3.19
  script:
    - apk add --no-cache lua5.1
    - lua5.1 scripts/validate-flat-keys.lua scripts/*.lua
  rules:
    - changes: ["scripts/**/*.lua"]

test:filters:
  stage: test
  image: fluent/fluent-bit:4.2.2-debug
  script:
    - ./scripts/run-test.sh
  rules:
    - changes: ["scripts/**/*.lua", "configs/**", "tests/**"]
  artifacts:
    when: on_failure
    paths:
      - test-output/
```

## Key Rules

1. **Use `-debug` image** — standard image has no shell, can't run scripts
2. **`exit_on_eof: true`** in service config — otherwise container hangs forever
3. **Never use `file` input with `exit_after_read`** — known hang bug (#288)
4. **Use `tail` input** with `read_from_head: true` instead
5. **Container user is `logstash` (UID 1000)** — mount volumes `:ro` or fix permissions

## Test Script Pattern (`run-test.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

PASS=0; FAIL=0
for config in configs/test_*.yaml; do
  filter=$(basename "$config" .yaml | sed 's/test_//')
  echo -n "Testing $filter... "

  output=$(fluent-bit -c "$config" 2>/dev/null)
  expected="tests/expected_${filter}.ndjson"

  if [ -f "$expected" ]; then
    if diff <(echo "$output" | jq -S .) <(jq -S . "$expected") > /dev/null 2>&1; then
      echo "PASS"; ((PASS++))
    else
      echo "FAIL"; ((FAIL++))
      echo "$output" > "test-output/${filter}_actual.ndjson"
    fi
  else
    echo "SKIP (no expected file)"
  fi
done

echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] || exit 1
```

## Selective Testing (Monorepo)

Use `changes:` rules per-filter directory:

```yaml
test:enrich:
  extends: .test-filter
  variables:
    FILTER_DIR: filters/enrich
  rules:
    - changes: ["filters/enrich/**"]

test:normalize:
  extends: .test-filter
  variables:
    FILTER_DIR: filters/normalize
  rules:
    - changes: ["filters/normalize/**"]
```

## Common CI Failures

| Symptom | Cause | Fix |
|---------|-------|-----|
| Container hangs | Missing `exit_on_eof` | Add to service config |
| Permission denied | Root-owned mounted files | Use `:ro` or `chmod 644` |
| "Module not found" | Using `require()` in Lua | Remove — not supported |
| Empty output | Filter returning -1 (drop) | Check return code logic |
| Wrong field values | Nested table access | Use flat dot-keys only |
