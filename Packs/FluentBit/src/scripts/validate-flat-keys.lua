#!/usr/bin/env luajit
-- validate-flat-keys.lua — Static check for nested table patterns in Lua filters
-- Usage: luajit validate-flat-keys.lua <file.lua> [file2.lua ...]
--
-- Detects common structural errors:
--   1. Nested table assignments: record["x"] = { ... }
--   2. Chained bracket access: record["x"]["y"]
--   3. Dot-access on record: record.field.subfield

local issues = {}
local total_issues = 0

local function check_file(path)
    local f = io.open(path, "r")
    if not f then
        io.stderr:write("ERROR: Cannot open " .. path .. "\n")
        return
    end

    local file_issues = {}
    local lineno = 0

    for line in f:lines() do
        lineno = lineno + 1

        -- Pattern 1: record["x"] = { ... }  (nested table assignment)
        if line:match('record%[.-%]%s*=%s*{') then
            table.insert(file_issues, {
                line = lineno,
                kind = "NESTED_TABLE",
                text = line:match("^%s*(.-)%s*$"),
                fix = "Use flat keys: record[\"parent.child\"] = value"
            })
        end

        -- Pattern 2: record["x"]["y"]  (chained bracket access)
        if line:match('record%[.-%]%[.-%]') then
            table.insert(file_issues, {
                line = lineno,
                kind = "CHAINED_ACCESS",
                text = line:match("^%s*(.-)%s*$"),
                fix = "Use flat key: record[\"parent.child\"]"
            })
        end

        -- Pattern 3: record.field.subfield (dot access suggesting nesting)
        if line:match('record%.%w+%.%w+') then
            table.insert(file_issues, {
                line = lineno,
                kind = "DOT_NESTING",
                text = line:match("^%s*(.-)%s*$"),
                fix = "Use bracket notation: record[\"field.subfield\"]"
            })
        end
    end

    f:close()

    if #file_issues > 0 then
        io.write(string.format("\n%s (%d issues)\n", path, #file_issues))
        for _, issue in ipairs(file_issues) do
            io.write(string.format("  L%d [%s]: %s\n", issue.line, issue.kind, issue.text))
            io.write(string.format("       Fix: %s\n", issue.fix))
        end
        total_issues = total_issues + #file_issues
    end
end

-- Main
if #arg == 0 then
    print("Usage: luajit validate-flat-keys.lua <file.lua> [file2.lua ...]")
    print("")
    print("Checks Lua FluentBit filters for nested table patterns that cause")
    print("silent Elasticsearch mapping conflicts.")
    os.exit(0)
end

print("Checking for nested table patterns...")

for _, path in ipairs(arg) do
    check_file(path)
end

if total_issues == 0 then
    print("\n✓ All files clean — no nested table patterns found.")
    os.exit(0)
else
    io.write(string.format("\n✗ Found %d potential flat-key violations.\n", total_issues))
    os.exit(1)
end
