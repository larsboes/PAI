---
name: ApiPatterns
description: "Direct HTTP API patterns — raw curl/fetch for OpenAI, Anthropic, GitHub, Stripe, Cloudflare, and more. Skip SDKs and wrappers. Use when calling APIs directly, writing curl commands, debugging API responses, or building lightweight integrations without library dependencies."
---

# API Patterns — Skip the SDK

Direct API interaction patterns. No wrappers, no libraries, no overhead.

## Quick Reference: Auth Patterns

| Provider | Auth Header | Token Env Var |
|----------|-------------|---------------|
| OpenAI | `Authorization: Bearer $OPENAI_API_KEY` | `OPENAI_API_KEY` |
| Anthropic | `x-api-key: $ANTHROPIC_API_KEY` | `ANTHROPIC_API_KEY` |
| GitHub | `Authorization: Bearer $GITHUB_TOKEN` | `GITHUB_TOKEN` |
| Stripe | `Authorization: Bearer $STRIPE_SECRET_KEY` | `STRIPE_SECRET_KEY` |
| Cloudflare | `Authorization: Bearer $CF_API_TOKEN` | `CF_API_TOKEN` |
| Google/GCP | `Authorization: Bearer $(gcloud auth print-access-token)` | — |
| AWS | SigV4 (use `--aws-sigv4` in curl) | `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` |

## Core Patterns

### POST JSON (most common)
```bash
curl -s https://api.example.com/v1/resource \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'
```

### Streaming (SSE)
```bash
curl -sN https://api.example.com/v1/stream \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"stream": true}' | while IFS= read -r line; do
  [[ "$line" == data:* ]] && echo "${line#data: }"
done
```

### Pagination (Link header)
```bash
url="https://api.github.com/repos/OWNER/REPO/issues?per_page=100"
while [ -n "$url" ]; do
  response=$(curl -sI -H "Authorization: Bearer $GITHUB_TOKEN" "$url")
  curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$url"
  url=$(echo "$response" | grep -i '^link:' | grep -oP '(?<=<)[^>]+(?=>; rel="next")')
done
```

### File Upload (multipart)
```bash
curl -s https://api.example.com/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@/path/to/file.pdf" \
  -F "purpose=assistants"
```

## Workflow Routing

| Trigger | Workflow |
|---------|----------|
| "call API", "curl pattern", "raw API" | `Workflows/DirectCall.md` |
| "debug API", "API not working" | `Workflows/Debug.md` |
| "paginate", "fetch all pages" | `Workflows/Pagination.md` |
| "stream response", "SSE" | `Workflows/Streaming.md` |

## Deep References

- `references/openai.md` — All OpenAI endpoints with exact curl
- `references/anthropic.md` — Messages API, streaming, tool use
- `references/github.md` — REST + GraphQL patterns
- `references/common-patterns.md` — Retry, backoff, rate limits, error handling
- `references/auth-patterns.md` — OAuth2 flows, JWT, API keys, SigV4

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/api-call.sh` | Generic authenticated API caller with retry |
| `scripts/stream-sse.sh` | SSE stream parser |
| `scripts/paginate.sh` | Auto-paginate any Link-header API |
| `scripts/oauth-token.sh` | OAuth2 client_credentials token fetch |

## Output
- Produces: Working curl commands or shell scripts
- Format: Executable bash
