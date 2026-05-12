#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  add-customization — Append a path + reason to manifest.yaml
#
#  Usage:
#    add-customization.sh <path> "<reason>"
#
#  Example:
#    add-customization.sh Packs/Foo/SKILL.md "Added Bar workflow integration"
# ═══════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$FORK_DIR/.." && pwd)"
MANIFEST="$FORK_DIR/manifest.yaml"

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; BOLD='\033[1m'; RESET='\033[0m'

if [[ $# -lt 2 ]]; then
  echo -e "${BOLD}Usage:${RESET} $(basename "$0") <path> \"<reason>\""
  echo
  echo "Example:"
  echo "  $(basename "$0") Packs/Foo/SKILL.md \"Added Bar workflow integration\""
  exit 1
fi

PATH_REL="$1"
REASON="$2"

# Validate path exists
if [[ ! -f "$REPO_DIR/$PATH_REL" ]]; then
  echo -e "  ${RED}✗${RESET} File does not exist: $PATH_REL"
  exit 1
fi

# Check if already in manifest
if grep -qF "path: $PATH_REL" "$MANIFEST"; then
  echo -e "  ${YELLOW}⚠${RESET} Already in manifest: $PATH_REL"
  exit 0
fi

# Append entry
TODAY="$(date +%Y-%m-%d)"
cat >> "$MANIFEST" <<EOF

  - path: $PATH_REL
    reason: $REASON
    added: $TODAY
EOF

echo -e "  ${GREEN}✓${RESET} Added to manifest:"
echo -e "      ${BOLD}$PATH_REL${RESET}"
echo -e "      reason: $REASON"
