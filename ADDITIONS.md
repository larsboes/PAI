# ADDITIONS.md — Fork Drift & Upstream-Merge Guide

**Fork:** `larsboes/PAI` · **Upstream:** [`danielmiessler/Personal_AI_Infrastructure`](https://github.com/danielmiessler/Personal_AI_Infrastructure)
**Purpose:** the single map of everything this fork adds or changes on top of upstream, so future upstream syncs stay cheap and safe. Read this before running a sync.

> Companion docs: `.pai-fork/` (sync machinery), `README-ADDITIONS.md` (narrative pack catalog), `PR-IDEAS.md` (changes staged to send upstream).

Last reconciled: **2026-06-09** (against upstream `2fde1bb`).

---

## 1. How this fork tracks upstream (don't `git merge`)

The fork diverged structurally from upstream (different distribution shape) — a `git merge upstream/main` would produce massive spurious conflicts for zero benefit. **Content is integrated selectively via `.pai-fork/`, never by merging branches.**

- `.pai-fork/last-synced.ref` — the upstream SHA the fork is reconciled to (**`2fde1bb`**).
- `.pai-fork/manifest.yaml` — upstream files we deliberately override + why.
- `.pai-fork/exclusions.yaml` — fork-only paths the sync never touches (see §4).
- `.github/workflows/upstream-drift.yml` — weekly drift report → `[upstream-drift]` issue. Read-only; never auto-applies.
- `.pai-fork/tools/sync.sh {status|apply|report|rollback|lint}` — the sync driver. Upstream is source of truth; manifested files 3-way merge; excluded files are left alone.

**Sync workflow:** `sync.sh status` → review → `sync.sh apply` → resolve any manifested merges → bump `last-synced.ref` → update this file.

> Git history shows the fork ~600 commits "behind" — that is an **artifact**. The fork integrates upstream by file-content sync (above), not by merging commits, so the git merge-base never advances. Trust `last-synced.ref`, not `git rev-list`.

## 2. Two filesystems (repo vs runtime)

| | Location | Git? | Role |
|---|---|---|---|
| **Repo** | `~/Developer/PAI` | yes | Source of truth for packs, hooks, releases, tools. |
| **Runtime** | `~/.claude` | **no** | What actually runs. Populated from the repo. |
| **Private vault** | `~/Developer/knowledge-base` (`$VAULT_PATH`) | separate/private | All personal content (TELOS). Never in this repo. |

Deploy paths:
- **Skills:** `sync-deploy.sh` symlinks `Packs/<X>/src` → `~/.claude/skills/<X>` (+ `~/.pi`, `~/.gemini`). Edits write through to the repo. Active set = `skills.yaml`.
- **Hooks:** canonical copies live under `Releases/v*/.claude/hooks/`; `sync-hooks.sh --fix` deploys the newest into `~/.claude/hooks/`.
- **Algorithm / PAI core:** canonical under `Releases/v5.0.0/.claude/PAI/`; deployed to `~/.claude/PAI/` by the installer. ⚠️ casing wrinkle: repo uses `ALGORITHM/`, runtime uses `Algorithm/` — keep references internally consistent per side.

## 3. Live-only files (NOT in this repo — reproduce manually)

These exist only in `~/.claude` and carry machine/personal specifics, so they are intentionally untracked. To reproduce on a new machine:

- **`~/.claude/CLAUDE.md`** — operational rules + context routing. Personal context is loaded by the **LoadTelos hook** (§6), not by `@import`. (Claude Code does **not** expand `${VAULT_PATH}` in `@import` paths — that pattern silently fails; the hook reads the env var instead.)
- **`~/.claude/settings.json`** — registers the hook lifecycle (reproduce verbatim; Claude Code rejects unknown top-level keys, so DA/principal names can NOT live here):
  - **SessionStart:** `KittyEnvPersist`, `LoadTelos`, `LoadContext`, `KVSync`(async)
  - **UserPromptSubmit:** `PromptGuard`(sync,10s), `PromptProcessing`(async,30s — the Sonnet mode/tier classifier), `RepeatDetection`(5s), `SatisfactionCapture`(async,20s)
  - **SessionEnd:** `WorkCompletionLearning`, `SessionCleanup`, `RelationshipMemory`, `UpdateCounts`, `IntegrityCheck`
  - **PreCompact:** `PreCompact`
  - **PreToolUse:** `SecurityPipeline` (Bash/Read/Write/Edit/MultiEdit)
  - Optional `dynamicContext.telosContext: false` disables TELOS injection. Deferred (add if wanted): full SessionEnd `ULWorkSync`(missing file), `Stop`/`PostToolUse` observability + voice (Pulse-dependent).
- **`~/.claude/PAI/PAI_SYSTEM_PROMPT.md`** — **resolved** copy: `{{DA_NAME}}`/`{{DA_FULL_NAME}}`→`Jarvis`, `{{PRINCIPAL_NAME}}`→`Lars`. The repo/release copy stays **tokenized** (generic template, zero personal names — F2-clean). `install.sh` `cp`s the tokenized template raw and does NOT substitute, so re-resolve after install:
  `sed -i 's/{{DA_FULL_NAME}}/Jarvis/g; s/{{DA_NAME}}/Jarvis/g; s/{{PRINCIPAL_NAME}}/Lars/g' ~/.claude/PAI/PAI_SYSTEM_PROMPT.md`
  (Only matters when launched via the `pai` launcher, which passes `--append-system-prompt-file`; plain `claude` doesn't load it. Identity also loads via LoadTelos regardless.)
- **`~/.claude/.env`**, **`.pai-protected.json`** — secrets / protection config.

**Privacy (F2) — verified clean 2026-06-09.** No vault content, no real personal data, and no secrets are committed: `git grep -w Lars -- 'Packs/**'` is empty; Personal/Telos packs reference the *mechanism* (`$VAULT_PATH`, `PERSONAL_CONTEXT.md`) not data; `.env`/credentials are untracked. **Known divergence:** this work put Lars-specific `$VAULT_PATH` references into the repo *release-template* `PAI_SYSTEM_PROMPT.md` and Algorithm `v6.4.0.md` LEARN-router — env-var *names*, not content, so still F2-clean, but the template is no longer fully generic. Harmless for Lars (his install source; LoadTelos skips a missing vault). **If ever publishing a clean generic release, genericize those two files back to the `USER/*_IDENTITY.md` convention.**

## 4. Fork-only packs (41) — excluded from sync

Authoritative list lives in `.pai-fork/exclusions.yaml` (reconciled 2026-06-09). Computed via `comm -23 <fork Packs> <upstream Packs>`:

`ApiPatterns Architecture Azure Bazel BlindSpot Brainstorm Cloudflare Cmux Confluence Context7 DataEngineer Deep DevOps DevWorkflow Docker Documents FluentBit Git Google HomeInfra HtmlDocs Jira Learn Logstash MailCraft Mermaid Notion Obsidian Outlook PPTX Parser Personal SkillForge Swift SystemAdmin Tmux TripPlanning TypeScript Uv WorldThreatModelHarness revealjs`

**Consolidations** (don't reintroduce as separate packs on sync): `DeepAnalysis`+`DeepDebug`→**Deep**; `GitWorkflow`(+GitHub/GitLab)→**Git**; `OSINT`+`PrivateInvestigator`→**Investigation**; `LlmApi`→**ApiPatterns**.
**Upstream-only pack the fork does NOT take:** `PrivateInvestigator` (absorbed into Investigation — intentional).

## 5. Custom Algorithm system (upstream has none)

The fork runs a versioned **Algorithm** (`~/.claude/PAI/Algorithm/` + `Releases/v5.0.0/.claude/PAI/ALGORITHM/`), single-sourced by the `LATEST` file. Upstream ships no equivalent — this is **fork-only doctrine; never overwrite from upstream**.

- Current: **v6.4.0** (TELOS-aware — see §6).
- Bump = author `v<X>.md`, `echo <X> > LATEST`, add `changelog.md` entry. Rollback = `echo <prev> > LATEST`.

## 6. TELOS-in-vault + the LoadTelos hook (private content, public loader)

Personal identity/goals live **only** in the private Obsidian vault (`$VAULT_PATH/Atlas/TELOS/*.md`, `Atlas/Personal/PERSONAL_CONTEXT.md`) — never committed here. The **loader is public and repo-tracked**; the **content stays private**.

- `Releases/v5.0.0/.claude/hooks/LoadTelos.hook.ts` — SessionStart hook; reads `$VAULT_PATH`, injects TELOS as a `<system-reminder>`. Mirrors `LoadContext.hook.ts`'s contract. Toggle: `settings.json` `dynamicContext.telosContext`.
- **Algorithm v6.4.0** consults TELOS (GOALS/MISSION/BELIEFS/CHALLENGES) when building Ideal State Criteria in OBSERVE, so planning aligns to the principal's actual goals.
- **Break-3 repoint:** the Algorithm LEARN-router `identity` target and `PAI_SYSTEM_PROMPT.md` persona refs point at `$VAULT_PATH/Atlas/TELOS/{IDENTITY,SOUL}.md` — **not** `USER/DA_IDENTITY.md` / `USER/PRINCIPAL_IDENTITY.md` (which this fork does not use). This is a deliberate divergence from upstream's `USER/*_IDENTITY.md` convention.
- Orphan: `TelosSummarySync.hook.ts` targets a non-existent `PAI/USER/TELOS/` — legacy, do not build on it.

## 7. Upstream files modified in-place (keep on sync)

Tracked here so `sync.sh` can 3-way-merge rather than clobber. These are **upstream-alignment or hardening**, not arbitrary forks:

| File | Change | Origin |
|---|---|---|
| `…/hooks/lib/tab-setter.ts` | `execSync`→`execFileSync` (all kitten+cmux sites), `command -v`→`which`, kitten\|jq → `execFileSync`+`JSON.parse`, `KITTY_LISTEN_ON` socket validation | upstream #1046 (hand-ported; fork has extra cmux sites) |
| `…/PAI/PULSE/**/*.ts` | `"Pulse"`→`"PULSE"` path-segment casing (real bug on Linux/WSL2) | upstream #1259 / #1175 |
| `Packs/{Art,Media}/src/**` | removed Midjourney/Discord libs (6 files) + stale trigger keywords | upstream Art security removal |

**Verified N/A to this fork** (do not re-flag): plansDirectory #672 (no such config key), case-colliding #621 (no `pai-observability-server`), wiki Algorithm #1273 (fork casing is internally consistent), PAI-Install #1267 (fork ships its own `install.sh`).

---

### Maintenance checklist (run when syncing upstream)
1. `git fetch upstream && .pai-fork/tools/sync.sh status`
2. Apply non-excluded, non-fork-only changes; 3-way-merge manifested files.
3. Re-check the §7 N/A list and §4 consolidations — don't reintroduce removed/merged items.
4. Never overwrite: Algorithm (§5), LoadTelos/TELOS wiring (§6), fork-only packs (§4).
5. Bump `.pai-fork/last-synced.ref`; update the "Last reconciled" date here.
