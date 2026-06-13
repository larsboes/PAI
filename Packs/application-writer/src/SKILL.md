---
name: application-writer
description: "Draft applications for CFPs, fellowships, scholarships, grants — pulls context from the vault to personalize. USE WHEN write application, draft application, CFP, call for papers, fellowship application, scholarship, grant application, apply for, personal statement, motivation letter."
allowed-tools: Read, Write, Glob, WebFetch
---

# Application Writer Skill

Orchestrates drafting applications for opportunities (CFPs, fellowships, scholarships, etc.).

## When to Use

- User wants to apply for a conference CFP
- User found a fellowship/scholarship to apply for
- User needs help with speaker proposal
- User says "help me apply", "draft application", "write proposal"

## Workflow

### 1. Understand the Opportunity

Either:
- User provides details directly, OR
- Delegate to `opportunity-researcher` agent to gather requirements

Key info needed:
- Deadline
- Requirements/criteria
- Word limits
- Specific questions to answer
- What they're looking for

### 2. Gather Context from Vault

Load personal context (PERSONAL_CONTEXT.md or memory skill) for the user's profile, focus areas, and current projects. Then pull specifics:

**For CFPs/Speaking:**
- Career/visibility focus note from `${VAULT_FOCUS}/` — speaking goals, past talks
- Active projects from `${PROGRESSIVE_CURRENT}`
- Technical expertise focus note from `${VAULT_FOCUS}/`

**For Fellowships:**
- User's profile from personal context
- Career focus note — career goals
- Personal foundation focus note — values, motivations
- Active projects for proof of work

**For Technical Applications:**
- `${VAULT_RESOURCES}/` — deep knowledge areas
- `${VAULT_PROJECTS}/` — hands-on experience
- Technical focus note from `${VAULT_FOCUS}/`

### 3. Draft the Application

Structure based on opportunity type:

**CFP/Talk Proposal:**
```
Title: [Catchy, specific title]

Abstract: (usually 200-400 words)
- Hook: Why this matters now
- What attendees will learn
- Key takeaways (3 bullets)
- Why the applicant is qualified to give this talk

Outline: (if required)
- Section breakdown with timing

Bio: (50-150 words)
- Relevant experience
- Current role
- Previous speaking (if any)
```

**Fellowship Application:**
```
Personal Statement:
- Who you are
- Why this program
- What you'll contribute
- What you'll gain

Project/Goals: (if required)
- Specific plans
- How fellowship enables them

Impact:
- How this advances your goals
- How you'll give back
```

### 4. Tailor and Polish

- Match the tone of the program (academic vs. startup-y vs. corporate)
- Use specific examples from vault context
- Stay within word limits
- Make it sound like the user, not generic

### 5. Output

Provide:
1. Draft application text
2. Checklist of materials needed
3. Submission deadline reminder
4. Suggested follow-up actions

## Principles

- **Specific > Generic**: Use real project names, real numbers
- **Show don't tell**: "Built X processing Y items" not "experienced in Z"
- **Match their language**: Mirror keywords from the opportunity description
- **Be confident but honest**: Don't overclaim, but don't undersell

## Example

```
User: "Help me apply for [Conference] CFP - I want to talk about [topic]"

1. Research: Check CFP requirements, deadline, audience
2. Context: Pull from relevant project notes and focus area notes
3. Draft:
   Title: "Beyond Chatbots: Building Reliable AI Agent Systems"
   Abstract: [drafted based on the user's actual work]
   Bio: [pulled from vault]
4. Output: Full draft + checklist (bio, headshot, etc.)
```
