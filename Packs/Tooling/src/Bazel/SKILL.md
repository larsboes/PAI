---
name: Bazel
description: "Bazel build system — MODULE.bazel (bzlmod), custom rules, test targets, Starlark, CI integration, and remote caching. Use when setting up or debugging Bazel builds."
---

# Bazel

Hermetic build system with caching, reproducibility, and custom rules via Starlark.

## Quick Reference

- **Module file:** `MODULE.bazel` — declares deps (WORKSPACE removed in Bazel 9)
- **Build files:** `BUILD.bazel` — targets per package
- **Rules:** Starlark (Python-like, deterministic, no I/O in analysis)
- **Tests:** Rule produces script, exit 0 = pass, non-zero = fail
- **Caching:** Same inputs = instant skip. Remote cache shares across CI jobs.
- **Formatter:** `buildifier -r .` — mandatory for clean .bzl files
- **Query:** `bazel query "deps(//target)"` — explore the dependency graph

## References

| Need | File |
|------|------|
| MODULE.bazel, BCR, deps, .bazelversion | [references/bzlmod.md](references/bzlmod.md) |
| Writing custom test rules (Starlark) | [references/custom-rules.md](references/custom-rules.md) |
| GitLab CI, remote cache, Docker tests | [references/ci-integration.md](references/ci-integration.md) |
| Bazel 7/8/9 changes, style guide, queries, perf | [references/modern-principles.md](references/modern-principles.md) |

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/bazel-debug.sh` | Query deps, rdeps, changed targets, profile builds |
| `scripts/bazel-init.sh` | Bootstrap a new project with MODULE.bazel + .bazelrc |

## External References

- [Bazel 9 Release Notes](https://blog.bazel.build/2026/01/20/bazel-9.html)
- [Bzlmod User Guide](https://bazel.build/external/module)
- [Writing Rules](https://bazel.build/extending/rules)
- [Test Encyclopedia](https://bazel.build/reference/test-encyclopedia)
- [.bzl Style Guide](https://bazel.build/rules/bzl-style)
- [Query Guide](https://bazel.build/query/guide)
- [Remote Execution](https://bazel.build/remote/rbe)
- [Bazel Central Registry](https://registry.bazel.build/)
- [Buildifier](https://github.com/bazelbuild/buildtools/blob/main/buildifier/README.md)
- [Airbnb Monorepo Migration](https://airbnb.tech/infrastructure/migrating-airbnbs-jvm-monorepo-to-bazel/)
