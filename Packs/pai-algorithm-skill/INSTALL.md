# Installation Guide - THE ALGORITHM Skill

## Prerequisites

- **Bun runtime**: `curl -fsSL https://bun.sh/install | bash`
- **Claude Code** (or compatible agent system)
- **pai-core-install** pack installed (provides skill routing and CORE context)
- **pai-agents-skill** pack installed (provides AgentFactory for custom agents)
- **Optional**: pai-voice-system pack for voice notifications during phase transitions

## Pre-Installation: System Analysis

```bash
# 1. Check PAI_DIR
echo "PAI_DIR: ${PAI_DIR:-'NOT SET - will use ~/.config/pai'}"

# 2. Check for existing THEALGORITHM skill
PAI_CHECK="${PAI_DIR:-$HOME/.config/pai}"
if [ -d "$PAI_CHECK/skills/THEALGORITHM" ]; then
  echo "Warning: THEALGORITHM skill already exists"
  ls -la "$PAI_CHECK/skills/THEALGORITHM"
else
  echo "Clean install - no existing THEALGORITHM skill"
fi

# 3. Check dependencies
if [ -f "$PAI_CHECK/skills/CORE/SKILL.md" ]; then
  echo "pai-core-install: INSTALLED"
else
  echo "Warning: pai-core-install not found (required)"
fi

if [ -f "$PAI_CHECK/skills/Agents/SKILL.md" ]; then
  echo "pai-agents-skill: INSTALLED"
else
  echo "Warning: pai-agents-skill not found (required for custom agents)"
fi
```

---

## Installation Steps

### Step 1: Create Directory Structure

```bash
PAI_DIR="${PAI_DIR:-$HOME/.config/pai}"

mkdir -p "$PAI_DIR/skills/THEALGORITHM/Tools"
mkdir -p "$PAI_DIR/skills/THEALGORITHM/Data"
mkdir -p "$PAI_DIR/skills/THEALGORITHM/Phases"
mkdir -p "$PAI_DIR/skills/THEALGORITHM/Reference"
mkdir -p "$PAI_DIR/MEMORY/Work"
mkdir -p "$PAI_DIR/MEMORY/State"

ls -la "$PAI_DIR/skills/THEALGORITHM/"
```

### Step 2: Copy Skill Files

Copy from this pack's `src/` directory to your PAI installation:

| Source | Destination |
|--------|-------------|
| `src/skills/THEALGORITHM/SKILL.md` | `$PAI_DIR/skills/THEALGORITHM/SKILL.md` |
| `src/skills/THEALGORITHM/Data/Capabilities.yaml` | `$PAI_DIR/skills/THEALGORITHM/Data/Capabilities.yaml` |
| `src/skills/THEALGORITHM/Tools/*.ts` | `$PAI_DIR/skills/THEALGORITHM/Tools/` |
| `src/skills/THEALGORITHM/Phases/*.md` | `$PAI_DIR/skills/THEALGORITHM/Phases/` |
| `src/skills/THEALGORITHM/Reference/*.md` | `$PAI_DIR/skills/THEALGORITHM/Reference/` |

```bash
PAI_DIR="${PAI_DIR:-$HOME/.config/pai}"
PACK_DIR="[PATH_TO_THIS_PACK]"

# Copy main skill file
cp "$PACK_DIR/src/skills/THEALGORITHM/SKILL.md" "$PAI_DIR/skills/THEALGORITHM/"

# Copy data files
cp "$PACK_DIR/src/skills/THEALGORITHM/Data/Capabilities.yaml" "$PAI_DIR/skills/THEALGORITHM/Data/"

# Copy tools
cp "$PACK_DIR/src/skills/THEALGORITHM/Tools/"*.ts "$PAI_DIR/skills/THEALGORITHM/Tools/"

# Copy phase documentation
cp "$PACK_DIR/src/skills/THEALGORITHM/Phases/"*.md "$PAI_DIR/skills/THEALGORITHM/Phases/"

# Copy reference documentation
cp "$PACK_DIR/src/skills/THEALGORITHM/Reference/"*.md "$PAI_DIR/skills/THEALGORITHM/Reference/"
```

### Step 3: Install Dependencies

```bash
cd "$PAI_DIR/skills/THEALGORITHM/Tools"
bun add yaml
```

### Step 4: Update Path References

The tools use `$PAI_DIR` environment variable or default to `~/.config/pai`. If your PAI installation is elsewhere, set the environment variable:

```bash
# Add to your shell profile (.zshrc, .bashrc, etc.)
export PAI_DIR="$HOME/.config/pai"
```

### Step 5: Register Skill (Optional)

If using the skill index system, regenerate the skill index:

```bash
bun run "$PAI_DIR/Tools/GenerateSkillIndex.ts"
```

---

## Verification

```bash
PAI_DIR="${PAI_DIR:-$HOME/.config/pai}"

echo "Checking installation..."

[ -f "$PAI_DIR/skills/THEALGORITHM/SKILL.md" ] && echo "[OK] SKILL.md" || echo "[MISSING] SKILL.md"
[ -f "$PAI_DIR/skills/THEALGORITHM/Data/Capabilities.yaml" ] && echo "[OK] Capabilities.yaml" || echo "[MISSING] Capabilities.yaml"
[ -f "$PAI_DIR/skills/THEALGORITHM/Tools/EffortClassifier.ts" ] && echo "[OK] EffortClassifier.ts" || echo "[MISSING] EffortClassifier.ts"
[ -f "$PAI_DIR/skills/THEALGORITHM/Tools/ISCManager.ts" ] && echo "[OK] ISCManager.ts" || echo "[MISSING] ISCManager.ts"
[ -f "$PAI_DIR/skills/THEALGORITHM/Tools/AlgorithmDisplay.ts" ] && echo "[OK] AlgorithmDisplay.ts" || echo "[MISSING] AlgorithmDisplay.ts"

echo ""
echo "Testing EffortClassifier..."
bun run "$PAI_DIR/skills/THEALGORITHM/Tools/EffortClassifier.ts" --request "Add a new feature" --output json | head -10

echo ""
echo "Testing ISCManager..."
bun run "$PAI_DIR/skills/THEALGORITHM/Tools/ISCManager.ts" --help | head -5
```

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `PAI_DIR` | No | Custom PAI directory (default: `~/.config/pai`) |

## Post-Installation

### Voice Support (Optional)

If you have the pai-voice-system pack installed, the AlgorithmDisplay tool will automatically send voice notifications during phase transitions. No additional configuration needed.

### Integration with Other Skills

THE ALGORITHM integrates with:
- **Agents skill** - For custom agent composition via AgentFactory
- **BeCreative skill** - For UltraThink thinking mode
- **Council skill** - For multi-perspective debate (THOROUGH+)
- **RedTeam skill** - For adversarial analysis (DETERMINED)
- **FirstPrinciples skill** - For assumption challenging
- **Browser skill** - For web verification

These integrations work automatically if the skills are installed.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| EffortClassifier not found | Check `$PAI_DIR` is set correctly |
| Missing dependencies | Run `bun add yaml` in Tools directory |
| Voice not working | Ensure pai-voice-system is installed and running |
| ISC not saving | Check `$PAI_DIR/MEMORY/Work/` directory exists |
| Capability loading fails | Verify Capabilities.yaml syntax is valid |
