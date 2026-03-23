# Workflow: profile

Exploratory data analysis on any dataset — JSON, CSV, JSONL, Parquet, or database exports.

## Process

### 1. Identify & Load

Determine file format and structure:
- JSON: single object, array of objects, nested, or JSONL
- CSV: delimiter, header row, quoting, encoding
- Directory: multiple files, naming convention, partitioning scheme

Read a sample (first 50-100 records) to understand shape before full analysis.

### 2. Structural Profile

```markdown
## Dataset Profile: [name]

| Metric | Value |
|--------|-------|
| Format | JSON / CSV / JSONL |
| Records | N |
| Fields | N |
| Nesting depth | N |
| File size | N KB/MB |
| Encoding | UTF-8 / ... |
```

### 3. Field-Level Analysis

For each field:

```markdown
| Field | Type | Nulls | Unique | Min | Max | Mean/Mode | Notes |
|-------|------|-------|--------|-----|-----|-----------|-------|
| id | string | 0% | 100% | — | — | — | UUID format, candidate PK |
| temp_c | float | 2.1% | — | -12.3 | 44.8 | 22.1 | Normal dist, 3 outliers >40 |
| status | string | 0% | 5 | — | — | "nominal" (78%) | Enum candidate |
```

### 4. Relationship Detection

- Identify candidate primary keys (100% unique, non-null)
- Identify candidate foreign keys (field names matching PK patterns in other files)
- Check referential integrity if multiple files present
- Note 1:1, 1:N, N:M relationships

### 5. Quality Assessment

```markdown
## Data Quality Score

| Dimension | Score | Issues |
|-----------|-------|--------|
| Completeness | 94% | 3 fields >5% null |
| Consistency | 87% | Mixed date formats in `created_at` |
| Accuracy | — | No reference data to validate against |
| Timeliness | OK | Most recent record: 2h ago |
| Uniqueness | 99% | 2 near-duplicate records (fuzzy match) |
```

### 6. Recommendations

Based on findings, suggest:
- Schema improvements (type tightening, enum extraction)
- Data quality fixes (null handling, format normalization)
- Index candidates (high-cardinality fields used in lookups)
- Partitioning strategy (if time-series or high-volume)

## Output Format

```markdown
## EDA Report: [dataset name]

### Overview
[1-2 sentence description of what this data represents]

### Structure
[Table from step 2]

### Fields
[Table from step 3]

### Relationships
[Findings from step 4]

### Quality
[Table from step 5]

### Recommendations
1. ...
2. ...
```

## Execution

Use Read to sample files, Bash for `wc -l`, `jq`, `head`, or `csvstat` if available. For large files, sample rather than read entire contents.
