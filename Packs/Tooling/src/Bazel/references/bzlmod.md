# Bzlmod — Bazel's Module System

## MODULE.bazel Basics

Every Bazel project starts with `MODULE.bazel` at the repo root:

```python
module(
    name = "my_project",
    version = "1.0.0",
)

# Declare dependencies from the Bazel Central Registry
bazel_dep(name = "rules_python", version = "1.1.0")
bazel_dep(name = "rules_oci", version = "2.2.0")  # for container images

# Use extensions for toolchain setup
python = use_extension("@rules_python//python/extensions:python.bzl", "python")
python.toolchain(python_version = "3.12", is_default = True)
```

## Key Concepts

| Concept | What it does |
|---------|-------------|
| `bazel_dep()` | Declares a dependency, fetched from registry or override |
| `use_extension()` | Loads a module extension for additional setup (toolchains, etc.) |
| `local_path_override()` | Points a dependency to a local path (for vendoring/dev) |
| `git_override()` | Points a dependency to a git repo + commit |

## Bazel Central Registry (BCR)

Dependencies are resolved from https://registry.bazel.build/ by default. Search for available modules there. No need to vendor or manually download.

```python
# These come from BCR automatically:
bazel_dep(name = "rules_python", version = "1.1.0")
bazel_dep(name = "rules_go", version = "0.50.1")
bazel_dep(name = "rules_rust", version = "0.56.0")
```

## .bazelversion

Pin the Bazel version for reproducibility:
```
7.1.1
```

Tools like `bazelisk` (drop-in replacement for `bazel`) read this and auto-download the right version.

## .bazelrc — Project Settings

```python
# Enable bzlmod (default in Bazel 7+, explicit is good)
common --enable_bzlmod

# Output behavior
build --color=yes
build --show_timestamps
test --test_output=errors

# Performance
build --jobs=auto
build --experimental_remote_cache_compression
```

## WORKSPACE Is Dead

- **Bazel 7:** bzlmod on by default, WORKSPACE still works
- **Bazel 8 (late 2024):** WORKSPACE disabled by default
- **Bazel 9 (late 2025):** WORKSPACE removed entirely

If you see `WORKSPACE` or `WORKSPACE.bazel` files — that's legacy. Migrate to `MODULE.bazel`.

## References

- [Bzlmod User Guide](https://bazel.build/external/module)
- [Module Extensions](https://bazel.build/external/extension)
- [BCR Search](https://registry.bazel.build/)
- [Migration Guide](https://github.com/bazelbuild/bazel/blob/release-9.0.0/site/en/external/migration.md)
