---
name: Docx
description: "Create, edit, and analyze Word documents (.docx) with tracked changes, templates, and bulk operations. Use when working with Word files."
---

# DOCX creation, editing, and analysis

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

### Creating Word Documents
- User says "create Word document", "new docx", "make a document"
- User wants to generate professional documents from scratch
- User needs formatted documents with tables, images, or complex layout

### Editing Word Documents
- User says "edit Word document", "modify docx", "update document"
- User mentions "tracked changes", "redlining", "document review"
- User wants to add, remove, or modify content in existing .docx files
- User needs to work with comments, formatting, or document structure

### Reading and Analyzing Documents
- User says "read docx", "extract text from Word", "analyze document"
- User wants to view tracked changes, comments, or document metadata
- User needs to convert documents to other formats (markdown, PDF, images)
- User wants to inspect document structure or raw OOXML

### Contextual Activation
- User provides a .docx file or path to a Word document
- User is working with professional, legal, academic, or business documents
- User needs to preserve formatting, track changes, or maintain document integrity

## Overview

A user may ask you to create, edit, or analyze the contents of a .docx file. A .docx file is essentially a ZIP archive containing XML files and other resources that you can read or edit. You have different tools and workflows available for different tasks.

## Workflow Decision Tree

### Reading/Analyzing Content
Use "Text extraction" or "Raw XML access" sections below

### Creating New Document
Use "Creating a new Word document" workflow

### Editing Existing Document
- **Your own document + simple changes**
  Use "Basic OOXML editing" workflow

- **Someone else's document**
  Use **"Redlining workflow"** (recommended default)

- **Legal, academic, business, or government docs**
  Use **"Redlining workflow"** (required)


## Quick Start

```python
from docx import Document

# Read
doc = Document("input.docx")
for para in doc.paragraphs:
    print(para.text)

# Create
doc = Document()
doc.add_heading("Title", 0)
doc.add_paragraph("Content here.")
doc.save("output.docx")
```

## Deep References

| Reference | Content |
|-----------|---------|
| `references/python-docx-patterns.md` | Full creation/editing/redlining patterns, image conversion, style guidelines |

## Output
- Produces: .docx files or extracted text
- Format: Word documents with formatting, tracked changes support
