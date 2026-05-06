# python-pptx API Reference (v1.0.0)

> Source: https://python-pptx.readthedocs.io/en/latest/
> Distilled for pptx_helpers.py development — focuses on APIs we use or should use.

## Slide Management

```python
# Access slides
prs.slides[0]                          # By index
prs.slides.get(slide_id)              # By internal ID
prs.slides.index(slide)              # Get index of slide
len(prs.slides)                       # Count

# Slide properties
slide.slide_id                        # Unique internal ID
slide.slide_layout                    # SlideLayout object
slide.name                            # Internal name (r/w)
slide.background                      # _Background object
slide.follow_master_background        # bool — inherit master bg (r/w)
slide.has_notes_slide                 # Check without creating
slide.notes_slide                     # Get/create notes slide
slide.placeholders                    # Sequence of placeholders
slide.shapes                          # Sequence of shapes

# Hidden slides (XML attribute, not exposed as property)
slide._element.get('show') == '0'     # Check if hidden
slide._element.set('show', '0')       # Hide slide

# Layout lookup (better than iteration!)
layout = prs.slide_layouts.get_by_name('Zwei Inhalte')
layout.used_by_slides                 # Tuple of slides using this layout
```

## Shape Creation (SlideShapes)

```python
shapes = slide.shapes

# Basic shapes
shapes.add_shape(MSO_SHAPE.RECTANGLE, left, top, width, height)
shapes.add_textbox(left, top, width, height)
shapes.add_picture(image_file, left, top, width=None, height=None)
shapes.add_table(rows, cols, left, top, width, height)
shapes.add_chart(chart_type, left, top, width, height, chart_data)

# Advanced
shapes.add_group_shape(shapes_iterable)   # Group shapes together
shapes.add_connector(MSO_CONNECTOR, x1, y1, x2, y2)  # Lines between shapes
shapes.add_movie(movie_file, left, top, w, h, poster_frame)  # EXPERIMENTAL
shapes.add_ole_object(file, prog_id, left, top, ...)  # Embed Excel, etc.

# Freeform shapes (custom polygons)
builder = shapes.build_freeform(start_x=0, start_y=0, scale=Inches(1)/1000)
builder.add_line_segments([(x1,y1), (x2,y2), ...])
shape = builder.convert_to_shape()

# Performance: turbo mode for 100s of shapes
shapes.turbo_add_enabled = True  # Cache shape IDs (use with ONE Slide object only)

# Shape access
shapes.title                          # Title placeholder or None
shapes.placeholders                   # Placeholder shapes only
shapes.index(shape)                   # Position in z-order
```

## MSO_SHAPE Types (Most Useful)

| Shape | Constant | Use Case |
|-------|----------|----------|
| Rectangle | `MSO_SHAPE.RECTANGLE` | Bars, backgrounds, lines |
| Rounded Rectangle | `MSO_SHAPE.ROUNDED_RECTANGLE` | Cards, buttons |
| Oval | `MSO_SHAPE.OVAL` | Circles, dots |
| Diamond | `MSO_SHAPE.DIAMOND` | Milestones |
| Right/Left/Up/Down Arrow | `MSO_SHAPE.RIGHT_ARROW` etc. | Flow direction |
| Chevron | `MSO_SHAPE.CHEVRON` | Process steps |
| Pentagon | `MSO_SHAPE.PENTAGON` | Callouts |
| Hexagon | `MSO_SHAPE.HEXAGON` | Hub nodes |
| Cloud | `MSO_SHAPE.CLOUD` | Abstract concepts |
| Lightning Bolt | `MSO_SHAPE.LIGHTNING_BOLT` | Action/alert |
| Flowchart Process | `MSO_SHAPE.FLOWCHART_PROCESS` | Diagrams |
| Flowchart Decision | `MSO_SHAPE.FLOWCHART_DECISION` | Diagrams |
| Flowchart Connector | `MSO_SHAPE.FLOWCHART_CONNECTOR` | Numbered circles |

