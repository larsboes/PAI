# PAI Core Install - Installation Guide

## Prerequisites

### Required Packs (Install First)

> **STOP:** Before installing this pack, ensure you have installed:
> 1. **pai-hook-system** - Event-driven automation foundation
>
> pai-hook-system provides the lifecycle hooks that enable CORE functionality (context loading, session management, etc.).

### System Requirements

- **Bun runtime**: `curl -fsSL https://bun.sh/install | bash`
- **Claude Code** (or compatible agent system)
- **Write access** to `~/.claude/` directory

---

## Pre-Installation: System Analysis

### Step 0.1: Detect Current Configuration

Run these commands to understand your current system:

```bash
# 1. Check if PAI directory exists
if [ -d "$HOME/.claude" ]; then
  echo "PAI directory EXISTS at: $HOME/.claude"
  echo "Contents:"
  ls -la "$HOME/.claude/skills/" 2>/dev/null || echo "  (no skills yet)"
else
  echo "PAI directory does not exist (clean install)"
fi

# 2. Check for existing CORE skill
if [ -d "$HOME/.claude/skills/CORE" ]; then
  echo "CORE skill ALREADY EXISTS"
  echo "Existing CORE contents:"
  ls -la "$HOME/.claude/skills/CORE/"
else
  echo "No existing CORE skill (clean install)"
fi

# 3. Check Claude settings
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ -f "$CLAUDE_SETTINGS" ]; then
  echo "settings.json EXISTS"
else
  echo "No settings.json (will be created)"
fi
```

### Step 0.2: Conflict Resolution Matrix

| Scenario | Existing State | Action |
|----------|---------------|--------|
| **Clean Install** | No `~/.claude/skills/CORE/` | Proceed normally with Step 1 |
| **CORE Exists** | CORE skill present | **MERGE** - backup USER, replace SYSTEM |
| **USER Content Exists** | Has personal USER files | **PRESERVE** - never overwrite USER |

### Step 0.3: Backup Existing Configuration (If Needed)

If CORE already exists, create a backup before proceeding:

```bash
# Create timestamped backup
if [ -d "$HOME/.claude/skills/CORE" ]; then
  BACKUP_DIR="$HOME/.pai-backup/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"

  # Backup USER directory (CRITICAL - personal content)
  if [ -d "$HOME/.claude/skills/CORE/USER" ]; then
    cp -r "$HOME/.claude/skills/CORE/USER" "$BACKUP_DIR/USER"
    echo "Backed up USER directory to: $BACKUP_DIR/USER"
  fi

  # Backup WORK directory (CRITICAL - sensitive content)
  if [ -d "$HOME/.claude/skills/CORE/WORK" ]; then
    cp -r "$HOME/.claude/skills/CORE/WORK" "$BACKUP_DIR/WORK"
    echo "Backed up WORK directory to: $BACKUP_DIR/WORK"
  fi

  echo "Backup location: $BACKUP_DIR"
fi
```

---

## Installation Steps

### Step 1: Create Directory Structure

```bash
# Create base skill directories
mkdir -p ~/.claude/skills/CORE/{SYSTEM,USER,WORK,Workflows,Tools}
mkdir -p ~/.claude/skills/CORE/USER/{PAISECURITYSYSTEM,SKILLCUSTOMIZATIONS,BANNER,TERMINAL}

# Verify structure
ls -la ~/.claude/skills/CORE/
```

### Step 2: Copy SKILL.md

Copy the main skill definition file:

```bash
cp src/skills/CORE/SKILL.md ~/.claude/skills/CORE/SKILL.md
```

### Step 3: Copy SYSTEM Directory

The SYSTEM directory contains all PAI architecture documentation:

```bash
cp -r src/skills/CORE/SYSTEM/* ~/.claude/skills/CORE/SYSTEM/

# Verify - should show 19+ files
ls -la ~/.claude/skills/CORE/SYSTEM/
```

**Expected files:**
- PAISYSTEMARCHITECTURE.md
- SKILLSYSTEM.md
- MEMORYSYSTEM.md
- THEHOOKSYSTEM.md
- RESPONSEFORMAT.md
- And 14+ more

### Step 4: Copy USER Templates

**IMPORTANT:** If you already have USER content, SKIP this step to preserve your data.

```bash
# Only copy if USER is empty or doesn't exist
if [ ! -f "$HOME/.claude/skills/CORE/USER/README.md" ]; then
  cp -r src/skills/CORE/USER/* ~/.claude/skills/CORE/USER/
  echo "Copied USER templates"
else
  echo "USER directory has content - preserving existing files"
fi
```

