---
name: Documents
description: "Read, write, convert, and analyze documents — PDF, DOCX, XLSX, PPTX creation, editing, extraction, and format conversion. Use when working with any office document format."
---

# Documents Skill

## 🎯 Load Full PAI Context

**Before starting any task with this skill, load complete PAI context:**

`read ~/.claude/PAI/SKILL.md`


## When to Activate This Skill

### Word Documents (DOCX)
- User wants to create, edit, or analyze Word documents
- User mentions "tracked changes", "redlining", "document review"
- User needs to convert documents to other formats
- User wants to work with document structure, comments, or formatting

### PDF Files
- User wants to create, merge, split, or manipulate PDFs
- User mentions "extract text from PDF", "PDF tables", "fill PDF form"
- User needs to convert PDFs to/from other formats
- User wants to add watermarks, passwords, or extract images

### PowerPoint Presentations (PPTX)
- User wants to create or edit presentations
- User mentions "slides", "presentation template", "speaker notes"
- User needs to convert presentations to other formats
- User wants to work with slide layouts or design elements

### Excel Spreadsheets (XLSX)
- User wants to create or edit spreadsheets
- User mentions "formulas", "financial model", "data analysis"
- User needs to work with Excel tables, charts, or pivot tables
- User wants to convert spreadsheets to/from other formats

## Workflow Routing

| Request Pattern | Route To |
|---|---|
| Consulting report, McKinsey report, assessment report, professional PDF | `Workflows/ConsultingReport.md` |
| Large PDF, process big PDF, Gemini PDF | `Workflows/ProcessLargePdfGemini3.md` |
| Word document, DOCX, create docx, edit docx, tracked changes, redlining | `Docx/SKILL.md` |
| PDF, create PDF, merge PDF, split PDF, extract text from PDF, fill form | `Pdf/SKILL.md` |
| Presentation, PPTX, slides, PowerPoint, speaker notes | `Pptx/SKILL.md` (install separately) |
| Spreadsheet, XLSX, Excel, formulas, financial model, data analysis | `Xlsx/SKILL.md` |


## Sub-Skills

| Format | Skill | Quick Pattern |
|--------|-------|---------------|
| PDF | `Pdf/SKILL.md` | pypdf, pdfplumber, reportlab |
| Word | `Docx/SKILL.md` | python-docx |
| Excel | `Xlsx/SKILL.md` | openpyxl |
| PowerPoint | `Pptx/SKILL.md` | python-pptx |

## Deep References

| Reference | Content |
|-----------|---------|
| `references/document-types.md` | Detailed type routing, processing principles, examples |

## Key Principles
- Always export slides to PNG for visual verification
- Use formulas in Excel (never hardcoded values)
- Preserve tracked changes in Word when editing
- Use templates when available for consistent output