## Rounded Rectangle Corner Radius

python-pptx has no direct API. Set via XML:
```python
prstGeom = shape._element.spPr.find(qn('a:prstGeom'))
avLst = prstGeom.find(qn('a:avLst'))  # or create
etree.SubElement(avLst, qn('a:gd'), attrib={'name': 'adj', 'fmla': 'val 16667'})
# Range: 0 (square) to 50000 (full pill). Telekom deck default: 16667
```

## Fill & Color (DrawingML)

```python
# FillFormat — accessed via shape.fill or chart_element.format.fill
fill = shape.fill
fill.solid()                          # Set to solid fill
fill.gradient()                       # Set to gradient fill
fill.patterned()                      # Set to pattern fill
fill.background()                     # Set to transparent (noFill)
fill.fore_color.rgb = RGBColor(0xE2, 0x00, 0x74)  # Set RGB color
fill.fore_color.theme_color = MSO_THEME_COLOR.ACCENT_1  # Set theme color
fill.fore_color.brightness = -0.25    # 25% darker
fill.type                             # MSO_FILL_TYPE enum

# Gradient stops
fill.gradient()                       # Enable gradient first
fill.gradient_angle = 90.0            # Bottom to top (0 = left to right)
stops = fill.gradient_stops           # GradientStops collection
stop = stops[0]
stop.color.rgb = RGBColor(...)
stop.position                         # 0.0 to 1.0

# LineFormat
line = shape.line
line.fill.background()                # No line
line.color.rgb = RGBColor(...)        # Line color
line.width = Pt(1)                    # Line width
line.dash_style = MSO_LINE_DASH.DASH  # Dash style

# ColorFormat
color = shape.fill.fore_color
color.rgb                             # RGBColor or None
color.theme_color                     # MSO_THEME_COLOR member
color.brightness                      # -1.0 to 1.0 (darken/lighten)
color.type                            # MSO_COLOR_TYPE.RGB or .SCHEME

# ShadowFormat
shape.shadow.inherit                  # True = inherited from style
shape.shadow.inherit = True           # Remove explicit shadow (restores ALL effects!)
```

## Text

```python
# TextFrame
tf = shape.text_frame
tf.word_wrap = True
tf.auto_size = MSO_AUTO_SIZE.BEST_FIT  # or NONE, SHAPE_TO_FIT_TEXT
tf.margin_left = Inches(0.1)          # Also margin_right, _top, _bottom

# Paragraphs and Runs
p = tf.paragraphs[0]                  # First paragraph
p = tf.add_paragraph()                # Add new paragraph
p.text = "Hello"                      # Shortcut (creates single run)
p.alignment = PP_ALIGN.CENTER
p.level = 0                           # Indentation level (0-8)
p.space_after = Pt(6)                 # Space after paragraph
p.space_before = Pt(6)

# Font (on paragraph or run)
p.font.size = Pt(14)
p.font.bold = True
p.font.italic = True
p.font.name = 'Arial'
p.font.color.rgb = RGBColor(0x26, 0x26, 0x26)
p.font.color.theme_color = MSO_THEME_COLOR.DARK_1
p.font.underline = True               # or MSO_TEXT_UNDERLINE_TYPE member

# Runs (for mixed formatting within a paragraph)
run = p.add_run()
run.text = "bold part"
run.font.bold = True
```

## Charts

### Chart Data Types

```python
from pptx.chart.data import CategoryChartData, XyChartData, BubbleChartData

# Category-based (bar, column, line, pie, doughnut, area, radar)
data = CategoryChartData()
data.categories = ['A', 'B', 'C']
data.add_series('Series 1', (10, 20, 30))

# XY Scatter
data = XyChartData()
series = data.add_series('Model 1')
series.add_data_point(x, y)

# Bubble
data = BubbleChartData()
series = data.add_series('Series 1')
series.add_data_point(x, y, size)
```

