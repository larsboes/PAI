#!/usr/bin/env bash
# Generate a structured attack matrix for adversarial analysis
# Usage: attack-matrix.sh "TOPIC" [OUTPUT_FILE]
# Creates a markdown template for the 5-phase RedTeam protocol

set -euo pipefail

TOPIC="${1:?Usage: attack-matrix.sh \"TOPIC\" [OUTPUT_FILE]}"
OUTPUT="${2:-/tmp/redteam-$(date +%Y%m%d-%H%M%S).md}"

cat > "$OUTPUT" << EOF
# RedTeam Attack Matrix

**Target:** $TOPIC
**Date:** $(date -Idate)
**Status:** In Progress

---

## Phase 1: Decomposition

Break the argument into atomic claims:

| # | Claim | Type | Confidence |
|---|-------|------|-----------|
| 1 | | fact/assumption/inference | |
| 2 | | fact/assumption/inference | |
| 3 | | fact/assumption/inference | |
| 4 | | fact/assumption/inference | |
| 5 | | fact/assumption/inference | |

---

## Phase 2: Perspective Analysis

| Perspective | Strength Found | Weakness Found | Severity |
|-------------|---------------|----------------|----------|
| Engineer | | | low/med/high/critical |
| Architect | | | |
| Pentester | | | |
| Economist | | | |
| Historian | | | |
| Intern (naive) | | | |
| Regulator | | | |
| End User | | | |

---

## Phase 3: Convergent Findings

Patterns that multiple perspectives agree on:

1. **Strength convergence:**
   -

2. **Weakness convergence:**
   -

3. **Critical blind spots:**
   -

---

## Phase 4: Steelman

> *The strongest possible version of this argument:*

1.
2.
3.
4.
5.
6.
7.
8.

---

## Phase 5: Counter-Argument

> *The strongest rebuttal:*

**Core fatal flaw:**


**Supporting points:**

1.
2.
3.
4.
5.
6.
7.
8.

---

## Verdict

**Kill shot (the ONE thing that could collapse this):**


**Risk level:** [ ] Acceptable  [ ] Concerning  [ ] Fatal
EOF

echo "Attack matrix generated: $OUTPUT"
