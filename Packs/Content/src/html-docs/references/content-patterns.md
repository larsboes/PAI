# Content Patterns Reference

What content goes on each page type. Follow the progressive disclosure pattern:
**Cards → Headers → `<details>` → Tables/Code**

## Page Types

### Architecture / Overview (`index.html`)

The landing page. Answers: "What is this and how is it structured?"

```
1. Card grid: Core principles / design decisions (3-4 cards)
2. Mermaid diagram: Bounded contexts / module relationships
3. Mermaid diagram: Dependency rule / layer flow
4. Mermaid diagram: Data flow pipeline
5. Collapsible ADRs (Architecture Decision Records)
6. Status table with badges (Done / Pending / In Progress)
7. Callout box linking to PRD or roadmap
```

**Example card grid:**
```html
<div class="card-grid">
  <div class="card">
    <h4>Clean Architecture</h4>
    <p>Dependency direction flows inward: <code>ui/ → adapters/ → core/</code>.</p>
  </div>
  <div class="card">
    <h4>Ports & Adapters</h4>
    <p>All external I/O goes through interface contracts.</p>
  </div>
</div>
```

**Example ADR:**
```html
<details>
  <summary>ADR-0001: Hexagonal Architecture</summary>
  <div class="details-content">
    <p>Decision explanation.</p>
    <p><strong>Consequence:</strong> Impact statement.</p>
  </div>
</details>
```

**Example status table:**
```html
<table>
  <thead><tr><th>Phase</th><th>Goal</th><th>Status</th></tr></thead>
  <tbody>
    <tr><td>Phase 1</td><td>Description</td><td><span class="badge badge-green">Done</span></td></tr>
    <tr><td>Phase 2</td><td>Description</td><td><span class="badge badge-yellow">Pending</span></td></tr>
  </tbody>
</table>
```

---

### Features (`features.html`)

Answers: "What can this thing do?"

```
1. Card grid: Output formats / key capabilities (3-4 cards)
2. Collapsible details per feature group
3. Comparison tables inside details (backends, parsers, etc.)
4. Code example at the bottom (quick start)
```

**Feature detail pattern:**
```html
<details>
  <summary>Feature Name</summary>
  <div class="details-content">
    <p>Description.</p>
    <table>
      <thead><tr><th>Option</th><th>Strength</th><th>Use When</th></tr></thead>
      <tbody>
        <tr><td><code>option-a</code></td><td>Fast</td><td>Default</td></tr>
        <tr><td><code>option-b</code></td><td>Thorough</td><td>Edge cases</td></tr>
      </tbody>
    </table>
  </div>
</details>
```

---

### Components (`components.html`)

Answers: "What modules exist and where do they live?"

```
1. Mermaid diagram: Layer overview (UI → Adapters → Core)
2. Collapsible section per architectural layer
3. Tables inside: Module | Type | Responsibility
4. h4 subheadings for sub-groups within a layer
5. Composition root / wiring documentation at the bottom
```

**Module catalog pattern:**
```html
<details>
  <summary>domain/ — Business Rules</summary>
  <div class="details-content">
    <h4>sub-package/ — Context Name</h4>
    <table>
      <thead><tr><th>Module</th><th>Type</th><th>Responsibility</th></tr></thead>
      <tbody>
        <tr><td><code>entity.py</code></td><td>Entity</td><td>Core business entity</td></tr>
        <tr><td><code>value_objects.py</code></td><td>Value Objects</td><td>Immutable data</td></tr>
        <tr><td><code>service.py</code></td><td>Domain Service</td><td>Business logic</td></tr>
      </tbody>
    </table>
  </div>
</details>
```

---

### Configuration (`config.html`)

Answers: "How do I configure / use this?"

```
1. File tree: Config file structure
2. Collapsible sections per config file (full YAML/JSON reference)
3. CLI arguments table: Flag | Description | Default
4. Environment variables table: Variable | Description
5. Programmatic API code block
6. Defaults summary table
7. Troubleshooting: collapsible sections with Issue | Solution tables
8. Debug mode instructions
```

**Config reference pattern:**
```html
<h3>config-file.yaml</h3>
<p>Brief description.</p>
<details>
  <summary>Full reference</summary>
  <div class="details-content">
    <pre><code># YAML content with comments
key: value  # explanation</code></pre>
  </div>
</details>
```

**Troubleshooting pattern:**
```html
<details>
  <summary>Category Name</summary>
  <div class="details-content">
    <table>
      <thead><tr><th>Issue</th><th>Solution</th></tr></thead>
      <tbody>
        <tr><td>Error message</td><td>Fix instructions</td></tr>
      </tbody>
    </table>
  </div>
</details>
```

---

## Additional Page Types

### API Reference
Like Components but organized by endpoint/function instead of module.

### Guides / How-To
Step-by-step sections with code blocks. Use numbered `<h3>` headings.

### Changelog
Reverse-chronological. Collapsible per version. Badges for `Added`, `Changed`, `Fixed`, `Removed`.

### FAQ
`<details>` for each question. No tables needed.

---

## Element Decision Guide

| Content Type | Element | Why |
|---|---|---|
| 3-4 key concepts | Card grid | Scannable at a glance |
| Module/flag/setting list | Table | Structured, sortable |
| Longer explanation | `<details>` | Don't overwhelm |
| Important note | `.callout` | Visually distinct |
| Architecture diagram | `.mermaid` | Interactive, themed |
| Config/code example | `<pre><code>` | Monospace, copyable |
| Status indicator | `.badge` | Compact, color-coded |
| Unfinished section | `.placeholder` | Honest about gaps |
