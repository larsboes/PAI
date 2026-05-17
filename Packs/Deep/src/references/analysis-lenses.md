# DeepAnalysis Reference: Analysis Lenses

## The 5 Dimensions (Quick Reference)

Use these as a checklist. Not every analysis needs all 5 — but consider each before skipping.

| Dimension | Core Question | What It Reveals |
|-----------|--------------|-----------------|
| **Structure** | What is this made of? | Components, boundaries, interfaces |
| **Flow** | How does it move? | Data paths, control flow, event chains |
| **Dependencies** | What relies on what? | Coupling, SPOFs, blast radius |
| **Tensions** | Where does it fight itself? | Contradictions, tech debt, misalignment |
| **Evolution** | Where is this heading? | Growth limits, pressure points, likely changes |

---

## Analysis Depth Selector

| Signal | Depth Level | Time |
|--------|-------------|------|
| "Quick overview", orientation needed | Quick Map | 5-10 min |
| Making a decision that depends on understanding | Standard | 20-40 min |
| High-stakes, unfamiliar, complex, many dependencies | Deep Dive | 45-90 min |
| User said "deep analysis" or "really understand" | Deep Dive | 45-90 min |

---

## Revealing Non-Obvious Insights

The REAL value of deep analysis is surfacing what others miss. Techniques:

### 1. Gap Analysis
- What's MISSING that should be there?
- What's NOT documented but relied upon?
- What failure mode has no handling?

### 2. Contradiction Hunting
- Where does stated intent conflict with actual implementation?
- Where do two components make incompatible assumptions?
- Where does the team's language not match the code's behavior?

### 3. Temporal Reasoning
- What was true when this was built but isn't anymore?
- What assumption about scale/usage has been outgrown?
- What's on a trajectory to break within 6 months?

### 4. Perspective Shifting
- How does this look from the user's perspective vs the developer's?
- How does this look from the ops/infra perspective?
- How would a new team member perceive this?
- How would an attacker view this?

### 5. Boundary Stress Testing
- What happens at the edges? (empty data, max data, concurrent access)
- What happens at the boundaries between components?
- What happens when an assumption is violated?

---

## Output Structures

### For Codebases/Architecture → MapSystem
```
Structure Map → Flow Diagram → Dependency Table → Tensions List → Evolution Notes
```

### For Changes/Decisions → TraceImpact
```
Change Definition → Impact Table (by order) → Risk Assessment → Safe Approach
```

### For Domains/Problem Spaces → MapDomain
```
Concept Map → Taxonomy → Tension Spectrum → Landscape Table → Recommendations
```

### For Comparisons → Tradeoffs
```
Options Table → Dimension Matrix → Second-Order Effects → Core Tension → Assessment
```

---

## Integration Decision Tree

After analysis is complete, the user likely needs one of:

| What They Need Next | Invoke |
|--------------------|--------|
| Challenge the analysis findings | **RedTeam** or **FirstPrinciples** |
| Decide between options revealed | **Council** / `/swarm begin` |
| Fix a problem the analysis found | **DeepDebug** |
| Design a solution for a gap found | **Brainstorm** |
| Test a hypothesis from the analysis | **Science** |
| Explore an idea that emerged | **Brainstorm** / **BeCreative** |

---

## Common Mistakes in Analysis

| Mistake | Fix |
|---------|-----|
| Listing features instead of revealing relationships | Ask "so what?" for each observation |
| Stopping at surface structure | Trace one level deeper: why is it structured this way? |
| Missing implicit coupling | Check shared state, shared config, shared conventions |
| Assuming docs are accurate | Always compare docs to actual code/behavior |
| Only analyzing what exists | Also ask what's MISSING (error handling, monitoring, tests) |
| Generic dimensions in comparison | Extract dimensions from the specific context and user's goals |
| Treating all findings as equal | Rank by impact and relevance to user's actual goal |
