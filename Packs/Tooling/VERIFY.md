# Tooling Pack — Verification

## Quick Checks

```bash
# Scripts are executable
find src -name "*.sh" ! -executable && echo "FAIL: non-executable scripts" || echo "OK"

# Scripts pass syntax check
for f in src/*/scripts/*.sh; do bash -n "$f" || echo "FAIL: $f"; done && echo "All scripts valid"

# Key skills present
for skill in ApiPatterns GitWorkflow Docker LlmApi SystemAdmin Bazel FluentBit Logstash; do
  [ -f "src/$skill/SKILL.md" ] && echo "✓ $skill" || echo "✗ $skill MISSING"
done
```

## Optional: Test API connectivity

```bash
# Only if API keys are set
[ -n "$ANTHROPIC_API_KEY" ] && bash src/LlmApi/scripts/call-anthropic.sh claude-haiku-3-5-20241022 "ping" && echo "✓ Anthropic"
[ -n "$OPENAI_API_KEY" ] && bash src/LlmApi/scripts/call-openai.sh gpt-4o-mini "ping" && echo "✓ OpenAI"
```
