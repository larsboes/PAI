---
name: webfetch
description: "Fetch and convert any content to Markdown — URLs via Jina AI Reader (fast, free), local files via markitdown (PDF, DOCX, PPTX, HTML). Optional AI summarization, entity extraction, and batch processing."
# @sync: public
---

# WebFetch

Unified content fetcher. Two backends, one skill.

| Source | Backend | Speed |
|--------|---------|-------|
| Any URL | Jina AI Reader (free, no API key) | ~200ms |
| Local files (PDF, DOCX, PPTX, HTML) | markitdown (local, no network) | varies |
| URL (fallback / advanced) | markitdown via uvx | ~1-2s |

---

## URL → Markdown (Primary Path)

```bash
{baseDir}/webfetch.js fetch https://docs.python.org/3/library/asyncio.html
{baseDir}/webfetch.js fetch https://github.com/anthropics/anthropic-sdk-python
{baseDir}/webfetch.js fetch https://example.com/article
```

Jina handles robots.txt, JS-rendered pages, and most SPAs. Free, no rate limits for normal usage.

**Fallback** (if Jina fails — blocked site, heavy SPA):
```bash
uvx markitdown <url>
```

---

## Local File → Markdown

```bash
uvx markitdown document.pdf
uvx markitdown slides.pptx
uvx markitdown report.docx
uvx markitdown page.html

# Write to file
uvx markitdown document.pdf > output.md
```

Supported: PDF, Word (.docx), PowerPoint (.pptx), Excel (.xlsx), HTML, images (OCR), audio (transcription), ZIP.

---

## Routing: When to Use What

| Need | Command |
|------|---------|
| Read docs / article at known URL | `webfetch.js fetch <url>` |
| Convert local PDF / DOCX / PPTX | `uvx markitdown <file>` |
| **Find content by keyword** | Use built-in `WebSearch` tool |
