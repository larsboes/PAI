---
name: Createskill
description: MANDATORY skill creation framework for ALL skill creation requests. USE WHEN user wants to create, validate, update, or canonicalize a skill, OR user mentions skill creation, skill development, new skill, build skill, OR user references skill compliance, skill structure, or skill architecture.
---

# Createskill

**MANDATORY framework for creating, validating, updating, and canonicalizing PAI skills.**

This skill ensures all skills follow the canonical structure defined in `${PAI_DIR}/skills/CORE/SkillSystem.md`.

## Workflow Routing

**When executing a workflow, call the notification script via Bash:**

```bash
${PAI_DIR}/tools/skill-workflow-notification WorkflowName Createskill
```

| Workflow | Trigger | File |
|----------|---------|------|
| **CreateSkill** | "create skill", "new skill", "build skill" | `workflows/CreateSkill.md` |
| **ValidateSkill** | "validate skill", "check skill compliance", "audit skill" | `workflows/ValidateSkill.md` |
| **UpdateSkill** | "update skill", "add workflow to skill", "extend skill" | `workflows/UpdateSkill.md` |
| **CanonicalizeSkill** | "canonicalize skill", "fix skill structure", "standardize skill" | `workflows/CanonicalizeSkill.md` |

## Examples

**Example 1: Create a new skill**
```
User: "Create a skill for managing my docker containers"
→ Invokes CreateSkill workflow
→ Reads SkillSystem.md for canonical structure
→ Creates skill directory with TitleCase naming
→ Generates SKILL.md with single-line USE WHEN description
→ Creates workflows/ and tools/ directories
```

**Example 2: Canonicalize an existing skill**
```
User: "Canonicalize the blogging skill"
→ Invokes CanonicalizeSkill workflow
→ Analyzes current structure against SkillSystem.md
→ Renames files to TitleCase
→ Updates YAML to single-line format
→ Adds missing Examples section
→ Moves backups out of skill directory
```

**Example 3: Validate skill compliance**
```
User: "Check if the research skill is compliant"
→ Invokes ValidateSkill workflow
→ Checks TitleCase naming throughout
→ Verifies single-line USE WHEN description
→ Confirms Examples section exists
→ Reports compliance status with specific fixes needed
```

## Core Principles

### 1. SkillSystem.md is THE Source of Truth

**ALWAYS read `${PAI_DIR}/skills/CORE/SkillSystem.md` before any skill operation.**

This document defines:
- TitleCase naming convention (MANDATORY)
- Single-line `USE WHEN` description format
- Required `## Examples` section
- Workflow vs Reference documentation distinction
- Complete checklist for compliance

### 2. TitleCase Naming (MANDATORY)

All skill naming MUST use TitleCase:

| Wrong | Correct |
|-------|---------|
| `createskill` | `Createskill` |
| `create-skill` | `Createskill` |
| `CREATE_SKILL` | `Createskill` |
| `update-info.md` | `UpdateInfo.md` |

### 3. Single-Line USE WHEN Description (MANDATORY)

```yaml
# WRONG - Multi-line description
description: |
  This skill does X.
  USE WHEN user says Y.

# CORRECT - Single-line with embedded USE WHEN
description: This skill does X. USE WHEN user mentions Y or wants to do Z. Also handles A, B, C.
```

### 4. Examples Section (REQUIRED)

Every skill MUST have a `## Examples` section with 2-3 concrete usage patterns showing input → behavior → output.

### 5. Backups Go in history/backups/

**NEVER create `backups/` directories inside skills.** All backups go to `${PAI_DIR}/history/backups/`.

## Quick Reference

### Directory Structure

```
SkillName/                    # TitleCase directory
├── SKILL.md                  # Main skill file (always uppercase)
├── ReferenceDoc.md           # Reference docs at root (TitleCase)
├── tools/                    # Always present (even if empty)
│   ├── ToolName.ts           # TypeScript tools (TitleCase)
│   └── ToolName.help.md      # Tool documentation
└── workflows/
    ├── Create.md             # Execution workflows (TitleCase)
    ├── Update.md
    └── Sync.md
```

### Checklist Before Any Skill is Complete

**Naming:**
- [ ] Skill directory uses TitleCase
- [ ] All workflow files use TitleCase
- [ ] All reference docs use TitleCase
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
- [ ] Workflows contain ONLY execution procedures
- [ ] Reference docs live at skill root

## Extended Context

### Read These Before Creating/Updating Skills

1. **`${PAI_DIR}/skills/CORE/SkillSystem.md`** - Canonical skill structure (MANDATORY)
2. **`${PAI_DIR}/skills/CORE/CONSTITUTION.md`** - PAI philosophy and principles
3. **Existing skills** - Reference compliant skills like Blogging, Research, Development

### Workflow Files

- `workflows/CreateSkill.md` - Complete creation process
- `workflows/ValidateSkill.md` - Compliance auditing
- `workflows/UpdateSkill.md` - Adding/modifying skill components
- `workflows/CanonicalizeSkill.md` - Full restructuring to canonical form

## Anti-Patterns to Avoid

### ❌ Creating Without Reading SkillSystem.md
**Problem:** Skills won't follow current standards
**Solution:** ALWAYS read SkillSystem.md first

### ❌ Using kebab-case or lowercase
**Problem:** Inconsistent naming breaks pattern recognition
**Solution:** Use TitleCase for everything

### ❌ Multi-line YAML Description
**Problem:** Claude Code can't parse USE WHEN properly
**Solution:** Single-line description with embedded USE WHEN

### ❌ Missing Examples Section
**Problem:** 72% vs 90% tool selection accuracy
**Solution:** Always add 2-3 concrete examples

### ❌ Putting Backups Inside Skills
**Problem:** Clutters skill structure, .bak files everywhere
**Solution:** Use ${PAI_DIR}/history/backups/
