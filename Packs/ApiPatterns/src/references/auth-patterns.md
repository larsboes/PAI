# Authentication Patterns — OAuth2, JWT, API Keys, SigV4

## OAuth2 Flows

### Client Credentials (Machine-to-Machine)
```bash
# Standard OAuth2 client_credentials
TOKEN=$(curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&scope=read write" \
  | jq -r '.access_token')

# Use token
curl -s https://api.example.com/resource \
  -H "Authorization: Bearer $TOKEN"
```

### Authorization Code (User Login - for scripting)
```bash
# Step 1: Generate auth URL (open in browser)
AUTH_URL="${AUTHORIZE_URL}?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=read+write&state=$(openssl rand -hex 16)"
echo "Open: $AUTH_URL"

# Step 2: After redirect, extract code from URL parameter
read -rp "Paste the code: " CODE

# Step 3: Exchange code for token
curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code&code=${CODE}&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&redirect_uri=${REDIRECT_URI}"
```

### Token Refresh
```bash
curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=refresh_token&refresh_token=${REFRESH_TOKEN}&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}"
```

### PKCE (for public clients)
```bash
# Generate code verifier and challenge
CODE_VERIFIER=$(openssl rand -base64 32 | tr -d '=/+' | cut -c1-43)
CODE_CHALLENGE=$(echo -n "$CODE_VERIFIER" | openssl dgst -sha256 -binary | base64 | tr -d '=' | tr '/+' '_-')

# Auth URL includes challenge
AUTH_URL="${AUTHORIZE_URL}?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&code_challenge=${CODE_CHALLENGE}&code_challenge_method=S256"

# Token exchange includes verifier
curl -s -X POST "$TOKEN_URL" \
  -d "grant_type=authorization_code&code=${CODE}&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&code_verifier=${CODE_VERIFIER}"
```

## JWT

### Decode JWT (no verification)
```bash
# Decode header
echo "$JWT" | cut -d. -f1 | base64 -d 2>/dev/null | jq .

# Decode payload
echo "$JWT" | cut -d. -f2 | base64 -d 2>/dev/null | jq .

# Check expiry
exp=$(echo "$JWT" | cut -d. -f2 | base64 -d 2>/dev/null | jq -r '.exp')
now=$(date +%s)
echo "Expires in: $(( exp - now )) seconds"
```

### Create JWT (for service accounts)
```bash
# Google-style service account JWT
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | base64 | tr -d '=' | tr '/+' '_-')
NOW=$(date +%s)
EXP=$((NOW + 3600))
PAYLOAD=$(echo -n "{\"iss\":\"$SERVICE_ACCOUNT\",\"scope\":\"$SCOPE\",\"aud\":\"$TOKEN_URL\",\"iat\":$NOW,\"exp\":$EXP}" | base64 | tr -d '=' | tr '/+' '_-')
SIGNATURE=$(echo -n "${HEADER}.${PAYLOAD}" | openssl dgst -sha256 -sign private_key.pem | base64 | tr -d '=' | tr '/+' '_-')
JWT="${HEADER}.${PAYLOAD}.${SIGNATURE}"

# Exchange for access token
curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$JWT"
```

## API Key Patterns

| Provider | Method | Header/Param |
|----------|--------|-------------|
| OpenAI | Header | `Authorization: Bearer sk-...` |
| Anthropic | Header | `x-api-key: sk-ant-...` |
| Stripe | Basic Auth | `-u sk_live_...:` (empty password) |
| SendGrid | Header | `Authorization: Bearer SG...` |
| GitHub | Header | `Authorization: Bearer ghp_...` |
| Cloudflare | Header | `Authorization: Bearer ...` |
| AWS | SigV4 | `--aws-sigv4 "aws:amz:REGION:SERVICE"` |
| GCP | Header | `Authorization: Bearer $(gcloud auth print-access-token)` |

## AWS SigV4 (via curl)

```bash
# curl built-in SigV4 (requires curl 7.75+)
curl -s "https://SERVICE.REGION.amazonaws.com/path" \
  --aws-sigv4 "aws:amz:us-east-1:execute-api" \
  --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
  -H "x-amz-security-token: $AWS_SESSION_TOKEN"

# Or use temporary credentials from STS
eval $(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name cli \
  | jq -r '.Credentials | "export AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nexport AWS_SESSION_TOKEN=\(.SessionToken)"')
```

## mTLS (Mutual TLS)

```bash
curl -s https://api.example.com/secure \
  --cert client.pem \
  --key client-key.pem \
  --cacert ca.pem
```

## Token Caching Pattern

```bash
TOKEN_FILE="/tmp/.api-token-$(echo "$CLIENT_ID" | md5sum | cut -c1-8)"

get_token() {
  # Check cache
  if [[ -f "$TOKEN_FILE" ]]; then
    cached=$(cat "$TOKEN_FILE")
    exp=$(echo "$cached" | jq -r '.expires_at')
    if (( exp > $(date +%s) + 60 )); then  # 60s buffer
      echo "$cached" | jq -r '.access_token'
      return
    fi
  fi
  
  # Fetch new token
  response=$(curl -s -X POST "$TOKEN_URL" \
    -d "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET")
  
  token=$(echo "$response" | jq -r '.access_token')
  expires_in=$(echo "$response" | jq -r '.expires_in')
  expires_at=$(( $(date +%s) + expires_in ))
  
  echo "$response" | jq --argjson exp "$expires_at" '. + {expires_at: $exp}' > "$TOKEN_FILE"
  echo "$token"
}
```
