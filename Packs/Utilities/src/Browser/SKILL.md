---
name: Browser
description: "Browser automation and visual verification via Playwright — headless or headed Chrome. Use when taking screenshots, debugging web UIs, automating web interactions, or verifying frontend behavior."
version: 3.3.0
---

# Browser v3.3.0 — CLI-First Browser Automation

**`playwright-cli` first. Agents only when reasoning is needed. Stories and Recipes for composable automation.**

---

## Workflow Routing (READ THIS FIRST)

| Trigger Words | Workflow | What It Does |
|--------------|----------|-------------|
| "review stories", "run stories", "ui review", "validate stories" | `Workflows/ReviewStories.md` | Fan out YAML stories to parallel UIReviewers |
| "automate", "recipe", "template", or a recipe name | `Workflows/Automate.md` | Load and execute a parameterized recipe template |
| "update", "check version" | `Workflows/Update.md` | Verify browser tools are current and working |

If the user's request matches a trigger above, route to that workflow. Otherwise, use the decision tree below.

---

## CLI-First Decision Tree

Every browser task enters this tree. Pick the FIRST match:

| Task | Tool | Time | Tokens | Cost |
|------|------|------|--------|------|
| **Multi-step interaction** (navigate, click, fill, assert) | `playwright-cli -s=<name>` | ~3s | 0 | Free |
| **Screenshot a URL** | `bunx playwright screenshot "<url>" <file>` | ~2s | 0 | Free |
| **Save page as PDF** | `bunx playwright pdf <url> <file>` | ~2s | 0 | Free |
| **Dump page HTML** | Chrome `--headless=new --dump-dom <url>` | ~1s | 0 | Free |
| **Check if page loads** | `curl -sf <url> > /dev/null` | <1s | 0 | Free |
| **Verify after code change** | `playwright-cli` or `bunx playwright screenshot` + Read | ~3s | 0 | Free |
| **Extract text content** | `playwright-cli -s=<name> snapshot` | ~2s | 0 | Free |
| **AI-driven multi-step interaction** (needs reasoning about what to do) | BrowserAgent | ~30s | ~30K | ~$0.09 |
| **Structured test validation** (user stories with assertions) | UIReviewer | ~30s | ~30K | ~$0.09 |
| **Parallel page checks** (8+ pages) | Multiple BrowserAgents | ~30s | ~30K each | Scales |
| **Authenticated session** (SSO, cookies, extensions) | Headed Chrome via `claude --chrome` | ~6s | 0 | Free |

**The rule:** `playwright-cli` handles most multi-step work for FREE. BrowserAgent costs 30K tokens — only pay for it when you need AI decision-making about what to click/type next.

---

## Philosophy

Browser automation should use standard CLI tools, not custom code. `playwright-cli` provides named sessions with ref-based interaction for multi-step work. `bunx playwright` handles one-shot screenshots and PDFs. BrowserAgent provides AI reasoning for complex tasks. No custom code to maintain.

**Headless by default.** All automation runs headless. When the user says "show me", open the URL in their preferred browser from `~/.claude/PAI/USER/TECHSTACKPREFERENCES.md`:

```bash
open -a "$BROWSER" "<url>"  # BROWSER from tech stack prefs
```

---


## Quick Reference: Common Commands

```bash
# Screenshot
playwright screenshot https://example.com screenshot.png --full-page

# Click + Screenshot (single action)
playwright screenshot https://example.com --click="button.submit" after-click.png

# PDF export
playwright pdf https://example.com output.pdf

# Accessibility snapshot (token-efficient)
playwright screenshot https://example.com --accessibility-snapshot
```

## Deep References

| Reference | Content |
|-----------|---------|
| `references/tiers.md` | Full tier 1-3 details: playwright-cli, BrowserAgent, headed Chrome |
| `references/patterns.md` | Accessibility snapshots, debugging workflow, stories, recipes |

## Output
- Produces: Screenshots (PNG), PDFs, accessibility snapshots, or automated action results
- Format: Image files or structured text output
