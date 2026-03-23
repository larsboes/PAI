---
name: html-docs
description: "Use when creating standalone HTML documentation sites for projects — architecture overviews, feature catalogs, component references, or configuration docs. Zero-build, no framework, just HTML/CSS/JS."
---

# HTML Documentation Site

Build standalone HTML documentation sites. Zero build step, no framework, no SSG. Open `index.html` in a browser and it works — including `file:///`.

## When to Use

- Project needs docs but doesn't warrant a full SSG (Docusaurus, MkDocs, etc.)
- Internal tools, libraries, or utilities that need clean reference docs
- Architecture overviews for stakeholders or onboarding
- Quick project showcase pages
- Any situation where `file:///` or `python -m http.server` should work

## Scripts

### Scaffold a new docs site

```bash
./scripts/scaffold.sh "My Project"
./scripts/scaffold.sh "API Gateway" --dir api-docs --pages index,endpoints,auth,errors --labels "Overview,Endpoints,Authentication,Errors"
./scripts/scaffold.sh "Tool" --accent "#3fb950" --pages index,usage --labels "Overview,Usage"
```

**Options:**

| Flag | Description | Default |
|------|-------------|---------|
| `--dir <path>` | Output directory | `./docs/site` |
| `--pages <list>` | Comma-separated page names | `index,features,components,config` |
| `--labels <list>` | Comma-separated page labels | `Architecture,Features,Components,Configuration` |
| `--accent <hex>` | Accent color | `#58a6ff` |
| `--no-mermaid` | Skip Mermaid.js CDN | off |
| `--mermaid-pages <list>` | Pages needing Mermaid | `index,components` |

Creates: `shared.css`, `shared.js`, and one HTML file per page with scaffold content (cards, details, tables, callouts).

### Validate a docs site

```bash
./scripts/validate.sh ./docs/site
```

Checks:
- Required files (CSS, JS, HTML)
- Viewport meta, `data-theme` attribute
- Navigation consistency across all pages
- Internal link integrity
- Mermaid CDN vs usage alignment
- Stale placeholders and TODOs
- CSS quality (max-width, responsive, light theme)

## Architecture

```
docs/site/
  index.html      # Landing page (Architecture / Overview)
  features.html   # Feature catalog
  components.html # Component / module reference
  config.html     # Configuration reference
  shared.css      # Design system — dark/light theme, all components
  shared.js       # Nav highlighting, theme toggle, Mermaid init
```

3–6 pages is the sweet spot. More than 6 → use an SSG.

## Design System

The CSS template (`references/templates/shared.css`) provides a complete component library:

| Component | Class(es) | Use For |
|-----------|-----------|---------|
| Card grid | `.card-grid` + `.card` | 3–4 item overviews, principles |
| Collapsible | `<details>` + `.details-content` | Anything longer than 3 lines |
| Table | `<table>` | Structured reference data |
| Badge | `.badge` `.badge-green/yellow/blue/red` | Status indicators |
| Callout | `.callout` `.callout-info/warn/error/success` | Important notes |
| Mermaid | `.mermaid` | Architecture diagrams |
| Code | `<pre><code>` | Config examples, API usage |
| Placeholder | `.placeholder` | Sections not yet written |

### Theme Support

Dark + light via CSS variables on `:root` and `:root[data-theme="light"]`. Theme toggle persists to `localStorage`. Mermaid diagrams re-render on toggle.

### Responsive

Mobile breakpoint at 768px. Hamburger menu toggles sidebar. Cards collapse to single column.

## Progressive Disclosure Pattern

Layer information density — never dump a 50-row table at the top level:

```
Level 1: Card grid        → Scannable overview (2–3 seconds)
Level 2: Section h2/h3    → Navigate to topic (5 seconds)
Level 3: <details>         → Drill into specifics (click to expand)
Level 4: Tables + code     → Reference data inside details
```

## Content Patterns

See `references/content-patterns.md` for detailed patterns per page type:
- **Architecture page** — cards, Mermaid diagrams, ADRs, status table
- **Features page** — cards, collapsible feature groups, comparison tables
- **Components page** — layer diagram, module catalog tables
- **Config page** — file tree, YAML references, CLI args, troubleshooting

## Templates

Raw template files for manual use (the scaffold script copies these automatically):

- `references/templates/shared.css` — Complete CSS design system (dark + light)
- `references/templates/shared.js` — Nav highlight, theme toggle, Mermaid init

## Common Mistakes

1. **Too many pages** — 3–6 max. More → SSG.
2. **No progressive disclosure** — Use `<details>` liberally.
3. **Inconsistent nav** — Every page must have identical sidebar HTML.
4. **Mermaid CDN on every page** — Only include on pages that have `<div class="mermaid">`.
5. **Stale placeholders** — Remove `.placeholder` divs after implementing.
6. **Giant code blocks at top level** — Wrap in `<details>`.
7. **No `max-width`** — Content wider than 860px is unreadable.
8. **Inline styles** — Use CSS classes from the design system.

## Red Flags

- Missing `<meta name="viewport">` — broken on mobile
- Missing `data-theme="dark"` on `<html>` — theme toggle fails
- JS beyond nav/theme — this isn't an app, keep it minimal
- Google Fonts imports — system font stack loads instantly
- `<iframe>` embeds — prefer Mermaid or inline content

## Quick Checklist

- [ ] Run `./scripts/scaffold.sh` or manually copy templates
- [ ] `shared.css` has dark + light theme variables
- [ ] `shared.js` handles nav + theme + mobile menu
- [ ] Every page has identical sidebar nav
- [ ] Progressive disclosure: cards → headers → details → tables
- [ ] Run `./scripts/validate.sh` — 0 errors
- [ ] Works with `file:///` (no build step)
