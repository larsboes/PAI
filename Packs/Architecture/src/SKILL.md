---
name: architecture
description: "Software architecture patterns — Clean Architecture review/check/fix, DDD tactical patterns (aggregates, value objects, domain events, repositories), DDD strategic patterns (bounded contexts, context maps, anti-corruption layers), hexagonal/ports-and-adapters, CQRS, and event sourcing. Use when architecture, DDD, domain-driven, bounded context, aggregate, clean architecture, hexagonal, ports and adapters, CQRS, event sourcing, context map, anti-corruption layer, design module, design workflow."
allowed-tools: Read, Edit, Write, Grep, Glob
---

# Architecture Skill

Unified skill for reviewing, enforcing, fixing, and designing software architecture — Clean Architecture, DDD tactical and strategic patterns, hexagonal/ports-and-adapters, CQRS, and event sourcing.

## Mode Selection

Pass the mode as the first argument:

| Mode | Usage | Purpose |
|------|-------|---------|
| `review` | `/architecture review [files...]` | Comprehensive architecture review |
| `check` | `/architecture check` | Quick boundary violation scan |
| `fix` | `/architecture fix [file or violation type]` | Guided violation remediation |
| `design-module` | `/architecture design-module [description]` | Design a new module |
| `design-workflow` | `/architecture design-workflow [description]` | Design an agent workflow |
| `ddd-tactical` | `/architecture ddd-tactical [context]` | DDD building blocks: aggregates, entities, value objects, domain events, repositories |
| `ddd-strategic` | `/architecture ddd-strategic [context]` | Bounded contexts, context maps, shared kernels, ACL |
| `hexagonal` | `/architecture hexagonal [context]` | Ports & adapters, driving/driven sides |

$ARGUMENTS

---

## Quick Reference

### Layer Boundaries

| Layer | Can Import | Must Not Import |
|-------|-----------|-----------------|
| **Domain** | `dataclasses`, `typing`, `uuid`, `datetime`, `abc`, `enum` | Web frameworks, ORMs, validation libs |
| **Service** | Domain, abstract interfaces | ORM models, concrete repos, direct infra |
| **Agent/Workflow** | Injected adapters/services | Direct adapter instantiation |
| **Infrastructure** | Domain, external libs | - |
| **API** | Services | Concrete repos, direct DB access |

### Common Fixes

| Violation | Fix Pattern |
|-----------|-------------|
| Domain imports framework | Replace with pure Python (dataclasses) |
| Service imports ORM model | Use repository abstraction |
| Repository calls `commit()` | Use `flush()`, let UoW commit |
| Workflow hardcodes adapter | Inject via `functools.partial` |
| Prompt embedded in node | Externalize to prompts/ directory |

---

## Mode Details

See references for detailed mode documentation:

- **[review](references/modes/review.md)** — Comprehensive architecture review with layer analysis, pattern compliance, SOLID checks
- **[check](references/modes/check.md)** — Quick automated boundary violation scanning with grep patterns
- **[fix](references/modes/fix.md)** — Common refactoring patterns for violations
- **[design-module](references/modes/design-module.md)** — Design new modules following Clean Architecture
- **[design-workflow](references/modes/design-workflow.md)** — Design agent workflows with dependency injection
- **[ddd-tactical](references/ddd-tactical.md)** — Aggregates, entities, value objects, domain events, repositories, domain services
- **[ddd-strategic](references/ddd-strategic.md)** — Bounded contexts, context maps, shared kernels, anti-corruption layers, CQRS, event sourcing

## Implementation References

Deep reference material for the hard parts — wiring domain objects to real infrastructure:

- **[persistence-mapping](references/persistence-mapping.md)** — Imperative mapping (SQLAlchemy), data mapper pattern, Unit of Work, value object/enum/collection mapping recipes, optimistic locking
- **[aggregate-design](references/aggregate-design.md)** — Boundary heuristics (4-question framework), sizing rules, cross-aggregate coordination (events, sagas), red flags for too-big/too-small
- **[application-services](references/application-services.md)** — Command handlers, Result/Either error pattern, event dispatch timing, outbox pattern, query services (read side)
- **[testing](references/testing.md)** — Domain unit tests, fakes vs mocks, in-memory repositories, integration tests with testcontainers, test data builders

---

## Philosophy

**Good architecture is:**
- **Boundary-respecting** — Domain stays pure, bounded contexts have clear borders
- **Dependency-inverted** — Services depend on abstractions, not implementations
- **Domain-centric** — Business logic lives in the domain layer, not in infrastructure
- **Testable** — Dependencies injected, not hardcoded
- **Explicit** — Violations caught early, context boundaries enforced
- **Ubiquitous Language** — Code speaks the domain's language

**Anti-patterns to catch:**
- Framework dependencies in domain
- Direct DB access from API layer
- Hardcoded infrastructure in workflows
- Transaction control in repositories
- Anemic domain models (logic in services, entities are just data bags)
- Missing aggregate boundaries (everything references everything)
- Bounded contexts without explicit contracts
