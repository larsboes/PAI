---
name: Pptx
description: "Create and edit PowerPoint presentations (.pptx) with templates, charts, KPI dashboards, and DT Telekom CI. Use when building presentations or modifying slide decks."
---

# PPTX creation, editing, and analysis

## 🎯 Load Full PAI Context

**Before starting any task with this skill, load complete PAI context:**

`read ~/.claude/PAI/SKILL.md`

This provides access to:
- Complete contact list (Angela, Bunny, Saša, Greg, team members)
- Stack preferences (TypeScript>Python, bun>npm, uv>pip)
- Security rules and repository safety protocols
- Response format requirements (structured emoji format)
- Voice IDs for agent routing (ElevenLabs)
- Personal preferences and operating instructions

## 🔀 When to Use This Sub-Skill

### Explicit Triggers
Route to this sub-skill when user requests contain:

**Creation Triggers:**
- "create presentation", "new presentation", "make slides"
- "build PowerPoint", "generate pptx"
- "presentation from scratch"

**Editing Triggers:**
- "edit presentation", "modify slides", "update PowerPoint"
- "change slide content", "edit pptx"

**Template Triggers:**
- "use presentation template", "based on template"
- "apply template design", "template slides"

**Design Triggers:**
- "presentation design", "slide layout"
- "speaker notes", "add notes to slides"
- "pitch deck", "slide deck"

### Contextual Triggers
Route to this sub-skill when:
- Working with .pptx files
- User mentions "PowerPoint"
- User mentions "pitch deck" or "slide deck"
- User mentions "keynote" (if exporting to pptx)
- Presentation-related file paths or operations

### Workflow Routing

Once in this sub-skill, route to specific workflows:

**Programmatic Workflow (PythonPptx) — PREFERRED for data-driven content:**
- KPI dashboards, charts, tables, Gantt timelines
- DT Telekom CI branded decks
- Batch slide generation from data
- Need native PowerPoint charts (editable in PowerPoint)
- → Read `references/python-pptx-api.md` completely, use SlideBuilder/SlideRecipes/ChartBuilder/GanttBuilder

**Creation Workflow (html2pptx):**
- "create presentation", "new slides", "build from scratch"
- No template mentioned, complex visual layouts
- → Read `html2pptx.md` completely, use html2pptx.js

**Template Workflow:**
- "use template", "based on template", "apply template"
- Existing pptx file to use as template
- → Follow rearrange/replace workflow with inventory.py

**Editing Workflow (OOXML):**
- "edit presentation", "modify existing slides"
- Need to change specific content in existing pptx
- → Read `ooxml.md` completely, use unpack/pack scripts

**Text Extraction Workflow:**
- "extract text", "read presentation", "what's in this pptx"
- → Use markitdown: `python -m markitdown file.pptx`

**Visual Analysis Workflow:**
- "show slides", "thumbnail grid", "preview slides"
- → Use thumbnail.py script for grid visualization

**Speaker Notes Workflow:**
- "add speaker notes", "presenter notes"
- → Use OOXML workflow, edit notesSlide{N}.xml files


## Quick Start

```bash
# Export slides to PNG for visual inspection
python3 scripts/export_slides.py input.pptx ./slides/

# Create from template
python3 -c "from pptx import Presentation; prs = Presentation('template.pptx')"
```

## Deep References

| Reference | Content |
|-----------|---------|
| `references/creation-patterns.md` | Full creation/editing patterns, design principles, color palettes, layouts |
| `references/thumbnails.md` | Creating thumbnail grids from slide exports |
| `references/python-pptx-api.md` | python-pptx specific API patterns |

## Output
- Produces: .pptx files or PNG slide exports
- Format: PowerPoint presentations or image files
