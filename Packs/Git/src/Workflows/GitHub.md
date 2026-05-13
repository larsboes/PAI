# Git GitHub — gh CLI Patterns

GitHub workflows via `gh` CLI. Direct commands + scripts.

## Environment

```bash
# gh authenticates via stored token — run once:
gh auth login
# Or via env var:
export GITHUB_TOKEN="ghp_xxxx"
```

## Pull Requests

```bash
# Create PR (interactive)
gh pr create

# Create PR (one-liner)
gh pr create --title "feat: add auth" --body "Implements OAuth2" --base main

# Create draft PR
gh pr create --draft --title "wip: refactor"

# Create PR from template
gh pr create --template .github/pull_request_template.md

# View PR
gh pr view 123

# Checkout PR locally
gh pr checkout 123

# Review PR
gh pr review 123 --approve --body "LGTM"
gh pr review 123 --request-changes --body "Fix the typo"
gh pr review 123 --comment --body "Question about line 42"

# Merge PR
gh pr merge 123 --squash --delete-branch
gh pr merge 123 --rebase
gh pr merge 123 --merge

# List PRs
gh pr list
gh pr list --author "@me"
gh pr list --label "bug" --state open
```

## CI / Actions

```bash
# View workflow runs
gh run list
gh run list --workflow ci.yml --branch main

# View specific run (with logs)
gh run view <run-id>
gh run view <run-id> --log-failed

# Re-run failed jobs
gh run rerun <run-id> --failed

# Trigger workflow manually
gh workflow run deploy.yml --ref main
gh workflow run deploy.yml --ref main -f environment=prod

# Watch run in real time
gh run watch <run-id>

# Download artifacts
gh run download <run-id>
```

## Issues

```bash
# List issues
gh issue list
gh issue list --label "bug" --state open
gh issue list --search "authentication error"
gh issue list --assignee "@me"

# Create issue
gh issue create --title "Bug: login fails" --label bug --body "Steps to reproduce..."

# View & close
gh issue view 456
gh issue close 456 --comment "Fixed in #123"
gh issue comment 456 --body "Looking into this"
```

## Releases

```bash
# Create release
gh release create v1.0.0 --generate-notes
gh release create v1.0.0 --notes "Major release" --title "v1.0.0"
gh release create v2.0.0-rc1 --prerelease --draft

# Attach assets
gh release upload v1.0.0 ./dist/app.zip

# List releases
gh release list

# Download release
gh release download v1.0.0
```

## Repo Management

```bash
# Clone
gh repo clone owner/repo
gh repo clone owner/repo -- --depth=1

# Fork
gh repo fork owner/repo --clone

# View repo in browser
gh repo view --web

# Create repo
gh repo create my-project --public --clone
gh repo create my-project --private --add-readme

# List repos
gh repo list owner --limit 50
```

## Useful jq Recipes

```bash
# PRs with key fields
gh pr list --json number,title,author,headRefName \
  --jq '.[] | "#\(.number): \(.title) by @\(.author.login)"'

# Failed workflow runs
gh run list --json conclusion,displayTitle,databaseId \
  --jq '.[] | select(.conclusion == "failure")'

# Review decisions on PR
gh api repos/{owner}/{repo}/pulls/123/reviews \
  --jq '.[] | "@\(.user.login): \(.state)"'

# Count issues by label
gh issue list --json labels \
  --jq '[.[].labels[].name] | group_by(.) | map({label: .[0], count: length}) | sort_by(-.count)'
```

## Raw API

```bash
# Any REST endpoint
gh api repos/owner/repo/pulls/55/files --jq '.[] | "\(.status): \(.filename)"'
gh api rate_limit --jq '.rate | "\(.remaining)/\(.limit) remaining"'

# GraphQL
gh api graphql -f query='{ viewer { login } }'
```

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/pr-create.sh` | PR creation with options |
| `scripts/pr-review.sh` | PR review helpers |
| `scripts/release.sh` | Release management |
| `scripts/ci-status.sh` | CI status overview |
| `scripts/ci-logs.sh` | Fetch CI logs |
