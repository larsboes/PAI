# Integrations v1.0.0 - Installation Guide

**This guide is designed for AI agents installing this pack into a user's infrastructure.**

---

## AI Agent Instructions

**This is a wizard-style installation.**

### Welcome Message

```
"I'm installing Integrations v1.0.0 — personal service integrations for Claude Code.

This pack adds 9 skills:
- gmcli — Gmail: search, read, send, drafts, labels
- gccli — Google Calendar: events, availability
- gdcli — Google Drive: list, search, upload, download
- github — GitHub: PRs, reviews, releases, CI
- notion — Notion: pages, databases, content
- obsidian — vault search, backlinks, UI control, health diagnostics
- zotero — citation library search and full-text retrieval

Let me analyze your system and guide you through installation."
```

---

## Phase 1: System Analysis

```bash
CLAUDE_DIR="$HOME/.claude"

echo "=== System Check ==="
[ -d "$CLAUDE_DIR" ] && echo "OK Claude Code directory" || echo "MISSING Claude Code directory"

# Check for optional dependencies
command -v uv &>/dev/null && echo "OK uv available (needed for obsidian)" || echo "WARN uv not found — obsidian skill requires uv"
```

---

## Phase 2: User Questions

Ask the user which integrations they use:
- Do you use Obsidian? (needed for obsidian skill)
- Do you have a Zotero account? (needed for zotero skill)

Only install skills for services the user actually uses.

---

## Phase 3: Installation

```bash
PACK_DIR="$(dirname "$0")"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR/skills"

for skill in gmcli gccli gdcli github notion obsidian zotero; do
  if [ -d "$PACK_DIR/src/$skill" ]; then
    cp -r "$PACK_DIR/src/$skill" "$CLAUDE_DIR/skills/$skill"
    echo "Installed: $skill"
  fi
done
```

---

## Phase 4: Verification

Run VERIFY.md checks to confirm installation.

---

## Dependencies

- uv (for obsidian Python scripts)
- Zotero API key (for zotero skill)
