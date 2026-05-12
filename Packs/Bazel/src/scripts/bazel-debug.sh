#!/bin/bash
# bazel-debug.sh — Common Bazel debugging commands
# Usage: ./bazel-debug.sh <command> [target]
#
# Commands:
#   deps <target>     — Show dependency tree
#   rdeps <target>    — Show reverse dependencies (who uses this?)
#   actions <target>  — Show actions that would execute
#   tests             — List all test targets
#   changed           — Show targets affected by uncommitted changes
#   graph <target>    — Generate dependency graph (requires graphviz)
#   cache-stats       — Show cache hit/miss statistics
#   profile <target>  — Profile a build and print summary

set -euo pipefail

CMD="${1:-help}"
TARGET="${2:-//...}"

case "$CMD" in
  deps)
    echo "=== Dependencies of $TARGET ==="
    bazel query "deps($TARGET)" --output=label 2>/dev/null | sort
    ;;
  rdeps)
    echo "=== Reverse dependencies of $TARGET ==="
    bazel query "rdeps(//..., $TARGET)" --output=label 2>/dev/null | sort
    ;;
  actions)
    echo "=== Actions for $TARGET ==="
    bazel aquery "$TARGET" 2>/dev/null | grep -E "^action|Mnemonic:|Input:|Output:"
    ;;
  tests)
    echo "=== All test targets ==="
    bazel query "kind(test, //...)" --output=label 2>/dev/null | sort
    ;;
  changed)
    echo "=== Targets affected by uncommitted changes ==="
    CHANGED_DIRS=$(git diff --name-only HEAD 2>/dev/null | sed 's|/[^/]*$||' | sort -u | sed 's|^|//|;s|$|/...|')
    if [ -z "$CHANGED_DIRS" ]; then
      echo "No uncommitted changes"
    else
      bazel query "set($CHANGED_DIRS)" --output=label 2>/dev/null | sort
    fi
    ;;
  graph)
    echo "=== Dependency graph for $TARGET ==="
    if ! command -v dot &>/dev/null; then
      echo "ERROR: graphviz not installed (need 'dot' command)"
      echo "  Install: sudo apt install graphviz"
      exit 1
    fi
    OUTPUT="bazel-deps-graph.png"
    bazel query "deps($TARGET)" --output=graph 2>/dev/null | dot -Tpng > "$OUTPUT"
    echo "Written to: $OUTPUT"
    ;;
  cache-stats)
    echo "=== Cache statistics ==="
    bazel build $TARGET --execution_log_json_file=/tmp/bazel_exec.json 2>&1 | tail -5
    echo ""
    echo "Full execution log: /tmp/bazel_exec.json"
    if [ -f /tmp/bazel_exec.json ]; then
      echo "Actions: $(wc -l < /tmp/bazel_exec.json)"
      echo "Cache hits: $(grep -c '"remoteCacheHit":true' /tmp/bazel_exec.json 2>/dev/null || echo 0)"
    fi
    ;;
  profile)
    echo "=== Profiling $TARGET ==="
    PROFILE="/tmp/bazel_profile.json"
    bazel build "$TARGET" --profile="$PROFILE" 2>&1
    echo ""
    echo "Profile written to: $PROFILE"
    echo "Open in Chrome: chrome://tracing (load the file)"
    echo ""
    echo "Quick summary:"
    bazel analyze-profile "$PROFILE" 2>/dev/null || echo "(analyze-profile not available in this version)"
    ;;
  help|*)
    echo "Bazel Debug Helper"
    echo ""
    echo "Usage: $0 <command> [target]"
    echo ""
    echo "Commands:"
    echo "  deps <target>     Show dependency tree"
    echo "  rdeps <target>    Show reverse dependencies"
    echo "  actions <target>  Show actions that would execute"
    echo "  tests             List all test targets"
    echo "  changed           Targets affected by uncommitted changes"
    echo "  graph <target>    Generate PNG dependency graph (needs graphviz)"
    echo "  cache-stats       Build and show cache hit/miss stats"
    echo "  profile <target>  Profile a build"
    echo ""
    echo "Examples:"
    echo "  $0 deps //tests:gk_notruf_demo"
    echo "  $0 rdeps //logstash:logstash.conf"
    echo "  $0 tests"
    echo "  $0 changed"
    ;;
esac
