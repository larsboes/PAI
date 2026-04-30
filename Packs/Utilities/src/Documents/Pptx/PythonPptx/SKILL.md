---
name: PythonPptx
description: "Programmatic PowerPoint creation via python-pptx — SlideBuilder, SlideRecipes, ChartBuilder, GanttBuilder, TELEKOM CI colors. Use for data-driven slides, KPI dashboards, Gantt timelines, batch modifications, and DT-branded decks."
---

# PPTX Skill

## When to Use

- User wants to **create** a new presentation or **add slides** to an existing deck
- User needs **data-driven slides** (KPIs, tables, comparisons, timelines)
- User wants to **batch-edit** text, styling, or layout across a deck
- User needs a **Gantt chart** or project timeline slide
- User wants to **extract/analyze** an existing deck's structure
- User mentions `.pptx` files, PowerPoint, or presentation generation

## Architecture: Four Layers

| Layer | Class | Purpose |
|-------|-------|---------|
| **Recipes** | `SlideRecipes` | One-call slide templates (title, KPI, comparison, agenda, chart, table) |
| **Charts** | `ChartBuilder` | Native PowerPoint charts (column, bar, line, pie, scatter, doughnut) |
| **Primitives** | `SlideBuilder` | Shapes, text, tables, images, bullets, speaker notes, find/replace |
| **Gantt** | `GanttBuilder` | Project timeline slides with phases, tasks, milestones |
| **Colors** | `TELEKOM` | Full DT CI color palette |

**Always start with Recipes.** Drop to Charts/Primitives only when Recipes don't cover the layout.

## Quick Start

```python
import sys; sys.path.insert(0, str(Path.home() / ".claude/skills/Documents/Pptx/PythonPptx/scripts"))
from pptx_helpers import SlideBuilder, SlideRecipes, ChartBuilder, GanttBuilder, TELEKOM

sb = SlideBuilder("deck.pptx")
recipes = SlideRecipes(sb)

# High-level recipes (one call per slide)
recipes.title_slide("Q1 Results", "Lars Boes — Feb 2026")
recipes.kpi_dashboard([("Users", "1.2M", "+12%"), ("Revenue", "€4.2M")])
recipes.comparison_slide("Options", "A", ["Fast", "Cheap"], "B", ["Reliable"])
recipes.content_slide("Key Findings", ["Point one", "Point two", "Point three"])
recipes.agenda_slide(["Intro", "Analysis", "Results", "Next Steps"], current_index=1)
recipes.table_slide("Data", [["Name", "Score", "Grade"], ["Alice", "95", "A"]])
recipes.chart_slide("Revenue Trend", "line", ["Q1", "Q2", "Q3"],
                    [("2025", [100, 120, 115]), ("2026", [130, 145, 160])])

# Project management recipes (Assembly-inspired)
recipes.numbered_section_divider("Research Design", 2, "DSR Methodology")
recipes.icon_grid_slide("Overview", [("📋", "Scope", "Code Migration"), ...])
recipes.milestone_timeline_slide("Milestones", [("1", ["Kickoff", "Lit review"]), ...])
recipes.risk_grid_slide("Risks", [("R1", ["Data compliance", "DE3 blocker"]), ...])
recipes.phase_tree_slide("Phase 2", 2, "Prototyp", [("Tests", ["Unit", "Integration"]), ...])
recipes.team_slide("Team", [("Lars Boes", None, "Lead Engineer"), ...])

sb.save()
```

## SlideRecipes — One Call Per Slide

All recipes return the slide object for further customization. All accept `notes=''` for speaker notes.

```python
recipes = SlideRecipes(sb)

# Title / cover
recipes.title_slide(title, subtitle='', notes='')

# Section divider — magenta left bar + large title
recipes.section_divider(title, subtitle='', notes='')

# Content — title + bullet list
recipes.content_slide(title, bullets: list[str], subtitle='', notes='')

# KPI dashboard — up to 4 metric cards with deltas
recipes.kpi_dashboard(metrics: list[tuple], title='Key Metrics', notes='')
# metrics: [("Label", "Value", "+Delta"), ...]  — delta is optional

# Two-column comparison (pros/cons, before/after, option A/B)
recipes.comparison_slide(title, left_title, left_items, right_title, right_items,
                         left_color=TELEKOM.TEAL, right_color=TELEKOM.MAGENTA, notes='')

# Agenda / TOC with optional current-section highlight
recipes.agenda_slide(items: list[str], current_index=None, title='Agenda', notes='')

# Image + text (text left/right, image on other side)
recipes.image_slide(title, image_path, caption='', image_side='right', notes='')

# Data table slide
recipes.table_slide(title, data: list[list], col_widths=None, notes='')
```