### Step 5: Copy WORK Template

**IMPORTANT:** If you already have WORK content, SKIP this step to preserve your data.

```bash
# Only copy if WORK is empty or doesn't exist
if [ ! -f "$HOME/.claude/skills/CORE/WORK/README.md" ]; then
  cp src/skills/CORE/WORK/README.md ~/.claude/skills/CORE/WORK/
  echo "Copied WORK template"
else
  echo "WORK directory has content - preserving existing files"
fi
```

### Step 6: Copy Workflows

```bash
cp -r src/skills/CORE/Workflows/* ~/.claude/skills/CORE/Workflows/

# Verify
ls -la ~/.claude/skills/CORE/Workflows/
```

**Expected files:**
- Delegation.md
- SessionContinuity.md
- ImageProcessing.md
- Transcription.md

### Step 7: Copy Tools

```bash
cp -r src/skills/CORE/Tools/* ~/.claude/skills/CORE/Tools/

# Verify
ls -la ~/.claude/skills/CORE/Tools/
```

**Expected files:**
- Inference.ts
- SessionProgress.ts
- FeatureRegistry.ts
- SkillSearch.ts

### Step 8: Configure settings.json

Create or update `~/.claude/settings.json`:

```json
{
  "daidentity": {
    "name": "Kai",
    "fullName": "Kai AI Assistant",
    "voiceId": "your-elevenlabs-voice-id"
  },
  "principal": {
    "name": "YourName",
    "timezone": "America/Los_Angeles"
  }
}
```

**If settings.json already exists**, merge the above into your existing configuration.

### Step 9: Set Environment Variables

Add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export PAI_DIR="$HOME/.claude"
export DA="Kai"  # Your DA's name
export TIME_ZONE="America/Los_Angeles"
```

Then reload:

```bash
source ~/.zshrc  # or source ~/.bashrc
```

### Step 10: Restore Backed Up Content (If Applicable)

If you backed up USER/WORK content in Step 0.3:

```bash
# Restore USER content (merge, don't overwrite templates)
if [ -d "$BACKUP_DIR/USER" ]; then
  # Copy user files that don't exist in new install
  for file in "$BACKUP_DIR/USER"/*; do
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      if [ ! -f "$HOME/.claude/skills/CORE/USER/$filename" ] || [ "$filename" != "README.md" ]; then
        cp "$file" "$HOME/.claude/skills/CORE/USER/"
        echo "Restored: $filename"
      fi
    fi
  done
fi

# Restore WORK content entirely
if [ -d "$BACKUP_DIR/WORK" ]; then
  cp -r "$BACKUP_DIR/WORK"/* ~/.claude/skills/CORE/WORK/
  echo "Restored WORK content"
fi
```

---

## One-Line Installation (Clean Install Only)

For completely fresh installations:

```bash
# Create structure and copy all files
mkdir -p ~/.claude/skills/CORE/{SYSTEM,USER,WORK,Workflows,Tools} && \
mkdir -p ~/.claude/skills/CORE/USER/{PAISECURITYSYSTEM,SKILLCUSTOMIZATIONS,BANNER,TERMINAL} && \
cp src/skills/CORE/SKILL.md ~/.claude/skills/CORE/ && \
cp -r src/skills/CORE/SYSTEM/* ~/.claude/skills/CORE/SYSTEM/ && \
cp -r src/skills/CORE/USER/* ~/.claude/skills/CORE/USER/ && \
cp src/skills/CORE/WORK/README.md ~/.claude/skills/CORE/WORK/ && \
cp -r src/skills/CORE/Workflows/* ~/.claude/skills/CORE/Workflows/ && \
cp -r src/skills/CORE/Tools/* ~/.claude/skills/CORE/Tools/ && \
echo "CORE skill installed successfully!"
```

---

## Post-Installation

After installation, populate your USER directory:

1. **Edit `USER/ABOUTME.md`** - Tell your DA about yourself
2. **Edit `USER/BASICINFO.md`** - Add your name, timezone, location
3. **Edit `USER/DAIDENTITY.md`** - Customize your DA's personality
4. **Update `settings.json`** - Set your DA's name and your details

**The USER directory is intentionally empty.** CORE provides the structure; you provide the personalization.

---

## Verification

Run the verification checklist in VERIFY.md to confirm successful installation.
