# PAI Voice System - Installation Guide

## Prerequisites

- **Bun runtime**: `curl -fsSL https://bun.sh/install | bash`
- **macOS**: Currently the primary supported platform
- **ElevenLabs account**: [elevenlabs.io](https://elevenlabs.io) - API key required
- **Required PAI Packs** (install these first):
  - `pai-hook-system` - Foundation hook infrastructure
  - `pai-core-install` - Skills, identity, and response format

---

## Pre-Installation: System Analysis

### Step 0.1: Verify Required Dependencies

```bash
PAI_CHECK="${PAI_DIR:-$HOME/.config/pai}"

echo "=== Checking Required Dependencies ==="

# Check hook system (REQUIRED)
if [ -d "$PAI_CHECK/hooks" ]; then
  echo "✓ pai-hook-system is installed"
else
  echo "❌ pai-hook-system NOT installed - REQUIRED!"
fi

# Check core install (REQUIRED)
if [ -d "$PAI_CHECK/skills" ] && [ -f "$PAI_CHECK/skills/CORE/SKILL.md" ]; then
  echo "✓ pai-core-install is installed"
else
  echo "❌ pai-core-install NOT installed - REQUIRED!"
fi
```

### Step 0.2: Check Port Availability

```bash
# Check if default port 8888 is available
if lsof -i :8888 > /dev/null 2>&1; then
  echo "⚠️  Port 8888 is IN USE"
  lsof -i :8888 | head -5
  echo ""
  echo "Options:"
  echo "  1. Stop the service using port 8888"
  echo "  2. Use a different port (set VOICE_SERVER_PORT in ~/.env)"
else
  echo "✓ Port 8888 is available"
fi
```

---

## Step 1: Create Directory Structure

```bash
PAI_DIR="${PAI_DIR:-$HOME/.config/pai}"

mkdir -p $PAI_DIR/hooks/lib
mkdir -p $PAI_DIR/voice-server
```

---

## Step 2: Install Voice Server

Copy the voice server files:

```bash
# From pack directory
cp src/voice/server.ts $PAI_DIR/voice-server/server.ts
cp src/voice/manage.sh $PAI_DIR/voice-server/manage.sh
chmod +x $PAI_DIR/voice-server/manage.sh
```

---

## Step 3: Install Prosody Enhancer

Copy the prosody enhancer library:

```bash
cp src/hooks/lib/prosody-enhancer.ts $PAI_DIR/hooks/lib/prosody-enhancer.ts
```

---

## Step 4: Install Voice Hooks

Copy the voice hooks:

```bash
cp src/hooks/stop-hook-voice.ts $PAI_DIR/hooks/stop-hook-voice.ts
cp src/hooks/subagent-stop-hook-voice.ts $PAI_DIR/hooks/subagent-stop-hook-voice.ts
```

---

## Step 5: Configure ElevenLabs API

1. **Sign up** at [elevenlabs.io](https://elevenlabs.io)
2. **Get your API key** from Profile → API key
3. **Choose a voice** from the Voice Library and copy its ID
4. **Add to ~/.env**:

```bash
ELEVENLABS_API_KEY=your-api-key-here
ELEVENLABS_VOICE_ID=your-voice-id-here
```

### Test Your API Key

```bash
curl -X POST "https://api.elevenlabs.io/v1/text-to-speech/YOUR_VOICE_ID" \
  -H "xi-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, this is a test.", "model_id": "eleven_turbo_v2_5"}' \
  --output test.mp3

afplay test.mp3  # Should hear "Hello, this is a test"
rm test.mp3
```

---

## Step 6: Register Hooks

Add the voice hooks to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "bun run $PAI_DIR/hooks/stop-hook-voice.ts"
      }
    ],
    "SubagentStop": [
      {
        "type": "command",
        "command": "bun run $PAI_DIR/hooks/subagent-stop-hook-voice.ts"
      }
    ]
  }
}
```

**Note:** Replace `$PAI_DIR` with your actual PAI directory path, or ensure the environment variable is set.

---

## Step 7: Start Voice Server

```bash
# Start the voice server
$PAI_DIR/voice-server/manage.sh start

# Or manually
bun run $PAI_DIR/voice-server/server.ts &

# Verify it's running
curl http://localhost:8888/health
```

---

## Step 8: (Optional) Auto-Start on Login

### macOS (LaunchAgent)

```bash
cat > ~/Library/LaunchAgents/com.pai.voice-server.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.pai.voice-server</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/.bun/bin/bun</string>
        <string>run</string>
        <string>$PAI_DIR/voice-server/server.ts</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/pai-voice-server.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/pai-voice-server.log</string>
</dict>
</plist>
EOF

# Load the agent
launchctl load ~/Library/LaunchAgents/com.pai.voice-server.plist
```

**Note:** You'll need to replace `$HOME` and `$PAI_DIR` with actual paths in the plist file.

---

## Step 9: Verify Installation

Run the verification checklist in VERIFY.md to confirm everything works.

---

## Troubleshooting

### No Voice Output

1. Check voice server is running: `curl http://localhost:8888/health`
2. Verify API key is set in `~/.env`
3. Check logs: `tail -f /tmp/pai-voice-server.log`

### ElevenLabs Errors

| Error | Solution |
|-------|----------|
| `invalid_uid` | Remove quotes from API key in .env |
| `quota_exceeded` | Free tier exhausted (~10K chars/month) |
| `missing_permissions` | Enable TTS permission in ElevenLabs dashboard |
| `voice_not_found` | Check voice ID is correct |

### Audio Playback Issues

1. Verify `afplay` works: `afplay /System/Library/Sounds/Ping.aiff`
2. Check system volume
3. Check audio permissions in System Preferences

### Server Won't Start

1. Check port 8888 is free: `lsof -i :8888`
2. Check bun is installed: `bun --version`
3. Check for syntax errors: `bun run $PAI_DIR/voice-server/server.ts`
