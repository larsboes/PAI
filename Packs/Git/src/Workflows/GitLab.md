# Git GitLab — glab CLI + REST API Patterns

GitLab workflows via `glab` CLI and REST API. Instance-agnostic — reads from env.

## Environment

```bash
# ~/.env or ~/.secrets (never hardcoded in skill)
export GITLAB_URL="gitlab.com"          # or your self-hosted instance
export GITLAB_TOKEN="glpat-xxxx"        # Personal Access Token
```

Scopes needed: `api`, `read_user`, `read_repository`, `write_repository`

Generate at: `https://$GITLAB_URL/-/user_settings/personal_access_tokens`

**One-time glab auth:**
```bash
glab auth login --hostname $GITLAB_URL
# Or: glab config set host $GITLAB_URL
```

> **Note:** glab defaults to `gitlab.com`. When working on a self-hosted instance, always pass `--hostname $GITLAB_URL` or ensure you're inside a cloned repo (glab auto-detects the remote).

## Merge Requests

```bash
# List MRs
glab mr list
glab mr list --assignee=@me

# Create MR
glab mr create --source-branch feat --target-branch main --title "Add feature"
glab mr create --fill  # auto-fill from branch name + commits

# View & diff
glab mr view 10
glab mr diff 10

# Review actions
glab mr approve 10
glab mr merge 10 --squash --remove-source-branch
glab mr close 10
glab mr checkout 10    # checkout MR branch locally
glab mr note 10 --message "LGTM"
```

## Issues

```bash
glab issue list
glab issue list --assignee=@me
glab issue view 42
glab issue create --title "Bug" --label bug
glab issue close 42
glab issue note 42 --message "Fixed in MR"
```

## CI/CD Pipelines

```bash
glab ci list                          # list recent pipelines
glab ci view                          # interactive pipeline viewer
glab ci status                        # current branch pipeline status
glab ci run --branch main             # trigger pipeline
glab ci retry <pipeline-id>           # retry failed pipeline
glab ci trace <job-id>                # stream job log (live)
glab ci lint .gitlab-ci.yml           # validate CI config
glab ci artifact download <job-id>    # download job artifacts
```

## Repository

```bash
glab repo clone group/project
glab repo view
glab repo archive --format=zip
```

## Releases & Tags

```bash
glab release list
glab release create v1.0.0 --notes "First release"
glab release download v1.0.0
```

## REST API (gitlab.sh pattern)

For bulk/scripted operations or when glab isn't enough:

```bash
BASE="https://$GITLAB_URL/api/v4"
AUTH="PRIVATE-TOKEN: $GITLAB_TOKEN"

# Project info (by path or numeric ID)
curl -s -H "$AUTH" "$BASE/projects/group%2Fproject"

# List branches
curl -s -H "$AUTH" "$BASE/projects/12345/repository/branches"

# Read file from repo
curl -s -H "$AUTH" "$BASE/projects/12345/repository/files/src%2Fmain.rb/raw?ref=main"

# List open MRs
curl -s -H "$AUTH" "$BASE/projects/12345/merge_requests?state=opened"

# Create MR
curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" \
  "$BASE/projects/12345/merge_requests" \
  -d '{"source_branch":"feat","target_branch":"main","title":"Add feature"}'

# Search code across project
curl -s -H "$AUTH" "$BASE/projects/12345/search?scope=blobs&search=def+process"

# List pipelines
curl -s -H "$AUTH" "$BASE/projects/12345/pipelines?ref=main"

# Get job log
curl -s -H "$AUTH" "$BASE/projects/12345/jobs/67890/trace"

# List wiki pages
curl -s -H "$AUTH" "$BASE/projects/12345/wikis"
```

**URL-encode project paths:** `group/sub/project` → `group%2Fsub%2Fproject`

## When to Use Which

| Scenario | Use |
|----------|-----|
| Inside a cloned repo | `glab` (auto-detects remote) |
| Interactive MR review/create | `glab mr` |
| CI/CD monitoring | `glab ci` |
| Read files without cloning | REST API |
| Search across all projects | REST API |
| Bulk/scripted operations | REST API |
| Need raw JSON | REST API |
| Wiki operations | REST API |

## Raw API Escape Hatch

```bash
# Any endpoint via glab
glab api projects/:id/repository/tree
glab api graphql -f query='{ currentUser { name } }'
```

## Gotchas

- `glab` defaults to `gitlab.com` — always verify hostname or set `GITLAB_URL`
- Token expired → regenerate + `glab auth login --hostname $GITLAB_URL`
- 403 Forbidden → token missing `api` scope
- 404 Not Found → try numeric project ID instead of path
