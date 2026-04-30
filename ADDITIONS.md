# Fork Additions — Lars Boes

What this fork adds beyond [`danielmiessler/Personal_AI_Infrastructure`](https://github.com/danielmiessler/Personal_AI_Infrastructure).

This fork has diverged significantly from upstream — the relationship is mostly historical.
Pull from upstream occasionally to cherry-pick improvements, not for full merges.

---

## Architecture Changes

### Packs System
All skills are organized into themed Packs under `Packs/{Name}/src/{skill}/SKILL.md`.
Upstream uses a flat skills structure.

| Pack | Skills | Focus |
|------|--------|-------|
| Agents | Agents, Delegation, cmux | Multi-agent orchestration |
| AI | claude-api, context7, pai-memory | AI tooling |
| Content | ExtractWisdom, ContentAnalysis, Parser | Content processing |
| Daily | daily, focus-alignment, inbox, review-workflow | Life operations |
| DevTools | dev-workflow, debug, simplify, vscode | Development |
| Integrations | obsidian, notion, whatsapp, gmail, gdrive | Integrations |
| ... | 22 packs total, 90+ skills | |

### PAI Algorithm v3.7.0
Full algorithm system at `Releases/v4.0.3/.claude/PAI/Algorithm/v3.7.0.md`.
7-phase execution: Observe → Think → Plan → Build → Execute → Verify → Learn.
Upstream has no equivalent.

### Hook System (20 hooks)
All hooks at `Releases/v4.0.3/.claude/hooks/`:
- `LoadContext.hook.ts` — session start: TELOS + learning + work summary injection
- `SecurityValidator.hook.ts` — pre-tool security checks
- `PRDSync.hook.ts` — syncs PRD.md to work.json on write
- `UpdateCounts.hook.ts` — tracks session metrics
- `WorkCompletionLearning.hook.ts` — captures learnings at session end
- + 15 more

### pai-sync.sh
`scripts/pai-sync.sh` — deploys skills from PAI Packs to:
- `~/.claude/skills/` (Claude Code)
- `~/.gemini/skills/` (Gemini CLI)
- `pai-marketplace` repo (public marketplace)

Upstream has no equivalent sync mechanism.

### Releases Structure
`Releases/` contains versioned snapshots of the full Claude Code config:
`v2.3, v2.4, v2.5, v3.0, v4.0.0, v4.0.1, v4.0.2, v4.0.3`
Current live version: `v4.0.3`.

---

## Key Files Unique to This Fork

| File | Purpose |
|------|---------|
| `scripts/pai-sync.sh` | Multi-target skill deployment |
| `Releases/v4.0.3/.claude/hooks/LoadContext.hook.ts` | TELOS + dynamic context injection (includes vault TELOS loading via VAULT_PATH) |
| `Releases/v4.0.3/.claude/PAI/Algorithm/v3.7.0.md` | The Algorithm |
| `Releases/v4.0.3/.claude/CLAUDE.md` | PAI 4.0.3 system prompt |
| `ADDITIONS.md` | This file |

---

## Upstream Sync Notes

**README.md** — Keep ours on merge conflicts. Upstream's README describes their system, ours documents Lars's PAI.

**New upstream skills** — Review and cherry-pick if useful. Our skills are in Packs/, upstream's are flat.

**Algorithm/hooks changes** — Upstream may introduce new algorithm versions. Evaluate before merging.

**Frequency:** Pull upstream when notified of significant upstream changes, not on every commit.
