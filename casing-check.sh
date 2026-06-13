#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  casing-check.sh — guard against engine-dir casing drift (Linux is case-sensitive)
#
#  WHY: macOS/APFS hides casing bugs; Linux/ext4 doesn't. Canonical engine dirs are
#  ALL-CAPS (ALGORITHM, TOOLS, PULSE, DOCUMENTATION, TEMPLATES) per upstream. A stray
#  TitleCase ref (PAI/Algorithm) silently fails to resolve on Linux. This asserts
#  every `PAI/<DIR>` reference matches the on-disk dir case-EXACTLY.
#
#  Modes:
#    (no args)  CHECK — print drift and exit non-zero, so it can gate sync.sh /
#                       pre-commit. Behavior unchanged from the original.
#    --fix      FIX   — rewrite every drifted `PAI/<wrong>` ref to the canonical
#                       on-disk casing, idempotently. Used as the post-pull step of
#                       .pai-fork/tools/sync.sh apply so upstream's macOS-safe
#                       TitleCase refs are normalized on every sync with ZERO manual
#                       reconciliation. Cross-platform: ALL-CAPS refs resolve on both
#                       case-sensitive (Linux) and case-insensitive (macOS) FS. Exits 0.
#
#  Exits non-zero on drift (check mode) so it can gate sync.sh / pre-commit.
#  Exception: PAI/Tools/{validate-protected,BackupRestore} are ROOT tools (the repo
#  itself is named PAI), not the engine — whitelisted in BOTH modes.
# ═══════════════════════════════════════════════════════════════════════════
set -uo pipefail

MODE="check"
case "${1:-}" in
  --fix)        MODE="fix" ;;
  ""|--check)   MODE="check" ;;
  *) echo "usage: casing-check.sh [--fix]" >&2; exit 2 ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE="$ROOT/PAI"

# canonical on-disk engine dir names (dirs + the MEMORY/USER symlinks)
mapfile -t DIRS < <(find "$ENGINE" -maxdepth 1 -mindepth 1 \( -type d -o -type l \) -printf '%f\n')

# shared grep excludes + the root-tool whitelist (never rewrite / never flag these refs)
EXCLUDES=(--exclude=casing-check.sh --exclude-dir=Releases --exclude-dir=.git --exclude-dir=.pai-fork)
WHITELIST='PAI/Tools/(validate-protected|BackupRestore)'

fail=0
fixes=0

while IFS= read -r ref; do
  name="${ref#PAI/}"
  for d in "${DIRS[@]}"; do
    if [ "${name,,}" = "${d,,}" ] && [ "$name" != "$d" ]; then
      if [ "$MODE" = "fix" ]; then
        # Rewrite PAI/<name> → PAI/<d> across the same file set. The perl lookaheads:
        #   (?![A-Za-z0-9_])  whole dir-segment only (won't touch PAI/Toolsmith)
        #   (?!/(validate-protected|BackupRestore))  preserve the root-tool whitelist
        while IFS= read -r f; do
          pre="$(md5sum "$f" | cut -d' ' -f1)"
          perl -i -pe "s{PAI/\\Q$name\\E(?![A-Za-z0-9_])(?!/(?:validate-protected|BackupRestore))}{PAI/$d}g" "$f"
          post="$(md5sum "$f" | cut -d' ' -f1)"
          if [ "$pre" != "$post" ]; then
            echo "  ✓ fixed: PAI/$name → PAI/$d  in ${f#"$ROOT"/}"
            fixes=$((fixes + 1))
          fi
        done < <(grep -rIlE "PAI/$name" "${EXCLUDES[@]}" "$ROOT")
      else
        echo "  ✗ CASING DRIFT: ref 'PAI/$name' but on-disk dir is 'PAI/$d'"
        # show where
        grep -rIn "${EXCLUDES[@]}" "PAI/$name" "$ROOT" \
          | grep -vE "$WHITELIST" | head -5 | sed 's/^/      /'
        fail=1
      fi
    fi
  done
done < <(
  grep -rhoE 'PAI/[A-Za-z]+(/[A-Za-z0-9_.-]+)?' \
    "${EXCLUDES[@]}" "$ROOT" \
    | grep -vE "$WHITELIST" \
    | sed -E 's#^(PAI/[A-Za-z]+).*#\1#' | sort -u
)

if [ "$MODE" = "fix" ]; then
  if [ "$fixes" -eq 0 ]; then
    echo "  ✓ casing already canonical — nothing to fix"
  else
    echo "  ✓ normalized engine-dir casing in $fixes file(s)"
  fi
  exit 0
fi

if [ "$fail" -eq 0 ]; then
  echo "  ✓ casing OK — every engine PAI/<DIR> ref matches on-disk casing"
  exit 0
else
  echo "  ✗ casing drift detected — run ./casing-check.sh --fix (or fix refs to match on-disk ALL-CAPS dirs)"
  exit 1
fi
