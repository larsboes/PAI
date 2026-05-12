# Cloudflare — Installation Guide

**For AI agents installing this pack.**

---

## Welcome

```
Installing Cloudflare — Cloudflare Workers, Pages, KV, R2, D1, DNS — wrangler CLI and Code Mode MCP
```

---

## Phase 1: Verify PAI is configured

### Pi (primary)
```bash
grep -r "Cloudflare" ~/.pi/agent/config.yml 2>/dev/null && echo "OK config references PAI Packs dir" || echo "Check ~/.pi/agent/config.yml"

# config.yml should contain:
# skills:
#   customDirectories:
#     - ~/Developer/PAI/Packs
grep "customDirectories" ~/.pi/agent/config.yml && echo "OK" || echo "Add PAI/Packs to customDirectories in ~/.pi/agent/config.yml"
```

### Claude Code (alternative)
```bash
SKILL_DIR="$HOME/.claude/skills/Cloudflare"
[ -d "$SKILL_DIR" ] && echo "Already installed" || echo "Run Phase 4 (Claude Code install)"
```

---
## Phase 2: Check Dependencies

```bash
wrangler --version && echo "OK Wrangler CLI available" || echo "MISSING Wrangler CLI — install from: https://developers.cloudflare.com/workers/wrangler/install-and-update/"
```

---

## Phase 3: Install (Claude Code only)

Pi discovers skills automatically via `customDirectories` — no copy needed.

For Claude Code:
```bash
mkdir -p ~/.claude/skills
cp -r "$(pwd)/." ~/.claude/skills/Cloudflare/
echo "Installed to ~/.claude/skills/Cloudflare/"
```

---

## Phase 4: Verify

Run the checks in [VERIFY.md](VERIFY.md).
