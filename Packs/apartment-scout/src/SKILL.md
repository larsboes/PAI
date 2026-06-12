---
name: apartment-scout
description: "Automated apartment hunting — run scans, check results, pause/resume cron. Searches listing platforms with configurable budget, district, and transit filters."
---

# Apartment Scout

Monitors apartment listings on a cron schedule. New listings that pass price + transit filters trigger a notification.

## Project Location

```
${APARTMENT_SCOUT_DIR}
```

## Search Configuration

Configured in `${APARTMENT_SCOUT_DIR}/config.ts`. Supports multiple parallel searches:

| Search Type | Platforms | Config Keys |
|-------------|-----------|-------------|
| Apartment | Immoscout24 + Kleinanzeigen | `maxWarmMiete`, `districts` |
| WG slot | WG-Gesucht | `maxWarmMieteWG`, `wgCity` |

Transit filters: configurable max commute times to target stations in `config.ts`.

## Commands

### Run a scan now
```bash
cd ${APARTMENT_SCOUT_DIR} && bun run src/main.ts
```

### Pause cron (stop auto-runs)
```bash
touch ~/.apartment-scout-paused
```

### Resume cron
```bash
rm -f ~/.apartment-scout-paused
```

### Check if paused
```bash
ls ~/.apartment-scout-paused 2>/dev/null && echo "PAUSED" || echo "RUNNING"
```

### View recent finds (SQLite)
```bash
cd ${APARTMENT_SCOUT_DIR} && bun -e "
import { recentFinds } from './src/db.ts'
const finds = recentFinds(10)
finds.forEach(f => console.log(\`[\${f.type}] \${f.price} | \${f.title?.slice(0,50)} | \${f.added.slice(0,10)}\n  \${f.url}\n\`))
"
```

### View live log
```bash
tail -f ${APARTMENT_SCOUT_DIR}/logs/scout.log
```

### Check cron status
```bash
crontab -l | grep apartment
```

### Edit config (price limits, districts, transit thresholds)
```
${APARTMENT_SCOUT_DIR}/config.ts
```

## Setup (first time)

1. Get a free Gemini API key at https://aistudio.google.com/apikey
2. Set `GEMINI_API_KEY` in `${APARTMENT_SCOUT_DIR}/.env`
3. Run a test scan: `cd ${APARTMENT_SCOUT_DIR} && bun run src/main.ts`
4. Install cron — runs every 30 minutes automatically

## When Claude uses this skill

- User asks "check my apartment search" → run `recentFinds()` and show results
- User asks "pause the scout" → `touch ~/.apartment-scout-paused`
- User asks "resume the scout" → `rm ~/.apartment-scout-paused`
- User asks "run a scan now" → execute main.ts
- User asks "how many listings found?" → query the SQLite DB
- User wants to change budget → edit `config.ts` budget values

## Configuration

Set in your `.env`:

```bash
APARTMENT_SCOUT_DIR=~/Developer/apartment-scout
```
