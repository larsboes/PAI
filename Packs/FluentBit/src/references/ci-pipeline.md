
# CI Integration with FluentBit

## Why This Matters

Tests that only run locally are not tests — they are suggestions. The CI pipeline guarantees that every push validates filters against test cases using the exact same FluentBit binary as production. The patterns here (debug image, parallel matrix, FAILED flag, artifact preservation) are battle-tested in production CI. Without CI, a broken filter can reach production undetected. With CI, it cannot merge.

FluentBit tests in GitLab CI — from the debug image to the production pipeline.

## The Pipeline at a Glance

A typical CI pipeline has stages like: `build → test → deploy`. The **test** stage is where FluentBit tests run against Lua filters.

```
scaffold → migrate → test → judge → metrics → document → compare → commit
```

## 1. Why the `-debug` Image?

FluentBit ships its official Docker image as a **Distroless** container. This means: no `/bin/sh`, no package manager, no standard tools. In CI this is a problem — GitLab CI needs a shell to execute scripts.

| | fluent/fluent-bit:4.2.2 | fluent/fluent-bit:4.2.2-debug |
|---|---|---|
| Shell | No `/bin/sh` — Distroless | `/bin/sh` available (busybox) |
| FluentBit | Identical build | Identical build |
| CI-compatible | No — entrypoint override not possible | Yes — shell scripts executable |

```bash
# Standard image — fails:
$ docker run fluent/fluent-bit:4.2.2 sh
# docker: Error: exec: "sh": not found

# Debug image — works:
$ docker run -it fluent/fluent-bit:4.2.2-debug sh
/ # fluent-bit --version
Fluent Bit v4.2.2
```

> [!warning] Entrypoint Override in GitLab CI
> In GitLab CI, the `entrypoint` must be set to `["/bin/sh", "-c"]` because the image's default entrypoint is `/fluent-bit/bin/fluent-bit`. Without the override, GitLab would try to pass the CI script as an argument to FluentBit.

## 2. GitLab CI Base Configuration

The `.fluentbit_test` template is the foundation for all FluentBit test jobs:

```yaml
variables:
  FLUENT_BIT_VERSION: 4.2.2

.fluentbit_test:
  image:
    name: fluent/fluent-bit:$FLUENT_BIT_VERSION-debug
    entrypoint: ["/bin/sh", "-c"]   # CRITICAL: Override of default entrypoint
  before_script:
    - export PATH="/fluent-bit/bin:$PATH"
    - fluent-bit --version          # Sanity check: fail-fast on wrong image
```

- **Global variable**: Pins the exact FluentBit version for reproducibility
- **Hidden key** (`.` prefix): Not interpreted as a job, other jobs use `extends`
- **PATH export**: FluentBit is located at `/fluent-bit/bin/` — without the PATH export, every call would need the full path

## 3. Build Step: Preparing Test Data

The test data exists as CSV and Lua files. Before FluentBit can process them, they need to be converted to JSON-Lines and matching FluentBit configs need to be generated.

> [!info] Why a separate build step?
> FluentBit itself has no LuaJIT CLI — it can only run Lua as an embedded filter. The `openresty/openresty:alpine` image provides a full LuaJIT, which we use to execute the build script.

```yaml
build-test-artifacts:
  stage: test
  image: openresty/openresty:alpine   # Has LuaJIT
  needs: []                            # No dependencies, starts immediately
  script:
    - luajit tests/src/build.lua
  artifacts:
    paths:
      - tests/inputs/
      - tests/configs/
    expire_in: 1 hour
```

What the build script produces:

```
# Before (human-maintained)
tests/data/enrich/ip_ranges.csv
tests/data/enrich/service_map.lua

# After (generated)
tests/inputs/enrich/ip_ranges.json      # JSON-Lines for FluentBit tail input
tests/configs/enrich/ip_ranges.yaml      # Complete FluentBit pipeline config
tests/inputs/enrich/service_map.json
tests/configs/enrich/service_map.yaml
```

## 4. Test Step: Running FluentBit

