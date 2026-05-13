# PR Ideas — Upstream Contributions

Ideas for PRs to `danielmiessler/PAI`. Not yet submitted — staging area.

---

## HIGH Priority

### Voice port `:8888` → `:31337`
- **What:** 167 files across `Packs/` reference wrong notify port
- **Impact:** Voice notifications silently fail for all PAI users
- **Files:** SKILL.md + Workflows/*.md across ~30 packs
- **Risk:** Zero — mechanical find/replace, no logic change
- **Notes:** Our fork already fixed this. PR is a straight diff.

### `{PRINCIPAL.NAME}` YAML key quoting in Traits.yaml
- **What:** Line 175 in `Packs/Agents/src/Data/Traits.yaml` has an unquoted YAML key with curly braces
- **Impact:** Strict YAML parsers choke on this; breaks ComposeAgent for users with strict tooling
- **Fix:** Quote it: `"{PRINCIPAL.NAME}":`
- **Risk:** Zero

---

## MEDIUM Priority

### Description expansions (14 packs)
- **What:** 14 packs have <200 char descriptions with no `USE WHEN` triggers
- **Packs:** GitHub, Mermaid, Obsidian, TripPlanning, Uv, Logstash, Bazel, Tmux, Cloudflare, Documents, FluentBit, Parser, WorldThreatModelHarness, Notion
- **Impact:** Poor routing — model can't match user intent to skill
- **Risk:** Low — additive change to description field only

### `name:` field normalization (14 packs)
- **What:** Directory is TitleCase but `name:` field is kebab-case in frontmatter
- **Packs:** Architecture, DataEngineer, GitHub, HtmlDocs, Learn, Mermaid, Notion, Obsidian, SkillForge, Swift, TripPlanning, Tmux, TypeScript, Uv
- **Impact:** Invocation mismatch when `name:` doesn't match the symlink directory name
- **Risk:** May affect downstream tooling that reads `name:` — check with Daniel

---

## LOW Priority / Needs Discussion

### Unified `Git` pack (consolidating GitHub + GitLab + local)
- **What:** We created `Packs/Git/` with 3 workflow files covering all git surfaces
- **Impact:** Replaces `GitWorkflow` (local only) with full coverage
- **Risk:** Breaking change for users who reference `GitWorkflow` by name
- **Notes:** Needs Daniel's buy-in on naming and scope

### Validation gate in `sync-deploy.sh`
- **What:** Check `name:` + `description:` exist before symlinking; case-insensitive dedup
- **Impact:** Prevents broken skills from deploying silently
- **Risk:** Could reject some of Daniel's stubs that are deliberately minimal

---

## Submitted (track here after PRing)

| PR | Date | Status |
|----|------|--------|
| — | — | — |
