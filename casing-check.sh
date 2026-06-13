#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  casing-check.sh — guard against engine-dir casing drift (Linux is case-sensitive)
#
#  WHY: macOS/APFS hides casing bugs; Linux/ext4 doesn't. Canonical engine dirs are
#  ALL-CAPS (ALGORITHM, TOOLS, PULSE, DOCUMENTATION, TEMPLATES) per upstream. A stray
#  TitleCase ref (PAI/Algorithm) silently fails to resolve on Linux. This asserts
#  every `PAI/<DIR>` reference matches the on-disk dir case-EXACTLY.
#
#  Exits non-zero on drift so it can gate sync.sh / pre-commit.
#  Exception: PAI/Tools/{validate-protected,BackupRestore} are ROOT tools (the repo
#  itself is named PAI), not the engine — whitelisted.
# ═══════════════════════════════════════════════════════════════════════════
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE="$ROOT/PAI"

# canonical on-disk engine dir names (dirs + the MEMORY/USER symlinks)
mapfile -t DIRS < <(find "$ENGINE" -maxdepth 1 -mindepth 1 \( -type d -o -type l \) -printf '%f\n')

fail=0
# collect distinct PAI/<DIR> top segments referenced anywhere (excl frozen/vcs/build),
# dropping the whitelisted root-tool refs first.
while IFS= read -r ref; do
  name="${ref#PAI/}"
  for d in "${DIRS[@]}"; do
    if [ "${name,,}" = "${d,,}" ] && [ "$name" != "$d" ]; then
      echo "  ✗ CASING DRIFT: ref 'PAI/$name' but on-disk dir is 'PAI/$d'"
      # show where
      grep -rIn --exclude=casing-check.sh --exclude-dir=Releases --exclude-dir=.git --exclude-dir=.marketplace-build --exclude-dir=.pai-fork "PAI/$name" "$ROOT" \
        | grep -vE 'PAI/Tools/(validate-protected|BackupRestore)' | head -5 | sed 's/^/      /'
      fail=1
    fi
  done
done < <(
  grep -rhoE 'PAI/[A-Za-z]+(/[A-Za-z0-9_.-]+)?' \
    --exclude=casing-check.sh --exclude-dir=Releases --exclude-dir=.git --exclude-dir=.marketplace-build --exclude-dir=.pai-fork "$ROOT" \
    | grep -vE 'PAI/Tools/(validate-protected|BackupRestore)' \
    | sed -E 's#^(PAI/[A-Za-z]+).*#\1#' | sort -u
)

if [ "$fail" -eq 0 ]; then
  echo "  ✓ casing OK — every engine PAI/<DIR> ref matches on-disk casing"
  exit 0
else
  echo "  ✗ casing drift detected — fix the refs above to match on-disk ALL-CAPS dirs"
  exit 1
fi
