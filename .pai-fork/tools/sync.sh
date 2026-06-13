#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  pai-sync — Vendor Daniel's upstream + preserve our customizations
#
#  Strategy:
#    1. Upstream is source of truth; we always take Daniel's version
#    2. Our intentional customizations are tracked in manifest.yaml — when
#       upstream changes those, we backup ours and write a REPORT.md
#    3. AUTO-BACKUP: any drifted local file (not in manifest) gets backed
#       up before being overwritten by upstream
#    4. Files in exclusions.yaml are never touched
#    5. last-synced.ref is the SHA we synced to last; computes the delta
#
#  Commands:
#    sync.sh status       Show pending upstream changes (read-only)
#    sync.sh apply        Run the sync, write backups + REPORT.md
#    sync.sh report       Show last sync's REPORT.md
#    sync.sh rollback <ts> Restore files from a backup snapshot
#    sync.sh lint         Validate manifest paths exist
#
#  Conventions:
#    - Backups land at .pai-fork/backups/{YYYYMMDD-HHMMSS}_{upstream-sha7}/
#    - Each backup dir mirrors repo structure + REPORT.md at root
#    - Sync writes ONE commit: chore(sync): upstream@{sha7} -> backups/{ts}
# ═══════════════════════════════════════════════════════════════════════
set -euo pipefail

# ── Resolve paths ───────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$(cd "$FORK_DIR/.." && pwd)"
MANIFEST="$FORK_DIR/manifest.yaml"
EXCLUSIONS="$FORK_DIR/exclusions.yaml"
LAST_SYNCED="$FORK_DIR/last-synced.ref"
BACKUPS_DIR="$FORK_DIR/backups"

# ── Colors ──────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'
BLUE='\033[0;34m'; DIM='\033[2m'; BOLD='\033[1m'; RESET='\033[0m'
ok()      { echo -e "  ${GREEN}✓${RESET} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${RESET} $1"; }
err()     { echo -e "  ${RED}✗${RESET} $1" >&2; }
info()    { echo -e "  ${BLUE}ℹ${RESET} $1"; }
header()  { echo -e "\n${BOLD}${BLUE}── $1 ─────────────────────────────────${RESET}"; }

# ── Helpers ─────────────────────────────────────────────────────────────
require_clean_tree() {
  cd "$REPO_DIR"
  if ! git diff --quiet || ! git diff --cached --quiet; then
    err "Working tree not clean. Commit or stash first."
    git status --short
    exit 1
  fi
}

read_manifest_paths() {
  # Extract `path:` lines from manifest.yaml (no jq/yq dependency)
  grep -E '^\s*-\s*path:' "$MANIFEST" 2>/dev/null \
    | sed -E 's/^\s*-\s*path:\s*//;s/\s*$//' \
    | sort -u
}

read_exclusions() {
  # Extract glob patterns from exclusions.yaml
  grep -E '^\s*-\s+' "$EXCLUSIONS" 2>/dev/null \
    | sed -E 's/^\s*-\s+//;s/\s*$//' \
    | grep -v '^#' | grep -v '^$'
}

