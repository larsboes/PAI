# Logstash CI Pipeline

GitLab CI patterns for testing Logstash Ruby filters in containers.

## Pipeline Structure

```yaml
stages:
  - validate
  - test

validate:config:
  stage: validate
  image: docker.elastic.co/logstash/logstash:8.15.0
  script:
    - |
      for conf in configs/*.conf; do
        echo -n "Validating $(basename $conf)... "
        logstash --config.test_and_exit -f "$conf" --path.settings /dev/null 2>/dev/null && echo "OK" || { echo "FAIL"; exit 1; }
      done
  rules:
    - changes: ["configs/**/*.conf"]

test:filters:
  stage: test
  image: docker.elastic.co/logstash/logstash:8.15.0
  script:
    - ./scripts/run-logstash-stdin.sh
  rules:
    - changes: ["scripts/**/*.rb", "configs/**/*.conf", "tests/**"]
  artifacts:
    when: on_failure
    paths:
      - test-output/
```

## Key Rules

1. **stdin input only** — file input hangs in containers (bug #288)
2. **`--path.settings /dev/null`** — skip settings loading in test mode
3. **12s JVM startup** — budget accordingly, parallelize where possible
4. **`--config.test_and_exit`** — validates config syntax without running
5. **Mount scripts `:ro`** — Logstash runs as UID 1000

## Selective Testing (Monorepo)

```yaml
.test-filter:
  stage: test
  image: docker.elastic.co/logstash/logstash:8.15.0
  script:
    - ./scripts/run-logstash-stdin.sh "configs/test_${FILTER}.conf" "tests/${FILTER}.ndjson"

test:enrich:
  extends: .test-filter
  variables:
    FILTER: enrich
  rules:
    - changes: ["filters/enrich/**"]

test:normalize:
  extends: .test-filter
  variables:
    FILTER: normalize
  rules:
    - changes: ["filters/normalize/**"]
```

## JVM Startup Optimization

For monorepos with many filter tests, batch into one job:

```yaml
test:all-filters:
  stage: test
  image: docker.elastic.co/logstash/logstash:8.15.0
  script:
    - |
      PASS=0; FAIL=0
      for input in tests/*.ndjson; do
        filter=$(basename "$input" .ndjson)
        config="configs/test_${filter}.conf"
        [ -f "$config" ] || continue
        # Reuse warm JVM — run sequentially in same container
        output=$(cat "$input" | logstash -f "$config" --path.settings /dev/null 2>/dev/null)
        expected="tests/expected_${filter}.ndjson"
        if [ -f "$expected" ] && diff <(echo "$output" | jq -S .) <(jq -S . "$expected") > /dev/null; then
          echo "PASS: $filter"; ((PASS++))
        else
          echo "FAIL: $filter"; ((FAIL++))
        fi
      done
      echo "Results: $PASS passed, $FAIL failed"
      [ $FAIL -eq 0 ]
```
