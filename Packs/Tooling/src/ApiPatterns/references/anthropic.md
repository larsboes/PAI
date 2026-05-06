# Anthropic API — Direct Patterns

## Base URL
```
https://api.anthropic.com/v1
```

## Auth
```bash
-H "x-api-key: $ANTHROPIC_API_KEY"
-H "anthropic-version: 2023-06-01"
-H "Content-Type: application/json"
```

## Messages API

### Basic
```bash
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 4096,
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

### With System Prompt
```bash
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 4096,
    "system": "You are a helpful coding assistant.",
    "messages": [{"role": "user", "content": "Write fizzbuzz in Rust"}]
  }'
```

### Streaming
```bash
curl -sN https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 4096,
    "stream": true,
    "messages": [{"role": "user", "content": "Hello"}]
  }' | grep '^data: ' | sed 's/^data: //' | while read -r event; do
    type=$(echo "$event" | jq -r '.type // empty')
    case "$type" in
      content_block_delta)
        echo -n "$(echo "$event" | jq -r '.delta.text // empty')"
        ;;
      message_stop)
        echo ""
        break
        ;;
    esac
  done
```

### Tool Use
```bash
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 4096,
    "tools": [{
      "name": "get_weather",
      "description": "Get current weather for a location",
      "input_schema": {
        "type": "object",
        "properties": {
          "location": {"type": "string", "description": "City name"}
        },
        "required": ["location"]
      }
    }],
    "messages": [{"role": "user", "content": "Weather in Berlin?"}]
  }'
```

### Tool Result (completing the loop)
```bash
# After receiving tool_use response, send back tool_result:
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 4096,
    "messages": [
      {"role": "user", "content": "Weather in Berlin?"},
      {"role": "assistant", "content": [
        {"type": "tool_use", "id": "toolu_123", "name": "get_weather", "input": {"location": "Berlin"}}
      ]},
      {"role": "user", "content": [
        {"type": "tool_result", "tool_use_id": "toolu_123", "content": "15°C, partly cloudy"}
      ]}
    ]
  }'
```

### Extended Thinking
```bash
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 16000,
    "thinking": {
      "type": "enabled",
      "budget_tokens": 10000
    },
    "messages": [{"role": "user", "content": "Solve this step by step..."}]
  }'
```

### Vision (Image Input)
```bash
# Base64 encoded image
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"claude-sonnet-4-20250514\",
    \"max_tokens\": 4096,
    \"messages\": [{
      \"role\": \"user\",
      \"content\": [
        {\"type\": \"image\", \"source\": {\"type\": \"base64\", \"media_type\": \"image/png\", \"data\": \"$(base64 -w0 image.png)\"}},
        {\"type\": \"text\", \"text\": \"What's in this image?\"}
      ]
    }]
  }"

# URL-referenced image
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 4096,
    "messages": [{
      "role": "user",
      "content": [
        {"type": "image", "source": {"type": "url", "url": "https://example.com/image.png"}},
        {"type": "text", "text": "Describe this"}
      ]
    }]
  }'
```

### Batch API
```bash
# Create batch
curl -s https://api.anthropic.com/v1/messages/batches \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "requests": [
      {
        "custom_id": "req-1",
        "params": {
          "model": "claude-sonnet-4-20250514",
          "max_tokens": 1024,
          "messages": [{"role": "user", "content": "Summarize: ..."}]
        }
      }
    ]
  }'

# Check batch status
curl -s https://api.anthropic.com/v1/messages/batches/BATCH_ID \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01"
```

## Response Extraction

```bash
# Extract text content
| jq -r '.content[] | select(.type=="text") | .text'

# Extract tool use blocks
| jq '.content[] | select(.type=="tool_use")'

# Extract thinking blocks
| jq -r '.content[] | select(.type=="thinking") | .thinking'

# Check stop reason
| jq -r '.stop_reason'

# Token usage
| jq '.usage'
```

## Models (as of 2025)

| Model | Context | Best For |
|-------|---------|----------|
| `claude-sonnet-4-20250514` | 200K | General purpose, coding |
| `claude-opus-4-20250514` | 200K | Complex reasoning |
| `claude-haiku-3-5-20241022` | 200K | Fast, cheap |

## Rate Limit Headers

```
anthropic-ratelimit-requests-limit
anthropic-ratelimit-requests-remaining
anthropic-ratelimit-requests-reset
anthropic-ratelimit-tokens-limit
anthropic-ratelimit-tokens-remaining
anthropic-ratelimit-tokens-reset
```