is_excluded() {
  local path="$1"
  while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    # Convert gitignore-style glob to bash pattern
    case "$path" in
      $pattern) return 0 ;;
    esac
    # Handle ** prefix matching (e.g. .pai-fork/** matches .pai-fork/anything)
    if [[ "$pattern" == *"**" ]]; then
      local prefix="${pattern%/\*\*}"
      [[ "$path" == "$prefix"/* || "$path" == "$prefix" ]] && return 0
    fi
  done < <(read_exclusions)
  return 1
}

is_manifested() {
  local path="$1"
  read_manifest_paths | grep -qxF "$path"
}

ensure_upstream() {
  cd "$REPO_DIR"
  if ! git remote get-url upstream >/dev/null 2>&1; then
    err "No 'upstream' remote configured."
    info "Add it: git remote add upstream <upstream-url>"
    exit 1
  fi
  info "Fetching upstream..."
  git fetch upstream --quiet
}

upstream_sha() {
  cd "$REPO_DIR" && git rev-parse upstream/main
}

last_synced_sha() {
  [[ -f "$LAST_SYNCED" ]] && tr -d '[:space:]' < "$LAST_SYNCED" || echo ""
}

# ── Compute changes since last sync ─────────────────────────────────────
compute_changes() {
  local from="$1" to="$2"
  cd "$REPO_DIR"
  if [[ -z "$from" ]]; then
    # First-ever sync — diff against current HEAD
    git diff --name-status "HEAD..$to" 2>/dev/null
  else
    git diff --name-status "$from..$to" 2>/dev/null
  fi
}

# ── Status command ──────────────────────────────────────────────────────
cmd_status() {
  ensure_upstream

  local from to
  from="$(last_synced_sha)"
  to="$(upstream_sha)"

  header "Sync Status"
  echo -e "    Last synced: ${from:0:12}${from:+ ${DIM}($(cd "$REPO_DIR" && git log -1 --format=%cr "$from" 2>/dev/null || echo "unknown"))${RESET}}"
  echo -e "    Upstream:    ${to:0:12} ${DIM}($(cd "$REPO_DIR" && git log -1 --format=%cr "$to"))${RESET}"

  if [[ "$from" == "$to" ]]; then
    ok "Up to date with upstream/main."
    return 0
  fi

  local nahead
  nahead="$(cd "$REPO_DIR" && git rev-list --count "${from}..${to}" 2>/dev/null || echo "?")"
  info "Upstream has $nahead new commits since last sync."

  header "Pending changes"
  local n_collide=0 n_safe=0 n_excluded=0 n_new=0 n_delete=0

  while IFS=$'\t' read -r status path rest; do
    [[ -z "$path" ]] && continue
    # Handle rename status R100 path1\tpath2
    if [[ "$status" =~ ^R ]]; then
      path="$rest"
    fi

    if is_excluded "$path"; then
      ((n_excluded++)) || true
      continue
    fi

    case "$status" in
      A) ((n_new++)) || true; echo -e "  ${GREEN}+${RESET} new:    $path" ;;
      D) ((n_delete++)) || true; echo -e "  ${RED}-${RESET} delete: $path" ;;
      M|R*)
        if is_manifested "$path"; then
          ((n_collide++)) || true
          echo -e "  ${YELLOW}!${RESET} CUSTOM: $path ${DIM}(manifested — will backup + take upstream)${RESET}"
        elif [[ -f "$REPO_DIR/$path" ]]; then
          # Check if our local version differs from previous upstream sha
          local our_sha upstream_old_sha
          our_sha="$(cd "$REPO_DIR" && git hash-object "$path" 2>/dev/null || echo "missing")"
          upstream_old_sha="$(cd "$REPO_DIR" && git ls-tree "$from" -- "$path" 2>/dev/null | awk '{print $3}' || echo "")"
          if [[ -n "$upstream_old_sha" && "$our_sha" != "$upstream_old_sha" ]]; then
            ((n_collide++)) || true
            echo -e "  ${YELLOW}!${RESET} drift:  $path ${DIM}(unmanifested local change — will auto-backup)${RESET}"
          else
            ((n_safe++)) || true
            echo -e "  ${BLUE}~${RESET} update: $path"
          fi
        else
          ((n_safe++)) || true
          echo -e "  ${BLUE}~${RESET} update: $path ${DIM}(missing locally)${RESET}"
        fi
        ;;
    esac
  done < <(compute_changes "$from" "$to")

  header "Summary"
  echo -e "    New:        $n_new"
  echo -e "    Updates:    $n_safe"
  echo -e "    Deletes:    $n_delete"
  echo -e "    Conflicts:  $n_collide ${DIM}(will be backed up)${RESET}"
  echo -e "    Excluded:   $n_excluded"
  echo
  if [[ $((n_new + n_safe + n_delete + n_collide)) -gt 0 ]]; then
    info "Run ${BOLD}sync.sh apply${RESET} to perform the sync."
  fi
}

# ── Apply command ───────────────────────────────────────────────────────
cmd_apply() {
  require_clean_tree
  ensure_upstream

  local from to
  from="$(last_synced_sha)"
  to="$(upstream_sha)"

  if [[ "$from" == "$to" ]]; then
    ok "Already at upstream/main — nothing to do."
    return 0
  fi

  local ts sha7 backup_dir report
  ts="$(date +%Y%m%d-%H%M%S)"
  sha7="${to:0:7}"
  backup_dir="$BACKUPS_DIR/${ts}_upstream-${sha7}"
  report="$backup_dir/REPORT.md"

  mkdir -p "$backup_dir"

  header "Sync apply: $from → $to"
  info "Backup dir: $backup_dir"

  # Init report
  cat > "$report" <<EOF
# Sync Report — ${ts}

**From upstream:** \`${from}\`
**To upstream:** \`${to}\`
**Backup dir:** \`.pai-fork/backups/${ts}_upstream-${sha7}/\`

---

## Actions taken

EOF

  local n_taken=0 n_backed_up=0 n_excluded=0 n_new=0 n_deleted=0 n_collide=0

  while IFS=$'\t' read -r status path rest; do
    [[ -z "$path" ]] && continue
    if [[ "$status" =~ ^R ]]; then
      path="$rest"
    fi

    if is_excluded "$path"; then
      ((n_excluded++)) || true
      continue
    fi

    case "$status" in
      A)
        # New upstream file — fetch from upstream tree
        mkdir -p "$REPO_DIR/$(dirname "$path")"
        (cd "$REPO_DIR" && git show "$to:$path" > "$path" 2>/dev/null) && {
          ok "+ added: $path"
          echo "- ➕ Added: \`$path\`" >> "$report"
          ((n_new++)) || true
        } || warn "Failed to add: $path"
        ;;
      D)
        if [[ -f "$REPO_DIR/$path" ]]; then
          # Backup before delete (in case of drift)
          local our_sha upstream_old_sha
          our_sha="$(cd "$REPO_DIR" && git hash-object "$path" 2>/dev/null || echo "")"
          upstream_old_sha="$(cd "$REPO_DIR" && git ls-tree "$from" -- "$path" 2>/dev/null | awk '{print $3}' || echo "")"
          if [[ -n "$upstream_old_sha" && "$our_sha" != "$upstream_old_sha" ]]; then
            mkdir -p "$backup_dir/$(dirname "$path")"
            cp "$REPO_DIR/$path" "$backup_dir/$path"
            echo "- 🗑️  Deleted (with backup): \`$path\` — local was modified" >> "$report"
            ((n_backed_up++)) || true
          else
            echo "- 🗑️  Deleted: \`$path\`" >> "$report"
          fi
          rm "$REPO_DIR/$path"
          ok "- deleted: $path"
          ((n_deleted++)) || true
        else
          # Already absent locally — log it so REPORT.md isn't empty
          echo "- ⏭️  Skipped delete: \`$path\` (already absent locally)" >> "$report"
          info "skipped: $path (already absent)"
        fi
        ;;
      M|R*)
        local our_sha upstream_old_sha
        our_sha="$(cd "$REPO_DIR" && git hash-object "$path" 2>/dev/null || echo "missing")"
        upstream_old_sha="$(cd "$REPO_DIR" && git ls-tree "$from" -- "$path" 2>/dev/null | awk '{print $3}' || echo "")"

        local needs_backup=false
        if is_manifested "$path"; then
          needs_backup=true
        elif [[ -n "$upstream_old_sha" && "$our_sha" != "$upstream_old_sha" && -f "$REPO_DIR/$path" ]]; then
          needs_backup=true
        fi

        if $needs_backup && [[ -f "$REPO_DIR/$path" ]]; then
          # Save backup of OURS (always — survives any merge outcome)
          mkdir -p "$backup_dir/$(dirname "$path")"
          cp "$REPO_DIR/$path" "$backup_dir/$path"
          ((n_backed_up++)) || true
          ((n_collide++)) || true
          local why="manifested"
          is_manifested "$path" || why="auto-backup (unmanifested drift)"

          # Try 3-way merge for .md files (preserves both sides cleanly)
          local merged=false
          if [[ "$path" == *.md ]] && [[ -n "$upstream_old_sha" ]]; then
            local tmp_base tmp_theirs
            tmp_base="$(mktemp)"
            tmp_theirs="$(mktemp)"
            (cd "$REPO_DIR" && git cat-file -p "$upstream_old_sha" > "$tmp_base" 2>/dev/null) || true
            (cd "$REPO_DIR" && git show "$to:$path" > "$tmp_theirs" 2>/dev/null) || true
            if [[ -s "$tmp_base" && -s "$tmp_theirs" ]]; then
              if git merge-file -L "ours" -L "previous-upstream" -L "new-upstream" \
                   "$REPO_DIR/$path" "$tmp_base" "$tmp_theirs" 2>/dev/null; then
                # Clean 3-way merge succeeded
                merged=true
                echo "- 🤝 3-way merged: \`$path\` ($why)" >> "$report"
                ok "🤝 3-way merged: $path"
              else
                # Conflict markers in working tree
                merged=true
                echo "- ⚠️ 3-way merge with CONFLICTS: \`$path\` — resolve <<<<<<< markers" >> "$report"
                warn "⚠ conflict markers: $path (resolve before commit)"
              fi
            fi
            rm -f "$tmp_base" "$tmp_theirs"
          fi

          if ! $merged; then
            # Fall back: backup + take upstream wholesale
            echo "- 🔁 Backed up + replaced: \`$path\` ($why)" >> "$report"
            warn "! backed up: $path ($why)"
            mkdir -p "$REPO_DIR/$(dirname "$path")"
            (cd "$REPO_DIR" && git show "$to:$path" > "$path" 2>/dev/null) || {
              warn "Failed to fetch upstream version of: $path"
              continue
            }
          fi
        else
          echo "- ↻ Updated: \`$path\`" >> "$report"
          ok "~ updated: $path"
          # Take upstream version
          mkdir -p "$REPO_DIR/$(dirname "$path")"
          (cd "$REPO_DIR" && git show "$to:$path" > "$path" 2>/dev/null) || {
            warn "Failed to fetch upstream version of: $path"
            continue
          }
        fi
        ((n_taken++)) || true
        ;;
    esac
  done < <(compute_changes "$from" "$to")

  # Summary in report
  cat >> "$report" <<EOF

---

## Summary

| Metric | Count |
|---|---|
| Files added | $n_new |
| Files updated (clean) | $((n_taken - n_collide)) |
| Files deleted | $n_deleted |
| **Conflicts (backed up)** | $n_collide |
| Files excluded | $n_excluded |

## Reintegration TODO

EOF

  if [[ $n_collide -gt 0 ]]; then
    echo "The following files had local customizations. Review backups and decide what to re-apply:" >> "$report"
    echo "" >> "$report"
    find "$backup_dir" -type f ! -name 'REPORT.md' -printf '%P\n' | sort | while read -r f; do
      echo "- [ ] \`$f\` — diff against new upstream: \`diff .pai-fork/backups/${ts}_upstream-${sha7}/$f $f\`" >> "$report"
    done
    echo "" >> "$report"
    echo "**Tools:** \`./.pai-fork/tools/reintegrate.sh ${ts}_upstream-${sha7}\`" >> "$report"
  else
    echo "_No conflicts — clean sync._" >> "$report"
  fi

  # Update last-synced
  echo "$to" > "$LAST_SYNCED"

  # ── Normalize engine-dir casing (cross-platform) ─────────────────────────
  # Upstream uses macOS-safe TitleCase refs (PAI/Tools, PAI/Algorithm) that break on
  # case-sensitive Linux. Rewrite them to canonical ALL-CAPS on every sync so the tree
  # is correct on both platforms with zero manual reconciliation. Idempotent.
  if [[ -x "$REPO_DIR/casing-check.sh" ]]; then
    header "Casing normalization"
    "$REPO_DIR/casing-check.sh" --fix || warn "casing --fix returned non-zero (continuing)"
  fi

  header "Sync complete"
  ok "Synced to upstream@${sha7}"
  ok "Files added:        $n_new"
  ok "Files updated:      $((n_taken - n_collide))"
  ok "Files deleted:      $n_deleted"
  if [[ $n_collide -gt 0 ]]; then
    warn "Conflicts (backed up): $n_collide"
    info "Review: $report"
    info "Reintegrate: ./.pai-fork/tools/reintegrate.sh ${ts}_upstream-${sha7}"
  fi
  ok "Excluded:           $n_excluded"
  echo
  info "Next: review changes with ${BOLD}git status${RESET}, then commit:"
  echo "    git add -A && git commit -m 'chore(sync): upstream@${sha7} -> backups/${ts}_upstream-${sha7}'"
}

# ── Report command ──────────────────────────────────────────────────────
cmd_report() {
  local latest
  latest="$(ls -1t "$BACKUPS_DIR" 2>/dev/null | head -1)"
  if [[ -z "$latest" ]]; then
    warn "No sync reports yet."
    return 0
  fi
  local report="$BACKUPS_DIR/$latest/REPORT.md"
  if [[ ! -f "$report" ]]; then
    warn "Report not found: $report"
    return 1
  fi
  cat "$report"
}

# ── Rollback command ────────────────────────────────────────────────────
cmd_rollback() {
  local ts="${1:-}"
  if [[ -z "$ts" ]]; then
    err "Usage: sync.sh rollback <backup-timestamp>"
    info "Available backups:"
    ls -1 "$BACKUPS_DIR" 2>/dev/null | sed 's/^/    /'
    exit 1
  fi
  local backup_dir="$BACKUPS_DIR/$ts"
  if [[ ! -d "$backup_dir" ]]; then
    err "Backup not found: $backup_dir"
    exit 1
  fi

  header "Rollback from $ts"
  warn "This will OVERWRITE current files with backed-up versions."
  read -p "  Continue? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || { info "Cancelled."; exit 0; }

  find "$backup_dir" -type f ! -name 'REPORT.md' -printf '%P\n' | while read -r f; do
    mkdir -p "$REPO_DIR/$(dirname "$f")"
    cp "$backup_dir/$f" "$REPO_DIR/$f"
    ok "Restored: $f"
  done

  ok "Rollback complete. Review with 'git status'."
}

# ── Lint command ────────────────────────────────────────────────────────
cmd_lint() {
  header "Manifest validation"
  local errs=0
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    if [[ -f "$REPO_DIR/$p" ]]; then
      ok "$p"
    else
      err "$p — file does not exist!"
      ((errs++)) || true
    fi
  done < <(read_manifest_paths)

  if [[ $errs -eq 0 ]]; then
    ok "Manifest is clean."
  else
    err "$errs manifest entries reference missing files."
    exit 1
  fi
}

# ── Help ────────────────────────────────────────────────────────────────
cmd_help() {
  echo -e "${BOLD}pai-sync${RESET} — Vendor Daniel's upstream + preserve customizations"
  echo
  echo -e "${BOLD}Usage:${RESET}"
  echo "  sync.sh <command> [args]"
  echo
  echo -e "${BOLD}Commands:${RESET}"
  echo "  status              Show pending upstream changes (read-only)"
  echo "  apply               Run the sync; creates backups + REPORT.md"
  echo "  report              Show the latest sync's REPORT.md"
  echo "  rollback <ts>       Restore files from a backup snapshot"
  echo "  lint                Validate manifest paths exist"
  echo "  help                Show this help"
  echo
  echo -e "${BOLD}Files:${RESET}"
  echo "  manifest.yaml       Files we customize (will be backed up on conflict)"
  echo "  exclusions.yaml     Paths sync NEVER touches"
  echo "  last-synced.ref     Upstream SHA from last sync"
  echo "  backups/            Conflict snapshots + REPORT.md per sync"
  echo
  echo -e "${BOLD}Workflow:${RESET}"
  echo -e "  1. ${BLUE}sync.sh status${RESET}          — see what changed upstream"
  echo -e "  2. ${BLUE}sync.sh apply${RESET}           — pull upstream, backup customizations"
  echo -e "  3. ${BLUE}sync.sh report${RESET}          — review what got backed up"
  echo -e "  4. ${BLUE}reintegrate.sh${RESET}          — walk backups, re-apply customizations"
  echo -e "  5. ${BLUE}git commit${RESET}              — single sync commit"
}

# ── Dispatch ────────────────────────────────────────────────────────────
case "${1:-help}" in
  status)    cmd_status ;;
  apply)     cmd_apply ;;
  report)    cmd_report ;;
  rollback)  shift; cmd_rollback "$@" ;;
  lint)      cmd_lint ;;
  help|-h|--help) cmd_help ;;
  *)         err "Unknown command: $1"; cmd_help; exit 1 ;;
esac
