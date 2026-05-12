# MapSystem Workflow

Running the **MapSystem** workflow in the **DeepAnalysis** skill to comprehend this system's architecture...

## Overview

Systematic comprehension of a codebase or system architecture. Produces a structured mental model covering structure, flows, dependencies, tensions, and evolution trajectory.

---

## Phase 1: Orient (5 minutes)

**Get the big picture before diving in. Resist the urge to read individual files.**

### 1.1 Project Shape
```bash
# What is this?
cat README.md
cat package.json  # or Cargo.toml, go.mod, etc.

# How big? How structured?
find . -type f -name "*.ts" | wc -l
ls -la src/
find . -maxdepth 2 -type d | grep -v node_modules | sort

# Entry points
grep -r "main\|entry\|start\|bin" package.json
ls src/index.* src/main.* src/app.* 2>/dev/null
```

### 1.2 Technology Stack
- Language(s) and runtime
- Framework(s) and paradigm (OOP, functional, event-driven)
- Build system
- Key dependencies (what heavy libraries does it lean on?)

### 1.3 Stated Architecture
- What do the docs/README SAY it is?
- Are there architecture docs, ADRs, or diagrams?
- What's the claimed mental model?

**Output of Phase 1:**
> "This is a [type] project using [stack], structured as [pattern], with [N] main components."

---

## Phase 2: Map Structure (10 minutes)

**Identify all the pieces and their boundaries.**

### 2.1 Component Inventory
For each major component/module/service:
- Name and purpose (one sentence)
- Public interface (what does it expose?)
- Size/complexity (rough LOC, number of files)
- Boundary type (module boundary, network boundary, process boundary)

### 2.2 Relationship Mapping
```bash
# Internal imports — who depends on who?
rg "import.*from ['\"]\./" --type ts | sed 's/.*from ['\''\"]//' | sort | uniq -c | sort -rn | head -20

# What's the most-imported module? (likely core/shared)
rg "from ['\"]" --type ts -o | sort | uniq -c | sort -rn | head -15

# External dependency usage
rg "from ['\"](?!\.)" --type ts -o | sort | uniq -c | sort -rn | head -15
```

### 2.3 Produce Structure Map

```markdown
## Structure Map

┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   CLI/API   │────▶│   Core       │────▶│  Database   │
│  (entry)    │     │  (business)  │     │  (persist)  │
└─────────────┘     └──────────────┘     └─────────────┘
       │                    │
       ▼                    ▼
┌─────────────┐     ┌──────────────┐
│   Config    │     │  External    │
│  (settings) │     │  (APIs)      │
└─────────────┘     └──────────────┘
```

Adapt to actual architecture. ASCII is fine. Tables work too.

---

## Phase 3: Trace Flows (10 minutes)

**Follow the 2-3 most important paths through the system.**

### 3.1 Identify Key Flows
- The "happy path" — most common user action, end to end
- The "critical path" — most important/dangerous operation
- The "init path" — startup/bootstrap sequence

### 3.2 Trace Each Flow

For each flow, follow from trigger to completion:
```
Trigger → Step 1 → Step 2 → ... → Result
                      ↓
              (side effect: X)
```

What to note:
- Where does data transform?
- Where are the async boundaries?
- Where could it fail?
- Where is state mutated?

### 3.3 Document Flows

```markdown
### Flow: User Login
1. Client sends POST /auth/login
2. AuthController validates input shape
3. AuthService.login() called
4. UserRepository.findByEmail() → DB query
5. bcrypt.compare() for password
6. JWT signed with ACCESS_SECRET
7. RefreshToken stored in DB
8. Response: { accessToken, refreshToken }

**Side effects:** Login event emitted, last_login updated
**Failure modes:** Invalid creds (401), DB down (500), rate limited (429)
```

---

## Phase 4: Map Dependencies (5 minutes)

**What relies on what? Where's the hidden coupling?**

### 4.1 Hard Dependencies
- What MUST be running for this to work? (databases, services, APIs)
- What env vars are required?
- What config files must exist?

### 4.2 Implicit Coupling
Things that aren't imported but are coupled:
- Shared database tables (two services writing same table)
- Shared config/env (changing a var affects multiple things)
- Convention coupling (assumed file names, paths, formats)
- Temporal coupling (must happen in order, but nothing enforces it)

### 4.3 Single Points of Failure
- If this component dies, what else dies?
- What has no fallback/redundancy?
- What's the blast radius of each component's failure?

```markdown
### Dependency Map

| Component | Depends On | Depended On By | SPOF? |
|-----------|-----------|----------------|-------|
| AuthService | DB, JWT secret | Everything | ⚠️ YES |
| UserRepo | PostgreSQL | Auth, Profile, Admin | No (replicas) |
| Config | .env file | Everything | ⚠️ YES (no defaults) |
```

---

## Phase 5: Surface Tensions (5 minutes)

**Where does the system contradict itself or fight its own design?**

### 5.1 Stated vs Actual
- README says X but code does Y
- Architecture diagram shows clean boundaries but imports cross them
- "Microservices" but with a shared database
- "Event-driven" but with synchronous calls everywhere

### 5.2 Design Smells
```bash
# God objects (huge files)
find . -name "*.ts" -exec wc -l {} \; | sort -rn | head -10

# Circular dependencies (import A→B→A)
# High fan-in (everyone imports this = fragile core)
# High fan-out (this imports everything = god module)

# Tech debt markers
rg "TODO\|HACK\|FIXME\|XXX\|WORKAROUND" --type ts | wc -l
rg "TODO\|HACK\|FIXME" --type ts | head -10
```

### 5.3 Tradeoffs Embedded in Design
Every architecture embeds tradeoffs. Name them:
- "Chose simplicity over performance here (single-threaded)"
- "Chose consistency over availability (sync writes)"
- "Chose flexibility over type safety (any types, runtime validation)"

---

## Phase 6: Evolution Trajectory (5 minutes)

**Where is this heading? What will break first?**

### 6.1 Growth Pressure
- What happens at 10x users/data/traffic?
- What's the first bottleneck?
- Where does complexity accumulate?

### 6.2 Change Patterns
```bash
# What changes most often? (high churn = pressure point)
git log --format=format: --name-only --since="3 months ago" | sort | uniq -c | sort -rn | head -20

# What's growing? (new files added recently)
git log --diff-filter=A --format=format: --name-only --since="1 month ago" | sort
```

### 6.3 Likely Next States
Based on current trajectory:
- "If team grows, they'll need to split [X]"
- "If data grows, [Y] will become the bottleneck"
- "The current approach to [Z] won't scale past [threshold]"

---

## Phase 7: Synthesize

Produce the final analysis using the output format from SKILL.md:
- One-sentence summary
- Structure map
- Key flows
- Dependency graph with SPOFs
- Tensions & contradictions
- Evolution trajectory
- **Non-obvious insights** (the REAL value — what would someone new miss?)
- Implications for user's goal

---

## Time Budget

| Phase | Quick Map | Standard | Deep Dive |
|-------|-----------|----------|-----------|
| Orient | 2 min | 5 min | 5 min |
| Structure | 3 min | 10 min | 15 min |
| Flows | skip | 10 min | 15 min |
| Dependencies | skip | 5 min | 10 min |
| Tensions | skip | 5 min | 10 min |
| Evolution | skip | 5 min | 10 min |
| **Total** | **5 min** | **40 min** | **65 min** |
