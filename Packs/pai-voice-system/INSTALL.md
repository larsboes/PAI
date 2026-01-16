# PAI Voice System - Installation Guide

## Prerequisites

### Required Packs (Install First)

> **STOP:** Before installing this pack, ensure you have installed:
> 1. **pai-hook-system** - Event-driven automation foundation
> 2. **pai-core-install** - Core identity, skills, and memory system
>
> These are required for this pack to function properly.

### System Requirements

- **macOS** (tested on macOS 11+)
- **Bun runtime**: `curl -fsSL https://bun.sh/install | bash`
- **ElevenLabs API key** (optional - falls back to macOS say)

---

## Pre-Installation: System Analysis

### Step 0.1: Detect Current Configuration

```bash
# 1. Check for existing voice server
if [ -d "$HOME/.claude/VoiceServer" ]; then
  echo "WARNING: VoiceServer directory already exists"
  ls -la "$HOME/.claude/VoiceServer"
else
  echo "Clean install - no existing VoiceServer"
fi

# 2. Check if port 8888 is in use
if lsof -i :8888 > /dev/null 2>&1; then
  echo "WARNING: Port 8888 is already in use"
  lsof -i :8888
else
  echo "Port 8888 is available"
fi

# 3. Check for existing LaunchAgent
if [ -f "$HOME/Library/LaunchAgents/com.pai.voice-server.plist" ]; then
  echo "WARNING: LaunchAgent already exists"
else
  echo "No existing LaunchAgent"
fi

# 4. Check ElevenLabs configuration
if [ -f "$HOME/.env" ] && grep -q "ELEVENLABS_API_KEY=" "$HOME/.env"; then
  echo "ElevenLabs API key found in ~/.env"
else
  echo "No ElevenLabs API key - will use macOS say fallback"
fi
```

### Step 0.2: Conflict Resolution Matrix

| Scenario | Existing State | Action |
|----------|---------------|--------|
| **Clean Install** | No VoiceServer directory | Proceed to Step 1 |
| **Upgrade** | Existing VoiceServer | Backup, then replace |
| **Port Conflict** | Port 8888 in use | Stop existing process first |
| **Existing Service** | LaunchAgent exists | Unload before install |

### Step 0.3: Backup Existing Configuration (If Needed)

```bash
if [ -d "$HOME/.claude/VoiceServer" ]; then
  BACKUP_DIR="$HOME/.pai-backup/voice-server-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  cp -r "$HOME/.claude/VoiceServer" "$BACKUP_DIR/"
  echo "Backed up to: $BACKUP_DIR"
fi
```

---

## Step 1: Create Directory Structure

```bash
mkdir -p $HOME/.claude/VoiceServer/{menubar,macos-service,logs}
```

---

## Step 2: Copy Voice Server Files

Copy the contents of `src/VoiceServer/` to `~/.claude/VoiceServer/`:

```bash
# From the pack directory, copy all files:
cp -r src/VoiceServer/* $HOME/.claude/VoiceServer/

# Make scripts executable
chmod +x $HOME/.claude/VoiceServer/*.sh
chmod +x $HOME/.claude/VoiceServer/menubar/*.sh
```

---

## Step 3: Configure ElevenLabs (Optional)

Add your ElevenLabs API key to `~/.env`:

```bash
# Get your free API key at https://elevenlabs.io
echo "ELEVENLABS_API_KEY=your_api_key_here" >> ~/.env

# Optionally set a default voice
echo "ELEVENLABS_VOICE_ID=bIHbv24MWmeRgasZH58o" >> ~/.env
```

**Without an API key**, the voice server will use macOS's built-in `say` command.

---

## Step 4: Install the Service

Run the installation script:

```bash
cd $HOME/.claude/VoiceServer
./install.sh
```

This will:
1. Install dependencies
2. Create a macOS LaunchAgent for auto-start
3. Start the voice server on port 8888
4. Verify the installation
5. Optionally install menu bar indicator

---

## Step 5: Verify Installation

```bash
# Check server status
./status.sh

# Test with a notification
curl -X POST http://localhost:8888/notify \
  -H "Content-Type: application/json" \
  -d '{"message": "Voice server installed successfully"}'

# Check health endpoint
curl http://localhost:8888/health
```

**Expected output from health:**
```json
{
  "status": "healthy",
  "port": 8888,
  "voice_system": "ElevenLabs",
  "api_key_configured": true
}
```

---

## Management Commands

| Command | Purpose |
|---------|---------|
| `./start.sh` | Start the voice server |
| `./stop.sh` | Stop the voice server |
| `./restart.sh` | Restart the voice server |
| `./status.sh` | Check server status and configuration |
| `./uninstall.sh` | Remove the service (keeps files) |

---

## Optional: Menu Bar Indicator

Install the menu bar indicator for quick status and controls:

```bash
# Requires SwiftBar or BitBar
brew install --cask swiftbar  # or bitbar

# Install the menu bar plugin
cd $HOME/.claude/VoiceServer/menubar
./install-menubar.sh
```

---

## Troubleshooting

### Server won't start

```bash
# Check if port 8888 is already in use
lsof -i :8888

# Kill any existing process
lsof -ti :8888 | xargs kill -9

# Restart
./restart.sh
```

### No voice output

```bash
# Check API key configuration
grep ELEVENLABS_API_KEY ~/.env

# Check server logs
tail -f ~/Library/Logs/pai-voice-server.log

# Test with macOS say (fallback)
say "Testing voice output"
```

### Service not auto-starting

```bash
# Check LaunchAgent status
launchctl list | grep pai.voice

# Reload LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.pai.voice-server.plist
launchctl load ~/Library/LaunchAgents/com.pai.voice-server.plist
```

---

## Integration with Hooks

To have your DA speak on task completion, add to your Stop hook:

```typescript
// In your stop hook
await fetch('http://localhost:8888/notify', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    message: "Task completed successfully",
    voice_id: "bIHbv24MWmeRgasZH58o",
    title: "PAI Assistant"
  })
});
```

---

## File Locations

| File | Purpose |
|------|---------|
| `~/.claude/VoiceServer/server.ts` | Main server code |
| `~/.claude/VoiceServer/voices.json` | Voice personality configuration |
| `~/.env` | API key configuration |
| `~/Library/LaunchAgents/com.pai.voice-server.plist` | macOS service definition |
| `~/Library/Logs/pai-voice-server.log` | Server logs |
