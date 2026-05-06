## CSS Components Reference

### Blockquotes
```css
.reveal blockquote {
  border-left: 4px solid var(--primary-color);
  padding-left: 20px;
  margin: 20px 0;
  font-style: italic;
  background: none;
  box-shadow: none;
  width: 100%;
}

.reveal blockquote cite {
  display: block;
  margin-top: 10px;
  font-style: normal;
  color: var(--muted-color);
}
```

### Icons (Font Awesome)

Font Awesome is included in the scaffold. Usage:
```html
<i class="fa-solid fa-lightbulb"></i>
<i class="fa-solid fa-check"></i>
<i class="fa-solid fa-gears"></i>
```

## Advanced Features

For fragments (progressive reveal), speaker notes, custom backgrounds, auto-animate, and transitions, see [references/advanced-features.md](references/advanced-features.md).

## Reveal.js Configuration

```javascript
Reveal.initialize({
  controls: true,          // Show navigation arrows
  progress: true,          // Show progress bar
  slideNumber: true,       // Show slide numbers
  hash: true,              // Update URL hash for each slide
  transition: 'slide',     // none/fade/slide/convex/concave/zoom
  center: false,           // Vertical centering of slide content
  autoSlide: 0,            // Auto-advance (ms), 0 to disable
  loop: false,             // Loop presentation
});
```

**Note on `center`:** Default is `false` (content aligns to top), which works best for content-heavy slides. Set to `true` for minimal/creative presentations where you want content vertically centered.

## Built-in Reveal.js Classes

Use these directly without custom CSS:

- `r-fit-text` - Auto-size text to fill slide
- `r-stretch` - Stretch element to fill remaining vertical space
- `r-stack` - Layer elements on top of each other

```html
<h1 class="r-fit-text">BIG TEXT</h1>
<img class="r-stretch" src="image.jpg">
```

## Adding Charts

**IMPORTANT: Before adding ANY chart, you MUST read [references/charts.md](references/charts.md).** Charts require specific flexbox/grid patterns to size correctly and avoid overflow. Do not attempt to add charts without reading the full documentation first.

The scaffold includes the Chart.js plugin for adding bar, line, pie, doughnut, and scatter charts to slides.

**Required pattern** - charts need flexbox containers and `maintainAspectRatio: false`:

```html
<section style="display: flex; flex-direction: column; height: 100%;">
  <h2>Chart Title</h2>
  <div style="flex: 1; position: relative; min-height: 0;">
    <canvas data-chart="bar">
    <!--
    {
      "data": {
        "labels": ["Q1", "Q2", "Q3", "Q4"],
        "datasets": [{ "label": "Revenue", "data": [12, 19, 8, 15] }]
      },
      "options": {
        "maintainAspectRatio": false
      }
    }
    -->
    </canvas>
  </div>
</section>
```

**[references/charts.md](references/charts.md) covers (required reading):**
- Layout patterns: full slide, half (horizontal/vertical), quarter, unequal splits (1fr 2fr, 1fr 3fr)
- Why the flexbox pattern is required (Chart.js aspect ratio behavior)
- All chart types (bar, line, pie, doughnut, scatter, etc.)
- Styling and color options
- CSV data format (simpler alternative to JSON)

## Dependencies

Required for the scripts, should be already installed:
- **Node.js** (for running scripts)
- **Puppeteer** (for overflow checking): `npm install puppeteer`
- **Decktape** (for screenshots): `npx decktape` (runs directly)
