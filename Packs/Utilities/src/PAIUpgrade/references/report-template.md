## Primary Output Format

**Discoveries first. Recommendations second. Technique details third.**

The output has THREE major sections:
1. **Discoveries** — Everything found, ranked by interestingness, showing source and PAI relevance at a glance
2. **Recommendations** — What to actually integrate, organized by priority tier
3. **Technique Details** — Full extraction with code examples and implementation steps

```markdown
# PAI Upgrade Report
**Generated:** [timestamp]
**Sources Processed:** [N] release notes parsed | [N] videos checked | [N] docs analyzed | [N] GitHub queries run
**Findings:** [N] techniques extracted | [N] content items skipped

---

## ✨ Discoveries

Everything interesting we found, ranked by how compelling it is for PAI. This is the "what's out there" overview.

| # | Discovery | Source | Why It's Interesting | PAI Relevance |
|---|-----------|--------|---------------------|---------------|
| 1 | [Name of thing found] | [GitHub release / YouTube video / Docs / Blog] | [1-2 sentences: what makes this cool or notable] | [1 sentence: how it maps to PAI] |
| 2 | ... | ... | ... | ... |
| ... | ... | ... | ... | ... |

**Ranking rule:** Sort by interestingness — the most "whoa, that's cool" discoveries go at the top. This is NOT the same as implementation priority (that's the Recommendations section below). A LOW-priority awareness item can still be the most interesting discovery.

---

## 🔥 Recommendations

What to actually DO with these discoveries, organized by urgency and impact.

### 🔴 CRITICAL — Integrate immediately

These fix gaps, security issues, or unlock capabilities that PAI should already have.

| # | Recommendation | PAI Relevance | Effort | Files Affected |
|---|---------------|---------------|--------|----------------|
| 1 | [Short action name] | [Why this matters for PAI — what gap it fills or what breaks without it] | [Low/Med/High] | `[file1]`, `[file2]` |

### 🟠 HIGH — Integrate this week

These significantly improve PAI's capabilities or efficiency.

| # | Recommendation | PAI Relevance | Effort | Files Affected |
|---|---------------|---------------|--------|----------------|
| 2 | [Short action name] | [Which PAI component improves and how] | [Low/Med/High] | `[file1]` |

### 🟡 MEDIUM — Integrate when convenient

These add useful capabilities or align PAI with ecosystem best practices.

| # | Recommendation | PAI Relevance | Effort | Files Affected |
|---|---------------|---------------|--------|----------------|
| 3 | [Short action name] | [What becomes possible for PAI] | [Low/Med/High] | `[file1]` |

### 🟢 LOW — Awareness / future reference

These are nice-to-know or will become relevant later.

| # | Recommendation | PAI Relevance | Effort | Files Affected |
|---|---------------|---------------|--------|----------------|
| 4 | [Short action name] | [Why to keep this on the radar] | [Low/Med/High] | `[file1]` |

---

## 🎯 Technique Details

Full extracted techniques for reference. Each recommendation above maps to one or more techniques below.

### From Release Notes

#### [N]. [Feature/Change Name]
**Source:** GitHub claude-code v2.1.16, commit abc123
**Priority:** 🔴 CRITICAL | 🟠 HIGH | 🟡 MEDIUM | 🟢 LOW

**What It Is (16-32 words):**
[Describe the technique itself - what it does, how it works, what capability it provides. Must be 16-32 words, concrete and specific.]

**How It Helps PAI (16-32 words):**
[Describe the specific benefit to our PAI system - which component improves, what gap it fills, what becomes possible. Must be 16-32 words.]

**The Technique:**
> [Exact code pattern, configuration, or approach - quoted or code-blocked]

**Applies To:** `hooks/SecurityValidator.hook.ts`, ISC verification
**Implementation:**
```typescript
// Before (what you have now)
[current pattern]

// After (with this technique)
[new pattern]
```

---

### From YouTube Videos

#### [N]. [Specific Technique Name]
**Source:** R Amjad - "Video Title" @ 12:34
**Priority:** 🔴 CRITICAL | 🟠 HIGH | 🟡 MEDIUM | 🟢 LOW

**What It Is (16-32 words):**
[Describe the technique itself]

**How It Helps PAI (16-32 words):**
[Describe the specific benefit]

**The Technique:**
> "[Exact quote or paraphrased technique from transcript]"

**Applies To:** Browser skill, delegation system
**Implementation:**
[Specific steps to apply this technique]

---

### From Documentation / Other Sources

#### [N]. [Specific Capability/Pattern]
**Source:** Claude Docs - Tool Use section, updated 2026-01-20
**Priority:** 🔴 CRITICAL | 🟠 HIGH | 🟡 MEDIUM | 🟢 LOW

**What It Is (16-32 words):**
[Describe the technique itself]

**How It Helps PAI (16-32 words):**
[Describe the specific benefit]

**The Technique:**
> [Exact documentation excerpt showing the capability]

**Applies To:** `PAI/SKILL.md`, agent spawning
**Implementation:**
[Specific changes needed]

---

## 📊 Summary

| # | Technique | Source | Priority | PAI Component | Effort |
|---|-----------|--------|----------|---------------|--------|
| 1 | [name] | [source] | 🔴/🟠/🟡/🟢 | [component] | Low/Med/High |

**Totals:** [N] Critical | [N] High | [N] Medium | [N] Low | [N] Skipped

---

## ⏭️ Skipped Content

| Content | Source | Why Skipped |
|---------|--------|-------------|
| [video/doc title] | [source] | [No extractable technique / Not relevant to PAI / Covers basics already implemented] |

---

## 🔍 Sources Processed

**Release Notes Parsed:**
- claude-code v2.1.14, v2.1.15, v2.1.16 → [N] techniques extracted
- MCP 2025-11-25 → [N] techniques extracted

**Videos Checked:**
- R Amjad: "Title" (23:45) → [N] techniques extracted
- AI Jason: "Title" (15:20) → 0 techniques (skipped: Gemini focus)

**Docs Analyzed:**
- Claude Tool Use docs → [N] techniques extracted
```

---
