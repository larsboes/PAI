---
name: fritz
description: Fritz!Box router management — overview, WLAN, devices, energy, and raw API access via the Fritz!Box data.lua API.
---

# Fritz!Box CLI

Manage your Fritz!Box router from the terminal.

## Setup

- Credentials in `~/.env` (`FRITZBOX_HOST`, `FRITZBOX_USER`, `FRITZBOX_PASSWORD`)
- Script: `${CLAUDE_SKILL_DIR}/scripts/fritzcli` (pure Python 3, no deps)
- Auth: PBKDF2 challenge-response via `login_sid.lua` (Fritz!OS 7.24+)
- Access: HTTPS to `$FRITZBOX_HOST` (local LAN only, `fritz.box` resolves externally)

## Commands

```bash
# Overview (model, OS version, WAN, WLAN status)
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli overview

# WLAN settings (SSIDs, bands, active/inactive)
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli wlan
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli wlan --json

# Connected devices
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli devices
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli devices --all  # include inactive

# Energy consumption
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli energy
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli energy --json

# Raw API call (any data.lua page)
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli raw <page> [key=value ...]
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli raw wSet
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli raw net
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli raw dnsSet

# List known API pages
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli pages
```

## Known API Pages

| Page | Description |
|------|-------------|
| `overview` | Default overview (no page param) |
| `net` | Full network (WAN, LAN, WLAN, DSL, VPN, DECT) |
| `wSet` | WLAN settings (SSIDs, channels, bands) |
| `netDev` | Network devices |
| `energy` | Power consumption |
| `dslOv` | DSL overview |
| `wKey` | WLAN keys |
| `wGuest` | Guest WLAN |
| `chan` | WLAN channels |
| `dnsSet` | DNS settings |
| `portFwd` | Port forwarding |

## Modifying Settings

The Fritz!Box `data.lua` API supports writes via POST with `apply` parameter. To change settings:

1. First GET the current page data via `raw` command
2. Identify the parameter names from the JSON response
3. POST back with `apply=` and modified values

Example pattern for raw apply calls:
```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/fritzcli raw <page> apply= key1=value1 key2=value2
```

## Notes

- SID expires after ~20 min of inactivity; script re-authenticates each call
- SSL verification disabled (self-signed cert on local router)
- Fritz!OS 8.20 confirmed working
- WAN connection details depend on your ISP setup
