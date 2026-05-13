#!/usr/bin/env bash
# Delete branches that have been merged into main/master
# Usage: git-cleanup.sh [--remote] [--dry-run]
# Skips: main, master, develop, current branch

set -euo pipefail

DRY_RUN=false
REMOTE=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --remote) REMOTE=true ;;
  esac
done

# Detect default branch
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
CURRENT=$(git branch --show-current)

PROTECTED="main|master|develop|$CURRENT"

echo "Default branch: $DEFAULT_BRANCH"
echo "Current branch: $CURRENT"
echo "---"

# Local merged branches
merged=$(git branch --merged "$DEFAULT_BRANCH" | grep -v -E "^\*|($PROTECTED)" | sed 's/^[[:space:]]*//' || true)

if [[ -n "$merged" ]]; then
  echo "Merged local branches:"
  while IFS= read -r branch; do
    echo "  - $branch"
    if [[ "$DRY_RUN" == "false" ]]; then
      git branch -d "$branch"
    fi
  done <<< "$merged"
else
  echo "No merged local branches to clean."
fi

# Remote merged branches
if [[ "$REMOTE" == "true" ]]; then
  echo ""
  echo "Checking remote merged branches..."
  git fetch --prune origin
  
  remote_merged=$(git branch -r --merged "origin/$DEFAULT_BRANCH" | grep -v -E "HEAD|($PROTECTED)" | sed 's@origin/@@;s/^[[:space:]]*//' || true)
  
  if [[ -n "$remote_merged" ]]; then
    echo "Merged remote branches:"
    while IFS= read -r branch; do
      echo "  - origin/$branch"
      if [[ "$DRY_RUN" == "false" ]]; then
        git push origin --delete "$branch"
      fi
    done <<< "$remote_merged"
  else
    echo "No merged remote branches to clean."
  fi
fi

[[ "$DRY_RUN" == "true" ]] && echo -e "\n(DRY RUN — no branches were deleted)"
