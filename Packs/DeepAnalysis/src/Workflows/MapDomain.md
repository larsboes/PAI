# MapDomain Workflow

Running the **MapDomain** workflow in the **DeepAnalysis** skill to map this problem space...

## Overview

Comprehend a problem domain, technology landscape, or conceptual space. Produce a structured map that makes the territory navigable — key concepts, relationships, players, tensions, and where opportunities/dangers live.

---

## When to Use

- "Help me understand the landscape of [technology/domain]"
- "What's the problem space here?"
- "Map out the options and tradeoffs in [area]"
- "I'm new to [domain] — what do I need to know?"

---

## Phase 1: Define the Territory

What are we mapping?

```markdown
**Domain:** [Name/topic]
**Scope:** [What's in vs out — deliberately constrain]
**User's goal:** [Why do they need this map? What decision does it serve?]
**Current knowledge:** [What they already know — don't waste time on basics they have]
```

If the scope is unclear, ask:
> "This is a broad area. Are you interested in [A], [B], or the full landscape? What decision is this serving?"

---

## Phase 2: Research the Space

### 2.1 If Unfamiliar
```
web_search: "[domain] landscape overview 2025/2026"
web_search: "[domain] key concepts and terminology"
code_search: "[domain] popular libraries/tools comparison"
```

### 2.2 If Partially Known
- Identify the gaps in your knowledge
- Research specifically what's new/changed
- Look for non-obvious connections

### 2.3 Source Types
| Source | Gets You |
|--------|----------|
| Overview articles | Structure, key concepts |
| Comparison posts | Tradeoffs, when-to-use |
| GitHub stars/trends | What's actually adopted |
| HN/Reddit discussions | Real-world experience, gotchas |
| Academic papers | Theoretical foundations |

---

## Phase 3: Map the Concepts

### 3.1 Core Concepts
Identify the 5-10 key concepts/entities in the domain:
- What is it? (one sentence definition)
- How does it relate to other concepts?
- What's commonly confused with it?

### 3.2 Concept Relationships

```markdown
## Concept Map

[Concept A] ──uses──▶ [Concept B]
     │                      │
     │inherits              │produces
     ▼                      ▼
[Concept C] ──conflicts──▶ [Concept D]
```

Or as a table:
| Concept | Related To | Relationship | Key Distinction |
|---------|-----------|--------------|-----------------|
| A | B | A uses B for X | A is NOT the same as B because... |

### 3.3 Taxonomy (if applicable)

```
Domain
├── Category 1
│   ├── Subcategory A (examples: X, Y)
│   └── Subcategory B (examples: Z)
├── Category 2
│   └── ...
└── Category 3
```

---

## Phase 4: Map the Tensions

Every interesting domain has fundamental tensions — tradeoffs that can't be fully resolved:

```markdown
## Core Tensions

### [Tension 1]: [X] vs [Y]
- **The tradeoff:** More X means less Y
- **Where different solutions sit:** 
  - [Solution A] optimizes for X
  - [Solution B] optimizes for Y
  - [Solution C] tries to balance
- **When X matters more:** [Scenario]
- **When Y matters more:** [Scenario]
```

Common tension patterns:
- Simplicity vs Power
- Speed vs Correctness
- Flexibility vs Safety
- Ease of start vs Scale of finish
- Control vs Convenience

---

## Phase 5: Map the Landscape (Players/Options)

### 5.1 If Technology Domain

| Option | Positioning | Strengths | Weaknesses | Best For |
|--------|------------|-----------|------------|----------|
| Tool A | [Where it sits on the tension spectrum] | ... | ... | ... |
| Tool B | ... | ... | ... | ... |

### 5.2 If Problem Domain

| Approach | Core Idea | When It Works | When It Fails |
|----------|-----------|---------------|---------------|
| Approach A | ... | ... | ... |
| Approach B | ... | ... | ... |

---

## Phase 6: Synthesize for User's Goal

Reconnect to WHY they need this map:

```markdown
## Implications for Your Situation

**Given that you're trying to:** [User's goal]
**And your constraints are:** [What they told you]

**My read:**
- [Option/approach that fits best and why]
- [What to watch out for]
- [What to learn more about before committing]
- [What's irrelevant to your situation (prune the map)]
```

---

## Output Format

```markdown
## Domain Map: [Subject]

### One-Sentence Summary
[What this domain IS about at its core]

### Key Concepts
[5-10 concepts with one-line definitions and relationships]

### Core Tensions
[2-3 fundamental tradeoffs that define the space]

### Landscape
[Table or map of options/players/approaches positioned on the tension axes]

### Evolution
[Where is this domain heading? What's emerging? What's dying?]

### For Your Situation
[Specific guidance given user's goal and constraints]

### Recommended Next Steps
[What to read, try, or investigate further]
```
