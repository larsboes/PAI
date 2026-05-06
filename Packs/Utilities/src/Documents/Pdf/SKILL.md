---
name: Pdf
description: "Read, create, merge, split, and fill PDF documents. Extract text, handle large PDFs, fill forms. Use when working with PDF files."
---

# PDF Processing Guide

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

## When to Activate This Skill

### Direct PDF Task Triggers
- User wants to **create** a new PDF document
- User wants to **merge**, **combine**, or **concatenate** multiple PDFs
- User wants to **split** or **separate** a PDF into individual pages/sections
- User mentions "**extract text from PDF**", "**PDF text extraction**"
- User mentions "**extract tables from PDF**", "**PDF tables**"
- User wants to "**fill PDF form**", "**PDF form filling**"
- User mentions "**OCR**", "**scanned PDF**", or "**scan to text**"
- User wants to add **watermarks**, **password protection**, or **encryption**
- User wants to **extract images** from a PDF
- User wants to **rotate pages** or manipulate PDF structure

### Contextual Triggers
- User provides a **.pdf file path** for processing
- User mentions form filling automation or batch PDF processing
- User needs to process PDFs programmatically at scale

## 🔀 PDF Workflow Routing

This skill supports multiple PDF processing workflows:


## Workflow Routing

| Task | Workflow |
|------|----------|
| Create PDF from scratch | `references/workflow-examples.md` → Creation |
| Merge/split PDFs | `references/workflow-examples.md` → Merge/Split |
| Extract text | `references/workflow-examples.md` → Extraction |
| Extract tables | `references/workflow-examples.md` → Tables |
| Fill forms | `references/workflow-examples.md` → Forms |
| OCR (scanned docs) | `references/workflow-examples.md` → OCR |

## Quick Start

```python
from pypdf import PdfReader, PdfWriter

# Read
reader = PdfReader("input.pdf")
text = reader.pages[0].extract_text()

# Merge
writer = PdfWriter()
for pdf in ["a.pdf", "b.pdf"]:
    writer.append(pdf)
writer.write("merged.pdf")
```

## Deep References

| Reference | Content |
|-----------|---------|
| `references/python-patterns.md` | Full pypdf, pdfplumber, reportlab, FPDF2 patterns |
| `references/workflow-examples.md` | Detailed workflow examples with full code |

## Dependencies
```bash
pip install pypdf pdfplumber reportlab fpdf2 pytesseract
```

## Output
- Produces: PDF files or extracted text/data
- Format: .pdf files or structured text/JSON
