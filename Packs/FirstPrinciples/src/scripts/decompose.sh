#!/usr/bin/env bash
# Generate a first-principles decomposition document
# Usage: decompose.sh "PROBLEM" [OUTPUT_FILE]

set -euo pipefail

PROBLEM="${1:?Usage: decompose.sh \"PROBLEM\" [OUTPUT_FILE]}"
OUTPUT="${2:-/tmp/first-principles-$(date +%Y%m%d-%H%M%S).md}"

cat > "$OUTPUT" << EOF
# First Principles Decomposition

**Problem:** $PROBLEM
**Date:** $(date -Idate)

---

## Step 1: DECONSTRUCT — What is this really made of?

### Constituent Parts
| # | Component | Can be broken down further? |
|---|-----------|---------------------------|
| 1 | | yes/no |
| 2 | | yes/no |
| 3 | | yes/no |
| 4 | | yes/no |
| 5 | | yes/no |

### Fundamental Truths (irreducible facts)
1.
2.
3.

---

## Step 2: CHALLENGE — What are we assuming?

| # | Assumption | Source | Actually True? | Evidence |
|---|-----------|--------|---------------|----------|
| 1 | | convention/authority/habit | yes/no/unknown | |
| 2 | | convention/authority/habit | yes/no/unknown | |
| 3 | | convention/authority/habit | yes/no/unknown | |
| 4 | | convention/authority/habit | yes/no/unknown | |
| 5 | | convention/authority/habit | yes/no/unknown | |

### Constraints Classification
| Constraint | Type | Real? |
|-----------|------|-------|
| | hard (physics, math, law) | ✓ definitely |
| | soft (convention, habit) | ? maybe not |
| | assumed (never questioned) | ✗ probably not |

---

## Step 3: RECONSTRUCT — Rebuild from verified truths

### Only working with:
- Verified truth 1:
- Verified truth 2:
- Verified truth 3:
- Hard constraint 1:
- Hard constraint 2:

### What solution emerges from ONLY these foundations?



### How is this different from the conventional approach?

| Aspect | Conventional | First Principles |
|--------|-------------|-----------------|
| | | |
| | | |
| | | |

---

## Verdict

**Biggest assumption that was wrong:**


**New solution that becomes possible:**


EOF

echo "Decomposition template: $OUTPUT"
