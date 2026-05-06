#!/usr/bin/env bash
# Find largest files and directories consuming disk space
# Usage: disk-hogs.sh [PATH] [--depth N] [--min-size SIZE]
# Defaults: PATH=/, depth=3, min-size=100M

set -euo pipefail

SEARCH_PATH="${1:-/}"
DEPTH=3
MIN_SIZE="100M"

shift 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --depth) DEPTH="$2"; shift 2 ;;
    --min-size) MIN_SIZE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

echo "=== Disk Hogs: $SEARCH_PATH (depth=$DEPTH, min=$MIN_SIZE) ==="
echo ""

# Top directories by size
echo "┌─── Largest Directories"
du -h --max-depth="$DEPTH" "$SEARCH_PATH" 2>/dev/null | sort -rh | head -20 | sed 's/^/  /'
echo ""

# Large files
echo "┌─── Large Files (>$MIN_SIZE)"
find "$SEARCH_PATH" -type f -size "+${MIN_SIZE}" -exec ls -lh {} \; 2>/dev/null \
  | awk '{printf "  %s %s %s %s\n", $5, $6, $7, $NF}' \
  | sort -rh | head -20
echo ""

# Recently modified large files (might be growing logs)
echo "┌─── Recently Modified Large Files (last 24h)"
find "$SEARCH_PATH" -type f -size +10M -mtime -1 -exec ls -lh {} \; 2>/dev/null \
  | awk '{printf "  %s %s\n", $5, $NF}' \
  | sort -rh | head -10
echo ""

# Inode usage
echo "┌─── Inode Usage"
df -i "$SEARCH_PATH" | head -2 | sed 's/^/  /'
