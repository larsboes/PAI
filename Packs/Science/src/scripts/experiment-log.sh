#!/usr/bin/env bash
# Track experiment iterations in a structured log
# Usage: experiment-log.sh init "GOAL" | add "HYPOTHESIS" "RESULT" | show
# Maintains a running experiment log file

set -euo pipefail

LOG_DIR="${EXPERIMENT_DIR:-/tmp/experiments}"
LOG_FILE="$LOG_DIR/current-experiment.md"

ACTION="${1:?Usage: experiment-log.sh init|add|show [args]}"
shift

case "$ACTION" in
  init)
    GOAL="${1:?Missing GOAL}"
    mkdir -p "$LOG_DIR"
    cat > "$LOG_FILE" << EOF
# Experiment Log

**Goal:** $GOAL
**Started:** $(date -Iminutes)
**Status:** Active

---

## Success Criteria

- [ ] [Define what success looks like]

---

## Iterations

EOF
    echo "Experiment initialized: $LOG_FILE"
    echo "Goal: $GOAL"
    ;;
    
  add)
    HYPOTHESIS="${1:?Missing HYPOTHESIS}"
    RESULT="${2:-[pending]}"
    
    if [[ ! -f "$LOG_FILE" ]]; then
      echo "ERROR: No active experiment. Run: experiment-log.sh init \"GOAL\"" >&2
      exit 1
    fi
    
    # Count existing iterations
    ITER=$(grep -c "^### Iteration" "$LOG_FILE" 2>/dev/null || echo 0)
    ITER=$((ITER + 1))
    
    cat >> "$LOG_FILE" << EOF

### Iteration $ITER — $(date -Iminutes)

**Hypothesis:** $HYPOTHESIS

**Experiment:** [describe what you did]

**Result:** $RESULT

**Conclusion:** [ ] Confirmed  [ ] Refuted  [ ] Inconclusive

**Next:** [what to try based on this result]

---
EOF
    echo "Added iteration $ITER to experiment log"
    ;;
    
  show)
    if [[ ! -f "$LOG_FILE" ]]; then
      echo "No active experiment."
      exit 0
    fi
    cat "$LOG_FILE"
    ;;
    
  close)
    VERDICT="${1:-[no verdict]}"
    cat >> "$LOG_FILE" << EOF

## Final Verdict

**Conclusion:** $VERDICT
**Completed:** $(date -Iminutes)
**Total iterations:** $(grep -c "^### Iteration" "$LOG_FILE")
EOF
    echo "Experiment closed."
    cat "$LOG_FILE"
    ;;
    
  *)
    echo "Usage: experiment-log.sh init|add|show|close [args]"
    exit 1
    ;;
esac
