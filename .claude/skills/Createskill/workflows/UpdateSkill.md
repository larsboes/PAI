# UpdateSkill Workflow

**Purpose:** Add workflows, tools, or documentation to an existing skill while maintaining compliance.

## Prerequisites

**MANDATORY:** Read `${PAI_DIR}/skills/CORE/SkillSystem.md` for current standards.
**VERIFY:** Skill is already compliant (run ValidateSkill first if unsure).

## Step 1: Identify What to Update

Clarify with user:
- **Add workflow?** New execution procedure
- **Add tool?** New CLI automation
- **Add documentation?** New reference doc
- **Update SKILL.md?** Change description, add triggers

## Adding a New Workflow

### Step 2a: Create Workflow File (TitleCase)

```bash
touch ${PAI_DIR}/skills/[SkillName]/workflows/[WorkflowName].md
```

**Example:**
```bash
touch ${PAI_DIR}/skills/DockerManager/workflows/RestartContainer.md
```

### Step 3a: Write Workflow Content

Use standard workflow format:

```markdown
# [WorkflowName] Workflow

**Purpose:** [One-line description]

## Prerequisites

[What must exist/be true before running]

## Steps

1. [First action]
2. [Second action]
3. [Third action]

## Outputs

[What this workflow produces]

## Related Workflows

- `OtherWorkflow.md` - [Relationship]
```

### Step 4a: Update SKILL.md Routing Table

Add new workflow to the routing table:

```markdown
| Workflow | Trigger | File |
|----------|---------|------|
| **ExistingWorkflow** | "existing trigger" | `workflows/ExistingWorkflow.md` |
| **NewWorkflow** | "new trigger" | `workflows/NewWorkflow.md` |  ← ADD THIS
```

## Adding a New Tool

### Step 2b: Create Tool File (TitleCase)

```bash
touch ${PAI_DIR}/skills/[SkillName]/tools/[ToolName].ts
touch ${PAI_DIR}/skills/[SkillName]/tools/[ToolName].help.md
```

### Step 3b: Write Tool with Standard Header

```typescript
#!/usr/bin/env bun
/**
 * [ToolName].ts - [Brief description]
 *
 * Usage:
 *   bun ${PAI_DIR}/skills/[SkillName]/tools/[ToolName].ts <command> [options]
 *
 * Commands:
 *   start     [Description]
 *   stop      [Description]
 *   status    [Description]
 *
 * @author PAI System
 * @version 1.0.0
 */
```

### Step 4b: Create Help Documentation

Create `[ToolName].help.md` with full documentation.

## Adding Reference Documentation

### Step 2c: Create Doc at Skill Root (TitleCase)

Reference docs go at skill root, NOT in workflows/:

```bash
touch ${PAI_DIR}/skills/[SkillName]/[DocName].md
```

**Example:**
```bash
touch ${PAI_DIR}/skills/DockerManager/ContainerConfig.md
```

## Verification

After any update:

### Verify Naming
```bash
ls ${PAI_DIR}/skills/[SkillName]/
ls ${PAI_DIR}/skills/[SkillName]/workflows/
ls ${PAI_DIR}/skills/[SkillName]/tools/
```

All files should be TitleCase.

### Verify Routing
Check that SKILL.md has routing entries for all workflows:

```bash
# Count workflows
ls ${PAI_DIR}/skills/[SkillName]/workflows/*.md | wc -l

# Should match count of routing table rows
```

### Verify Examples
If significantly new functionality was added, consider adding another example to the Examples section.

## Outputs

- New workflow/tool/doc file created
- SKILL.md updated with routing (if workflow added)
- Structure maintains compliance

## Related Workflows

- `ValidateSkill.md` - Verify compliance after update
- `CanonicalizeSkill.md` - If update breaks compliance
- `CreateSkill.md` - Reference for standard structure
