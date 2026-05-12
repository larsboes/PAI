# GitHub API — Direct Patterns

## Base URLs
```
REST: https://api.github.com
GraphQL: https://api.github.com/graphql
```

## Auth
```bash
-H "Authorization: Bearer $GITHUB_TOKEN"
-H "Accept: application/vnd.github+json"
-H "X-GitHub-Api-Version: 2022-11-28"
```

## Repositories

### Get repo info
```bash
curl -s https://api.github.com/repos/OWNER/REPO \
  -H "Authorization: Bearer $GITHUB_TOKEN" | jq '{name, stars: .stargazers_count, forks: .forks_count}'
```

### List repo contents
```bash
curl -s https://api.github.com/repos/OWNER/REPO/contents/PATH \
  -H "Authorization: Bearer $GITHUB_TOKEN" | jq '.[].name'
```

### Get file content (decoded)
```bash
curl -s https://api.github.com/repos/OWNER/REPO/contents/README.md \
  -H "Authorization: Bearer $GITHUB_TOKEN" | jq -r '.content' | base64 -d
```

## Issues & PRs

### List issues
```bash
curl -s "https://api.github.com/repos/OWNER/REPO/issues?state=open&per_page=100" \
  -H "Authorization: Bearer $GITHUB_TOKEN" | jq '.[] | {number, title, labels: [.labels[].name]}'
```

### Create issue
```bash
curl -s https://api.github.com/repos/OWNER/REPO/issues \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Bug: something broken",
    "body": "Description here",
    "labels": ["bug"],
    "assignees": ["username"]
  }'
```

### List PRs
```bash
curl -s "https://api.github.com/repos/OWNER/REPO/pulls?state=open" \
  -H "Authorization: Bearer $GITHUB_TOKEN" | jq '.[] | {number, title, user: .user.login}'
```

### Get PR diff
```bash
curl -s https://api.github.com/repos/OWNER/REPO/pulls/PR_NUMBER \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.diff"
```

### Create PR
```bash
curl -s https://api.github.com/repos/OWNER/REPO/pulls \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "feat: add new feature",
    "body": "Description",
    "head": "feature-branch",
    "base": "main"
  }'
```

## Actions / Workflows

### Trigger workflow dispatch
```bash
curl -s -X POST https://api.github.com/repos/OWNER/REPO/actions/workflows/WORKFLOW_ID/dispatches \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ref": "main", "inputs": {"environment": "staging"}}'
```

### List workflow runs
```bash
curl -s "https://api.github.com/repos/OWNER/REPO/actions/runs?per_page=5" \
  -H "Authorization: Bearer $GITHUB_TOKEN" | jq '.workflow_runs[] | {id, status, conclusion, name}'
```

### Download workflow logs
```bash
curl -sL https://api.github.com/repos/OWNER/REPO/actions/runs/RUN_ID/logs \
  -H "Authorization: Bearer $GITHUB_TOKEN" -o logs.zip
```

## Releases

### Create release
```bash
curl -s https://api.github.com/repos/OWNER/REPO/releases \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tag_name": "v1.0.0",
    "name": "Release 1.0.0",
    "body": "Changelog here",
    "draft": false,
    "prerelease": false
  }'
```

### Upload release asset
```bash
UPLOAD_URL="https://uploads.github.com/repos/OWNER/REPO/releases/RELEASE_ID/assets?name=binary.tar.gz"
curl -s "$UPLOAD_URL" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/gzip" \
  --data-binary @binary.tar.gz
```

## GraphQL

### Basic query
```bash
curl -s https://api.github.com/graphql \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { viewer { login repositories(first: 5, orderBy: {field: UPDATED_AT, direction: DESC}) { nodes { name stargazerCount } } } }"
  }' | jq '.data'
```

### Search with GraphQL
```bash
curl -s https://api.github.com/graphql \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query($q: String!) { search(query: $q, type: REPOSITORY, first: 10) { nodes { ... on Repository { nameWithOwner stargazerCount description } } } }",
    "variables": {"q": "language:rust stars:>1000"}
  }' | jq '.data.search.nodes[]'
```

## Search

### Code search
```bash
curl -s "https://api.github.com/search/code?q=filename:SKILL.md+org:anthropics" \
  -H "Authorization: Bearer $GITHUB_TOKEN" | jq '.items[] | {path: .path, repo: .repository.full_name}'
```

### Repo search
```bash
curl -s "https://api.github.com/search/repositories?q=topic:mcp+stars:>100&sort=stars" \
  -H "Authorization: Bearer $GITHUB_TOKEN" | jq '.items[] | {name: .full_name, stars: .stargazers_count}'
```

## Pagination

GitHub uses Link headers. All list endpoints support `?per_page=100&page=N`.

```bash
# Follow pagination automatically
url="https://api.github.com/repos/OWNER/REPO/issues?per_page=100&state=all"
while [ -n "$url" ]; do
  headers=$(mktemp)
  curl -s -D "$headers" -H "Authorization: Bearer $GITHUB_TOKEN" "$url"
  url=$(grep -i '^link:' "$headers" | grep -oP '(?<=<)[^>]+(?=>; rel="next")' || true)
  rm "$headers"
done
```

## Webhooks

### Create webhook
```bash
curl -s https://api.github.com/repos/OWNER/REPO/hooks \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "web",
    "active": true,
    "events": ["push", "pull_request"],
    "config": {
      "url": "https://your-server.com/webhook",
      "content_type": "json",
      "secret": "your-webhook-secret"
    }
  }'
```
