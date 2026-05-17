# DeepAnalysis Reference: Output Formats

## Structured Output Templates

### System Map Output

```markdown
## System Map: [Name]

### Components
| Component | Responsibility | Interfaces | Owner |
|-----------|---------------|------------|-------|
| ... | ... | ... | ... |

### Data Flow
[Mermaid or text description of primary data paths]

### Dependencies
- **Hard:** [Component] → [Component] (if this breaks, that breaks)
- **Soft:** [Component] ↔ [Component] (degraded but functional without)
- **Hidden:** [Description of non-obvious coupling]

### SPOFs
1. [Single point of failure + blast radius]

### Tensions
- [Goal A] conflicts with [Goal B] because [mechanism]
- Stated architecture says X but implementation optimizes for Y

### Evolution Pressure
- Will break when: [growth condition]
- Next likely change: [prediction + evidence]
```

### Impact Trace Output

```markdown
## Impact Trace: [Change Description]

### Direct Effects
| What Changes | Where | Confidence |
|--------------|-------|-----------|
| ... | ... | High/Med/Low |

### Second-Order Effects
| If [direct effect] | Then [consequence] | Timeline |
|--------------------|-------------------|----------|
| ... | ... | Immediate/Days/Weeks |

### Affected Stakeholders
- [Person/team] — affected because [reason]

### Rollback Difficulty
[Easy/Medium/Hard] — [explanation]

### Recommendation
[Go/Conditional/Don't] — [reasoning]
```

### Domain Map Output

```markdown
## Domain Map: [Topic]

### Core Concepts
| Concept | Definition | Relates To |
|---------|-----------|-----------|
| ... | ... | ... |

### Boundaries
- [Subdomain A] owns: [concepts]
- [Subdomain B] owns: [concepts]
- Overlap/contention: [shared concepts]

### Mental Models
- Experts think about this as: [frame]
- Common misconception: [what people assume vs reality]

### Open Questions
- [What's genuinely unclear or debated in this domain]
```

### Tradeoff Landscape Output

```markdown
## Tradeoffs: [Decision]

### Options
| Option | Best When | Worst When | Reversibility |
|--------|-----------|-----------|---------------|
| A | ... | ... | Easy/Hard |
| B | ... | ... | Easy/Hard |

### Axes of Comparison
- [Axis 1]: A wins / B wins
- [Axis 2]: A wins / B wins

### Hidden Costs
- Option A looks cheap but [hidden cost]
- Option B looks expensive but [hidden benefit]

### Recommendation
[Option] — because [your specific context matches these conditions]
```
