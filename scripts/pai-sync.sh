#!/usr/bin/env bash
#
# pai-sync.sh — Sync PAI skills from source repos to all agent targets
#
# Sources: ~/.pai/sources.conf (one repo path per line, ~ supported)
# Targets:
#   ~/.claude/skills/{name}/SKILL.md
#   ~/.gemini/skills/{name}/SKILL.md
#   ~/.pi/skills/{name}/SKILL.md
#   ~/.pi/scripts/         (for skills with scripts/ subdir)
#
# Usage:
#   pai-sync.sh             # dry run (default)
#   pai-sync.sh --dry-run   # dry run (explicit)
#   pai-sync.sh --confirm   # apply changes
#   pai-sync.sh --status    # show drift summary only
#   pai-sync.sh --clean     # dry run + show orphaned skills that would be removed
#   pai-sync.sh --clean --confirm  # remove orphaned skills from targets
#
# Skill discovery supports both:
#   Flat:  {repo}/skills/{name}/SKILL.md
#   Packs: {repo}/Packs/{Pack}/src/{name}/SKILL.md
#
# Sync tag in SKILL.md frontmatter:
#   # @sync: public   → claude + gemini + pi  (default)
#   # @sync: personal → claude + gemini + pi
#   # @sync: private  → pi only
#
# Path rewrites per target:
#   claude:  ${CLAUDE_SKILL_DIR}/scripts/ → unchanged (Claude resolves it)
#   gemini:  ${CLAUDE_SKILL_DIR}/scripts/ → ./scripts/ (relative, scripts deployed alongside)
#   pi:      ${CLAUDE_SKILL_DIR}/scripts/ → ~/.pi/scripts/ (centralized)

set -euo pipefail

SOURCES_CONF="${HOME}/.pai/sources.conf"
CLAUDE_SKILLS="${HOME}/.claude/skills"
GEMINI_SKILLS="${HOME}/.gemini/skills"
PI_SKILLS="${HOME}/.pi/skills"
PI_SCRIPTS="${HOME}/.pi/scripts"

DRY_RUN=true
STATUS_ONLY=false
CLEAN=false

# ── Counters ──────────────────────────────────────────────────────────────────
created=0
updated=0
unchanged=0
scripts_synced=0
cleaned=0

# ── Shared temp file (reused across all deploy calls) ────────────────────────
TMP_EFFECTIVE=$(mktemp)
TEMP_FILES=("$TMP_EFFECTIVE")
trap 'rm -f "${TEMP_FILES[@]}"' EXIT

# ── Helpers ───────────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
Usage: pai-sync.sh [--dry-run | --confirm | --status | --clean]

  (no flag)   Dry run — print what would change, no writes
  --dry-run   Dry run (explicit)
  --confirm   Apply all changes
  --status    Show drift summary only (compact, no per-file output)
  --clean     Remove orphaned skills from targets (skills not in any source)
              Use with --confirm to actually delete, otherwise dry run
  --help      Show this help

Sources: ~/.pai/sources.conf
EOF
}

expand_path() {
  echo "${1/#\~/$HOME}"
}

# to_kebab <TitleCaseName>
# Converts TitleCase/PascalCase to kebab-case for pi compatibility.
# Preserves known acronyms as single tokens (CLI→cli, OSINT→osint, etc).
to_kebab() {
  python3 -c "
import re, sys
name = sys.argv[1]
acronyms = {'CLI':'cli','OSINT':'osint','PAI':'pai','SEC':'sec','US':'us','API':'api'}
for acr, rep in sorted(acronyms.items(), key=lambda x: -len(x[0])):
    name = name.replace(acr, '_' + rep + '_')
parts = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', name).lower()
parts = [p for p in re.split(r'[_]+', parts) if p]
print('-'.join(parts))
" "$1"
}

