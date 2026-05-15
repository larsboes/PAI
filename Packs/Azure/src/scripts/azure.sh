#!/usr/bin/env bash
# Azure CLI helper — common compound operations
# Wraps `az` CLI for patterns that need multiple calls or complex flags
set -euo pipefail

usage() {
  cat <<'EOF'
Azure Helper — Compound operations for az CLI

USAGE: azure.sh <command> [args...]

OVERVIEW:
  status                                          Account + subscription overview
  resources [--group RG] [--type TYPE]            List resources (filterable)
  cost [--group RG] [--days N]                    Cost summary (last N days, default: 30)

COMPUTE:
  webapp-info <NAME> [--group RG]                 Full web app details + config
  webapp-logs <NAME> [--group RG] [--lines N]     Recent app logs
  webapp-env <NAME> [--group RG]                  List app settings (env vars)
  webapp-env-set <NAME> <KEY> <VALUE> [--group RG] Set app setting
  webapp-restart <NAME> [--group RG]              Restart web app
  function-list [--group RG]                      List function apps
  function-info <NAME> [--group RG]               Function app details

STORAGE:
  storage-list [--group RG]                       List storage accounts
  blob-list <ACCOUNT> <CONTAINER>                 List blobs
  blob-upload <ACCOUNT> <CONTAINER> <FILE>        Upload file
  blob-download <ACCOUNT> <CONTAINER> <BLOB> <OUT> Download blob

KEYVAULT:
  kv-list [--group RG]                            List key vaults
  kv-secrets <VAULT>                              List secrets
  kv-secret-get <VAULT> <NAME>                    Get secret value
  kv-secret-set <VAULT> <NAME> <VALUE>            Set secret

AI / COGNITIVE:
  ai-list [--group RG]                            List cognitive services
  ai-keys <NAME> [--group RG]                     Get API keys
  ai-deployments <NAME> [--group RG]              List OpenAI deployments
  ai-models <NAME> [--group RG]                   List available models

MONITORING:
  alerts [--group RG]                             List active alerts
  metrics <RESOURCE_ID> <METRIC> [--interval PT1H] Get metrics
  logs <WORKSPACE> <QUERY> [--timespan P1D]       Run KQL query

NETWORKING:
  nsg-list [--group RG]                           List network security groups
  nsg-rules <NSG> [--group RG]                    Show NSG rules

IDENTITY:
  ad-user <UPN_OR_ID>                             Get Azure AD user info
  ad-groups                                       List my group memberships
  roles [--group RG]                              List role assignments

DEVOPS:
  devops-projects [--org ORG]                     List DevOps projects
  devops-repos [--org ORG] [--project P]          List repos
  devops-pipelines [--org ORG] [--project P]      List pipelines
EOF
  exit 1
}

# Default resource group
DEFAULT_RG="${AZ_DEFAULT_RG:-}"

get_rg() {
  local rg=""
  while [[ $# -gt 0 ]]; do
    case "$1" in --group) rg="$2"; shift 2 ;; *) shift ;; esac
  done
  if [[ -n "$rg" ]]; then echo "$rg"
  elif [[ -n "$DEFAULT_RG" ]]; then echo "$DEFAULT_RG"
  else echo ""; fi
}