### Project Management Recipes (Assembly-inspired)

```python
# Numbered section divider — magenta circle with chapter number + title + subtitle pill
recipes.numbered_section_divider(title, number, subtitle='', circle_color=None, notes='')

# Icon grid — 2×3 or 2×4 grid of icon circles with titles + descriptions
recipes.icon_grid_slide(title, items: list[tuple], cols=3, icon_color=None, notes='')
# items: [(icon_label, title, description), ...]  — icon_label is emoji or 1-2 chars

# Milestone timeline — vertical cascade of numbered milestones with bullet cards
recipes.milestone_timeline_slide(title, milestones: list[tuple], notes='')
# milestones: [(number_or_label, [bullet1, bullet2, ...]), ...]

# Risk/info card grid — 2×N grid with numbered circles + bullet cards
recipes.risk_grid_slide(title, risks: list[tuple], cols=2, notes='')
# risks: [(id_label, [bullet1, bullet2, ...]), ...]

# Phase tree — numbered phase with tree connector lines to item cards → arrows → bullets
recipes.phase_tree_slide(title, phase_number, phase_name, items: list[tuple], notes='')
# items: [(item_name, [bullet1, bullet2, ...]), ...]

# Team portraits — circular photos (or colored placeholder) with name + quote
recipes.team_slide(title, members: list[tuple], notes='')
# members: [(name, image_path_or_None, quote), ...]
```

## SlideBuilder — Primitives

All coordinates in **inches**. Colors default to Telekom CI.

### Slide Management

```python
sb = SlideBuilder("deck.pptx")
slide = sb.add_blank_slide()                  # Truly blank (placeholders removed)
slide = sb.add_layout_slide('Zwei Inhalte')   # Use named layout
sb.remove_last_slide()                        # Remove last slide
sb.remove_slides_from(17)                     # Remove from index 17+ (0-based)
new_slide = sb.duplicate_slide(3)             # Copy slide at index 3
count = sb.find_and_replace("old", "new")     # Replace text across all slides
sb.save()                                     # Overwrite source
sb.save("other.pptx")                         # Save to different path
```

### Text & Content

```python
# Simple label
sb.add_label(slide, x, y, w, h, "Text", size=10, bold=False, color=TELEKOM.DARK,
             align=PP_ALIGN.LEFT, wrap=False)

# Bullet list
sb.add_bullet_list(slide, x, y, w, h, ["Item 1", "Item 2", "Sub-item"],
                   indent_levels=[0, 0, 1], bullet_char='•', font_size=11)

# Multi-paragraph rich text
sb.add_rich_text(slide, x, y, w, h, [
    {"text": "Bold Title", "size": 18, "bold": True},
    {"text": "Normal body text", "size": 12},
    {"text": "Italic note", "size": 10, "italic": True, "color": TELEKOM.GRAY},
])

# Speaker notes
sb.set_speaker_notes(slide, "Talk about these metrics...")
```

### Glass Morphism & Overlays

```python
# Glass card — semi-transparent rounded rect (great on dark/image backgrounds)
sb.add_glass_card(slide, x, y, w, h, text='', text_size=12,
                  text_color=TELEKOM.WHITE, alpha=20,       # 0=invisible, 100=opaque
                  fill_hex='FFFFFF', radius=50000)           # 50000=pill, 16667=standard

# Footer bar — consistent slide footer (number | section | year)
sb.add_footer_bar(slide, number=1, section='Chapter Title', year='2026')
```

### Tables

```python
data = [["Name", "Score", "Grade"],  # Header row
        ["Alice", "95", "A"],
        ["Bob", "87", "B+"]]

sb.add_table(slide, x, y, w, h, data,
             header=True,                           # First row styled as header
             col_widths=[3, 2, 1.5],               # Optional manual widths
             header_color=TELEKOM.MAGENTA,           # Header bg
             header_text_color=TELEKOM.WHITE,        # Header text
             stripe_color=TELEKOM.SURFACE)           # Alternating rows
```

### Images

```python
sb.add_image(slide, "chart.png", x, y, w=4)       # Width-constrained (keeps ratio)
sb.add_image(slide, "photo.jpg", x, y, h=3)       # Height-constrained
sb.add_image(slide, "logo.png", x, y, w=2, h=1)   # Fixed dimensions
```

### Basic Shapes

