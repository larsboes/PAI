# Bazel CI Integration

## Why Bazel in CI

| Without Bazel | With Bazel |
|--------------|-----------|
| Run all tests every time | Only run tests whose inputs changed |
| Sequential execution | Parallel by default |
| "Works on my machine" | Hermetic — same result everywhere |
| Rebuild everything | Cached artifacts (local + remote) |
| Scripts do orchestration | Declarative BUILD files |

## GitLab CI with Bazel

### Basic Setup

```yaml
variables:
  BAZEL_VERSION: "7.1.1"

.bazel_base:
  image: gcr.io/bazel-public/bazel:${BAZEL_VERSION}
  cache:
    key: bazel-${CI_COMMIT_REF_SLUG}
    paths:
      - .cache/bazel/

bazel-test:
  extends: .bazel_base
  stage: test
  script:
    - bazel test //...
  rules:
    - changes:
        - "**/*.bzl"
        - "**/BUILD.bazel"
        - "MODULE.bazel"
        - "**/*.py"
        - "**/*.lua"
        - "**/*.conf"
```

### With Remote Cache

```yaml
bazel-test:
  extends: .bazel_base
  script:
    - |
      bazel test //... \
        --remote_cache=grpc://cache.example.com:9092 \
        --remote_upload_local_results=true
```

Remote cache = if ANY CI run already computed a result for the same inputs, reuse it instantly.

### Parallel Test Execution

Bazel parallelizes automatically. Control with:
```
bazel test //... --jobs=8           # limit parallelism
bazel test //... --test_output=all  # show all test output
bazel test //... --test_tag_filters=logstash  # filter by tag
```

## Pattern: Tests That Need Docker/External Tools

When tests require tools not in the Bazel sandbox (like `logstash` or `fluent-bit`):

### Option 1: Tag tests, run on appropriate runners

```python
logstash_test(
    name = "my_test",
    tags = ["requires-logstash", "external"],
    ...
)
```

```yaml
# CI only runs these on runners with logstash available
bazel-logstash-tests:
  image: docker.elastic.co/logstash/logstash:8.10.0
  script:
    - bazel test //tests/... --test_tag_filters=requires-logstash
```

### Option 2: Use `local = True` for non-hermetic tests

```python
logstash_test(
    name = "my_test",
    local = True,  # Runs on host, not in sandbox
    ...
)
```

### Option 3: rules_oci for container-based tests

```python
bazel_dep(name = "rules_oci", version = "2.2.0")

# Pull test image
oci.pull(
    name = "logstash",
    image = "docker.elastic.co/logstash/logstash",
    tag = "8.10.0",
)
```

## Pattern: Generating Test Configs

Use `genrule` or a custom rule to generate configs from templates:

```python
genrule(
    name = "generate_test_config",
    srcs = ["template.yaml", "test_data.csv"],
    outs = ["generated_config.yaml"],
    cmd = "luajit $(location //tools:build_config) $(SRCS) > $@",
    tools = ["//tools:build_config"],
)
```

## Caching Strategy

```
Level 1: Local disk cache (default)
  └── ~/.cache/bazel/ — survives between runs

Level 2: Remote cache (shared across CI jobs)
  └── gRPC/HTTP cache server — any job's result reusable by others

Level 3: Remote execution (advanced)
  └── Build/test on a cluster, not locally
```

For most projects, Level 1 + Level 2 gives 80% of the benefit.

## .bazelrc for CI

```python
# CI-specific settings (applied with --config=ci)
build:ci --color=yes
build:ci --show_timestamps
build:ci --jobs=auto
test:ci --test_output=errors
test:ci --flaky_test_attempts=2

# Local development settings
build --color=yes
test --test_output=errors
```

Usage: `bazel test //... --config=ci`

## Common Mistakes in CI

| Mistake | Fix |
|---------|-----|
| Not caching `.cache/bazel/` | Add to CI cache, keyed by branch |
| Running `bazel clean` every time | Defeats the purpose of caching |
| Using `--spawn_strategy=local` everywhere | Breaks hermeticity |
| Not pinning `.bazelversion` | Different Bazel versions = different results |
| Tests depend on host tools without declaring | Use `tags = ["requires-X"]` or container rules |

## References

- [Bazel Remote Caching](https://bazel.build/remote/caching)
- [Bazel CI Best Practices](https://bazel.build/configure/best-practices)
- [Test Encyclopedia](https://bazel.build/reference/test-encyclopedia)
- [rules_oci (container images)](https://github.com/bazel-contrib/rules_oci)
