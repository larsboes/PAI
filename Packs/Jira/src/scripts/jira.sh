#!/usr/bin/env bash
# Jira REST API wrapper
# Requires: JIRA_URL + JIRA_EMAIL + JIRA_TOKEN in ~/.env
# Auth: Basic auth (email:api_token)
set -euo pipefail

JIRA_URL="${JIRA_URL:?Set JIRA_URL in ~/.env}"
API="${JIRA_URL}/rest/api/2"
AGILE_API="${JIRA_URL}/rest/agile/1.0"
EMAIL="${JIRA_EMAIL:?Set JIRA_EMAIL in ~/.env}"
TOKEN="${JIRA_TOKEN:?Set JIRA_TOKEN in ~/.env}"

# Common curl with auth (basic: email:token)
jc() {
  curl -sS --fail-with-body -u "${EMAIL}:${TOKEN}" -H "Content-Type: application/json" "$@"
}

usage() {
  cat <<'EOF'
Jira CLI — /rest/api/2

USAGE: jira.sh <command> [args...]

SEARCH:
  search <JQL> [--max N] [--fields F1,F2]        Search with JQL
  my-issues [--status STATUS]                     My open issues

ISSUES:
  issue <KEY>                                     Get issue details
  create <PROJECT> <TYPE> <SUMMARY> [--desc TEXT] [--priority P] [--labels L1,L2]
  update <KEY> [--summary S] [--desc D] [--labels L] [--priority P]
  delete <KEY>                                    Delete issue
  assign <KEY> <USERNAME>                         Assign issue
  transition <KEY> <TRANSITION_ID_OR_NAME>        Change status
  transitions <KEY>                               List available transitions

COMMENTS:
  comments <KEY> [--max N]                        List comments
  comment <KEY> <BODY>                            Add comment

WORKLOG:
  worklogs <KEY>                                  List work logs
  worklog <KEY> <TIME_SPENT> [--comment TEXT]     Add work log (e.g., "2h", "1d")

LINKS:
  link <FROM_KEY> <TO_KEY> <LINK_TYPE>            Link two issues
  link-types                                      List available link types

PROJECTS:
  projects [--max N]                              List projects
  project <KEY>                                   Get project details
  versions <PROJECT_KEY>                          List project versions
  version-create <PROJECT_KEY> <NAME> [--desc D] [--release-date YYYY-MM-DD]

BOARDS & SPRINTS (Agile):
  boards [--project KEY] [--type scrum|kanban]    List boards
  board-issues <BOARD_ID> [--max N]               Get board issues
  sprints <BOARD_ID> [--state active|future|closed]
  sprint-issues <SPRINT_ID> [--max N]             Get sprint issues
  sprint-create <BOARD_ID> <NAME> [--start DATE] [--end DATE]
  sprint-update <SPRINT_ID> [--name N] [--state active|closed]

FIELDS:
  fields [--search TEXT]                          List/search fields

USERS:
  user <USERNAME>                                 Get user info
  user-search <QUERY>                             Search users

JQL EXAMPLES:
  "project=MYPROJ AND status='In Progress'"
  "assignee=currentUser() AND resolution=Unresolved"
  "labels in (backend,api) AND updated > -7d"
  "type=Bug AND priority in (Critical,Blocker)"
EOF
  exit 1
}

