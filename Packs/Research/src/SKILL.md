---
name: Research
description: "Multi-mode research system — quick (1 agent), standard (3 agents), extensive (12 agents), or deep investigation (iterative). Use when researching topics, finding information, or analyzing content at any depth level."
---

## Modes

| Request | Mode |
|---------|------|
| "research" / "do research" | Standard (3 agents) |
| "quick research" | Quick (1 agent) |
| "extensive research" / "deep research" | Extensive (12 agents) |
| "deep investigation" / "investigate" | Deep Investigation (iterative) |
| "quick research" / "minor research" | → Quick mode (1 agent) |
| "extensive research" / "deep research" | → Extensive mode (12 agents) |
| "deep investigation" / "investigate [topic]" / "map the [X] landscape" | → Deep Investigation (iterative) |

**"Research" alone = Standard mode. No exceptions.**

# Research Skill

Comprehensive research, analysis, and content extraction system.

## MANDATORY: URL Verification

**READ:** `UrlVerificationProtocol.md` - Every URL must be verified before delivery.

Research agents hallucinate URLs. A single broken link is a catastrophic failure.

---

## Workflow Routing

Route to the appropriate workflow based on the request.

**CRITICAL:** For due diligence, company/person background checks, or vetting -> **INVOKE OSINT SKILL INSTEAD**

### Research Modes (Primary Workflows)
- Quick/minor research (1 Perplexity, 1 query) -> `Workflows/QuickResearch.md`
- Standard research - DEFAULT (3 agents: Perplexity + Claude + Gemini) -> `Workflows/StandardResearch.md`
- Extensive research (4 types x 3 threads = 12 agents) -> `Workflows/ExtensiveResearch.md`
- Deep investigation / iterative research (progressive deepening, loop-compatible) -> `Workflows/DeepInvestigation.md`

### Deep Content Analysis
- Extract alpha / deep analysis / highest-alpha insights -> `Workflows/ExtractAlpha.md`

### Content Retrieval
- Difficulty accessing content (CAPTCHA, bot detection, blocking) -> `Workflows/Retrieve.md`
- YouTube URL extraction (use `fabric -y URL` immediately) -> `Workflows/YoutubeExtraction.md`
- Web scraping -> `Workflows/WebScraping.md`

### Specific Research Types
- Claude WebSearch only (free, no API keys) -> `Workflows/ClaudeResearch.md`
- Perplexity API research (use Quick for single-agent) -> `Workflows/QuickResearch.md`
- Interview preparation (Tyler Cowen style) -> `Workflows/InterviewResearch.md`
- AI trends analysis -> `Workflows/AnalyzeAiTrends.md`


### Content Enhancement
- Enhance/improve content -> `Workflows/Enhance.md`
- Extract knowledge from content -> `Workflows/ExtractKnowledge.md`

---

## Quick Reference

**READ:** `QuickReference.md` for detailed examples and mode comparison.

| Trigger | Mode | Speed |
|---------|------|-------|
| "quick research" | 1 Perplexity agent | ~10-15s |
| "do research" | 3 agents (default) | ~15-30s |
| "extensive research" | 12 agents | ~60-90s |
| "deep investigation" | Progressive iteration | ~3-60min |

---

## Integration

### Feeds Into
- **blogging** - Research for blog posts
- **newsletter** - Research for newsletters
- **xpost** - Create posts from research

### Uses
- **be-creative** - deep thinking for extract alpha
- **OSINT** - MANDATORY for company/people comprehensive research
- **BrightData MCP** - CAPTCHA solving, advanced scraping
- **Apify MCP** - RAG browser, specialized site scrapers

---

## Deep Investigation Mode

**Progressive iterative research** that builds a persistent knowledge vault. Works in both single-run (one cycle) and loop mode (Algorithm-driven iterations).

**Concept:** Broad landscape → discover entities → score importance/effort → deep-dive one at a time → loop until coverage complete.

**Domain template packs** customize the investigation for specific domains:
- `Templates/MarketResearch.md` — Companies, Products, People, Technologies, Trends, Investors
- `Templates/ThreatLandscape.md` — Threat Actors, Campaigns, TTPs, Vulnerabilities, Tools, Defenders
- No template? The workflow creates entity categories dynamically from the landscape research.

**Example invocation:**
```
"Do a deep investigation of the AI agent market"
→ Loads MarketResearch.md template
→ Iteration 1: Broad landscape + first entity deep-dive
→ Loop mode: Each iteration deep-dives the next highest-priority entity
→ Exit: When all CRITICAL/HIGH entities researched + all categories covered
```

**Artifacts persist** at `~/.claude/MEMORY/RESEARCH/{date}_{topic}/` — the vault survives across sessions.

See `Workflows/DeepInvestigation.md` for full workflow details.

---

## File Organization

**Working files (temporary work artifacts):** `~/.claude/MEMORY/WORK/{current_work}/`
- Read `~/.claude/MEMORY/STATE/current-work.json` to get the `work_dir` value
- All iterative work artifacts go in the current work item directory
- This ties research artifacts to the work item for learning and context

**History (permanent):** `~/.claude/History/research/YYYY-MM/YYYY-MM-DD_[topic]/`
