# DeepAnalysis Reference: Anti-Patterns

Common mistakes when doing deep analysis. Check yourself against these.

## Surface-Level Traps

### 1. Describing Instead of Analyzing
- **Wrong:** "The system has 3 microservices and a database"
- **Right:** "The auth service is a SPOF — if it goes down, both other services fail because they validate tokens synchronously on every request"

### 2. Listing Without Connecting
- **Wrong:** Bullet list of components
- **Right:** Map showing which depends on which, and what breaks when each fails

### 3. Stating the Obvious
- **Wrong:** "The React frontend calls the API"
- **Right:** "The frontend makes 12 API calls per page load because there's no aggregation layer — this will become the bottleneck before the backend does"

## Depth Traps

### 4. Going Deep Everywhere
Not everything deserves full 5-dimension analysis. Match depth to stakes:
- Critical path? Full depth.
- Stable utility code? Structure only.
- Config files? Skip entirely.

### 5. Analysis Without Synthesis
Listing findings per dimension but never connecting them. The insight is usually at the intersection: "The dependency structure (dim 3) means the tension (dim 4) can't be resolved without restructuring (dim 1)."

### 6. Missing the Human Layer
Systems exist in organizations. Hidden coupling is often:
- Team A owns service X, team B needs changes to X, so B works around it
- The architecture matches the 2019 org chart, not the current one
- Knowledge is in one person's head, not in the code

## Framing Traps

### 7. Assuming the Stated Problem is the Real Problem
User asks "analyze this database schema" but the real issue is the application queries, not the schema. Step back before diving in.

### 8. Technology-First Analysis
Looking at tech choices before understanding what problem they solve. Start with: what job does this system do for its users?

### 9. Ignoring Context
A "bad" architecture might be perfect for the team size, growth rate, and constraints. Analysis without context is just judgment.

## Quality Checks

Before delivering analysis, verify:
- [ ] Did I surface something the reader didn't already know?
- [ ] Are my findings actionable (not just interesting)?
- [ ] Did I connect findings across dimensions?
- [ ] Did I state confidence levels where uncertain?
- [ ] Is this useful to someone who needs to make a decision?