Each filter is tested in parallel. GitLab CI creates a separate job per filter module via the `parallel: matrix` directive.

```yaml
test-filters:
  extends: .fluentbit_test
  needs:
    - job: build-test-artifacts
      artifacts: true
  parallel:
    matrix:
      - FILTER: [enrich, normalize, transform, validate, route, utils]
  script:
    - |
      echo "=== Testing: $FILTER ==="
      for config in tests/configs/$FILTER/*.yaml; do
        echo "  Running: $(basename $config)"
        fluent-bit -c "$config"
      done
  artifacts:
    paths: [tests/results/]
    when: always                      # Even on failure!
```

> [!success] Zero Gap Between Local and CI
> The same `fluent-bit -c config.yaml` command runs identically on your machine and in CI. No special CI-only logic, no environment differences. If it passes locally, it passes in CI. This is enabled by the Test Framework design: everything is self-contained in the config + test data.

The exit code of FluentBit determines pass/fail. If the `expect` filter or `assert_filter.lua` finds an error, FluentBit terminates with exit code != 0. GitLab CI interprets this as a job failure.

## 5. Artifact Handling

The `when: always` pattern is crucial for error analysis:

```yaml
# Standard: Artifacts only on success
artifacts:
  paths: [tests/results/]
  # when: on_success  (Default)

# Better: ALWAYS store artifacts
artifacts:
  paths: [tests/results/]
  when: always  # Even on failure!
```

- With `when: on_success` (default), artifacts are lost on failed jobs
- But that is exactly when you need them most — the FluentBit stdout output shows what went wrong
- `when: always` ensures test results and logs are always downloadable

In the experiment pipeline, `when: always` is even set globally as a default:

```yaml
default:
  artifacts:
    paths: [runs/]
    when: always  # Every job keeps its artifacts
```

## 6. Error Handling: The FAILED-Flag Pattern

**Problem:** When a test fails, the shell loop aborts. The remaining tests don't run. You only see the first error.

**Solution:** The `FAILED` flag pattern collects all errors and reports at the end:

```yaml
test-filters:
  script:
    - |
      FAILED=0
      for config in tests/configs/$FILTER/*.yaml; do
        echo "Running: $(basename $config)"
        fluent-bit -c "$config" || FAILED=1
      done
      # Let all tests run, decide at the end
      [ "$FAILED" -eq 0 ] || exit 1
  artifacts:
    when: always  # Keep even on failures
```

> [!info] How it works
> `fluent-bit -c "$config" || FAILED=1` — if FluentBit exits with code != 0, FAILED is set to 1, but the loop continues. Only at the end does `[ "$FAILED" -eq 0 ] || exit 1` check whether any test failed.

This way you see **all** errors in a single pipeline run, not just the first one.

## 7. Integration into the Experiment Pipeline

The experiment pipeline has a special flow: The tests must use the **migrated filters** from the `migrate` stage, not the original filters. For this, the test job uses the artifacts from the migrate job.

1. **scaffold** creates a run directory with a template structure and exports `RUN_ID` via dotenv
2. **migrate** produces Lua filters — Claude Code migrates Ruby filters to Lua
3. **test** validates the migrated filters — 4 parallel jobs (2 conditions x 2 modes)
4. **judge** evaluates the quality — independent LLM evaluation

The crucial part — how the test job finds the migrated filters:

```yaml
test:
  image: openresty/openresty:alpine
  parallel:
    matrix:
      - CONDITION: [full-context, minimal]
        MODE: [ACCESS, SESSION]
  script:
    - *resolve_run
    - |
      FILTER="$RUN_DIR/conditions/$CONDITION/output/filters/enrich.lua"
      if [ ! -f "$FILTER" ]; then
        echo "[$CONDITION] No enrich.lua -- skipping"
        exit 0
      fi
      export FILTER_DATA_DIR="$RUN_DIR/source"
      export FILTER_MODE="$MODE"
      
      luajit "$TESTS_DIR/unit/test_enrich.lua" "$FILTER" "$MODE"
      for test_file in "$TESTS_DIR"/properties/test_*.lua; do
        luajit "$test_file" "$FILTER" "$MODE"
      done
```

