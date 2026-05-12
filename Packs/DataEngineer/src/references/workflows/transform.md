# Workflow: transform

Data cleaning, normalization, reshaping, and merging — with validation at each step.

## Process

### 1. Assess Source Data

Read the source and identify:
- Current format and structure
- Target format and structure (if specified)
- Quality issues from profiling (or do a quick profile first)
- Transform complexity (rename vs reshape vs merge)

### 2. Plan Transforms

Document each transform as a discrete, verifiable step:

```markdown
## Transform Plan: [source] -> [target]

| # | Operation | Input | Output | Validation |
|---|-----------|-------|--------|------------|
| 1 | Rename fields | snake_case | camelCase | All fields present |
| 2 | Normalize units | Mixed C/F temps | All Celsius | Range check |
| 3 | Merge sources | file_a + file_b | combined | Row count = a + b |
| 4 | Compute derived | temp, humidity | + vpd field | Formula verified |
| 5 | Filter invalid | all records | valid only | Rejected count logged |
```

### 3. Common Transform Operations

#### Rename / Reshape
- Field renaming (snake_case <-> camelCase, abbreviation expansion)
- Flatten nested objects (`address.city` -> `address_city`)
- Nest flat fields (`address_city` -> `address.city`)
- Pivot (rows to columns or reverse)
- Type coercion (string dates -> ISO 8601, string numbers -> float)

#### Clean
- Null handling: drop, fill (forward/backward/value), interpolate
- Deduplication: exact match, fuzzy match with threshold
- Outlier handling: clip to range, flag, remove
- Encoding: UTF-8 normalization, BOM removal
- Whitespace: trim, collapse, normalize line endings

#### Normalize
- Unit conversion (apply formula, document conversion factor)
- Scale normalization (0-1, z-score, min-max)
- Enum standardization (map variants to canonical values)
- Date/time standardization (timezone, format, epoch)
- ID format standardization (prefix, padding, case)

#### Merge / Join
- Inner join (only matching records)
- Left join (keep all from primary, null-fill from secondary)
- Union (stack datasets with same schema)
- Lookup enrichment (add fields from reference data)

#### Derive
- Computed fields from formulas
- Aggregations (group-by, window functions)
- Categorization (continuous -> discrete bins)
- Cross-field validation flags

### 4. Execute Transforms

For each step:
1. Apply the transform
2. Validate the output (row count, null check, range check)
3. Log what changed (rows affected, values modified)
4. Save intermediate result if multi-step

### 5. Validate Final Output

```markdown
## Transform Validation

| Check | Expected | Actual | Status |
|-------|----------|--------|--------|
| Row count | 1,200 | 1,200 | PASS |
| Null fields | 0 in required | 0 | PASS |
| Type compliance | All float temps | All float | PASS |
| Range compliance | temp 0-50 | 2.1-44.8 | PASS |
| Referential integrity | All FKs valid | All valid | PASS |
| Schema match | target schema | matches | PASS |
```

## Output Format

```markdown
## Transform Report: [name]

### Source
[File, format, record count]

### Target
[File, format, record count]

### Transforms Applied
[Table from step 2]

### Validation
[Table from step 5]

### Issues / Decisions
- [Records dropped and why]
- [Ambiguous mappings and chosen resolution]
```

## Execution

Prefer in-place transforms via Read + Write for small files (<5000 records). Use Bash with `jq`, `python`, or `node` for larger datasets. Always read before and after to verify.
