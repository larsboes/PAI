---
name: Xlsx
description: "Create, analyze, and transform Excel spreadsheets (.xlsx) with formulas, charts, and multi-sheet operations. Use when working with Excel files or spreadsheet data."
---

# Requirements for Outputs

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

This sub-skill activates when the user's request involves Excel spreadsheets (.xlsx, .xlsm, .csv, .tsv).

### Explicit Triggers
- User mentions "create spreadsheet", "new Excel file", "Excel workbook"
- User requests "formulas", "financial model", "financial modeling"
- User wants to "recalculate" or "recalculate formulas"
- User says "analyze data in Excel", "read Excel", "Excel data analysis"
- User mentions .xlsx, .xlsm, .csv, or .tsv files

### Contextual Triggers
- User provides path to .xlsx/.xlsm file
- User discusses calculations, projections, or financial data
- User mentions financial projections, revenue models, or valuations
- User wants to work with spreadsheet formulas or data

### Workflow Routing

**Creation Workflow (openpyxl):**
- "Create spreadsheet", "new Excel file", "build financial model"
- User wants to create new .xlsx files with formulas and formatting
- Use openpyxl for formula support and Excel-specific features

**Editing Workflow (openpyxl):**
- "Edit spreadsheet", "modify Excel", "update cells"
- User wants to modify existing .xlsx files while preserving formulas
- Use `load_workbook()` to preserve existing formatting and formulas

**Data Analysis Workflow (pandas):**
- "Analyze data", "read Excel", "data visualization"
- User wants to analyze or visualize data from Excel files
- Use pandas for powerful data manipulation and analysis

**Financial Modeling Workflow:**
- "Financial model", "revenue projections", "valuation model"
- User wants professional financial models with color coding
- Follow financial model standards (blue inputs, black formulas, green links)

**Recalculation Workflow:**
- "Recalculate", "update formula values", "calculate formulas"
- After creating/editing files with formulas
- MANDATORY step after using formulas - run `recalc.py` script


## Quick Start

```python
from openpyxl import Workbook, load_workbook

# Read
wb = load_workbook("input.xlsx", data_only=True)
ws = wb.active
for row in ws.iter_rows(values_only=True):
    print(row)

# Write
wb = Workbook()
ws = wb.active
ws.append(["Name", "Value"])
ws.append(["Total", "=SUM(B2:B100)"])  # ALWAYS use formulas!
wb.save("output.xlsx")
```

## Critical Rules
- **ALWAYS use formulas, never hardcoded calculated values**
- Read with `data_only=True` to see computed values
- Use named ranges for complex models

## Deep References

| Reference | Content |
|-----------|---------|
| `references/openpyxl-patterns.md` | Full openpyxl patterns: charts, formatting, formulas, financial models |

## Dependencies
```bash
pip install openpyxl
```

## Output
- Produces: .xlsx files with formulas, charts, formatting
- Format: Excel spreadsheets