## 8. Example: Shared CI Template

A common pattern is to share the FluentBit base config via GitLab CI `include`:

```yaml
# .gitlab-ci.yml (excerpt)
include:
  - project: 'your-group/cicd-templates'
    file: ['fluentbit-cicd.yml']
    ref: '2.2.2'

variables:
  FLUENT_BIT_VERSION: 4.2.2
  IMAGE_VERSION: $FLUENT_BIT_VERSION

.test_config:
  image:
    name: fluent/fluent-bit:$FLUENT_BIT_VERSION-debug
    entrypoint: ["/bin/sh", "-c"]
  script:
    - export PATH="/fluent-bit/bin:$PATH"
    - echo "Fluent Bit version:"
    - fluent-bit --version

unit_tests_demo:
  stage: test
  extends: .test_config
  variables:
    ENVFILE_PATH: "$CI_PROJECT_DIR/fluentbit_output/processed.log"
  script:
    - !reference [.test_config, script]
    - mkdir -p "$(dirname "$ENVFILE_PATH")"
    - fluent-bit -c fluent-bit-ci.yaml
  artifacts:
    paths: [${ENVFILE_PATH}]
    expire_in: 1 hour
```

What this pattern demonstrates:

- The `.test_config` template with `!reference` instead of `extends` for script blocks
- Storing FluentBit output as an artifact for later analysis
- Each filter gets its own test job
- The same FluentBit version in testing as in production (via variable)

## 9. Local Development Workflow

CI is important, but the daily workflow happens locally. Three Taskfile commands are enough:

```bash
# 1. Build only (CSV/Lua -> JSON + Configs)
$ task test:build

# 2. Build + Test (a single module)
$ task test -- enrich

# 3. File watcher for TDD loop
$ task test:watch -- enrich

# 4. Commit: ONLY data/ — everything else is generated
$ git add tests/data/
$ git commit -m "Add region code edge cases for EU/APAC"
$ git push   # CI builds and tests automatically
```

> [!danger] Commit Rule
> Only `tests/data/` is committed. The directories `tests/inputs/`, `tests/configs/`, and `tests/results/` are build artifacts and belong in `.gitignore`. They are regenerated by the build step in CI. Committing generated files causes merge conflicts and version skew between what the CI builds and what is in the repo. See Filter Modules for the 22 test data files that are the source of truth.

The Taskfile configuration behind it:

```yaml
# Taskfile.yml (excerpt)
tasks:
  test:build:
    desc: "Generate JSON inputs + FluentBit configs from CSV/Lua"
    cmds:
      - luajit tests/src/build.lua {{.CLI_ARGS}}

  test:
    desc: "Run tests (builds implicitly)"
    deps: [test:build]
    cmds:
      - |
        for config in tests/configs/{{.CLI_ARGS | default "*"}}/*.yaml; do
          fluent-bit -c "$config"
        done

  test:watch:
    desc: "File watcher for TDD loop"
    cmds:
      - watchexec -e csv,lua -- task test {{.CLI_ARGS}}
```

## Summary

The CI integration consists of a few clearly separated building blocks:

1. **Use the debug image** — `fluent/fluent-bit:4.2.2-debug` with `entrypoint: ["/bin/sh", "-c"]`
2. **Define a template** — `.fluentbit_test` sets PATH and checks the version
3. **Build step: prepare data** — LuaJIT converts CSV/Lua to JSON + FluentBit configs
4. **Test step: run in parallel** — `parallel: matrix` for parallel filter tests, `FAILED` flag for complete error reporting
5. **Artifacts: always store** — `when: always` ensures debugging output is never lost

> [!tip] Key Takeaway
> The pattern is proven in production, scalable (parallel matrix), and debuggable (artifacts:when:always). The same tests run locally in under 1 second and in CI with the exact same FluentBit.