# discover_skills <repo>
# Prints "name:path" pairs to stdout, one per skill
discover_skills() {
  local repo="$1"

  # Flat: {repo}/skills/{name}/SKILL.md
  if [[ -d "${repo}/skills" ]]; then
    for skill_dir in "${repo}/skills"/*/; do
      [[ -f "${skill_dir}SKILL.md" ]] || continue
      local name
      name=$(basename "${skill_dir%/}")
      printf '%s:%s\n' "$name" "${skill_dir%/}"
    done
  fi

  # Packs: {repo}/Packs/{Pack}/src/{name}/SKILL.md  (upstream format)
  #    or: {repo}/Packs/{Pack}/src/skills/{name}/SKILL.md  (legacy)
  if [[ -d "${repo}/Packs" ]]; then
    for pack_dir in "${repo}/Packs"/*/; do
      [[ -d "${pack_dir}src" ]] || continue

      # Upstream format: src/{SkillName}/SKILL.md
      for skill_dir in "${pack_dir}src"/*/; do
        [[ -f "${skill_dir}SKILL.md" ]] || continue
        local name
        name=$(basename "${skill_dir%/}")
        # Skip non-skill directories (Workflows, Templates, Tools, etc.)
        # A skill dir must contain a SKILL.md — already checked above
        printf '%s:%s\n' "$name" "${skill_dir%/}"
      done

      # Pack-level SKILL.md: src/SKILL.md (single-skill Pack like Research)
      if [[ -f "${pack_dir}src/SKILL.md" ]]; then
        local name
        name=$(basename "${pack_dir%/}")
        printf '%s:%s\n' "$name" "${pack_dir}src"
      fi
    done
  fi
}

# get_sync_tag <skill_md>
# Returns: public | personal | private (default: public)
get_sync_tag() {
  local skill_md="$1"
  local tag
  tag=$(grep -o '# @sync: [a-z]*' "$skill_md" 2>/dev/null | sed 's/# @sync: //' | head -1 || true)
  echo "${tag:-public}"
}

# targets_for_tag <tag>
targets_for_tag() {
  case "$1" in
    private)  echo "pi" ;;
    *)        echo "claude gemini pi" ;;
  esac
}

# build_effective <src_md> <target> <skill_name>
# Writes the target-specific SKILL.md content to $TMP_EFFECTIVE
build_effective() {
  local src_md="$1"
  local target="$2"
  local skill_name="$3"
  case "$target" in
    pi)      sed -e "s|\${CLAUDE_SKILL_DIR}/scripts/|${PI_SCRIPTS}/|g" \
                 -e "s|\${CLAUDE_SKILL_DIR}|${PI_SKILLS}/${skill_name}|g" \
                 -e "s|^name: .*|name: ${skill_name}|" \
                 "$src_md" > "$TMP_EFFECTIVE" ;;
    gemini)  sed -e "s|\${CLAUDE_SKILL_DIR}/scripts/|./scripts/|g" \
                 -e "s|\${CLAUDE_SKILL_DIR}|.|g" \
                 "$src_md" > "$TMP_EFFECTIVE" ;;
    claude)  cp "$src_md" "$TMP_EFFECTIVE" ;;
  esac
}

# deploy_skill_md <name> <src_md> <dst_dir> <target>
deploy_skill_md() {
  local name="$1"
  local src_md="$2"
  local dst_dir="$3"
  local target="$4"
  local dst_md="${dst_dir}/SKILL.md"

  build_effective "$src_md" "$target" "$name"

  if [[ ! -f "$dst_md" ]]; then
    if [[ "$STATUS_ONLY" == true ]]; then
      created=$((created + 1))
    elif [[ "$DRY_RUN" == true ]]; then
      echo "  [CREATE] ${target}: ${name}/SKILL.md"
    else
      mkdir -p "$dst_dir"
      cp "$TMP_EFFECTIVE" "$dst_md"
      echo "  [CREATED] ${target}: ${name}/SKILL.md"
      created=$((created + 1))
    fi
  elif ! diff -q "$TMP_EFFECTIVE" "$dst_md" > /dev/null 2>&1; then
    if [[ "$STATUS_ONLY" == true ]]; then
      updated=$((updated + 1))
    elif [[ "$DRY_RUN" == true ]]; then
      echo "  [UPDATE]  ${target}: ${name}/SKILL.md"
    else
      cp "$TMP_EFFECTIVE" "$dst_md"
      echo "  [UPDATED] ${target}: ${name}/SKILL.md"
      updated=$((updated + 1))
    fi
  else
    if [[ "$DRY_RUN" == true && "$STATUS_ONLY" == false ]]; then
      echo "  [OK]      ${target}: ${name}/SKILL.md"
    fi
    unchanged=$((unchanged + 1))
  fi
}

# deploy_scripts_to_dir <name> <scripts_src_dir> <dst_dir> <label>
deploy_scripts_to_dir() {
  local name="$1"
  local scripts_dir="$2"
  local dst_dir="$3"
  local label="$4"

  for script in "$scripts_dir"/*; do
    [[ -f "$script" ]] || continue
    local script_name dst
    script_name=$(basename "$script")
    dst="${dst_dir}/${script_name}"

    if [[ ! -f "$dst" ]]; then
      if [[ "$STATUS_ONLY" == true ]]; then
        scripts_synced=$((scripts_synced + 1))
      elif [[ "$DRY_RUN" == true ]]; then
        echo "  [CREATE] ${label}: ${script_name}"
      else
        mkdir -p "$dst_dir"
        cp "$script" "$dst"
        chmod +x "$dst"
        echo "  [CREATED] ${label}: ${script_name}"
        scripts_synced=$((scripts_synced + 1))
      fi
    elif ! diff -q "$script" "$dst" > /dev/null 2>&1; then
      if [[ "$STATUS_ONLY" == true ]]; then
        scripts_synced=$((scripts_synced + 1))
      elif [[ "$DRY_RUN" == true ]]; then
        echo "  [UPDATE]  ${label}: ${script_name}"
      else
        cp "$script" "$dst"
        chmod +x "$dst"
        echo "  [UPDATED] ${label}: ${script_name}"
        scripts_synced=$((scripts_synced + 1))
      fi
    fi
  done
}

# deploy_skill_files <name> <skill_path> <dst_dir> <target>
# Deploys all files in skill dir except SKILL.md and scripts/
# Uses direct copy (no sed transforms — path rewriting only applies to SKILL.md)
deploy_skill_files() {
  local name="$1"
  local skill_path="$2"
  local dst_dir="$3"
  local target="$4"

  while IFS= read -r -d '' src_file; do
    local rel_path="${src_file#${skill_path}/}"
    local dst_file="${dst_dir}/${rel_path}"

    if [[ ! -f "$dst_file" ]]; then
      if [[ "$STATUS_ONLY" == true ]]; then
        created=$((created + 1))
      elif [[ "$DRY_RUN" == true ]]; then
        echo "  [CREATE] ${target}: ${name}/${rel_path}"
      else
        mkdir -p "$(dirname "$dst_file")"
        cp "$src_file" "$dst_file"
        echo "  [CREATED] ${target}: ${name}/${rel_path}"
        created=$((created + 1))
      fi
    elif ! diff -q "$src_file" "$dst_file" > /dev/null 2>&1; then
      if [[ "$STATUS_ONLY" == true ]]; then
        updated=$((updated + 1))
      elif [[ "$DRY_RUN" == true ]]; then
        echo "  [UPDATE]  ${target}: ${name}/${rel_path}"
      else
        cp "$src_file" "$dst_file"
        echo "  [UPDATED] ${target}: ${name}/${rel_path}"
        updated=$((updated + 1))
      fi
    else
      if [[ "$DRY_RUN" == true && "$STATUS_ONLY" == false ]]; then
        echo "  [OK]      ${target}: ${name}/${rel_path}"
      fi
      unchanged=$((unchanged + 1))
    fi
  done < <(
    # Build find command, excluding sub-skill directories (dirs with their own SKILL.md)
    find_cmd=(find "$skill_path" -type f ! -name "SKILL.md" ! -path "*/scripts/*")
    for sub in "$skill_path"/*/; do
      [[ -f "${sub}SKILL.md" ]] && find_cmd+=(! -path "${sub%/}/*")
    done
    find_cmd+=(-print0)
    "${find_cmd[@]}"
  )
}

