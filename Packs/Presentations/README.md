---
name: Presentations
pack-id: larsboes-presentations-v1.0.0
version: 1.0.0
author: larsboes
description: Polished reveal.js presentations from natural language — themes, layouts, charts, overflow detection, and visual review
type: skill
purpose-type: [content, presentations, visualization]
platform: claude-code
dependencies: []
keywords: [revealjs, presentations, slides, deck, slideshow, charts, reveal.js]
---

# Presentations

> Create polished, professional reveal.js HTML presentations from natural language — no build step required.

---

## The Problem

Creating presentations is tedious. You either spend hours in PowerPoint/Keynote tweaking layouts, or you use a Markdown-based tool and accept limited styling. Either way:

- **Design takes too long** — choosing colors, fonts, layouts for every slide
- **Charts require separate tools** — export from Excel, import into slides, resize, repeat
- **Content overflow is invisible** — text runs off the slide and you don't notice until presenting
- **Iteration is slow** — change one thing, re-export, re-check

The fundamental issue: presentations should be as fast as describing what you want.

---

## The Solution

The Presentations pack generates complete reveal.js HTML presentations from natural language. Describe your topic and structure, and the system handles design, layout, charts, and quality checks.

1. **Smart scaffolding** — generates HTML structure so the LLM doesn't waste tokens on boilerplate
2. **Content-driven design** — analyzes the subject matter and chooses colors, fonts, and layouts that match
3. **Chart.js integration** — bar, line, pie, doughnut, scatter charts rendered directly in slides
4. **Automated overflow detection** — catches content that extends beyond slide boundaries
5. **Visual review** — screenshots every slide for manual inspection of color, layout, and readability
6. **Browser editing** — edit text inline in the browser after generation, no HTML editing needed

Output is a self-contained HTML + CSS bundle. Open in any browser, export to PDF with DeckTape.

---

## Installation

This pack is designed for AI-assisted installation. Give this directory to your AI and ask it to install using `INSTALL.md`.

---

## What's Included

| Component | Path | Purpose |
|-----------|------|---------|
| Skill definition | `src/revealjs/SKILL.md` | Skill routing, design principles, full workflow |
| Scaffold generator | `src/revealjs/scripts/create-presentation.js` | HTML boilerplate generation |
| Overflow checker | `src/revealjs/scripts/check-overflow.js` | Automated slide overflow detection |
| Chart validator | `src/revealjs/scripts/check-charts.js` | Chart.js configuration validation |
| Browser editor | `src/revealjs/scripts/edit-html.js` | Inline text editing via local server |
| Base styles | `src/revealjs/references/base-styles.css` | CSS template with variables for theming |
| Advanced features | `src/revealjs/references/advanced-features.md` | Fragments, speaker notes, auto-animate, transitions |
| Chart reference | `src/revealjs/references/charts.md` | Chart sizing patterns, types, styling, CSV format |

**Summary:**
- **Skills:** 1 (revealjs)
- **Scripts:** 4 (scaffold, overflow, charts, editor)
- **Reference docs:** 3 (base CSS, advanced features, charts)
- **Dependencies:** Node.js, Playwright, DeckTape, Cheerio

---

## Invocation Scenarios

| Trigger | What Happens |
|---------|--------------|
| "create a presentation about renewable energy" | Plans structure, picks palette, generates HTML + CSS, checks overflow, reviews screenshots |
| "make a pitch deck for my startup" | Business-oriented layout with charts, metrics slides, professional theme |
| "build a quarterly review with charts" | Data-heavy slides with Chart.js bar/line/pie charts |
| "create slides about machine learning basics" | Educational layout with progressive reveal, code highlighting |

---

## Example Usage

```
User: "Create a 10-slide pitch deck for an AI legal tech startup"

AI:
1. Plans slide structure (title, problem, solution, market, traction, etc.)
2. Selects color palette matching legal/tech industry
3. Generates scaffold with create-presentation.js
4. Fills in content slide-by-slide using Edit tool
5. Adds Chart.js charts for market size and traction data
6. Runs overflow checker
7. Captures and reviews screenshots of all slides
8. Suggests browser editor for final text tweaks
```

---

## Configuration

### Required

- **Node.js** for running scaffold and validation scripts
- **npm dependencies** installed in the skill directory (Playwright, Cheerio)

### Optional

- **DeckTape** for PDF export and slide screenshots (`npx decktape`)

---

## Credits

- **Original skill:** Ryan Brown ([ryanbbrown/revealjs-skill](https://github.com/ryanbbrown/revealjs-skill))
- **Packaged for PAI by:** Lars Boes

---

## Works Well With

- **Media Pack** — generated diagrams and images can be embedded in slides
- **Research Pack** — research outputs provide content for data-driven presentations

---

## Changelog

### 1.0.0 - 2026-04-19
- Initial PAI pack release
- Ported from ryanbbrown/revealjs-skill
- Single skill: revealjs (scaffold, overflow check, chart validation, browser editor)
