# BlindSpot — Installation Guide

## For Pi Agent

Add the PAI Packs directory to `~/.pi/agent/config.yml`:

```yaml
skills:
  customDirectories:
    - ~/.pi/agent/skills
```

Then run `sync.sh` from the PAI repo to symlink active skills.

## For Claude Code

Skills are synced via `sync.sh`:

```bash
cd ~/Developer/PAI && ./sync.sh --confirm
```

## Manual Install

```bash
SKILL_DIR="$HOME/.claude/skills/BlindSpot"
mkdir -p "$SKILL_DIR"
cp -R src/* "$SKILL_DIR/"
```

## Verify

Run the checks in [VERIFY.md](VERIFY.md).
