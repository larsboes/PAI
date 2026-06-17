# Obsidian Canvas Reference

Canvas is a core plugin for visual note-taking on an infinite 2D space. Files use the open JSON Canvas format (`.canvas`).

## Creating a Canvas

- **Command palette:** "Canvas: Create new canvas"
- **File explorer:** Right-click folder → "New canvas"
- **Ribbon:** Canvas icon

## Card Types

| Type | Description |
|------|-------------|
| **Text** | Markdown text, no file reference |
| **File/Note** | Embed a vault file |
| **Media** | Images, audio, PDFs |
| **Web page** | Embedded URL |
| **Folder** | All files from a folder |

## Key Operations

- **Edit:** Double-click card
- **Context menu:** Right-click card
- **Select all:** `Ctrl/Cmd+A`
- **Multi-select:** Drag to select area
- **Connect:** Drag from card edge to another card
- **Group:** Select cards → create named group
- **Color:** Right-click → set color on cards or edges
- **Convert text to file:** Right-click text card → convert (enables backlinks)

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Shift+1` | Zoom to fit all items |
| `Shift+2` | Zoom to selection |
| `Space + drag` | Pan canvas |
| `Space + scroll` | Zoom |
| `Ctrl/Cmd + scroll` | Zoom |
| `Space` (while moving) | Disable snapping |
| `Shift` (while moving) | Constrain to one axis |
| `Shift` (while resizing) | Maintain aspect ratio |

## JSON Canvas Spec (v1.0)

**License:** MIT open format
**File:** `.canvas` (JSON)

### Top-Level Structure
```json
{
  "nodes": [],   // optional — array of node objects (ascending z-index)
  "edges": []    // optional — array of edge objects
}
```

### Generic Node (shared by all types)

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `id` | yes | string | Unique identifier |
| `type` | yes | string | `"text"`, `"file"`, `"link"`, `"group"` |
| `x` | yes | integer | X position (pixels) |
| `y` | yes | integer | Y position (pixels) |
| `width` | yes | integer | Width (pixels) |
| `height` | yes | integer | Height (pixels) |
| `color` | no | canvasColor | Node color |

### Text Node (additional fields)
| Field | Required | Type |
|-------|----------|------|
| `text` | yes | string (Markdown) |

### File Node (additional fields)
| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `file` | yes | string | Path to file |
| `subpath` | no | string | Heading/block link (starts with `#`) |

### Link Node (additional fields)
| Field | Required | Type |
|-------|----------|------|
| `url` | yes | string |

### Group Node (additional fields)
| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `label` | no | string | Group name |
| `background` | no | string | Path to background image |
| `backgroundStyle` | no | string | `"cover"`, `"ratio"`, `"repeat"` |

### Edge

| Field | Required | Type | Default | Description |
|-------|----------|------|---------|-------------|
| `id` | yes | string | — | Unique identifier |
| `fromNode` | yes | string | — | Source node ID |
| `fromSide` | no | string | — | `"top"`, `"right"`, `"bottom"`, `"left"` |
| `fromEnd` | no | string | `"none"` | `"none"`, `"arrow"` |
| `toNode` | yes | string | — | Target node ID |
| `toSide` | no | string | — | `"top"`, `"right"`, `"bottom"`, `"left"` |
| `toEnd` | no | string | `"arrow"` | `"none"`, `"arrow"` |
| `color` | no | canvasColor | — | Edge color |
| `label` | no | string | — | Edge label text |

### Color (`canvasColor`)

Two formats:
- **Hex:** `"#FF0000"`
- **Preset number:**

| Preset | Color |
|--------|-------|
| `"1"` | Red |
| `"2"` | Orange |
| `"3"` | Yellow |
| `"4"` | Green |
| `"5"` | Cyan |
| `"6"` | Purple |

Preset RGB values are intentionally undefined — apps choose their own.

### Example .canvas File

```json
{
  "nodes": [
    {
      "id": "group1",
      "type": "group",
      "x": -300, "y": -460,
      "width": 610, "height": 200,
      "label": "My Group"
    },
    {
      "id": "note1",
      "type": "file",
      "file": "Knowledge/Kubernetes.md",
      "x": -280, "y": -200,
      "width": 400, "height": 300,
      "color": "5"
    },
    {
      "id": "text1",
      "type": "text",
      "text": "# Key Insight\n\nThis connects to [[Docker]]",
      "x": 200, "y": -200,
      "width": 250, "height": 160
    }
  ],
  "edges": [
    {
      "id": "edge1",
      "fromNode": "note1",
      "fromSide": "right",
      "toNode": "text1",
      "toSide": "left",
      "label": "relates to"
    }
  ]
}
```

## CSS Variables (9)

```css
--canvas-background           /* Canvas background color */
--canvas-card-label-color     /* Card label text color */
--canvas-dot-pattern          /* Dot pattern color */
--canvas-color-1              /* Preset 1: Red */
--canvas-color-2              /* Preset 2: Orange */
--canvas-color-3              /* Preset 3: Yellow */
--canvas-color-4              /* Preset 4: Green */
--canvas-color-5              /* Preset 5: Cyan */
--canvas-color-6              /* Preset 6: Purple */
```

