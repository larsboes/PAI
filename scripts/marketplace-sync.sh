#!/usr/bin/env bash
#
# marketplace-sync.sh — Sync Packs/ → marketplace/ for Claude Code plugin distribution
#
# Source of truth: Packs/{PackName}/src/{skill-name}/SKILL.md
# Target:          marketplace/plugins/{pack-name}/skills/{skill-name}/SKILL.md
#
# Also generates:
#   marketplace/plugins/{pack-name}/.claude-plugin/plugin.json
#   .claude-plugin/marketplace.json
#
# Usage:
#   marketplace-sync.sh             # dry run (default)
#   marketplace-sync.sh --confirm   # apply changes
#   marketplace-sync.sh --status    # compact drift summary
#
# Repository: https://github.com/larsboes/PAI

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKS_DIR="${REPO_ROOT}/Packs"
MARKETPLACE_DIR="${REPO_ROOT}/marketplace/plugins"
MARKETPLACE_JSON="${REPO_ROOT}/.claude-plugin/marketplace.json"

# ── Config ──────────────────────────────────────────────────────────────────

OWNER_NAME="Lars Boes"
OWNER_EMAIL=""
REPO_URL="https://github.com/larsboes/PAI"
PLUGIN_VERSION="1.0.0"
LICENSE="MIT"

# Packs to EXCLUDE from marketplace (personal/niche — override with MARKETPLACE_INCLUDE_ALL=1)
EXCLUDE_PACKS=()

# ── Modes ───────────────────────────────────────────────────────────────────

DRY_RUN=true
STATUS_ONLY=false

# ── Counters ────────────────────────────────────────────────────────────────

created=0
updated=0
unchanged=0
removed=0

# ── Helpers ─────────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
Usage: marketplace-sync.sh [--dry-run | --confirm | --status]

  (no flag)   Dry run — print what would change, no writes
  --dry-run   Dry run (explicit)
  --confirm   Apply all changes
  --status    Show drift summary only (compact)
  --help      Show this help

Syncs Packs/ → marketplace/plugins/ and regenerates marketplace.json
EOF
}

# to_lower <Name> → name (lowercase, preserving hyphens)
to_lower() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

# is_excluded <PackName>
is_excluded() {
  local pack="$1"
  for exc in "${EXCLUDE_PACKS[@]+"${EXCLUDE_PACKS[@]}"}"; do
    [[ "$pack" == "$exc" ]] && return 0
  done
  return 1
}

