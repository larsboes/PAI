# Logstash CI Patterns

Battle-tested patterns for running Logstash in GitLab CI on Kubernetes runners.

## Known Bugs (as of Logstash 8.10.0)

### Bug #1: `exit_after_read` + `file_completed_action => "log"` — never exits

**GitHub Issue:** [logstash-plugins/logstash-input-file#288](https://github.com/logstash-plugins/logstash-input-file/issues/288) (open since 2021)

The plugin only recognizes "all files read" when files are **removed from the path** (deleted). With `file_completed_action => "log"`, files stay — plugin never sees them as "completed" — Logstash hangs forever.

### Bug #2: `exit_after_read` + default `file_completed_action` — race condition

With `file_completed_action => "delete"` (default), files ARE consumed but `exit_after_read` triggers shutdown **before events flush through the pipeline**. Result: files deleted, zero output.

### Bug #3: `**` recursive glob doesn't work in Kubernetes pods

The filewatch library's glob discovery fails silently. Explicit file paths work, but globs don't match even when files exist at the expected paths.

### Bug #4: Logstash container runs as `logstash` user (UID 1000)

GitLab CI Kubernetes runners clone files as `root`. The `init-permissions` container sets `rw-rw-rw-` but ownership stays `root`. You **cannot chmod** (not owner). Files are readable but not permission-changeable.

## The Solution: stdin Input per File

```yaml
variables:
  TEST_DIR: ${CI_PROJECT_DIR}/tests
  INPUT_EXTENSION: "ndjson"
  OUTPUT_EXTENSION: "output"
  LOGSTASH_VERSION: "8.10.0"

run-logstash:
  stage: test
  image: docker.elastic.co/logstash/logstash:${LOGSTASH_VERSION}
  script:
    - |
      for input_file in $(find "${TEST_DIR}" -name "*.${INPUT_EXTENSION}" -type f); do
        output_file="${input_file}_${OUTPUT_EXTENSION}"
        echo "Processing: ${input_file}"
        cat "${input_file}" | logstash -e '
          input { stdin { codec => json_lines } }
          filter {
            ruby {
              code => "fields = event.to_hash.reject { |k, _| k.start_with?(64.chr) }; event.set(110.chr+101.chr+119.chr, fields.sort_by { |k, _| k }.map { |_, v| v.to_s }.join(32.chr))"
            }
            mutate { remove_field => ["message", "@version", "host", "log", "event"] }
          }
          output {
            stdout { codec => rubydebug }
            file { path => "'"${output_file}"'" codec => json_lines }
          }
        '
      done
  artifacts:
    when: always
    paths:
      - ${TEST_DIR}
```

## Why stdin Works

| Property | File Input | stdin |
|----------|-----------|-------|
| Signals "input done" | Broken (depends on file deletion) | Natural EOF from pipe |
| Discovery | Glob bugs, timing issues | N/A — data piped directly |
| Exit behavior | Requires `exit_after_read` (buggy) | Exits after EOF + flush |
| Per-file output | Via `[@metadata][path]` (may be nil in ECS v8) | Via shell variable injection |
| JVM startup | Once (but may not process) | Once per file (12s each) |

**Trade-off:** stdin requires one JVM startup per file (12s overhead each). For 2-5 test files, this is acceptable. For 50+ files, consider a wrapper that concatenates with path markers.

## Concatenated stdin (Advanced)

For many files without per-file JVM startup:

```bash
# Embed source path into each JSON line, pipe all through one Logstash run
for f in $(find "${TEST_DIR}" -name "*.ndjson" -type f); do
  while IFS= read -r line; do
    # Inject __source into each JSON object
    echo "${line%\}},\"__source\":\"${f}\"}"
  done < "$f"
done | logstash -e '
  input { stdin { codec => json_lines } }
  filter {
    ruby {
      code => "
        source = event.get(\"__source\")
        event.set(\"[@metadata][output_path]\", source + \"_output\")
        event.remove(\"__source\")
      "
    }
    # ... your actual filter logic ...
  }
  output {
    file { path => "%{[@metadata][output_path]}" codec => json_lines }
  }
'
```

## Pipeline Settings for CI

```yaml
# logstash.yml — optimized for batch CI (not production!)
xpack.monitoring.enabled: false
log.level: info
pipeline.batch.size: 1
pipeline.batch.delay: 0
pipeline.workers: 1
pipeline.unsafe_shutdown: false
```

## Debugging Checklist

When Logstash produces no output in CI:

1. **Is rubydebug showing events?** → If no, events never reach output (input or filter problem)
2. **Are input files still present after run?** → If deleted, `file_completed_action` default is `delete`
3. **What's the exit code?** → 0 = clean exit, 1 = error, 124 = timeout killed it
4. **Set `log.level: info`** → `error` hides critical warnings
5. **Add `|| true` after logstash** → Ensures subsequent diagnostic commands run
6. **Print the config before running** → Verify variable substitution worked
