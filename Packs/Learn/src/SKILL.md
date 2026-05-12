---
name: learn
description: "Two-phase learning skill. Phase 1: design a structured learning path (goal clarification, phases, resources, milestones). Phase 2: build interactive HTML learning modules. Use when 'teach me X', 'how should I learn X', 'explain', 'learning module', 'build tutorial'."
argument-hint: "[topic]"
user-invocable: true
---

# Learn

Two phases. Run them in sequence or independently.

**Phase 1 → Plan:** design the learning path
**Phase 2 → Build:** generate interactive HTML modules

Default: run both. If the user says "just plan" or "just build the modules", split accordingly.

---

## Phase 1: Plan the Path

### 1. Clarify the Goal

Ask:
- **What:** Specific skill/topic?
- **Why:** Career goal? Project need? Interest? Build on existing skill?
- **Level:** Beginner to expert, or specific proficiency target?
- **Timeline:** Hard deadline or ongoing?
- **Constraints:** Hours per week available?

### 2. Assess Current State

Pull from context (memory skill if loaded):
- Related projects already built
- Current skill level and learning preferences
- Existing expertise to build on — don't duplicate

Recommended learning style: Theory → Practice → Deeper Theory (spiral). Implement from scratch to understand, then use libraries.

### 3. Design the Path

Use `references/path-template.md` for structure. Standard phases:

| Phase | Goal |
|-------|------|
| Foundations | Core concepts, mental model, terminology |
| Core | Main tools/APIs, common patterns |
| Applied | Real project, production use, integration |
| Advanced | Edge cases, performance, debugging |

Not every topic needs all phases — adjust based on scope and timeline.

### 4. Curate Resources

See `references/resource-guide.md` for evaluation criteria.

Priority order:
1. Official docs (usually best signal-to-noise)
2. Hands-on courses (if kinesthetic learning fits)
3. Books (deep understanding, theory-heavy topics)
4. Videos (visual concepts, architecture overviews)
5. Projects (integration, portfolio)

**Recommended default:** Start with docs + build early. Go deeper as needed. Avoid tutorial hell.

### 5. Set Success Criteria

Every path ends with:
- "Can explain X without notes"
- "Can build Y without looking up basics"
- "Can evaluate Z objectively"
- A portfolio project showing what was learned

### Plan Red Flags

- No project or concrete outcome → too abstract
- No timeline or milestones → will drift
- All resources, no practice → passive learning
- Doesn't connect to existing knowledge → isolated learning
- Too ambitious for timeline → will burn out

### Principles

- **Just-in-time > Just-in-case** — learn what you need for the next step
- **Build early** — don't wait until ready
- **Spaced repetition** — plan review points, not just consumption
- **Output-focused** — every phase has tangible output
- **Depth > Breadth** — go deep on what matters

---

## Phase 2: Build the Modules

Generate self-contained interactive HTML learning modules. Prose in user's preferred language (`${CONTENT_LANG}`), English code. No external dependencies.

### Workflow

1. **Scope** — topic, audience level, how many modules?
2. **Structure** — plan progressive complexity: Basics → Applied → Advanced → Bridge
3. **Build** — one HTML per module, parallel agents if multiple
4. **Index** — card-based navigation page linking all modules
5. **Review** — does a complete beginner reach discussion-readiness?

### Page Structure

```
DOCTYPE html, lang="${CONTENT_LANG}"
├── <head>: charset UTF-8, viewport, inline <style>
├── <body>
│   ├── Navigation (${NAV_BACK} / ${NAV_NEXT})
│   ├── Title + subtitle
│   ├── Table of Contents (anchor links)
│   ├── Sections (collapsible where deep)
│   └── Navigation (repeated at bottom)
└── No external CSS, JS, fonts, or CDN
```

### Color Tokens

```css
--bg-primary: #0d1117;
--bg-card: #161b22;
--bg-elevated: #21262d;
--border: #30363d;
--text-primary: #c9d1d9;
--text-heading: #f0f6fc;
--text-muted: #8b949e;
--accent: #58a6ff;
--green: #3fb950;
--red: #f85149;
--yellow: #d29922;
```

Font: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`
Code: `'SF Mono', SFMono-Regular, Consolas, Menlo, monospace`

### Interactive Components

CSS-only. Minimal vanilla JS only if absolutely necessary.

**Collapsible:** `<details><summary>...</summary>...</details>`

**Tabs:** CSS radio-input trick (see `references/css-components.md`)

**Correct/Incorrect comparison:** Side-by-side divs, green border = correct, red = incorrect

**Q&A Cards:** `<details class="qa-card">` for discussion prep ("${QA_FRAME}")

**Terminal output:** `<div class="terminal">` with header + `<pre>` block

**Callouts:** `<div class="callout callout-warning|info|danger|success|tip">`

**Step-by-step flow:** Numbered step boxes with content + code at each stage

**Pipeline diagrams:** CSS flexbox boxes + arrows, no SVG unless complex routing

Full component CSS: `references/css-components.md`

### Content Patterns

**Progressive complexity per module:**
1. Foundations — what is X, core concepts, mental model
2. Application — how to use X, practical examples
3. Testing/Validation — how to verify X works
4. Integration — X in CI/CD, production, team
5. Advanced — edge cases, performance, debugging
6. Bridge — connect X to the user's specific project/context

**Data walkthrough:** trace ONE concrete item through the entire system step by step. Show actual data at each transformation point. Most powerful teaching tool.

**Side-by-side:** correct vs. incorrect, before vs. after, old vs. new. Always label + color-code.

**Discussion prep:** Q&A cards framed as "${QA_FRAME}" — cover obvious objections first.

### Index Page

Every set of modules gets `index.html` with card-based navigation:

```html
<a href="01-basics.html" class="card">
  <span class="card-number">01</span>
  <h2>Title</h2>
  <p>Description</p>
  <div class="tags"><span class="tag">topic</span></div>
</a>
```

Cards: hover border-color change + slight translateY + box-shadow.

### Language Rules

- **`${CONTENT_LANG_LABEL}`** for all prose, headings, callouts, questions
- **English** for code, commands, config files, commonly-English technical terms
- Product names stay English: FluentBit, Docker, GitLab CI
- Use proper characters for the content language (e.g., ü, ä, ö — never ae, oe, ue)

### Parallelization

Multiple modules → parallel Agent calls, one per module. Each agent gets:
- Full content spec for its module
- Design system (colors, fonts, components from this SKILL.md)
- Navigation links to adjacent modules
- Instruction to match styling exactly

After all agents finish → build/update index.html.

### Build Red Flags

- "I'll use a CDN" → No. Self-contained.
- "Let me add React" → No. CSS-only.
- "I'll write explanations in English" → No. Prose in ${CONTENT_LANG_LABEL}, code in English.
- "One giant HTML for everything" → No. One module per file.
- "Skip the index page" → No. Always card-based navigation.

---

## References

- [path-template.md](references/path-template.md) — phased learning path structure with real examples
- [resource-guide.md](references/resource-guide.md) — how to evaluate and curate quality resources
- [css-components.md](references/css-components.md) — complete CSS for all HTML components (copy-paste ready)
