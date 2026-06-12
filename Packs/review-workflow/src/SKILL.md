---
name: review-workflow
description: Structured process for weekly, monthly, and yearly reviews. Guides reflection and planning.
allowed-tools: Read, Write, Glob
---

# Review Workflow Skill

Structured process for periodic reviews (weekly/monthly/yearly). Pulls data from the vault, guides reflection, and creates review notes.

## When to Use

- End of week reflection
- Monthly planning
- Year-end review
- User says "review", "reflect", "plan the week/month"

## Before Starting

1. **Offer brain-dump first:** "Do you want to `/brain-dump` anything before we start the review?"
2. **Load progressive-context** for focus area status and current themes

## Review Types

### Weekly Review
**Location:** `${VAULT_WEEKLY_REVIEWS}/`
**Template:** `${VAULT_WEEKLY_TEMPLATE}`

### Monthly Review
**Location:** `${VAULT_MONTHLY_REVIEWS}/`
**Template:** `${VAULT_MONTHLY_TEMPLATE}`

### Yearly Review
**Location:** `${VAULT_YEARLY_REVIEWS}/`
**Template:** `${VAULT_YEARLY_TEMPLATE}`

## Process (All Review Types)

### 1. Gather Data

Read the source material for the review period. For specific data sources and prompts per review type, reference: `review-workflow/review-questions.md`

### 2. Present Findings

Before asking questions, present what you found:
- Summary of activity (what got done, what didn't)
- Pattern observations (recurring themes, behavioral patterns from progressive-context)
- Focus area balance (which focuses got attention, which were neglected)

### 3. Guide Reflection

Work through the review prompts from `review-questions.md`, one section at a time. Don't dump all questions at once.

### 4. Create Review Note

Read the relevant template, then create the review note with:
- Structured sections matching the template
- `[[wikilinks]]` to relevant notes reviewed
- Clear action items for next period
- Updated priorities if changed
- Pattern observations linked to `${VAULT_REFLECTIONS}/` files

### 5. Update Current Context

After the review, update `${PROGRESSIVE_CURRENT}` with:
- New priorities
- Shifted emotional themes
- Updated project statuses

## Integration

- **progressive-context**: For focus area status, pattern index, current themes
- **brain-dump**: Offer before review for pre-processing
- **focus-alignment**: Run balance assessment as part of monthly/yearly reviews
- **google-calendar MCP**: Pull past events for the review period
