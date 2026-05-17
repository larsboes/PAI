#!/usr/bin/env bash
# GitLab REST API wrapper
# Requires: GITLAB_URL + GITLAB_TOKEN in ~/.env
set -euo pipefail

GITLAB_URL="${GITLAB_URL:?Set GITLAB_URL in ~/.env}"
API="${GITLAB_URL}/api/v4"
TOKEN="${GITLAB_TOKEN:?Set GITLAB_TOKEN in ~/.env}"

# Common curl with auth
gc() {
  curl -sS --fail-with-body -H "PRIVATE-TOKEN: ${TOKEN}" "$@"
}

# URL-encode helper
urlencode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('$1', safe=''))"
}

usage() {
  cat <<'EOF'
GitLab CLI — /api/v4

USAGE: gitlab.sh <command> [args...]

PROJECTS & GROUPS:
  projects [--search TEXT] [--per-page N]         List/search projects
  project <ID_OR_PATH>                            Get project details
  groups [--search TEXT]                           List/search groups
  group <ID>                                      Get group details
  group-projects <GROUP_ID>                       List projects in group

REPOSITORY:
  branches <PROJECT> [--search TEXT]              List branches
  files <PROJECT> <PATH> [--ref BRANCH]           Get file content (raw)
  tree <PROJECT> [--path DIR] [--ref BRANCH]      List repo tree

COMMITS:
  commits <PROJECT> [--ref BRANCH] [--per-page N] List commits
  commit <PROJECT> <SHA>                          Get commit details
  diff <PROJECT> <FROM> <TO>                      Compare refs (commits/branches/tags)

ISSUES:
  issues <PROJECT> [--state opened|closed|all] [--search TEXT]
  issue <PROJECT> <IID>                           Get issue details
  issue-create <PROJECT> <TITLE> [--desc TEXT] [--labels L1,L2]
  issue-update <PROJECT> <IID> [--title T] [--state close|reopen] [--labels L]
  issue-comments <PROJECT> <IID>                  List issue comments
  issue-comment <PROJECT> <IID> <BODY>            Add comment

MERGE REQUESTS:
  mrs <PROJECT> [--state opened|merged|closed|all] [--search TEXT]
  mr <PROJECT> <IID>                              Get MR details
  mr-changes <PROJECT> <IID>                      Get MR diff/changes
  mr-create <PROJECT> <SOURCE> <TARGET> <TITLE> [--desc TEXT]
  mr-update <PROJECT> <IID> [--title T] [--state close|reopen]
  mr-approve <PROJECT> <IID>                      Approve MR
  mr-merge <PROJECT> <IID> [--squash]             Merge MR
  mr-comments <PROJECT> <IID>                     List MR comments
  mr-comment <PROJECT> <IID> <BODY>               Add MR comment

PIPELINES:
  pipelines <PROJECT> [--ref BRANCH] [--status STATUS]
  pipeline <PROJECT> <ID>                         Get pipeline details
  pipeline-jobs <PROJECT> <ID>                    List pipeline jobs
  pipeline-run <PROJECT> <REF>                    Trigger new pipeline
  pipeline-retry <PROJECT> <ID>                   Retry failed pipeline
  job-log <PROJECT> <JOB_ID>                      Get job log output

SEARCH:
  search <SCOPE> <QUERY> [--project PROJECT]      Search (scopes: projects, issues, merge_requests, blobs, commits, wiki_blobs)

WIKI:
  wikis <PROJECT>                                 List wiki pages
  wiki <PROJECT> <SLUG>                           Get wiki page
  wiki-create <PROJECT> <TITLE> <CONTENT>         Create wiki page
  wiki-update <PROJECT> <SLUG> <CONTENT>          Update wiki page

OPTIONS:
  --per-page N    Results per page (default: 20, max: 100)
  --page N        Page number (default: 1)
  --json          Force raw JSON output (default)

PROJECT can be numeric ID or URL-encoded path (e.g., "group%2Fproject")
EOF
  exit 1
}

# Parse a project arg — encode path if not numeric
parse_project() {
  local p="$1"
  if [[ "$p" =~ ^[0-9]+$ ]]; then
    echo "$p"
  else
    urlencode "$p"
  fi
}

