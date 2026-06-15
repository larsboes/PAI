# CreateSkill Workflow

Create a new PAI skill following the canonical structure, naming conventions, and progressive disclosure guidelines. This workflow uses a TypeScript scaffolding script (`Tools/ScaffoldSkill.ts`) to automate directory and file generation.

## Supporting Files

- **References**: Guidelines and best practices for creating skills
  - [References/GoodSkillGuide.md](../References/GoodSkillGuide.md) — **READ THIS** for context engineering principles, advanced frontmatter configuration, progressive disclosure, and dynamic context injection.
  - [SkillSystem.md](../../PAI/DOCUMENTATION/Skills/SkillSystem.md) — The authoritative system documentation for all PAI skills.
- **Scripts**: Run this tool to scaffold folders and files automatically
  - `Tools/ScaffoldSkill.ts` — The scaffolding CLI script. Supports command-line arguments and has an interactive fallback wizard.

---

## Step 1: Read the Authoritative Sources

**REQUIRED FIRST:**

1. Read the Skill System Documentation: `~/.claude/PAI/DOCUMENTATION/Skills/SkillSystem.md`
2. Read the Good Skill Reference Guide: `References/GoodSkillGuide.md` (Explaining Context Engineering, Progressive Disclosure, and Advanced Frontmatter).
3. Read a canonical example skill in `~/.claude/skills/` (e.g. `Research/SKILL.md`, `Daemon/SKILL.md`).

---

## Step 2: Gather Context & SME Interviews

Ask the user these questions interactively. Wait for answers before proceeding:

1. **Name and Purpose**: "What is the name of the skill, and what does it do at a high level?"
2. **Triggers**: "What are the trigger phrases or keywords that should invoke this skill? (USE WHEN triggers)"
3. **Location**: "Should this skill be **global** (`~/.claude/skills/` - available across all projects) or **project-level** (`.claude/skills/` - local to this repository)?"
4. **Depth**: Select the depth of scaffolding. **You MUST recommend a depth to the user based on their description:**
   - **skill**: Simple reference cards or static checklists (creates `SKILL.md` only).
   - **skill+workflows**: Standard multi-step playbooks (creates `SKILL.md` + `Workflows/`).
   - **skill+scripts**: Script-based tools and CLI automations (creates `SKILL.md` + `Tools/`).
   - **skill+references**: Complex, reference-heavy domain knowledge (creates `SKILL.md` + `References/`).
   - **skill+workflows+scripts**: Complete package with CLI utilities and workflows.
   - **all**: Full layout containing Workflows, Tools, and References.

*Recommendation Rule:*
- If the skill performs scripts, compilations, or CLI executions → Recommend **skill+workflows+scripts**.
- If the skill contains style guides, API definitions, or documentation references → Recommend **skill+references**.
- If the skill outlines execution sequences or manual playbooks → Recommend **skill+workflows**.

---

## Step 2a: Identify Skill Type

Classify the skill using the 9 Anthropic skill types (see details in `References/GoodSkillGuide.md`):

| # | Type | Focus | Key Structural Pattern |
|---|------|-------|------------------------|
| 1 | Library/API Reference | gotchas, edge cases | gotchas-heavy, reference snippets |
| 2 | Product Validation | test/verify code | state assertions, test execution |
| 3 | Data Fetching | connect to data systems | credential refs, query patterns |
| 4 | Business Process | automate business SOPs | execution logs, consistency tracking |
| 5 | Code Scaffolding | generate boilerplate | template files, project-aware scripts |
| 6 | Code Quality | enforce standards, reviews | deterministic scripts, hook integration |
| 7 | CI/CD & Deployment | deploy with safety checks | pre-deploy checks, smoke tests, rollbacks |
| 8 | Operations Runbook | map problems to diagnostics | phenomenon → diagnosis → report |
| 9 | Infrastructure Ops | maintenance with guardrails | safety gates, audit logging |

The type informs structure decisions — e.g. Type 1 skills are mostly gotchas, Type 7 needs safety gates.

---

## Step 2b: BPE (Bitter-Pill Engineering) Check

Before building, apply the bitter lesson test: **"Would a smarter model make this skill unnecessary?"**

- **Anti-fragile (proceed)**: Verification harnesses, data pipelines, CLI tool wrappers, accumulated gotchas, and deterministic scripts.
- **Fragile (reconsider)**: Complex chain-of-thought prompt orchestrators, format parsers, and elaborate reasoning scaffolds.

---

## Step 3: Naming Convention Enforcement (MANDATORY)

Enforce naming conventions strictly before scaffolding. **There are exactly two valid forms:**

