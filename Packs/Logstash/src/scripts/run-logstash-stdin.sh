#!/bin/bash
# run-logstash-stdin.sh — Reliable Logstash CI runner using stdin per file
# Usage: ./run-logstash-stdin.sh <test-dir> <filter-config> [input-ext] [output-ext]
#
# Processes each input file through Logstash via stdin, bypassing broken file input.
# Requires: logstash in PATH (or run inside Logstash Docker container)

set -euo pipefail

TEST_DIR="${1:?Usage: $0 <test-dir> <filter-config> [input-ext] [output-ext]}"
FILTER_CONFIG="${2:?Usage: $0 <test-dir> <filter-config> [input-ext] [output-ext]}"
INPUT_EXT="${3:-ndjson}"
OUTPUT_EXT="${4:-output}"

FAILED=0
PASSED=0

echo "======================================================"
echo "  Logstash Stdin Runner"
echo "======================================================"
echo "  Test dir:    $TEST_DIR"
echo "  Filter:      $FILTER_CONFIG"
echo "  Input ext:   $INPUT_EXT"
echo "  Output ext:  $OUTPUT_EXT"
echo ""

# Extract just the filter block from the config
# (strips input/output, keeps only filter section)
FILTER_BLOCK=$(sed -n '/^filter {/,/^}/p' "$FILTER_CONFIG")

if [ -z "$FILTER_BLOCK" ]; then
    echo "ERROR: No 'filter { ... }' block found in $FILTER_CONFIG"
    exit 1
fi

for input_file in $(find "$TEST_DIR" -name "*.${INPUT_EXT}" -type f | sort); do
    output_file="${input_file}_${OUTPUT_EXT}"
    name=$(basename "$input_file")
    echo -n "  $name ... "

    # Pipe through Logstash with inline config
    if cat "$input_file" | logstash -e "
        input { stdin { codec => json_lines } }
        ${FILTER_BLOCK}
        output { file { path => \"${output_file}\" codec => json_lines } }
    " 2>/dev/null; then
        if [ -f "$output_file" ]; then
            echo "PASS ($output_file)"
            PASSED=$((PASSED + 1))
        else
            echo "FAIL (no output file created)"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "FAIL (logstash exit $?)"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "======================================================"
echo "  Results: $PASSED passed, $FAILED failed"
echo "======================================================"

[ "$FAILED" -eq 0 ] || exit 1
