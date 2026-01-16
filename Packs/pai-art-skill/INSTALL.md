# PAI Art Skill - Installation Guide

## Prerequisites

### Required Packs (Install First)

> **STOP:** Before installing this pack, ensure you have installed:
> 1. **pai-hook-system** - Event-driven automation foundation
> 2. **pai-core-install** - Core identity, skills, and memory system
>
> These are required for this pack to function properly.

### System Requirements

- **Bun runtime**: `curl -fsSL https://bun.sh/install | bash`
- **FAL_KEY**: API key for FAL AI image generation
- **Claude Code** (or compatible agent system)
- **Write access** to `~/.claude/skills/` directory

---

## Pre-Installation: System Analysis

### Step 0.1: Detect Current Configuration

Run these commands to understand your current system:

```bash
# 1. Check for existing Art skill
if [ -d "$HOME/.claude/skills/Art" ]; then
  echo "WARNING: Art skill already exists at ~/.claude/skills/Art"
  echo "Contents:"
  ls -la "$HOME/.claude/skills/Art" 2>/dev/null
else
  echo "OK: Art skill does not exist (clean install)"
fi

# 2. Check for FAL_KEY
if [ -n "$FAL_KEY" ]; then
  echo "OK: FAL_KEY is set"
else
  echo "WARNING: FAL_KEY not set - required for image generation"
fi

# 3. Check for Bun
if command -v bun &> /dev/null; then
  echo "OK: Bun is installed ($(bun --version))"
else
  echo "WARNING: Bun not installed - required for CLI tool"
fi
```

### Step 0.2: Conflict Resolution Matrix

| Scenario | Action |
|----------|--------|
| Clean install | Proceed to Step 1 |
| Art skill exists | Backup existing, then proceed |
| FAL_KEY not set | Set FAL_KEY before proceeding |
| Bun not installed | Install Bun first |

### Step 0.3: Backup Existing Configuration (If Needed)

```bash
if [ -d "$HOME/.claude/skills/Art" ]; then
  BACKUP_DIR="$HOME/.pai-backup/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  cp -r "$HOME/.claude/skills/Art" "$BACKUP_DIR/Art"
  echo "Backed up existing Art skill to: $BACKUP_DIR/Art"
fi
```

---

## Step 1: Create Directory Structure

```bash
mkdir -p ~/.claude/skills/Art/Workflows
mkdir -p ~/.claude/skills/Art/Tools

# Verify
ls -la ~/.claude/skills/Art/
```

---

## Step 2: Set FAL_KEY Environment Variable

**Option 1: Shell profile (recommended)**

```bash
# Add to ~/.zshrc or ~/.bashrc
export FAL_KEY="your-fal-api-key-here"
```

**Option 2: .env file in skills directory**

```bash
# Create ~/.claude/skills/.env
echo 'FAL_KEY="your-fal-api-key-here"' >> ~/.claude/skills/.env
```

**Get your FAL_KEY:**
1. Go to https://fal.ai
2. Create an account or sign in
3. Navigate to API Keys
4. Generate a new key
5. Copy and add to your environment

---

## Step 3: Copy Skill Files

Copy all files from this pack's `src/skills/Art/` directory to `~/.claude/skills/Art/`:

```bash
# From the pack directory:
cp -r src/skills/Art/* ~/.claude/skills/Art/
```

**Files to copy:**
- `SKILL.md` -> `~/.claude/skills/Art/SKILL.md`
- `Tools/Generate.ts` -> `~/.claude/skills/Art/Tools/Generate.ts`
- `Workflows/Essay.md` -> `~/.claude/skills/Art/Workflows/Essay.md`
- `Workflows/Visualize.md` -> `~/.claude/skills/Art/Workflows/Visualize.md`
- `Workflows/TechnicalDiagrams.md` -> `~/.claude/skills/Art/Workflows/TechnicalDiagrams.md`
- `Workflows/Mermaid.md` -> `~/.claude/skills/Art/Workflows/Mermaid.md`
- `Workflows/Frameworks.md` -> `~/.claude/skills/Art/Workflows/Frameworks.md`
- `Workflows/Stats.md` -> `~/.claude/skills/Art/Workflows/Stats.md`
- `Workflows/CreatePAIPackIcon.md` -> `~/.claude/skills/Art/Workflows/CreatePAIPackIcon.md`

---

## Step 4: Install Tool Dependencies

```bash
cd ~/.claude/skills/Art/Tools

# Initialize if needed
if [ ! -f package.json ]; then
  bun init -y
fi

# Install dependencies
bun add @fal-ai/serverless-client
```

---

## Step 5: Verify Installation

```bash
# 1. Check all files exist
echo "Checking files..."
for file in SKILL.md Tools/Generate.ts Workflows/Essay.md Workflows/Visualize.md Workflows/TechnicalDiagrams.md Workflows/Mermaid.md Workflows/Frameworks.md Workflows/Stats.md Workflows/CreatePAIPackIcon.md; do
  if [ -f "$HOME/.claude/skills/Art/$file" ]; then
    echo "OK: $file"
  else
    echo "MISSING: $file"
  fi
done

# 2. Test the generation tool
echo ""
echo "Testing Generate tool..."
bun run ~/.claude/skills/Art/Tools/Generate.ts --help

# 3. Test with a simple generation (optional)
# bun run ~/.claude/skills/Art/Tools/Generate.ts \
#   --model nano-banana-pro \
#   --prompt "Simple test image, blue circle on white background" \
#   --size 1K \
#   --aspect-ratio 1:1 \
#   --output ~/Downloads/art-skill-test.png
```

---

## Step 6: Register Skill (If Using Skill System)

If your PAI installation uses a skill registry, add the Art skill:

```bash
# The Art skill should auto-register via its SKILL.md frontmatter
# Verify by checking skill availability:
echo "Art skill installed. Test by asking Claude to create an image."
```

---

## Verification Complete

After installation, test with these commands:

**Quick test:**
```
"Create a simple illustration of a robot reading a book"
```

**Full workflow test:**
```
"Create an editorial illustration for an essay about AI safety"
```

The Art skill should:
1. Route to the Essay workflow
2. Analyze the concept
3. Construct an optimized prompt
4. Generate the image
5. Open the result

See VERIFY.md for complete verification checklist.
