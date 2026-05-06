### Step 3: Customize the CSS

The scaffold script automatically copies `base-styles.css` to your presentation directory as `styles.css`. Now customize the CSS variables (especially colors) for your presentation theme.

**Using Google Fonts:** Add an `@import` at the top of your CSS file:
```css
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Lato:wght@300;400;600&display=swap');

:root {
  --heading-font: "Playfair Display", Georgia, serif;
  --body-font: "Lato", Helvetica, sans-serif;
  /* ... */
}
```

The base file includes:

1. **CSS Variables** for easy customization:
```css
:root {
  /* ===========================================
     BACKGROUND COLOR - Set this first!
     =========================================== */
  --background-color: #ffffff;  /* Change for dark themes (e.g., #1a1a2e) */

  /* Typography - ALWAYS use pt for font sizes */
  --heading-font: "Source Sans Pro", Helvetica, sans-serif;
  --body-font: "Source Sans Pro", Helvetica, sans-serif;
  --base-font-size: 32px;  /* Only px value - sets reveal.js base */
  --text-size: 16pt;       /* Base body text - intentionally small */
  --h1-size: 48pt;
  --h2-size: 36pt;
  --h3-size: 24pt;

  /* Colors - customize these for each presentation */
  --primary-color: #2196F3;
  --secondary-color: #ff9800;
  --text-color: #222;       /* Use light color (e.g., #FAF7F2) for dark backgrounds */
  --muted-color: #666;      /* Adjust for dark backgrounds too */
}
```

2. **Override reveal.js styles** using `.reveal` prefix:
```css
.reveal {
  font-family: var(--body-font);
}

.reveal h1, .reveal h2, .reveal h3 {
  font-family: var(--heading-font);
  text-transform: none;
  color: var(--text-color);
}

.reveal p, .reveal li {
  font-size: var(--text-size);
  color: var(--text-color);
}
```

3. **Slide layout styles** - control padding and positioning:
```css
.reveal .slides section {
  padding: 40px 60px;
  text-align: left;
}
```

4. **Text size utilities** (use these to scale up text when slides have less content):
```css
/* Base text is 16pt - use these classes to increase size when needed */
.text-lg { font-size: 18pt; }    /* Slightly larger */
.text-xl { font-size: 20pt; }    /* Medium emphasis */
.text-2xl { font-size: 24pt; }   /* Strong emphasis */
.text-3xl { font-size: 28pt; }   /* Very large */
.text-4xl { font-size: 32pt; }   /* Maximum body text */
.text-muted { color: var(--muted-color); }
.text-center { text-align: center; }
```

**Typography guidance:**
- Base text (`--text-size: 16pt`) is intentionally small to fit more content
- When a slide has less content, use `.text-lg`, `.text-xl`, etc. to fill space appropriately
- This approach prevents overflow on content-heavy slides while allowing flexibility on lighter slides

**Custom CSS classes for repeated patterns:**

Use inline styles for layout (grids, flex containers) since those vary per slide. But when a visual pattern appears on multiple slides, create a dedicated CSS class in `styles.css` instead of repeating inline styles. This keeps the HTML clean and ensures consistency. Common examples: stat boxes (number + label), feature cards (icon + title + description), timeline/process steps, profile/bio cards. If an element repeats 3+ times, it should be a class.

### Step 4: Fill in the HTML Content
