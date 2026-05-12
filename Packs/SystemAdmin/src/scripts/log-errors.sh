#!/usr/bin/env bash
# Aggregate recent errors across all services + kernel
# Usage: log-errors.sh [--since "TIME"] [--top N]
# Defaults: since="1 hour ago", top=20

set -euo pipefail

SINCE="${2:-1 hour ago}"
TOP=20

while [[ $# -gt 0 ]]; do
  case "$1" in
    --since) SINCE="$2"; shift 2 ;;
    --top) TOP="$2"; shift 2 ;;
    *) shift ;;
  esac
done

echo "=== System Errors since: $SINCE ==="
echo ""

# Count by service
echo "┌─── Errors by Service (top $TOP)"
journalctl -p err --since "$SINCE" --no-pager -o json 2>/dev/null \
  | jq -r '._SYSTEMD_UNIT // .SYSLOG_IDENTIFIER // "unknown"' \
  | sort | uniq -c | sort -rn | head -"$TOP" \
  | awk '{printf "  %5d  %s\n", $1, $2}'
echo ""

# Latest critical/emergency
echo "┌─── Critical & Emergency"
crit=$(journalctl -p crit --since "$SINCE" --no-pager -q 2>/dev/null | wc -l)
if (( crit > 0 )); then
  echo "  ⚠️  $crit critical messages:"
  journalctl -p crit --since "$SINCE" --no-pager -q -n 10 2>/dev/null | sed 's/^/    /'
else
  echo "  ✓ No critical/emergency messages"
fi
echo ""

# Kernel errors (hardware, OOM, etc.)
echo "┌─── Kernel Errors"
kernel_err=$(journalctl -k -p err --since "$SINCE" --no-pager -q 2>/dev/null | wc -l)
if (( kernel_err > 0 )); then
  echo "  $kernel_err kernel errors:"
  journalctl -k -p err --since "$SINCE" --no-pager -q -n 5 2>/dev/null | sed 's/^/    /'
  
  # Check for OOM
  oom=$(journalctl -k --since "$SINCE" --no-pager 2>/dev/null | grep -c "Out of memory" || true)
  (( oom > 0 )) && echo "  🔴 OOM killer invoked $oom time(s)!"
else
  echo "  ✓ No kernel errors"
fi
echo ""

# Auth failures
echo "┌─── Auth Failures"
auth_fail=$(journalctl --since "$SINCE" --no-pager -q 2>/dev/null | grep -ci "authentication failure\|failed password\|invalid user" || true)
echo "  $auth_fail authentication failure(s)"
if (( auth_fail > 5 )); then
  echo "  ⚠️  Possible brute force — check IPs:"
  journalctl --since "$SINCE" --no-pager 2>/dev/null \
    | grep -i "failed password" | grep -oP 'from \K[\d.]+' \
    | sort | uniq -c | sort -rn | head -5 | sed 's/^/    /'
fi
