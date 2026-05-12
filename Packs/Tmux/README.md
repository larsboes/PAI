---
name: Tmux
pack-id: pai-tmux-v1.0.0
version: 1.0.0
author: larsboes
description: Remote control tmux sessions for interactive CLIs (python, gdb, node, etc.) by sending keystrokes and scraping pane output. Includes session presets, save/restore, and JSON capture.
type: skill
platform: pi,claude-code
source: PAI Fork (larsboes)
---

# Tmux

Remote control tmux sessions for interactive CLIs (python, gdb, node, etc.) by sending keystrokes and scraping pane output. Includes session presets, save/restore, and JSON capture.

## Installation

Point your AI at this directory:

```
"Install the Tmux pack from PAI/Packs/Tmux/"
```

Your AI reads `INSTALL.md` and walks through the wizard: system check, dependency verification, installation, verification.

## What's Included

```
  SKILL.md
  scripts/
    python-session.sh
    gdb-session.sh
    node-session.sh
    save-session.sh
    restore-session.sh
    find-sessions.sh
    wait-for-text.sh
    capture-json.sh
```

The skill source is `SKILL.md`. See `INSTALL.md` for setup and `VERIFY.md` to confirm everything works.

## Source

Original skill created for PAI Fork — not in upstream danielmiessler/Personal_AI_Infrastructure.

## License

MIT — see [PAI LICENSE](../../LICENSE).
