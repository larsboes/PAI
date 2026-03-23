# Obsidian CLI Reference

This document provides a reference for the Obsidian CLI and its commands. This is useful for extending the `client.py` script or understanding what's possible via the native integration.

## Overview

Obsidian CLI is a command line interface that lets you control Obsidian from your terminal for scripting, automation, and integration with external tools.

Anything you can do in Obsidian can be done from the command line. Obsidian CLI even includes developer commands to access developer tools, inspect elements, take screenshots, reload plugins, and more.

## Command Structure

The CLI is located at:
`/Applications/Obsidian.app/Contents/MacOS/Obsidian`

Most commands follow the pattern:
`Obsidian <command> [parameter=value] [flag]`

## Core Commands

### Daily Notes
- `daily`: Open today's daily note
- `daily:append content="..."`: Append text to daily note
- `daily silent`: Return path to daily note without opening

### File Operations
- `search query="..."`: Search vault
- `read`: Read active file content
- `create name="..."`: Create new note
- `file`: Show info about active file
- `open path="..."`: Open specific file

### Developer Tools
- `dev:open`: Open developer tools
- `plugin:reload id="..."`: Reload a plugin
- `dev:eval code="..."`: Run JS in console

## Examples

```shell
# Open today's daily note
obsidian daily

# Add a task to your daily note
obsidian daily:append content="- [ ] Buy groceries"

# Search your vault
obsidian search query="meeting notes"

# Read the active file
obsidian read

# List all tasks from your daily note
obsidian tasks daily

# Create a new note from a template
obsidian create name="Trip to Paris" template=Travel

# List all tags in your vault with counts
obsidian tags counts

# Compare two versions of a file
obsidian diff file=README from=1 to=3
```

## Advanced Usage

### Target a Vault
Use `vault=<name>` to target a specific vault.

### Target a File
Use `file=<name>` (wikilink resolution) or `path=<path>` (exact path).

### Copy Output
Add `--copy` to copy output to clipboard.

## Full Command List

See the original documentation for a complete list of commands including:
- `bookmarks`
- `commands` (execute command palette actions)
- `properties` (frontmatter manipulation)
- `publish`
- `sync`
- `tasks`
- `workspace`

For the full list, refer to the official Obsidian Help or run `obsidian help`.