[[ $# -lt 1 ]] && usage
cmd="$1"; shift

case "$cmd" in

  # === SEARCH ===
  search)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh search <JQL> [--max N] [--fields F1,F2]"; exit 1; }
    jql="$1"; shift
    max=20 ; fields="summary,status,assignee,priority,issuetype,created,updated,labels"
    while [[ $# -gt 0 ]]; do
      case "$1" in --max) max="$2"; shift 2 ;; --fields) fields="$2"; shift 2 ;; *) shift ;; esac
    done
    jc -X POST -d "$(jq -n --arg j "$jql" --argjson m "$max" --arg f "$fields" \
      '{jql: $j, maxResults: $m, fields: ($f | split(","))}')" \
      "${API}/search" | jq '{total, issues: [.issues[] | {key, summary: .fields.summary, status: .fields.status.name, assignee: (.fields.assignee.displayName // null), priority: .fields.priority.name, type: .fields.issuetype.name, labels: .fields.labels, updated: .fields.updated}]}'
    ;;

  my-issues)
    status=""
    while [[ $# -gt 0 ]]; do case "$1" in --status) status="$2"; shift 2 ;; *) shift ;; esac; done
    jql="assignee=currentUser() AND resolution=Unresolved"
    [[ -n "$status" ]] && jql+=" AND status='${status}'"
    jql+=" ORDER BY updated DESC"
    jc -X POST -d "$(jq -n --arg j "$jql" '{jql: $j, maxResults: 30, fields: ["summary","status","priority","issuetype","updated"]}')" \
      "${API}/search" | jq '{total, issues: [.issues[] | {key, summary: .fields.summary, status: .fields.status.name, priority: .fields.priority.name, type: .fields.issuetype.name, updated: .fields.updated}]}'
    ;;

  # === ISSUES ===
  issue)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh issue <KEY>"; exit 1; }
    jc "${API}/issue/$1?expand=renderedFields" | jq '{key, summary: .fields.summary, status: .fields.status.name, type: .fields.issuetype.name, priority: .fields.priority.name, assignee: (.fields.assignee.displayName // null), reporter: .fields.reporter.displayName, labels: .fields.labels, description: (.fields.description // "" | .[0:2000]), created: .fields.created, updated: .fields.updated, components: [.fields.components[]?.name], fix_versions: [.fields.fixVersions[]?.name], url: ("'"${JIRA_URL}"'/browse/" + .key)}'
    ;;

  create)
    [[ $# -lt 3 ]] && { echo "Usage: jira.sh create <PROJECT> <TYPE> <SUMMARY> [--desc TEXT] [--priority P] [--labels L1,L2]"; exit 1; }
    project="$1"; issuetype="$2"; summary="$3"; shift 3
    desc="" ; priority="" ; labels=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --desc) desc="$2"; shift 2 ;; --priority) priority="$2"; shift 2 ;; --labels) labels="$2"; shift 2 ;; *) shift ;; esac
    done
    payload=$(jq -n --arg p "$project" --arg t "$issuetype" --arg s "$summary" \
      '{fields: {project: {key: $p}, issuetype: {name: $t}, summary: $s}}')
    [[ -n "$desc" ]] && payload=$(echo "$payload" | jq --arg d "$desc" '.fields.description = $d')
    [[ -n "$priority" ]] && payload=$(echo "$payload" | jq --arg pr "$priority" '.fields.priority = {name: $pr}')
    [[ -n "$labels" ]] && payload=$(echo "$payload" | jq --arg l "$labels" '.fields.labels = ($l | split(","))')
    jc -X POST -d "$payload" "${API}/issue" | jq '{id, key, url: ("'"${JIRA_URL}"'/browse/" + .key)}'
    ;;

  update)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh update <KEY> [--summary S] [--desc D] [--labels L] [--priority P]"; exit 1; }
    key="$1"; shift
    payload='{"fields":{}}'
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --summary) payload=$(echo "$payload" | jq --arg v "$2" '.fields.summary = $v'); shift 2 ;;
        --desc) payload=$(echo "$payload" | jq --arg v "$2" '.fields.description = $v'); shift 2 ;;
        --labels) payload=$(echo "$payload" | jq --arg v "$2" '.fields.labels = ($v | split(","))'); shift 2 ;;
        --priority) payload=$(echo "$payload" | jq --arg v "$2" '.fields.priority = {name: $v}'); shift 2 ;;
        *) shift ;;
      esac
    done
    jc -X PUT -d "$payload" "${API}/issue/${key}"
    echo "{\"status\": \"updated\", \"key\": \"${key}\", \"url\": \"${JIRA_URL}/browse/${key}\"}"
    ;;

  delete)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh delete <KEY>"; exit 1; }
    jc -X DELETE "${API}/issue/$1"
    echo "{\"status\": \"deleted\", \"key\": \"$1\"}"
    ;;

  assign)
    [[ $# -lt 2 ]] && { echo "Usage: jira.sh assign <KEY> <USERNAME>"; exit 1; }
    jc -X PUT -d "{\"name\":\"$2\"}" "${API}/issue/$1/assignee"
    echo "{\"status\": \"assigned\", \"key\": \"$1\", \"assignee\": \"$2\"}"
    ;;

  transitions)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh transitions <KEY>"; exit 1; }
    jc "${API}/issue/$1/transitions" | jq '[.transitions[] | {id, name, to: .to.name}]'
    ;;

  transition)
    [[ $# -lt 2 ]] && { echo "Usage: jira.sh transition <KEY> <TRANSITION_ID_OR_NAME>"; exit 1; }
    key="$1"; trans="$2"
    # If not numeric, look up by name
    if [[ ! "$trans" =~ ^[0-9]+$ ]]; then
      trans_id=$(jc "${API}/issue/${key}/transitions" | jq -r --arg n "$trans" '[.transitions[] | select(.name == $n)][0].id // empty')
      [[ -z "$trans_id" ]] && { echo "Transition not found: $trans"; exit 1; }
      trans="$trans_id"
    fi
    jc -X POST -d "{\"transition\":{\"id\":\"${trans}\"}}" "${API}/issue/${key}/transitions"
    echo "{\"status\": \"transitioned\", \"key\": \"${key}\", \"transition_id\": \"${trans}\"}"
    ;;

  # === COMMENTS ===
  comments)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh comments <KEY> [--max N]"; exit 1; }
    key="$1"; shift
    max=20
    while [[ $# -gt 0 ]]; do case "$1" in --max) max="$2"; shift 2 ;; *) shift ;; esac; done
    jc "${API}/issue/${key}/comment?maxResults=${max}" | jq '[.comments[] | {id, author: .author.displayName, body: (.body | .[0:500]), created, updated}]'
    ;;

  comment)
    [[ $# -lt 2 ]] && { echo "Usage: jira.sh comment <KEY> <BODY>"; exit 1; }
    jc -X POST -d "$(jq -n --arg b "$2" '{body: $b}')" "${API}/issue/$1/comment" | jq '{id, author: .author.displayName, created}'
    ;;

  # === WORKLOG ===
  worklogs)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh worklogs <KEY>"; exit 1; }
    jc "${API}/issue/$1/worklog" | jq '[.worklogs[] | {id, author: .author.displayName, timeSpent, started, comment: (.comment // "" | .[0:200])}]'
    ;;

  worklog)
    [[ $# -lt 2 ]] && { echo "Usage: jira.sh worklog <KEY> <TIME_SPENT> [--comment TEXT]"; exit 1; }
    key="$1"; time_spent="$2"; shift 2
    comment_text=""
    while [[ $# -gt 0 ]]; do case "$1" in --comment) comment_text="$2"; shift 2 ;; *) shift ;; esac; done
    payload=$(jq -n --arg t "$time_spent" '{timeSpent: $t}')
    [[ -n "$comment_text" ]] && payload=$(echo "$payload" | jq --arg c "$comment_text" '. + {comment: $c}')
    jc -X POST -d "$payload" "${API}/issue/${key}/worklog" | jq '{id, timeSpent, author: .author.displayName}'
    ;;

  # === LINKS ===
  link)
    [[ $# -lt 3 ]] && { echo "Usage: jira.sh link <FROM_KEY> <TO_KEY> <LINK_TYPE>"; exit 1; }
    jc -X POST -d "$(jq -n --arg t "$3" --arg f "$1" --arg to "$2" \
      '{type: {name: $t}, inwardIssue: {key: $f}, outwardIssue: {key: $to}}')" "${API}/issueLink"
    echo "{\"status\": \"linked\", \"from\": \"$1\", \"to\": \"$2\", \"type\": \"$3\"}"
    ;;

  link-types)
    jc "${API}/issueLinkType" | jq '[.issueLinkTypes[] | {id, name, inward, outward}]'
    ;;

  # === PROJECTS ===
  projects)
    max=50
    while [[ $# -gt 0 ]]; do case "$1" in --max) max="$2"; shift 2 ;; *) shift ;; esac; done
    jc "${API}/project?maxResults=${max}" | jq '[.[] | {key, name, projectTypeKey, lead: .lead.displayName}]'
    ;;

  project)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh project <KEY>"; exit 1; }
    jc "${API}/project/$1" | jq '{key, name, description: (.description // "" | .[0:500]), lead: .lead.displayName, projectTypeKey, url: ("'"${JIRA_URL}"'/browse/" + .key)}'
    ;;

  versions)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh versions <PROJECT_KEY>"; exit 1; }
    jc "${API}/project/$1/versions" | jq '[.[] | {id, name, description, released, releaseDate, archived}]'
    ;;

  version-create)
    [[ $# -lt 2 ]] && { echo "Usage: jira.sh version-create <PROJECT_KEY> <NAME> [--desc D] [--release-date YYYY-MM-DD]"; exit 1; }
    project="$1"; name="$2"; shift 2
    desc="" ; release_date=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --desc) desc="$2"; shift 2 ;; --release-date) release_date="$2"; shift 2 ;; *) shift ;; esac
    done
    payload=$(jq -n --arg p "$project" --arg n "$name" '{project: $p, name: $n}')
    [[ -n "$desc" ]] && payload=$(echo "$payload" | jq --arg d "$desc" '. + {description: $d}')
    [[ -n "$release_date" ]] && payload=$(echo "$payload" | jq --arg r "$release_date" '. + {releaseDate: $r}')
    jc -X POST -d "$payload" "${API}/version" | jq '{id, name, releaseDate}'
    ;;

  # === BOARDS & SPRINTS ===
  boards)
    project="" ; type=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --project) project="$2"; shift 2 ;; --type) type="$2"; shift 2 ;; *) shift ;; esac
    done
    url="${AGILE_API}/board?maxResults=50"
    [[ -n "$project" ]] && url+="&projectKeyOrId=${project}"
    [[ -n "$type" ]] && url+="&type=${type}"
    jc "$url" | jq '[.values[] | {id, name, type}]'
    ;;

  board-issues)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh board-issues <BOARD_ID> [--max N]"; exit 1; }
    board_id="$1"; shift
    max=50
    while [[ $# -gt 0 ]]; do case "$1" in --max) max="$2"; shift 2 ;; *) shift ;; esac; done
    jc "${AGILE_API}/board/${board_id}/issue?maxResults=${max}" | jq '{total, issues: [.issues[] | {key, summary: .fields.summary, status: .fields.status.name, type: .fields.issuetype.name}]}'
    ;;

  sprints)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh sprints <BOARD_ID> [--state active|future|closed]"; exit 1; }
    board_id="$1"; shift
    state=""
    while [[ $# -gt 0 ]]; do case "$1" in --state) state="$2"; shift 2 ;; *) shift ;; esac; done
    url="${AGILE_API}/board/${board_id}/sprint?maxResults=50"
    [[ -n "$state" ]] && url+="&state=${state}"
    jc "$url" | jq '[.values[] | {id, name, state, startDate, endDate}]'
    ;;

  sprint-issues)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh sprint-issues <SPRINT_ID> [--max N]"; exit 1; }
    sprint_id="$1"; shift
    max=50
    while [[ $# -gt 0 ]]; do case "$1" in --max) max="$2"; shift 2 ;; *) shift ;; esac; done
    jc "${AGILE_API}/sprint/${sprint_id}/issue?maxResults=${max}" | jq '{total, issues: [.issues[] | {key, summary: .fields.summary, status: .fields.status.name, assignee: (.fields.assignee.displayName // null)}]}'
    ;;

  sprint-create)
    [[ $# -lt 2 ]] && { echo "Usage: jira.sh sprint-create <BOARD_ID> <NAME> [--start DATE] [--end DATE]"; exit 1; }
    board_id="$1"; name="$2"; shift 2
    start="" ; end=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --start) start="$2"; shift 2 ;; --end) end="$2"; shift 2 ;; *) shift ;; esac
    done
    payload=$(jq -n --argjson b "$board_id" --arg n "$name" '{originBoardId: $b, name: $n}')
    [[ -n "$start" ]] && payload=$(echo "$payload" | jq --arg s "$start" '. + {startDate: $s}')
    [[ -n "$end" ]] && payload=$(echo "$payload" | jq --arg e "$end" '. + {endDate: $e}')
    jc -X POST -d "$payload" "${AGILE_API}/sprint" | jq '{id, name, state}'
    ;;

  sprint-update)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh sprint-update <SPRINT_ID> [--name N] [--state active|closed]"; exit 1; }
    sprint_id="$1"; shift
    payload="{}"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --name) payload=$(echo "$payload" | jq --arg v "$2" '. + {name: $v}'); shift 2 ;;
        --state) payload=$(echo "$payload" | jq --arg v "$2" '. + {state: $v}'); shift 2 ;;
        *) shift ;;
      esac
    done
    jc -X POST -d "$payload" "${AGILE_API}/sprint/${sprint_id}" | jq '{id, name, state}'
    ;;

  # === FIELDS ===
  fields)
    search=""
    while [[ $# -gt 0 ]]; do case "$1" in --search) search="$2"; shift 2 ;; *) shift ;; esac; done
    if [[ -n "$search" ]]; then
      jc "${API}/field" | jq --arg s "$search" '[.[] | select(.name | test($s; "i")) | {id, name, custom}]'
    else
      jc "${API}/field" | jq '[.[] | {id, name, custom}] | sort_by(.name)'
    fi
    ;;

  # === USERS ===
  user)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh user <USERNAME>"; exit 1; }
    jc "${API}/user?username=$1" | jq '{key, name, displayName, emailAddress, active}'
    ;;

  user-search)
    [[ $# -lt 1 ]] && { echo "Usage: jira.sh user-search <QUERY>"; exit 1; }
    jc "${API}/user/search?username=$1&maxResults=10" | jq '[.[] | {key, name, displayName, active}]'
    ;;

  *)
    echo "Unknown command: $cmd"
    usage
    ;;
esac
