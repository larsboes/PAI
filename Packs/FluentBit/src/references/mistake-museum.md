
# The Mistake Museum

Welcome to the museum. Every exhibit is a real bug — code that compiles, runs,
and produces wrong results. Some are silent. Some crash. All of them have been
found in production or in AI-generated migration code.

Walk through. Read each exhibit. You will encounter every one of these in the wild.


### Exhibit 2: The Silent Discard

**Symptom:** Filter runs. No errors. But the output record is identical to the input — all modifications are gone.

**Wrong Code:**
```lua
function cb_filter(tag, ts, record)
    record["enriched"] = "yes"
    record["status"] = "processed"
    return 0, ts, record  -- Return 0 = keep ORIGINAL
end
```

**Right Code:**
```lua
function cb_filter(tag, ts, record)
    record["enriched"] = "yes"
    record["status"] = "processed"
    return 1, ts, record  -- Return 1 = modified
end
```

**Why:** Return code 0 tells FluentBit "I didn't change anything, use the original." All modifications to the record table are discarded.

**Caught by:** Any assertion test that checks for the presence of added fields.


### Exhibit 4: Zero Is Truthy

**Symptom:** Records with value `0` or `"0"` are treated as "present" when the intent was to check for meaningful values.

**Wrong Code:**
```lua
local duration = record["duration"]
if duration then
    -- Executes when duration is 0, "0", 0.0 — all truthy in Lua!
    record["has_duration"] = "yes"
end
```

**Right Code:**
```lua
local duration = tonumber(record["duration"] or 0)
if duration > 0 then
    record["has_duration"] = "yes"
end
```

**Why:** In Lua, only `nil` and `false` are falsy. The number `0`, empty string `""`, and the string `"0"` are all truthy. Every other language (Python, Ruby, JavaScript) treats 0 as falsy.

**Caught by:** Test case with `duration = 0` that expects `has_duration` to be absent.


### Exhibit 6: Not-Equal Typo

**Symptom:** Lua script fails to load. FluentBit logs a syntax error but continues running — the filter simply never executes.

**Wrong Code:**
```lua
if record["status"] != "active" then  -- != is not Lua!
    record["inactive"] = "true"
end
```

**Right Code:**
```lua
if record["status"] ~= "active" then  -- ~= is Lua's not-equal
    record["inactive"] = "true"
end
```

**Why:** Lua uses `~=` for inequality, not `!=`. This is a syntax error at parse time.

**Caught by:** Any test execution — the script fails to load entirely. But in `protected_mode: true` (the default), FluentBit silently discards the error and passes records through unfiltered.


### Exhibit 8: The Length Operator Lie

**Symptom:** `#table` returns 0 or a wrong count for tables with string keys, or returns an unexpected count for arrays with nil gaps.

**Wrong Code:**
```lua
local record = {
    ["name"] = "web-prod-01",
    ["region"] = "eu-west",
    ["env"] = "production",
}
print(#record)  -- Prints 0, not 3!

local arr = {1, 2, nil, 4, 5}
print(#arr)  -- Could print 2 or 5 — undefined for arrays with gaps
```

**Right Code:**
```lua
-- Count string-keyed entries manually
local count = 0
for _ in pairs(record) do
    count = count + 1
end

-- For arrays: never have nil gaps
local arr = {1, 2, 3, 4, 5}
print(#arr)  -- Always 5
```

**Why:** The `#` operator only works for contiguous integer-indexed arrays (sequences). For tables with string keys, it returns 0. For arrays with nil gaps, the result is undefined.

**Caught by:** Any test that relies on record field count.


### Exhibit 10: State Persistence Leak

**Symptom:** Memory usage grows continuously. After hours or days, FluentBit is OOM-killed.

**Wrong Code:**
```lua
local history = {}

function cb_filter(tag, ts, record)
    table.insert(history, record["request_id"])
    -- history grows with EVERY record, forever
    return 1, ts, record
end
```

**Right Code:**
```lua
-- If you need a counter, bound it
local error_count = 0
local window_start = os.clock()

function cb_filter(tag, ts, record)
    if os.clock() - window_start > 60 then
        error_count = 0
        window_start = os.clock()
    end
    -- Bounded state
    return 1, ts, record
end
```

**Why:** Module-level tables persist for the entire process lifetime. A table that grows per-record at 100k rec/sec adds ~100k entries/sec with no upper bound.

**Caught by:** Load testing with sustained throughput over hours. Memory monitoring.


### Exhibit 12: Case Sensitivity

**Symptom:** Pattern matching works for lowercase input but fails for uppercase or mixed case.

**Wrong Code:**
```lua
-- Ruby original used .downcase.include?("web-prod")
if string.find(record["hostname"], "web-prod") then
    record["env"] = "production"
end
-- Misses "WEB-PROD", "Web-Prod", etc.
```

**Right Code:**
```lua
local host_lower = string.lower(record["hostname"] or "")
if string.find(host_lower, "web-prod") then
    record["env"] = "production"
end
```

**Why:** Lua's `string.find` is case-sensitive by default. Ruby's `.downcase` before `.include?` normalizes case, but AI models sometimes drop the normalization step during translation.

**Caught by:** Edge case tests with uppercase, lowercase, and mixed-case variants of the same input.


### Exhibit 14: Case-Sensitive Field Names

**Symptom:** A field that exists in the record cannot be read. `record["Status"]` returns `nil` even though the JSON has `"status"`.

**Wrong Code:**
```lua
local status = record["Status"]  -- Capital S
-- JSON had: {"status": "active"} — lowercase s
-- status is nil
```

**Right Code:**
```lua
local status = record["status"]  -- Exact case match
```

**Why:** Lua table keys are case-sensitive strings. `"Status"` and `"status"` are different keys. JSON field names preserve their original casing through FluentBit's parser.

**Caught by:** Any test that accesses the field. But the bug is subtle when field names are similar — `"requestUrl"` vs `"request_url"`.

