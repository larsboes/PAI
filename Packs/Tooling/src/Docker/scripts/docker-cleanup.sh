#!/usr/bin/env bash
# Smart Docker cleanup — removes stopped containers, dangling images, unused volumes
# Usage: docker-cleanup.sh [--aggressive]
# --aggressive: also removes all unused images (not just dangling)

set -euo pipefail

AGGRESSIVE=false
[[ "${1:-}" == "--aggressive" ]] && AGGRESSIVE=true

echo "=== Docker Cleanup ==="
echo ""

# Stopped containers
stopped=$(docker ps -aq --filter "status=exited" --filter "status=dead" 2>/dev/null | wc -l)
if (( stopped > 0 )); then
  echo "Removing $stopped stopped containers..."
  docker container prune -f
else
  echo "No stopped containers."
fi

echo ""

# Dangling images (or all unused)
if [[ "$AGGRESSIVE" == "true" ]]; then
  unused=$(docker images -q --filter "dangling=false" --filter "reference!=*:latest" | wc -l)
  echo "Removing ALL unused images..."
  docker image prune -af
else
  dangling=$(docker images -qf "dangling=true" | wc -l)
  if (( dangling > 0 )); then
    echo "Removing $dangling dangling images..."
    docker image prune -f
  else
    echo "No dangling images."
  fi
fi

echo ""

# Unused volumes
volumes=$(docker volume ls -qf "dangling=true" | wc -l)
if (( volumes > 0 )); then
  echo "Removing $volumes unused volumes..."
  docker volume prune -f
else
  echo "No unused volumes."
fi

echo ""

# Build cache
echo "Removing build cache..."
docker builder prune -f 2>/dev/null || true

echo ""
echo "=== Space Reclaimed ==="
docker system df
