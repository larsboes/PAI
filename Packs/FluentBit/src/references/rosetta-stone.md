
# Rosetta Stone: Ruby/Logstash to Lua/FluentBit

A direct translation reference. Left column is what you see in Ruby/Logstash filters.
Right column is the correct Lua/FluentBit equivalent. Every pattern is from real
migration work.


## 2. String Substring Check

| Ruby/Logstash | Lua/FluentBit |
|---|---|
| `str.include?("edge-gw")` | `string.find(str, "edge-gw", 1, true) ~= nil` |
| `str.start_with?("prefix")` | `string.sub(str, 1, #"prefix") == "prefix"` |
| `str.end_with?("suffix")` | `string.sub(str, -#"suffix") == "suffix"` |

> [!tip] The `plain=true` flag
> `string.find(str, pattern, 1, true)` disables pattern matching and does a
> plain substring search. Faster and safer when you don't need regex.


## 4. Regex / Pattern Matching

| Ruby/Logstash | Lua/FluentBit |
|---|---|
| `str =~ /^(\d{4})/` | `string.match(str, "^(%d%d%d%d)")` |
| `str.match(/error\|warn/i)` | `string.find(string.lower(str), "error") or string.find(string.lower(str), "warn")` |
| `str.gsub(/[^0-9]/, "")` | `string.gsub(str, "[^0-9]", "")` |
| `str.scan(/\d+/)` | `for n in string.gmatch(str, "%d+") do ... end` |

Lua patterns are NOT regex. Key differences:

| Regex | Lua Pattern |
|-------|-------------|
| `\d` | `%d` |
| `\w` | `%w` |
| `\s` | `%s` |
| `.+` (greedy) | `.+` (greedy) |
| `.+?` (lazy) | `.-(` (lazy, use `%-`) |
| `(a\|b)` | No alternation — use multiple `string.find` calls |
| `(?i)` case flag | No flag — use `string.lower` first |


## 6. Conditionals

| Ruby/Logstash | Lua/FluentBit |
|---|---|
| `if condition` | `if condition then` |
| `elsif` | `elseif` |
| `unless condition` | `if not condition then` |
| `value = cond ? a : b` | `value = cond and a or b` |
| `case/when` | `if/elseif` chain (no switch/case in Lua) |

> [!tip] The ternary trick `cond and a or b`
> This works like a ternary **only when `a` is truthy**. If `a` could be `false`
> or `nil`, the expression returns `b` instead. For boolean results, use an
> explicit if/else.


## 8. Type Conversion

| Ruby/Logstash | Lua/FluentBit |
|---|---|
| `val.to_s` | `tostring(val)` |
| `val.to_i` | `tonumber(val)` (returns nil if not numeric) |
| `val.to_f` | `tonumber(val)` (Lua has only doubles) |
| `val.is_a?(String)` | `type(val) == "string"` |
| `val.is_a?(Numeric)` | `type(val) == "number"` |

> [!tip] tonumber returns nil for non-numeric strings
> `tonumber("hello")` returns `nil`, not 0. Always check: `local n = tonumber(val); if n then ... end`.


## 10. Hash / Table Iteration

| Ruby/Logstash | Lua/FluentBit |
|---|---|
| `hash.each { \|k,v\| ... }` | `for k, v in pairs(tbl) do ... end` |
| `hash.keys` | Collect with `for k in pairs(tbl) do keys[#keys+1] = k end` |
| `hash.values` | Collect with `for _, v in pairs(tbl) do vals[#vals+1] = v end` |
| `hash.key?(k)` | `tbl[k] ~= nil` |
| `hash.merge(other)` | `for k, v in pairs(other) do tbl[k] = v end` |
| `hash.delete(k)` | `tbl[k] = nil` (but never during pairs() iteration!) |

> [!danger] Never delete during pairs() iteration
> See the Deletion Queue pattern. Collect keys first, delete in a second pass.


## 12. File I/O

| Ruby/Logstash | Lua/FluentBit |
|---|---|
| `File.read("path")` | `local f = io.open("path", "r"); local s = f:read("*a"); f:close()` |
| `File.exist?("path")` | `local f = io.open("path", "r"); if f then f:close(); return true end` |
| `File.foreach("path") { \|line\| ... }` | `for line in io.lines("path") do ... end` |

> [!danger] Only in cb_init, never in cb_filter
> All file I/O must happen in `cb_init` (once at startup). File operations in
> `cb_filter` run per record — at 100k rec/sec, that is 100k file opens per second.


## 14. Time / Date Formatting

| Ruby/Logstash | Lua/FluentBit |
|---|---|
| `Time.now.utc` | `os.time()` (seconds since epoch) |
| `Time.at(epoch).strftime("%Y-%m-%d")` | `os.date("%Y-%m-%d", epoch)` |
| `DateTime.parse("2025-01-01")` | Manual parsing with `string.match` |
| `time.iso8601` | `os.date("!%Y-%m-%dT%H:%M:%SZ", epoch)` |

```lua
-- ISO 8601 from epoch
local iso = os.date("!%Y-%m-%dT%H:%M:%SZ", ts)

-- Parse "2025-04-01T12:00:00Z" (no built-in parser)
local y, m, d, h, min, s = string.match(
    timestamp_str,
    "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"
)
```


## 16. Iteration with Index

| Ruby/Logstash | Lua/FluentBit |
|---|---|
| `arr.each_with_index { \|v, i\| ... }` | `for i, v in ipairs(arr) do ... end` |
| `(0..4).each { \|i\| ... }` | `for i = 0, 4 do ... end` |
| `5.times { \|i\| ... }` | `for i = 1, 5 do ... end` |
| `next` / `continue` | `goto continue` ... `::continue::` (LuaJIT) |


## 18. Boolean Logic

| Ruby/Logstash | Lua/FluentBit |
|---|---|
| `&&` | `and` |
| `\|\|` | `or` |
| `!` | `not` |
| `true` / `false` | `true` / `false` |
| `nil` is falsy | `nil` and `false` are falsy; `0`, `""` are **truthy** |


## 20. String Concatenation

| Ruby/Logstash | Lua/FluentBit |
|---|---|
| `"hello" + " world"` | `"hello" .. " world"` |
| `str << "append"` (mutate) | Strings are immutable — `str = str .. "append"` |
| `arr.join(",")` | `table.concat(arr, ",")` |
| `"x" * 5` (repeat) | `string.rep("x", 5)` |

> [!warning] String concatenation in loops is O(n^2)
> Each `str = str .. val` creates a new string and copies the entire existing
> string. For building strings in a loop, collect into a table and use
> `table.concat()` at the end:
> ```lua
> local parts = {}
> for _, v in ipairs(values) do
>     parts[#parts + 1] = tostring(v)
> end
> local result = table.concat(parts, ",")
> ```

