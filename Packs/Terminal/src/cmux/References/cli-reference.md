# cmux CLI Reference

> Generated from `cmux --help` on 2026-03-18. Update by re-running `cmux --help`.

## Global Syntax

```
cmux <path>                          Open directory in new workspace
cmux [global-options] <command> [options]
```

**Inputs:** UUIDs, short refs (`window:1`, `workspace:2`, `pane:3`, `surface:4`), or indexes.
**Output:** Defaults to refs. Pass `--id-format uuids` or `--id-format both` for UUIDs.
**Auth:** `--password` flag > `CMUX_SOCKET_PASSWORD` env > saved in Settings.

## All Commands

### System

| Command | Description |
|---------|-------------|
| `version` | Show cmux version |
| `welcome` | Show welcome message |
| `shortcuts` | Show keyboard shortcuts |
| `feedback [--email --body --image]` | Send feedback |
| `ping` | Test socket connection |
| `capabilities` | List cmux capabilities |
| `identify [--workspace] [--surface] [--no-caller]` | Show current context IDs |

### Windows

| Command | Description |
|---------|-------------|
| `list-windows` | List all windows |
| `current-window` | Current window ref |
| `new-window` | Create new window |
| `focus-window --window <id>` | Focus window |
| `close-window --window <id>` | Close window |
| `next-window` / `previous-window` / `last-window` | Cycle windows |
| `rename-window [--workspace] <title>` | Rename window |
| `find-window [--content] [--select] <query>` | Search windows |

### Workspaces

| Command | Description |
|---------|-------------|
| `list-workspaces` | List all workspaces |
| `current-workspace` | Current workspace ref |
| `new-workspace [--cwd] [--command]` | Create workspace |
| `select-workspace --workspace <id\|ref>` | Switch to workspace |
| `close-workspace --workspace <id\|ref>` | Close workspace |
| `rename-workspace [--workspace] <title>` | Rename workspace |
| `move-workspace-to-window --workspace <id\|ref> --window <id\|ref>` | Move workspace between windows |
| `reorder-workspace --workspace <id\|ref> (--index\|--before\|--after)` | Reorder workspace tabs |
| `workspace-action --action <name> [--workspace] [--title]` | Trigger workspace action |

### Panes & Surfaces

| Command | Description |
|---------|-------------|
| `list-panes [--workspace]` | List panes in workspace |
| `list-pane-surfaces [--workspace] [--pane]` | List surfaces (tabs) |
| `list-panels [--workspace]` | List panels |
| `tree [--all] [--workspace]` | Full hierarchy tree |
| `new-split <left\|right\|up\|down> [--workspace] [--surface] [--panel]` | Split pane |
| `new-pane [--type terminal\|browser] [--direction] [--workspace] [--url]` | New pane |
| `new-surface [--type terminal\|browser] [--pane] [--workspace] [--url]` | New surface in pane |
| `focus-pane --pane <id\|ref> [--workspace]` | Focus pane |
| `focus-panel --panel <id\|ref> [--workspace]` | Focus panel |
| `close-surface [--surface] [--workspace]` | Close surface |
| `move-surface --surface <ref> [--pane] [--before\|--after\|--index]` | Move surface |
| `reorder-surface --surface <ref> (--index\|--before\|--after)` | Reorder surface tabs |
| `swap-pane --pane <ref> --target-pane <ref> [--workspace]` | Swap pane positions |
| `resize-pane --pane <ref> [--workspace] (-L\|-R\|-U\|-D) [--amount]` | Resize pane |
| `break-pane [--workspace] [--pane] [--surface] [--no-focus]` | Break surface to own pane |
| `join-pane --target-pane <ref> [--workspace] [--pane] [--surface]` | Join surface into pane |
| `last-pane [--workspace]` | Switch to last pane |
| `drag-surface-to-split --surface <ref> <left\|right\|up\|down>` | Drag surface to split |
| `refresh-surfaces` | Refresh all surfaces |
| `surface-health [--workspace]` | Check surface health |
| `trigger-flash [--workspace] [--surface]` | Flash surface |

### Tab Actions

| Command | Description |
|---------|-------------|
| `tab-action --action <name> [--tab\|--surface] [--workspace] [--title] [--url]` | Tab action |
| `rename-tab [--workspace] [--tab\|--surface] <title>` | Rename tab |

### Terminal Interaction

| Command | Description |
|---------|-------------|
| `send [--workspace] [--surface] <text>` | Send text to terminal |
| `send-key [--workspace] [--surface] <key>` | Send keystroke |
| `send-panel --panel <ref> [--workspace] <text>` | Send to panel |
| `send-key-panel --panel <ref> [--workspace] <key>` | Send key to panel |
| `read-screen [--workspace] [--surface] [--scrollback] [--lines]` | Read screen content |
| `capture-pane [--workspace] [--surface] [--scrollback] [--lines]` | tmux-compat capture |
| `clear-history [--workspace] [--surface]` | Clear scrollback |
| `respawn-pane [--workspace] [--surface] [--command]` | Restart pane |
| `pipe-pane --command <shell> [--workspace] [--surface]` | Pipe output to command |

### Clipboard

| Command | Description |
|---------|-------------|
| `set-buffer [--name] <text>` | Set clipboard buffer |
| `list-buffers` | List buffers |
| `paste-buffer [--name] [--workspace] [--surface]` | Paste buffer |
| `copy-mode` | Enter copy mode |

### Sidebar Metadata

