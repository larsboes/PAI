---
name: Azure
description: "Azure CLI wrapper — manage web apps, storage, key vaults, cognitive services, functions, and monitoring. Reads AZ_DEFAULT_RG from env. USE WHEN azure, az CLI, web app, app service, key vault, storage account, function app, cognitive services, azure openai, azure devops, resource group, azure monitoring, AKS."
---

# Azure CLI

Two interfaces:
1. **`az`** — Azure CLI directly (full power, any command)
2. **`azure.sh`** — Compound operations wrapper (multi-step patterns, common tasks)

## Configuration (`~/.env`)

```env
AZ_DEFAULT_RG=your-resource-group
AZ_SUBSCRIPTION=your-subscription-name-or-id
```

Auth via `az login`. Switch subscriptions:
```bash
az account set --subscription "${AZ_SUBSCRIPTION}"
```

Discover your resources:
```bash
az resource list --resource-group $AZ_DEFAULT_RG -o table
```

## azure.sh — Compound Operations

```bash
{baseDir}/scripts/azure.sh <command> [args...]
```

| Task | Command |
|------|---------|
| Account overview | `azure.sh status` |
| List all resources | `azure.sh resources --group <RG>` |
| Web app details | `azure.sh webapp-info <NAME> --group <RG>` |
| View env vars | `azure.sh webapp-env <NAME> --group <RG>` |
| Set env var | `azure.sh webapp-env-set <NAME> KEY val --group <RG>` |
| Restart web app | `azure.sh webapp-restart <NAME> --group <RG>` |
| List secrets | `azure.sh kv-secrets <VAULT>` |
| Get secret value | `azure.sh kv-secret-get <VAULT> <SECRET>` |
| List AI services | `azure.sh ai-list --group <RG>` |
| OpenAI deployments | `azure.sh ai-deployments <NAME> --group <RG>` |
| OpenAI API keys | `azure.sh ai-keys <NAME> --group <RG>` |
| List blobs | `azure.sh blob-list <ACCOUNT> <CONTAINER>` |
| Run KQL query | `azure.sh logs <WORKSPACE> "AppRequests | top 10"` |

## az CLI — Direct Commands

### Resource Management
```bash
az group list -o table
az resource list -g $AZ_DEFAULT_RG -o table
az resource show --ids <RESOURCE_ID> -o json
```

### Web Apps / App Service
```bash
az webapp list -o table
az webapp show -n <NAME> -g <RG> -o json
az webapp config appsettings list -n <NAME> -g <RG> -o table
az webapp config appsettings set -n <NAME> -g <RG> --settings KEY=VALUE
az webapp restart -n <NAME> -g <RG>
az webapp log tail -n <NAME> -g <RG>
az webapp deploy -n <NAME> -g <RG> --src-path app.zip --type zip
```

### Storage
```bash
az storage account list -o table
az storage container list --account-name <ACC> --auth-mode login -o table
az storage blob list --account-name <ACC> -c <CONTAINER> --auth-mode login -o table
az storage blob upload --account-name <ACC> -c <CONTAINER> -f <FILE> -n <NAME> --auth-mode login
az storage blob download --account-name <ACC> -c <CONTAINER> -n <BLOB> -f <OUTPUT> --auth-mode login
```

### Key Vault
```bash
az keyvault list -o table
az keyvault secret list --vault-name <VAULT> -o table
az keyvault secret show --vault-name <VAULT> -n <SECRET>
az keyvault secret set --vault-name <VAULT> -n <SECRET> --value "val"
```

### Azure OpenAI / Cognitive Services
```bash
az cognitiveservices account list -o table
az cognitiveservices account keys list -n <NAME> -g <RG>
az cognitiveservices account deployment list -n <NAME> -g <RG> -o table
# Call OpenAI endpoint:
curl "https://<NAME>.openai.azure.com/openai/deployments/<DEPLOY>/chat/completions?api-version=2024-02-15-preview" \
  -H "api-key: <KEY>" -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'
```

### Monitoring & Logs
```bash
az monitor metrics list --resource <ID> --metric "CpuPercentage" -o table
az monitor log-analytics workspace list -o table
az monitor log-analytics query -w <WORKSPACE_ID> --analytics-query "AppRequests | top 10" -o table
az monitor app-insights query --app <APP_ID> --analytics-query "requests | take 10"
```

### Azure DevOps
```bash
az devops configure --defaults organization=https://dev.azure.com/<ORG> project=<PROJ>
az devops project list -o table
az repos list -o table
az pipelines list -o table
az pipelines run --id <ID> --branch main
az boards work-item show --id <ID>
```

### Identity / RBAC
```bash
az ad user show --id <UPN>
az role assignment list -g <RG> -o table
az ad group list --filter "displayName eq '<NAME>'" -o table
```

## Subscription Switching

```bash
az account list -o table
az account set -s "${AZ_SUBSCRIPTION}"
az account show -o table
```

## Red Flags

- **Token expired**: Run `az login`
- **Wrong subscription**: Verify with `az account show` before destructive operations
- **Missing permissions**: Check role assignments with `az role assignment list`
- **Resource not found**: Verify resource group with `--resource-group` flag
