---
name: MailCraft
description: "Use when composing, reviewing, or restructuring business emails — direct style, minimal softeners, structured clarity. USE WHEN draft email, write email, review email, email tone, business email, compose email, email structure, mail, corporate communication, email draft."
---

# MailCraft

## When to Use

- Drafting emails from messy bullet points or notes
- Reviewing drafts for tone, softeners, and structural clarity
- Creating emails for recurring patterns (access requests, status updates, escalations)
- Adapting tone between cold contacts (strict) and known colleagues (warmer)
- Flagging excessive formality or hedging language

## Red Flags

- Excessive softeners that signal uncertainty: "maybe", "if you have time", "only if possible"
- Ask-before-context structure (reader doesn't know why you're writing)
- Missing timeline (no urgency signal)
- No escape hatch (what if they're the wrong contact?)
- Excessive apologies in cold emails
- Wall-of-text questions instead of numbered items

## Overview

Your email voice: **Direct and clear** — engineering precision without corporate fluff. Known contacts get warmth; strangers get clarity without excessive softeners.

Match the formality level of the environment — but always prefer direct over vague.

## Modes

### 1. `/mail-craft draft`

Transform bullet points or messy notes into a polished email.

**Input formats:**
- Raw bullet dump
- "Tell X about Y, need Z by date"
- Partial draft that needs restructuring

**Process:**
1. **Anchor**: Name referral/context first sentence
2. **Context Block**: 2-3 sentences — who you are, what you want, who's involved
3. **Constraints**: What's NOT relevant (reduces reader cognitive load)
4. **Ask**: Numbered questions, max 4 items
5. **Close**: Timeline + one escape hatch

**Flags:**
- `--friendly`: Soften tone (for known contacts)
- `--urgent`: Priority flag without panic language
- `--escalate`: Manager loop, firmer structure

---

### 2. `/mail-craft review`

Score draft against direct communication criteria.

**Checks:**
| Criterion | Good Example | Flag |
|-----------|--------------|------|
| Minimal softeners | "When is X ready?" | ⚠️ "Would you be so kind as to..." |
| Numbered asks | "1. Budget? 2. Timeline?" | ⚠️ Wall-of-text paragraph |
| Context up front | "I'm [role], need [thing]" | ❌ Ask before context |
| Appropriate warmth | emoji with known contacts | ❌ excessive emoji in cold email |
| Escape hatch present | "If not you, who should I ask?" | ⚠️ Dead-end ask |

**Output:** Inline diff + score 0-100%.

---

### 3. `/mail-craft template`

Pre-built structures for recurring patterns.

**Available templates:**

#### `tool-access`
For requesting tool access or endpoint evaluation.
```
→ POC request: [Tool] for [Use Case]
→ Current blocker: [Specific limitation]
→ Alternative considered: [X], rejected because [Y]
→ Risk mitigation: [What you've done]
→ Timeline: [Date]
```

#### `status-update`
For stakeholder async updates.
```
→ Subject: [Project] — Status [Date]
→ Done: 2-3 bullets with outcomes
→ Blocked: Specific blocker + who can unblock
→ Next: Concrete next step + owner
→ Need from you: Specific ask or FYI
```

#### `coordination`
For cross-team sync requests.
```
→ Goal: [Specific outcome]
→ My input: [What you bring]
→ Your input: [What you need from them]
→ When: [Specific slots or async]
```

#### `escalation`
For manager loop when blocked.
```
→ Blocker: [Specific technical/approval issue]
→ Tried: [What you did, who you asked]
→ Impact: [What slips if not resolved]
→ Options: [A or B, your recommendation]
→ Decision needed by: [Date]
```

---

## Style Rules

### Do
- Start with anchor (referral, previous message, shared context)
- 2-3 sentence context block max
- Explicit "Not relevant" section
- Numbered questions, nested sub-questions if needed
- One clear timeline/deadline
- Single escape hatch (wrong recipient?)

### Don't
| Softener | Replace With |
|----------|--------------|
| "Would you maybe..." | "When is X done?" |
| "I would be very grateful..." | "I need X by Y." |
| "If it were possible..." | "Can you do this by X?" |
| Excessive emoji (cold emails) | Nothing, or name-specific |
| "Sorry to bother you" | Nothing |

### Emoji Policy
- ❌ Cold emails to new contacts
- ❌ Security requests, procurement, legal
- ✅ Known colleagues who use them
- ✅ Internal team updates

---

## Usage Flow

```
# Draft from notes
/mail-craft draft "Ask Sarah about the API endpoint..."

# Review before sending
/mail-craft review "[paste your draft]"

# Grab template structure
/mail-craft template tool-access

# Friendly mode for known colleague
/mail-craft draft --friendly "Quick update for Andreas..."
```
