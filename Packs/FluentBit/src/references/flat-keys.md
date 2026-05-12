
# Flat Keys — The #1 Pattern

This is the single most important pattern in FluentBit Lua development. If you learn
nothing else, learn this: **record keys are flat strings, dots are
characters, not nesting operators.**


## The Correct Way

```lua
record["order.currency"] = "EUR"
```

One key. One string. The dot is literally part of the key name — like a hyphen
or underscore. FluentBit's C core serializes this as a single key-value pair
in msgpack. Elasticsearch receives the flat key and interprets the dots as
its own nesting convention.


## Visual: The Same Data, Two Ways

### What you want in Elasticsearch

```json
{
  "request_id": "req-8a3f-01",
  "order.status": "confirmed",
  "order.currency": "EUR",
  "order.items.0": "SKU-4821"
}
```

Elasticsearch interprets dots in flat keys as its own hierarchy. Four flat keys,
four values. Clean mapping.

### What nested tables produce

```json
{
  "request_id": "req-8a3f-01",
  "order": {
    "status": "confirmed",
    "currency": "EUR",
    "items": {
      "0": "SKU-4821"
    }
  }
}
```

This looks similar at first glance. But Elasticsearch treats `order` as
an **object type** — which conflicts with existing documents where `order.status`
is a flat keyword field. The index mapping breaks. Ingestion fails silently or throws
mapping exceptions.

### What Elasticsearch actually receives (comparison)

| Approach | ES Field | ES Type | Status |
|----------|----------|---------|--------|
| Flat: `record["order.status"] = "confirmed"` | `order.status` | keyword | Works |
| Nested: `record.order = {status = "confirmed"}` | `order` | object | **Mapping conflict** |


## The Migration Trap

Ruby hashes ARE nested. Logstash's `e.set` and `e.get` handle dot-notation
transparently — the developer never thinks about whether the storage is flat or nested.

```ruby
# Ruby: this is natural and correct
e.set("order.currency", "EUR")
value = e.get("order.currency")
```

When an AI model sees this Ruby code and translates to Lua, it "improves" the
structure by making the nesting explicit:

```lua
-- AI-generated: looks clean, compiles, runs, BREAKS EVERYTHING
record.order = record.order or {}
record.order.currency = "EUR"
```

The AI is applying its training data — where nested access is the norm in Python,
JavaScript, Ruby, Go, and every other language. Lua tables support nesting. The
code is valid. The AI has no way to know that FluentBit's C serializer treats
flat keys differently.

> [!warning] Every AI-generated filter must be checked for nested tables
> This is not a theoretical risk. In production migration work, approximately
> 60-70% of initial AI-generated filters contained nested table assignments.
> The only reliable defense is automated tests that check for flat key output.


