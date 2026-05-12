---
name: Obsidian
pack-id: pai-obsidian-v1.0.0
version: 1.0.0
author: larsboes
description: Full Obsidian vault integration — search, canvas generation, base management, bulk property ops, structure validation, and vault diagnostics.
type: skill
platform: pi,claude-code
source: PAI Fork (larsboes)
---

# Obsidian

Full Obsidian vault integration — search, canvas generation, base management, bulk property ops, structure validation, and vault diagnostics.

## Installation

Point your AI at this directory:

```
"Install the Obsidian pack from PAI/Packs/Obsidian/"
```

Your AI reads `INSTALL.md` and walks through the wizard: system check, dependency verification, installation, verification.

## What's Included

```
  SKILL.md
  INTEGRATIONS.md
  references/
  scripts/
```

The skill source is `SKILL.md`. See `INSTALL.md` for setup and `VERIFY.md` to confirm everything works.

## Configuration

Set these in `~/.env`:

```env
OBSIDIAN_VAULT_PATH=/path/to/your/vault
OBSIDIAN_BIN=/path/to/obsidian/binary
```

## Source

Original skill created for PAI Fork — not in upstream danielmiessler/Personal_AI_Infrastructure.

## License

MIT — see [PAI LICENSE](../../LICENSE).
