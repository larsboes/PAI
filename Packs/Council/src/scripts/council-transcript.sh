#!/usr/bin/env bash
# Format and save a council debate transcript
# Usage: council-transcript.sh "TOPIC" [OUTPUT_DIR]
# Creates a structured markdown transcript template

set -euo pipefail

TOPIC="${1:?Usage: council-transcript.sh \"TOPIC\" [OUTPUT_DIR]}"
OUTPUT_DIR="${2:-$HOME/.pai/artifacts/councils}"
FILENAME="$(date +%Y%m%d-%H%M%S)_$(echo "$TOPIC" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | cut -c1-40).md"

mkdir -p "$OUTPUT_DIR"
OUTPUT="$OUTPUT_DIR/$FILENAME"

cat > "$OUTPUT" << EOF
# Council Debate: $TOPIC

**Date:** $(date -Idate)
**Rounds:** 3
**Members:** [to be filled]

---

## Round 1 — Opening Positions

### 🔵 Member 1: [Role]
> [Opening position]

### 🟢 Member 2: [Role]
> [Opening position]

### 🟡 Member 3: [Role]
> [Opening position]

### 🔴 Member 4: [Role]
> [Opening position]

---

## Round 2 — Direct Responses

### 🔵 Member 1 responds to Member 3:
> [Response addressing specific points]

### 🟢 Member 2 responds to Member 1:
> [Response addressing specific points]

### 🟡 Member 3 responds to Member 4:
> [Response addressing specific points]

### 🔴 Member 4 responds to Member 2:
> [Response addressing specific points]

---

## Round 3 — Final Positions (Updated)

### 🔵 Member 1:
> [Updated position after hearing others]

### 🟢 Member 2:
> [Updated position after hearing others]

### 🟡 Member 3:
> [Updated position after hearing others]

### 🔴 Member 4:
> [Updated position after hearing others]

---

## Synthesis

**Convergence points (all agree):**
-

**Key tensions (unresolved):**
-

**Recommended path:**


**Confidence level:** [ ] High  [ ] Medium  [ ] Low
EOF

echo "Council transcript: $OUTPUT"
