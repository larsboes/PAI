# OpenAI API — Direct Patterns

## Base URL
```
https://api.openai.com/v1
```

## Auth
```bash
-H "Authorization: Bearer $OPENAI_API_KEY"
-H "OpenAI-Organization: $OPENAI_ORG_ID"  # optional
```

## Chat Completions

### Basic
```bash
curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

### With Streaming
```bash
curl -sN https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": true
  }' | grep '^data: ' | sed 's/^data: //' | while read -r chunk; do
    [[ "$chunk" == "[DONE]" ]] && break
    echo "$chunk" | jq -r '.choices[0].delta.content // empty'
  done
```

### Structured Output (JSON mode)
```bash
curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "List 3 colors"}],
    "response_format": {"type": "json_object"}
  }'
```

### Function Calling / Tool Use
```bash
curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "What is the weather in Berlin?"}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get weather for a location",
        "parameters": {
          "type": "object",
          "properties": {
            "location": {"type": "string"}
          },
          "required": ["location"]
        }
      }
    }]
  }'
```

## Responses API (new, 2025+)

```bash
curl -s https://api.openai.com/v1/responses \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "input": "Explain quantum computing",
    "instructions": "Be concise"
  }'
```

## Embeddings

```bash
curl -s https://api.openai.com/v1/embeddings \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "text-embedding-3-small",
    "input": "Your text here"
  }' | jq '.data[0].embedding[:5]'  # first 5 dims for preview
```

## Images (DALL-E)

```bash
curl -s https://api.openai.com/v1/images/generations \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "dall-e-3",
    "prompt": "A cat in space",
    "size": "1024x1024",
    "n": 1
  }' | jq -r '.data[0].url'
```

## Audio (Whisper + TTS)

### Transcription
```bash
curl -s https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F "file=@audio.mp3" \
  -F "model=whisper-1" \
  -F "response_format=verbose_json" \
  -F "timestamp_granularities[]=word"
```

### TTS
```bash
curl -s https://api.openai.com/v1/audio/speech \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tts-1-hd",
    "input": "Hello world",
    "voice": "alloy"
  }' --output speech.mp3
```

## Files & Assistants

### Upload file
```bash
curl -s https://api.openai.com/v1/files \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F "purpose=assistants" \
  -F "file=@document.pdf"
```

## Common Response Extraction

```bash
# Extract just the text content
| jq -r '.choices[0].message.content'

# Extract tool calls
| jq '.choices[0].message.tool_calls'

# Extract usage/tokens
| jq '.usage'

# Extract finish reason
| jq -r '.choices[0].finish_reason'
```

## Rate Limits & Headers

Response headers to check:
```
x-ratelimit-limit-requests
x-ratelimit-limit-tokens
x-ratelimit-remaining-requests
x-ratelimit-remaining-tokens
x-ratelimit-reset-requests
x-ratelimit-reset-tokens
```

```bash
# Check rate limits without consuming tokens
curl -sI https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-4o","messages":[{"role":"user","content":"hi"}]}' \
  | grep -i 'x-ratelimit'
```