| Skill type | Directory format | Example | Allowed content |
|------------|------------------|---------|-----------------|
| **Public** | `TitleCase` | `Blogging`, `Daemon`, `CreateSkill` | Templated, safe, generic, ready for public release |
| **Private** | `_ALLCAPS` (underscore prefix, all uppercase) | `<your-release-skill>`, `_INBOX`, `_BROADCAST` | Anything personal, sensitive, or environment-specific |

### Sub-File Casing Rules:
- **Workflow files**: `TitleCase.md` (e.g. `Create.md`, `UpdateInfo.md`).
- **Reference docs**: `TitleCase.md` (e.g. `ApiReference.md`, `GoodSkillGuide.md`).
- **Tool files**: `TitleCase.ts` (e.g. `ScaffoldSkill.ts`, `ManageServer.ts`).
- **Help files**: `TitleCase.help.md` (e.g. `ManageServer.help.md`).

*Wrong naming (NEVER use)*: `create-skill`, `create_skill`, `CREATESKILL` (no underscore for public; no snake/kebab for private).

---

## Step 4: Run the Scaffolding Tool

Execute the scaffolding command based on the parameters gathered in Step 2. The script will automatically format the casing, create the directory structure, and generate template files.

```bash
bun run ~/.claude/skills/CreateSkill/Tools/ScaffoldSkill.ts \
  --name "[SkillName]" \
  --location "[global|project]" \
  --depth "[depth]" \
  --description "[Description]" \
  --triggers "[triggers]"
```

*Note: If working in the local development repository, run `bun run Packs/CreateSkill/src/Tools/ScaffoldSkill.ts`.*

---

## Step 5: Customize the Scaffolded Files

Customize the generated template files to implement the specific playbooks and utilities:
1. **Routing Table**: Open `SKILL.md` and define the trigger mapping table.
2. **Customization Block**: Ensure the `## Customization` block exists to load `PREFERENCES.md` at runtime.
3. **Examples**: Add 2-3 concrete examples showing user input, agent process, and output (increases selection accuracy from 72% to 90%).
4. **Gotchas**: Populate the gotchas section with quirks, common errors, and constraints.
5. **Workflows**: Write instructions inside the `Workflows/[WorkflowName].md` files.

---

## Step 5b: Workflow-to-Tool Integration (CLI Flags)

**If a workflow calls a CLI tool, it MUST include intent-to-flag mapping tables.** This pattern translates natural language user requests into appropriate CLI flags:

### Intent-to-Flag Mapping
| User Says | Flag | Effect |
|-----------|------|--------|
| "JSON output" | `--format json` | Machine-readable |
| "detailed", "verbose" | `--verbose` | Extra information |

### Execute Tool
Based on user request, construct the CLI command:
```bash
bun ToolName.ts \
  [FLAGS_FROM_INTENT_MAPPING] \
  --required-param "value"
```

---

## Step 6: Public Release Readiness (MANDATORY)

If creating a public skill (`TitleCase`), verify:
1. **No sensitive content** — no API keys, tokens, credentials, private URLs.
2. **No personal references** — no author name, specific project names, personal domains, or absolute paths like `/Users/<name>/`.
3. **Pre-Flight Grep**:
   ```bash
   rg -i "danielmiessler|unsupervised|ULAdmin|thesurface|human3|ul\.live|/Users/[a-z]+/" ~/.claude/skills/[SkillName]/
   ```

*Note: Private skills (`_ALLCAPS`) are exempt from release scrubbing.*

---

## Step 7: Verify Casing & Directory Layout

Run this check:
```bash
ls -la ~/.claude/skills/[SkillName]/
ls -la ~/.claude/skills/[SkillName]/Workflows/
ls -la ~/.claude/skills/[SkillName]/Tools/
```

Verify ALL files use TitleCase:
- `SKILL.md` ✓ (exception - always uppercase)
- `WorkflowName.md` ✓
- `ToolName.ts` ✓
- `ToolName.help.md` ✓

---

## Step 8: Final Checklist

### Naming & Structure
- [ ] Skill directory uses correct casing (`TitleCase` or `_ALLCAPS`).
- [ ] All workflows, references, and tools use TitleCase naming.
- [ ] Flat directory structure matches PAI standards (max 2 levels deep). No nested folders like `Docs/` or `Context/`.
- [ ] YAML frontmatter `name:` matches the directory name exactly.
- [ ] `description:` is a single line, under 650 characters, and contains `USE WHEN`.

### Body Contents
- [ ] Gotchas section is populated with common error modes.
- [ ] Examples section contains 2-3 concrete user interaction examples.

---

## Step 9: Suggest Effectiveness Testing

Offer to run evaluations on the newly created skill:
> "The skill is now scaffolded and customized. Would you like me to test its effectiveness against a no-skill baseline? I can run the TestSkill workflow."

If they agree, execute `Workflows/TestSkill.md`.
If triggers need tuning, execute `Workflows/OptimizeDescription.md`.
