#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  rebuild-gitattributes — Sync manifested paths into .gitattributes
#
#  Maintains a marked block at the bottom of .gitattributes that maps every
#  manifested path to the pai-fork-3way merge driver. Block is auto-managed
#  between BEGIN/END markers — anything outside the markers is preserved.
#
#  Usage:
#    rebuild-gitattributes.sh          # regenerate from manifest.yaml
#
#  Run by pre-commit when manifest.yaml or .gitattributes changes.
# ═══════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$FORK_DIR/.." && pwd)"
MANIFEST="$FORK_DIR/manifest.yaml"
GITATTR="$REPO_DIR/.gitattributes"

BEGIN_MARKER="# >>> pai-fork manifested paths (auto-managed — do not edit)"
END_MARKER="# <<< end pai-fork manifested paths"

read_manifest_paths() {
  grep -E '^\s*-\s*path:' "$MANIFEST" 2>/dev/null \
    | sed -E 's/^\s*-\s*path:\s*//;s/\s*$//' | sort -u
}

# Extract content OUTSIDE the marked block (preserve hand-edited stuff)
preserve_outside_block() {
  awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
    $0 == begin { skip=1; next }
    $0 == end   { skip=0; next }
    skip != 1   { print }
  ' "$GITATTR"
}

# Build new file
{
  preserve_outside_block | sed -E '/^$/N;/^\n$/D'  # collapse double blank lines
  echo
  echo "$BEGIN_MARKER"
  echo "# Manifested files use 3-way merge driver — preserves both sides on git merge"
  echo "# Driver registered in .git/config (run .pai-fork/tools/install-hooks.sh once)"
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    echo "$p merge=pai-fork-3way"
  done < <(read_manifest_paths)
  echo "$END_MARKER"
} > "$GITATTR.tmp"

mv "$GITATTR.tmp" "$GITATTR"

echo "✓ Rebuilt $GITATTR ($(read_manifest_paths | wc -l) manifested paths)"
