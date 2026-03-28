---
name: Infrastructure
pack-id: larsboes-infrastructure-v1.0.0
version: 1.0.0
author: larsboes
description: Home infrastructure management — Fritz!Box router and Synology NAS via pure Python CLIs
type: skill
purpose-type: [infrastructure, networking, nas, router]
platform: claude-code
dependencies: []
keywords: [fritz, fritzbox, synology, nas, smb, router, wlan, network]
---

# Infrastructure

> Home infrastructure skills — manage Fritz!Box routers and Synology NAS devices from the terminal via pure Python CLIs (no dependencies).

---

## Skills

| Skill | What It Does |
|-------|-------------|
| **fritz** | Fritz!Box router: overview, WLAN, devices, energy, raw data.lua API access |
| **synology** | Synology NAS: SMB mounting, share listing, network diagnostics |

---

## Setup

Both skills require credentials in `~/.env`:

```bash
# Fritz!Box
FRITZBOX_HOST=<your-router-ip>
FRITZBOX_USER=<your-username>
FRITZBOX_PASSWORD=<your-password>

# Synology
SYNOLOGY_HOST=<your-nas-ip>
SYNOLOGY_USER=<your-username>
SYNOLOGY_PASSWORD=<your-password>
```
