# Writing Custom Bazel Test Rules

## The Core Pattern

A Bazel test rule generates an executable script. Exit 0 = pass, non-zero = fail.

```python
# my_rules/defs.bzl

def _my_test_impl(ctx):
    # 1. Declare the output script
    script = ctx.actions.declare_file(ctx.label.name + "_test.sh")

    # 2. Write the test logic
    ctx.actions.write(
        output = script,
        content = """#!/bin/bash
set -euo pipefail

INPUT="{input}"
EXPECTED="{expected}"

# Your test logic here
ACTUAL=$(process "$INPUT")
diff <(echo "$ACTUAL") "$EXPECTED" || {{ echo "FAIL"; exit 1; }}
echo "PASS"
""".format(
            input = ctx.file.input.short_path,
            expected = ctx.file.expected.short_path,
        ),
        is_executable = True,
    )

    # 3. Declare runfiles (files available at test runtime)
    runfiles = ctx.runfiles(files = [ctx.file.input, ctx.file.expected])

    return [DefaultInfo(executable = script, runfiles = runfiles)]

# 4. Define the rule
my_test = rule(
    implementation = _my_test_impl,
    test = True,  # Makes this a test rule
    attrs = {
        "input": attr.label(allow_single_file = True, mandatory = True),
        "expected": attr.label(allow_single_file = True, mandatory = True),
    },
)
```

## Usage in BUILD.bazel

```python
load("//my_rules:defs.bzl", "my_test")

my_test(
    name = "example_test",
    input = "testdata/input.json",
    expected = "testdata/expected.json",
)
```

```bash
bazel test //path/to:example_test
```

## Key Concepts

### Phases

| Phase | What happens | What you can do |
|-------|-------------|----------------|
| **Loading** | BUILD files parsed, rules instantiated | Declare dependencies |
| **Analysis** | Rule implementations run, action graph built | Register actions, create scripts |
| **Execution** | Actions run (scripts executed, commands run) | Actual work (compiling, testing) |

**Critical:** In the analysis phase (your `_impl` function), you can NOT run commands or read file contents. You can only declare what WILL happen during execution.

### Attrs — Declaring Inputs

```python
attrs = {
    # Single file
    "config": attr.label(allow_single_file = True),

    # Multiple files
    "srcs": attr.label_list(allow_files = [".lua", ".py"]),

    # String option
    "mode": attr.string(default = "strict", values = ["strict", "lenient"]),

    # Boolean flag
    "verbose": attr.bool(default = False),

    # Another rule's output
    "dep": attr.label(providers = [DefaultInfo]),
}
```

### Runfiles — Files Available at Runtime

```python
# Your test script can access these files at their short_path locations
runfiles = ctx.runfiles(files = [ctx.file.input, ctx.file.config])

# Include transitive runfiles from dependencies
runfiles = runfiles.merge(ctx.attr.dep[DefaultInfo].default_runfiles)
```

### ctx.actions — Registering Work

```python
# Write a file (scripts, configs)
ctx.actions.write(output = file, content = "...", is_executable = True)

# Run a command
ctx.actions.run(
    executable = ctx.executable._tool,
    arguments = ["--input", input.path, "--output", output.path],
    inputs = [input],
    outputs = [output],
)

# Run a shell command
ctx.actions.run_shell(
    command = "cat {input} | process > {output}".format(...),
    inputs = [input],
    outputs = [output],
)
```

## Example: Logstash Test Rule

```python
def _logstash_test_impl(ctx):
    script = ctx.actions.declare_file(ctx.label.name + "_test.sh")
    ctx.actions.write(
        output = script,
        content = """#!/bin/bash
set -euo pipefail
export LOGSTASH_INPUT_PATH="{input}"
export OUTPUT_EXTENSION="output"
cat "{input}" | logstash -f "{config}"
# Compare output to expected
python3 -c "
import json, sys
actual = [json.loads(l) for l in open('{input}_output') if l.strip()]
expected = [json.loads(l) for l in open('{expected}') if l.strip()]
if actual != expected:
    print('FAIL'); sys.exit(1)
print('PASS')
"
""".format(
            input = ctx.file.input.short_path,
            expected = ctx.file.expected.short_path,
            config = ctx.file.config.short_path,
        ),
        is_executable = True,
    )
    return [DefaultInfo(
        executable = script,
        runfiles = ctx.runfiles(files = [ctx.file.input, ctx.file.expected, ctx.file.config]),
    )]

logstash_test = rule(
    implementation = _logstash_test_impl,
    test = True,
    attrs = {
        "input": attr.label(allow_single_file = True, mandatory = True),
        "expected": attr.label(allow_single_file = True, mandatory = True),
        "config": attr.label(allow_single_file = True, mandatory = True),
    },
)
```

## Common Mistakes

| Mistake | Why it fails |
|---------|-------------|
| Reading file contents in `_impl` | Analysis phase has no I/O — only declare actions |
| Forgetting runfiles | Test script can't find its input files at runtime |
| Hardcoded absolute paths | Tests must be location-independent. Use `short_path` |
| Not setting `test = True` | Rule won't be recognized by `bazel test` |
| Using `fail()` for test failures | `fail()` is a BUILD error. Generate a failing script instead |

## References

- [Writing Rules](https://bazel.build/extending/rules)
- [Testing Rules](https://bazel.build/rules/testing)
- [Test Encyclopedia](https://bazel.build/reference/test-encyclopedia)
- [Actions API](https://bazel.build/rules/lib/builtins/actions)
- [Tweag: Bazel rules to test Bazel rules](https://www.tweag.io/blog/2022-10-06-bazel-rules-to-test-bazel-rules/)