# get_pack_description <pack_dir>
# Extracts description from Pack README.md frontmatter, or generates from skill list
get_pack_description() {
  local pack_dir="$1"
  local readme="${pack_dir}/README.md"

  if [[ -f "$readme" ]]; then
    # Try frontmatter description field
    local desc
    desc=$(sed -n '/^---$/,/^---$/{ /^description:/{ s/^description:[[:space:]]*"\{0,1\}//; s/"\{0,1\}[[:space:]]*$//; p; q; } }' "$readme")
    if [[ -n "$desc" ]]; then
      echo "$desc"
      return
    fi
  fi

  # Fallback: list skill names
  local skills=()
  for skill_dir in "${pack_dir}/src"/*/; do
    [[ -f "${skill_dir}SKILL.md" ]] || continue
    skills+=("$(basename "${skill_dir%/}")")
  done
  # Pack-level SKILL.md
  if [[ -f "${pack_dir}/src/SKILL.md" ]]; then
    skills+=("$(basename "${pack_dir%/}")")
  fi

  local IFS=', '
  echo "${skills[*]}"
}

# sync_file <src> <dst> <label>
# Compares and copies a single file. Respects DRY_RUN/STATUS_ONLY.
sync_file() {
  local src="$1"
  local dst="$2"
  local label="$3"

  if [[ ! -f "$dst" ]]; then
    if [[ "$STATUS_ONLY" == true ]]; then
      created=$((created + 1))
    elif [[ "$DRY_RUN" == true ]]; then
      echo "  [CREATE] ${label}"
      created=$((created + 1))
    else
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      # Preserve executable bit
      [[ -x "$src" ]] && chmod +x "$dst"
      echo "  [CREATED] ${label}"
      created=$((created + 1))
    fi
  elif ! diff -q "$src" "$dst" > /dev/null 2>&1; then
    if [[ "$STATUS_ONLY" == true ]]; then
      updated=$((updated + 1))
    elif [[ "$DRY_RUN" == true ]]; then
      echo "  [UPDATE]  ${label}"
      updated=$((updated + 1))
    else
      cp "$src" "$dst"
      [[ -x "$src" ]] && chmod +x "$dst"
      echo "  [UPDATED] ${label}"
      updated=$((updated + 1))
    fi
  else
    unchanged=$((unchanged + 1))
  fi
}

# write_if_changed <content> <dst> <label>
# Writes generated content if different from existing file.
write_if_changed() {
  local content="$1"
  local dst="$2"
  local label="$3"

  if [[ ! -f "$dst" ]]; then
    if [[ "$STATUS_ONLY" == true ]]; then
      created=$((created + 1))
    elif [[ "$DRY_RUN" == true ]]; then
      echo "  [CREATE] ${label}"
      created=$((created + 1))
    else
      mkdir -p "$(dirname "$dst")"
      echo "$content" > "$dst"
      echo "  [CREATED] ${label}"
      created=$((created + 1))
    fi
  elif [[ "$(cat "$dst")" != "$content" ]]; then
    if [[ "$STATUS_ONLY" == true ]]; then
      updated=$((updated + 1))
    elif [[ "$DRY_RUN" == true ]]; then
      echo "  [UPDATE]  ${label}"
      updated=$((updated + 1))
    else
      echo "$content" > "$dst"
      echo "  [UPDATED] ${label}"
      updated=$((updated + 1))
    fi
  else
    unchanged=$((unchanged + 1))
  fi
}

# remove_path <path> <label>
remove_path() {
  local path="$1"
  local label="$2"

  if [[ "$STATUS_ONLY" == true ]]; then
    removed=$((removed + 1))
  elif [[ "$DRY_RUN" == true ]]; then
    echo "  [REMOVE] ${label}"
    removed=$((removed + 1))
  else
    rm -rf "$path"
    echo "  [REMOVED] ${label}"
    removed=$((removed + 1))
  fi
}

# ── Argument parsing ────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --confirm)   DRY_RUN=false; shift ;;
    --dry-run)   DRY_RUN=true; shift ;;
    --status)    STATUS_ONLY=true; DRY_RUN=true; shift ;;
    --help|-h)   usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
done

# ── Validate ────────────────────────────────────────────────────────────────

if [[ ! -d "$PACKS_DIR" ]]; then
  echo "ERROR: Packs directory not found at $PACKS_DIR"
  exit 1
fi

# ── Main ────────────────────────────────────────────────────────────────────

if [[ "$STATUS_ONLY" == false ]]; then
  echo ""
  echo "════ marketplace-sync ═══════════════════════════════════════════════"
  [[ "$DRY_RUN" == true ]] \
    && echo "Mode: DRY RUN  (use --confirm to apply changes)" \
    || echo "Mode: CONFIRM"
  echo "Source: ${PACKS_DIR}"
  echo "Target: ${MARKETPLACE_DIR}"
  echo ""
fi

# Track which plugins we create (for marketplace.json generation and orphan cleanup)
declare -A PLUGIN_MAP  # plugin_name → description

total_skills=0

for pack_dir in "${PACKS_DIR}"/*/; do
  [[ -d "$pack_dir" ]] || continue
  pack_name=$(basename "$pack_dir")

  # Skip excluded packs
  if is_excluded "$pack_name"; then
    [[ "$STATUS_ONLY" == false ]] && echo "  ⊘ ${pack_name} (excluded)"
    continue
  fi

  # Skip packs with no skills
  skill_count=$(find "$pack_dir" -name "SKILL.md" 2>/dev/null | wc -l)
  if [[ "$skill_count" -eq 0 ]]; then
    [[ "$STATUS_ONLY" == false ]] && echo "  ⊘ ${pack_name} (no skills)"
    continue
  fi

  plugin_name=$(to_lower "$pack_name")
  plugin_dir="${MARKETPLACE_DIR}/${plugin_name}"
  description=$(get_pack_description "$pack_dir")

  PLUGIN_MAP["$plugin_name"]="$description"

  [[ "$STATUS_ONLY" == false ]] && echo "  → ${pack_name} → ${plugin_name}/ (${skill_count} skills)"

  # ── Generate plugin.json ──────────────────────────────────────────────
  plugin_json=$(cat <<EOF
{
  "name": "${plugin_name}",
  "description": "${description}",
  "version": "${PLUGIN_VERSION}",
  "author": {
    "name": "${OWNER_NAME}"
  },
  "repository": "${REPO_URL}",
  "homepage": "${REPO_URL}#${plugin_name}",
  "license": "${LICENSE}"
}
EOF
)
  write_if_changed "$plugin_json" "${plugin_dir}/.claude-plugin/plugin.json" "${plugin_name}: plugin.json"

  # ── Collect expected skills for this plugin (for orphan detection) ────
  declare -A expected_skills=()

  # ── Sync sub-skills: src/{skill-name}/SKILL.md ────────────────────────
  if [[ -d "${pack_dir}src" ]]; then
    for skill_src in "${pack_dir}src"/*/; do
      [[ -f "${skill_src}SKILL.md" ]] || continue
      skill_name=$(basename "${skill_src%/}")
      # Skip sub-skill directories that are children of other skills (e.g., Documents/Docx)
      # These are handled by their parent skill's file sync
      total_skills=$((total_skills + 1))
      expected_skills["$skill_name"]=1
      skill_dst="${plugin_dir}/skills/${skill_name}"

      # Sync all files in the skill directory recursively
      while IFS= read -r -d '' src_file; do
        rel_path="${src_file#${skill_src}}"
        sync_file "$src_file" "${skill_dst}/${rel_path}" "${plugin_name}/${skill_name}/${rel_path}"
      done < <(find "$skill_src" -type f -print0)
    done

    # ── Pack-level SKILL.md: src/SKILL.md (single-skill Pack) ───────────
    if [[ -f "${pack_dir}src/SKILL.md" ]]; then
      # Check it's not already handled as a sub-skill directory
      # Pack-level skill uses the pack name as skill name
      pack_skill_name=$(to_lower "$pack_name")
      if [[ -z "${expected_skills[$pack_skill_name]+x}" ]]; then
        total_skills=$((total_skills + 1))
        expected_skills["$pack_skill_name"]=1
        skill_dst="${plugin_dir}/skills/${pack_skill_name}"

        # Only sync the pack-level SKILL.md and any non-subdir files in src/
        sync_file "${pack_dir}src/SKILL.md" "${skill_dst}/SKILL.md" "${plugin_name}/${pack_skill_name}/SKILL.md"

        # Sync Workflows/ and Tools/ at pack level if they exist
        for extra_dir in "Workflows" "Tools"; do
          if [[ -d "${pack_dir}src/${extra_dir}" ]]; then
            while IFS= read -r -d '' src_file; do
              rel_path="${src_file#${pack_dir}src/}"
              sync_file "$src_file" "${skill_dst}/${rel_path}" "${plugin_name}/${pack_skill_name}/${rel_path}"
            done < <(find "${pack_dir}src/${extra_dir}" -type f -print0)
          fi
        done
      fi
    fi
  fi

  # ── Remove orphaned skills from this plugin ───────────────────────────
  if [[ -d "${plugin_dir}/skills" ]]; then
    for existing_skill_dir in "${plugin_dir}/skills"/*/; do
      [[ -d "$existing_skill_dir" ]] || continue
      existing_skill=$(basename "$existing_skill_dir")
      if [[ -z "${expected_skills[$existing_skill]+x}" ]]; then
        remove_path "$existing_skill_dir" "${plugin_name}/${existing_skill}/ (orphan)"
      fi
    done
  fi

  # ── Remove orphaned files within existing skills ──────────────────────
  if [[ -d "${plugin_dir}/skills" ]]; then
    for existing_skill_dir in "${plugin_dir}/skills"/*/; do
      [[ -d "$existing_skill_dir" ]] || continue
      existing_skill=$(basename "$existing_skill_dir")

      # Find corresponding source
      local_src=""
      if [[ -d "${pack_dir}src/${existing_skill}" ]]; then
        local_src="${pack_dir}src/${existing_skill}"
      fi
      [[ -n "$local_src" ]] || continue

      while IFS= read -r -d '' dst_file; do
        rel_path="${dst_file#${existing_skill_dir}}"
        src_candidate="${local_src}/${rel_path}"
        if [[ ! -f "$src_candidate" ]]; then
          remove_path "$dst_file" "${plugin_name}/${existing_skill}/${rel_path} (orphan)"
        fi
      done < <(find "$existing_skill_dir" -type f -print0)
    done
  fi

  unset expected_skills
done

[[ "$STATUS_ONLY" == false ]] && echo ""

# ── Remove orphaned plugins (in marketplace but no longer a Pack) ────────

if [[ -d "$MARKETPLACE_DIR" ]]; then
  for existing_plugin_dir in "${MARKETPLACE_DIR}"/*/; do
    [[ -d "$existing_plugin_dir" ]] || continue
    existing_plugin=$(basename "$existing_plugin_dir")
    if [[ -z "${PLUGIN_MAP[$existing_plugin]+x}" ]]; then
      remove_path "$existing_plugin_dir" "plugin: ${existing_plugin}/ (orphan)"
    fi
  done
fi

# ── Generate marketplace.json ────────────────────────────────────────────

# Build plugins array sorted by name
plugins_json=""
first=true
for plugin_name in $(echo "${!PLUGIN_MAP[@]}" | tr ' ' '\n' | sort); do
  desc="${PLUGIN_MAP[$plugin_name]}"
  # Escape double quotes in description
  desc="${desc//\"/\\\"}"
  if [[ "$first" == true ]]; then
    first=false
  else
    plugins_json+=","
  fi
  plugins_json+="
    {
      \"name\": \"${plugin_name}\",
      \"source\": \"./marketplace/plugins/${plugin_name}\",
      \"description\": \"${desc}\",
      \"repository\": \"${REPO_URL}\",
      \"license\": \"${LICENSE}\",
      \"strict\": false
    }"
done

marketplace_content=$(cat <<EOF
{
  "name": "pai-skills",
  "owner": {
    "name": "${OWNER_NAME}"
  },
  "metadata": {
    "description": "PAI skill marketplace — coding, devtools, integrations, content, terminal, and more",
    "version": "${PLUGIN_VERSION}",
    "pluginRoot": "./marketplace/plugins",
    "repository": "${REPO_URL}",
    "license": "${LICENSE}"
  },
  "plugins": [${plugins_json}
  ]
}
EOF
)

write_if_changed "$marketplace_content" "$MARKETPLACE_JSON" "marketplace.json"

# ── Summary ──────────────────────────────────────────────────────────────

if [[ "$STATUS_ONLY" == true ]]; then
  echo "════ marketplace-sync status ═══════════════════════════════════════"
  echo "  Skills scanned : $total_skills"
  echo "  To create      : $created"
  echo "  To update      : $updated"
  echo "  To remove      : $removed"
  echo "  Up to date     : $unchanged"
  echo ""
  [[ $((created + updated + removed)) -gt 0 ]] \
    && echo "  Run: marketplace-sync.sh --confirm  to apply" \
    || echo "  Marketplace is up to date."
  echo "════════════════════════════════════════════════════════════════════"
else
  echo "════ done ═══════════════════════════════════════════════════════════"
  if [[ "$DRY_RUN" == true ]]; then
    echo "  Skills: $total_skills | Create: $created | Update: $updated | Remove: $removed | OK: $unchanged"
    echo "  (dry run — no changes written)"
    echo "  Run with --confirm to apply"
  else
    echo "  Created: $created  Updated: $updated  Removed: $removed  Unchanged: $unchanged"
    echo "  Plugins: ${#PLUGIN_MAP[@]}  Skills: $total_skills"
  fi
  echo "════════════════════════════════════════════════════════════════════"
fi
