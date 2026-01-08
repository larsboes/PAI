# Kai Core Install - Installation Guide

**This guide is designed for AI agents installing this pack into a user's infrastructure.**

---

## 🎯 AI Agent Instructions

**This is a wizard-style installation.** Use Claude Code's native tools to guide the user through installation:

1. **AskUserQuestion** - For user decisions and confirmations
2. **TodoWrite** - For progress tracking
3. **Bash/Read/Write** - For actual installation
4. **VERIFY.md** - For final validation

### Welcome Message

Before starting, greet the user:
```
"I'm installing the CORE skill - the foundation of your PAI system. This provides
skill routing, response formatting, identity configuration, and the CreateSkill
meta-skill for building new capabilities.

Let me analyze your system and guide you through installation."
```

---

## Phase 1: System Analysis

**Execute this analysis BEFORE any file operations.**

### 1.1 Run These Commands

```bash
PAI_CHECK="${PAI_DIR:-$HOME/.config/pai}"

# Check if PAI_DIR is set
echo "PAI_DIR: ${PAI_DIR:-'NOT SET - will use ~/.config/pai'}"

# Check for Bun runtime
which bun && bun --version

# Check for hook system (required dependency)
if [ -f "$PAI_CHECK/hooks/lib/observability.ts" ]; then
  echo "✓ Hook system is installed (required)"
else
  echo "❌ Hook system NOT installed - install kai-hook-system first!"
fi

# Check for existing CORE skill
if [ -d "$PAI_CHECK/skills/CORE" ]; then
  echo "⚠️ Existing CORE skill found at: $PAI_CHECK/skills/CORE"
else
  echo "✓ No existing CORE skill (clean install)"
fi
```

### 1.2 Present Findings

Tell the user what you found:
```
"Here's what I found on your system:
- PAI_DIR: [path or NOT SET]
- Bun: [installed vX.X / NOT INSTALLED]
- Hook system: [installed / NOT INSTALLED - REQUIRED]
- Existing CORE skill: [Yes at path / No]"
```

---

## Phase 2: User Questions

**Use AskUserQuestion tool at each decision point.**

### Question 1: Missing Hook System (if not installed)

**Only ask if hook system is NOT installed:**

```json
{
  "header": "Dependency",
  "question": "The hook system is required but not installed. How should I proceed?",
  "multiSelect": false,
  "options": [
    {"label": "Install kai-hook-system first (Recommended)", "description": "I'll install the hook system pack, then continue with CORE"},
    {"label": "Skip and continue anyway", "description": "CORE will install but session context loading won't work"},
    {"label": "Abort installation", "description": "Cancel - I'll install dependencies manually"}
  ]
}
```

### Question 2: Conflict Resolution (if existing CORE found)

**Only ask if existing CORE skill detected:**

```json
{
  "header": "Conflict",
  "question": "Existing CORE skill detected at $PAI_DIR/skills/CORE. How should I proceed?",
  "multiSelect": false,
  "options": [
    {"label": "Backup and Replace (Recommended)", "description": "Creates timestamped backup, then installs new version"},
    {"label": "Merge/Update", "description": "Keep existing customizations, add new files"},
    {"label": "Abort Installation", "description": "Cancel installation, keep existing CORE"}
  ]
}
```

### Question 3: AI Identity Configuration

```json
{
  "header": "Identity",
  "question": "What should I name your AI assistant?",
  "multiSelect": false,
  "options": [
    {"label": "Kai (Recommended)", "description": "The default PAI assistant name"},
    {"label": "Atlas", "description": "Alternative name"},
    {"label": "Custom name", "description": "I'll ask you for a custom name"}
  ]
}
```

### Question 4: Final Confirmation

```json
{
  "header": "Install",
  "question": "Ready to install CORE skill?",
  "multiSelect": false,
  "options": [
    {"label": "Yes, install now (Recommended)", "description": "Proceeds with installation using choices above"},
    {"label": "Show me what will change", "description": "Lists all files that will be created/modified"},
    {"label": "Cancel", "description": "Abort installation"}
  ]
}
```

