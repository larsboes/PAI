#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  merge-driver — 3-way merge for upstream-sync customizations
#
#  Invoked by git when sync.sh apply hits a manifested file. Instead of
#  blindly taking upstream, runs a 3-way merge:
#    %O = base (last common ancestor — previous upstream)
#    %A = ours (current local)
#    %B = theirs (new upstream)
#
#  Strategy:
#    1. Try `git merge-file` for clean 3-way merge
#    2. If conflicts, leave conflict markers in OURS for manual resolution
#       AND copy ours+theirs to .pai-fork/backups/{ts}/conflict-pairs/
#    3. Always exit 0 — git treats any exit code as "auto-resolved"; we let
#       the pre-commit hook surface unresolved <<<<<<< markers
#
#  Configured via:
#    [merge "pai-fork-3way"]
#      name = PAI fork 3-way merge for manifested files
#      driver = .pai-fork/tools/merge-driver.sh %O %A %B %P
#  And .gitattributes pointing manifested paths at this driver.
# ═══════════════════════════════════════════════════════════════════════
set -uo pipefail

BASE="$1"
OURS="$2"
THEIRS="$3"
PATH_HINT="${4:-unknown}"

# Try clean 3-way merge — writes result to OURS in-place
if git merge-file -L "ours" -L "base" -L "theirs" "$OURS" "$BASE" "$THEIRS" 2>/dev/null; then
  # Clean merge — exit 0
  exit 0
fi

# Conflict markers were written into OURS. Save the trio for forensics.
REPO_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -n "$REPO_DIR" && -d "$REPO_DIR/.pai-fork" ]]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  TRIO_DIR="$REPO_DIR/.pai-fork/backups/merge-conflicts/${TS}_$(basename "$PATH_HINT")"
  mkdir -p "$TRIO_DIR"
  cp "$BASE" "$TRIO_DIR/base" 2>/dev/null || true
  cp "$OURS" "$TRIO_DIR/ours-with-markers" 2>/dev/null || true
  cp "$THEIRS" "$TRIO_DIR/theirs" 2>/dev/null || true
  cat > "$TRIO_DIR/README.md" <<EOF
# Merge conflict — $PATH_HINT

Generated: $TS

3-way merge had unresolved conflicts. Files saved here:

- \`base\` — last common ancestor (previous upstream version)
- \`ours-with-markers\` — your version with \`<<<<<<<\` conflict markers
- \`theirs\` — new upstream version

Resolve in the working tree (search for \`<<<<<<<\`), then commit.
EOF
fi

# Exit 1 = "merge had conflicts, look at the file"
exit 1
