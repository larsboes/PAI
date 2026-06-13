# graphify (PAI skill)

Graph-first codebase understanding. Wraps the `graphify` (PyPI `graphifyy`) CLI so the agent can turn a repo into a queryable knowledge graph and then **query instead of grep**.

- **Build once** (`extract`, needs an LLM key or falls back to free AST-only).
- **Then read for free**: `query` / `explain` / `path` / `affected`.
- **Keep fresh** with `update` (AST-only, free).
- **Export** call-flow / tree / SVG / GraphML / Cypher.

See `src/SKILL.md` for the workflows and `INSTALL.md` for setup.

Custom fork pack (not upstream). Drives CLI verbs directly; never calls `graphify install`.
