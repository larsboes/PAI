#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  PAI Hooks Sync — sync ~/.claude/hooks/ from PAI releases
#
#  Reads ~/.claude/settings.json to find required hooks,
#  resolves each to the best available release, shows diff,
#  and optionally installs missing or updated hooks.
#  Also syncs lib/, handlers/, and PAI Tools symlink.
#
#  Usage:
#    ./sync-hooks.sh                  # status (dry-run)
#    ./sync-hooks.sh --fix            # install missing hooks + support files
#    ./sync-hooks.sh --update         # also update outdated hooks
#    ./sync-hooks.sh --from v2.5      # force a specific release
#    ./sync-hooks.sh --from v2.5 --fix
# ═══════════════════════════════════════════════════════════
set -euo pipefail

# ── Config ──────────────────────────────────────────────────
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
RELEASES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/Releases" && pwd)"

# ── Colors ──────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'
BLUE='\033[0;34m'; DIM='\033[2m'; BOLD='\033[1m'; RESET='\033[0m'
ok()     { echo -e "  ${GREEN}✓${RESET}  $1"; }
missing(){ echo -e "  ${RED}✗${RESET}  $1"; }
outdated(){ echo -e "  ${YELLOW}↑${RESET}  $1"; }
info()   { echo -e "  ${BLUE}ℹ${RESET}  $1"; }
warn()   { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
dim()    { echo -e "  ${DIM}$1${RESET}"; }

# ── Args ────────────────────────────────────────────────────
FIX=false
UPDATE=false
FORCE_FROM=""

for arg in "$@"; do
  case "$arg" in
    --fix)       FIX=true ;;
    --update)    UPDATE=true; FIX=true ;;
    --from)      shift; FORCE_FROM="$1" ;;
    --from=*)    FORCE_FROM="${arg#--from=}" ;;
    --help|-h)
      echo "Usage: sync-hooks.sh [--fix] [--update] [--from <version>]"
      echo ""
      echo "  (no flags)      Show hook status (dry-run)"
      echo "  --fix           Install missing hooks"
      echo "  --update        Install missing + update outdated hooks"
      echo "  --from <ver>    Force source release (e.g. v2.5, v4.0.3)"
      echo ""
      echo "Releases available:"
      ls "$RELEASES_DIR" | grep "^v" | sort -V | sed 's/^/  /'
      exit 0
      ;;
  esac
done

# ── Validate ────────────────────────────────────────────────
[[ -f "$SETTINGS_FILE" ]] || { echo "ERROR: settings.json not found at $SETTINGS_FILE"; exit 1; }
[[ -d "$HOOKS_DIR"    ]] || { echo "ERROR: hooks dir not found at $HOOKS_DIR"; exit 1; }
[[ -d "$RELEASES_DIR" ]] || { echo "ERROR: Releases dir not found at $RELEASES_DIR"; exit 1; }

# ── Sanity check settings.json env ──────────────────────────
# PAI_DIR should be absolute (not ~) so hook subprocesses always resolve it
# PATH must include bun so #!/usr/bin/env bun shebangs work in hooks
_pai_dir=$(python3 -c "import json,os; d=json.load(open('$SETTINGS_FILE')); print(d.get('env',{}).get('PAI_DIR',''))" 2>/dev/null)
_settings_path=$(python3 -c "import json,os; d=json.load(open('$SETTINGS_FILE')); print(d.get('env',{}).get('PATH',''))" 2>/dev/null)
_bun=$(which bun 2>/dev/null || echo "")
_bun_dir=$(dirname "$_bun" 2>/dev/null || echo "")

if [[ "$_pai_dir" == ~* || "$_pai_dir" == *'~'* ]]; then
  warn "PAI_DIR in settings.json uses ~ ('$_pai_dir') — hook subprocesses may not expand it!"
  warn "Fix: change PAI_DIR to absolute path: ${HOME}/.claude"
fi
if [[ -n "$_bun_dir" && "$_settings_path" != *"$_bun_dir"* ]]; then
  warn "settings.json env.PATH doesn't include bun ($_bun_dir) — hooks with #!/usr/bin/env bun may fail!"
  warn "Fix: add to settings.json env: \"PATH\": \"$HOME/.local/bin:${_bun_dir}:/usr/local/bin:/usr/bin:/bin\""
