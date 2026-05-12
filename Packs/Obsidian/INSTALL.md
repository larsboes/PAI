# Obsidian — Installation Guide

**For AI agents installing this pack.**

---

## Welcome

```
Installing Obsidian — Full vault integration with search, canvas generation, bases, bulk ops, and diagnostics
```

---

## Phase 1: Prerequisites

### Required
```bash
# ripgrep (used for vault search)
which rg && echo "OK rg installed" || echo "MISSING: install ripgrep"

# uv (Python script runner)
which uv && echo "OK uv installed" || echo "MISSING: install uv (https://docs.astral.sh/uv/)"
```

### Configuration
```bash
# ~/.env must contain vault path
grep -q "OBSIDIAN_VAULT_PATH" ~/.env && echo "OK vault path configured" || echo "Add OBSIDIAN_VAULT_PATH=/path/to/vault to ~/.env"

# Optional: Obsidian binary path (for CLI features)
grep -q "OBSIDIAN_BIN" ~/.env && echo "OK binary path configured" || echo "INFO: OBSIDIAN_BIN not set (CLI features disabled)"
```

---

## Phase 2: Verify PAI is configured

### Pi (primary)
```bash
grep -r "Obsidian" ~/.pi/agent/config.yml 2>/dev/null && echo "OK config references PAI Packs dir" || echo "Check ~/.pi/agent/config.yml"

# config.yml should contain:
# skills:
#   customDirectories:
#     - ~/Developer/PAI/Packs
grep "customDirectories" ~/.pi/agent/config.yml && echo "OK" || echo "Add PAI/Packs to customDirectories in ~/.pi/agent/config.yml"
```

### Claude Code (alternative)
```bash
SKILL_DIR="$HOME/.claude/skills/obsidian"
[ -d "$SKILL_DIR" ] && echo "Already installed" || echo "Run Phase 3 (Claude Code install)"
```

---

## Phase 3: Install (Claude Code only)

Pi discovers skills automatically via `customDirectories` — no copy needed.

For Claude Code:
```bash
mkdir -p ~/.claude/skills
cp -r "$(pwd)/src/." ~/.claude/skills/obsidian/
echo "Installed to ~/.claude/skills/obsidian/"
```

---

## Phase 4: Verify

Run the checks in [VERIFY.md](VERIFY.md).
