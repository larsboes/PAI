# Test Logstash Pipeline

Run Logstash configs against test inputs via stdin in containers.

## Approach

Pipe each NDJSON test file through stdin — never use file input in containers (hangs due to [bug #288](https://github.com/logstash-plugins/logstash-input-file/issues/288)).

## Test Config Template

```ruby
input {
  stdin {
    codec => json_lines
  }
}

filter {
  # Your filter here (inline or path-based)
  ruby {
    path => "/usr/share/logstash/scripts/your_filter.rb"
  }
}

output {
  stdout {
    codec => json_lines
  }
}
```

## Running Tests

### Docker (matches CI)
```bash
cat tests/input.ndjson | docker run --rm -i \
  -v $(pwd)/configs:/usr/share/logstash/pipeline:ro \
  -v $(pwd)/scripts:/usr/share/logstash/scripts:ro \
  docker.elastic.co/logstash/logstash:8.15.0 \
  logstash -f /usr/share/logstash/pipeline/test.conf \
  --path.settings /dev/null \
  2>/dev/null
```

### Helper Script
```bash
./scripts/run-logstash-stdin.sh configs/test.conf tests/input.ndjson
```

## Script Pattern (`run-logstash-stdin.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

CONFIG="$1"
INPUT="$2"
EXPECTED="${3:-}"

OUTPUT=$(cat "$INPUT" | docker run --rm -i \
  -v "$(pwd)/configs:/usr/share/logstash/pipeline:ro" \
  -v "$(pwd)/scripts:/usr/share/logstash/scripts:ro" \
  docker.elastic.co/logstash/logstash:8.15.0 \
  logstash -f "/usr/share/logstash/pipeline/$(basename "$CONFIG")" \
  --path.settings /dev/null 2>/dev/null)

if [ -n "$EXPECTED" ]; then
  if diff <(echo "$OUTPUT" | jq -S .) <(jq -S . "$EXPECTED") > /dev/null 2>&1; then
    echo "PASS: $(basename "$CONFIG")"
  else
    echo "FAIL: $(basename "$CONFIG")"
    echo "$OUTPUT" | jq .
    exit 1
  fi
else
  echo "$OUTPUT" | jq .
fi
```

## CI Pipeline

```yaml
test:logstash:
  stage: test
  image: docker.elastic.co/logstash/logstash:8.15.0
  script:
    - |
      for input in tests/*.ndjson; do
        filter=$(basename "$input" .ndjson)
        config="configs/test_${filter}.conf"
        expected="tests/expected_${filter}.ndjson"
        [ -f "$config" ] || continue
        echo -n "Testing $filter... "
        output=$(cat "$input" | logstash -f "$config" --path.settings /dev/null 2>/dev/null)
        if [ -f "$expected" ] && diff <(echo "$output" | jq -S .) <(jq -S . "$expected") > /dev/null; then
          echo "PASS"
        else
          echo "FAIL"
          exit 1
        fi
      done
```

## Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Hangs forever | Using `file` input | Switch to `stdin` |
| ~12s startup | JVM cold start | Normal — plan CI budgets |
| Permission denied | UID mismatch | Mount `:ro` |
| "Could not find filter" | Missing plugin | Add to Gemfile or use inline |
| ECS field not found | Logstash 8 ECS v8 changes | Use `[log][file][path]` not `[path]` |