[[ $# -lt 1 ]] && usage
cmd="$1"; shift

case "$cmd" in

  # === OVERVIEW ===
  status)
    echo "=== Account ==="
    az account show -o table
    echo ""
    echo "=== Subscriptions ==="
    az account list -o table
    echo ""
    echo "=== Resource Groups ==="
    az group list -o table
    ;;

  resources)
    rg="" ; rtype=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --group) rg="$2"; shift 2 ;; --type) rtype="$2"; shift 2 ;; *) shift ;; esac
    done
    args=(-o table)
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    [[ -n "$rtype" ]] && args+=(--resource-type "$rtype")
    az resource list "${args[@]}"
    ;;

  cost)
    rg="" ; days=30
    while [[ $# -gt 0 ]]; do
      case "$1" in --group) rg="$2"; shift 2 ;; --days) days="$2"; shift 2 ;; *) shift ;; esac
    done
    from=$(date -u -d "${days} days ago" +%Y-%m-%dT00:00:00Z 2>/dev/null || date -u -v-${days}d +%Y-%m-%dT00:00:00Z)
    to=$(date -u +%Y-%m-%dT23:59:59Z)
    scope="/subscriptions/$(az account show --query id -o tsv)"
    [[ -n "$rg" ]] && scope+="/resourceGroups/${rg}"
    az consumption usage list --start-date "${from}" --end-date "${to}" -o table 2>/dev/null || \
      echo "Cost management requires 'Microsoft.Consumption' provider or 'az cost' extension. Use Azure Portal → Cost Analysis instead."
    ;;

  # === WEB APPS ===
  webapp-info)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh webapp-info <NAME> [--group RG]"; exit 1; }
    name="$1"; shift; rg=$(get_rg "$@")
    args=(--name "$name")
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    echo "=== App Details ==="
    az webapp show "${args[@]}" -o table
    echo ""
    echo "=== Configuration ==="
    az webapp config show "${args[@]}" -o table
    echo ""
    echo "=== Deployment Slots ==="
    az webapp deployment slot list "${args[@]}" -o table 2>/dev/null || echo "(no slots)"
    ;;

  webapp-logs)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh webapp-logs <NAME> [--group RG] [--lines N]"; exit 1; }
    name="$1"; shift; rg="" ; lines=100
    while [[ $# -gt 0 ]]; do
      case "$1" in --group) rg="$2"; shift 2 ;; --lines) lines="$2"; shift 2 ;; *) shift ;; esac
    done
    args=(--name "$name")
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az webapp log tail "${args[@]}" 2>/dev/null &
    pid=$!
    sleep 5 && kill $pid 2>/dev/null
    # Fallback: download log
    echo "(For persistent logs: az webapp log download ${args[*]} --log-file app.zip)"
    ;;

  webapp-env)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh webapp-env <NAME> [--group RG]"; exit 1; }
    name="$1"; shift; rg=$(get_rg "$@")
    args=(--name "$name")
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az webapp config appsettings list "${args[@]}" -o table
    ;;

  webapp-env-set)
    [[ $# -lt 3 ]] && { echo "Usage: azure.sh webapp-env-set <NAME> <KEY> <VALUE> [--group RG]"; exit 1; }
    name="$1"; key="$2"; val="$3"; shift 3; rg=$(get_rg "$@")
    args=(--name "$name" --settings "${key}=${val}")
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az webapp config appsettings set "${args[@]}" -o table
    ;;

  webapp-restart)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh webapp-restart <NAME> [--group RG]"; exit 1; }
    name="$1"; shift; rg=$(get_rg "$@")
    args=(--name "$name")
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az webapp restart "${args[@]}"
    echo "Restarted: $name"
    ;;

  function-list)
    rg=$(get_rg "$@")
    args=(-o table)
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az functionapp list "${args[@]}"
    ;;

  function-info)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh function-info <NAME> [--group RG]"; exit 1; }
    name="$1"; shift; rg=$(get_rg "$@")
    args=(--name "$name")
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az functionapp show "${args[@]}" -o table
    echo ""
    az functionapp config appsettings list "${args[@]}" -o table
    ;;

  # === STORAGE ===
  storage-list)
    rg=$(get_rg "$@")
    args=(-o table)
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az storage account list "${args[@]}"
    ;;

  blob-list)
    [[ $# -lt 2 ]] && { echo "Usage: azure.sh blob-list <ACCOUNT> <CONTAINER>"; exit 1; }
    az storage blob list --account-name "$1" --container-name "$2" --auth-mode login -o table
    ;;

  blob-upload)
    [[ $# -lt 3 ]] && { echo "Usage: azure.sh blob-upload <ACCOUNT> <CONTAINER> <FILE>"; exit 1; }
    az storage blob upload --account-name "$1" --container-name "$2" --file "$3" --name "$(basename "$3")" --auth-mode login --overwrite -o table
    ;;

  blob-download)
    [[ $# -lt 4 ]] && { echo "Usage: azure.sh blob-download <ACCOUNT> <CONTAINER> <BLOB> <OUTPUT>"; exit 1; }
    az storage blob download --account-name "$1" --container-name "$2" --name "$3" --file "$4" --auth-mode login -o table
    ;;

  # === KEYVAULT ===
  kv-list)
    rg=$(get_rg "$@")
    args=(-o table)
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az keyvault list "${args[@]}"
    ;;

  kv-secrets)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh kv-secrets <VAULT>"; exit 1; }
    az keyvault secret list --vault-name "$1" -o table
    ;;

  kv-secret-get)
    [[ $# -lt 2 ]] && { echo "Usage: azure.sh kv-secret-get <VAULT> <NAME>"; exit 1; }
    az keyvault secret show --vault-name "$1" --name "$2" --query '{name: name, value: value, created: attributes.created, updated: attributes.updated, enabled: attributes.enabled}' -o table
    ;;

  kv-secret-set)
    [[ $# -lt 3 ]] && { echo "Usage: azure.sh kv-secret-set <VAULT> <NAME> <VALUE>"; exit 1; }
    az keyvault secret set --vault-name "$1" --name "$2" --value "$3" -o table
    ;;

  # === AI / COGNITIVE ===
  ai-list)
    rg=$(get_rg "$@")
    args=(-o table)
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az cognitiveservices account list "${args[@]}"
    ;;

  ai-keys)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh ai-keys <NAME> [--group RG]"; exit 1; }
    name="$1"; shift; rg=$(get_rg "$@")
    args=(--name "$name")
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az cognitiveservices account keys list "${args[@]}" -o table
    ;;

  ai-deployments)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh ai-deployments <NAME> [--group RG]"; exit 1; }
    name="$1"; shift; rg=$(get_rg "$@")
    args=(--name "$name")
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az cognitiveservices account deployment list "${args[@]}" -o table
    ;;

  ai-models)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh ai-models <NAME> [--group RG]"; exit 1; }
    name="$1"; shift; rg=$(get_rg "$@")
    args=(--name "$name")
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az cognitiveservices account list-models "${args[@]}" -o table 2>/dev/null || \
      az cognitiveservices model list --location "$(az cognitiveservices account show "${args[@]}" --query location -o tsv)" -o table
    ;;

  # === MONITORING ===
  alerts)
    rg=$(get_rg "$@")
    args=(-o table)
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az monitor alert list "${args[@]}" 2>/dev/null || \
      az monitor metrics alert list "${args[@]}" 2>/dev/null || \
      echo "No alerts configured or insufficient permissions."
    ;;

  metrics)
    [[ $# -lt 2 ]] && { echo "Usage: azure.sh metrics <RESOURCE_ID> <METRIC> [--interval PT1H]"; exit 1; }
    rid="$1"; metric="$2"; shift 2
    interval="PT1H"
    while [[ $# -gt 0 ]]; do case "$1" in --interval) interval="$2"; shift 2 ;; *) shift ;; esac; done
    az monitor metrics list --resource "$rid" --metric "$metric" --interval "$interval" -o table
    ;;

  logs)
    [[ $# -lt 2 ]] && { echo "Usage: azure.sh logs <WORKSPACE_NAME> <KQL_QUERY> [--timespan P1D]"; exit 1; }
    workspace="$1"; query="$2"; shift 2
    timespan="P1D"
    while [[ $# -gt 0 ]]; do case "$1" in --timespan) timespan="$2"; shift 2 ;; *) shift ;; esac; done
    workspace_id=$(az monitor log-analytics workspace show --workspace-name "$workspace" --query customerId -o tsv 2>/dev/null)
    if [[ -n "$workspace_id" ]]; then
      az monitor log-analytics query --workspace "$workspace_id" --analytics-query "$query" --timespan "$timespan" -o table
    else
      echo "Workspace '$workspace' not found. List workspaces: az monitor log-analytics workspace list -o table"
    fi
    ;;

  # === NETWORKING ===
  nsg-list)
    rg=$(get_rg "$@")
    args=(-o table)
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az network nsg list "${args[@]}"
    ;;

  nsg-rules)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh nsg-rules <NSG_NAME> [--group RG]"; exit 1; }
    name="$1"; shift; rg=$(get_rg "$@")
    args=(--nsg-name "$name")
    [[ -n "$rg" ]] && args+=(--resource-group "$rg")
    az network nsg rule list "${args[@]}" -o table
    ;;

  # === IDENTITY ===
  ad-user)
    [[ $# -lt 1 ]] && { echo "Usage: azure.sh ad-user <UPN_OR_ID>"; exit 1; }
    az ad user show --id "$1" -o table
    ;;

  ad-groups)
    az ad signed-in-user list-owned-objects --type Group -o table 2>/dev/null || \
      echo "Use: az ad user get-member-objects --id <your-upn>"
    ;;

  roles)
    rg=$(get_rg "$@")
    if [[ -n "$rg" ]]; then
      az role assignment list --resource-group "$rg" -o table
    else
      az role assignment list --all -o table 2>/dev/null | head -50
    fi
    ;;

  # === DEVOPS ===
  devops-projects)
    org=""
    while [[ $# -gt 0 ]]; do case "$1" in --org) org="$2"; shift 2 ;; *) shift ;; esac; done
    args=(list -o table)
    [[ -n "$org" ]] && args+=(--organization "$org")
    az devops project "${args[@]}"
    ;;

  devops-repos)
    org="" ; project=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --org) org="$2"; shift 2 ;; --project) project="$2"; shift 2 ;; *) shift ;; esac
    done
    args=(list -o table)
    [[ -n "$org" ]] && args+=(--organization "$org")
    [[ -n "$project" ]] && args+=(--project "$project")
    az repos "${args[@]}"
    ;;

  devops-pipelines)
    org="" ; project=""
    while [[ $# -gt 0 ]]; do
      case "$1" in --org) org="$2"; shift 2 ;; --project) project="$2"; shift 2 ;; *) shift ;; esac
    done
    args=(list -o table)
    [[ -n "$org" ]] && args+=(--organization "$org")
    [[ -n "$project" ]] && args+=(--project "$project")
    az pipelines "${args[@]}"
    ;;

  *)
    echo "Unknown command: $cmd"
    usage
    ;;
esac