```python
sb.add_rect(slide, x, y, w, h, color)
sb.add_rounded_rect(slide, x, y, w, h, color, radius=16667)
sb.add_diamond(slide, x, y, size, color)
sb.add_circle(slide, x, y, size, color)
sb.add_arrow(slide, x, y, w, h, color, direction='right')  # right/left/up/down
sb.add_line(slide, x, y, w, h, color)                      # w≈0 → vertical
sb.add_accent_bar(slide, x, y, direction='vertical')
```

### DT Telekom Compound Shapes

```python
sb.add_magenta_gradient_card(slide, x, y, w, h, "Text")   # 4-stop gradient
sb.add_numbered_circle(slide, x, y, size, "1")             # Gradient-filled circle
sb.add_info_card(slide, x, y, w, h, "Title", "Body")      # Gray (EDEDED) card
sb.add_highlight_card(slide, x, y, w, h, "Text")           # Magenta card
sb.add_process_flow(slide, items, x, y)                    # Box → arrow → box chain
sb.add_column_shading(slide, cols, x, y, col_w, h)        # Alternating column bg
sb.add_legend_item(slide, x, y, 'bar'|'diamond', color, "Label")
```

## GanttBuilder — Project Timelines

```python
slide = sb.add_blank_slide()
gantt = GanttBuilder(sb, slide,
    title="Projektübersicht",
    subtitle="Bachelor Thesis — 2026",
    months=["Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep"],
    row_spacing=0.30)

gantt.add_phase("Phase 1: Research")
gantt.add_task("Literature Review", 0, 0.0, 1, 0.5, TELEKOM.TEAL)
gantt.add_task("Prototype", 1, 0.0, 2, 0.5, TELEKOM.MAGENTA)
gantt.add_milestone("Mid-Review", 2, 0.0)
gantt.add_today_marker(month_fraction=0.5, month_index=0)
gantt.add_legend([("Done", "bar", TELEKOM.GREEN), ("Active", "bar", TELEKOM.MAGENTA)])
gantt.add_slide_number()
```

Month coordinates: `(month_index, fraction)` where index 0 = first month, fraction 0.0–1.0 within that month.

## ChartBuilder — Native PowerPoint Charts

Charts are **editable in PowerPoint** (double-click → edit data). Theme accent colors are applied automatically.

```python
charts = ChartBuilder(sb)

# Column (vertical bars) — multi-series
charts.column_chart(slide, "Revenue by Region",
    categories=["East", "West", "Midwest"],
    series_data=[("2025", [19.2, 21.4, 16.7]),
                 ("2026", [22.3, 28.6, 15.2])],
    stacked=False, data_labels=True)

# Bar (horizontal) — same API as column
charts.bar_chart(slide, "Response Time", ["API", "DB", "Cache"],
    [("p50", [120, 45, 8]), ("p99", [450, 200, 25])])

# Line chart — with optional smoothing
charts.line_chart(slide, "Monthly Users", ["Jan", "Feb", "Mar", "Apr"],
    [("Mobile", [100, 150, 180, 200]),
     ("Desktop", [80, 75, 70, 65])],
    smooth=True)

# Pie chart — single series, auto-percentages
charts.pie_chart(slide, "Market Share",
    categories=["Mobile", "Fixed", "TV", "Other"],
    values=[0.45, 0.30, 0.15, 0.10],
    number_format='0%')

# Doughnut chart (ring-shaped pie)
charts.doughnut_chart(slide, "Budget Allocation",
    ["Dev", "Ops", "QA", "PM"], [40, 25, 20, 15])

# XY Scatter — per-series data points
charts.scatter_chart(slide, "Accuracy vs Speed",
    series_data=[("Model A", [(0.7, 2.7), (1.8, 3.2)]),
                 ("Model B", [(1.3, 3.7), (2.7, 2.3)])])
```

### Chart recipe (one-call slide with chart)

```python
recipes.chart_slide("Revenue Trend", "line",
    categories=["Q1", "Q2", "Q3", "Q4"],
    series_data=[("2025", [100, 120, 115, 130]),
                 ("2026", [130, 145, 160, 180])],
    smooth=True)
```

## TELEKOM Color Palette

