#!/usr/bin/env bash
# Confluence REST API wrapper
# Requires: CONFLUENCE_URL + CONFLUENCE_EMAIL + CONFLUENCE_TOKEN in ~/.env
# Auth: Basic auth (email:api_token) — same as atlassian-python-api cloud mode
set -euo pipefail

CONFLUENCE_URL="${CONFLUENCE_URL:?Set CONFLUENCE_URL in ~/.env}"
API="${CONFLUENCE_URL}/rest/api"
EMAIL="${CONFLUENCE_EMAIL:?Set CONFLUENCE_EMAIL in ~/.env}"
TOKEN="${CONFLUENCE_TOKEN:?Set CONFLUENCE_TOKEN in ~/.env}"

# Common curl with auth (basic: email:token)
cc() {
  curl -sS --fail-with-body -u "${EMAIL}:${TOKEN}" "$@"
}

usage() {
  cat <<'EOF'
Confluence CLI — /rest/api

USAGE: confluence.sh <command> [args...]

SEARCH:
  search <CQL_QUERY> [--limit N]                 Search with CQL
  search-text <TEXT> [--space KEY] [--limit N]    Full-text search

PAGES:
  page <PAGE_ID> [--expand body.storage,version]  Get page by ID
  page-by-title <SPACE> <TITLE>                   Find page by exact title
  children <PAGE_ID> [--limit N]                   Get child pages
  ancestors <PAGE_ID>                              Get parent chain

PAGE CRUD:
  create <SPACE> <TITLE> <BODY_HTML> [--parent ID] Create page
  update <PAGE_ID> <TITLE> <BODY_HTML> [--version N] Update page
  delete <PAGE_ID>                                 Delete/trash page
  append <PAGE_ID> <HTML_TO_APPEND>                Append to existing page

COMMENTS:
  comments <PAGE_ID> [--limit N]                   List page comments
  comment <PAGE_ID> <BODY_HTML>                    Add comment

LABELS:
  labels <PAGE_ID>                                 Get labels
  label-add <PAGE_ID> <LABEL>                      Add label
  label-remove <PAGE_ID> <LABEL>                   Remove label

SPACES:
  spaces [--limit N]                               List spaces
  space <SPACE_KEY>                                Get space details

ATTACHMENTS:
  attachments <PAGE_ID>                            List attachments
  attachment-download <PAGE_ID> <FILENAME>         Download attachment

USERS:
  user <USERNAME>                                  Get user info
  user-search <QUERY>                              Search users

OPTIONS:
  --limit N       Results per request (default: 25, max: 100)
  --expand FIELD  Comma-separated expansions (body.storage, version, space, etc.)

CQL EXAMPLES:
  "type=page AND space=MYSPACE AND title~'meeting'"
  "label=important AND lastmodified > now('-7d')"
  "creator=currentUser() AND type=page"
EOF
  exit 1
}

