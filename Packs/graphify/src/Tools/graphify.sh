#!/usr/bin/env bash
# graphify.sh — resolve the graphify (PyPI: graphifyy) binary and pass args through.
# One place for binary resolution so SKILL workflows stay simple.
#
#   bash Tools/graphify.sh <graphify-args...>   # e.g. extract . --mode deep
#   bash Tools/graphify.sh --mcp                 # launch the graphify-mcp stdio server
#
# Resolution order: PATH > uv tool > pipx venv > uvx (ephemeral).
# Exits 127 with an install hint if nothing is found.
set -euo pipefail

# --mcp launches the MCP server entrypoint instead of the CLI.
BIN="graphify"
if [[ "${1:-}" == "--mcp" ]]; then
  BIN="graphify-mcp"
  shift
fi

# 1) Already on PATH (uv tool / pipx shims usually land here).
if command -v "$BIN" >/dev/null 2>&1; then
  exec "$BIN" "$@"
fi

# 2) uv tool install location.
if [[ -x "$HOME/.local/bin/$BIN" ]]; then
  exec "$HOME/.local/bin/$BIN" "$@"
fi

# 3) pipx venv.
if [[ -x "$HOME/.local/pipx/venvs/graphifyy/bin/$BIN" ]]; then
  exec "$HOME/.local/pipx/venvs/graphifyy/bin/$BIN" "$@"
fi

# 4) uvx ephemeral run (no install). Only works for the CLI entrypoint.
if [[ "$BIN" == "graphify" ]] && command -v uvx >/dev/null 2>&1; then
  exec uvx --from graphifyy graphify "$@"
fi

# Nothing found — print install hint and fail.
cat >&2 <<'EOF'
graphify not found. Install it (package name is graphifyy, double-y):

    uv tool install graphifyy          # recommended, puts `graphify` on PATH
    # or:  pipx install graphifyy
    # or:  uvx --from graphifyy graphify ...   # no install, per-run

Optional extras for full functionality:
    uv tool install "graphifyy[all]"   # pdf, office, video, leiden, neo4j, providers

See INSTALL.md in this skill for details.
EOF
exit 127
