---
name: cmux
description: Spawn named Claude sub-agents in split panes, orchestrate parallel agents from one workspace, open browser panes, send/read terminal I/O, and track agent status in the sidebar. USE WHEN opening agent splits, spawning a debugger/researcher/writer agent, parallel Claude sessions, browser automation, or any terminal multiplexer operation.
# @sync: public
---

# cmux Terminal Multiplexer

Orchestrate named Claude agents as splits in the current workspace. Includes browser automation, terminal I/O, and sidebar status tracking.

## When to Use

- **Multi-agent orchestration:** Spawn named Claude agents in splits, coordinate from one workspace
- **Terminal control:** Send commands, keystrokes, read screen content
- **Browser automation:** Open URLs, screenshot, interact with page elements, verify UI
- **Visual verification:** Screenshot → Read tool loop for confirming web output
- **Status tracking:** Sidebar status, progress bars, notifications, logging
- **Multi-pane coordination:** Splits, surfaces, cross-pane orchestration

## Core Concepts

**References:** Most commands accept refs like `workspace:1`, `pane:2`, `surface:3`. Use `cmux tree` to see the hierarchy. Pass `--id-format both` to see UUIDs alongside refs.

**Environment:** Inside cmux terminals, `CMUX_WORKSPACE_ID`, `CMUX_SURFACE_ID`, `CMUX_PANE_ID` are auto-set. Commands default to these if no explicit target is given. This means `cmux new-split` with no flags always splits the current workspace.

**Surfaces:** A surface is a tab within a pane. Surfaces can be `terminal` or `browser` type. Browser commands require targeting the correct browser surface.

**Cross-workspace targeting:** Use `--workspace <ref>` not `--surface <ref>` when targeting panes in other workspaces. `--surface` only works reliably within the same workspace.

## Multi-Agent Orchestration

Spawn named interactive Claude agents as splits in the current workspace. Both the orchestrator (AI) and the user can interact with any pane freely — they are regular terminals.

### Spawn a Named Agent

```bash
# Split right — returns the new surface ref
AGENT=$(cmux new-split right | awk '{print $2}')

# Name it in the tab bar
cmux rename-tab --surface $AGENT "🐛 Debugger"

# Launch an interactive Claude session in it
# --dangerously-skip-permissions: REQUIRED for orchestration — without it agents
#   prompt for every tool use, blocking automated workflows.
# --bare: add this to strip PAI/CLAUDE.md overhead for lean sub-agents
cmux send --surface $AGENT "claude --name 'Debugger' --append-system-prompt 'You are a dedicated debugger. Root-cause first, fix second.' --dangerously-skip-permissions"
cmux send-key --surface $AGENT Enter

# IMPORTANT: Claude shows a trust dialog on first boot — confirm it
sleep 6 && cmux send-key --surface $AGENT Enter

# Track it in the sidebar
cmux set-status "debugger" "ready" --icon ladybug.fill --color "#a855f7"
```

The user can click into the pane and type at any time — no lock-out. When booting multiple agents, confirm all trust dialogs after the `sleep`:

```bash
sleep 6
cmux send-key --surface $TOP Enter
cmux send-key --surface $MID Enter
cmux send-key --surface $BOT Enter
```

### Send Tasks / Read Responses

```bash
# Orchestrator sends a task
cmux send --surface $AGENT "Debug this: TypeError: Cannot read property 'map' of undefined at line 42"
cmux send-key --surface $AGENT Enter

# Wait for response — simple tasks ~15s, complex tasks 30-60s
sleep 15

# ALWAYS use --scrollback — visible area is tiny in unfocused panes
cmux read-screen --surface $AGENT --scrollback --lines 40

# Extract the actual response — raw output includes status bar noise
# PAI agents: capture from Jarvis line to the next separator (multi-line safe)
cmux read-screen --surface $AGENT --scrollback --lines 40 | awk '/🗣️ Jarvis:/{found=1} found && /^─{10}/{exit} found{print}'

# Non-PAI / bare agents: grab lines between last ⏺ response block and the ❯ prompt
cmux read-screen --surface $AGENT --scrollback --lines 40 | awk '/^⏺/{found=1; buf=""} found{buf=buf"\n"$0} /^❯/{if(found) print buf; found=0}'
```

### Layout Patterns

All splits happen in the current workspace. `new-split right` puts the agent beside you. `new-split down --surface <ref>` stacks below an existing split.