[[ $# -lt 1 ]] && usage
cmd="$1"; shift

case "$cmd" in

  # === SEARCH ===
  search)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh search <CQL> [--limit N]"; exit 1; }
    cql="$1"; shift
    limit=25
    while [[ $# -gt 0 ]]; do case "$1" in --limit) limit="$2"; shift 2 ;; *) shift ;; esac; done
    encoded_cql=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$cql', safe=''))")
    cc "${API}/content/search?cql=${encoded_cql}&limit=${limit}&expand=space,version" | jq '{total: .size, results: [.results[] | {id, type, title, space: .space.key, version: .version.number, url: ._links.webui}]}'
    ;;

  search-text)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh search-text <TEXT> [--space KEY] [--limit N]"; exit 1; }
    text="$1"; shift
    space="" ; limit=25
    while [[ $# -gt 0 ]]; do
      case "$1" in --space) space="$2"; shift 2 ;; --limit) limit="$2"; shift 2 ;; *) shift ;; esac
    done
    cql="type=page AND text~\"${text}\""
    [[ -n "$space" ]] && cql="space=${space} AND ${cql}"
    encoded_cql=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$cql''', safe=''))")
    cc "${API}/content/search?cql=${encoded_cql}&limit=${limit}&expand=space,version" | jq '{total: .size, results: [.results[] | {id, type, title, space: .space.key, url: ._links.webui}]}'
    ;;

  # === PAGES ===
  page)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh page <PAGE_ID> [--expand FIELDS]"; exit 1; }
    page_id="$1"; shift
    expand="body.storage,version,space"
    while [[ $# -gt 0 ]]; do case "$1" in --expand) expand="$2"; shift 2 ;; *) shift ;; esac; done
    cc "${API}/content/${page_id}?expand=${expand}" | jq '{id, type, title, space: .space.key, version: .version.number, body: .body.storage.value, url: ._links.webui}'
    ;;

  page-by-title)
    [[ $# -lt 2 ]] && { echo "Usage: confluence.sh page-by-title <SPACE_KEY> <TITLE>"; exit 1; }
    space_key="$1"; title="$2"
    encoded_title=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$title', safe=''))")
    cc "${API}/content?spaceKey=${space_key}&title=${encoded_title}&expand=body.storage,version" | jq '{results: [.results[] | {id, title, version: .version.number, body: .body.storage.value}]}'
    ;;

  children)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh children <PAGE_ID> [--limit N]"; exit 1; }
    page_id="$1"; shift
    limit=50
    while [[ $# -gt 0 ]]; do case "$1" in --limit) limit="$2"; shift 2 ;; *) shift ;; esac; done
    cc "${API}/content/${page_id}/child/page?limit=${limit}&expand=version" | jq '[.results[] | {id, title, version: .version.number}]'
    ;;

  ancestors)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh ancestors <PAGE_ID>"; exit 1; }
    cc "${API}/content/$1?expand=ancestors" | jq '[.ancestors[] | {id, title}]'
    ;;

  # === PAGE CRUD ===
  create)
    [[ $# -lt 3 ]] && { echo "Usage: confluence.sh create <SPACE_KEY> <TITLE> <BODY_HTML> [--parent ID]"; exit 1; }
    space_key="$1"; title="$2"; body_html="$3"; shift 3
    parent=""
    while [[ $# -gt 0 ]]; do case "$1" in --parent) parent="$2"; shift 2 ;; *) shift ;; esac; done
    payload=$(jq -n \
      --arg s "$space_key" \
      --arg t "$title" \
      --arg b "$body_html" \
      '{type: "page", title: $t, space: {key: $s}, body: {storage: {value: $b, representation: "storage"}}}')
    [[ -n "$parent" ]] && payload=$(echo "$payload" | jq --arg p "$parent" '. + {ancestors: [{id: ($p | tonumber)}]}')
    cc -X POST -H "Content-Type: application/json" -d "$payload" "${API}/content" | jq '{id, title, url: ._links.webui}'
    ;;

  update)
    [[ $# -lt 3 ]] && { echo "Usage: confluence.sh update <PAGE_ID> <TITLE> <BODY_HTML> [--version N]"; exit 1; }
    page_id="$1"; title="$2"; body_html="$3"; shift 3
    version=""
    while [[ $# -gt 0 ]]; do case "$1" in --version) version="$2"; shift 2 ;; *) shift ;; esac; done
    # Auto-get current version if not provided
    if [[ -z "$version" ]]; then
      version=$(cc "${API}/content/${page_id}?expand=version" | jq '.version.number')
    fi
    next_version=$((version + 1))
    payload=$(jq -n \
      --arg t "$title" \
      --arg b "$body_html" \
      --argjson v "$next_version" \
      '{type: "page", title: $t, version: {number: $v}, body: {storage: {value: $b, representation: "storage"}}}')
    cc -X PUT -H "Content-Type: application/json" -d "$payload" "${API}/content/${page_id}" | jq '{id, title, version: .version.number, url: ._links.webui}'
    ;;

  delete)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh delete <PAGE_ID>"; exit 1; }
    cc -X DELETE "${API}/content/$1"
    echo '{"status": "deleted", "id": "'"$1"'"}'
    ;;

  append)
    [[ $# -lt 2 ]] && { echo "Usage: confluence.sh append <PAGE_ID> <HTML_TO_APPEND>"; exit 1; }
    page_id="$1"; append_html="$2"
    # Get current page
    current=$(cc "${API}/content/${page_id}?expand=body.storage,version")
    title=$(echo "$current" | jq -r '.title')
    current_body=$(echo "$current" | jq -r '.body.storage.value')
    version=$(echo "$current" | jq '.version.number')
    next_version=$((version + 1))
    new_body="${current_body}${append_html}"
    payload=$(jq -n \
      --arg t "$title" \
      --arg b "$new_body" \
      --argjson v "$next_version" \
      '{type: "page", title: $t, version: {number: $v}, body: {storage: {value: $b, representation: "storage"}}}')
    cc -X PUT -H "Content-Type: application/json" -d "$payload" "${API}/content/${page_id}" | jq '{id, title, version: .version.number, url: ._links.webui}'
    ;;

  # === COMMENTS ===
  comments)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh comments <PAGE_ID> [--limit N]"; exit 1; }
    page_id="$1"; shift
    limit=25
    while [[ $# -gt 0 ]]; do case "$1" in --limit) limit="$2"; shift 2 ;; *) shift ;; esac; done
    cc "${API}/content/${page_id}/child/comment?limit=${limit}&expand=body.storage,version" | jq '[.results[] | {id, author: .version.by.displayName, body: .body.storage.value, created: .version.when}]'
    ;;

  comment)
    [[ $# -lt 2 ]] && { echo "Usage: confluence.sh comment <PAGE_ID> <BODY_HTML>"; exit 1; }
    payload=$(jq -n \
      --arg pid "$1" \
      --arg b "$2" \
      '{type: "comment", container: {id: $pid, type: "page"}, body: {storage: {value: $b, representation: "storage"}}}')
    cc -X POST -H "Content-Type: application/json" -d "$payload" "${API}/content" | jq '{id, title, url: ._links.webui}'
    ;;

  # === LABELS ===
  labels)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh labels <PAGE_ID>"; exit 1; }
    cc "${API}/content/$1/label" | jq '[.results[] | {name, prefix}]'
    ;;

  label-add)
    [[ $# -lt 2 ]] && { echo "Usage: confluence.sh label-add <PAGE_ID> <LABEL>"; exit 1; }
    cc -X POST -H "Content-Type: application/json" -d "[{\"prefix\":\"global\",\"name\":\"$2\"}]" "${API}/content/$1/label" | jq '[.results[] | {name, prefix}]'
    ;;

  label-remove)
    [[ $# -lt 2 ]] && { echo "Usage: confluence.sh label-remove <PAGE_ID> <LABEL>"; exit 1; }
    cc -X DELETE "${API}/content/$1/label/$2"
    echo '{"status": "removed", "label": "'"$2"'"}'
    ;;

  # === SPACES ===
  spaces)
    limit=50
    while [[ $# -gt 0 ]]; do case "$1" in --limit) limit="$2"; shift 2 ;; *) shift ;; esac; done
    cc "${API}/space?limit=${limit}&expand=description.plain" | jq '[.results[] | {key, name, type, description: (.description.plain.value // "" | .[0:100])}]'
    ;;

  space)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh space <SPACE_KEY>"; exit 1; }
    cc "${API}/space/$1?expand=description.plain,homepage" | jq '{key, name, type, description: .description.plain.value, homepage_id: .homepage.id, homepage_title: .homepage.title}'
    ;;

  # === ATTACHMENTS ===
  attachments)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh attachments <PAGE_ID>"; exit 1; }
    cc "${API}/content/$1/child/attachment?expand=version" | jq '[.results[] | {id, title, mediaType, fileSize: .extensions.fileSize, download: ._links.download}]'
    ;;

  attachment-download)
    [[ $# -lt 2 ]] && { echo "Usage: confluence.sh attachment-download <PAGE_ID> <FILENAME>"; exit 1; }
    download_url=$(cc "${API}/content/$1/child/attachment?filename=$2" | jq -r '.results[0]._links.download // empty')
    [[ -z "$download_url" ]] && { echo "Attachment not found: $2"; exit 1; }
    cc -o "$2" "${CONFLUENCE_URL}${download_url}"
    echo "Downloaded: $2"
    ;;

  # === USERS ===
  user)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh user <USERNAME>"; exit 1; }
    cc "${API}/user?username=$1" | jq '{username: .username, displayName, email: .email, userKey}'
    ;;

  user-search)
    [[ $# -lt 1 ]] && { echo "Usage: confluence.sh user-search <QUERY>"; exit 1; }
    encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$1', safe=''))")
    cc "${API}/search/user?cql=user.fullname~\"${encoded}\"&limit=10" | jq '.'
    ;;

  *)
    echo "Unknown command: $cmd"
    usage
    ;;
esac
