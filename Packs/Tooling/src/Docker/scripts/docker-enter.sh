#!/usr/bin/env bash
# Enter any running container — auto-detects available shell
# Usage: docker-enter.sh [CONTAINER_NAME_OR_ID]
# If no name given, shows running containers to pick from

set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Running containers:"
  echo ""
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | nl -w3 -s') '
  echo ""
  read -rp "Enter container name/number: " selection
  
  if [[ "$selection" =~ ^[0-9]+$ ]]; then
    CONTAINER=$(docker ps --format "{{.Names}}" | sed -n "${selection}p")
  else
    CONTAINER="$selection"
  fi
else
  CONTAINER="$1"
fi

# Auto-detect shell
for shell in /bin/bash /bin/sh /bin/ash; do
  if docker exec "$CONTAINER" test -f "$shell" 2>/dev/null; then
    echo "Entering $CONTAINER with $shell..."
    exec docker exec -it "$CONTAINER" "$shell"
  fi
done

echo "ERROR: No shell found in container $CONTAINER" >&2
exit 1