| Command | Description |
|---------|-------------|
| `set-status <key> <value> [--icon] [--color] [--workspace]` | Set status indicator |
| `clear-status <key> [--workspace]` | Clear status |
| `list-status [--workspace]` | List all status |
| `set-progress <0.0-1.0> [--label] [--workspace]` | Set progress bar |
| `clear-progress [--workspace]` | Clear progress |
| `log [--level] [--source] [--workspace] <message>` | Add log entry |
| `clear-log [--workspace]` | Clear log |
| `list-log [--limit] [--workspace]` | List log entries |
| `sidebar-state [--workspace]` | Get sidebar state |

### Notifications

| Command | Description |
|---------|-------------|
| `notify --title <text> [--subtitle] [--body] [--workspace] [--surface]` | Send notification |
| `list-notifications` | List notifications |
| `clear-notifications` | Clear notifications |

### Focus & App Control

| Command | Description |
|---------|-------------|
| `set-app-focus <active\|inactive\|clear>` | Set app focus state |
| `simulate-app-active` | Simulate app active |

### Hooks & Key Bindings

| Command | Description |
|---------|-------------|
| `set-hook [--list] [--unset <event>] \| <event> <command>` | Manage hooks |
| `bind-key` / `unbind-key` | Key bindings |
| `popup` | Popup window |
| `wait-for [-S\|--signal] <name> [--timeout]` | Wait for signal |

### Markdown & Special

| Command | Description |
|---------|-------------|
| `markdown [open] <path>` | Open markdown in formatted viewer with live reload |
| `display-message [-p\|--print] <text>` | Display message |
| `claude-teams [claude-args...]` | Claude teams integration |
| `claude-hook <session-start\|stop\|notification> [--workspace] [--surface]` | Claude hooks |

## Browser Subcommands

Syntax: `cmux browser [--surface <id\|ref\|index>] <subcommand> [args...]`

**The `--surface` flag MUST come before the subcommand.**

### Navigation

| Command | Description |
|---------|-------------|
| `open [url]` | Open browser in new split (returns surface ID) |
| `open-split [url]` | Open browser in new split (explicit) |
| `goto\|navigate <url> [--snapshot-after]` | Navigate to URL |
| `back [--snapshot-after]` | Go back |
| `forward [--snapshot-after]` | Go forward |
| `reload [--snapshot-after]` | Reload page |
| `url\|get-url` | Get current URL |

### Inspection

| Command | Description |
|---------|-------------|
| `snapshot [--interactive\|-i] [--cursor] [--compact] [--max-depth] [--selector]` | Accessibility tree with refs |
| `screenshot [--out <path>] [--json]` | Take screenshot |
| `get url\|title\|text\|html\|value\|attr\|count\|box\|styles [selector] [args]` | Get page data |
| `is visible\|enabled\|checked <selector>` | Check element state |
| `find role\|text\|label\|placeholder\|alt\|title\|testid\|first\|last\|nth ...` | Find elements |
| `identify [--surface]` | Identify browser surface |

### Interaction

All support `--snapshot-after` to return page state after action.

| Command | Description |
|---------|-------------|
| `click <selector\|ref> [--snapshot-after]` | Click element |
| `dblclick <selector> [--snapshot-after]` | Double-click |
| `hover <selector> [--snapshot-after]` | Hover over element |
| `focus <selector> [--snapshot-after]` | Focus element |
| `check <selector> [--snapshot-after]` | Check checkbox |
| `uncheck <selector> [--snapshot-after]` | Uncheck checkbox |
| `scroll-into-view <selector> [--snapshot-after]` | Scroll element into view |
| `type <selector> <text> [--snapshot-after]` | Type text (character by character) |
| `fill <selector> [text] [--snapshot-after]` | Fill input (empty = clear) |
| `press <key> [--snapshot-after]` | Press key |
| `keydown\|keyup <key> [--snapshot-after]` | Key down/up |
| `select <selector> <value> [--snapshot-after]` | Select dropdown option |
| `scroll [--selector] [--dx] [--dy] [--snapshot-after]` | Scroll page or element |
| `highlight <selector>` | Highlight element visually |

### JavaScript

| Command | Description |
|---------|-------------|
| `eval <script>` | Execute JavaScript |
| `addinitscript <script>` | Add init script (runs on every navigation) |
| `addscript <script>` | Add script to current page |
| `addstyle <css>` | Add CSS to current page |

### Waiting

| Command | Description |
|---------|-------------|
| `wait [--selector] [--text] [--url-contains] [--load-state] [--function] [--timeout-ms]` | Wait for condition |

### Tabs

| Command | Description |
|---------|-------------|
| `tab new [url]` | Open new tab |
| `tab list` | List tabs |
| `tab switch <index>` | Switch to tab |
| `tab close` | Close current tab |

### Dialogs & Downloads

| Command | Description |
|---------|-------------|
| `dialog accept\|dismiss [text]` | Handle dialog |
| `download [wait] [--path] [--timeout-ms]` | Handle download |

### Storage & State

| Command | Description |
|---------|-------------|
| `cookies get\|set\|clear [...]` | Cookie management |
| `storage local\|session get\|set\|clear [key] [value]` | Web storage |
| `state save\|load <path>` | Save/load browser state (cookies + storage) |
| `frame <selector\|main>` | Switch iframe context |

### Console & Errors

| Command | Description |
|---------|-------------|
| `console list\|clear` | Browser console messages |
| `errors list\|clear` | JavaScript errors |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `CMUX_WORKSPACE_ID` | Auto-set in cmux terminals. Default `--workspace` for all commands. |
| `CMUX_SURFACE_ID` | Auto-set. Default `--surface`. |
| `CMUX_PANE_ID` | Auto-set. Current pane. |
| `CMUX_TAB_ID` | Optional. Default for `tab-action`/`rename-tab`. |
| `CMUX_SOCKET_PATH` | Override socket path (default: `/tmp/cmux.sock`). |
| `CMUX_SOCKET_PASSWORD` | Socket authentication password. |