```bash
# Right column — single agent
AGENT=$(cmux new-split right | awk '{print $2}')

# Right column — top / middle / bottom (3 agents)
TOP=$(cmux new-split right | awk '{print $2}')
MID=$(cmux new-split down --surface $TOP | awk '{print $2}')
BOT=$(cmux new-split down --surface $MID | awk '{print $2}')
cmux rename-tab --surface $TOP "🐛 Debugger"
cmux rename-tab --surface $MID "🔬 Researcher"
cmux rename-tab --surface $BOT "✍️ Writer"

# Left column — agent on left, orchestrator stays right
AGENT=$(cmux new-split left | awk '{print $2}')
```

### Multi-Agent Sidebar Dashboard

```bash
cmux set-status "debugger"   "working..." --icon ladybug.fill      --color "#f59e0b"
cmux set-status "researcher" "idle"       --icon magnifyingglass   --color "#6b7280"
cmux set-status "writer"     "ready"      --icon pencil.fill       --color "#22c55e"
cmux set-progress 0.33 --label "1/3 agents complete"

# Update on completion
cmux set-status "debugger" "done" --icon checkmark.circle.fill --color "#22c55e"
cmux set-progress 0.66 --label "2/3 agents complete"
cmux log --source orchestrator "Debugger finished root-cause analysis"
```

### Claude Session Lifecycle in Sidebar

Wire `cmux claude-hook` into Claude Code's hooks system to show a live "Running" indicator per pane:

```bash
# session-start → blue bolt appears in sidebar
echo '{"session_id":"abc"}' | cmux claude-hook session-start --surface $AGENT

# stop → indicator clears
echo '{}' | cmux claude-hook stop --surface $AGENT
```

Configure automatically via settings.json hooks so every Claude session in every pane signals its state.

### Fire-and-Forget (Non-Interactive)

For one-shot tasks where you don't need back-and-forth, use `-p` with file redirect. More reliable than parsing `read-screen`.

```bash
AGENT=$(cmux new-split right | awk '{print $2}')
cmux rename-tab --surface $AGENT "⚡ Task"

# Run task, write output to file
cmux send --surface $AGENT "claude -p 'summarize this error: segfault at 0x0' --model haiku > /tmp/agent-out.txt 2>&1; echo __DONE__"
cmux send-key --surface $AGENT Enter

# Poll until done
while ! cmux read-screen --surface $AGENT --scrollback 2>/dev/null | grep -q '__DONE__'; do sleep 3; done
cat /tmp/agent-out.txt
```

### Signal-Based Coordination (cleaner than sleep polling)

Instead of guessing with `sleep`, have the agent signal when it's done and the orchestrator waits on that signal.

```bash
# In the agent pane — after the task, signal completion
cmux send --surface $AGENT "claude -p 'fix the bug' --model haiku && cmux wait-for -S 'debugger-done'"
cmux send-key --surface $AGENT Enter

# Orchestrator waits — blocks until signal arrives (or timeout)
cmux wait-for "debugger-done" --timeout 120
echo "Debugger finished — collecting result"
cmux read-screen --surface $AGENT --scrollback --lines 40 | awk '/🗣️ Jarvis:/{found=1} found && /^─{10}/{exit} found{print}'
```

For multiple agents, use distinct signal names per agent:

```bash
cmux wait-for "agent-top-done" --timeout 120 &
cmux wait-for "agent-mid-done" --timeout 120 &
cmux wait-for "agent-bot-done" --timeout 120 &
wait  # waits for all 3 shell background jobs
```

### Stalled Agent Recovery

```bash
# Check if a pane is healthy
cmux surface-health 2>&1

# Restart a hung agent in-place (keeps the split, relaunches the process)
cmux respawn-pane --surface $AGENT --command "claude --name 'Debugger' --dangerously-skip-permissions"
sleep 6 && cmux send-key --surface $AGENT Enter  # confirm trust dialog again

# Update sidebar
cmux set-status "debugger" "restarted" --icon arrow.clockwise --color "#f59e0b"
```

### Close Agents

```bash
# Clean: send /exit first, then close the pane
cmux send --surface $AGENT "/exit"
cmux send-key --surface $AGENT Enter
sleep 1
cmux close-surface --surface $AGENT
cmux clear-status "debugger"

# Force close (if agent is hung or you don't need clean shutdown)
cmux close-surface --surface $AGENT
```

## Workspace & Pane Management

