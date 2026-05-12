# Logstash Ruby Filters

## Ruby Filter API

```ruby
filter {
  ruby {
    code => '
      # Read/write fields
      value = event.get("field_name")
      event.set("new_field", "value")
      event.remove("unwanted_field")

      # Metadata (pipeline-internal, not sent to output)
      event.set("[@metadata][temp]", "value")
      path = event.get("[@metadata][path]")

      # Nested fields use bracket notation
      event.get("[nested][field]")
    '
  }
}
```

### Common Patterns

| Pattern | Ruby Code |
|---------|-----------|
| Sort fields, join values | `fields.sort_by { |k, _| k }.map { |_, v| v.to_s }.join(" ")` |
| Reject internal fields | `event.to_hash.reject { |k, _| k.start_with?("@") }` |
| Conditional set | `event.set("tier", "premium") if event.get("plan") == "pro"` |
| Nil-safe downcase | `val = event.get("name")&.downcase` |
| Environment variable | `ENV["OUTPUT_EXTENSION"] || "default"` |
| String interpolation | `event.set("path", "#{base}_#{ext}")` |

### Using a File-Based Script

```ruby
filter {
  ruby {
    path => "/scripts/my_filter.rb"
    script_params => { "lookup_path" => "/data/lookup.json" }
  }
}
```

Script template:
```ruby
def register(params)
  @lookup_path = params["lookup_path"]
  @lookup = JSON.parse(File.read(@lookup_path))
end

def filter(event)
  key = event.get("route")
  event.set("service", @lookup[key]) if @lookup.key?(key)
  return [event]
end
```

## ECS Compatibility v8 (Logstash 8.x default)

All plugins run in ECS v8 mode by default. Field locations change:

| Plugin | Old field | ECS v8 field |
|--------|-----------|--------------|
| File input | `[path]` | `[log][file][path]` |
| Beats input | `[host]` | `[host][name]` |

**Disable per-plugin:**
```ruby
input {
  file {
    ecs_compatibility => disabled
  }
}
```

**Disable per-pipeline:**
```yaml
# logstash.yml
pipeline.ecs_compatibility: disabled
```

## Mutate Filter (Common Companion)

```ruby
filter {
  mutate {
    remove_field => ["message", "@version", "host", "log", "event"]
    rename => { "old_name" => "new_name" }
    add_field => { "env" => "production" }
    convert => { "status" => "integer" }
    lowercase => ["method"]
  }
}
```

## Output Plugins

```ruby
output {
  # Debug: human-readable to stdout
  stdout { codec => rubydebug }

  # File: per-event path via sprintf
  file {
    path => "%{[@metadata][output_path]}"
    codec => json_lines
  }

  # Elasticsearch
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
}
```

## References

- [Ruby Filter Plugin Docs](https://www.elastic.co/docs/reference/logstash/plugins/plugins-filters-ruby)
- [Ruby Scripting Blog Post](https://www.elastic.co/search-labs/blog/ruby-scripting-logstash)
- [Mutate Filter](https://www.elastic.co/guide/en/logstash/current/plugins-filters-mutate.html)
- [Logstash Event API](https://www.elastic.co/guide/en/logstash/current/event-api.html)
- [Ruby 3.1 Core Docs](https://ruby-doc.org/core-3.1.0/)
