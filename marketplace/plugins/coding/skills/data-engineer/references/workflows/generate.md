# Workflow: generate

Synthetic dataset generation from a schema definition or data model, respecting domain constraints and realistic distributions.

## Process

### 1. Parse Schema

Read the schema source (JSON Schema, class diagram, table defs, or a SKILL.md data model) and extract:
- Field names, types, and constraints
- Relationships and cardinalities
- Enums and valid value sets
- Computed field formulas
- Volume targets

### 2. Define Constraints

For each field, determine generation strategy:

| Field Type | Strategy | Example |
|-----------|----------|---------|
| ID / PK | UUID, sequential, or composite | `uuid4()`, `ZONE-001` |
| Timestamp | Range + frequency + optional gaps | Every 10s for 450 sols |
| Enum | Weighted random from valid set | `nominal: 70%, watch: 20%, critical: 10%` |
| Float (sensor) | Distribution + noise + drift | `N(22.0, 2.5)` with 0.01/tick drift |
| Float (bounded) | Uniform or beta within [min, max] | `Beta(2,5) * (max-min) + min` |
| Int (counter) | Monotonic increasing + resets | Cycle count 1-15 |
| String (name) | Pick from domain-specific list | Crop names, crew names |
| Computed | Derive from other generated fields | `vpd = f(temp, humidity)` |
| FK | Reference existing generated records | `zone_id` from zone table |

### 3. Define Temporal Patterns

For time-series data, model:
- **Diurnal cycles** — day/night patterns (temperature, light, humidity)
- **Seasonal drift** — gradual change over mission duration
- **Events** — anomalies, crises, spikes (CME, equipment failure)
- **Noise** — sensor noise floor, measurement jitter
- **Gaps** — missing readings, downtime periods

```
value(t) = baseline
         + seasonal(t)      # long-term trend
         + diurnal(t)       # daily cycle
         + event(t)         # crisis overlay
         + noise(t)         # random jitter
```

### 4. Define Correlations

Specify cross-field correlations:
- Temperature up -> humidity down (inverse)
- Solar output down -> battery drains -> desal drops (cascade)
- Plant health drops when sensor values leave optimal range
- Water reserve = previous - consumption + desalination

### 5. Generate

Output format options:
- **JSON** — array of objects or nested document
- **JSONL** — one record per line (streaming)
- **CSV** — flat tabular
- **SQL** — INSERT statements
- **DynamoDB JSON** — typed attribute format

Generation approach:
1. Generate reference/dimension data first (zones, crops, crew)
2. Generate fact/event data referencing dimensions
3. Apply temporal patterns and correlations
4. Inject planned anomalies at specified points
5. Compute derived fields last

### 6. Validate Generated Data

After generation, verify:
- All constraints satisfied (ranges, enums, non-null)
- Referential integrity (all FKs resolve)
- Distribution matches specification (not accidentally uniform)
- Temporal continuity (no impossible jumps)
- Computed fields match formula

## Output Format

```markdown
## Generated Dataset: [name]

### Specification
| Parameter | Value |
|-----------|-------|
| Records | N |
| Time range | Sol 1-450 |
| Frequency | 10s intervals |
| Anomalies | 3 CME events, 2 equipment failures |

### Files Created
| File | Records | Size | Description |
|------|---------|------|-------------|
| telemetry.json | 120,000 | 45MB | Zone sensor readings |
| events.json | 47 | 12KB | Crisis events |

### Distribution Summary
| Field | Expected | Actual | OK? |
|-------|----------|--------|-----|
| temp_c | N(22, 2.5) | N(21.8, 2.6) | Yes |
| status | nominal 70% | nominal 72% | Yes |

### Validation
- [x] All constraints satisfied
- [x] Referential integrity OK
- [x] No impossible temporal jumps
- [x] Computed fields verified
```

## Execution

Use Bash to run Python/Node scripts for large datasets. For small datasets (<1000 records), generate directly as JSON via Write. Always validate after generation.
