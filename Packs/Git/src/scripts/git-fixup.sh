#!/usr/bin/env bash
# Quick fixup commit — creates fixup for a target commit
# Usage: git-fixup.sh [COMMIT_HASH]
# If no hash given, shows recent commits to pick from

set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Recent commits — pick one to fixup:"
  echo ""
  git log --oneline -15 | nl -w3 -s') '
  echo ""
  read -rp "Enter number (or commit hash): " selection
  
  if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection <= 15 )); then
    COMMIT=$(git log --oneline -15 | sed -n "${selection}p" | awk '{print $1}')
  else
    COMMIT="$selection"
  fi
else
  COMMIT="$1"
fi

# Verify commit exists
if ! git cat-file -t "$COMMIT" &>/dev/null; then
  echo "ERROR: Commit '$COMMIT' not found" >&2
  exit 1
fi

echo "Creating fixup for: $(git log --oneline -1 "$COMMIT")"
git commit --fixup="$COMMIT"

echo ""
echo "To apply: git rebase -i --autosquash ${COMMIT}~1"
read -rp "Apply now? [y/N] " apply
if [[ "$apply" =~ ^[yY] ]]; then
  GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash "${COMMIT}~1"
  echo "Done! Fixup applied."
fi
