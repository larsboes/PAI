# graphify — install

The skill drives the `graphify` CLI, which ships from the PyPI package **`graphifyy`** (double-y).

## Install (pick one)

```bash
uv tool install graphifyy            # recommended — puts `graphify` on PATH
pipx install graphifyy               # alternative
uvx --from graphifyy graphify ...    # no install, per-run (slower)
```

Full features (PDF/office/video extraction, Leiden clustering, Neo4j export, LLM providers):

```bash
uv tool install "graphifyy[all]"
```

## Verify

```bash
bash src/Tools/graphify.sh --version
```

If that prints an install hint instead of a version, the binary isn't resolvable — install via one of the commands above.

## Notes / gotchas

- **Package name `graphifyy`, binary `graphify`** — the mismatch is the most common setup error.
- Prefer `uv tool`/`pipx` over plain `pip install` — a bare `pip install` can yield `ModuleNotFoundError: No module named 'graphify'` because of how the package resolves its interpreter.
- **Build needs an LLM API key** (`ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `OPENAI_API_KEY`, `DEEPSEEK_API_KEY`, `MOONSHOT_API_KEY`, or `OLLAMA_BASE_URL`). With no key, graphify still builds a free **AST-only** graph (code structure), just without semantic/doc edges and community names.
- `leiden` clustering (graspologic) requires Python <3.13; `video` extras need Python ≥3.11.

## Optional: graph-first nudge hook

`src/hooks/GraphifyNudge.hook.ts` is a `PreToolUse(Bash)` hook that, **only when `graphify-out/graph.json` exists in the current project**, injects a one-line nudge to prefer `graphify query/explain/affected` over `grep`/`find`/`rg`/`fd`. It's a no-op everywhere else.

It is **not auto-registered** (it adds a bun process to every search-style Bash call). To activate:

1. Deploy it to the live hooks dir: `./sync-hooks.sh` (from the repo root) — or copy `src/hooks/GraphifyNudge.hook.ts` to `${PAI_DIR}/hooks/`.
2. Add it to `~/.claude/settings.json` under `hooks.PreToolUse` → the `"matcher": "Bash"` entry's `hooks` array:
   ```json
   { "type": "command", "command": "${PAI_DIR}/hooks/GraphifyNudge.hook.ts" }
   ```
