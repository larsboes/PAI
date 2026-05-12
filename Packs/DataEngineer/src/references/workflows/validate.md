# Workflow: validate

Cross-reference data sources, detect discrepancies, and produce a gap analysis.

## Process

### 1. Identify Validation Targets

Determine what to validate:
- **Internal consistency** — Does the data agree with itself? (FK integrity, computed fields, enum values)
- **Cross-source** — Does source A agree with source B? (USDA vs Syngenta KB nutrition data)
- **Schema compliance** — Does the data match the declared schema?
- **Domain constraints** — Are values physically/logically possible?

### 2. Schema Compliance Check

For each data file against its schema:

```markdown
## Schema Compliance: [file]

| Field | Schema Type | Actual Type | Schema Constraint | Actual Range | Status |
|-------|------------|-------------|-------------------|-------------|--------|
| temp_c | float | float | -10 to 45 | -8.2 to 44.1 | PASS |
| zone_id | enum | string | 5 valid values | 5 values | PASS |
| status | enum | string | 6 valid values | "unknwon" found | FAIL |
```

### 3. Referential Integrity Check

For each foreign key relationship:

```markdown
## Referential Integrity

| Source Table | FK Field | Target Table | Target PK | Orphans | Status |
|-------------|----------|--------------|-----------|---------|--------|
| crop_instance | crop_name | crop_profile | name | 0 | PASS |
| crop_instance | zone_id | zone | id | 1 ("test") | FAIL |
```

### 4. Cross-Source Validation

When multiple sources describe the same entity:

```markdown
## Cross-Reference: [entity]

| Field | Source A (USDA) | Source B (Syngenta KB) | Source C (Our Data) | Match? | Resolution |
|-------|----------------|----------------------|---------------------|--------|------------|
| protein_g | 12.95 | 13.0 | 12.95 | ~YES | Use USDA (FDC verified) |
| calcium_mg | 56 | 35 | 56 | NO | Variety difference — document |
| vitamin_c_mg | 19.7 | 20 | 20 | ~YES | Rounding OK |
```

### 5. Computed Field Verification

For each computed/derived field, verify the formula:

```markdown
## Computed Field Verification

| Field | Formula | Sample Input | Expected | Actual | Status |
|-------|---------|-------------|----------|--------|--------|
| vpd_kpa | Tetens(temp, humidity) | T=22, H=65 | 0.93 | 0.93 | PASS |
| days_to_harvest | growth_days - days_planted | 90 - 45 | 45 | 45 | PASS |
| coverage_pct | produced / required * 100 | 40774 / 108000 | 37.8% | 37.8% | PASS |
```

### 6. Gap Analysis

Identify what's missing, stale, or inconsistent:

```markdown
## Gap Analysis

### Critical (blocks functionality)
| # | Gap | Impact | Owner | Status |
|---|-----|--------|-------|--------|
| G1 | mock.js uses v1 crop names | Dashboard shows wrong data | Bryan | IN PROGRESS |

### High (degrades quality)
| # | Gap | Impact | Resolution |
|---|-----|--------|------------|
| G4 | Vitamin A not tracked | Incomplete nutrition model | Add to crop profile |

### Medium (nice to have)
| # | Gap | Notes |
|---|-----|-------|
| G8 | O2 model static | V6 defined, needs implementation |
```

### 7. Staleness Check

For each data file, verify currency:

```markdown
## Staleness Check

| File | Last Modified | Schema Version | Current Version | Status |
|------|--------------|----------------|-----------------|--------|
| crop-profiles.json | 2h ago | v2.0 | v2.0 | CURRENT |
| sensor-baseline.json | 3d ago | v1 | v2 expected | STALE |
| mock.js | 1d ago | v1 crops | v2 crops expected | STALE |
```

## Output Format

```markdown
## Validation Report: [project/dataset]

### Summary
| Check | Passed | Failed | Warnings |
|-------|--------|--------|----------|
| Schema compliance | 45 | 2 | 3 |
| Referential integrity | 12 | 1 | 0 |
| Cross-source | 8 | 1 | 2 |
| Computed fields | 6 | 0 | 0 |

### Failures
[Details of each failure with resolution]

### Gap Analysis
[Categorized gaps: Critical / High / Medium]

### Staleness
[Files needing update]
```

## Execution

Use Read to load data files, Bash with `jq` for JSON validation, Grep to find references across codebase. For cross-source validation, read both sources and compare field-by-field.