---

## Phase 3: Backup (If Needed)

**Only execute if user chose "Backup and Replace" for conflicts:**

```bash
BACKUP_DIR="$HOME/.pai-backup/$(date +%Y%m%d-%H%M%S)"
PAI_CHECK="${PAI_DIR:-$HOME/.config/pai}"

if [ -d "$PAI_CHECK/skills/CORE" ]; then
  mkdir -p "$BACKUP_DIR/skills"
  cp -r "$PAI_CHECK/skills/CORE" "$BACKUP_DIR/skills/CORE"
  echo "✓ Backed up CORE skill to $BACKUP_DIR/skills/CORE"
fi
```

---

## Phase 4: Installation

**Create a TodoWrite list to track progress:**

```json
{
  "todos": [
    {"content": "Create directory structure", "status": "pending", "activeForm": "Creating directory structure"},
    {"content": "Install SkillSystem.md", "status": "pending", "activeForm": "Installing SkillSystem.md"},
    {"content": "Install tools", "status": "pending", "activeForm": "Installing tools"},
    {"content": "Install CORE skill", "status": "pending", "activeForm": "Installing CORE skill"},
    {"content": "Install CreateSkill meta-skill", "status": "pending", "activeForm": "Installing CreateSkill"},
    {"content": "Generate initial index", "status": "pending", "activeForm": "Generating skill index"},
    {"content": "Run verification", "status": "pending", "activeForm": "Running verification"}
  ]
}
```

### 4.1 Create Directory Structure

**Mark todo "Create directory structure" as in_progress.**

```bash
mkdir -p $PAI_DIR/skills/CORE/Workflows
mkdir -p $PAI_DIR/skills/CORE/tools
mkdir -p $PAI_DIR/skills/CreateSkill/Workflows
mkdir -p $PAI_DIR/skills/CreateSkill/tools
mkdir -p $PAI_DIR/tools
```

**Mark todo as completed.**

### 4.2 Install SkillSystem.md

**Mark todo "Install SkillSystem.md" as in_progress.**

Copy `src/skills/CORE/SkillSystem.md` to `$PAI_DIR/skills/CORE/SkillSystem.md`

**Mark todo as completed.**

### 4.3 Install Tools

**Mark todo "Install tools" as in_progress.**

Copy the following tools to `$PAI_DIR/tools/`:
- `src/tools/SkillSearch.ts` → `$PAI_DIR/tools/SkillSearch.ts`
- `src/tools/GenerateSkillIndex.ts` → `$PAI_DIR/tools/GenerateSkillIndex.ts`
- `src/tools/PaiArchitecture.ts` → `$PAI_DIR/tools/PaiArchitecture.ts`

**Mark todo as completed.**

### 4.4 Install CORE Skill

**Mark todo "Install CORE skill" as in_progress.**

Copy `src/skills/CORE/SKILL.md` to `$PAI_DIR/skills/CORE/SKILL.md`

**IMPORTANT:** Replace placeholders with user's choices from Question 3:
- `[YOUR_AI_NAME]` → User's chosen AI name
- `[YOUR_NAME]` → Ask user for their name
- `[YOUR_PROFESSION]` → Ask user for their profession

**Mark todo as completed.**

### 4.5 Install CreateSkill Meta-Skill

**Mark todo "Install CreateSkill meta-skill" as in_progress.**

Copy `src/skills/CreateSkill/SKILL.md` to `$PAI_DIR/skills/CreateSkill/SKILL.md`

**Mark todo as completed.**

### 4.6 Install Workflows

Copy `src/skills/CORE/Workflows/UpdateDocumentation.md` to:
`$PAI_DIR/skills/CORE/Workflows/UpdateDocumentation.md`

### 4.7 Generate Initial Index

**Mark todo "Generate initial index" as in_progress.**

