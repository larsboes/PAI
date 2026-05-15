# HomeInfra — Installation
See SKILL.md for configuration and prerequisites.

## Configuration (`~/.env`)

```env
# Synology NAS
SYNOLOGY_HOST=your-nas.local
SYNOLOGY_USER=your-username
SYNOLOGY_MOUNT=~/Synology
# SYNOLOGY_PASSWORD=<in ~/.secrets>

# Fritz!Box router
FRITZBOX_HOST=fritz.box
FRITZBOX_USER=admin
# FRITZBOX_PASSWORD=<in ~/.secrets>

# WhatsApp bridge
WHATSAPP_BRIDGE_PORT=3210
WHATSAPP_BRIDGE_DIR=~/.pai/skills/whatsapp

# Apartment Scout
APARTMENT_SCOUT_DIR=~/Developer/apartment-scout
```
