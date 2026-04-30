---
name: design
description: Create high-quality frontend interfaces and creative web pages. Use when building UI components, dashboards, apps, landing pages, posters, or any web design work. Covers both product interfaces and marketing/creative pages.
---

<!--
🌐 COMMUNITY SKILL

Part of the PAI open skills collection.
- License: MIT

Contributions welcome via GitHub issues and PRs.
Last synced: 2026-02-18 21:06:29
-->

# Design

Two modes. Detect from context, or ask.

- **Interface mode** → dashboards, apps, tools, admin panels, product UIs
- **Creative mode** → landing pages, marketing sites, posters, campaigns, portfolio pieces

Shared foundation. Different discovery phases.

## Mode Detection

| Signal | Mode |
|---|---|
| Dashboard, admin, settings, CRUD, data tables, forms | Interface |
| Landing page, marketing, campaign, poster, portfolio, "make it beautiful" | Creative |
| Component library, design system, tokens | Interface |
| One-off page, event site, announcement | Creative |

If ambiguous, ask: "Is this a product interface or a marketing/creative piece?"

## Shared Foundation

These apply to BOTH modes. Non-negotiable.

### Anti-Default Philosophy

Never accept first-instinct values. Every choice must survive the **swap test**: if you replaced this value with another, would it matter? If not, the choice isn't intentional enough.

- No default border-radius, padding, or colors
- No `Inter` / `Roboto` / `Arial` / system fonts as lazy defaults
- No purple-gradient-on-white AI slop
- Every value must have a reason

### Surface & Depth System

Choose ONE depth strategy per project. Don't mix.

| Strategy | When | Implementation |
|---|---|---|
| Borders-only | Dense data, technical tools | `0.5px solid rgba(...)`, no shadows |
| Subtle shadows | Consumer apps, friendly tools | `0 1px 3px rgba(0,0,0,0.08)` |
| Layered shadows | Rich editorial, premium feel | Multiple shadow layers, elevation scale |

Surface elevation: use lightness shifts (e.g., `7% → 9% → 11%` for dark themes, `white → gray-50 → gray-100` for light themes). Surfaces should feel like physical layers — each level slightly different.

### Token Architecture

Define tokens BEFORE building. These are your constraints:

```
Spacing:    base unit (4px or 8px) → scale (4, 8, 12, 16, 24, 32, 48, 64)
Radius:     sharp (2, 4, 6, 8) or soft (8, 12, 16, 24)
Typography: font, scale (11-32px), weights (400, 500, 600, 700)
Colors:     foreground, secondary, muted, faint, accent, destructive
```

Every component pulls from these tokens. No magic numbers.

### Spacing Rules

- Use the spacing scale. No `17px` or `22px`.
- Consistent internal padding per component type (all cards same, all buttons same)
- Group related items with tighter spacing, separate groups with wider spacing
- Minimum margins: 0.5rem on mobile, 1rem on desktop

### Typography

- **Hierarchy is mandatory**: clear distinction between heading, subheading, body, caption
- **Line height**: 1.2-1.3 for headings, 1.5-1.6 for body
- **Font pairing**: max 2 fonts. One for headings, one for body. They must contrast (e.g., serif + sans, geometric + humanist)
- **Weight range**: don't use all weights. Pick 3 max (regular, medium, bold)

### Color

- **60-30-10 rule**: 60% dominant, 30% secondary, 10% accent
- **Contrast**: meet WCAG AA minimum (4.5:1 for body text, 3:1 for large text)
- **Semantic colors**: success (green), warning (amber), error (red), info (blue) — these exist alongside brand palette
- **Dark/light**: design for the chosen theme. If both needed, define both token sets.

---

## Interface Mode

For product UIs — dashboards, apps, tools, admin panels.

### Discovery Phase

Before ANY code:

1. **Domain exploration** — What is this tool? Who uses it? What data does it show? What actions do users take? Understanding the domain prevents generic design.

2. **Direction** — Choose a personality:

