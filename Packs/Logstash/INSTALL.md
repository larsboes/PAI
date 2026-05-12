# Logstash — Installation Guide

**For AI agents installing this pack.**

---

## Welcome

```
Installing Logstash — Logstash Ruby filter development and CI pipeline patterns
```

---

## Phase 1: Verify PAI is configured

### Pi (primary)
```bash
grep -r "Logstash" ~/.pi/agent/config.yml 2>/dev/null && echo "OK config references PAI Packs dir" || echo "Check ~/.pi/agent/config.yml"

# config.yml should contain:
# skills:
#   customDirectories:
#     - ~/Developer/PAI/Packs
grep "customDirectories" ~/.pi/agent/config.yml && echo "OK" || echo "Add PAI/Packs to customDirectories in ~/.pi/agent/config.yml"
```

### Claude Code (alternative)
```bash
SKILL_DIR="$HOME/.claude/skills/Logstash"
[ -d "$SKILL_DIR" ] && echo "Already installed" || echo "Run Phase 4 (Claude Code install)"
```

---
## Phase 2: Check Dependencies

```bash
logstash --version && echo "OK Logstash available" || echo "MISSING Logstash — install from: https://www.elastic.co/downloads/logstash"
```

---

## Phase 3: Install (Claude Code only)

Pi discovers skills automatically via `customDirectories` — no copy needed.

For Claude Code:
```bash
mkdir -p ~/.claude/skills
cp -r "$(pwd)/." ~/.claude/skills/Logstash/
echo "Installed to ~/.claude/skills/Logstash/"
```

---

## Phase 4: Verify

Run the checks in [VERIFY.md](VERIFY.md).
