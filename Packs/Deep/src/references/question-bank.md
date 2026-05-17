# DeepAnalysis Reference: Question Bank

Questions to ask per dimension. Pick 3-5 from each relevant dimension — not all.

## Structure Questions

- What are the top-level components and what does each own?
- Where are the boundaries? What crosses them?
- Which interfaces are stable vs volatile?
- Is there a component that does too much (god object)?
- What's the dependency tree depth? Flat or deeply nested?
- What would a new team member misunderstand about the structure?

## Flow Questions

- What's the happy path for the primary use case?
- Where does data transform between representations?
- What's the longest chain of synchronous calls?
- Where does control flow branch in non-obvious ways?
- What happens to a request that takes 10x longer than normal?
- Where do things queue up under load?

## Dependency Questions

- If I delete [component], what breaks? What still works?
- Which dependencies are implicit (not in import statements)?
- Is there shared mutable state between components?
- Which external services have no fallback?
- What's the blast radius of a database schema change?
- Which dependencies have different SLA than the system?

## Tension Questions

- What does the README say vs what the code actually does?
- Where has the team clearly worked around a limitation?
- Which parts of the system optimize for contradicting goals?
- What's the oldest hack that everyone knows about?
- Where do metrics/monitoring disagree with stated goals?
- What would the original authors be surprised by today?

## Evolution Questions

- What breaks first at 10x current scale?
- What's the most likely next feature request and how well does the architecture support it?
- Which dependencies are at risk of deprecation?
- Where is complexity growing fastest?
- What decisions were made for constraints that no longer exist?
- If you could restart this component, what would you change?

## Meta Questions (for any dimension)

- What am I not seeing because I'm looking at the code instead of the usage?
- Who uses this that the developers don't know about?
- What's the gap between the team's mental model and reality?
- What's the most expensive assumption that hasn't been tested?
