# Write Ruby Filter

Guided workflow for writing Logstash Ruby filter plugins.

## Steps

1. **Clarify the requirement** — What fields to read/transform/create?
2. **Choose inline vs file** — Simple = inline `code =>`, complex = `path =>`
3. **Write the filter** using the Event API
4. **Write test input** (NDJSON)
5. **Run via stdin** (never file input in containers)

## Inline Filter Template

```ruby
filter {
  ruby {
    code => '
      # Read field (bracket notation for nested)
      value = event.get("[source][field]")

      # Guard nil
      return unless value

      # Transform
      result = value.downcase.strip

      # Write result
      event.set("[target][field]", result)
    '
  }
}
```

## File-based Filter Template (`scripts/my_filter.rb`)

```ruby
def filter(event)
  value = event.get("[source][field]")
  return [event] unless value

  result = value.split("|").map(&:strip)
  event.set("[target][parts]", result)

  [event]
end
```

Reference in config:
```ruby
filter {
  ruby {
    path => "/usr/share/logstash/scripts/my_filter.rb"
  }
}
```

## Event API

```ruby
event.get("[field]")          # read top-level
event.get("[nested][field]")  # read nested
event.set("[field]", value)   # write
event.remove("[field]")       # delete
event.tag("_parse_failure")   # add tag
event.get("[@metadata][key]") # metadata (not in output)
```

## Critical Rules

1. **Bracket notation** — `[field]` not `field`, `[a][b]` not `[a.b]`
2. **Return `[event]`** from file-based filters (array!) — not bare `event`
3. **nil check before operations** — `.get()` returns nil for missing fields
4. **No gems** in inline code — only Ruby stdlib available
5. **Avoid `require`** in inline code — path-based filters can use it

## Common Patterns

### Conditional field mapping
```ruby
mapping = { "APP" => "call_detail", "SVC" => "registration" }
event.set("[type]", mapping[event.get("[raw_type]")] || "unknown")
```

### Parse timestamp
```ruby
require 'time'
ts = event.get("[timestamp_str]")
event.set("[@timestamp]", Time.parse(ts).iso8601) if ts
```

### Split and extract
```ruby
parts = event.get("[combined]")&.split(";")
if parts && parts.length >= 3
  event.set("[first]", parts[0])
  event.set("[second]", parts[1])
  event.set("[third]", parts[2])
end
```

### Copy and rename
```ruby
event.set("[new_name]", event.get("[old_name]"))
event.remove("[old_name]")
```

### Drop event
```ruby
event.cancel
```
