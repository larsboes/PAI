---
name: synology
description: Synology NAS management — SMB mounting, share listing, and network diagnostics.
---

# Synology NAS CLI

Manage your Synology NAS from the terminal.

## Setup

- Credentials in `~/.env` (`SYNOLOGY_HOST`, `SYNOLOGY_USER`, `SYNOLOGY_PASSWORD`)
- Script: `${CLAUDE_SKILL_DIR}/scripts/synologycli` (pure Python 3, no deps)
- Access: SMB protocol to local network NAS ($SYNOLOGY_HOST)
- Mount point: `${SYNOLOGY_MOUNT}/` (default: `~/Synology/`, created automatically)

## Commands

```bash
# Mount home share locally
python3 ${CLAUDE_SKILL_DIR}/scripts/synologycli mount home

# List available shares on NAS
python3 ${CLAUDE_SKILL_DIR}/scripts/synologycli shares

# Check connection status
python3 ${CLAUDE_SKILL_DIR}/scripts/synologycli status

# Unmount share
python3 ${CLAUDE_SKILL_DIR}/scripts/synologycli umount home

# Get mounted shares
python3 ${CLAUDE_SKILL_DIR}/scripts/synologycli mounted
```

## Common Shares

| Share | Description |
|-------|-------------|
| `home` | User home directory |
| `backup` | Backup destination |
| `public` | Public share |

## Usage Examples

Mount home share for backup:
```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/synologycli mount home
# Then in Synology Drive Client, set backup destination to:
# ${SYNOLOGY_MOUNT}/Backup/
```

Check if mounted:
```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/synologycli mounted
```

Unmount when done:
```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/synologycli umount home
```

## Notes

- Mounts to `${SYNOLOGY_MOUNT}/<share>` automatically
- Requires SMB/CIFS support on macOS/Linux
- Shares persist until manual unmount or system restart
- Credentials auto-read from `~/.env`
