---
name: GitLab
description: "GitLab REST API + glab CLI — projects, issues, merge requests, pipelines, wikis, CI/CD jobs, and code search. Reads GITLAB_URL + GITLAB_TOKEN from env. USE WHEN gitlab, MR, merge request, pipeline, glab, gitlab CI, gitlab API, create MR, review MR, CI/CD, job log, gitlab issue, gitlab project, gitlab wiki, gitlab search."
allowed-tools: Bash
---

# GitLab

Two interfaces:
1. **`gitlab.sh`** — REST API wrapper (any project, bulk ops, raw JSON)
2. **`glab`** — Official GitLab CLI (best inside a cloned repo)

## Configuration (`~/.env`)

```env
GITLAB_URL=https://gitlab.example.com
GITLAB_TOKEN=glpat-xxxxxxxxxxxxxxxxxxxx
```

Generate token: GitLab → Settings → Access Tokens. Scopes: `api`, `read_user`, `read_repository`, `write_repository`.
For `glab`: `glab auth login --hostname your-gitlab.example.com`

## Usage

```bash
{baseDir}/scripts/gitlab.sh <command> [args...]
```

## When to Use Which

| Scenario | Use |
|----------|-----|
| Inside a cloned repo | `glab` (auto-detects remote) |
| Interactive MR review/create | `glab mr` |
| CI/CD pipeline monitoring | `glab ci` |
| Read files without cloning | `gitlab.sh files` |
| Bulk/scripted operations | `gitlab.sh` |
| Need raw JSON | `gitlab.sh` |
| Wiki operations | `gitlab.sh wikis/wiki` |

## gitlab.sh Quick Reference

| Task | Command |
|------|---------|
| List projects | `gitlab.sh projects` |
| Search projects | `gitlab.sh projects --search "name"` |
| Get project | `gitlab.sh project group/project` |
| List branches | `gitlab.sh branches 12345` |
| Read file | `gitlab.sh files 12345 src/main.rb --ref develop` |
| List open MRs | `gitlab.sh mrs 12345` |
| Get MR diff | `gitlab.sh mr-changes 12345 42` |
| Create MR | `gitlab.sh mr-create 12345 feature main "Add feature"` |
| List pipelines | `gitlab.sh pipelines 12345 --ref main` |
| Get job log | `gitlab.sh job-log 12345 67890` |
| Search code | `gitlab.sh search blobs "pattern" --project 12345` |
| List wikis | `gitlab.sh wikis 12345` |

## glab Quick Reference

```bash
glab mr list                    # Open MRs
glab mr create --title "feat"   # Create MR
glab mr view 10                 # View MR details
glab mr diff 10                 # Show diff
glab mr approve 10              # Approve
glab mr merge 10 --squash       # Merge
glab ci list                    # Pipelines
glab ci trace <job-id>          # Stream job log live
glab ci lint .gitlab-ci.yml     # Validate CI config
glab issue list                 # Issues
glab repo clone group/project   # Clone
glab api projects/:id/repository/tree  # Raw API
```

## Red Flags

- **glab defaults to gitlab.com** — verify remote or use `--hostname`
- **Token expired** — `glab auth login --hostname your-instance`
- **403 Forbidden** — token missing `api` scope
- **404 Not Found** — use numeric project ID if path encoding fails
