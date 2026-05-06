## Accessibility Snapshots (Token-Efficient Browsing)

The `playwright-cli snapshot` command returns a structured accessibility tree. This is:
- **Zero tokens** — runs as a CLI command, no AI needed
- **Machine-readable** — elements have refs you can click/fill directly
- **Better for content extraction** — structured text, not pixels

Use snapshots when you need to read page content or interact with elements. Use screenshots when you need visual verification.

---

## Debugging Workflow

**Scenario: "Why isn't the user list loading?"**

**Step 1 (CLI — free):**
```bash
# Quick check: does the page load at all?
curl -so /dev/null -w "%{http_code}" "http://myapp.com/users"

# Visual check
playwright-cli -s=debug open http://myapp.com/users --persistent
playwright-cli -s=debug screenshot --filename=/tmp/debug.png
playwright-cli -s=debug snapshot  # Check page structure
playwright-cli -s=debug close
```

**Step 2 (only if CLI isn't enough — 30K tokens):**
```
Task(subagent_type="BrowserAgent", prompt="
  Navigate to http://myapp.com/users.
  Take a screenshot.
  Check console for errors.
  Check network requests for failed calls (4xx, 5xx).
  Summarize: what's working, what's broken.
")
```

---

---

## Stories — YAML User Story Validation

Define user stories in YAML format and validate them in parallel with UIReviewer agents.

**Directory:** `skills/Utilities/Browser/Stories/`

```yaml
name: App Name
url: https://example.com
stories:
  - name: Story name
    steps:
      - action: click
        target: "LLM-readable description"
    assertions:
      - type: snapshot_contains
        text: "expected text"
```

Run with: `"review stories"` or `"run stories in HackerNews.yaml"`

See `Stories/README.md` for full format documentation.

---

## Recipes — Parameterized Workflow Templates

Reusable Markdown templates with `{PROMPT}` injection and frontmatter defaults.

**Directory:** `skills/Utilities/Browser/Recipes/`

| Recipe | Description | Tool |
|--------|-------------|------|
| `SummarizePage.md` | Navigate to URL and extract content summary | BrowserAgent |
| `ScreenshotCompare.md` | Before/after screenshot comparison | playwright-cli |
| `FormFill.md` | Fill form fields with provided data | playwright-cli |

Run with: `"automate SummarizePage for https://example.com"`

See `Recipes/README.md` for full format documentation.

---

**Last Updated:** 2026-02-17
