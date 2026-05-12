# Obsidian CSS Foundations Reference

Core CSS variables for theming. Use in CSS snippets (`.obsidian/snippets/`) or themes.

## Colors

### Base Colors (Light/Dark)
```css
/* Each has --color-*-rgb variant for use with rgba() */
--color-red              --color-red-rgb
--color-orange           --color-orange-rgb
--color-yellow           --color-yellow-rgb
--color-green            --color-green-rgb
--color-cyan             --color-cyan-rgb
--color-blue             --color-blue-rgb
--color-purple           --color-purple-rgb
--color-pink             --color-pink-rgb
```

### Accent Color (user-configurable)
```css
--accent-h               /* hue */
--accent-s               /* saturation */
--accent-l               /* lightness */
--color-accent           /* computed from HSL above */
--color-accent-1         /* lighter variant */
--color-accent-2         /* darker variant */
```

### Extended Colors (each has -rgb variant)
```css
--color-red-1 to -3      /* light to dark */
--color-orange-1 to -3
--color-yellow-1 to -3
--color-green-1 to -3
--color-cyan-1 to -3
--color-blue-1 to -3
--color-purple-1 to -3
--color-pink-1 to -3
```

### Semantic Colors
```css
/* Backgrounds */
--background-primary          /* main content area */
--background-primary-alt      /* alternate (sidebars) */
--background-secondary        /* secondary surfaces */
--background-secondary-alt

/* Interactive */
--interactive-normal          /* buttons, inputs */
--interactive-hover
--interactive-accent          /* active/selected */
--interactive-accent-hover

/* Text */
--text-normal                 /* primary text */
--text-muted                  /* secondary text */
--text-faint                  /* tertiary/hint text */
--text-on-accent              /* text on accent backgrounds */
--text-accent                 /* accent-colored text (links) */
--text-accent-hover
--text-error                  /* error messages */
--text-highlight-bg           /* ==highlight== background */
--text-selection              /* text selection background */

/* Caret */
--caret-color                 /* cursor color in editor */
```

### Black/White
```css
--mono-rgb-0                  /* 0,0,0 */
--mono-rgb-100                /* 255,255,255 */
```

## Typography

### Fonts
```css
--font-interface              /* UI elements (sans-serif) */
--font-text                   /* Editor content (serif or sans) */
--font-monospace              /* Code blocks (monospace) */
```

### Font Sizes (relative, for editor)
```css
--font-smallest               /* 0.8em */
--font-smaller                /* 0.875em */
--font-small                  /* 0.933em */
--font-text-size              /* 1em (base, default 16px) */
```

### Font Sizes (fixed, for UI)
```css
--font-ui-smaller             /* 12px */
--font-ui-small               /* 13px */
--font-ui-medium              /* 15px */
--font-ui-large               /* 20px */
```

### Font Weights
```css
--font-thin                   /* 100 */
--font-extralight             /* 200 */
--font-light                  /* 300 */
--font-normal                 /* 400 */
--font-medium                 /* 500 */
--font-semibold               /* 600 */
--font-bold                   /* 700 */
--font-extrabold              /* 800 */
--font-black                  /* 900 */
```

### Text
```css
--bold-modifier               /* additional weight for bold (100-300) */
--bold-color                  /* color override for bold text */
--italic-color                /* color override for italic text */
--font-weight-normal          /* default body weight */
--line-height-normal          /* 1.5 */
--line-height-tight           /* 1.3 */
--p-spacing                   /* paragraph spacing */
--heading-spacing             /* space above headings */
```

## Spacing
```css
--size-2-1                    /* 2px */
--size-2-2                    /* 4px */
--size-2-3                    /* 6px */
--size-4-1                    /* 4px */
--size-4-2                    /* 8px */
--size-4-3                    /* 12px */
--size-4-4                    /* 16px */
--size-4-6                    /* 24px */
--size-4-8                    /* 32px */
--size-4-9                    /* 36px */
--size-4-12                   /* 48px */
--size-4-16                   /* 64px */
--size-4-18                   /* 72px */
```

## Radiuses
```css
--radius-s                    /* small (4px) */
--radius-m                    /* medium (8px) */
--radius-l                    /* large (12px) */
--radius-xl                   /* extra large (16px) */
```

## Borders
```css
--border-width                /* default border width */
--divider-color               /* separator/divider color */
--divider-color-hover
```

## Using in Snippets

Create `.css` files in `.obsidian/snippets/`:

```css
/* .obsidian/snippets/my-style.css */
.theme-dark {
  --background-primary: #1a1a2e;
  --text-normal: #e0e0e0;
}

.theme-light {
  --background-primary: #fafafa;
}

/* Target specific elements */
.workspace-leaf-content[data-type="canvas"] {
  --canvas-background: #0d1117;
}
```

Enable in Settings → Appearance → CSS Snippets.
