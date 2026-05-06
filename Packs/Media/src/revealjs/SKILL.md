---
name: revealjs
description: Create polished, professional reveal.js presentations. Use when the user asks to create slides, a presentation, a deck, or a slideshow. Supports themes, multi-column layouts, code highlighting, animations, speaker notes, and custom styling. Generates HTML + CSS with no build step required.
---

# Reveal.js Presentations

Create HTML presentations using reveal.js. No build step required - just open the HTML in a browser.

## What You Create

A reveal.js presentation consists of:

1. **HTML file** - Contains slides and loads reveal.js from CDN
2. **CSS file** - Custom styles for layouts, colors, typography, and components


## Design Principles (Summary)

- Dark backgrounds, light text, high contrast
- Professional color palettes (see `references/design-guide.md`)
- Content hierarchy: one key idea per slide
- Font sizes: titles 2.5em+, body 1.1-1.3em, captions 0.8em

## Workflow

1. **Plan structure** — section titles, flow, transitions
2. **Generate scaffold** — `scripts/scaffold.sh` creates base HTML
3. **Customize CSS** — theme, colors, typography (see `references/theming.md`)
4. **Fill HTML content** — slides, fragments, speaker notes
5. **Check overflow** — ensure nothing bleeds off-screen
6. **Visual review** — screenshot verification via Browser skill
7. **Suggest edits** — open in browser for final tweaks

### Scaffold Command
```bash
scripts/scaffold.sh "Presentation Title" 10  # 10 slides
```

### Slide Types
- `<section>` = horizontal slide
- Nested `<section>` = vertical stack
- `class="r-fit-text"` = auto-size text
- `data-auto-animate` = smooth transitions
- `<aside class="notes">` = speaker notes

## Deep References

| Reference | Content |
|-----------|---------|
| `references/design-guide.md` | Full color palette selection, design principles |
| `references/theming.md` | CSS customization, variable system, gradients |
| `references/css-reference.md` | Component CSS (blockquotes, icons, advanced features) |

## Output
- Produces: Self-contained HTML + CSS presentation file
- Format: Single HTML file, opens directly in any browser
- Location: Project directory or `~/presentations/`
