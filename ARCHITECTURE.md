# PAI Architecture

## Repositories

| Repo | Role | Visibility |
|------|------|------------|
| `larsboes/PAI` | Source of truth for all Packs and skills (fork of `danielmiessler/PAI`) | Public (fork) |
| `larsboes/pai-personal` | Marketplace-only — `.claude-plugin/marketplace.json` + `marketplace/plugins/` | Private |

**PAI** contains everything: upstream Packs from Daniel Miessler + custom Packs (Coding, Content, DevTools, Infrastructure, Integrations, LifeOS, Personal, SkillsMeta, Terminal). All skill development and editing happens here.

**pai-personal** exists solely because GitHub forks cannot be registered as marketplaces in the Claude Desktop UI (the server resolves forks to their parent). It holds no source code — only the marketplace manifest and plugin directories, synced from PAI via script.

## Skill Flow

```
PAI/Packs/*/src/*/          ──symlinks──>  ~/.claude/skills/
                                           (Claude Code reads skills from here)

PAI/Packs/                  ──sync script──>  pai-personal/marketplace/plugins/
                                              (marketplace for Claude Desktop UI)
```

## Directory Layout

```
PAI/
├── Packs/
│   ├── Agents/            # Upstream
│   ├── Coding/            # Custom — TypeScript, Swift, Python uv, architecture
│   ├── Content/           # Custom — webfetch, mermaid, transcribe, html-docs
│   ├── ContentAnalysis/   # Upstream
│   ├── ContextSearch/     # Upstream
│   ├── DevTools/          # Custom — debug, design, dev-workflow, vscode, context7
│   ├── Infrastructure/    # Custom — Fritz!Box, Synology NAS
│   ├── Integrations/      # Custom — gccli, gdcli, gmcli, github, notion, obsidian, zotero, notebooklm
│   ├── Investigation/     # Upstream
│   ├── LifeOS/            # Custom — learn, inbox, review-workflow, trip-planning, apartment-scout
│   ├── Media/             # Upstream
│   ├── Personal/          # Custom — brainstorm, daily, focus-alignment, pai-memory, whatsapp, application-writer
│   ├── Research/          # Upstream
│   ├── Scraping/          # Upstream
│   ├── Security/          # Upstream
│   ├── SkillsMeta/        # Custom — skill-forge, skill-sync, pi-extender, find-skills, system-ops
│   ├── Telos/             # Upstream
│   ├── Terminal/          # Custom — tmux, cmux
│   ├── Thinking/          # Upstream
│   ├── USMetrics/         # Upstream
│   └── Utilities/         # Upstream
├── .claude-plugin/
│   └── marketplace.json   # PAI marketplace (cannot register via Desktop UI due to fork)
└── ARCHITECTURE.md

pai-personal/
├── .claude-plugin/
│   └── marketplace.json   # Marketplace manifest (registered via Desktop UI)
└── marketplace/
    └── plugins/
        ├── coding/        # Each plugin has .claude-plugin/plugin.json + skills/
        ├── devtools/
        └── ...            # Synced from PAI by script
```

## Configuration

| What | Where | Contains |
|------|-------|----------|
| Secrets and paths | `~/.env` | Vault paths, Fritz/Synology/Zotero credentials, service ports |
| Personal context | Obsidian vault (`Atlas/Identity/`) | PERSONAL_CONTEXT.md, life context |
| Analyses and reference | Obsidian vault (`Atlas/Analysis/`, `Resources/`) | Project analyses, guides, PDFs |
| Skill source code | `PAI/Packs/*/src/*/SKILL.md` | All skill definitions |

Skills reference `~/.env` variables via `${VAR}` for paths and credentials. No secrets or personal paths are hardcoded in Pack source files.

## Upstream Sync

PAI tracks `danielmiessler/Personal_AI_Infrastructure` as `upstream` remote:

```bash
git fetch upstream
git merge upstream/main
```

Custom Packs live alongside upstream Packs in the same `Packs/` directory. Merge conflicts are limited to files upstream modifies (README, marketplace config).

## Marketplace Sync (PAI -> pai-personal)

A sync script generates the marketplace structure from PAI Packs:

1. For each Pack, creates `marketplace/plugins/<name>/` with:
   - `.claude-plugin/plugin.json` (name, description, version)
   - `skills/` directory with the Pack's skills
2. Updates `marketplace.json` with all plugin entries
3. Commits and pushes to `pai-personal`

This allows `larsboes/pai-personal` to be registered as a marketplace in the Claude Desktop UI.