```bash
# Inspect
cmux tree                              # Full workspace/pane/surface hierarchy
cmux tree --all                        # All windows
cmux list-workspaces                   # List workspaces
cmux list-panes                        # List panes in current workspace
cmux list-pane-surfaces                # List surfaces (tabs)
cmux identify                          # Show current workspace/surface/pane context
cmux current-workspace                 # Current workspace ref

# Create
cmux new-workspace --cwd ~/project     # New workspace in directory
cmux new-workspace --command "npm dev"  # New workspace with startup command
cmux new-split right                   # Split current pane right
cmux new-split down                    # Split current pane down
cmux new-pane --type terminal          # New terminal pane
cmux new-pane --type browser --url <url>  # New browser pane with URL

# Navigate
cmux select-workspace --workspace workspace:2  # Switch workspace
cmux focus-pane --pane pane:3                  # Focus pane
cmux next-window                               # Cycle windows
cmux find-window --select "query"              # Find and switch to window by content

# Organize
cmux rename-workspace "My Project"     # Rename current workspace
cmux move-surface --surface surface:3 --pane pane:2  # Move tab to different pane
cmux reorder-surface --surface surface:3 --index 0   # Reorder tabs
cmux swap-pane --pane pane:1 --target-pane pane:2    # Swap pane positions
cmux resize-pane --pane pane:1 -R --amount 20        # Resize pane right by 20

# Close
cmux close-surface --surface surface:3  # Close a surface (tab)
cmux close-workspace --workspace workspace:2  # Close workspace
```

## Terminal Interaction

```bash
# Send commands
cmux send "git status"                 # Send text to current surface
cmux send --surface surface:3 "ls"     # Send to specific surface
cmux send-key Enter                    # Send Enter key
cmux send-key C-c                      # Send Ctrl+C
cmux send-key Tab                      # Send Tab

# Read output
cmux read-screen                       # Read visible screen content
cmux read-screen --lines 100           # Read last 100 lines
cmux read-screen --scrollback          # Include scrollback buffer
cmux capture-pane --scrollback         # Capture full pane with scrollback (tmux compat)

# Clipboard
cmux set-buffer "text to copy"         # Set clipboard buffer
cmux paste-buffer                      # Paste buffer to current surface
cmux list-buffers                      # List clipboard buffers

# Other
cmux clear-history                     # Clear scrollback
cmux respawn-pane                      # Restart pane process
cmux respawn-pane --command "new cmd"  # Restart with new command
```

## Browser Automation

The browser is cmux's built-in Chromium instance. No external dependencies needed.

### Critical Pattern: Surface Targeting

When you open a browser, capture the returned surface ID. All subsequent browser commands must target that surface.

```bash
# Open browser — CAPTURE THE SURFACE ID from output
cmux browser open "https://example.com"
# Returns: OK surface=surface:11 pane=pane:11 placement=split
#                ^^^^^^^^^^^^ use this for all subsequent commands

# All browser commands use --surface BEFORE the subcommand
cmux browser --surface surface:11 screenshot
cmux browser --surface surface:11 navigate "https://other.com"
cmux browser --surface surface:11 click "button.submit"

# Clean up when done
cmux close-surface --surface surface:11
```

### Navigation

```bash
cmux browser open [url]                              # Open in new split (returns surface ID)
cmux browser open-split [url]                        # Explicit split open
cmux browser --surface <ref> navigate <url>          # Navigate existing browser
cmux browser --surface <ref> goto <url>              # Alias for navigate
cmux browser --surface <ref> back                    # Go back
cmux browser --surface <ref> forward                 # Go forward
cmux browser --surface <ref> reload                  # Reload page
```

### Screenshots & Visual Verification

```bash
# Screenshot to auto-generated temp path
cmux browser --surface <ref> screenshot
# Returns: OK file:///var/folders/.../cmux-browser-screenshots/surface-XXX.png

# Screenshot to specific path
cmux browser --surface <ref> screenshot --out /tmp/my-screenshot.png
# Returns: OK /tmp/my-screenshot.png

# Screenshot as JSON (base64)
cmux browser --surface <ref> screenshot --json
```

**The verification loop** — the most common browser pattern:

```bash
# 1. Open page
cmux browser open "http://localhost:3000"
# → surface=surface:5

# 2. Screenshot
cmux browser --surface surface:5 screenshot --out /tmp/verify.png

# 3. View with Read tool to visually verify
# Read /tmp/verify.png  (Claude's multimodal vision)

# 4. Fix issues if needed, re-screenshot, re-verify
# 5. Close when done
cmux close-surface --surface surface:5
```

