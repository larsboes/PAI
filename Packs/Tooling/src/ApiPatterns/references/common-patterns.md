# Common API Patterns — Error Handling, Retry, Rate Limits

## Exponential Backoff with Jitter

```bash
retry_with_backoff() {
  local max_retries="${1:-5}"
  local base_delay="${2:-1}"
  shift 2
  
  for ((i=1; i<=max_retries; i++)); do
    if "$@"; then
      return 0
    fi
    if ((i < max_retries)); then
      # Exponential backoff with jitter
      delay=$(awk "BEGIN {printf \"%.1f\", $base_delay * 2^($i-1) * (0.5 + 0.5*rand())}")
      echo "Attempt $i failed, retrying in ${delay}s..." >&2
      sleep "$delay"
    fi
  done
  return 1
}

# Usage:
retry_with_backoff 3 2 curl -sf https://api.example.com/resource
```

## Rate Limit Handling

### Sleep Until Reset
```bash
call_with_rate_limit() {
  local response headers
  headers=$(mktemp)
  response=$(curl -s -D "$headers" "$@")
  
  remaining=$(grep -i 'x-ratelimit-remaining' "$headers" | tr -d '\r' | awk '{print $2}')
  reset=$(grep -i 'x-ratelimit-reset' "$headers" | tr -d '\r' | awk '{print $2}')
  
  if [[ "${remaining:-1}" == "0" ]]; then
    wait_time=$(( reset - $(date +%s) ))
    ((wait_time > 0)) && sleep "$wait_time"
  fi
  
  rm -f "$headers"
  echo "$response"
}
```

### Token Bucket (for batch operations)
```bash
# Simple token bucket — call between requests
rate_limit() {
  local requests_per_second="${1:-10}"
  local interval=$(awk "BEGIN {printf \"%.3f\", 1.0/$requests_per_second}")
  sleep "$interval"
}
```

## Error Response Patterns

### Standard error extraction
```bash
response=$(curl -s -w "\n%{http_code}" "$@")
http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

case "$http_code" in
  2*) echo "$body" ;;
  401) echo "AUTH_ERROR: Check token/key" >&2; exit 1 ;;
  403) echo "FORBIDDEN: Insufficient permissions" >&2; exit 1 ;;
  404) echo "NOT_FOUND: Resource doesn't exist" >&2; exit 1 ;;
  422) echo "VALIDATION: $(echo "$body" | jq -r '.message // .error // .')" >&2; exit 1 ;;
  429) echo "RATE_LIMITED: Back off" >&2; exit 2 ;;  # exit 2 = retryable
  5*) echo "SERVER_ERROR: $http_code" >&2; exit 2 ;;
  *) echo "UNKNOWN: $http_code $body" >&2; exit 1 ;;
esac
```

## Request Debugging

### Verbose mode (see full request/response)
```bash
curl -v https://api.example.com/resource 2>&1 | grep -E '^[<>*]'
```

### Time breakdown
```bash
curl -s -o /dev/null -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTLS: %{time_appconnect}s\nFirst byte: %{time_starttransfer}s\nTotal: %{time_total}s\n" https://api.example.com
```

### Save request/response for debugging
```bash
curl -s --trace-ascii /tmp/api-trace.txt https://api.example.com/resource
```

## Idempotency

### Idempotency keys (Stripe pattern)
```bash
curl -s https://api.stripe.com/v1/charges \
  -H "Authorization: Bearer $STRIPE_SECRET_KEY" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d amount=2000 \
  -d currency=usd \
  -d source=tok_visa
```

## Parallel Requests

### Using xargs
```bash
cat urls.txt | xargs -P 10 -I {} curl -s -H "Authorization: Bearer $TOKEN" {}
```

### Using GNU parallel
```bash
parallel -j 10 curl -s -H '"Authorization: Bearer $TOKEN"' ::: $(cat urls.txt)
```

### Using background jobs
```bash
pids=()
for url in "${urls[@]}"; do
  curl -s -H "Authorization: Bearer $TOKEN" "$url" > "/tmp/response_${#pids[@]}.json" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid"; done
```

## Content Types

| Scenario | Content-Type |
|----------|-------------|
| JSON body | `application/json` |
| Form data | `application/x-www-form-urlencoded` |
| File upload | `multipart/form-data` (curl sets automatically with -F) |
| Binary download | `application/octet-stream` |
| GraphQL | `application/json` |
| SSE stream | `text/event-stream` (Accept header) |

## Timeouts

```bash
# Connect timeout (TCP handshake)
curl --connect-timeout 5

# Total operation timeout
curl --max-time 30

# Both (recommended for production)
curl --connect-timeout 5 --max-time 30
```