| Direction | Feel | Best For |
|---|---|---|
| Precision & Density | Tight, technical, monochrome | Dev tools, admin, analytics |
| Warmth & Approachability | Generous spacing, soft depth | Consumer, collaboration |
| Sophistication & Trust | Cool tones, layered depth | Finance, enterprise |
| Boldness & Clarity | High contrast, dramatic | Modern dashboards |
| Utility & Function | Muted, functional density | GitHub-style tools |
| Data & Analysis | Chart-optimized, numbers-first | BI, analytics |

3. **Commit** — State the direction, tokens, and depth strategy before writing code. Get confirmation.

### Design Checkpoint (Per Component)

Before building each component, state:
- Depth treatment (borders, shadow, etc.)
- Surface level (which layer?)
- Spacing (which tokens?)
- Typography (which scale values?)

This prevents drift across a session.

### System Persistence

After establishing direction, save to `.interface-design/system.md`:

```markdown
# Design System

## Direction
Personality: [chosen]
Foundation: [warm/cool/neutral]
Depth: [borders-only/subtle-shadows/layered-shadows]

## Tokens
### Spacing
Base: [4px/8px]
Scale: [values]

### Colors
--foreground: [value]
--secondary: [value]
--accent: [value]

## Patterns
[Component patterns as they're built]

## Decisions
| Decision | Rationale | Date |
|---|---|---|
```

Load this at session start. Maintain across components. Offer to save new patterns.

See `references/system-examples.md` for full examples.

---

## Creative Mode

For marketing pages, landing pages, posters, campaigns, portfolio pieces.

### Discovery Phase

Before ANY code:

1. **Purpose & audience** — What is this selling/announcing/celebrating? Who sees it?

2. **Bold aesthetic direction** — Commit to an extreme. Not "clean and modern" — that's nothing. Pick a FLAVOR:
   - Brutally minimal
   - Maximalist chaos
   - Retro-futuristic
   - Organic / natural
   - Luxury / refined
   - Playful / toy-like
   - Editorial / magazine
   - Brutalist / raw
   - Art deco / geometric
   - Soft / pastel
   - Industrial / utilitarian

   Or invent one. The key is intentionality and commitment.

3. **Differentiation** — What's the ONE thing someone will remember? The unusual scroll interaction? The typography? The color? The motion? Design around that memorable element.

### Creative Principles

- **Typography as design element** — Fonts aren't just readable text. They're visual assets. Choose distinctive, characterful fonts. Pair a display font with a body font. Use scale dramatically (72px heading, 16px body).
- **Motion** — CSS animations, scroll-triggered reveals, staggered entrance sequences, hover states that surprise. One well-orchestrated page load > scattered micro-interactions.
- **Spatial composition** — Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density. NOT the middle ground.
- **Visual texture** — Gradient meshes, noise, geometric patterns, layered transparencies, dramatic shadows, grain overlays, custom cursors. Create atmosphere, not just content.
- **Color as story** — Dominant colors with sharp accents. Not evenly distributed palettes. Let one color own 70% of the page.

### Creative Anti-Patterns

- Same layout repeated across sections
- Centered body text everywhere
- White background with subtle gray cards (the default AI aesthetic)
- Stock photo hero sections
- Generic sans-serif with blue CTA buttons
- "Clean and modern" as the entire design direction

### Variation Rule

Every creative piece must be different from the last. Vary:
- Light vs dark theme
- Font family choices
- Layout approach
- Color palette
- Motion style

Never converge on the same aesthetic twice.

---

## Implementation

### HTML/CSS
- CSS custom properties for all tokens
- Mobile-first responsive
- Semantic HTML
- Accessible (ARIA labels, focus states, keyboard nav)

### React/Vue/Svelte
- Component-level token usage
- Props for variants (size, color, state)
- Composable patterns

### Tailwind
- Extend theme with custom tokens
- Use `@apply` sparingly — prefer utility classes
- Custom plugin for design system tokens if needed

---

## Quality Checklist

- [ ] Tokens defined before building
- [ ] Depth strategy consistent across all surfaces
- [ ] No magic numbers — all values from token scale
- [ ] Typography hierarchy clear (heading/sub/body/caption)
- [ ] Color contrast meets WCAG AA
- [ ] Responsive behavior tested
- [ ] Interactive states defined (hover, focus, active, disabled)
- [ ] Swap test passed — every value is intentional

