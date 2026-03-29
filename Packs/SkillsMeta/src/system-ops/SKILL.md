---
name: system-ops
description: "Use for system-wide PAI operations: installing skills, checking system status, navigating the stack architecture."
---

# System Operations

Quick reference for the PAI infrastructure. Two source repos → shared `~/.pai/` layer → Claude Code + pi.

## Architecture at a Glance

```
PAI/skills/          (public, generic)   → ~/Developer/PAI
pai-personal/skills/ (private, personal) → ~/Developer/pai-personal
        ↓ install.sh ↓
~/.pai/skills/       (shared layer — both tools read from here)
        ↓
~/.claude/skills/    (Claude Code)
~/.pi/skills/        (pi)
```

**Rule:** Always edit skills in `~/Developer/PAI/` or `~/Developer/pai-personal/`. Never edit in `~/.claude/skills/` or `~/.pi/skills/` directly.

---

## Install / Sync Skills

```bash
# Install all pai-personal skills → ~/.pai/skills/
cd ~/Developer/pai-personal && ./install.sh

# Install all PAI skills → ~/.pai/skills/
cd ~/Developer/PAI && ./install.sh   # once PAI install script exists
```

---

## Create a New Skill

Use `/skill-creator` — it guides through placement, structure, and quality checks.

Quick decision:
- Personal / private tool → `pai-personal/skills/<name>/`
- Generic / shareable → `PAI/skills/<name>/`

Minimal structure:
```
skills/<name>/
  SKILL.md       ← required
  scripts/       ← optional (colocated scripts, use ${CLAUDE_SKILL_DIR}/scripts/)
  references/    ← optional (deep docs, lazy-loaded)
```

---

## Paths Reference

| Path | Purpose |
|------|---------|
| `~/Developer/PAI/skills/` | Public skill source of truth (40 skills) |
| `~/Developer/pai-personal/skills/` | Personal skill source of truth (15 skills) |
| `~/.pai/skills/` | Merged install target (shared layer) |
| `~/.pai/memory/` | Shared memory (both Claude Code + pi) |
| `~/.pai/data/` | Persistent runtime data (obsidian-rag index, etc.) |
| `~/.pai/config.json` | Registry: repo locations, machine type |
| `~/.claude/skills/` | Claude Code runtime (downstream — do not edit) |
| `~/.pi/skills/` | pi runtime (downstream — do not edit) |
| `~/.env` | All secrets + paths (FRITZBOX_*, SYNOLOGY_*, OBSIDIAN_*, ...) |

---

## Memory

| Location | Purpose | Written by |
|----------|---------|-----------|
| `~/.pai/memory/` | Shared knowledge, domain context | Both tools |
| `~/.claude/projects/*/memory/` | Per-project auto-memory | Claude Code |

---

## Status Check

```bash
# What skills are installed?
ls ~/.pai/skills/

# What's in pai-personal vs PAI?
ls ~/Developer/pai-personal/skills/
ls ~/Developer/PAI/skills/

# ~/.env entries
grep -v "PASSWORD\|KEY\|SECRET" ~/.env
```

---

## Related Skills

- `/skill-creator` — guided skill creation
- `/skill-forge` — quality audit + cross-repo publishing
- `/skill-sync` — sync status + incremental installs
