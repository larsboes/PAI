#!/usr/bin/env bash
# Full system health check — CPU, memory, disk, services, recent errors
# Usage: syscheck.sh [--json]
# Outputs structured health report

set -euo pipefail

JSON_MODE=false
[[ "${1:-}" == "--json" ]] && JSON_MODE=true

echo "═══════════════════════════════════════════"
echo "  SYSTEM HEALTH CHECK — $(hostname)"
echo "  $(date -Iseconds)"
echo "═══════════════════════════════════════════"
echo ""

# --- UPTIME & LOAD ---
echo "┌─── Load & Uptime"
uptime
echo ""

# --- MEMORY ---
echo "┌─── Memory"
free -h | grep -E "^(Mem|Swap)"
echo ""
# Check if memory is critical (>90% used)
mem_pct=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
if (( mem_pct > 90 )); then
  echo "  ⚠️  CRITICAL: Memory at ${mem_pct}%"
  echo "  Top memory consumers:"
  ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "    %s %s%% %s\n", $11, $4, $2}'
fi
echo ""

# --- DISK ---
echo "┌─── Disk Usage"
df -h --output=target,pcent,avail -x tmpfs -x devtmpfs | sort -k2 -rn | head -10
echo ""
# Check critical
while read -r mount pct avail; do
  pct_num=${pct%\%}
  if (( pct_num > 90 )); then
    echo "  ⚠️  CRITICAL: $mount at $pct (${avail} free)"
  fi
done < <(df --output=target,pcent,avail -x tmpfs -x devtmpfs | tail -n +2)
echo ""

# --- CPU ---
echo "┌─── CPU"
echo "  Cores: $(nproc)"
echo "  Load: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
# Top CPU processes
echo "  Top CPU consumers:"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "    %-6s %5s%% %s\n", $2, $3, $11}'
echo ""

# --- SERVICES ---
echo "┌─── Failed Services"
failed=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
if (( failed > 0 )); then
  echo "  ⚠️  $failed failed service(s):"
  systemctl --failed --no-legend | awk '{printf "    - %s\n", $1}'
else
  echo "  ✓ No failed services"
fi
echo ""

# --- RECENT ERRORS ---
echo "┌─── Recent Errors (last hour)"
error_count=$(journalctl -p err --since "1 hour ago" --no-pager -q 2>/dev/null | wc -l)
echo "  $error_count error(s) in the last hour"
if (( error_count > 0 )); then
  echo "  Latest:"
  journalctl -p err --since "1 hour ago" --no-pager -q -n 5 2>/dev/null | sed 's/^/    /'
fi
echo ""

# --- NETWORK ---
echo "┌─── Network"
echo "  Listening ports:"
ss -tulnp 2>/dev/null | grep LISTEN | awk '{printf "    %s %s\n", $5, $7}' | head -10
echo ""

# --- SUMMARY ---
echo "═══════════════════════════════════════════"
echo "  Summary:"
[[ $mem_pct -gt 90 ]] && echo "  🔴 Memory critical (${mem_pct}%)" || echo "  🟢 Memory OK (${mem_pct}%)"
[[ $failed -gt 0 ]] && echo "  🔴 $failed failed services" || echo "  🟢 All services healthy"
[[ $error_count -gt 10 ]] && echo "  🟡 $error_count errors/hour" || echo "  🟢 Low error rate"
echo "═══════════════════════════════════════════"