# Arg parsing helpers
per_page=20
page=1
parse_pagination() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --per-page) per_page="$2"; shift 2 ;;
      --page) page="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
}

[[ $# -lt 1 ]] && usage
cmd="$1"; shift

case "$cmd" in

  # === PROJECTS & GROUPS ===
  projects)
    search="" ; per_page=20
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --search) search="$2"; shift 2 ;;
        --per-page) per_page="$2"; shift 2 ;;
        --page) page="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    url="${API}/projects?per_page=${per_page}&page=${page}&membership=true&order_by=last_activity_at"
    [[ -n "$search" ]] && url+="&search=${search}"
    gc "$url" | jq '.[] | {id, path_with_namespace, description: (.description // "" | .[0:100]), web_url, default_branch}'
    ;;

  project)
    [[ $# -lt 1 ]] && { echo "Usage: gitlab.sh project <ID_OR_PATH>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}" | jq '{id, name, path_with_namespace, description, web_url, default_branch, visibility, created_at, last_activity_at, star_count, forks_count, open_issues_count}'
    ;;

  groups)
    search=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --search) search="$2"; shift 2 ;;
        --per-page) per_page="$2"; shift 2 ;;
        *) shift ;;
      esac
    done
    url="${API}/groups?per_page=${per_page}&order_by=name"
    [[ -n "$search" ]] && url+="&search=${search}"
    gc "$url" | jq '.[] | {id, full_path, description: (.description // "" | .[0:100]), web_url}'
    ;;

  group)
    [[ $# -lt 1 ]] && { echo "Usage: gitlab.sh group <ID>"; exit 1; }
    gc "${API}/groups/$1" | jq '{id, name, full_path, description, web_url, visibility, created_at}'
    ;;

  group-projects)
    [[ $# -lt 1 ]] && { echo "Usage: gitlab.sh group-projects <GROUP_ID>"; exit 1; }
    gc "${API}/groups/$1/projects?per_page=50&order_by=last_activity_at" | jq '.[] | {id, path_with_namespace, web_url}'
    ;;

  # === REPOSITORY ===
  branches)
    [[ $# -lt 1 ]] && { echo "Usage: gitlab.sh branches <PROJECT> [--search TEXT]"; exit 1; }
    proj=$(parse_project "$1"); shift
    search=""
    while [[ $# -gt 0 ]]; do case "$1" in --search) search="$2"; shift 2 ;; *) shift ;; esac; done
    url="${API}/projects/${proj}/repository/branches?per_page=50"
    [[ -n "$search" ]] && url+="&search=${search}"
    gc "$url" | jq '.[] | {name, merged: .merged, protected: .protected, commit_short: .commit.short_id, commit_date: .commit.committed_date}'
    ;;

  files)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh files <PROJECT> <PATH> [--ref BRANCH]"; exit 1; }
    proj=$(parse_project "$1"); fpath=$(urlencode "$2"); shift 2
    ref="HEAD"
    while [[ $# -gt 0 ]]; do case "$1" in --ref) ref="$2"; shift 2 ;; *) shift ;; esac; done
    gc "${API}/projects/${proj}/repository/files/${fpath}/raw?ref=${ref}"
    ;;

  tree)
    [[ $# -lt 1 ]] && { echo "Usage: gitlab.sh tree <PROJECT> [--path DIR] [--ref BRANCH]"; exit 1; }
    proj=$(parse_project "$1"); shift
    path="" ; ref=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --path) path="$2"; shift 2 ;; --ref) ref="$2"; shift 2 ;; *) shift ;; esac
    done
    url="${API}/projects/${proj}/repository/tree?per_page=100&recursive=false"
    [[ -n "$path" ]] && url+="&path=${path}"
    [[ -n "$ref" ]] && url+="&ref=${ref}"
    gc "$url" | jq '.[] | {name, type, path}'
    ;;

  # === COMMITS ===
  commits)
    [[ $# -lt 1 ]] && { echo "Usage: gitlab.sh commits <PROJECT> [--ref BRANCH]"; exit 1; }
    proj=$(parse_project "$1"); shift
    ref="" ; per_page=20
    while [[ $# -gt 0 ]]; do
      case "$1" in --ref) ref="$2"; shift 2 ;; --per-page) per_page="$2"; shift 2 ;; *) shift ;; esac
    done
    url="${API}/projects/${proj}/repository/commits?per_page=${per_page}"
    [[ -n "$ref" ]] && url+="&ref_name=${ref}"
    gc "$url" | jq '.[] | {short_id, title, author_name, committed_date: .committed_date}'
    ;;

  commit)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh commit <PROJECT> <SHA>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/repository/commits/$2" | jq '{id, short_id, title, message, author_name, authored_date, stats}'
    ;;

  diff)
    [[ $# -lt 3 ]] && { echo "Usage: gitlab.sh diff <PROJECT> <FROM> <TO>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/repository/compare?from=$2&to=$3" | jq '{commits: [.commits[] | {short_id, title}], diffs: [.diffs[] | {old_path, new_path, diff: .diff}]}'
    ;;

  # === ISSUES ===
  issues)
    [[ $# -lt 1 ]] && { echo "Usage: gitlab.sh issues <PROJECT> [--state STATE] [--search TEXT]"; exit 1; }
    proj=$(parse_project "$1"); shift
    state="opened" ; search=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --state) state="$2"; shift 2 ;; --search) search="$2"; shift 2 ;; --per-page) per_page="$2"; shift 2 ;; *) shift ;; esac
    done
    url="${API}/projects/${proj}/issues?state=${state}&per_page=${per_page}"
    [[ -n "$search" ]] && url+="&search=${search}"
    gc "$url" | jq '.[] | {iid, title, state, author: .author.username, assignee: (.assignee.username // null), labels, created_at, web_url}'
    ;;

  issue)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh issue <PROJECT> <IID>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/issues/$2" | jq '{iid, title, state, description, author: .author.username, assignees: [.assignees[].username], labels, milestone: .milestone.title, created_at, updated_at, web_url}'
    ;;

  issue-create)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh issue-create <PROJECT> <TITLE> [--desc TEXT] [--labels L1,L2]"; exit 1; }
    proj=$(parse_project "$1"); title="$2"; shift 2
    desc="" ; labels=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --desc) desc="$2"; shift 2 ;; --labels) labels="$2"; shift 2 ;; *) shift ;; esac
    done
    body="{\"title\":$(jq -n --arg t "$title" '$t')}"
    [[ -n "$desc" ]] && body=$(echo "$body" | jq --arg d "$desc" '. + {description: $d}')
    [[ -n "$labels" ]] && body=$(echo "$body" | jq --arg l "$labels" '. + {labels: $l}')
    gc -X POST -H "Content-Type: application/json" -d "$body" "${API}/projects/${proj}/issues" | jq '{iid, title, web_url}'
    ;;

  issue-update)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh issue-update <PROJECT> <IID> [--title T] [--state close|reopen] [--labels L]"; exit 1; }
    proj=$(parse_project "$1"); iid="$2"; shift 2
    body="{}"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --title) body=$(echo "$body" | jq --arg v "$2" '. + {title: $v}'); shift 2 ;;
        --state) body=$(echo "$body" | jq --arg v "${2}_event" '. + {state_event: $v}'); shift 2 ;;
        --labels) body=$(echo "$body" | jq --arg v "$2" '. + {labels: $v}'); shift 2 ;;
        --desc) body=$(echo "$body" | jq --arg v "$2" '. + {description: $v}'); shift 2 ;;
        *) shift ;;
      esac
    done
    gc -X PUT -H "Content-Type: application/json" -d "$body" "${API}/projects/${proj}/issues/${iid}" | jq '{iid, title, state, web_url}'
    ;;

  issue-comments)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh issue-comments <PROJECT> <IID>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/issues/$2/notes?per_page=50" | jq '.[] | {id, author: .author.username, body: (.body | .[0:500]), created_at}'
    ;;

  issue-comment)
    [[ $# -lt 3 ]] && { echo "Usage: gitlab.sh issue-comment <PROJECT> <IID> <BODY>"; exit 1; }
    proj=$(parse_project "$1")
    gc -X POST -H "Content-Type: application/json" -d "{\"body\":$(jq -n --arg b "$3" '$b')}" "${API}/projects/${proj}/issues/$2/notes" | jq '{id, body: (.body | .[0:200]), created_at}'
    ;;

  # === MERGE REQUESTS ===
  mrs)
    [[ $# -lt 1 ]] && { echo "Usage: gitlab.sh mrs <PROJECT> [--state STATE] [--search TEXT]"; exit 1; }
    proj=$(parse_project "$1"); shift
    state="opened" ; search=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --state) state="$2"; shift 2 ;; --search) search="$2"; shift 2 ;; --per-page) per_page="$2"; shift 2 ;; *) shift ;; esac
    done
    url="${API}/projects/${proj}/merge_requests?state=${state}&per_page=${per_page}"
    [[ -n "$search" ]] && url+="&search=${search}"
    gc "$url" | jq '.[] | {iid, title, state, author: .author.username, source_branch, target_branch, web_url}'
    ;;

  mr)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh mr <PROJECT> <IID>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/merge_requests/$2" | jq '{iid, title, state, description, author: .author.username, source_branch, target_branch, merge_status, has_conflicts, changes_count, created_at, updated_at, web_url}'
    ;;

  mr-changes)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh mr-changes <PROJECT> <IID>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/merge_requests/$2/changes" | jq '{title, changes: [.changes[] | {old_path, new_path, diff: .diff}]}'
    ;;

  mr-create)
    [[ $# -lt 4 ]] && { echo "Usage: gitlab.sh mr-create <PROJECT> <SOURCE> <TARGET> <TITLE> [--desc TEXT]"; exit 1; }
    proj=$(parse_project "$1"); src="$2"; tgt="$3"; title="$4"; shift 4
    desc=""
    while [[ $# -gt 0 ]]; do case "$1" in --desc) desc="$2"; shift 2 ;; *) shift ;; esac; done
    body=$(jq -n --arg s "$src" --arg t "$tgt" --arg ti "$title" '{source_branch: $s, target_branch: $t, title: $ti}')
    [[ -n "$desc" ]] && body=$(echo "$body" | jq --arg d "$desc" '. + {description: $d}')
    gc -X POST -H "Content-Type: application/json" -d "$body" "${API}/projects/${proj}/merge_requests" | jq '{iid, title, web_url}'
    ;;

  mr-update)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh mr-update <PROJECT> <IID> [--title T] [--state close|reopen]"; exit 1; }
    proj=$(parse_project "$1"); iid="$2"; shift 2
    body="{}"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --title) body=$(echo "$body" | jq --arg v "$2" '. + {title: $v}'); shift 2 ;;
        --state) body=$(echo "$body" | jq --arg v "${2}_event" '. + {state_event: $v}'); shift 2 ;;
        --desc) body=$(echo "$body" | jq --arg v "$2" '. + {description: $v}'); shift 2 ;;
        *) shift ;;
      esac
    done
    gc -X PUT -H "Content-Type: application/json" -d "$body" "${API}/projects/${proj}/merge_requests/${iid}" | jq '{iid, title, state, web_url}'
    ;;

  mr-approve)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh mr-approve <PROJECT> <IID>"; exit 1; }
    proj=$(parse_project "$1")
    gc -X POST "${API}/projects/${proj}/merge_requests/$2/approve" | jq '{iid, title, state}'
    ;;

  mr-merge)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh mr-merge <PROJECT> <IID> [--squash]"; exit 1; }
    proj=$(parse_project "$1"); iid="$2"; shift 2
    squash="false"
    while [[ $# -gt 0 ]]; do case "$1" in --squash) squash="true"; shift ;; *) shift ;; esac; done
    gc -X PUT -H "Content-Type: application/json" -d "{\"squash\":${squash}}" "${API}/projects/${proj}/merge_requests/${iid}/merge" | jq '{iid, title, state, merge_commit_sha}'
    ;;

  mr-comments)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh mr-comments <PROJECT> <IID>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/merge_requests/$2/notes?per_page=50" | jq '.[] | {id, author: .author.username, body: (.body | .[0:500]), created_at}'
    ;;

  mr-comment)
    [[ $# -lt 3 ]] && { echo "Usage: gitlab.sh mr-comment <PROJECT> <IID> <BODY>"; exit 1; }
    proj=$(parse_project "$1")
    gc -X POST -H "Content-Type: application/json" -d "{\"body\":$(jq -n --arg b "$3" '$b')}" "${API}/projects/${proj}/merge_requests/$2/notes" | jq '{id, body: (.body | .[0:200]), created_at}'
    ;;

  # === PIPELINES ===
  pipelines)
    [[ $# -lt 1 ]] && { echo "Usage: gitlab.sh pipelines <PROJECT> [--ref BRANCH] [--status STATUS]"; exit 1; }
    proj=$(parse_project "$1"); shift
    ref="" ; status=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --ref) ref="$2"; shift 2 ;; --status) status="$2"; shift 2 ;; --per-page) per_page="$2"; shift 2 ;; *) shift ;; esac
    done
    url="${API}/projects/${proj}/pipelines?per_page=${per_page}"
    [[ -n "$ref" ]] && url+="&ref=${ref}"
    [[ -n "$status" ]] && url+="&status=${status}"
    gc "$url" | jq '.[] | {id, status, ref, sha: .sha[0:8], created_at, web_url}'
    ;;

  pipeline)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh pipeline <PROJECT> <ID>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/pipelines/$2" | jq '{id, status, ref, sha: .sha[0:8], duration, created_at, finished_at, web_url}'
    ;;

  pipeline-jobs)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh pipeline-jobs <PROJECT> <PIPELINE_ID>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/pipelines/$2/jobs?per_page=100" | jq '.[] | {id, name, stage, status, duration, web_url}'
    ;;

  pipeline-run)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh pipeline-run <PROJECT> <REF>"; exit 1; }
    proj=$(parse_project "$1")
    gc -X POST -H "Content-Type: application/json" -d "{\"ref\":\"$2\"}" "${API}/projects/${proj}/pipeline" | jq '{id, status, ref, web_url}'
    ;;

  pipeline-retry)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh pipeline-retry <PROJECT> <ID>"; exit 1; }
    proj=$(parse_project "$1")
    gc -X POST "${API}/projects/${proj}/pipelines/$2/retry" | jq '{id, status, ref, web_url}'
    ;;

  job-log)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh job-log <PROJECT> <JOB_ID>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/jobs/$2/trace"
    ;;

  # === SEARCH ===
  search)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh search <SCOPE> <QUERY> [--project PROJECT]"; exit 1; }
    scope="$1"; query="$2"; shift 2
    project=""
    while [[ $# -gt 0 ]]; do case "$1" in --project) project="$2"; shift 2 ;; *) shift ;; esac; done
    if [[ -n "$project" ]]; then
      proj=$(parse_project "$project")
      gc "${API}/projects/${proj}/search?scope=${scope}&search=$(urlencode "$query")&per_page=20"
    else
      gc "${API}/search?scope=${scope}&search=$(urlencode "$query")&per_page=20"
    fi | jq '.'
    ;;

  # === WIKI ===
  wikis)
    [[ $# -lt 1 ]] && { echo "Usage: gitlab.sh wikis <PROJECT>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/wikis" | jq '.[] | {slug, title, format}'
    ;;

  wiki)
    [[ $# -lt 2 ]] && { echo "Usage: gitlab.sh wiki <PROJECT> <SLUG>"; exit 1; }
    proj=$(parse_project "$1")
    gc "${API}/projects/${proj}/wikis/$2" | jq '{slug, title, content, format}'
    ;;

  wiki-create)
    [[ $# -lt 3 ]] && { echo "Usage: gitlab.sh wiki-create <PROJECT> <TITLE> <CONTENT>"; exit 1; }
    proj=$(parse_project "$1")
    gc -X POST -H "Content-Type: application/json" -d "$(jq -n --arg t "$2" --arg c "$3" '{title: $t, content: $c}')" "${API}/projects/${proj}/wikis" | jq '{slug, title}'
    ;;

  wiki-update)
    [[ $# -lt 3 ]] && { echo "Usage: gitlab.sh wiki-update <PROJECT> <SLUG> <CONTENT>"; exit 1; }
    proj=$(parse_project "$1")
    gc -X PUT -H "Content-Type: application/json" -d "$(jq -n --arg c "$3" '{content: $c}')" "${API}/projects/${proj}/wikis/$2" | jq '{slug, title}'
    ;;

  *)
    echo "Unknown command: $cmd"
    usage
    ;;
esac