---

## Advanced Canvas Plugin

The [obsidian-advanced-canvas](https://github.com/Developer-Mike/obsidian-advanced-canvas) plugin extends the standard JSON Canvas format with `styleAttributes`, collapsible groups, portals, and presentation mode. All additions are stored as extra JSON properties alongside the standard fields.

### Node Style Attributes

Add a `styleAttributes` object to any node. Available keys depend on node type.

#### Shape (text nodes only)

| Value | Shape | Use Case |
|-------|-------|----------|
| `null` | Round rectangle | Default |
| `"pill"` | Rounded oval | Start/end, titles |
| `"diamond"` | Diamond | Decision points |
| `"parallelogram"` | Parallelogram | Input/output |
| `"circle"` | Circle | References |
| `"predefined-process"` | Rectangle + side lines | Subroutines |
| `"document"` | Curved bottom | Documents, definitions |
| `"database"` | Cylinder | Data stores |

#### Border (all node types)

| Value | Style |
|-------|-------|
| `null` | Solid (default) |
| `"dashed"` | Dashed line |
| `"dotted"` | Dotted line |
| `"invisible"` | No border |

#### Text Alignment (text nodes only)

| Value | Alignment |
|-------|-----------|
| `null` | Left (default) |
| `"center"` | Center |
| `"right"` | Right |

#### Node Example

```json
{
  "id": "decision1",
  "type": "text",
  "text": "## Is it sorted?",
  "x": 0, "y": 0,
  "width": 200, "height": 150,
  "styleAttributes": {
    "shape": "diamond",
    "textAlign": "center",
    "border": "dashed"
  }
}
```

### Edge Style Attributes

Add a `styleAttributes` object to any edge.

#### Path Style

| Value | Style |
|-------|-------|
| `null` | Solid (default) |
| `"dotted"` | Dotted line |
| `"short-dashed"` | Short dashes |
| `"long-dashed"` | Long dashes |

#### Arrow Style

| Value | Shape |
|-------|-------|
| `null` | Filled triangle (default) |
| `"triangle-outline"` | Hollow triangle |
| `"thin-triangle"` | Thin triangle |
| `"halved-triangle"` | Half triangle |
| `"diamond"` | Filled diamond |
| `"diamond-outline"` | Hollow diamond |
| `"circle"` | Filled circle |
| `"circle-outline"` | Hollow circle |
| `"blunt"` | Blunt end |

#### Pathfinding Method

| Value | Method |
|-------|--------|
| `null` | Bezier (default) |
| `"direct"` | Straight line |
| `"square"` | Right-angle turns |
| `"a-star"` | A* pathfinding |

#### Edge Example

```json
{
  "id": "e1",
  "fromNode": "a",
  "toNode": "b",
  "fromSide": "right",
  "toSide": "left",
  "label": "generalizes to",
  "styleAttributes": {
    "path": "long-dashed",
    "arrow": "diamond-outline",
    "pathfindingMethod": "square"
  }
}
```

### Collapsible Groups

Add `"collapsed": false` to a group node to make it collapsible. Users can toggle in the UI.

```json
{
  "id": "group1",
  "type": "group",
  "x": 0, "y": 0,
  "width": 600, "height": 400,
  "label": "My Collapsible Group",
  "collapsed": false
}
```

### Portals

Embed another canvas inside the current one. Add `"portal": true` to a file node referencing a `.canvas` file.

```json
{
  "id": "portal1",
  "type": "file",
  "file": "Resources/Canvas/Other Map.canvas",
  "x": 0, "y": 0,
  "width": 600, "height": 400,
  "portal": true
}
```

### Presentation Mode

Create slide-based presentations from canvas groups. Uses a `"presentation"` top-level key with ordered node references.

### Additional Features

- **Focus mode:** Blur all nodes except selected
- **Edge highlight:** Edges glow when connected node is selected
- **Auto node resizing:** `"dynamicHeight": true` on nodes
- **Frontmatter support:** Canvas files can have YAML frontmatter for tags, aliases, CSS classes
- **Metadata cache:** `.canvas` files appear in graph view and backlinks
- **Single node links:** `[[canvas-file#node-id]]` links to specific nodes
- **Encapsulate selection:** Move nodes to new canvas with backlink

### Design Patterns for Canvas Styling

Use `styleAttributes` consistently to encode meaning:

| Pattern | Node Style | Edge Style |
|---------|-----------|------------|
| **Definition cards** | `shape: "document"` | `path: "short-dashed"` to first child |
| **Decision points** | `shape: "diamond"`, `textAlign: "center"` | — |
| **Title/summary** | `shape: "pill"`, `textAlign: "center"` | — |
| **Hierarchy edges** | — | `arrow: "thin-triangle"` |
| **Cross-group refs** | — | `path: "long-dashed"`, `arrow: "diamond-outline"` |
| **Data stores** | `shape: "database"` | — |
| **Process steps** | `shape: "predefined-process"` | `pathfindingMethod: "square"` |
