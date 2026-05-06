---
name: PAIUpgrade
description: "Extract system improvements from content and monitor external sources (Anthropic ecosystem, YouTube). Use when upgrading the PAI system or mining content for improvements."
---

# PAIUpgrade Skill

**Primary Purpose:** Generate prioritized upgrade recommendations for the user's existing PAI setup by understanding their context and discovering what's new in the ecosystem.

The skill runs **three parallel agent threads** that converge into personalized recommendations:

```
Thread 1: USER CONTEXT     Thread 2: SOURCE COLLECTION    Thread 3: INTERNAL REFLECTIONS
┌───────────────────┐     ┌───────────────────────┐      ┌───────────────────────┐
│ TELOS Analysis    │     │ Anthropic Sources     │      │ Algorithm Reflections │
│ Project Analysis  │     │ YouTube Channels      │      │ Q2: Algorithm fixes   │
│ Recent Work       │     │ Custom USER Sources   │      │ Q1: Execution errors  │
│ PAI System State  │     │ GitHub Trending       │      │ Sentiment weighting   │
│                   │     │ Community Updates     │      │                       │
└───────────────────┘     └───────────────────────┘      └───────────────────────┘
           │                         │                              │
           └─────────────┬───────────┴──────────────────────────────┘
                         ▼
           ┌─────────────────────────────┐
           │  PRIORITIZED RECOMMENDATIONS │
           │  (external + internal)       │
           └─────────────────────────────┘
```

---

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **Upgrade** | "check for upgrades", "check sources", "any updates", "check Anthropic", "check YouTube", "upgrade", "pai upgrade" | `Workflows/Upgrade.md` |
| **MineReflections** | "mine reflections", "check reflections", "what have we learned", "internal improvements", "reflection insights" | `Workflows/MineReflections.md` |
| **AlgorithmUpgrade** | "algorithm upgrade", "upgrade algorithm", "improve the algorithm", "algorithm improvements", "fix the algorithm" | `Workflows/AlgorithmUpgrade.md` |
| **ResearchUpgrade** | "research this upgrade", "deep dive on [feature]", "further research" | `Workflows/ResearchUpgrade.md` |
| **FindSources** | "find upgrade sources", "find new sources", "discover channels" | `Workflows/FindSources.md` |

**Default workflow:** If user says "upgrade" or "check for upgrades" without specifics, run the **Upgrade** workflow. The Upgrade workflow automatically includes internal reflection mining as Thread 3.

---


## Deep References

| Reference | Content |
|-----------|---------|
| `references/report-template.md` | Full report format template with all sections |
| `references/architecture.md` | Two-thread architecture, extraction rules, process flow |

## Output
- Produces: PAI Upgrade Report with prioritized recommendations
- Format: Structured markdown report (Critical/High/Medium/Low priority)
