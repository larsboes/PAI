# CreateSkill Workflow

**Purpose:** Create a new PAI skill following canonical structure from SkillSystem.md.

## Prerequisites

**MANDATORY:** Read `${PAI_DIR}/skills/CORE/SkillSystem.md` before proceeding.
**REFERENCE:** Read `${PAI_DIR}/skills/Blogging/SKILL.md` as a compliant example.

## Step 1: Define Skill Purpose

Ask the user to clarify:
- **What does this skill do?** (Core capability)
- **When should it activate?** (Trigger patterns)
- **What workflows does it need?** (Count and categories)
- **What tools does it need?** (CLI automation)

## Step 2: Choose Skill Name (TitleCase)

**TitleCase naming is MANDATORY.**

| Bad | Good |
|-----|------|
| `docker-manager` | `DockerManager` |
| `dockermanager` | `DockerManager` |
| `DOCKER_MANAGER` | `DockerManager` |

## Step 3: Create Directory Structure

```bash
# Create directories
mkdir -p ${PAI_DIR}/skills/[SkillName]/workflows
mkdir -p ${PAI_DIR}/skills/[SkillName]/tools
```

**Example:**
```bash
mkdir -p ${PAI_DIR}/skills/DockerManager/workflows
mkdir -p ${PAI_DIR}/skills/DockerManager/tools
```

## Step 4: Create SKILL.md

Create `${PAI_DIR}/skills/[SkillName]/SKILL.md` with this structure:

```markdown
---
name: [SkillName]
description: [What it does]. USE WHEN [intent triggers using OR]. [Additional capabilities].
---

# [SkillName]

[Brief description]

## Workflow Routing

**When executing a workflow, call the notification script via Bash:**

```bash
${PAI_DIR}/tools/skill-workflow-notification WorkflowName [SkillName]
```

| Workflow | Trigger | File |
|----------|---------|------|
| **WorkflowOne** | "trigger phrase" | `workflows/WorkflowOne.md` |
| **WorkflowTwo** | "another trigger" | `workflows/WorkflowTwo.md` |

## Examples

**Example 1: [Common use case]**
```
User: "[Typical request]"
→ Invokes WorkflowOne workflow
→ [What happens]
→ [What user gets]
```

**Example 2: [Another use case]**
```
User: "[Another request]"
→ [Process]
→ [Output]
```

## [Additional sections as needed]
```

## Step 5: Create Workflow Files (TitleCase)

Create each workflow file in `workflows/` directory:

```bash
touch ${PAI_DIR}/skills/[SkillName]/workflows/[WorkflowName].md
```

**Example:**
```bash
touch ${PAI_DIR}/skills/DockerManager/workflows/StartContainer.md
touch ${PAI_DIR}/skills/DockerManager/workflows/StopContainer.md
touch ${PAI_DIR}/skills/DockerManager/workflows/ListContainers.md
```

## Step 6: Verify Structure

Check the final structure:

```bash
ls ${PAI_DIR}/skills/[SkillName]/
ls ${PAI_DIR}/skills/[SkillName]/workflows/
ls ${PAI_DIR}/skills/[SkillName]/tools/
```

Expected output:
```
SKILL.md
workflows/
tools/

workflows/
WorkflowOne.md
WorkflowTwo.md

tools/
(empty or ToolName.ts files)
```

## Step 7: Validate Against Checklist

**Naming (TitleCase):**
- [ ] Skill directory uses TitleCase
- [ ] All workflow files use TitleCase
- [ ] YAML `name:` uses TitleCase

**YAML Frontmatter:**
- [ ] Single-line description
- [ ] Contains `USE WHEN` clause
- [ ] Under 1024 characters

**Markdown Body:**
- [ ] `## Workflow Routing` section with table
- [ ] `## Examples` section with 2-3 patterns
- [ ] All workflows have routing entries

**Structure:**
- [ ] `tools/` directory exists
- [ ] No `backups/` directory inside skill

## Outputs

- Complete skill directory at `${PAI_DIR}/skills/[SkillName]/`
- SKILL.md following canonical structure
- Workflow files for each capability
- Empty tools/ directory ready for automation

## Related Workflows

- `ValidateSkill.md` - Check compliance after creation
- `UpdateSkill.md` - Add workflows or tools later
- `CanonicalizeSkill.md` - If existing skill needs restructuring
