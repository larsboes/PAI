#!/usr/bin/env bash
# Show recently touched branches with last commit date and relative age
# Usage: git-recent.sh [--all] [--count N]

set -euo pipefail

COUNT="${2:-15}"
REFS="refs/heads"
[[ "${1:-}" == "--all" ]] && REFS="refs/heads refs/remotes"

git for-each-ref --sort=-committerdate \
  --format='%(committerdate:relative)|%(refname:short)|%(subject)' \
  $REFS | head -"$COUNT" | while IFS='|' read -r date branch subject; do
  printf "%-20s %-40s %s\n" "$date" "$branch" "${subject:0:60}"
done
