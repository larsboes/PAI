# ValidateSkill Workflow

**Purpose:** Audit an existing skill for compliance with SkillSystem.md canonical structure.

## Prerequisites

**MANDATORY:** Read `${PAI_DIR}/skills/CORE/SkillSystem.md` for current standards.

## Step 1: Identify Skill to Validate

Get the skill name/path from user:
- By name: "validate the Research skill"
- By path: "validate ${PAI_DIR}/skills/Research"

## Step 2: Read Skill Files

```bash
# Find the skill directory
ls ${PAI_DIR}/skills/ | grep -i [skillname]

# Read the SKILL.md
cat ${PAI_DIR}/skills/[SkillName]/SKILL.md

# List workflows
ls ${PAI_DIR}/skills/[SkillName]/workflows/

# List tools
ls ${PAI_DIR}/skills/[SkillName]/tools/
```

## Step 3: Check TitleCase Naming

Verify ALL naming uses TitleCase:

**Skill Directory:**
- [ ] `Research` not `research` or `research-skill`

**YAML name:**
- [ ] `name: Research` not `name: research`

**Workflow Files:**
- [ ] `Conduct.md` not `conduct.md` or `conduct-research.md`
- [ ] `ExtractAlpha.md` not `extract-alpha.md`

**Tool Files:**
- [ ] `SearchIndex.ts` not `search-index.ts`

**Reference Docs:**
- [ ] `ApiReference.md` not `api-reference.md`

## Step 4: Check YAML Frontmatter

Verify single-line description with USE WHEN:

**CORRECT:**
```yaml
---
name: Research
description: Comprehensive research system. USE WHEN user says do research, analyze content, or extract insights. Supports multi-source parallel research.
---
```

**INCORRECT:**
```yaml
---
name: research
description: |
  Comprehensive research system.
  USE WHEN user says do research.
triggers:
  - do research
  - analyze content
---
```

## Step 5: Check Required Sections

Verify presence of mandatory sections:

**Workflow Routing:**
- [ ] `## Workflow Routing` section exists
- [ ] Table format with Workflow | Trigger | File columns
- [ ] All workflows in workflows/ have routing entries
- [ ] Notification script documentation present

**Examples:**
- [ ] `## Examples` section exists
- [ ] 2-3 concrete examples present
- [ ] Examples show input → behavior → output pattern

## Step 6: Check Structure

**Required:**
- [ ] `SKILL.md` exists at skill root
- [ ] `workflows/` directory exists
- [ ] `tools/` directory exists (even if empty)

**Prohibited:**
- [ ] No `backups/` directory inside skill
- [ ] No `.bak` files inside skill
- [ ] No reference docs inside `workflows/` (should be at skill root)

## Step 7: Generate Compliance Report

Create a compliance report:

```markdown
# Skill Compliance Report: [SkillName]

## Status: [COMPLIANT / NON-COMPLIANT]

### TitleCase Naming
- [x] Skill directory: PASS
- [ ] YAML name: FAIL - uses lowercase
- [ ] Workflow files: FAIL - 3 files use kebab-case

### YAML Frontmatter
- [x] Single-line description: PASS
- [x] Contains USE WHEN: PASS
- [x] Under 1024 characters: PASS

### Required Sections
- [x] Workflow Routing: PASS
- [ ] Examples: FAIL - section missing

### Structure
- [x] SKILL.md exists: PASS
- [x] workflows/ exists: PASS
- [x] tools/ exists: PASS
- [ ] No backups/ inside: FAIL - found backups/

## Fixes Required
1. Rename YAML `name: research` → `name: Research`
2. Rename workflow files to TitleCase
3. Add `## Examples` section with 2-3 patterns
4. Move backups/ to ${PAI_DIR}/history/backups/

## Recommendation
Run CanonicalizeSkill workflow to fix all issues.
```

## Outputs

- Detailed compliance report
- Specific list of fixes needed
- Recommendation for next steps

## Related Workflows

- `CanonicalizeSkill.md` - Fix all compliance issues
- `UpdateSkill.md` - Add missing components
- `CreateSkill.md` - Reference for correct structure
