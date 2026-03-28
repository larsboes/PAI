# CSS Components Reference

Copy-paste ready CSS for interactive teaching modules. Read when building a module.

## Base Styles

```css
* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: #0d1117;
    color: #c9d1d9;
    line-height: 1.7;
    padding: 2rem;
}

.container {
    max-width: 900px;
    margin: 0 auto;
}

h1 { color: #f0f6fc; font-size: 2.2rem; margin-bottom: 0.5rem; }
h2 { color: #f0f6fc; font-size: 1.6rem; margin: 2.5rem 0 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid #30363d; }
h3 { color: #f0f6fc; font-size: 1.2rem; margin: 1.5rem 0 0.75rem; }

a { color: #58a6ff; text-decoration: none; }
a:hover { text-decoration: underline; }

p { margin-bottom: 1rem; }
```

## Code Blocks

```css
pre {
    background: #161b22;
    border: 1px solid #30363d;
    border-radius: 8px;
    padding: 1rem 1.25rem;
    overflow-x: auto;
    font-family: 'SF Mono', SFMono-Regular, Consolas, 'Liberation Mono', Menlo, monospace;
    font-size: 0.875rem;
    line-height: 1.5;
    margin: 1rem 0;
}

code {
    font-family: inherit;
    color: #c9d1d9;
}

/* Inline code */
p code, li code, td code {
    background: #21262d;
    padding: 0.15rem 0.4rem;
    border-radius: 4px;
    font-size: 0.85em;
}

/* Syntax highlighting (add classes manually to spans in code) */
.kw { color: #ff7b72; }    /* keywords: function, return, local, if, for */
.str { color: #a5d6ff; }   /* strings */
.num { color: #79c0ff; }   /* numbers */
.cm { color: #8b949e; }    /* comments */
.fn { color: #d2a8ff; }    /* function names */
.val { color: #7ee787; }   /* values, booleans */
```

## Code Block Labels

```css
.code-block {
    position: relative;
    margin: 1rem 0;
}

.code-label {
    position: absolute;
    top: 0;
    right: 0;
    background: #21262d;
    color: #8b949e;
    padding: 0.2rem 0.6rem;
    border-radius: 0 8px 0 8px;
    font-size: 0.75rem;
    text-transform: uppercase;
}
```

## Collapsible Sections

```css
details {
    background: #161b22;
    border: 1px solid #30363d;
    border-radius: 8px;
    margin: 1rem 0;
}

details summary {
    padding: 1rem 1.25rem;
    cursor: pointer;
    font-weight: 600;
    color: #f0f6fc;
    list-style: none;
}

details summary::before {
    content: "▶ ";
    font-size: 0.75rem;
    margin-right: 0.5rem;
    transition: transform 0.2s;
    display: inline-block;
}

details[open] summary::before {
    transform: rotate(90deg);
}

details .details-content {
    padding: 0 1.25rem 1rem;
}
```

## CSS-Only Tabs

```css
.tabs {
    margin: 1rem 0;
}

.tabs input[type="radio"] {
    display: none;
}

.tabs label {
    display: inline-block;
    padding: 0.5rem 1rem;
    cursor: pointer;
    color: #8b949e;
    border-bottom: 2px solid transparent;
    margin-bottom: -1px;
    transition: all 0.2s;
}

.tabs input[type="radio"]:checked + label {
    color: #58a6ff;
    border-bottom-color: #58a6ff;
}

.tabs .tab-panel {
    display: none;
    background: #161b22;
    border: 1px solid #30363d;
    border-radius: 0 0 8px 8px;
    padding: 1.25rem;
}

/* Show panel based on checked radio - adjust nth selectors per tab count */
.tabs input:nth-of-type(1):checked ~ .tab-panel:nth-of-type(1),
.tabs input:nth-of-type(2):checked ~ .tab-panel:nth-of-type(2),
.tabs input:nth-of-type(3):checked ~ .tab-panel:nth-of-type(3),
.tabs input:nth-of-type(4):checked ~ .tab-panel:nth-of-type(4) {
    display: block;
}
```

## Correct/Incorrect Comparison

```css
.comparison {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
    margin: 1.5rem 0;
}

.correct, .incorrect {
    border-radius: 8px;
    overflow: hidden;
}

.correct { border: 2px solid #3fb950; }
.incorrect { border: 2px solid #f85149; }

.correct .label {
    background: #3fb950;
    color: #0d1117;
    padding: 0.4rem 1rem;
    font-weight: 700;
    font-size: 0.85rem;
}

.incorrect .label {
    background: #f85149;
    color: #0d1117;
    padding: 0.4rem 1rem;
    font-weight: 700;
    font-size: 0.85rem;
}

.correct pre, .incorrect pre {
    margin: 0;
    border: none;
    border-radius: 0;
}

@media (max-width: 768px) {
    .comparison { grid-template-columns: 1fr; }
}
```

## Callout Boxes

