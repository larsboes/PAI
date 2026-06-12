# Fork Additions — larsboes/PAI

What this fork adds beyond [`danielmiessler/Personal_AI_Infrastructure`](https://github.com/danielmiessler/Personal_AI_Infrastructure).

Upstream files are modified minimally and tracked explicitly — see **Upstream Modifications** section below.

---

## Custom Packs (16)

Complete skill packs — SKILL.md, Workflows, references, scripts.

| Pack | What it does |
|------|--------------|
| `Packs/ApiPatterns/` | Direct HTTP patterns — curl/fetch for OpenAI, Anthropic, GitHub APIs |
| `Packs/Bazel/` | Modern Bazel builds — bzlmod, custom rules, CI integration |
| `Packs/Brainstorm/` | Dual-mode thinking — critical frameworks + dump/processing mode |
| `Packs/Cloudflare/` | Workers, Pages, KV, R2, D1 via wrangler and MCP |
| `Packs/DeepAnalysis/` | Multi-lens analysis — domain mapping, system mapping, impact tracing |
| `Packs/DeepDebug/` | Systematic debugging — understand, investigate, isolate |
| `Packs/Docker/` | Build, compose, debug containers — Dockerfile patterns |
| `Packs/Documents/` | PDF, DOCX, XLSX creation, editing, format conversion |
| `Packs/FluentBit/` | Lua filter development — LuaJIT semantics, flat-key patterns, CI |
| `Packs/Git/` | Git unified — local (worktrees/rebase/bisect/reflog), GitHub (gh CLI), GitLab (glab + REST, env-var-based) |
| `Packs/Logstash/` | Pipeline development — Ruby filters, grok patterns |
| `Packs/OSINT/` | Structured investigations — people, companies, domains |
| `Packs/Parser/` | Extract structured JSON from URLs, files, PDFs |
| `Packs/SystemAdmin/` | Linux admin — systemd, journalctl, networking |
| `Packs/WorldThreatModelHarness/` | Stress-test ideas against 11 time horizons (6mo–50yr) |
| `Packs/revealjs/` | reveal.js presentations — themes, charts, speaker notes |

---

## References & Scripts Added to Upstream Packs (12)

Enrichments to Daniel's packs — new reference docs and utility scripts inside `src/`.

| Pack | Added |
|------|-------|
| `Packs/Apify/` | `src/references/` — actor-catalog, advanced-patterns, examples |
| `Packs/Browser/` | `src/references/` — patterns, tiers |
| `Packs/Council/` | `src/scripts/council-transcript.sh` |
| `Packs/FirstPrinciples/` | `src/scripts/decompose.sh` |
| `Packs/Optimize/` | `src/references/` — eval-guide, optimize-loop, target-types |
| `Packs/PAIUpgrade/` | `src/references/` — architecture, report-template |
| `Packs/RedTeam/` | `src/references/perspectives.md`, `src/scripts/attack-matrix.sh` |
| `Packs/RootCauseAnalysis/` | `src/references/` — Foundation, MethodSelection |
| `Packs/Science/` | `src/references/methodology.md`, `src/scripts/experiment-log.sh` |
| `Packs/SystemsThinking/` | `src/references/` — Archetypes, Foundation, LeveragePoints |
| `Packs/Webdesign/` | `src/references/` — Capabilities, Exports, Handoff, InputFormats |
| `Packs/WriteStory/` | `src/references/` — 9 files (aesthetics, rhetoric, critics, etc.) |

---

## Fork Infrastructure

| Path | Purpose |
|------|---------|
| `.pai-fork/manifest.yaml` | Tracks intentionally customized upstream files |
| `.pai-fork/tools/sync.sh` | Upstream sync with backup + conflict report |
| `.pai-fork/tools/` | 7 scripts: add-customization, generate-inventory, install-hooks, merge-driver, rebuild-gitattributes, reintegrate, sync |
| `.pai-fork/exclusions.yaml` | Files excluded from sync |
| `.github/workflows/upstream-drift.yml` | Weekly CI check for upstream divergence |
| `install.sh` | Fresh machine setup (Bun, Git, PAI clone) |
| `sync-hooks.sh` | Hooks version migration between PAI releases |
| `Packs/INVENTORY.md` | Auto-generated pack inventory (pre-commit hook) |
| `Packs/README.md` | Modified — added "Fork Additions" section |
| `README.md` | Modified — 4-line fork banner at top |
| `.gitattributes` | Modified — merge drivers for manifest files |

---

## Fork Infrastructure

| Path | Purpose |
|------|---------|
| `skills.yaml` | Active pack selection — comment/uncomment to toggle, profiles for security/devops/etc |
| `sync.sh` | Symlink active packs to `~/.claude/skills/`, `~/.pi/agent/skills/`, `~/.gemini/skills/` |
| `sync-capture.sh` | Pull agent improvements back into PAI source |
| `sync-hooks.sh` | Hooks version migration between PAI releases |
| `.pai-fork/manifest.yaml` | Tracks intentionally customized upstream files |
| `.pai-fork/tools/sync.sh` | Upstream sync with backup + conflict report |
| `.pai-fork/exclusions.yaml` | Files excluded from sync |
| `.github/workflows/upstream-drift.yml` | Weekly CI check for upstream divergence |
| `install.sh` | Fresh machine setup (Bun, Git, PAI clone) |

Deploy: `task pai:sync` (root Taskfile) or `./sync.sh --confirm` directly.

---

## Upstream Modifications

Changes made to Daniel's files — watch these on merge:

### Bulk fixes (2026-05-13)
- **Voice port**: All `localhost:8888` → `localhost:31337` in 167 files across `Packs/` (bug fix, worth PRing upstream)
- **`name:` fields normalized** to TitleCase in 14 packs: Architecture, DataEngineer, GitHub, HtmlDocs, Learn, Mermaid, Notion, Obsidian, SkillForge, Swift, TripPlanning, Tmux, TypeScript, Uv
- **Descriptions expanded** on 14 packs with weak descriptions: GitHub, Mermaid, Obsidian, TripPlanning, Uv, Logstash, Bazel, Tmux, Cloudflare, Documents, FluentBit, Parser, WorldThreatModelHarness, Notion
- **`Utilities` description** trimmed from 2020 → ~450 chars (over-verbose, listed every sub-skill trigger)
- **`Telos`**: Added `effort: medium` field
- **`GitWorkflow`**: Renamed to `Git`, expanded with GitHub + GitLab workflow files

### On next upstream merge
1. Run `.pai-fork/tools/sync.sh status` to see what drifted
2. Expect conflicts in modified SKILL.md files above
3. Re-apply bulk fixes if Daniel pushed new packs with `:8888`
4. Re-run `task pai:sync` after resolving

### Potential upstream PRs
| Item | Priority |
|------|----------|
| Voice port `:8888` → `:31337` | HIGH — real bug in his SKILL.md + Workflow files |
| Description expansions | MEDIUM |
| `Git` pack (GitHub.md + GitLab.md) | LOW — needs his buy-in on consolidation |
