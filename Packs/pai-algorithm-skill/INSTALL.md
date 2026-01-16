# PAI Algorithm Skill Installation Wizard

> **FOR AI AGENTS:** Follow these steps exactly to install this pack. Use TodoWrite to track progress.

---

## Prerequisites

- [ ] Bun runtime installed (`curl -fsSL https://bun.sh/install | bash`)
- [ ] Claude Code or compatible AI coding assistant
- [ ] PAI base system (pai-core-install) already installed
- [ ] PAI agents system (pai-agents-skill) installed (for agent composition)

---

## Pre-Installation Analysis

### Step 0.1: Detect Current Configuration

```bash
# Check if target directories exist
ls -la ~/.claude/skills/THEALGORITHM/ 2>/dev/null || echo "THEALGORITHM not installed"
```

### Step 0.2: Backup Existing Files (if present)

```bash
# If THEALGORITHM exists, create backup
if [ -d ~/.claude/skills/THEALGORITHM ]; then
  cp -r ~/.claude/skills/THEALGORITHM ~/.claude/skills/THEALGORITHM.backup.$(date +%Y%m%d)
  echo "Backup created"
fi
```

---

## Installation Steps

### Step 1: Create Directory Structure

```bash
mkdir -p ~/.claude/skills/THEALGORITHM/{Data,Tools,Phases,Reference}
mkdir -p ~/.claude/MEMORY/Work
mkdir -p ~/.claude/MEMORY/State
mkdir -p ~/.claude/MEMORY/Learning/ALGORITHM
```

### Step 2: Copy Source Files

```bash
# Copy all files from src/ to target
cp -r ~/Projects/PAI/Packs/pai-algorithm-skill/src/skills/THEALGORITHM/* ~/.claude/skills/THEALGORITHM/
```

### Step 3: Verify TypeScript Tools

```bash
# Test that tools can be executed
bun run ~/.claude/skills/THEALGORITHM/Tools/EffortClassifier.ts --help
bun run ~/.claude/skills/THEALGORITHM/Tools/ISCManager.ts --help
bun run ~/.claude/skills/THEALGORITHM/Tools/AlgorithmDisplay.ts --help
```

### Step 4: Install Dependencies (if any)

The ALGORITHM skill requires the `yaml` package for parsing capabilities:

```bash
cd ~/.claude/skills/THEALGORITHM/Tools
bun add yaml
```

### Step 5: Verify Skill Integration

Check that the skill appears in available skills:

```bash
# The skill should now be accessible
ls -la ~/.claude/skills/THEALGORITHM/SKILL.md
```

### Step 6: Test Core Tools

```bash
# Test effort classification
bun run ~/.claude/skills/THEALGORITHM/Tools/EffortClassifier.ts --request "Add a new feature"

# Test capability loading
bun run ~/.claude/skills/THEALGORITHM/Tools/CapabilityLoader.ts --effort STANDARD

# Test ISC creation
bun run ~/.claude/skills/THEALGORITHM/Tools/ISCManager.ts create --request "Test ISC"
bun run ~/.claude/skills/THEALGORITHM/Tools/ISCManager.ts show
bun run ~/.claude/skills/THEALGORITHM/Tools/ISCManager.ts clear
```

---

## Post-Installation Configuration

### Optional: Configure Voice Notifications

If you have the voice system installed, THE ALGORITHM will automatically send voice announcements during phase transitions:

```bash
# Test voice integration
bun run ~/.claude/skills/THEALGORITHM/Tools/AlgorithmDisplay.ts start STANDARD -r "Test request"
```

### Optional: Create User Customizations Directory

```bash
mkdir -p ~/.claude/skills/CORE/USER/SKILLCUSTOMIZATIONS/THEALGORITHM
```

Then create `~/.claude/skills/CORE/USER/SKILLCUSTOMIZATIONS/THEALGORITHM/PREFERENCES.md` to customize behavior.

---

## Post-Installation

Proceed to `VERIFY.md` to confirm successful installation.
