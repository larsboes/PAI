---
name: Jira
description: "Jira REST API wrapper — search with JQL, create/update/transition issues, log work, manage sprints and boards. Reads JIRA_URL + JIRA_EMAIL + JIRA_TOKEN from env. USE WHEN jira, issues, tickets, sprint, board, JQL, create issue, update issue, log work, transition, kanban, scrum, worklog, project management."
allowed-tools: Bash
---

# Jira

REST API wrapper for Jira Server/Cloud (API v2 + Agile v1). Config from `~/.env`.

## Configuration (`~/.env`)

```env
JIRA_URL=https://your-jira-instance.example.com
JIRA_EMAIL=your.email@example.com
JIRA_TOKEN=your-api-token
```

Generate API token: Jira profile → Security → API tokens (Cloud) or Kantega plugin (Server).
Auth: Basic auth (email:token).

## Usage

```bash
{baseDir}/scripts/jira.sh <command> [args...]
```

## Quick Reference

| Task | Command |
|------|---------|
| My open issues | `jira.sh my-issues` |
| Search with JQL | `jira.sh search "project=MYPROJ AND status='In Progress'"` |
| Get issue | `jira.sh issue PROJ-123` |
| Create task | `jira.sh create PROJ Task "Summary" --desc "Details"` |
| Update issue | `jira.sh update PROJ-123 --summary "New title"` |
| Change status | `jira.sh transition PROJ-123 "In Progress"` |
| List transitions | `jira.sh transitions PROJ-123` |
| Add comment | `jira.sh comment PROJ-123 "Done, ready for review"` |
| Log work | `jira.sh worklog PROJ-123 "2h" --comment "Implementation"` |
| Link issues | `jira.sh link PROJ-123 PROJ-456 "Blocks"` |
| List sprints | `jira.sh sprints 42 --state active` |
| List boards | `jira.sh boards --project MYPROJ` |
| List projects | `jira.sh projects` |

## JQL Examples

```bash
jira.sh search "assignee=currentUser() AND resolution=Unresolved ORDER BY updated DESC"
jira.sh search "project=MYPROJ AND type=Bug AND status != Done"
jira.sh search "updated > -7d AND labels in (backend,api)"
jira.sh search "project=MYPROJ AND type=Bug AND priority in (Critical,Blocker)"
```

## Red Flags

- **401 Unauthorized**: Token expired — regenerate in Jira profile
- **400 on create**: Issue type name is case-sensitive
- **Transition fails**: Run `transitions <KEY>` first to get valid names
