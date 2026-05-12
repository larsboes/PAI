
# Lua Migration Pitfalls

## The Problem

You have a working Ruby Logstash filter processing thousands of order/payment records per second. Management says: migrate it to Lua for FluentBit. The languages look similar enough -- variables, functions, if/else -- so you translate line by line. Then the bugs start. Operator precedence silently reorders your boolean logic. Flat keys become nested tables that pass all Lua tests but explode in Elasticsearch. State leaks across records because Lua keeps your variables alive between calls. Each pitfall here caused real production bugs in the migration. See Lua Reference for correct syntax, Advanced Reference for safe patterns, and Lua Tables for how flat keys actually work in table memory.

Critical differences between Ruby and Lua that lead to real bugs when migrating
log management filters. Every pitfall is based on real bugs from the project.

> [!info] Learning Objectives
> - Recognize operator precedence differences between Ruby and Lua and use correct parenthesization
> - Distinguish flat key notation vs. nested tables — avoid the #1 structural mistake
> - Understand Lua state persistence and prevent state leak bugs
> - Master type coercion between JSON parser, Lua, and assertion framework
> - Correctly transfer case sensitivity rules for pattern matching from Ruby
> - Safely use FluentBit return codes and the GC finalizer pattern
> - Use different event modes and the correct field prefixes


## 2. Flat Keys vs. Nested Tables — THE #1 Structural Mistake

> [!danger] Most Dangerous Migration Mistake
> This is the most common and dangerous mistake in Ruby-to-Lua migration.
> `record["order.fulfillment.status"]` is a **flat string key**,
> not `record.order.fulfillment.status`.

### Ruby e.set() vs. Lua Table Assignment

| | Ruby (Logstash) | Lua (FluentBit) |
|---|---|---|
| **Syntax** | `e.set("order.fulfillment.status", "shipped")` | `record["order.fulfillment.status"] = "shipped"` |
| **Dot in key** | Part of the string | Part of the string (NOT a nesting operator!) |
| **Result in ES** | `order.fulfillment.status = "shipped"` | `order.fulfillment.status = "shipped"` (CORRECT) |

### The Fatal Mistake: Nested Tables

| | CORRECT — Flat Key | WRONG — Nested Table |
|---|---|---|
| **Code** | `record["order.fulfillment.status"] = "shipped"` | `record["order"] = { ["fulfillment"] = { ["status"] = "shipped" } }` |
| **Table entries** | ONE entry with a dot in the key string | 3 nested levels |
| **Elasticsearch** | Correct as a flat field name | MAPPING CONFLICT! |

> [!danger] Why is this so dangerous?
> - The Lua code **runs without errors** -- no syntax error, no runtime error
> - FluentBit logs show no warning
> - Only in Elasticsearch does the **mapping conflict** appear
> - Debugging takes hours because the error only becomes visible downstream
> - LLMs (GPT, Claude) frequently generate nested tables -- they "optimize" the code incorrectly

> [!tip] Understand the table structure behind flat keys
> To see why flat keys work this way, read Lua Tables -- specifically how bracket notation creates a single string key entry in the hash part, vs dot notation which chains table lookups. The Advanced Reference deletion queue pattern shows how to safely rename flat keys in bulk.


## 4. Type Coercion

Lua has only one number type: **double** (64-bit floating point). The JSON parser in FluentBit
converts strings automatically. This leads to subtle comparison problems.

### The Problem: `200` (number) vs. `"200"` (string)

```lua
-- Direct comparison fails:
local status = record["status_code"]

-- Sometimes string, sometimes number!
if status == "200" then
    -- Only works if string
end

if status == 200 then
    -- Only works if number
end

-- SOLUTION: tostring() fallback
if tostring(status) == "200" then
    -- Works ALWAYS
end
```

### How assert_filter.lua Solves This

The `values_match()` function implements a robust comparison with tostring fallback:

```lua
-- From: templates/tests/src/assert_filter.lua

local function values_match(expected, actual)
    -- 1. Exact match (same type + same value)
    if expected == actual then return true end

    -- 2. Table/array comparison (recursive)
    if type(expected) == "table" and type(actual) == "table" then
        if #expected ~= #actual then return false end
        for i = 1, #expected do
            if not values_match(expected[i], actual[i]) then return false end
        end
        return true
    end

    -- 3. String fallback: "200" (string) == 200 (number)
    return tostring(expected) == tostring(actual)
end
```

> [!info] Rule for Filter Code
> When comparing values that come from JSON, **always** use `tostring()` for the comparison.
> FluentBit's JSON parser and `type_int_key` can change the type unpredictably.


## 6. Return Codes

FluentBit Lua filters communicate via return codes. A wrong code can cause
changes to be lost or records to disappear.