```css
.callout {
    border-left: 4px solid;
    border-radius: 0 8px 8px 0;
    padding: 1rem 1.25rem;
    margin: 1.5rem 0;
    background: #161b22;
}

.callout-info    { border-color: #58a6ff; }
.callout-success { border-color: #3fb950; }
.callout-warning { border-color: #d29922; }
.callout-danger  { border-color: #f85149; }

.callout strong {
    display: block;
    margin-bottom: 0.25rem;
}

.callout-info strong    { color: #58a6ff; }
.callout-success strong { color: #3fb950; }
.callout-warning strong { color: #d29922; }
.callout-danger strong  { color: #f85149; }
```

## Terminal Output

```css
.terminal {
    background: #0d1117;
    border: 1px solid #30363d;
    border-radius: 8px;
    margin: 1rem 0;
    overflow: hidden;
}

.terminal-header {
    background: #161b22;
    padding: 0.4rem 1rem;
    font-size: 0.75rem;
    color: #8b949e;
    border-bottom: 1px solid #30363d;
}

.terminal pre {
    background: transparent;
    border: none;
    border-radius: 0;
    margin: 0;
    padding: 1rem;
}

.terminal .prompt { color: #3fb950; }
.terminal .output { color: #8b949e; }
.terminal .success { color: #3fb950; font-weight: 700; }
.terminal .error { color: #f85149; font-weight: 700; }
```

## Tag Pills

```css
.tags {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
    margin: 0.75rem 0;
}

.tag {
    background: #21262d;
    color: #8b949e;
    padding: 0.2rem 0.6rem;
    border-radius: 20px;
    font-size: 0.75rem;
}
```

## Step-by-Step Flow

```css
.steps {
    margin: 1.5rem 0;
}

.step {
    display: flex;
    gap: 1.25rem;
    margin-bottom: 1.5rem;
    position: relative;
}

.step-number {
    width: 36px;
    height: 36px;
    background: #58a6ff;
    color: #0d1117;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    flex-shrink: 0;
}

/* Connecting line between steps */
.step:not(:last-child)::after {
    content: "";
    position: absolute;
    left: 18px;
    top: 36px;
    width: 2px;
    height: calc(100% - 36px + 1.5rem);
    background: #30363d;
}

.step-content {
    flex: 1;
    min-width: 0;
}

.step-content h3 {
    margin-top: 0.3rem;
}
```

## Pipeline Diagram

```css
.pipeline {
    display: flex;
    align-items: center;
    gap: 0;
    margin: 1.5rem 0;
    overflow-x: auto;
    padding: 1rem 0;
}

.stage {
    background: #161b22;
    border: 2px solid #30363d;
    border-radius: 8px;
    padding: 0.75rem 1.25rem;
    color: #f0f6fc;
    font-weight: 600;
    white-space: nowrap;
}

.stage.active {
    border-color: #58a6ff;
    background: #161b22;
}

.arrow {
    color: #30363d;
    font-size: 1.5rem;
    padding: 0 0.5rem;
    flex-shrink: 0;
}
```

## Q&A Cards

```css
.qa-card {
    background: #161b22;
    border: 1px solid #30363d;
    border-radius: 8px;
    margin: 0.75rem 0;
}

.qa-card summary {
    color: #58a6ff;
    font-style: italic;
    font-size: 1.05rem;
}

.qa-card .answer {
    padding: 0 1.25rem 1rem;
    color: #c9d1d9;
    line-height: 1.7;
}
```

## Index Page Cards

```css
.cards {
    display: flex;
    flex-direction: column;
    gap: 1rem;
}

.card {
    display: block;
    background: #161b22;
    border: 1px solid #30363d;
    border-radius: 12px;
    padding: 1.5rem 2rem;
    text-decoration: none;
    color: inherit;
    transition: all 0.2s ease;
    position: relative;
    overflow: hidden;
}

.card:hover {
    border-color: #58a6ff;
    transform: translateY(-2px);
    box-shadow: 0 4px 20px rgba(88, 166, 255, 0.1);
}

.card-number {
    position: absolute;
    top: 1rem;
    right: 1.5rem;
    font-size: 3rem;
    font-weight: 800;
    color: #21262d;
    line-height: 1;
}

.card h2 {
    color: #58a6ff;
    font-size: 1.3rem;
    margin-bottom: 0.5rem;
}

.card p {
    color: #8b949e;
    line-height: 1.5;
}
```

## Tables

```css
table {
    width: 100%;
    border-collapse: collapse;
    margin: 1rem 0;
}

th {
    background: #161b22;
    color: #f0f6fc;
    text-align: left;
    padding: 0.75rem 1rem;
    border-bottom: 2px solid #30363d;
}

td {
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #21262d;
}

tr:hover {
    background: #161b22;
}
```

## Navigation

```css
.nav {
    display: flex;
    justify-content: space-between;
    margin: 2rem 0;
    padding: 1rem 0;
    border-top: 1px solid #30363d;
}

.nav a {
    color: #58a6ff;
    text-decoration: none;
}

.nav a:hover {
    text-decoration: underline;
}
```

## Responsive Breakpoint

```css
@media (max-width: 768px) {
    body { padding: 1rem; }
    h1 { font-size: 1.8rem; }
    h2 { font-size: 1.3rem; }
    .comparison { grid-template-columns: 1fr; }
    .pipeline { flex-wrap: wrap; justify-content: center; }
    .card-number { display: none; }
}
```