### Chart Types (XL_CHART_TYPE)

Most useful for business presentations:
| Type | Constant | Notes |
|------|----------|-------|
| Column | `COLUMN_CLUSTERED` | Default vertical bars |
| Column Stacked | `COLUMN_STACKED` | Stacked vertical bars |
| Bar | `BAR_CLUSTERED` | Horizontal bars |
| Line | `LINE` | Basic line |
| Line + Markers | `LINE_MARKERS` | Line with data point markers |
| Pie | `PIE` | Single-series pie |
| Doughnut | `DOUGHNUT` | Ring-shaped pie |
| Area | `AREA` | Filled area under line |
| Radar | `RADAR` | Spider/web chart |
| XY Scatter | `XY_SCATTER` | Continuous x-axis |
| Bubble | `BUBBLE` | XY with size dimension |

### Chart Customization

```python
chart = graphic_frame.chart

# Title
chart.has_title = True
chart.chart_title.text_frame.paragraphs[0].text = "Title"

# Legend
chart.has_legend = True
chart.legend.position = XL_LEGEND_POSITION.BOTTOM  # or RIGHT, LEFT, TOP
chart.legend.include_in_layout = False  # Don't shrink plot area
chart.legend.font.size = Pt(10)

# Axes
cat_axis = chart.category_axis
cat_axis.has_major_gridlines = True
cat_axis.tick_labels.font.size = Pt(10)

val_axis = chart.value_axis
val_axis.maximum_scale = 100.0
val_axis.has_minor_gridlines = True
val_axis.tick_labels.number_format = '0"%"'

# Data labels
plot = chart.plots[0]
plot.has_data_labels = True
labels = plot.data_labels
labels.number_format = '0%'
labels.position = XL_LABEL_POSITION.OUTSIDE_END
labels.font.size = Pt(9)

# Series formatting
series = chart.series[0]
series.smooth = True                  # Smooth line
series.format.fill.solid()
series.format.fill.fore_color.rgb = RGBColor(...)
series.format.line.color.rgb = RGBColor(...)

# Colors: default = theme Accent 1-6. Change theme colors in template deck for best results.
```

## Tables

```python
graphic_frame = slide.shapes.add_table(rows, cols, left, top, width, height)
table = graphic_frame.table

# Dimensions
table.columns[0].width = Inches(2)
table.rows[0].height = Inches(0.5)

# Cell access
cell = table.cell(row_idx, col_idx)
cell.text = "Value"
cell.vertical_anchor = MSO_ANCHOR.MIDDLE

# Cell text formatting
p = cell.text_frame.paragraphs[0]
p.font.size = Pt(10)
p.font.bold = True

# Merge cells
cell.merge(other_cell)                # Merge range
cell.is_merge_origin                  # True if top-left of merged range

# Cell fill (must use XML — no direct python-pptx API for cell fill)
# See _set_cell_fill() in pptx_helpers.py
```

## Presentation Properties

```python
prs = Presentation('deck.pptx')
prs.slide_width                       # EMU value (Inches(13.333) for widescreen)
prs.slide_height                      # EMU value (Inches(7.5) for widescreen)
prs.slide_layouts                     # SlideLayouts collection
prs.slide_masters                     # SlideMasters collection
prs.slide_master                      # Shortcut for first master
prs.core_properties.title             # Document title
prs.core_properties.author            # Author
prs.core_properties.subject           # Subject
```

## Units

```python
from pptx.util import Inches, Pt, Cm, Mm, Emu

# All return Length objects (EMU internally)
Inches(1)   # 914400 EMU
Pt(12)      # 152400 EMU
Cm(2.54)    # 914400 EMU
Emu(914400) # Raw EMU

# Length objects have convenience properties
length.inches  # float
length.pt      # float
length.cm      # float
length.emu     # int
```
