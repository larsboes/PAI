# PAI Upgrades Skill Installation

> **FOR AI AGENTS:** Follow these steps in order. Complete each step fully before proceeding.

---

## Prerequisites

- pai-core-install must be installed (provides skills directory structure)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) for YouTube monitoring (optional)

---

## Installation Steps

### Step 1: Create Directory Structure

```bash
mkdir -p ~/.claude/skills/Upgrades/{Workflows,Tools,State}
mkdir -p ~/.claude/SKILLCUSTOMIZATIONS/Upgrades
```

### Step 2: Copy Skill Files

Copy all files from `src/skills/Upgrades/` to `~/.claude/skills/Upgrades/`:

```bash
# From this pack's src directory
cp -r src/skills/Upgrades/* ~/.claude/skills/Upgrades/
```

**Files to copy:**
- `SKILL.md` - Main skill routing
- `sources.json` - Anthropic sources configuration
- `youtube-channels.json` - Base channels (empty)
- `Workflows/Anthropic.md` - Anthropic check workflow
- `Workflows/YouTube.md` - YouTube monitoring workflow
- `Workflows/ReleaseNotesDeepDive.md` - Deep research workflow
- `Tools/Anthropic.ts` - Source checking tool

### Step 3: Initialize State Directory

Create empty state files:

```bash
echo '{"last_check_timestamp": null, "sources": {}}' > ~/.claude/skills/Upgrades/State/last-check.json
echo '{"last_check_timestamp": null, "channels": {}}' > ~/.claude/skills/Upgrades/State/youtube-videos.json
```

### Step 4: Set Up YouTube Customization (Optional)

Create your personal YouTube channels file:

```bash
cat > ~/.claude/SKILLCUSTOMIZATIONS/Upgrades/youtube-channels.json << 'EOF'
{
  "_customization": {
    "description": "Your personal YouTube channels for AI development content",
    "merge_strategy": "append"
  },
  "channels": [
    {
      "name": "Indy Dev Dan",
      "channel_id": "@indydevdan",
      "url": "https://www.youtube.com/@indydevdan",
      "priority": "HIGH",
      "description": "Claude Code tutorials and AI development"
    }
  ]
}
EOF
```

Add more channels by editing this file.

### Step 5: Create Customization Extension Manifest (Optional)

```bash
cat > ~/.claude/SKILLCUSTOMIZATIONS/Upgrades/EXTEND.yaml << 'EOF'
# Extension manifest for Upgrades skill customization
skill: Upgrades
version: 1.0.0
files:
  - youtube-channels.json  # Your personal YouTube channels
EOF
```

### Step 6: Install yt-dlp (Optional, for YouTube Monitoring)

```bash
# macOS
brew install yt-dlp

# Or via pip
pip install yt-dlp
```

### Step 7: Verify Installation

Run the verification checklist in `VERIFY.md`.

---

## Post-Installation

### Add More YouTube Channels

Edit your customization file:
```bash
~/.claude/SKILLCUSTOMIZATIONS/Upgrades/youtube-channels.json
```

Add channels in this format:
```json
{
  "name": "Channel Name",
  "channel_id": "@channelhandle",
  "url": "https://www.youtube.com/@channelhandle",
  "priority": "HIGH",
  "description": "What this channel covers"
}
```

### Test the Skill

```
"Check for Anthropic updates"
"Any new videos from my YouTube channels?"
"Deep dive the latest Claude Code release notes"
```

---

## Troubleshooting

### "yt-dlp not found"

Install yt-dlp:
```bash
brew install yt-dlp
```

### State files not updating

Check permissions:
```bash
ls -la ~/.claude/skills/Upgrades/State/
```

### YouTube channels not loading

Verify customization file exists:
```bash
cat ~/.claude/SKILLCUSTOMIZATIONS/Upgrades/youtube-channels.json
```

---

## Next Steps

After installation:
1. Add your preferred YouTube channels to the customization file
2. Run "check for updates" to test Anthropic monitoring
3. Run "check YouTube" to test channel monitoring
4. Use "deep dive release notes" after major Claude Code releases
