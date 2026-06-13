---
name: Parser
description: "Turn any content source into structured JSON OR clean Markdown — URLs, articles, newsletters, YouTube, PDFs, DOCX/PPTX, browser extensions, Twitter/X — with entity extraction, schema validation, collision detection, and dedup; plus raw URL→Markdown (Jina Reader) and local-file→Markdown (markitdown). USE WHEN parse, extract, extract from URL, extract article, extract newsletter, extract YouTube, extract PDF, entity extraction, parse content, detect content type, structured data from URL, JSON from article, batch extract, browser extension parse, fetch url to markdown, url to markdown, convert pdf to markdown, convert docx to markdown, markitdown, jina reader, clean markdown from url."
---

# Parser

Parse any content into structured JSON with entity extraction and collision detection.

---

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **ParseContent** | "parse this", "extract from URL" | `Workflows/ParseContent.md` |
| **BatchEntityExtractionGemini3** | "batch extract", "Gemini extraction" | `Workflows/BatchEntityExtractionGemini3.md` |
| **CollisionDetection** | "check duplicates", "entity collision" | `Workflows/CollisionDetection.md` |
| **DetectContentType** | "what type is this", "auto-detect" | `Workflows/DetectContentType.md` |

### Content Type Workflows

| Workflow | Trigger | File |
|----------|---------|------|
| **ExtractNewsletter** | "parse newsletter" | `Workflows/ExtractNewsletter.md` |
| **ExtractTwitter** | "parse tweet", "X thread" | `Workflows/ExtractTwitter.md` |
| **ExtractArticle** | "parse article", "web page" | `Workflows/ExtractArticle.md` |
| **ExtractYoutube** | "parse YouTube", "video transcript" | `Workflows/ExtractYoutube.md` |
| **ExtractPdf** | "parse PDF", "document" | `Workflows/ExtractPdf.md` |

### Security Workflows

| Workflow | Trigger | File |
|----------|---------|------|
| **ExtractBrowserExtension** | "analyze extension", "browser extension security" | `Workflows/ExtractBrowserExtension.md` |

---

## Raw Markdown (not JSON)

When you want clean Markdown rather than structured JSON — reading docs/articles, or converting a local office file — skip the entity pipeline:

```bash
# URL -> Markdown via Jina AI Reader (free, no API key; handles JS/SPAs)
curl -s "https://r.jina.ai/https://example.com/article" -H "X-Return-Format: markdown"

# Local file -> Markdown (PDF, DOCX, PPTX, XLSX, HTML, images/OCR, audio, ZIP)
uvx markitdown document.pdf
uvx markitdown document.pdf > output.md
```

Use this for "fetch this URL to markdown" / "convert this PDF to markdown". For keyword discovery use the built-in WebSearch tool; for structured entity JSON use the workflows above. (Absorbed the former `webfetch` skill — Jina + markitdown.)

---

## Context Files

- **EntitySystem.md** - Entity extraction, GUIDs, collision detection reference

---

## Core Paths

- **Schema:** `Schema/content-schema.json`
- **Entity Index:** `entity-index.json`
- **Output:** `Output/`

---

## Examples

**Example 1: Parse YouTube video**
```
User: "parse this YouTube video for the newsletter"
--> Invokes Youtube workflow
--> Extracts transcript via YouTube API
--> Identifies people, companies, topics mentioned
--> Returns structured JSON with entities and key insights
**Example 2: Batch parse article URLs**
```
User: "parse these 5 URLs into JSON for the database"
--> Invokes ParseContent workflow for each
--> Detects content type for each URL
--> Extracts entities with collision detection
--> Assigns GUIDs, checks for duplicates
--> Returns validated JSON per schema
**Example 3: Check for duplicate content**
```
User: "have I already parsed this article?"
--> Invokes CollisionDetection workflow
--> Checks URL against entity index
--> Returns existing content ID if found
--> Skips re-parsing, saves time
---

## Quick Reference

- **Schema Version:** 1.0.0
- **Output Format:** JSON validated against `Schema/content-schema.json`
- **Entity Types:** people, companies, links, sources, topics
- **Deduplication:** Via entity-index.json with UUID v4 GUIDs

## When to Use Parser vs ExtractWisdom

| You Want... | Use |
|-------------|-----|
| Structured JSON with schema validation | **Parser** |
| Entity extraction with GUIDs/dedup | **Parser** |
| Batch processing N URLs into database | **Parser** |
| Insight extraction with personality/voice | **ExtractWisdom** |
| "What's interesting in this video?" | **ExtractWisdom** |
| Key takeaways in conversational tone | **ExtractWisdom** |
