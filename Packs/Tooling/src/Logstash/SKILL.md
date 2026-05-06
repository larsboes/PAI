---
name: Logstash
description: "Logstash Ruby filter development and CI pipeline patterns. Use when writing Ruby filters, testing Logstash configs, or building Logstash CI pipelines."
---

# Logstash

Ruby filter development and CI/CD patterns for Logstash 8.x.

## Quick Reference

- **Filter:** `ruby { code => 'event.get("field"); event.set("field", val)' }`
- **#1 CI rule:** NEVER use file input in containers. Use `stdin` + pipe per file.
- **Known bug:** `exit_after_read` + `file_completed_action => "log"` hangs ([#288](https://github.com/logstash-plugins/logstash-input-file/issues/288))
- **ECS v8:** Field paths changed (e.g. `[path]` → `[log][file][path]`). Test, don't assume.
- **Container user:** Runs as `logstash` (UID 1000), cannot chmod root-owned files
- **JVM startup:** ~12s cold start. Plan CI accordingly.

## References

| Need | File |
|------|------|
| CI bugs, stdin approach, pipeline drain, debugging | [references/ci-patterns.md](references/ci-patterns.md) |
| Ruby filter API, ECS v8, mutate, output plugins | [references/ruby-filters.md](references/ruby-filters.md) |

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/run-logstash-stdin.sh` | Reliable CI runner — pipes each file through stdin |

## External References

- [Logstash Ruby Filter Plugin](https://www.elastic.co/docs/reference/logstash/plugins/plugins-filters-ruby)
- [Ruby Scripting in Logstash (blog)](https://www.elastic.co/search-labs/blog/ruby-scripting-logstash)
- [Logstash File Input Plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-file.html)
- [File Input Bug #288 (open since 2021)](https://github.com/logstash-plugins/logstash-input-file/issues/288)
- [ECS in Logstash 8](https://www.elastic.co/guide/en/logstash/8.18/ecs-ls.html)
- [Logstash Event API](https://www.elastic.co/guide/en/logstash/current/event-api.html)
- [Ruby 3.1 Core Docs](https://ruby-doc.org/core-3.1.0/)