| Code | Name | Meaning |
|------|------|---------|
| `0` | KEEP | Keep original. Changes to the record are **discarded**! |
| `1` | MODIFY | Record was modified. FluentBit adopts the new version. |
| `2` | DROP | Delete record completely. It will not be forwarded. |
| `-1` | ERROR | Error. Drop record + log error. |

### The Most Common Trap: Return 0 After Modification

```lua
-- BUG: Changes are lost!
function cb_filter(tag, ts, record)
    record["service.category"] = "financial"  -- Modification...
    return 0, ts, record                      -- ...LOST! Return 0 = keep original
end

-- CORRECT:
function cb_filter(tag, ts, record)
    record["service.category"] = "financial"
    return 1, ts, record                      -- Return 1 = Modified
end
```

### Why `protected_mode: false` in Tests

FluentBit has a `protected_mode` setting for Lua filters:

- `protected_mode: true` (default) — Lua errors are caught. The record is simply
  **silently discarded** on error. No crash, but no feedback either.
- `protected_mode: false` — Lua errors crash the FluentBit process immediately.

In **tests** we use `protected_mode: false` so that:

- Lua errors are immediately visible (instead of silent data loss)
- The test process exits with exit code 1
- CI/CD detects the error and aborts the build

```yaml
# In the test pipeline YAML:
filters:
  - name: lua
    match: "*"
    script: /scripts/my_filter.lua
    call: cb_filter
    protected_mode: false   # Crashes on errors!
```

In **production**, `protected_mode: true` stays on, so a single faulty
record does not bring down the entire pipeline.


## 8. Order vs. Refund Mode

The filter system distinguishes between two modes that use different field prefixes.
The mode selection is **environment-variable-driven** and affects which sides
of a transaction are processed.

### The Two Modes

| Property | ORDER (Purchase) | REFUND (Return) |
|----------|------------------|-----------------|
| Meaning | Complete transaction with both sides | Refund flow, buyer side only |
| Sides | `buyer` + `seller` | Only `buyer` |
| Prefix | (none) | `refund_` |
| Example field | `buyer.service.category` | `refund_buyer.service.category` |
| Env variable | `FILTER_ORIGIN=ORDER` | `FILTER_ORIGIN=REFUND` |

### Ruby Original vs. Lua Migration

```ruby
# Ruby (Logstash)
if @origin == "REFUND"
    origin = "REFUND"
    sides = ['buyer']
    prefix = "refund_"
else
    origin = "ORDER"
    sides = ['buyer', 'seller']
    prefix = ""
end

# Sets either:
# buyer.service.category          (ORDER)
# refund_buyer.service.category   (REFUND)
e.set("#{prefix}#{side}.service.category", "commerce")
```

```lua
-- Lua (FluentBit)
local origin = os.getenv("FILTER_ORIGIN") or "ORDER"

local sides, prefix
if origin == "REFUND" then
    sides = {"buyer"}
    prefix = "refund_"
else
    sides = {"buyer", "seller"}
    prefix = ""
end

-- Sets either:
-- buyer.service.category          (ORDER)
-- refund_buyer.service.category   (REFUND)
for _, side in ipairs(sides) do
    record[prefix .. side .. ".service.category"] = "commerce"
end
```

> [!danger] Common Migration Mistake
> Forgetting to add the `refund_` prefix. The filter runs without errors, but
> the fields end up under the wrong name in Elasticsearch. ORDER tests pass, REFUND tests
> fail — or worse: REFUND tests don't exist and the bug remains undetected.

> [!warning] Quiz: Which key for REFUND record service.category?
> **Answer: `record["refund_buyer.service.category"] = "commerce"`**
>
> The REFUND prefix is `refund_` (with underscore), not `refund.` (with dot).
> Note: The underscore after `refund` and the dot before `service` —
> it's `refund_buyer.service.category`, composed from:
> `prefix("refund_") + side("buyer") + ".service.category"`.


## Summary: The 8 Migration Pitfalls

1. **Operator precedence:** Always use explicit parentheses with mixed `and`/`or` expressions
2. **Flat keys:** `record["a.b.c"] = val`, never nested tables
3. **State persistence:** Module-level only for constants and lookups, never for mutable data
4. **Type coercion:** `tostring()` before comparisons that come from JSON
5. **Case sensitivity:** `string.lower()` before pattern matching when Ruby uses `.downcase`
6. **Return codes:** Return 1 after modifications, return 0 discards all changes
7. **GC finalizer:** `newproxy(true)` + `__gc` for shutdown logic, don't forget the `_G` reference
8. **Order vs. Refund:** `refund_` prefix for REFUND mode, mode via `FILTER_ORIGIN` environment variable

> [!info] Rule of Thumb for LLM-Generated Migrations
> Every LLM-generated Ruby-to-Lua migration should be checked against **all 8 pitfalls**.
> The edge case tests in `templates/tests/data/enrichment/edge_cases.lua` cover the most critical
> combinations. Without these tests, the migration would be unreliable.