# sync_skill <name> <skill_path> <tag>
sync_skill() {
  local name="$1"
  local skill_path="$2"
  local tag="$3"
  local skill_md="${skill_path}/SKILL.md"

  local targets
  read -ra targets <<< "$(targets_for_tag "$tag")"

  for target in "${targets[@]}"; do
    local deploy_name="$name"
    local target_dir

    # Pi requires kebab-case skill names
    if [[ "$target" == "pi" ]]; then
      deploy_name=$(to_kebab "$name")
    fi

    case "$target" in
      claude) target_dir="${CLAUDE_SKILLS}/${deploy_name}" ;;
      gemini) target_dir="${GEMINI_SKILLS}/${deploy_name}" ;;
      pi)     target_dir="${PI_SKILLS}/${deploy_name}" ;;
    esac

    deploy_skill_md "$deploy_name" "$skill_md" "$target_dir" "$target"
    deploy_skill_files "$deploy_name" "$skill_path" "$target_dir" "$target"

    if [[ -d "${skill_path}/scripts" ]]; then
      deploy_scripts_to_dir "$name" "${skill_path}/scripts" "${target_dir}/scripts" "$target"
      if [[ "$target" == "pi" ]]; then
        deploy_scripts_to_dir "$name" "${skill_path}/scripts" "$PI_SCRIPTS" "pi-central"
      fi
    fi
  done
}

# ── Argument parsing ──────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --confirm)   DRY_RUN=false; shift ;;
    --dry-run)   DRY_RUN=true; shift ;;
    --status)    STATUS_ONLY=true; DRY_RUN=true; shift ;;
    --clean)     CLEAN=true; shift ;;
    --help|-h)   usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
