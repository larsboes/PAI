#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  install-hooks — Wire .pai-fork into this repo (one-time setup)
#
#  Idempotent. Sets:
#    - core.hooksPath = .pai-fork/git-hooks
#    - merge.pai-fork-3way.driver = .pai-fork/tools/merge-driver.sh
#  Then regenerates .gitattributes from manifest.yaml so manifested files
#  use the 3-way merge driver during `git merge upstream/main`.
#
#  Run once per fresh clone.
# ═══════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$FORK_DIR/.." && pwd)"
HOOKS_DIR="$FORK_DIR/git-hooks"

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; RESET='\033[0m'

cd "$REPO_DIR"

# Make scripts executable
chmod +x "$HOOKS_DIR"/* 2>/dev/null || true
chmod +x "$FORK_DIR"/tools/*.sh 2>/dev/null || true

# Set hooksPath (repo-local — does NOT touch global config)
git config --local core.hooksPath ".pai-fork/git-hooks"

# Register the 3-way merge driver (repo-local)
git config --local merge.pai-fork-3way.name "PAI fork 3-way merge for manifested files"
git config --local merge.pai-fork-3way.driver ".pai-fork/tools/merge-driver.sh %O %A %B %P"

current_hooks="$(git config --local --get core.hooksPath)"
current_driver="$(git config --local --get merge.pai-fork-3way.driver)"

echo -e "  ${GREEN}✓${RESET} core.hooksPath = ${BLUE}$current_hooks${RESET}"
echo -e "  ${GREEN}✓${RESET} merge driver registered: ${BLUE}pai-fork-3way${RESET}"
echo -e "      ${BLUE}$current_driver${RESET}"
echo
echo "  Active hooks:"
for h in "$HOOKS_DIR"/*; do
  [[ -f "$h" && -x "$h" ]] && echo -e "    ${GREEN}✓${RESET} $(basename "$h")"
done
echo
echo "  Rebuilding .gitattributes from manifest..."
"$FORK_DIR/tools/rebuild-gitattributes.sh"
echo
echo -e "  ${YELLOW}Note:${RESET} this is repo-local. Re-run after a fresh clone."
