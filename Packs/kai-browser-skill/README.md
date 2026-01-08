# Browser Skill v1.2.0

**Debug-first browser automation with always-on visibility.**

## What's New in v1.2.0

### Debug-First Architecture
- Console logs and network requests captured **by default**
- Diagnostic output with every navigation
- No more adding logging after the fact

### Session Auto-Start
- Session launches automatically on first command
- No explicit `session start` needed
- 30-minute idle timeout for cleanup

### New Commands
```bash
bun run Browse.ts <url>        # Navigate with full diagnostics (PRIMARY)
bun run Browse.ts errors       # Show console errors
bun run Browse.ts warnings     # Show console warnings
bun run Browse.ts console      # All console output
bun run Browse.ts network      # Network activity
bun run Browse.ts failed       # Failed requests (4xx, 5xx)
bun run Browse.ts status       # Session info
bun run Browse.ts restart      # Fresh session
bun run Browse.ts stop         # Stop session
```

---

## What It Does

The Browser skill provides Playwright automation with 99% token savings:

- **Navigate** to URLs with automatic diagnostics
- **Screenshot** pages with issue detection
- **Interact** with forms, buttons, dropdowns
- **Verify** page content and elements
- **Monitor** console logs and network requests

## Why Debug-First?

Traditional approach: Run test, it fails, add logging, run again.

Debug-first approach: **Logging already exists.** When something breaks, the data is there.

Every `bun run Browse.ts <url>` command captures:
- Screenshot
- Console errors/warnings
- Failed network requests
- Network summary
- Load status

## Quick Start

```bash
# Navigate and get full diagnostics
bun run $PAI_DIR/skills/Browser/Tools/Browse.ts https://example.com

# Check for errors
bun run $PAI_DIR/skills/Browser/Tools/Browse.ts errors

# Take screenshot of current page
bun run $PAI_DIR/skills/Browser/Tools/Browse.ts screenshot /tmp/shot.png
```

## Token Savings

| Approach | Tokens | When Loaded |
|----------|--------|-------------|
| Playwright MCP | ~13,700 | At startup (always) |
| Browser Skill | ~0 | Per operation (on demand) |

**Result:** 99%+ token savings

## API Reference

### CLI Commands

| Command | Description |
|---------|-------------|
| `<url>` | Navigate with full diagnostics |
| `errors` | Console errors only |
| `warnings` | Console warnings only |
| `console` | All console output |
| `network` | Network activity |
| `failed` | Failed requests |
| `screenshot [path]` | Screenshot current page |
| `navigate <url>` | Navigate without diagnostics |
| `click <selector>` | Click element |
| `fill <sel> <val>` | Fill input |
| `type <sel> <text>` | Type with delay |
| `eval "<js>"` | Execute JavaScript |
| `open <url>` | Open in default browser |
| `status` | Session info |
| `restart` | Fresh session |
| `stop` | Stop session |

### TypeScript API

```typescript
import { PlaywrightBrowser } from '$PAI_DIR/skills/Browser/src/index.ts'

const browser = new PlaywrightBrowser()
await browser.launch()
await browser.navigate('https://example.com')
await browser.screenshot({ path: 'shot.png' })
await browser.close()
```

**Navigation:** `launch()`, `navigate()`, `goBack()`, `goForward()`, `reload()`, `close()`

**Capture:** `screenshot()`, `getVisibleText()`, `getVisibleHtml()`, `savePdf()`

**Interaction:** `click()`, `fill()`, `type()`, `select()`, `pressKey()`

**Monitoring:** `getConsoleLogs()`, `getNetworkLogs()`, `getNetworkStats()`

**Waiting:** `waitForSelector()`, `waitForNavigation()`, `waitForNetworkIdle()`

## Installation

See `INSTALL.md` for step-by-step instructions.

## Verification

See `VERIFY.md` for verification steps (15 checks for v1.2.0).

---

## Changelog

### v1.2.0 (January 2026)
- **NEW:** Debug-first architecture with always-on event capture
- **NEW:** Session auto-start (no explicit start needed)
- **NEW:** 30-minute idle timeout for auto-cleanup
- **NEW:** Diagnostic commands (errors, warnings, console, network, failed)
- **NEW:** BrowserSession.ts persistent server
- **NEW:** Rich formatted diagnostic output
- **CHANGED:** Primary command is now `<url>` for navigate + diagnostics
- **CHANGED:** CLI expanded from 3 to 15+ commands

### v1.1.0
- CLI-first redesign
- Added decision tree routing
- Updated VERIFY phase integration

### v1.0.0
- Initial release
- Code-first Playwright wrapper
- Basic CLI (open, screenshot, verify)
