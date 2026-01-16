---
name: pai-browser-skill-install
version: 2.3.0
---

# Installation Guide

## Prerequisites

### Required Packs (Install First)

> **STOP:** Before installing this pack, ensure you have installed:
> 1. **pai-hook-system** - Event-driven automation foundation
> 2. **pai-core-install** - Core identity, skills, and memory system
>
> These are required for this pack to function properly.

### System Requirements

1. **Bun Runtime** - Required for running TypeScript tools
   ```bash
   # Install Bun if not present
   curl -fsSL https://bun.sh/install | bash
   ```

2. **Playwright** - Browser automation library
   ```bash
   # Playwright will be installed with dependencies
   ```

## Installation Steps

### Step 1: Copy Skill Files

Copy the Browser skill to your skills directory:

```bash
cp -r src/skills/Browser ~/.claude/skills/
```

### Step 2: Install Dependencies

Navigate to the Browser skill and install:

```bash
cd ~/.claude/skills/Browser
bun install
```

This installs Playwright and TypeScript types.

### Step 3: Install Browser Binaries

Playwright needs browser binaries. Install them:

```bash
bunx playwright install chromium
```

Optional - install all browsers:
```bash
bunx playwright install
```

### Step 4: Verify Installation

Test the installation:

```bash
# Take a test screenshot
bun run ~/.claude/skills/Browser/examples/screenshot.ts https://example.com

# Should output:
# === Playwright Screenshot ===
# 1. Launching browser...
# 2. Navigating to https://example.com...
# 3. Taking screenshot...
# Screenshot saved: screenshot.png
```

## Directory Structure After Installation

```
~/.claude/skills/Browser/
  SKILL.md           # Skill definition
  README.md          # Documentation
  index.ts           # Main library
  package.json       # Dependencies
  tsconfig.json      # TypeScript config
  node_modules/      # Installed after bun install
  Tools/
    Browse.ts        # CLI tool
    BrowserSession.ts # Session server
  Workflows/
    Extract.md
    Interact.md
    Screenshot.md
    Update.md
    VerifyPage.md
  examples/
    screenshot.ts
    verify-page.ts
    comprehensive-test.ts
```

## Configuration

### Headless Mode (Default)

Browser runs headless by default. To see the browser:

```typescript
await browser.launch({ headless: false })
```

### Custom Viewport

```typescript
await browser.launch({
  viewport: { width: 1920, height: 1080 }
})
```

### Session Settings

Environment variables for BrowserSession.ts:

| Variable | Default | Description |
|----------|---------|-------------|
| `BROWSER_PORT` | 9222 | Server port |
| `BROWSER_HEADLESS` | true | Headless mode |
| `BROWSER_WIDTH` | 1920 | Viewport width |
| `BROWSER_HEIGHT` | 1080 | Viewport height |

## Troubleshooting

### "Browser not launched" Error

```bash
# Solution: Ensure Playwright browsers are installed
bunx playwright install chromium
```

### Permission Errors on macOS

```bash
# Allow Chromium in System Preferences > Privacy & Security
# Or run once with:
xattr -d com.apple.quarantine ~/.cache/ms-playwright/chromium-*/chrome-mac/Chromium.app
```

### Port Already in Use

```bash
# Kill existing session
bun run ~/.claude/skills/Browser/Tools/Browse.ts stop

# Or specify different port
BROWSER_PORT=9223 bun run ~/.claude/skills/Browser/Tools/BrowserSession.ts
```

## Uninstallation

To remove the Browser skill:

```bash
rm -rf ~/.claude/skills/Browser
```