```python
# Brand
TELEKOM.MAGENTA          # E20074 — Primary brand
TELEKOM.MAGENTA_DARK     # 9A0050
TELEKOM.MAGENTA_LIGHT    # F9A8D4
TELEKOM.MAGENTA_10       # FCE7F3 — 10% tint

# Neutrals
TELEKOM.DARK             # 262626 — Primary text
TELEKOM.GRAY             # 6B7280 — Secondary text
TELEKOM.LIGHT_GRAY       # E5E5E5 — Borders
TELEKOM.SURFACE          # F5F5F7 — Backgrounds
TELEKOM.CARD_BG          # EDEDED — Card backgrounds
TELEKOM.WHITE            # FFFFFF

# Theme accents (Telekom Liquid Master)
TELEKOM.TEAL             # 32B9AF
TELEKOM.LIGHT_BLUE       # A4DEEE
TELEKOM.PEACH            # ECCCBF
TELEKOM.SKY_BLUE         # 00A8E6
TELEKOM.PURPLE           # 6E648C

# Semantic
TELEKOM.GREEN            # 059669 — Success
TELEKOM.RED              # DC2626 — Error/today
TELEKOM.BLUE             # 2563EB — Info
TELEKOM.WARNING          # D97706 — Warning
```

## Deck Theme Info

### Telekom Liquid Master (Brainstorming deck)
| Property | Value |
|----------|-------|
| Theme | Telekom Liquid Master |
| Heading font | TeleNeo Office ExtraBold |
| Body font | TeleNeo Office |
| Gradient | 4-stop linear 90°, Magenta lumMod 20→40→60→60% |
| Rounded rect radius | 16667 (of 50000) |
| Background | White with magenta ribbon |

Available layouts: `Titel lang 01/02`, `Kapiteltrenner 01/02/03`, `Agenda`,
`Titel und Inhalt`, `Nur Titel`, `Leer`, `Zwei Inhalte`, `Drei Inhalte`,
`Vier Inhalte`, `Inhalt mit Bild`, `One content - black`, `DEFAULT`

### Assembly (Simple Light / Google Slides origin)
| Property | Value |
|----------|-------|
| Theme | Simple Light |
| Heading font | Poppins SemiBold |
| Body font | Poppins |
| Accent colors | `#E2185B` (vivid), `#CC527A` (muted rose) |
| Background | Dark moody gradient image (teal/magenta/gray bokeh) |
| Glass cards | `#FFFFFF` @ 20.5% alpha, roundRect radius=50000 (pill) |
| Footer | `number \| section \| year` on every slide |
| Text | White on dark backgrounds |

Available layouts: `Title slide`, `Section header`, `Title and body`,
`Title and two columns`, `Title only`, `Blank`, `Table of contents`,
`Quote`, `Numbers and text`, `Thanks`, `Background` (30 total)

## Office XML Escape Hatch

When python-pptx can't do something, unpack → edit XML → repack:

```bash
python scripts/office/unpack.py deck.pptx unpacked/
# ... edit XML files ...
python scripts/office/pack.py unpacked/ deck.pptx
python scripts/office/validate.py deck.pptx        # Validates against XSD schemas
```

## Utility Scripts

```bash
# Render slides to PNG (requires libreoffice + poppler-utils)
python scripts/export_slides.py deck.pptx [output_dir] [--slides 0,2,4] [--dpi 150]

# Generate thumbnail grid for visual analysis
python scripts/thumbnail.py deck.pptx thumbnails --cols 5

# Add slide to unpacked PPTX from layout
python scripts/add_slide.py unpacked/ slideLayout2.xml

# Clean orphaned files from unpacked PPTX
python scripts/clean.py unpacked/
```

### Visual QA Loop (agent self-fixing)

```python
sb = SlideBuilder("deck.pptx")
# ... make changes ...
sb.save()

# Export specific slides to PNG for visual inspection
images = sb.export_slides(slides=[0, 5, 17])  # 0-based indices
# Returns: ['/tmp/pptx-preview/slide-01.png', ...]
# Use `read` tool to view the PNGs and verify layout

# Export all visible slides (hidden slides are skipped)
all_images = sb.export_slides()  # defaults to /tmp/pptx-preview/, dpi=150
```

Requires `libreoffice-impress` + `poppler-utils`:
```bash
sudo apt install -y libreoffice-impress poppler-utils
```

## Common Mistakes

- **Forgetting `sb.save()`** — changes only exist in memory until saved
- **Overlapping shapes** — always calculate x/y from previous element positions
- **Wrong font on non-DT systems** — TeleNeo Office must be installed; use `FONT_FALLBACK = 'Arial'` otherwise
- **OneDrive file locking** — if deck is open in PowerPoint, save to a temp path first, then copy
- **Table cell colors** — use `_set_cell_fill()` helper, not `cell.fill` directly (XML quirk)
- **Mixing inches and EMU** — all SlideBuilder/Recipes methods use inches; only use EMU for raw XML

## Red Flags

- Slide count > 20 → consider splitting into multiple decks
- Manual x/y positioning for standard layouts → use SlideRecipes instead
- Editing XML when python-pptx has a method → check the reference first
- Creating from scratch → start from an existing template deck, don't generate empty
