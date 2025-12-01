# CanonicalizeSkill Workflow

**Purpose:** Restructure an existing skill to match the canonical structure in SkillSystem.md.

## Prerequisites

**MANDATORY:** Read `${PAI_DIR}/skills/CORE/SkillSystem.md` for current standards.

## What is Canonicalization?

Canonicalization means restructuring a skill to match the EXACT format specified in SkillSystem.md, including:

1. **TitleCase naming** for all files and directories
2. **Single-line USE WHEN description** in YAML
3. **Required Examples section** with 2-3 patterns
4. **Proper structure** (workflows/, tools/, no backups inside)
5. **Workflow routing table** format

## Step 1: Analyze Current Skill

Read the current skill structure:

```bash
# Read the skill
cat ${PAI_DIR}/skills/[skill-name]/SKILL.md

# List all files
find ${PAI_DIR}/skills/[skill-name] -type f

# Check for backups inside
ls ${PAI_DIR}/skills/[skill-name]/backups/ 2>/dev/null
```

## Step 2: Create Backup

**CRITICAL:** Backup to history/backups/, NOT inside the skill:

```bash
cp -r ${PAI_DIR}/skills/[skill-name]/ ${PAI_DIR}/history/backups/[skill-name]-backup-$(date +%Y%m%d-%H%M%S)/
```

## Step 3: Rename to TitleCase

### Rename Directory (if needed)

```bash
# Example: blogging → Blogging
mv ${PAI_DIR}/skills/blogging ${PAI_DIR}/skills/Blogging
```

### Rename Workflow Files

```bash
cd ${PAI_DIR}/skills/[SkillName]/workflows/

# Example renames:
# create.md → Create.md
# update-info.md → UpdateInfo.md
# sync-repo.md → SyncRepo.md
```

### Rename Tool Files

```bash
cd ${PAI_DIR}/skills/[SkillName]/tools/

# Example renames:
# manage-server.ts → ManageServer.ts
# manage-server.help.md → ManageServer.help.md
```

### Rename Reference Docs

```bash
cd ${PAI_DIR}/skills/[SkillName]/

# Example renames:
# prosody-guide.md → ProsodyGuide.md
# api-reference.md → ApiReference.md
```

## Step 4: Update YAML Frontmatter

Convert multi-line description to single-line with USE WHEN:

**BEFORE:**
```yaml
---
name: blogging
description: |
  Complete blog workflow for your site.

  USE WHEN user mentions blog, website, etc.
triggers:
  - write a post
  - publish blog
workflows:
  - create.md
  - publish.md
---
```

**AFTER:**
```yaml
---
name: Blogging
description: Complete blog workflow for your site. USE WHEN user mentions doing anything with their blog, website, site, including things like update, proofread, write, edit, publish, preview, blog posts, articles, headers, or website pages, etc.
---
```

## Step 5: Update Workflow Routing Section

Convert to table format:

**BEFORE:**
```markdown
## Workflows

- `create.md` - Create new blog post
- `publish.md` - Publish to production
```

**AFTER:**
```markdown
## Workflow Routing

**When executing a workflow, call the notification script via Bash:**

```bash
${PAI_DIR}/tools/skill-workflow-notification WorkflowName Blogging
```

| Workflow | Trigger | File |
|----------|---------|------|
| **Create** | "write a post", "new article" | `workflows/Create.md` |
| **Publish** | "publish", "deploy" | `workflows/Publish.md` |
```

## Step 6: Add Examples Section

Add or update the Examples section:

```markdown
## Examples

**Example 1: Create new content**
```
User: "Write a blog post about AI agents"
→ Invokes Create workflow
→ Drafts content in scratchpad/
→ Opens dev server for preview
```

**Example 2: Publish to production**
```
User: "Publish the AI agents post"
→ Invokes Publish workflow
→ Runs build validation
→ Deploys to production
```
```

## Step 7: Move Backups Out

If skill has internal backups, move them:

```bash
# Move backups directory to history
mv ${PAI_DIR}/skills/[SkillName]/backups/* ${PAI_DIR}/history/backups/

# Remove empty backups directory
rmdir ${PAI_DIR}/skills/[SkillName]/backups/

# Remove any .bak files
find ${PAI_DIR}/skills/[SkillName] -name "*.bak" -exec mv {} ${PAI_DIR}/history/backups/ \;
```

## Step 8: Ensure tools/ Directory Exists

```bash
mkdir -p ${PAI_DIR}/skills/[SkillName]/tools
```

## Step 9: Verify Final Structure

```bash
# Check directory listing
ls ${PAI_DIR}/skills/[SkillName]/workflows/

# All files should be TitleCase
# Example output:
# Create.md
# Publish.md
# Header.md
```

## Step 10: Run Validation

Run ValidateSkill workflow to confirm compliance:

```bash
# All checks should pass
```

## Canonicalization Checklist

**Before declaring canonicalization complete:**

### Naming (TitleCase)
- [ ] Skill directory uses TitleCase
- [ ] All workflow files use TitleCase
- [ ] All reference docs use TitleCase
- [ ] All tool files use TitleCase
- [ ] YAML `name:` uses TitleCase

### YAML Frontmatter
- [ ] Single-line description
- [ ] Contains `USE WHEN` clause
- [ ] No separate `triggers:` or `workflows:` arrays
- [ ] Under 1024 characters

### Markdown Body
- [ ] `## Workflow Routing` section with table format
- [ ] All workflows have routing entries
- [ ] `## Examples` section with 2-3 patterns

### Structure
- [ ] `tools/` directory exists
- [ ] No `backups/` directory inside skill
- [ ] No `.bak` files inside skill
- [ ] Reference docs at skill root (not in workflows/)
- [ ] Workflows contain ONLY execution procedures

## Outputs

- Fully canonicalized skill structure
- Backup preserved in history/backups/
- All naming in TitleCase
- Compliant YAML and markdown structure

## Related Workflows

- `ValidateSkill.md` - Verify compliance after canonicalization
- `CreateSkill.md` - Reference for correct structure
- `UpdateSkill.md` - Add components after canonicalization
