
# String Patterns

## The Problem

You're writing a FluentBit filter and need to extract the service name from a path like `/api/v2/orders/export`, validate that a field looks like an IP address, or parse `key=value` pairs out of a raw log line. Lua's `string.find`, `string.match`, `string.gsub`, and `string.gmatch` are your tools — but **Lua patterns are not POSIX regex**. They're a simpler, smaller system with different syntax. Confuse the two and you'll spend an hour debugging a pattern that silently matches nothing.

> [!info] Lua patterns vs POSIX regex — key differences
> - `%` is the escape character, not `\`
> - No top-level alternation with `|` (use multiple calls or character classes instead)
> - No non-capturing groups `(?:...)`
> - `.-` is the lazy equivalent of `.*` — stops at the shortest match
> - Much smaller and faster than full POSIX regex — appropriate for embedded/log-pipeline use


## Quantifiers

| Quantifier | Meaning |
|-----------|---------|
| `+` | 1 or more (greedy) |
| `*` | 0 or more (greedy) |
| `-` | 0 or more (**lazy** — stops at shortest match) |
| `?` | 0 or 1 (optional) |

> [!danger] `.*` vs `.-` — the greedy trap
> `.*` expands as far as possible. `.-` stops at the first valid match. This matters whenever your input contains multiple instances of the delimiter.
> ```lua
> -- WRONG: greedy — eats from first /* to LAST */
> string.gsub("/* a */ int x; /* b */", "/%*.*%*/", "X")
> -- result: "X"  (both comments gone, replaced by one X)
>
> -- CORRECT: lazy — stops at first */
> string.gsub("/* a */ int x; /* b */", "/%*.-%*/", "X")
> -- result: "X int x; X"
> ```


## The Four Functions

### `string.find(s, pattern)`

Returns `start, end` positions, or `nil` if not found. With captures, also returns the captured values after the positions.

```lua
local i, j = string.find("GET /api/users HTTP/1.1", "%s(/[%w/]+)")
-- i=4, j=14
```

> [!warning] `find` returns `nil` on no match — not `-1`
> Coming from Python? `str.find()` returns `-1` on failure. Lua returns `nil`. Always check with `if result then` — never compare against `-1`.

### `string.match(s, pattern)`

Returns captures if present, the whole match if no captures, or `nil`. Cleaner than `find` when you only want the value.

```lua
local method = string.match(record["request"], "^(%u+)")
local path   = string.match(record["request"], "%s(/[%w/.%-_]+)")
```

### `string.gsub(s, pattern, replacement)`

Replaces all matches. The replacement can be a **string**, **table**, or **function**. Returns the new string plus the count of substitutions made.

```lua
-- String replacement: %1 references first capture
local normalized = string.gsub(record["path"], "^(/[^?]+)%?.*$", "%1")

-- Function replacement: called with captures, return value substituted in
local result = string.gsub(record["tags"], "([%w]+)", function(tag)
  return tag:upper()
end)
```

### `string.gmatch(s, pattern)`

Returns an iterator that yields successive matches. Each iteration returns the next match or captures.

```lua
-- Split comma-separated tags
for tag in string.gmatch(record["tags"] or "", "([^,]+)") do
  -- process each tag
end

-- Count words
local count = 0
for _ in string.gmatch(record["message"], "%S+") do
  count = count + 1
end
```


## Method Syntax Shorthand

`s:find(p)` is identical to `string.find(s, p)` — the colon passes `s` as the first argument automatically. Both forms are valid; method syntax is more idiomatic in modern Lua.

```lua
-- These are identical:
string.match(record["path"], "^/api")
record["path"]:match("^/api")
```

> [!warning] Nil-safety with method syntax
> `record["path"]:match(...)` will crash if `record["path"]` is `nil`. Always guard:
> ```lua
> local path = record["path"] or ""
> if path:match("^/api") then ... end
> ```