fi
if [[ "$_settings_path" != *".local/bin"* ]]; then
  warn "settings.json env.PATH doesn't include ~/.local/bin — Claude Code will warn about native installation"
fi

# ── Get sorted release list (newest first) ──────────────────
RELEASES=( $(ls "$RELEASES_DIR" | grep "^v" | sort -V -r) )
[[ ${#RELEASES[@]} -gt 0 ]] || { echo "ERROR: no releases found in $RELEASES_DIR"; exit 1; }

if [[ -n "$FORCE_FROM" ]]; then
  [[ -d "$RELEASES_DIR/$FORCE_FROM/.claude/hooks" ]] || {
    echo "ERROR: Release $FORCE_FROM not found (or no hooks dir)"
    echo "Available: ${RELEASES[*]}"
    exit 1
  }
fi

# ── Parse required hooks from settings.json ─────────────────
# Extracts hook filenames from ${PAI_DIR}/hooks/Foo.hook.ts patterns
REQUIRED_HOOKS=( $(grep -o '"[^"]*\.hook\.ts"' "$SETTINGS_FILE" \
  | tr -d '"' \
  | sed 's|.*hooks/||' \
  | sort -u) )

[[ ${#REQUIRED_HOOKS[@]} -gt 0 ]] || { echo "ERROR: no hooks found in settings.json"; exit 1; }

# ── Resolve best source for each hook ───────────────────────
# Returns path to latest release containing this hook
best_source() {
  local hook="$1"
  if [[ -n "$FORCE_FROM" ]]; then
    local p="$RELEASES_DIR/$FORCE_FROM/.claude/hooks/$hook"
    [[ -f "$p" ]] && echo "$p" && return
    echo ""
    return
  fi
  for ver in "${RELEASES[@]}"; do
    local p="$RELEASES_DIR/$ver/.claude/hooks/$hook"
    [[ -f "$p" ]] && echo "$p" && return
  done
  echo ""
}

# Source release name from path
release_of() {
  local p="${1#*Releases/}"
  echo "${p%%/*}"
}

# ── Banner ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}  PAI Hooks Sync${RESET}"
echo -e "  ${DIM}settings: $SETTINGS_FILE${RESET}"
echo -e "  ${DIM}hooks:    $HOOKS_DIR${RESET}"
echo -e "  ${DIM}releases: $RELEASES_DIR${RESET}"
[[ -n "$FORCE_FROM" ]] && echo -e "  ${YELLOW}source forced: $FORCE_FROM${RESET}"
echo ""

# ── Status counters ─────────────────────────────────────────
COUNT_OK=0; COUNT_MISSING=0; COUNT_OUTDATED=0; COUNT_NO_SOURCE=0

declare -A TO_INSTALL   # hook → source path (missing or outdated)

# ── Check each required hook ─────────────────────────────────
echo -e "  ${BOLD}Required hooks (${#REQUIRED_HOOKS[@]} from settings.json):${RESET}"
echo ""

for hook in "${REQUIRED_HOOKS[@]}"; do
  installed="$HOOKS_DIR/$hook"
  src=$(best_source "$hook")

  if [[ -z "$src" ]]; then
    # No source found in any release
    if [[ -f "$installed" ]]; then
      ok "$hook  ${DIM}(installed, no release source — keeping)${RESET}"
      ((COUNT_OK++)) || true
    else
      missing "$hook  ${RED}MISSING — no source in any release!${RESET}"
      ((COUNT_NO_SOURCE++)) || true
    fi
    continue
  fi

  src_ver=$(release_of "$src")

  if [[ ! -f "$installed" ]]; then
    missing "$hook  ${DIM}← $src_ver${RESET}"
    TO_INSTALL["$hook"]="$src"
    ((COUNT_MISSING++)) || true
  else
    # Compare checksums
    installed_sum=$(md5sum "$installed" | cut -d' ' -f1)
    src_sum=$(md5sum "$src" | cut -d' ' -f1)
    if [[ "$installed_sum" != "$src_sum" ]]; then
      outdated "$hook  ${DIM}(differs from $src_ver)${RESET}"
      TO_INSTALL["$hook"]="$src"
      ((COUNT_OUTDATED++)) || true
    else
      ok "$hook  ${DIM}($src_ver)${RESET}"
      ((COUNT_OK++)) || true
    fi
  fi
done

# ── Also show orphaned hooks (in dir but not in settings.json) ─
echo ""
echo -e "  ${BOLD}Installed but not required:${RESET}"
has_orphans=false
for f in "$HOOKS_DIR"/*.hook.ts; do
  hook=$(basename "$f")
  found=false
  for req in "${REQUIRED_HOOKS[@]}"; do
    [[ "$req" == "$hook" ]] && found=true && break
  done
  $found || { dim "  $hook  (orphaned — not in settings.json)"; has_orphans=true; }
done
$has_orphans || dim "  none"

# ── Summary ─────────────────────────────────────────────────
echo ""
echo -e "  ──────────────────────────────────────────"
echo -e "  ${GREEN}✓${RESET} ok:       $COUNT_OK"
[[ $COUNT_MISSING  -gt 0 ]] && echo -e "  ${RED}✗${RESET} missing:  $COUNT_MISSING"
[[ $COUNT_OUTDATED -gt 0 ]] && echo -e "  ${YELLOW}↑${RESET} outdated: $COUNT_OUTDATED"
[[ $COUNT_NO_SOURCE -gt 0 ]] && echo -e "  ${RED}?${RESET} no source: $COUNT_NO_SOURCE"
echo ""

# ── Apply fixes ──────────────────────────────────────────────
APPLICABLE=()
for hook in "${!TO_INSTALL[@]}"; do
  # --fix installs missing; --update installs missing+outdated
  installed="$HOOKS_DIR/$hook"
  if [[ ! -f "$installed" ]]; then
    APPLICABLE+=("$hook")   # always include missing in --fix
  elif $UPDATE; then
    APPLICABLE+=("$hook")   # include outdated only with --update
  fi
done

if [[ ${#APPLICABLE[@]} -eq 0 && ${#TO_INSTALL[@]} -gt 0 && ! $UPDATE ]]; then
  echo -e "  ${DIM}Run with --update to also refresh outdated hooks${RESET}"
fi

if [[ ${#APPLICABLE[@]} -eq 0 ]]; then
  if [[ $COUNT_MISSING -eq 0 && $COUNT_OUTDATED -eq 0 ]]; then
    echo -e "  ${GREEN}All required hooks are installed and up to date.${RESET}"
  elif ! $FIX; then
    echo -e "  ${YELLOW}Run with --fix to install missing hooks${RESET}"
    [[ $COUNT_OUTDATED -gt 0 ]] && echo -e "  ${YELLOW}Run with --update to also refresh outdated hooks${RESET}"
  fi
  echo ""
elif ! $FIX; then
  echo -e "  ${YELLOW}Run with --fix to install missing hooks${RESET}"
  [[ $COUNT_OUTDATED -gt 0 ]] && echo -e "  ${YELLOW}Run with --update to also refresh outdated hooks${RESET}"
  echo ""
else
  echo -e "  ${BOLD}Installing ${#APPLICABLE[@]} hooks:${RESET}"
  echo ""

# Backup first
BACKUP_DIR="$CLAUDE_DIR/backups/hooks-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
copied_backup=false
for hook in "${APPLICABLE[@]}"; do
  installed="$HOOKS_DIR/$hook"
  if [[ -f "$installed" ]]; then
    cp "$installed" "$BACKUP_DIR/$hook"
    copied_backup=true
  fi
done
$copied_backup && info "Backup saved → $BACKUP_DIR"

for hook in "${APPLICABLE[@]}"; do
  src="${TO_INSTALL[$hook]}"
  src_ver=$(release_of "$src")
  dst="$HOOKS_DIR/$hook"
  cp "$src" "$dst"
  chmod +x "$dst"
  if [[ -f "$dst" ]]; then
    ok "Installed $hook  ${DIM}(from $src_ver)${RESET}"
  fi
done
fi  # end of hooks install block

# ── Sync lib/ and handlers/ support dirs ────────────────────
echo ""
echo -e "  ${BOLD}Support dirs (lib/ + handlers/):${RESET}"
echo ""

sync_support_dir() {
  local subdir="$1"   # e.g. "lib" or "handlers"
  local dst_dir="$HOOKS_DIR/$subdir"
  local missing_files=()
  local outdated_files=()

  # Find best source for each file: newest release that has it
  declare -A src_map
  for ver in "${RELEASES[@]}"; do
    src_dir="$RELEASES_DIR/$ver/.claude/hooks/$subdir"
    [[ -d "$src_dir" ]] || continue
    for f in "$src_dir"/*.ts; do
      [[ -f "$f" ]] || continue
      name=$(basename "$f")
      [[ -z "${src_map[$name]:-}" ]] && src_map[$name]="$f"
    done
  done

  for name in $(echo "${!src_map[@]}" | tr ' ' '\n' | sort); do
    src="${src_map[$name]}"
    dst="$dst_dir/$name"
    src_ver=$(release_of "$src")
    if [[ ! -f "$dst" ]]; then
      missing "$subdir/$name  ${DIM}← $src_ver${RESET}"
      missing_files+=("$name")
    else
      s1=$(md5sum "$dst" | cut -d' ' -f1)
      s2=$(md5sum "$src" | cut -d' ' -f1)
      if [[ "$s1" != "$s2" ]]; then
        outdated "$subdir/$name  ${DIM}(differs from $src_ver)${RESET}"
        outdated_files+=("$name")
      else
        ok "$subdir/$name  ${DIM}($src_ver)${RESET}"
      fi
    fi
  done

  if $FIX; then
    mkdir -p "$dst_dir"
    for name in "${missing_files[@]:-}"; do
      [[ -z "$name" ]] && continue
      src="${src_map[$name]}"
      src_ver=$(release_of "$src")
      cp "$src" "$dst_dir/$name"
      ok "Installed $subdir/$name  ${DIM}(from $src_ver)${RESET}"
    done
    if $UPDATE; then
      for name in "${outdated_files[@]:-}"; do
        [[ -z "$name" ]] && continue
        src="${src_map[$name]}"
        src_ver=$(release_of "$src")
        cp "$src" "$dst_dir/$name"
        ok "Updated $subdir/$name  ${DIM}(from $src_ver)${RESET}"
      done
    fi
  fi
}

sync_support_dir "lib"
echo ""
sync_support_dir "handlers"

# ── Check PAI Tools symlink ──────────────────────────────────
echo ""
echo -e "  ${BOLD}PAI Tools path (../skills/PAI/TOOLS → ../PAI/TOOLS):${RESET}"
echo ""

SKILLS_TOOLS_DIR="$CLAUDE_DIR/skills/PAI/TOOLS"
PAI_TOOLS_DIR="$CLAUDE_DIR/PAI/TOOLS"

if [[ -d "$PAI_TOOLS_DIR" ]]; then
  if [[ -L "$SKILLS_TOOLS_DIR" ]]; then
    ok "skills/PAI/TOOLS → PAI/TOOLS  ${DIM}(symlink ok)${RESET}"
  elif [[ -d "$SKILLS_TOOLS_DIR" ]]; then
    ok "skills/PAI/TOOLS  ${DIM}(directory exists)${RESET}"
  else
    missing "skills/PAI/TOOLS  ${DIM}(hooks importing ../skills/PAI/TOOLS/* will fail)${RESET}"
    if $FIX; then
      mkdir -p "$CLAUDE_DIR/skills/PAI"
      ln -s "$PAI_TOOLS_DIR" "$SKILLS_TOOLS_DIR"
      ok "Created symlink skills/PAI/TOOLS → PAI/TOOLS"
    fi
  fi
else
  warn "PAI/TOOLS dir not found at $PAI_TOOLS_DIR — cannot create symlink"
fi

echo ""
echo -e "  ${GREEN}${BOLD}Done.${RESET} Restart Claude Code to pick up changes."
echo ""
