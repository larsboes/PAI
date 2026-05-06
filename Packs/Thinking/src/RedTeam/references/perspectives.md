# RedTeam — 32 Agent Perspectives

## Expert Types

Each perspective attacks from a different angle:

### Technical
1. **Software Engineer** — code quality, implementation feasibility
2. **Systems Architect** — scalability, coupling, single points of failure
3. **Security Pentester** — attack vectors, threat surface
4. **Database Engineer** — data integrity, performance at scale
5. **DevOps/SRE** — deployment risk, operational complexity
6. **QA Engineer** — edge cases, untested paths

### Business
7. **CFO** — ROI, hidden costs, financial risk
8. **Product Manager** — user impact, scope creep, priority
9. **Sales Engineer** — customer objections, competitive weakness
10. **Legal/Compliance** — regulatory risk, liability
11. **Operations Manager** — process disruption, training cost

### Domain
12. **Industry Expert** — domain-specific pitfalls
13. **Academic Researcher** — theoretical limitations, prior art
14. **Historian** — precedent, what failed before
15. **Economist** — market dynamics, incentive misalignment
16. **Ethicist** — moral hazard, unintended consequences

### Adversarial
17. **Competitor** — how to beat this, exploitable weaknesses
18. **Short Seller** — why this will fail
19. **Investigative Journalist** — what's being hidden, spin detection
20. **Regulator** — compliance gaps, public risk
21. **Hacker** — how to break it, abuse cases

### Skeptics
22. **Naïve Intern** — "why not just...?" (simplicity attacks)
23. **End User** — usability, confusion, friction
24. **Cynical Veteran** — "tried that, didn't work because..."
25. **Statistician** — sample bias, correlation≠causation
26. **Philosopher** — logical fallacies, category errors

### Wild Cards
27. **Science Fiction Writer** — second-order effects, dystopian outcomes
28. **Insurance Actuary** — low-probability high-impact events
29. **Military Strategist** — adversarial game theory
30. **Anthropologist** — cultural blind spots
31. **Child (5yo)** — "but why?" (exposes unjustified complexity)
32. **Future Self (10yr)** — "was this actually important?"

## How to Use in Practice

### Single-agent mode (default)
Simulate all 32 perspectives sequentially within a single response. Identify the TOP 5 most devastating perspectives for this specific topic and deep-dive those.

### Multi-agent mode (with Delegation)
Launch 6-8 Task() agents, each embodying 4-5 perspectives. Synthesize findings from all agents into the final steelman + counter-argument.

## Severity Scale

| Level | Meaning | Action |
|-------|---------|--------|
| **Observation** | Noted but not blocking | Document |
| **Concern** | Could become a problem | Monitor |
| **Warning** | Likely to cause issues | Mitigate |
| **Critical** | Will cause failure if unaddressed | Block/redesign |
| **Fatal** | Invalidates the entire premise | Abandon or fundamentally rethink |
