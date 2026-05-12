# Fork Additions — Lars Boes

What this fork adds beyond [`danielmiessler/Personal_AI_Infrastructure`](https://github.com/danielmiessler/Personal_AI_Infrastructure).

This fork follows Daniel's clean pack architecture, strips Claude Code-specific boilerplate (voice notifications, SKILLCUSTOMIZATIONS), and adds improvements: real executable scripts, natural descriptions, model-agnostic wording. Skills are the universal unit — portable across Pi, Claude Code, Gemini CLI.

---

## Architecture

### Packs System

Flat structure: one skill per top-level pack — `Packs/{Skill}/SKILL.md`.

Aligns with upstream v5.0.0 layout. Each pack has `README.md` (pack manifest with frontmatter), `INSTALL.md`, `VERIFY.md`, and `SKILL.md` + `Workflows/` at root.

**Active skills (root SKILL.md, discovered by any agent):** 37 (33 top-level + 4 Documents sub-skills)
**Future-port candidates (src/SKILL.md only):** Optimize, Webdesign, ArXiv

### Integration with Pi Agent

Skills load into [Pi](https://github.com/badlogic/pi-mono) via `~/.pi/agent/config.yml`:

```yaml
skills:
  customDirectories:
    - ~/Developer/PAI/Packs
    - ~/Developer/pai-work/Packs
```

Pi recursively scans for `SKILL.md` files, injects descriptions into system prompt, loads full content on-demand.

### Integration with Pi Agent

Skills load into [Pi](https://github.com/badlogic/pi-mono) via `~/.pi/agent/config.yml`:

```yaml
skills:
  customDirectories:
    - ~/Developer/PAI/Packs
    - ~/Developer/pai-work/Packs
```

Pi recursively scans for `SKILL.md` files, injects names+descriptions into the system prompt, and loads full content on-demand via `read`.

---

## Branch Strategy

```
main    = pure upstream mirror (never commit here)
dev     = our work (all changes here)
```

### Upstream Sync Strategy

We follow Daniel's clean pack architecture and merge upstream changes when structurally compatible. Cherry-pick individual skills when full-merge would conflict with our customizations.

**When upstream adds a useful skill:**
```bash
git fetch upstream
# Extract specific skill content
git show upstream/main:Packs/{Skill}/src/SKILL.md > /tmp/review.md
# Manually port: rewrite SKILL.md to our format, copy Workflows & references
```

**What we strip when porting:**
- Voice notification boilerplate (`curl localhost:31337/notify`)
- `~/.claude/PAI/USER/SKILLCUSTOMIZATIONS/` checks
- Keyword-stuffed descriptions (rewrite to natural language, <200 chars)
- `effort:` and `context:` non-standard frontmatter
- Execution log JSONL appending

**What we keep:**
- Workflow files (valuable structured content)
- Reference files (deep knowledge)
- Core skill logic and routing tables

### Ported from Upstream v5.0.0

| Skill | Date | Notes |
|-------|------|-------|
| SystemsThinking | 2026-05-07 | Clean port, stripped boilerplate |
| RootCauseAnalysis | 2026-05-07 | Clean port, stripped boilerplate |
| WriteStory | 2026-05-07 | Clean port, stripped boilerplate |
| BitterPillEngineering | 2026-05-11 | Stripped voice/customizations/log; made model-agnostic |
| ApertureOscillation | 2026-05-11 | Stripped voice/customizations/log; ISC → generic IMPLICATIONS |
| Ideate | 2026-05-11 | 9-phase engine; stripped boilerplate; 6 workflows |
| IterativeDepth | 2026-05-11 | Rewritten SKILL.md; TheLenses+ScientificFoundation → references/ |
| Browser | 2026-05-11 | Rewritten for agent-browser (Rust CLI); uses system Chrome |

### Upstream Skills Evaluated & Skipped

| Skill | Reason |
|-------|--------|
| ISA | PAI-specific (Ideal State Artifact lifecycle) |
| Interview | PAI TELOS interview system — not relevant to Pi |
| Daemon | PAI public profile management |
| Migrate | PAI content migration |
| ContextSearch | PAI session recovery — Pi has its own |
| Knowledge | PAI knowledge archive — we use Pi's memory system |
| Loop/Optimize | Very thin skills, agent can do this natively |
| Interceptor | CDP-based browser — we have Browser skill |
| Sales | Niche, low priority |
| Fabric | Killed in our May 6 restructure |
| IterativeDepth | Kept in src/ — port when needed |

### Future Port Candidates (src/SKILL.md, not active yet)

| Skill | Value | Notes |
|-------|-------|-------|
| Optimize | Medium | Autonomous hill-climbing loop with metrics |
| Webdesign | Medium | Claude Design integration + frontend handoff |
| ArXiv | Low | Paper search — niche |

---

## Key Additions Unique to This Fork

| Pack | Purpose |
|------|---------|
| `Packs/ApiPatterns/` | Direct HTTP patterns for OpenAI, Anthropic, GitHub — original |
| `Packs/GitWorkflow/` | Advanced git: worktrees, rebase, bisect, reflog — original |
| `Packs/Docker/` | Build, compose, debug containers — original |
| `Packs/LlmApi/` | Call any LLM in one line — original |
| `Packs/SystemAdmin/` | systemd, journalctl, networking — original |
| `Packs/Brainstorm/` | Brainstorming — original |
| `Packs/DeepAnalysis/` | Deep analysis methodology — original |
| `Packs/DeepDebug/` | Debugging methodology — original |

| File | Purpose |
|------|---------|
| `ADDITIONS.md` | This file |
| `PLAN.md` | Planned work |
| `Packs/ADDITIONS.md` | Restructure changelog |
| `pi-mono/IDEAS.md` | Skill reduction plan (target: ~20 active skills) |
