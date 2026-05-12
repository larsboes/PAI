#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  reintegrate — Walk a backup snapshot and help re-apply customizations
#
#  Usage:
#    reintegrate.sh <backup-timestamp>
#    reintegrate.sh                       # picks latest backup
#
#  For each backed-up file, shows side-by-side diff (backup vs new upstream)
#  and asks: keep upstream / restore ours / open in editor / skip.
# ═══════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$FORK_DIR/.." && pwd)"
BACKUPS_DIR="$FORK_DIR/backups"

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'
BLUE='\033[0;34m'; DIM='\033[2m'; BOLD='\033[1m'; RESET='\033[0m'

ok()    { echo -e "  ${GREEN}✓${RESET} $1"; }
info()  { echo -e "  ${BLUE}ℹ${RESET} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${RESET} $1"; }
err()   { echo -e "  ${RED}✗${RESET} $1"; }

# Pick backup
TS="${1:-}"
if [[ -z "$TS" ]]; then
  TS="$(ls -1t "$BACKUPS_DIR" 2>/dev/null | head -1)"
  [[ -z "$TS" ]] && { err "No backups found."; exit 1; }
  info "Using latest: $TS"
fi

BACKUP_DIR="$BACKUPS_DIR/$TS"
[[ -d "$BACKUP_DIR" ]] || { err "Not found: $BACKUP_DIR"; exit 1; }

# Find backed-up files (excluding REPORT.md)
mapfile -t FILES < <(find "$BACKUP_DIR" -type f ! -name 'REPORT.md' -printf '%P\n' | sort)

if [[ ${#FILES[@]} -eq 0 ]]; then
  ok "No files to reintegrate in $TS"
  exit 0
fi

echo -e "${BOLD}Reintegrating ${#FILES[@]} files from $TS${RESET}"
echo -e "${DIM}For each file: choose keep upstream (default), restore ours, or open editor.${RESET}\n"

for f in "${FILES[@]}"; do
  echo
  echo -e "${BOLD}── $f ────────────────────────────────${RESET}"
  if [[ ! -f "$REPO_DIR/$f" ]]; then
    warn "File no longer in repo (was deleted upstream). Backup at: $BACKUP_DIR/$f"
    continue
  fi
  echo -e "${DIM}  (backup = ours before sync, current = upstream now)${RESET}"
  diff -u "$BACKUP_DIR/$f" "$REPO_DIR/$f" | head -60 || true
  echo
  read -p "  [k]eep upstream / [r]estore ours / [e]dit / [s]kip? [k] " -n 1 -r choice
  echo
  case "${choice:-k}" in
    r|R)
      cp "$BACKUP_DIR/$f" "$REPO_DIR/$f"
      ok "Restored ours: $f"
      ;;
    e|E)
      "${EDITOR:-vi}" "$REPO_DIR/$f" "$BACKUP_DIR/$f"
      info "Edited: $f"
      ;;
    s|S)
      info "Skipped: $f"
      ;;
    *)
      ok "Kept upstream: $f"
      ;;
  esac
done

echo
ok "Reintegration walk complete."
info "Review with: git status / git diff"
