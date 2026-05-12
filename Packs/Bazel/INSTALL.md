# Bazel — Installation Guide

**For AI agents installing this pack.**

---

## Welcome

```
Installing Bazel — Bazel build system — MODULE.bazel, custom rules, test targets, Starlark, remote caching
```

---

## Phase 1: Verify PAI is configured

### Pi (primary)
```bash
grep -r "Bazel" ~/.pi/agent/config.yml 2>/dev/null && echo "OK config references PAI Packs dir" || echo "Check ~/.pi/agent/config.yml"

# config.yml should contain:
# skills:
#   customDirectories:
#     - ~/Developer/PAI/Packs
grep "customDirectories" ~/.pi/agent/config.yml && echo "OK" || echo "Add PAI/Packs to customDirectories in ~/.pi/agent/config.yml"
```

### Claude Code (alternative)
```bash
SKILL_DIR="$HOME/.claude/skills/Bazel"
[ -d "$SKILL_DIR" ] && echo "Already installed" || echo "Run Phase 4 (Claude Code install)"
```

---
## Phase 2: Check Dependencies

```bash
bazelisk version 2>/dev/null || bazel version 2>/dev/null && echo "OK Bazel/Bazelisk available" || echo "MISSING Bazel/Bazelisk — install from: https://bazel.build/install/bazelisk"
```

---

## Phase 3: Install (Claude Code only)

Pi discovers skills automatically via `customDirectories` — no copy needed.

For Claude Code:
```bash
mkdir -p ~/.claude/skills
cp -r "$(pwd)/." ~/.claude/skills/Bazel/
echo "Installed to ~/.claude/skills/Bazel/"
```

---

## Phase 4: Verify

Run the checks in [VERIFY.md](VERIFY.md).
