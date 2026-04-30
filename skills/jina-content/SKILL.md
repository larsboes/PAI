---
name: jina-content
description: Free web content extraction via Jina AI Reader. Extract any URL to clean markdown - no API key, no cost, no browser required.
---

<!--
🌐 COMMUNITY SKILL

Part of the PAI open skills collection.
- License: MIT

Contributions welcome via GitHub issues and PRs.
Last synced: 2026-02-18 21:06:30
-->

# Jina Content Extractor

**100% free** web content extraction using Jina AI Reader. No API key, no browser, no cost.

## Extract URL to Markdown

```bash
${CLAUDE_SKILL_DIR}/jina.js https://example.com/article      # Any URL to clean markdown
${CLAUDE_SKILL_DIR}/jina.js https://docs.python.org/3/library/asyncio.html
```

## Features

- **Free**: No API key required
- **Fast**: ~200ms response time
- **Clean**: Returns well-formatted markdown
- **Universal**: Works with docs, articles, GitHub, blogs
- **No limits**: Normal usage has no rate limits

## Output Format

```markdown
Title: Page Title
URL Source: https://example.com/article

Markdown Content:
# Article Heading

Article content in clean markdown...
```

## When to Use

| Scenario | Tool |
|----------|------|
| Read documentation | `jina.js <docs-url>` |
| Extract article content | `jina.js <article-url>` |
| Get GitHub README as markdown | `jina.js <repo-url>` |
| Parse blog posts | `jina.js <blog-url>` |

## Examples

```bash
# Python docs
${CLAUDE_SKILL_DIR}/jina.js https://docs.python.org/3/library/asyncio.html

# Rust book
${CLAUDE_SKILL_DIR}/jina.js https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html

# GitHub repo
${CLAUDE_SKILL_DIR}/jina.js https://github.com/tokio-rs/tokio

# MDN documentation
${CLAUDE_SKILL_DIR}/jina.js https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await
```

## Limitations

- **No search**: This extracts content from known URLs only (use other tools for discovery)
- **Requires URL**: You need the exact URL, cannot search by keywords
- **JS-heavy sites**: Some SPAs may not render fully (rare)

