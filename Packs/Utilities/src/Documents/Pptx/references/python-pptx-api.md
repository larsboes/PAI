---
name: PythonPptx
description: "Python-pptx patterns for programmatic PowerPoint generation — slides, charts, tables, images, and templates. Use when generating presentations from code."
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


## Deep References

| Reference | Content |
|-----------|---------|
| `references/api-patterns.md` | SlideRecipes, SlideBuilder, GanttBuilder, ChartBuilder, Telekom palette, XML escape hatch |

## Output
- Produces: .pptx presentations generated via Python scripts
- Format: PowerPoint files with charts, tables, timelines
