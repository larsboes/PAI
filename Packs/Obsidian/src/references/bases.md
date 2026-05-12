# Obsidian Bases Reference

Bases is a core plugin that creates database-like views of notes. Data lives in `.base` files (YAML format). All data stays local in Markdown.

## View Types

| Type | Since | Description |
|------|-------|-------------|
| **Table** | v1.9 | Rows/columns from note properties |
| **Cards** | v1.9 | Grid layout, good for image galleries |
| **List** | v1.10 | Bulleted/numbered display |
| **Map** | v1.10 | Geographic pins (requires Maps plugin) |

Community plugins can add additional view types.

## Creating a Base

- **Command palette:** "Bases: Create new base" or "Bases: Insert new base"
- **File explorer:** Right-click folder → "New base"
- **Ribbon:** "Create new base"

## Embedding

```markdown
![[File.base]]              # Embed entire base
![[File.base#View]]         # Embed specific view
```

Or inline as a code block:
````markdown
```base
filter: file.folder = "Projects"
view:
  type: table
```
````

## .base File Structure (YAML)

```yaml
# Filters — narrow the dataset (global or per-view)
filter: <condition>

# Formulas — calculated properties available in all views
formulas:
  formatted_price: "'$' + number(note.price).toFixed(2)"

# Properties — display config per property
properties:
  price:
    name: "Price (USD)"

# Summaries — aggregation formulas
summaries:
  total: "sum(note.price)"

# Views — different renderings of same data
views:
  - type: table
    name: "All Projects"
    limit: 50
    order:
      - property: note.status
        direction: asc
    groupBy:
      property: note.category
      direction: asc
    filters: <view-level filter>
    summaries:
      price: Sum
```

## Property Access

### Note Properties (from frontmatter)
```yaml
note.author        # explicit
author             # shorthand (same thing)
note.tags          # list property
```

### File Properties (file metadata)
```yaml
file.name          # filename without extension
file.path          # full path
file.ext           # file extension
file.size          # file size
file.ctime         # creation time
file.mtime         # modification time
file.folder        # parent folder
```

### Formula Properties
```yaml
formula.formatted_price    # reference a formula
```

### Context (`this`)
- In main view: refers to the base file itself
- When embedded: refers to the embedding file
- In sidebar: refers to the active file

## Filter Syntax

### Operators
| Type | Operators |
|------|-----------|
| Comparison | `==`, `!=`, `>`, `<`, `>=`, `<=` |
| Boolean | `!`, `&&`, `\|\|` |
| Arithmetic | `+`, `-`, `*`, `/`, `%` |

### Logical Combinators
```yaml
filter:
  and:
    - note.status == "active"
    - note.priority > 3
  or:
    - note.type == "project"
    - note.type == "task"
  not:
    - note.archived == true
```

### Date Arithmetic
Duration strings: `"1M"` (1 month), `"2h"` (2 hours), `"7d"` (7 days)
```yaml
filter: file.mtime > now() - "7d"
```

## Built-in Summaries

| Summary | Description |
|---------|-------------|
| Average | Mean of numeric values |
| Sum | Total of numeric values |
| Min | Minimum value |
| Max | Maximum value |
| Median | Median value |
| Stddev | Standard deviation |
| Earliest | Earliest date |
| Latest | Latest date |
| Checked | Count of checked checkboxes |
| Unchecked | Count of unchecked checkboxes |
| Empty | Count of empty values |
| Filled | Count of non-empty values |
| Unique | Count of unique values |

## Functions Reference

### Global Functions
`escapeHTML()`, `date()`, `duration()`, `file()`, `html()`, `if()`, `image()`, `icon()`, `link()`, `list()`, `max()`, `min()`, `now()`, `number()`, `today()`, `random()`

### Any Type
`isTruthy()`, `isType()`, `toString()`

### Date
- Access: `.year`, `.month`, `.day`, `.hour`, `.minute`, `.second`, `.millisecond`
- Methods: `date()`, `format()`, `time()`, `relative()`, `isEmpty()`

### String
`contains()`, `containsAll()`, `containsAny()`, `endsWith()`, `isEmpty()`, `lower()`, `replace()`, `repeat()`, `reverse()`, `slice()`, `split()`, `startsWith()`, `title()`, `trim()`

### Number
`abs()`, `ceil()`, `floor()`, `isEmpty()`, `round()`, `toFixed()`

### List
`contains()`, `containsAll()`, `containsAny()`, `filter()`, `flat()`, `isEmpty()`, `join()`, `map()`, `reduce()`, `reverse()`, `slice()`, `sort()`, `unique()`

### Link
`asFile()`, `linksTo()`

### File
- Access: `.name`, `.path`, `.ext`, `.size`, `.ctime`, `.mtime`
- Methods: `asLink()`, `hasLink()`, `hasProperty()`, `hasTag()`, `inFolder()`

### Object
`isEmpty()`, `keys()`, `values()`

### Regular Expression
`matches()`

## CSS Variables (39 total)

### Base Container (10)
```css
--bases-header-border-width
--bases-header-height
--bases-header-padding-start
--bases-header-padding-end
--bases-toolbar-label-display
--bases-toolbar-badge-display
--bases-embed-border-width
--bases-embed-border-color
--bases-embed-border-radius
--bases-filter-menu-width
```

### Table View (20)
```css
--bases-table-container-border-width
--bases-table-container-border-radius
--bases-table-header-weight
--bases-table-header-color
--bases-table-header-icon-display
--bases-table-header-background
--bases-table-header-background-hover
--bases-table-header-sort-mask
--bases-table-border-color
--bases-table-column-border-width
--bases-table-row-border-width
--bases-table-row-background-hover
--bases-table-row-height
--bases-table-text-size
--bases-table-column-max-width
--bases-table-column-min-width
--bases-table-cell-radius-active
--bases-table-cell-shadow-active
--bases-table-cell-background-active
--bases-table-cell-background-disabled
```

### Cards View (9)
```css
--bases-cards-container-background
--bases-cards-background
--bases-cards-cover-background
--bases-cards-scale
--bases-cards-group-padding
--bases-cards-line-height
--bases-cards-border-width
--bases-cards-shadow
--bases-cards-shadow-hover
```
