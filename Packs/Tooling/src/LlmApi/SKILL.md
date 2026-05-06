---
name: LlmApi
description: "Raw LLM API patterns — call OpenAI, Anthropic, Google Gemini, and local models directly via curl/fetch. Streaming, tool use, structured output, batch processing. No SDKs. Use when calling LLM APIs directly, building integrations, testing models, or orchestrating multi-model pipelines."
---

# LLM API — Raw Model Interaction

Call any LLM directly. No langchain, no SDKs, no abstraction layers.

## Quick Reference: One-Liner per Provider

```bash
# Anthropic Claude
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" -H "anthropic-version: 2023-06-01" -H "Content-Type: application/json" \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":1024,"messages":[{"role":"user","content":"Hello"}]}' \
  | jq -r '.content[0].text'

# OpenAI GPT
curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"gpt-4o","messages":[{"role":"user","content":"Hello"}]}' \
  | jq -r '.choices[0].message.content'

# Google Gemini
curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}' \
  | jq -r '.candidates[0].content.parts[0].text'

# Ollama (local)
curl -s http://localhost:11434/api/chat \
  -d '{"model":"llama3","messages":[{"role":"user","content":"Hello"}],"stream":false}' \
  | jq -r '.message.content'

# OpenRouter (any model via one API)
curl -s https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"anthropic/claude-sonnet-4-20250514","messages":[{"role":"user","content":"Hello"}]}' \
  | jq -r '.choices[0].message.content'
```

## Core Patterns

### Multi-Model Comparison (same prompt, N models)
```bash
PROMPT='Explain monads in one sentence.'
MODELS=("gpt-4o" "claude-sonnet-4-20250514" "gemini-2.5-flash")

for model in "${MODELS[@]}"; do
  echo "=== $model ==="
  # Route based on model prefix
  case "$model" in
    gpt-*|o1-*) scripts/call-openai.sh "$model" "$PROMPT" ;;
    claude-*)   scripts/call-anthropic.sh "$model" "$PROMPT" ;;
    gemini-*)   scripts/call-gemini.sh "$model" "$PROMPT" ;;
  esac
  echo ""
done
```

### Structured Output (JSON guaranteed)
```bash
# OpenAI — json_schema mode
curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role":"user","content":"List 3 programming languages with year created"}],
    "response_format": {
      "type": "json_schema",
      "json_schema": {
        "name": "languages",
        "schema": {
          "type": "object",
          "properties": {
            "languages": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "name": {"type": "string"},
                  "year": {"type": "integer"}
                },
                "required": ["name", "year"]
              }
            }
          },
          "required": ["languages"]
        }
      }
    }
  }'

# Anthropic — use tool_use trick for guaranteed JSON
curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" -H "anthropic-version: 2023-06-01" -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 1024,
    "tools": [{"name":"output","description":"Output structured data","input_schema":{"type":"object","properties":{"languages":{"type":"array","items":{"type":"object","properties":{"name":{"type":"string"},"year":{"type":"integer"}},"required":["name","year"]}}},"required":["languages"]}}],
    "tool_choice": {"type":"tool","name":"output"},
    "messages": [{"role":"user","content":"List 3 programming languages with year created"}]
  }' | jq '.content[0].input'
```

## Workflow Routing

| Trigger | Workflow |
|---------|----------|
| "call LLM", "prompt API", "test model" | `Workflows/SingleCall.md` |
| "compare models", "benchmark" | `Workflows/ModelCompare.md` |
| "batch process", "process N items" | `Workflows/BatchProcess.md` |
| "streaming", "real-time response" | `Workflows/Streaming.md` |
| "chain", "pipeline", "multi-step" | `Workflows/Chain.md` |

## Deep References

- `references/providers.md` — All providers: endpoints, auth, models, pricing
- `references/streaming.md` — SSE parsing for each provider
- `references/tool-use.md` — Function calling patterns (OpenAI vs Anthropic vs Gemini)
- `references/embeddings.md` — Embedding APIs, vector similarity, batch encoding
- `references/local-models.md` — Ollama, llama.cpp, vLLM setup and patterns

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/call-openai.sh` | OpenAI one-shot call |
| `scripts/call-anthropic.sh` | Anthropic one-shot call |
| `scripts/call-gemini.sh` | Gemini one-shot call |
| `scripts/batch-process.sh` | Process file of prompts through any provider |
| `scripts/compare-models.sh` | Same prompt to N models, side-by-side output |
| `scripts/token-count.sh` | Estimate tokens for input text |

## Output
- Produces: API responses, comparison reports, or batch results
- Format: JSON or plain text