### Page Inspection

```bash
# Accessibility snapshot — structured page tree with interactive element refs
cmux browser --surface <ref> snapshot
# Returns: - document "Page Title"
#            - heading "Welcome" [level=1]
#            - link "About" [ref=e1]
#            - textbox "Search" [ref=e2]
#            - button "Submit" [ref=e3]

# Interactive mode — only shows actionable elements with refs
cmux browser --surface <ref> snapshot --interactive
# Returns only clickable/fillable elements with [ref=eN] tags

# Compact snapshot
cmux browser --surface <ref> snapshot --compact

# Scoped snapshot
cmux browser --surface <ref> snapshot --selector "nav"

# Get specific data
cmux browser --surface <ref> get url             # Current URL
cmux browser --surface <ref> get title           # Page title
cmux browser --surface <ref> get text "h1"       # Text content of element
cmux browser --surface <ref> get html "h1"       # HTML of element
cmux browser --surface <ref> get value "input"   # Input value
cmux browser --surface <ref> get attr "a" href   # Element attribute
cmux browser --surface <ref> get count "li"      # Count matching elements
cmux browser --surface <ref> get box "button"    # Bounding box
cmux browser --surface <ref> get styles "h1"     # Computed styles

# Check state
cmux browser --surface <ref> is visible "h1"     # Returns 1 (true) or 0
cmux browser --surface <ref> is enabled "button"
cmux browser --surface <ref> is checked "input[type=checkbox]"
```

### Interaction

All interaction commands support `--snapshot-after` to return the page state after the action.

```bash
# Click/interact with elements — by CSS selector OR by ref from snapshot
cmux browser --surface <ref> click "button.submit"
cmux browser --surface <ref> click e3              # Using ref from snapshot
cmux browser --surface <ref> dblclick ".item"
cmux browser --surface <ref> hover ".menu-item"
cmux browser --surface <ref> focus "input"
cmux browser --surface <ref> check "input[type=checkbox]"
cmux browser --surface <ref> uncheck "input[type=checkbox]"
cmux browser --surface <ref> scroll-into-view ".footer"

# Text input
cmux browser --surface <ref> fill "input[name=email]" "user@example.com"
cmux browser --surface <ref> fill "input[name=email]"   # Empty = clear
cmux browser --surface <ref> type ".search" "hello"      # Types character by character
cmux browser --surface <ref> press Enter
cmux browser --surface <ref> press Tab

# Select dropdown
cmux browser --surface <ref> select "select.country" "US"

# Scroll
cmux browser --surface <ref> scroll --dy 500       # Scroll down 500px
cmux browser --surface <ref> scroll --dy -500      # Scroll up
cmux browser --surface <ref> scroll --selector ".panel" --dy 200

# JavaScript execution
cmux browser --surface <ref> eval "document.title"
cmux browser --surface <ref> eval "document.querySelectorAll('.item').length"
cmux browser --surface <ref> eval "document.querySelector('.btn').click()"  # Fallback for tricky selectors

# Inject styles/scripts
cmux browser --surface <ref> addstyle "body { background: red; }"
cmux browser --surface <ref> addscript "console.log('injected')"

# Highlight element (visual debugging)
cmux browser --surface <ref> highlight ".target-element"
```

### Waiting

```bash
cmux browser --surface <ref> wait --selector ".loaded"           # Wait for element
cmux browser --surface <ref> wait --text "Success"               # Wait for text
cmux browser --surface <ref> wait --url-contains "/dashboard"    # Wait for navigation
cmux browser --surface <ref> wait --load-state complete          # Wait for page load
cmux browser --surface <ref> wait --function "() => window.ready === true"  # Custom JS
cmux browser --surface <ref> wait --timeout-ms 10000             # Custom timeout
```

### Tabs, Dialogs, Downloads, Storage

