---
name: data-engineer
description: "Data engineering workflows — exploratory data analysis, schema design, synthetic dataset generation, data cleaning/transformation, data mapping/lineage, cross-source validation, and materialized view design. Use when EDA, data model, schema design, dataset generation, synthetic data, data cleaning, data transformation, ETL, data mapping, data lineage, data validation, cross-reference, gap analysis, materialized views, data profiling, DynamoDB schema, JSON schema, CSV, data pipeline."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
---

# Data Engineer Skill

Design, generate, transform, validate, and map structured datasets. From raw sources to production-ready data models.

## Mode Selection

Pass the mode as the first argument:

| Mode | Usage | Purpose |
|------|-------|---------|
| `profile` | `/data-engineer profile [file or dir]` | EDA — shape, types, distributions, nulls, outliers, summary stats |
| `schema` | `/data-engineer schema [requirements]` | Design data models: class diagrams, table defs, relationships, constraints |
| `generate` | `/data-engineer generate [schema-file]` | Synthetic dataset generation from schema + domain constraints |
| `transform` | `/data-engineer transform [source] [target-format]` | Clean, normalize, reshape, merge datasets with validation |
| `map` | `/data-engineer map [dir or files]` | Data lineage: source -> transform -> store -> view chains |
| `validate` | `/data-engineer validate [file] [reference]` | Cross-reference sources, detect discrepancies, gap analysis |
| `materialize` | `/data-engineer materialize [schema or data-model]` | Define computed views with formulas and dependencies |

$ARGUMENTS

---

## Quick Reference

### Data Profiling Checklist

| Check | What to look for |
|-------|-----------------|
| **Shape** | Row count, column count, nested depth |
| **Types** | Actual vs declared types, mixed-type columns |
| **Nulls** | Null rate per field, patterns (MCAR/MAR/MNAR) |
| **Cardinality** | Unique values, potential keys, enum candidates |
| **Distributions** | Min/max/mean/median/stddev, skew, outliers |
| **Relationships** | Foreign keys, join candidates, 1:N vs N:M |
| **Temporal** | Time ranges, gaps, frequency, timezone issues |
| **Consistency** | Naming conventions, unit mismatches, encoding |

### Common Data Smells

| Smell | Symptom | Fix |
|-------|---------|-----|
| Mixed units | `temp` field has both C and F values | Normalize to single unit, add `_unit` suffix |
| Implicit nulls | `""`, `"N/A"`, `0`, `-1` used as null | Map to explicit null, document sentinel values |
| Denormalized enums | Free-text where enum belongs | Extract unique values, propose enum |
| Orphan references | FK points to nonexistent PK | Validate referential integrity, flag orphans |
| Schema drift | Same field, different types across files | Canonical schema + validation layer |
| Precision loss | Float where decimal needed (money, coords) | Use string or integer representation |

### Schema Design Patterns

| Pattern | When | Example |
|---------|------|---------|
| **Time-series** | Sensor data, logs, metrics | PK=entity SK=timestamp, TTL for retention |
| **Event sourcing** | Audit trail, undo, replay | PK=aggregate SK=version, event_type+payload |
| **Adjacency list** | Hierarchies, graphs | PK=node SK=edge, GSI for reverse lookup |
| **Single-table** | DynamoDB, mixed entity types | PK=TYPE#ID SK=SORT, GSI overloading |
| **Star schema** | Analytics, dashboards | Fact table + dimension tables, denormalized |
| **Document** | Nested, self-contained records | Embedded sub-objects, schema-on-read |

---

## Mode Details

See references for detailed workflow documentation:

- **[profile](references/workflows/profile.md)** — Exploratory data analysis on any dataset
- **[schema](references/workflows/schema.md)** — Data model design with diagrams and table definitions
- **[generate](references/workflows/generate.md)** — Synthetic dataset generation with realistic constraints
- **[transform](references/workflows/transform.md)** — Data cleaning, normalization, reshaping, merging
- **[map](references/workflows/map.md)** — Data lineage diagrams and source-to-view chains
- **[validate](references/workflows/validate.md)** — Cross-source validation and gap analysis
- **[materialize](references/workflows/materialize.md)** — Computed view definitions with formulas

---

## Philosophy

**Good data engineering is:**
- **Schema-first** — Define the shape before generating or transforming
- **Source-traced** — Every value traceable to its origin
- **Validated at boundaries** — Trust nothing from external sources
- **Gap-aware** — Missing data is explicit, not hidden
- **Reproducible** — Transforms are deterministic and documented
- **Domain-constrained** — Synthetic data respects real-world bounds

**Anti-patterns to catch:**
- Schema designed around tool limitations, not domain
- Validation only at consumption, not ingestion
- Implicit relationships (convention-based FKs never checked)
- Data model docs that drift from actual schema
- Synthetic data with uniform distributions where real data is skewed
- Transform pipelines with no intermediate validation
