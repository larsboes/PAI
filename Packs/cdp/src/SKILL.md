---
name: cdp
description: Chrome DevTools Protocol — launch Chrome with debugging, list tabs, navigate, evaluate JS, capture screenshots, intercept network, and send raw CDP commands via a Python CLI.
---

# Chrome DevTools Protocol (CDP)

Direct Chrome/Chromium control via CDP WebSocket API. Lower-level than Playwright — use when you need raw protocol access, custom event streams, or Chrome internals not exposed by Playwright.

## Setup

**Dependency:** `websockets` Python package for WebSocket commands.
```bash
pip install websockets
# or: uv add websockets
```

**Launch Chrome with remote debugging:**
```bash
# macOS — isolated profile (safe, leaves your main Chrome untouched)
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug &
```

Chrome then exposes:
- `http://localhost:9222/json` — list open tabs
- `http://localhost:9222/json/version` — browser info + WebSocket debugger URL
- `ws://localhost:9222/devtools/page/<id>` — per-tab WebSocket

## Commands

```bash
# List open tabs
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli list

# Browser version info
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli version

# Navigate tab 0 to a URL
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli navigate "https://example.com"
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli navigate "https://example.com" --tab 1

# Evaluate JavaScript in page context
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli eval "document.title"
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli eval "window.location.href"
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli eval "JSON.stringify(performance.timing)"

# Capture screenshot (saves to ./screenshot.png by default)
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli screenshot
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli screenshot --out /tmp/page.png

# Get all cookies for current page
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli eval "document.cookie"

# Send raw CDP command
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli raw "Page.reload" '{}'
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli raw "Network.clearBrowserCache" '{}'
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli raw "Runtime.evaluate" '{"expression":"navigator.userAgent"}'
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli raw "DOM.getDocument" '{}'
```

## Key CDP Domains

| Domain | Purpose | Common Methods |
|--------|---------|----------------|
| `Page` | Navigation, lifecycle, screenshots | `navigate`, `reload`, `captureScreenshot`, `printToPDF` |
| `Runtime` | JS execution, exceptions | `evaluate`, `callFunctionOn`, `getProperties` |
| `DOM` | Query/modify document | `getDocument`, `querySelector`, `setAttributeValue` |
| `Network` | Request interception, cookies | `enable`, `getCookies`, `clearBrowserCache`, `setExtraHTTPHeaders` |
| `Target` | Manage tabs/windows | `getTargets`, `createTarget`, `closeTarget`, `attachToTarget` |
| `Input` | Mouse/keyboard simulation | `dispatchMouseEvent`, `dispatchKeyEvent` |
| `Fetch` | Intercept + modify requests | `enable`, `fulfillRequest`, `failRequest`, `continueRequest` |
| `Emulation` | Device emulation | `setDeviceMetricsOverride`, `setGeolocationOverride` |
| `Performance` | Metrics | `getMetrics`, `enable` |

## Common Patterns

### Intercept network requests (requires event loop — use raw for one-shots)
```python
# Enable network domain first, then listen for events
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli raw "Network.enable" '{}'
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli raw "Network.setRequestInterception" '{"patterns":[{"urlPattern":"*"}]}'
```

### Get page metrics
```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli raw "Performance.getMetrics" '{}'
```

### Print to PDF
```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/cdpcli raw "Page.printToPDF" '{"format":"A4","printBackground":true}'
```

## Notes

- CDP port defaults to 9222; set `CDP_PORT` env var to override
- Tab index 0 = first non-extension page tab
- `screenshot` returns base64 PNG — script decodes and saves automatically
- For event streaming (Network.requestIntercepted etc.) you need a persistent WebSocket loop — use the Browser skill (Playwright) for complex interception workflows
- Chrome must be launched with `--remote-debugging-port` — you cannot attach to a running Chrome without this flag
