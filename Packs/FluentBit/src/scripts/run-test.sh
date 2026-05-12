#!/bin/bash
# run-test.sh — Run FluentBit test configs and report results
# Usage: ./run-test.sh [filter-name|all] [--verbose]
#
# Expects: tests/configs/<filter>/*.yaml
# Requires: fluent-bit in PATH

set -euo pipefail

TESTS_DIR="${TESTS_DIR:-tests}"
FILTER="${1:-all}"
VERBOSE="${2:-}"
FAILED=0
PASSED=0
TOTAL=0

run_config() {
    local config="$1"
    local name
    name=$(basename "$config" .yaml)
    TOTAL=$((TOTAL + 1))

    if [ "$VERBOSE" = "--verbose" ] || [ "$VERBOSE" = "-v" ]; then
        echo -n "  $name ... "
        if fluent-bit -c "$config" 2>&1; then
            echo "PASS"
            PASSED=$((PASSED + 1))
        else
            echo "FAIL (exit $?)"
            FAILED=$((FAILED + 1))
        fi
    else
        if fluent-bit -c "$config" > /dev/null 2>&1; then
            echo "  $name ... PASS"
            PASSED=$((PASSED + 1))
        else
            echo "  $name ... FAIL"
            # Re-run to show error output
            fluent-bit -c "$config" 2>&1 | grep -E "FAIL|VIOLATION|ERROR" || true
            FAILED=$((FAILED + 1))
        fi
    fi
}

echo "======================================================"
echo "  FluentBit Test Runner"
echo "======================================================"
echo ""

if [ "$FILTER" = "all" ]; then
    for dir in "$TESTS_DIR"/configs/*/; do
        [ -d "$dir" ] || continue
        filter_name=$(basename "$dir")
        echo "[$filter_name]"
        for config in "$dir"*.yaml; do
            [ -f "$config" ] || continue
            run_config "$config"
        done
        echo ""
    done
else
    echo "[$FILTER]"
    for config in "$TESTS_DIR/configs/$FILTER/"*.yaml; do
        [ -f "$config" ] || { echo "  No configs found for $FILTER"; break; }
        run_config "$config"
    done
fi

echo "======================================================"
echo "  Results: $PASSED passed, $FAILED failed, $TOTAL total"
echo "======================================================"

[ "$FAILED" -eq 0 ] || exit 1