```bash
bun run $PAI_DIR/tools/GenerateSkillIndex.ts
bun run $PAI_DIR/tools/PaiArchitecture.ts generate
bun run $PAI_DIR/tools/PaiArchitecture.ts log-upgrade "Initial kai-core-install installation"
```

**Mark todo as completed.**

---

## Phase 5: Verification

**Mark todo "Run verification" as in_progress.**

**Execute all checks from VERIFY.md.**

Quick verification:
```bash
# Check CORE skill exists
ls $PAI_DIR/skills/CORE/SKILL.md

# Check tools exist
ls $PAI_DIR/tools/SkillSearch.ts
ls $PAI_DIR/tools/GenerateSkillIndex.ts

# Check CreateSkill exists
ls $PAI_DIR/skills/CreateSkill/SKILL.md

# Run SkillSearch
bun run $PAI_DIR/tools/SkillSearch.ts "test"
```

**Mark todo as completed when all VERIFY.md checks pass.**

---

## Success/Failure Messages

### On Success

```
"CORE skill installed successfully!

What's available:
- Skill routing system with USE WHEN triggers
- Structured response format
- Identity configuration for [AI_NAME]
- CreateSkill meta-skill for building new capabilities
- Architecture tracking with PaiArchitecture.ts

Your AI assistant [AI_NAME] is now configured and ready."
```

### On Failure

```
"Installation encountered issues. Here's what to check:

1. Hook system installed? Run: ls $PAI_DIR/hooks/lib/observability.ts
2. Directories created? Run: ls $PAI_DIR/skills/CORE/
3. Tools copied? Run: ls $PAI_DIR/tools/
4. Check VERIFY.md for the specific failing check

Need help? See Troubleshooting section below."
```

---

## Troubleshooting

### Step 0.1: Verify Environment and Dependencies

```bash
PAI_CHECK="${PAI_DIR:-$HOME/.config/pai}"

# Check if PAI_DIR is set
echo "PAI_DIR: ${PAI_DIR:-'NOT SET - will use ~/.config/pai'}"

# Check for hook system (required)
if [ -f "$PAI_CHECK/hooks/lib/observability.ts" ]; then
  echo "✓ Hook system is installed (required)"
else
  echo "❌ Hook system NOT installed - install kai-hook-system first!"
fi

# Check for history system (optional)
if [ -d "$PAI_CHECK/history" ]; then
  echo "✓ History system is installed (optional)"
else
  echo "ℹ️  History system not installed (skill usage won't be logged)"
fi
```

### Step 0.2: Detect Existing Installation

```bash
PAI_CHECK="${PAI_DIR:-$HOME/.config/pai}"

# Check for existing Skills directory
if [ -d "$PAI_CHECK/skills" ]; then
  echo "⚠️  Skills directory EXISTS at: $PAI_CHECK/skills"
  ls -la "$PAI_CHECK/skills" 2>/dev/null

  if [ -d "$PAI_CHECK/skills/CORE" ]; then
    echo ""
    echo "⚠️  CORE skill directory exists - will merge/update"
  fi
else
  echo "✓ No existing Skills directory (clean install)"
fi
```

### Step 0.3: Backup Existing (If Needed)

```bash
BACKUP_DIR="$HOME/.pai-backup/$(date +%Y%m%d-%H%M%S)"
PAI_CHECK="${PAI_DIR:-$HOME/.config/pai}"

if [ -d "$PAI_CHECK/skills/CORE" ]; then
  mkdir -p "$BACKUP_DIR/skills"
  cp -r "$PAI_CHECK/skills/CORE" "$BACKUP_DIR/skills/CORE"
  echo "✓ Backed up CORE skill to $BACKUP_DIR/skills/CORE"
fi
```

---

## Step 1: Create Directory Structure

```bash
# Create the Skills directory
mkdir -p $PAI_DIR/skills/CORE/Workflows
mkdir -p $PAI_DIR/skills/CORE/tools
mkdir -p $PAI_DIR/skills/CreateSkill/Workflows
mkdir -p $PAI_DIR/skills/CreateSkill/tools
mkdir -p $PAI_DIR/tools
```