done

# ── Prerequisites ─────────────────────────────────────────────────────────────

if [[ ! -f "$SOURCES_CONF" ]]; then
  echo "ERROR: sources.conf not found at $SOURCES_CONF"
  echo "Create it with one repo path per line:"
  echo "  ~/Developer/PAI"
  echo "  ~/Developer/pai-personal"
  exit 1
fi

if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "$CLAUDE_SKILLS" "$GEMINI_SKILLS" "$PI_SKILLS" "$PI_SCRIPTS"
fi

# ── Main ──────────────────────────────────────────────────────────────────────

if [[ "$STATUS_ONLY" == false ]]; then
  echo ""
  echo "════ pai-sync ════════════════════════════════════════════════════════"
  [[ "$DRY_RUN" == true ]] \
    && echo "Mode: DRY RUN  (use --confirm to apply changes)" \
    || echo "Mode: CONFIRM"
  echo "Sources: $(grep -c -v '^[[:space:]]*$\|^#' "$SOURCES_CONF" 2>/dev/null || echo '?') repos in sources.conf"
  echo ""
fi

total_skills=0

# ── Phase 1: Collect all skills from all sources → temp file ─────────────────
tmp_all=$(mktemp)
TEMP_FILES+=("$tmp_all")

while IFS= read -r raw_path || [[ -n "$raw_path" ]]; do
  [[ "$raw_path" =~ ^[[:space:]]*$ || "$raw_path" =~ ^# ]] && continue
  local_repo=$(expand_path "$raw_path")
  [[ -d "$local_repo" ]] || { echo "WARN: repo not found — $local_repo"; continue; }
  discover_skills "$local_repo" >> "$tmp_all"
done < "$SOURCES_CONF"

# Deduplicate: first-seen order, last path wins.
tmp_deduped=$(mktemp)
TEMP_FILES+=("$tmp_deduped")

python3 - "$tmp_all" > "$tmp_deduped" <<'PYEOF'
import sys
entries = {}
order   = []
with open(sys.argv[1]) as f:
    for line in f:
        line = line.strip()
        if ':' not in line:
            continue
        name, _, path = line.partition(':')
        if name not in entries:
            order.append(name)
        entries[name] = path
for name in order:
    print(f"{name}:{entries[name]}")
PYEOF

rm -f "$tmp_all"

# ── Phase 2: Deploy each unique skill ─────────────────────────────────────────

while IFS=: read -r skill_name skill_path; do
  [[ -n "$skill_name" && -n "$skill_path" ]] || continue
  total_skills=$((total_skills + 1))
  tag=$(get_sync_tag "${skill_path}/SKILL.md")
  if [[ "$STATUS_ONLY" == false ]]; then
    echo "  → $skill_name  ($tag)"
  fi
  sync_skill "$skill_name" "$skill_path" "$tag"
done < "$tmp_deduped"

rm -f "$tmp_deduped"

[[ "$STATUS_ONLY" == false ]] && echo ""

# ── Phase 2b: Sync USER directories ──────────────────────────────────────────
# Last repo's USER/ wins (same precedence as skills: PAI < pai-personal < pai-work)

PAI_USER_DIR="${HOME}/.pai/USER"
user_synced=0

while IFS= read -r raw_path || [[ -n "$raw_path" ]]; do
  [[ "$raw_path" =~ ^[[:space:]]*$ || "$raw_path" =~ ^# ]] && continue
  local_repo=$(expand_path "$raw_path")
  [[ -d "${local_repo}/USER" ]] || continue

  if [[ "$STATUS_ONLY" == false && "$DRY_RUN" == false ]]; then
    mkdir -p "$PAI_USER_DIR"
  fi

  # Sync all files from repo USER/ to ~/.pai/USER/ (recursive, preserving structure)
  while IFS= read -r -d '' src_file; do
    rel_path="${src_file#${local_repo}/USER/}"
    dst_file="${PAI_USER_DIR}/${rel_path}"

    if [[ ! -f "$dst_file" ]]; then
      if [[ "$STATUS_ONLY" == true ]]; then
        user_synced=$((user_synced + 1))
      elif [[ "$DRY_RUN" == true ]]; then
        echo "  [CREATE] USER: ${rel_path}"
      else
        mkdir -p "$(dirname "$dst_file")"
        cp "$src_file" "$dst_file"
        echo "  [CREATED] USER: ${rel_path}"
        user_synced=$((user_synced + 1))
      fi
    elif ! diff -q "$src_file" "$dst_file" > /dev/null 2>&1; then
      if [[ "$STATUS_ONLY" == true ]]; then
        user_synced=$((user_synced + 1))
      elif [[ "$DRY_RUN" == true ]]; then
        echo "  [UPDATE]  USER: ${rel_path}"
      else
        cp "$src_file" "$dst_file"
        echo "  [UPDATED] USER: ${rel_path}"
        user_synced=$((user_synced + 1))
      fi
    fi
  done < <(find "${local_repo}/USER" -type f -print0)
done < "$SOURCES_CONF"

[[ "$STATUS_ONLY" == false && "$DRY_RUN" == false && $user_synced -gt 0 ]] && echo "  USER: $user_synced files synced"
[[ "$STATUS_ONLY" == false ]] && echo ""

# ── Phase 3: Clean orphaned skills from targets ──────────────────────────────

if [[ "$CLEAN" == true ]]; then
  echo "── Cleaning orphaned skills ──"
  echo ""

  # Build set of known skill names from the discovered+deduped list
  # We saved known_skills during Phase 2 loop above
  # Re-discover to get the name list (lightweight)
  tmp_names=$(mktemp)
  TEMP_FILES+=("$tmp_names")

  while IFS= read -r raw_path || [[ -n "$raw_path" ]]; do
    [[ "$raw_path" =~ ^[[:space:]]*$ || "$raw_path" =~ ^# ]] && continue
    local_repo=$(expand_path "$raw_path")
    [[ -d "$local_repo" ]] || continue
    discover_skills "$local_repo"
  done < "$SOURCES_CONF" | cut -d: -f1 | sort -u > "$tmp_names"

  # Also add kebab-case versions for pi matching
  tmp_kebab=$(mktemp)
  TEMP_FILES+=("$tmp_kebab")
  while IFS= read -r sname; do
    echo "$sname"
    to_kebab "$sname"
  done < "$tmp_names" | sort -u > "$tmp_kebab"
  mv "$tmp_kebab" "$tmp_names"

  # Scan each target directory
  for target_label_dir in "claude:${CLAUDE_SKILLS}" "gemini:${GEMINI_SKILLS}" "pi:${PI_SKILLS}"; do
    target_label="${target_label_dir%%:*}"
    target_dir="${target_label_dir#*:}"
    [[ -d "$target_dir" ]] || continue

    for skill_dir in "$target_dir"/*/; do
      [[ -d "$skill_dir" ]] || continue
      skill_name=$(basename "$skill_dir")

      if ! grep -qx "$skill_name" "$tmp_names"; then
        if [[ "$DRY_RUN" == true ]]; then
          echo "  [ORPHAN]  ${target_label}: ${skill_name}/"
        else
          rm -rf "$skill_dir"
          echo "  [REMOVED] ${target_label}: ${skill_name}/"
        fi
        cleaned=$((cleaned + 1))
      fi
    done
  done

  rm -f "$tmp_names"

  echo ""
  if [[ $cleaned -gt 0 ]]; then
    [[ "$DRY_RUN" == true ]] \
      && echo "  $cleaned orphaned skills found. Run with --clean --confirm to remove." \
      || echo "  $cleaned orphaned skills removed."
  else
    echo "  No orphaned skills found. Targets are clean."
  fi
  echo ""
fi

# ── Summary ───────────────────────────────────────────────────────────────────

if [[ "$STATUS_ONLY" == true ]]; then
  echo "════ pai-sync status ════════════════════════════════════════════════"
  echo "  Skills scanned : $total_skills"
  echo "  To create      : $created"
  echo "  To update      : $updated"
  echo "  Up to date     : $unchanged"
  echo "  Pi scripts     : $scripts_synced changes"
  echo "  USER files     : $user_synced changes"
  echo ""
  [[ $((created + updated)) -gt 0 ]] \
    && echo "  Run: pai-sync.sh --confirm  to apply" \
    || echo "  All targets up to date."
  echo "════════════════════════════════════════════════════════════════════"
else
  echo "════ done ═══════════════════════════════════════════════════════════"
  if [[ "$DRY_RUN" == true ]]; then
    echo "  (dry run — no changes written)"
    echo "  Run with --confirm to apply"
  else
    echo "  Created : $created  Updated: $updated  Unchanged: $unchanged"
    [[ $scripts_synced -gt 0 ]] && echo "  Pi scripts: $scripts_synced synced"
    [[ $user_synced -gt 0 ]] && echo "  USER: $user_synced files synced"
    [[ $cleaned -gt 0 ]] && echo "  Cleaned : $cleaned orphaned skills removed"
  fi
  echo "════════════════════════════════════════════════════════════════════"
fi
