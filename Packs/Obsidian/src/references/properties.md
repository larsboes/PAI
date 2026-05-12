# Obsidian Properties Reference

Properties (frontmatter) are structured metadata at the top of a note, enclosed in `---` delimiters. Must be the very first thing in the file.

## Format

```yaml
---
key: value
tags:
  - tag1
  - tag2
aliases:
  - "alternate name"
---
```

## Property Types

| Type | Example | Notes |
|------|---------|-------|
| **Text** | `author: "Jane"` | Plain string |
| **List** | `tags: [a, b]` or multiline `- a` | Array of values |
| **Number** | `priority: 5` | Integer or float |
| **Checkbox** | `done: true` | `true` / `false` |
| **Date** | `created: 2026-03-30` | ISO 8601 (`YYYY-MM-DD`) |
| **Date & time** | `due: 2026-03-30T14:30` | ISO 8601 with time |

## Default Properties

| Property | Type | Description |
|----------|------|-------------|
| `tags` | list | Note tags (also works as `#tag` in body) |
| `aliases` | list | Alternative names for the note (used in link suggestions) |
| `cssclasses` | list | CSS classes applied to the note in reading/editing view |

## YAML Rules

- Strings with special chars need quotes: `title: "My Note: A Story"`
- Lists can be inline `[a, b]` or block form with `- item`
- Empty values: `key:` (no value) or `key: ""` or `key: []`
- Nested objects not officially supported by Obsidian properties UI (but valid YAML)
- Boolean: `true`/`false` (not `yes`/`no`)

## Accessing in Bases

```yaml
note.author          # note property
note.tags            # list property
note.tags.contains("ai")  # filter by tag
file.name            # file metadata
file.mtime           # modification time
```

## Hotkeys

| Action | Shortcut |
|--------|----------|
| Add property | `Cmd/Ctrl+;` |
| Focus properties | Click the properties section header |

## Property Naming

- Use lowercase with hyphens: `due-date`, `project-name`
- Avoid spaces (use hyphens instead)
- Obsidian normalizes property names to lowercase
- Properties are global — same name = same type across vault

## CSS Variables (35 total)

### Properties Container (9)
```css
--metadata-display-reading          /* display in reading mode */
--metadata-label-font-size
--metadata-label-font-weight
--metadata-label-width              /* label column width */
--metadata-property-radius          /* border radius */
--metadata-property-padding
--metadata-property-background
--metadata-property-background-hover
--metadata-property-background-active
```

### Individual Properties (26)
```css
--metadata-input-font-size
--metadata-input-font-weight
--metadata-input-background
--metadata-input-background-hover
--metadata-input-background-active
--metadata-input-height
--metadata-input-radius
--metadata-input-border-width
--metadata-input-border-color
--metadata-input-border-color-hover
--metadata-input-border-color-active
--metadata-tag-background
--metadata-tag-background-hover
--metadata-tag-border-width
--metadata-tag-border-color
--metadata-tag-border-color-hover
--metadata-tag-radius
--metadata-tag-padding-x
--metadata-tag-padding-y
--metadata-tag-font-size
--metadata-tag-font-weight
--metadata-checkbox-border-radius
--metadata-add-button-color
--metadata-add-button-color-hover
--metadata-add-button-background-hover
--metadata-add-button-background-active
```