---

## Step 2: Install SkillSystem.md

Copy `src/skills/CORE/SkillSystem.md` to `$PAI_DIR/skills/CORE/SkillSystem.md`

---

## Step 3: Install Tools

Copy the following tools to `$PAI_DIR/tools/`:
- `src/tools/SkillSearch.ts` → `$PAI_DIR/tools/SkillSearch.ts`
- `src/tools/GenerateSkillIndex.ts` → `$PAI_DIR/tools/GenerateSkillIndex.ts`
- `src/tools/PaiArchitecture.ts` → `$PAI_DIR/tools/PaiArchitecture.ts`

---

## Step 4: Install CORE Skill

Copy `src/skills/CORE/SKILL.md` to `$PAI_DIR/skills/CORE/SKILL.md`

**IMPORTANT:** Customize the placeholders in SKILL.md:
- `[YOUR_AI_NAME]` - Name for your AI (e.g., "Kai", "Atlas")
- `[YOUR_NAME]` - Your name
- `[YOUR_PROFESSION]` - Your profession

---

## Step 5: Install CreateSkill Meta-Skill

Copy `src/skills/CreateSkill/SKILL.md` to `$PAI_DIR/skills/CreateSkill/SKILL.md`

---

## Step 6: Install Workflows

Copy `src/skills/CORE/Workflows/UpdateDocumentation.md` to:
`$PAI_DIR/skills/CORE/Workflows/UpdateDocumentation.md`

---

## Step 7: Generate Initial Index

```bash
bun run $PAI_DIR/tools/GenerateSkillIndex.ts
```

---

## Step 8: Generate Initial Architecture

```bash
bun run $PAI_DIR/tools/PaiArchitecture.ts generate
bun run $PAI_DIR/tools/PaiArchitecture.ts log-upgrade "Initial kai-core-install installation"
```

---

## Step 9: Verify Installation

Run the verification checklist in VERIFY.md to confirm everything works.

---

## Customization

### Recommended: Define Your Personality and Identity

Edit `$PAI_DIR/skills/CORE/SKILL.md`:

1. **Fill in Your Identity**
```markdown
## Identity

**Assistant:**
- Name: [Choose a name for your AI - e.g., "Kai", "Atlas", "Sage"]
- Role: [Your name]'s AI assistant

**User:**
- Name: [Your name]
- Profession: [Your profession - e.g., "Software Engineer", "Researcher"]
```

2. **Calibrate Personality Traits**
```markdown
| Trait | Value | Description |
|-------|-------|-------------|
| Humor | 60/100 | Higher = more witty, lower = more serious |
| Curiosity | 90/100 | Higher = asks more questions, explores tangents |
| Precision | 95/100 | Higher = more exact details |
| Formality | 50/100 | Higher = more professional, lower = more casual |
| Directness | 80/100 | Higher = blunt, lower = diplomatic |
```

### Optional Customization

| Customization | File | Impact |
|---------------|------|--------|
| **Contacts Directory** | `Contacts.md` | Add your frequent contacts |
| **Stack Preferences** | `CoreStack.md` | Define your technology preferences |
| **Response Format** | `SKILL.md` | Modify the structured response format |
| **Security Protocols** | `SecurityProtocols.md` | Add project-specific security rules |

---

## Troubleshooting

### Skills Not Routing

1. Verify SKILL.md has single-line description with USE WHEN
2. Run GenerateSkillIndex.ts to rebuild index
3. Check skill frontmatter format

### Format Not Being Used

1. Verify CORE loads at session start (check hooks)
2. Ensure SKILL.md contains response format section

### Architecture Not Generating

1. Check PaiArchitecture.ts exists in Tools/
2. Verify write permissions to skills/CORE/
3. Run with explicit PAI_DIR: `PAI_DIR=~/.config/pai bun run ...`