```bash
# Tabs
cmux browser --surface <ref> tab list
cmux browser --surface <ref> tab new "https://url.com"
cmux browser --surface <ref> tab switch 1
cmux browser --surface <ref> tab close

# Dialogs (alert/confirm/prompt)
cmux browser --surface <ref> dialog accept
cmux browser --surface <ref> dialog dismiss
cmux browser --surface <ref> dialog accept "input text"

# Downloads
cmux browser --surface <ref> download wait --path /tmp/file.pdf

# Cookies
cmux browser --surface <ref> cookies get
cmux browser --surface <ref> cookies set '{"name":"a","value":"b","domain":".example.com"}'
cmux browser --surface <ref> cookies clear

# Storage
cmux browser --surface <ref> storage local get "key"
cmux browser --surface <ref> storage local set "key" "value"
cmux browser --surface <ref> storage session clear

# Console & Errors
cmux browser --surface <ref> console list    # Browser console output
cmux browser --surface <ref> console clear
cmux browser --surface <ref> errors list     # JavaScript errors
cmux browser --surface <ref> errors clear

# State save/restore (cookies + localStorage + sessionStorage)
cmux browser --surface <ref> state save /tmp/state.json
cmux browser --surface <ref> state load /tmp/state.json

# Frames
cmux browser --surface <ref> frame "iframe.content"  # Switch to iframe
cmux browser --surface <ref> frame main              # Switch back to main
```

## Sidebar Metadata

```bash
# Status indicators (appear in cmux sidebar)
cmux set-status build "passing" --icon check --color "#22c55e"
cmux set-status deploy "in progress" --icon rocket --color "#f59e0b"
cmux clear-status build
cmux list-status

# Progress bar
cmux set-progress 0.75 --label "Building... 75%"
cmux clear-progress

# Logging (sidebar log panel)
cmux log "Starting deployment"
cmux log --level error --source deploy "Failed to connect"
cmux list-log --limit 20
cmux clear-log

# Notifications
cmux notify --title "Build Complete" --subtitle "my-project" --body "No errors"
cmux list-notifications
cmux clear-notifications
```

## Markdown Viewer

```bash
cmux markdown README.md                # Open formatted markdown viewer with live reload
cmux markdown open docs/ARCHITECTURE.md
```

Opens in a side panel with proper rendering and auto-reloads on file changes.

## Practical Patterns

### Web Dev: Code → Verify Loop

```bash
# Initial setup
cmux browser open "http://localhost:3000"   # → surface:5

# After each code change:
cmux browser --surface surface:5 reload
cmux browser --surface surface:5 screenshot --out /tmp/check.png
# Read /tmp/check.png to verify

# Done
cmux close-surface --surface surface:5
```

### Scraping: Snapshot-Based Interaction

Use `snapshot --interactive` to get refs, then interact by ref — more reliable than CSS selectors for dynamic pages:

```bash
cmux browser open "https://target.com"     # → surface:7
cmux browser --surface surface:7 snapshot --interactive
# → - textbox "Search" [ref=e4]
# → - button "Go" [ref=e5]

cmux browser --surface surface:7 fill e4 "query"
cmux browser --surface surface:7 click e5 --snapshot-after
# Returns new snapshot with results

cmux browser --surface surface:7 get text ".results"
cmux close-surface --surface surface:7
```

### Multi-Browser Parallel

```bash
# Open 3 browsers simultaneously
cmux browser open "http://localhost:3000/page-a"  # → surface:10
cmux browser open "http://localhost:3000/page-b"  # → surface:11
cmux browser open "http://localhost:3000/page-c"  # → surface:12

# Screenshot all three
cmux browser --surface surface:10 screenshot --out /tmp/a.png
cmux browser --surface surface:11 screenshot --out /tmp/b.png
cmux browser --surface surface:12 screenshot --out /tmp/c.png

# Clean up
cmux close-surface --surface surface:10
cmux close-surface --surface surface:11
cmux close-surface --surface surface:12
```

### Form Fill + Submit

```bash
cmux browser open "https://app.com/signup"           # → surface:8
cmux browser --surface surface:8 wait --selector "form"
cmux browser --surface surface:8 fill "input[name=name]" "Lars Boes"
cmux browser --surface surface:8 fill "input[name=email]" "lars@example.com"
cmux browser --surface surface:8 select "select[name=country]" "CH"
cmux browser --surface surface:8 click "button[type=submit]" --snapshot-after
cmux browser --surface surface:8 wait --url-contains "/welcome"
cmux browser --surface surface:8 screenshot --out /tmp/success.png
cmux close-surface --surface surface:8
```

## Full CLI Reference

See `References/cli-reference.md` for the complete command table (all commands, browser subcommands, environment variables). Or run `cmux --help`.

## Socket Configuration

Default: `/tmp/cmux.sock`. Override with `CMUX_SOCKET_PATH`. Authenticate with `CMUX_SOCKET_PASSWORD` or `--password`.
