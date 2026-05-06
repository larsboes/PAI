#!/usr/bin/env bash
# Check port status — open? who owns it? firewall?
# Usage: port-check.sh PORT [HOST]

set -euo pipefail

PORT="${1:?Usage: port-check.sh PORT [HOST]}"
HOST="${2:-localhost}"

echo "=== Port $PORT on $HOST ==="
echo ""

# 1. Is something listening?
echo "┌─── Listening Process"
listener=$(ss -tlnp "sport = :$PORT" 2>/dev/null | tail -n +2)
if [[ -n "$listener" ]]; then
  echo "  ✓ Port $PORT is OPEN"
  echo "$listener" | awk '{printf "    %s → %s\n", $4, $6}'
  
  # Get PID and process name
  pid=$(echo "$listener" | grep -oP 'pid=\K[0-9]+' | head -1)
  if [[ -n "$pid" ]]; then
    echo "  Process: $(ps -p "$pid" -o comm= 2>/dev/null) (PID $pid)"
    echo "  User: $(ps -p "$pid" -o user= 2>/dev/null)"
    echo "  CMD: $(ps -p "$pid" -o args= 2>/dev/null)"
  fi
else
  echo "  ✗ Nothing listening on port $PORT"
fi
echo ""

# 2. Can we connect?
echo "┌─── Connectivity Test"
if timeout 3 bash -c "echo >/dev/tcp/$HOST/$PORT" 2>/dev/null; then
  echo "  ✓ TCP connection to $HOST:$PORT succeeded"
else
  echo "  ✗ Cannot connect to $HOST:$PORT"
fi
echo ""

# 3. Firewall rules
echo "┌─── Firewall"
if command -v nft &>/dev/null; then
  rules=$(nft list ruleset 2>/dev/null | grep -i "dport $PORT" || true)
  if [[ -n "$rules" ]]; then
    echo "  nftables rules for port $PORT:"
    echo "$rules" | sed 's/^/    /'
  else
    echo "  No specific nftables rules for port $PORT"
  fi
elif command -v iptables &>/dev/null; then
  rules=$(iptables -L -n 2>/dev/null | grep -i "dpt:$PORT" || true)
  if [[ -n "$rules" ]]; then
    echo "  iptables rules for port $PORT:"
    echo "$rules" | sed 's/^/    /'
  else
    echo "  No specific iptables rules for port $PORT"
  fi
elif command -v ufw &>/dev/null; then
  ufw status 2>/dev/null | grep "$PORT" | sed 's/^/  /' || echo "  No ufw rules for port $PORT"
fi
echo ""

# 4. Recent connection attempts
echo "┌─── Active Connections"
connections=$(ss -tnp "dport = :$PORT or sport = :$PORT" 2>/dev/null | tail -n +2 | wc -l)
echo "  $connections active connections involving port $PORT"
if (( connections > 0 )); then
  ss -tnp "dport = :$PORT or sport = :$PORT" 2>/dev/null | tail -n +2 | head -5 | sed 's/^/    /'
fi
