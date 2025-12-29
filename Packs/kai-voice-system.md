---
name: Kai Voice System
pack-id: danielmiessler-kai-voice-system-core-v1.0.0
version: 1.0.0
author: danielmiessler
description: Voice notification system with ElevenLabs TTS, prosody enhancement for natural speech, and agent personality-driven voice delivery
type: feature
purpose-type: [notifications, accessibility, automation]
platform: claude-code
dependencies: [kai-hook-system]
keywords: [voice, tts, elevenlabs, notifications, prosody, speech, agents, personalities, accessibility]
---

<p align="center">
  <img src="icons/kai-voice-system.png" alt="Kai Voice System" width="256">
</p>

# Kai Voice System (kai-voice-system)

> Voice notification system with natural speech synthesis and personality-driven delivery

## Why This Is Different

This sounds similar to basic text-to-speech tools like macOS's say command, which also read text aloud. What makes this approach different?

Basic TTS reads everything literally—code blocks, markdown syntax, technical artifacts. The Kai Voice System applies prosody enhancement before speech: bold text gets emphasis, ellipses create pauses, emotional markers adjust tone. It intelligently summarizes code blocks instead of reading them verbatim. Different agent personalities use different voices. The result is natural speech that sounds like a colleague reporting, not a screen reader monotonously parsing text.

- Prosody enhancement adds natural pauses and emphasis automatically
- Code blocks summarized instead of read character by character
- Agent personalities map to distinct ElevenLabs voice IDs
- Graceful degradation works silently when server is offline

---

## Installation Prompt

You are receiving a PAI Pack - a modular upgrade for AI agent systems.

**What is PAI?** See: [PAI Project Overview](../README.md#what-is-pai)

**What is a Pack?** See: [Pack System](../README.md#pack-system)

This Pack adds voice notifications to your AI infrastructure. The Kai Voice System provides:

- **Spoken Notifications**: Hear task completions via ElevenLabs text-to-speech
- **Prosody Enhancement**: Natural speech patterns with emotional markers
- **Agent Personalities**: Different voices for different agent types
- **Intelligent Cleaning**: Strips code blocks and artifacts for clean speech
- **Graceful Degradation**: Works silently when voice server is offline

**Core principle:** Your AI should speak to you, not just display text.

When tasks complete, you hear the results. When agents finish work, they announce themselves. This transforms AI from a silent tool into an audible assistant.

Please follow the installation instructions below to integrate this Pack into your infrastructure.

---

## The Concept and/or Problem

AI agents complete work constantly, but you only know if you're watching the screen:

- Tasks finish while you're in another window
- Background agents complete research you need to review
- Errors happen silently without notification
- Multi-hour operations give no status updates

**The Text-Only Problem:**

Traditional AI interfaces are entirely visual. You must:
- Watch the terminal for completions
- Monitor multiple windows for agent outputs
- Manually check status periodically
- Parse dense text output for results

**The Opportunity:**

Voice transforms AI interaction:
- Hear completions anywhere in the room
- Get status updates while doing other work
- Know immediately when things complete or fail
- Different agent voices indicate who's reporting

**Beyond Basic TTS:**

Simple text-to-speech sounds robotic. Real voice needs:
- Prosody: **bold** words get emphasis, `...` creates pauses
- Emotion: Success sounds different from warnings
- Personality: Different agents have different voices
- Intelligence: Code blocks are summarized, not read verbatim

---

## The Solution

The Kai Voice System provides natural-sounding voice output:

**Core Architecture:**

```
~/.config/pai/
├── hooks/
│   ├── stop-hook-voice.ts           # Main agent voice notification
│   ├── subagent-stop-hook-voice.ts  # Subagent voice notification
│   └── lib/
│       └── prosody-enhancer.ts      # Prosody and emotion enhancement
├── config/
│   └── voice-personalities.json     # Agent voice configurations
└── settings.json                    # Hook configuration
```

**Notification Server Pattern:**

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   Stop Hook     │ ───► │  Voice Server    │ ───► │   ElevenLabs    │
│ (extracts msg)  │      │  (localhost:8888)│      │   (TTS API)     │
└─────────────────┘      └──────────────────┘      └─────────────────┘
```

**Prosody Enhancement:**

| Input | Output | Effect |
|-------|--------|--------|
| `**fixed** the bug` | `[✨ success] **fixed** the bug!` | Emphasis + emotion |
| `found the issue... finally` | As-is | Natural pause preserved |
| `CRITICAL error in auth` | `[🚨 urgent] **CRITICAL** error in auth` | Urgency marker |
| `\`\`\`code block\`\`\`` | `code block` | Stripped for speech |

**Agent Voice Mapping:**

| Agent Type | Voice Archetype | Speaking Rate | Stability |
|------------|-----------------|---------------|-----------|
| Main (Kai) | Enthusiast | 235 wpm | 0.38 |
| Intern | High-energy | 270 wpm | 0.30 |
| Engineer | Wise leader | 212 wpm | 0.72 |
| Architect | Academic | 205 wpm | 0.75 |
| Researcher | Analyst | 229-240 wpm | 0.55-0.64 |
| Designer | Perfectionist | 226 wpm | 0.52 |
| Artist | Creative | 215 wpm | 0.20 |
| Pentester | Chaotic | 260 wpm | 0.18 |

---

## Installation

### Prerequisites

- **Bun runtime**: `curl -fsSL https://bun.sh/install | bash`
- **ElevenLabs API key**: Sign up at [elevenlabs.io](https://elevenlabs.io)
- **kai-hook-system Pack**: Install foundation hooks first
- **Voice notification server**: Local HTTP server at port 8888

### Step 1: Create Directory Structure

```bash
# Create directories (if not already from hook-system)
mkdir -p ~/.config/pai/hooks/lib
mkdir -p ~/.config/pai/config

# Verify
ls -la ~/.config/pai/hooks/
```

---

### Step 2: Create Voice Configuration

Create the voice personality configuration file:

```json
// ~/.config/pai/config/voice-personalities.json
{
  "default_rate": 175,
  "notification_server": "http://localhost:8888/notify",
  "voices": {
    "kai": {
      "voice_id": "${ELEVENLABS_VOICE_KAI}",
      "name": "Kai",
      "rate_wpm": 235,
      "stability": 0.38,
      "similarity_boost": 0.70,
      "archetype": "enthusiast",
      "description": "Expressive eager buddy: genuinely excited to help"
    },
    "engineer": {
      "voice_id": "${ELEVENLABS_VOICE_ENGINEER}",
      "name": "Engineer",
      "rate_wpm": 212,
      "stability": 0.72,
      "similarity_boost": 0.88,
      "archetype": "wise-leader",
      "description": "Battle-scarred leader: thinks in years not sprints"
    },
    "architect": {
      "voice_id": "${ELEVENLABS_VOICE_ARCHITECT}",
      "name": "Architect",
      "rate_wpm": 205,
      "stability": 0.75,
      "similarity_boost": 0.88,
      "archetype": "wise-leader",
      "description": "Academic wisdom: sees timeless patterns vs trends"
    },
    "intern": {
      "voice_id": "${ELEVENLABS_VOICE_INTERN}",
      "name": "Intern",
      "rate_wpm": 270,
      "stability": 0.30,
      "similarity_boost": 0.65,
      "archetype": "enthusiast",
      "description": "Brilliant overachiever: brain races ahead"
    },
    "designer": {
      "voice_id": "${ELEVENLABS_VOICE_DESIGNER}",
      "name": "Designer",
      "rate_wpm": 226,
      "stability": 0.52,
      "similarity_boost": 0.84,
      "archetype": "critic",
      "description": "Design school perfectionist: exacting standards"
    },
    "researcher": {
      "voice_id": "${ELEVENLABS_VOICE_RESEARCHER}",
      "name": "Researcher",
      "rate_wpm": 229,
      "stability": 0.64,
      "similarity_boost": 0.90,
      "archetype": "analyst",
      "description": "Strategic thinker: sees three moves ahead"
    },
    "pentester": {
      "voice_id": "${ELEVENLABS_VOICE_PENTESTER}",
      "name": "Pentester",
      "rate_wpm": 260,
      "stability": 0.18,
      "similarity_boost": 0.85,
      "archetype": "enthusiast",
      "description": "Reformed grey hat: giddy finding vulnerabilities"
    },
    "artist": {
      "voice_id": "${ELEVENLABS_VOICE_ARTIST}",
      "name": "Artist",
      "rate_wpm": 215,
      "stability": 0.20,
      "similarity_boost": 0.52,
      "archetype": "enthusiast",
      "description": "Aesthetic anarchist: follows invisible beauty threads"
    },
    "default": {
      "voice_id": "${ELEVENLABS_VOICE_DEFAULT}",
      "name": "Default",
      "rate_wpm": 220,
      "stability": 0.50,
      "similarity_boost": 0.75,
      "archetype": "professional",
      "description": "Balanced professional delivery"
    }
  }
}
```

**Note:** Replace `${ELEVENLABS_VOICE_*}` with your actual ElevenLabs voice IDs, or set them as environment variables.

---

### Step 3: Create Prosody Enhancer Library

```typescript
// ~/.config/pai/hooks/lib/prosody-enhancer.ts
// Enhances voice output with emotional markers and natural speech patterns

export interface AgentPersonality {
  name: string;
  rate_wpm: number;
  stability: number;
  archetype: 'enthusiast' | 'professional' | 'analyst' | 'critic' | 'wise-leader';
  energy_level: 'chaotic' | 'expressive' | 'measured' | 'stable';
}

export interface ProsodyConfig {
  emotionalMarkers: boolean;
  markdownProsody: boolean;
  personalityEnhancement: boolean;
  contextAnalysis: boolean;
}

/**
 * Agent personality configurations
 */
const AGENT_PERSONALITIES: Record<string, AgentPersonality> = {
  'kai': {
    name: 'Kai',
    rate_wpm: 235,
    stability: 0.38,
    archetype: 'professional',
    energy_level: 'expressive'
  },
  'intern': {
    name: 'Intern',
    rate_wpm: 270,
    stability: 0.30,
    archetype: 'enthusiast',
    energy_level: 'chaotic'
  },
  'pentester': {
    name: 'Pentester',
    rate_wpm: 260,
    stability: 0.18,
    archetype: 'enthusiast',
    energy_level: 'chaotic'
  },
  'artist': {
    name: 'Artist',
    rate_wpm: 215,
    stability: 0.20,
    archetype: 'enthusiast',
    energy_level: 'chaotic'
  },
  'designer': {
    name: 'Designer',
    rate_wpm: 226,
    stability: 0.52,
    archetype: 'critic',
    energy_level: 'measured'
  },
  'engineer': {
    name: 'Engineer',
    rate_wpm: 212,
    stability: 0.72,
    archetype: 'wise-leader',
    energy_level: 'stable'
  },
  'architect': {
    name: 'Architect',
    rate_wpm: 205,
    stability: 0.75,
    archetype: 'wise-leader',
    energy_level: 'stable'
  },
  'researcher': {
    name: 'Researcher',
    rate_wpm: 229,
    stability: 0.64,
    archetype: 'analyst',
    energy_level: 'measured'
  }
};

/**
 * Content patterns for detecting emotional context
 */
const CONTENT_PATTERNS = {
  // High Energy / Positive
  excited: [
    /\b(breakthrough|discovered|found it|eureka|amazing|incredible)\b/i,
    /\b(wait wait|ooh|wow|check this|look at this)\b/i,
    /!{2,}|💥|🔥|⚡/
  ],
  celebration: [
    /\b(finally|at last|phew|we did it|victory)\b/i,
    /\b(all .* passing|zero errors|zero (data )?loss)\b/i,
    /🎉|🥳|🍾/
  ],
  insight: [
    /\b(wait|aha|I see|that'?s why|now I understand)\b/i,
    /\b(this explains|the real issue|actually)\b/i,
    /💡|🔦/
  ],

  // Success / Achievement
  success: [
    /\b(completed|finished|done|success|working|fixed|resolved|solved)\b/i,
    /\b(all tests? pass|deploy|ship|launch)\b/i,
    /✅|✨/
  ],
  progress: [
    /\b(phase .* complete|step .* done)\b/i,
    /\b(moving to|now|next|partial|incremental)\b/i,
    /📈|⏩/
  ],

  // Analysis / Investigation
  investigating: [
    /\b(analyzing|examining|investigating|tracing)\b/i,
    /\b(pattern detected|correlation|cross-referencing)\b/i,
    /🔍|🔬|📊/
  ],
  debugging: [
    /\b(bug|error|issue|problem)\b/i,
    /\b(tracking|hunting|found it|located)\b/i,
    /🐛|🔧/
  ],

  // Thoughtful / Careful
  caution: [
    /\b(warning|careful|slow|partial|incomplete)\b/i,
    /\b(needs review|check|verify)\b/i,
    /⚠️|⚡/
  ],

  // Urgent / Critical
  urgent: [
    /\b(urgent|critical|down|failing|broken|alert)\b/i,
    /\b(immediate|asap|now|quickly|emergency)\b/i,
    /🚨|❌|⛔/
  ]
};

/**
 * Detect emotional context from message content
 */
function detectEmotionalContext(message: string): string | null {
  // Check for existing emotional markers
  if (/\[(💥|✨|⚠️|🚨|🎉|💡|🤔|🔍|📈|🎯|🎨|🐛|📚)/.test(message)) {
    return null; // Already has marker
  }

  const priorityOrder = [
    'urgent', 'debugging', 'insight', 'celebration', 'excited',
    'investigating', 'progress', 'success', 'caution'
  ];

  for (const emotion of priorityOrder) {
    const patterns = CONTENT_PATTERNS[emotion as keyof typeof CONTENT_PATTERNS];
    if (patterns) {
      for (const pattern of patterns) {
        if (pattern.test(message)) {
          return emotion;
        }
      }
    }
  }

  return null;
}

/**
 * Get emotional marker for detected emotion
 */
function getEmotionalMarker(emotion: string): string {
  const markers: Record<string, string> = {
    'excited': '[💥 excited]',
    'celebration': '[🎉 celebration]',
    'insight': '[💡 insight]',
    'success': '[✨ success]',
    'progress': '[📈 progress]',
    'investigating': '[🔍 investigating]',
    'debugging': '[🐛 debugging]',
    'caution': '[⚠️ caution]',
    'urgent': '[🚨 urgent]'
  };

  return markers[emotion] || '';
}

/**
 * Add personality-specific prosody patterns
 */
function addPersonalityProsody(message: string, personality: AgentPersonality): string {
  let enhanced = message;

  switch (personality.archetype) {
    case 'enthusiast':
      if (personality.energy_level === 'chaotic') {
        if (!/\.{3}/.test(enhanced) && Math.random() > 0.5) {
          enhanced = enhanced.replace(/\b(wait|found|check|look)\b/i, '$1...');
        }
        if (!/[!?]$/.test(enhanced)) {
          enhanced = enhanced.replace(/\.$/, '!');
        }
      }
      break;

    case 'wise-leader':
      if (personality.energy_level === 'stable') {
        if (/,/.test(enhanced)) {
          enhanced = enhanced.replace(/,\s+/, ' -- ');
        }
      }
      break;

    case 'professional':
      if (personality.energy_level === 'expressive') {
        if (!/\*\*/.test(enhanced)) {
          enhanced = enhanced.replace(
            /\b(completed|fixed|deployed|built|created|found)\b/i,
            '**$1**'
          );
        }
      }
      break;

    case 'analyst':
      enhanced = enhanced.replace(
        /\b(confirmed|verified|analyzed|discovered)\b/i,
        '**$1**'
      );
      break;
  }

  return enhanced;
}

/**
 * Main prosody enhancement function
 */
export function enhanceProsody(
  message: string,
  agentType: string,
  config: ProsodyConfig = {
    emotionalMarkers: true,
    markdownProsody: true,
    personalityEnhancement: true,
    contextAnalysis: true
  }
): string {
  let enhanced = message;

  const personality = AGENT_PERSONALITIES[agentType.toLowerCase()] ||
                     AGENT_PERSONALITIES['kai'];

  // 1. Context Analysis - Detect emotional context
  if (config.contextAnalysis && config.emotionalMarkers) {
    const emotion = detectEmotionalContext(enhanced);
    if (emotion) {
      const marker = getEmotionalMarker(emotion);
      if (marker) {
        enhanced = `${marker} ${enhanced}`;
      }
    }
  }

  // 2. Personality Enhancement
  if (config.personalityEnhancement && config.markdownProsody) {
    enhanced = addPersonalityProsody(enhanced, personality);
  }

  return enhanced.trim();
}

/**
 * Clean message for speech while preserving prosody
 */
export function cleanForSpeech(message: string): string {
  let cleaned = message;

  // Remove code blocks and inline code
  cleaned = cleaned.replace(/```[\s\S]*?```/g, 'code block');
  cleaned = cleaned.replace(/`[^`]+`/g, '');

  // Strip loose emoji while preserving markers
  const parts: Array<{isMarker: boolean, text: string}> = [];
  let lastIndex = 0;
  const markerRegex = /\[[^\]]+\]/g;
  let match: RegExpExecArray | null;

  while ((match = markerRegex.exec(cleaned)) !== null) {
    if (match.index > lastIndex) {
      parts.push({
        isMarker: false,
        text: cleaned.substring(lastIndex, match.index)
      });
    }
    parts.push({
      isMarker: true,
      text: match[0]
    });
    lastIndex = match.index + match[0].length;
  }

  if (lastIndex < cleaned.length) {
    parts.push({
      isMarker: false,
      text: cleaned.substring(lastIndex)
    });
  }

  if (parts.length === 0) {
    parts.push({
      isMarker: false,
      text: cleaned
    });
  }

  // Strip emoji from non-marker parts only
  cleaned = parts.map(part => {
    if (part.isMarker) {
      return part.text;
    } else {
      return part.text.replace(/\p{Emoji_Presentation}/gu, '');
    }
  }).join('');

  // Clean up whitespace
  cleaned = cleaned.replace(/\s+/g, ' ');

  return cleaned.trim();
}

/**
 * Get the voice ID for an agent type
 */
export function getVoiceId(agentType: string): string {
  // Read from environment or config file
  const envKey = `ELEVENLABS_VOICE_${agentType.toUpperCase()}`;
  const envVoice = process.env[envKey];
  if (envVoice) {
    return envVoice;
  }

  // Fallback to default
  return process.env.ELEVENLABS_VOICE_DEFAULT || '';
}
```

---

### Step 4: Create Voice-Enabled Stop Hook

```typescript
#!/usr/bin/env bun
// ~/.config/pai/hooks/stop-hook-voice.ts
// Main agent voice notification with prosody enhancement

import { readFileSync } from 'fs';
import { enhanceProsody, cleanForSpeech, getVoiceId } from './lib/prosody-enhancer';

interface NotificationPayload {
  title: string;
  message: string;
  voice_enabled: boolean;
  priority?: 'low' | 'normal' | 'high';
  voice_id: string;
}

interface HookInput {
  session_id: string;
  transcript_path: string;
  hook_event_name: string;
}

/**
 * Convert Claude content to plain text
 */
function contentToText(content: unknown): string {
  if (typeof content === 'string') return content;
  if (Array.isArray(content)) {
    return content
      .map(c => {
        if (typeof c === 'string') return c;
        if (c?.text) return c.text;
        if (c?.content) return contentToText(c.content);
        return '';
      })
      .join(' ')
      .trim();
  }
  return '';
}

/**
 * Extract completion message with prosody enhancement
 */
function extractCompletion(text: string, agentType: string = 'kai'): string {
  // Remove system-reminder tags
  text = text.replace(/<system-reminder>[\s\S]*?<\/system-reminder>/g, '');

  // Look for COMPLETED section
  const patterns = [
    /🎯\s*\*{0,2}COMPLETED:?\*{0,2}\s*(.+?)(?:\n|$)/i,
    /\*{0,2}COMPLETED:?\*{0,2}\s*(.+?)(?:\n|$)/i
  ];

  for (const pattern of patterns) {
    const match = text.match(pattern);
    if (match && match[1]) {
      let completed = match[1].trim();

      // Clean agent tags
      completed = completed.replace(/^\[AGENT:\w+\]\s*/i, '');

      // Clean for speech
      completed = cleanForSpeech(completed);

      // Enhance with prosody
      completed = enhanceProsody(completed, agentType);

      return completed;
    }
  }

  return 'Completed task';
}

/**
 * Read last assistant message from transcript
 */
function getLastAssistantMessage(transcriptPath: string): string {
  try {
    const content = readFileSync(transcriptPath, 'utf-8');
    const lines = content.trim().split('\n');

    let lastAssistantMessage = '';

    for (const line of lines) {
      if (line.trim()) {
        try {
          const entry = JSON.parse(line);
          if (entry.type === 'assistant' && entry.message?.content) {
            const text = contentToText(entry.message.content);
            if (text) {
              lastAssistantMessage = text;
            }
          }
        } catch {
          // Skip invalid JSON lines
        }
      }
    }

    return lastAssistantMessage;
  } catch (error) {
    console.error('Error reading transcript:', error);
    return '';
  }
}

/**
 * Send notification to voice server
 */
async function sendNotification(payload: NotificationPayload): Promise<void> {
  const serverUrl = process.env.PAI_VOICE_SERVER || 'http://localhost:8888/notify';

  try {
    const response = await fetch(serverUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      console.error('Voice server error:', response.statusText);
    }
  } catch (error) {
    // Fail silently - voice server may not be running
    console.error('Voice notification failed (server may be offline):', error);
  }
}

async function main() {
  let hookInput: HookInput | null = null;

  try {
    const decoder = new TextDecoder();
    const reader = Bun.stdin.stream().getReader();
    let input = '';

    const timeoutPromise = new Promise<void>((resolve) => {
      setTimeout(() => resolve(), 500);
    });

    const readPromise = (async () => {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        input += decoder.decode(value, { stream: true });
      }
    })();

    await Promise.race([readPromise, timeoutPromise]);

    if (input.trim()) {
      hookInput = JSON.parse(input);
    }
  } catch (error) {
    console.error('Error reading hook input:', error);
  }

  // Extract completion from transcript
  let completion = 'Completed task';
  const agentType = 'kai'; // Main agent is always Kai

  if (hookInput?.transcript_path) {
    const lastMessage = getLastAssistantMessage(hookInput.transcript_path);
    if (lastMessage) {
      completion = extractCompletion(lastMessage, agentType);
    }
  }

  // Get voice ID for this agent
  const voiceId = getVoiceId(agentType);

  // Send voice notification
  const payload: NotificationPayload = {
    title: 'Kai',
    message: completion,
    voice_enabled: true,
    priority: 'normal',
    voice_id: voiceId
  };

  await sendNotification(payload);

  process.exit(0);
}

main().catch((error) => {
  console.error('Stop hook error:', error);
  process.exit(0);
});
```

---

### Step 5: Create Subagent Voice Hook

```typescript
#!/usr/bin/env bun
// ~/.config/pai/hooks/subagent-stop-hook-voice.ts
// Subagent voice notification with personality-specific delivery

import { readFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { readdirSync, statSync } from 'fs';
import { enhanceProsody, cleanForSpeech, getVoiceId } from './lib/prosody-enhancer';

interface NotificationPayload {
  title: string;
  message: string;
  voice_enabled: boolean;
  voice_id: string;
}

async function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function findTaskResult(transcriptPath: string, maxAttempts: number = 2): Promise<{
  result: string | null;
  agentType: string | null;
  description: string | null;
}> {
  let actualTranscriptPath = transcriptPath;

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    if (attempt > 0) {
      await delay(200);
    }

    if (!existsSync(actualTranscriptPath)) {
      const dir = dirname(transcriptPath);
      if (existsSync(dir)) {
        const files = readdirSync(dir)
          .filter(f => f.startsWith('agent-') && f.endsWith('.jsonl'))
          .map(f => ({ name: f, mtime: statSync(join(dir, f)).mtime }))
          .sort((a, b) => b.mtime.getTime() - a.mtime.getTime());

        if (files.length > 0) {
          actualTranscriptPath = join(dir, files[0].name);
        }
      }

      if (!existsSync(actualTranscriptPath)) {
        continue;
      }
    }

    try {
      const transcript = readFileSync(actualTranscriptPath, 'utf-8');
      const lines = transcript.trim().split('\n');

      for (let i = lines.length - 1; i >= 0; i--) {
        try {
          const entry = JSON.parse(lines[i]);

          if (entry.type === 'assistant' && entry.message?.content) {
            for (const content of entry.message.content) {
              if (content.type === 'tool_use' && content.name === 'Task') {
                const toolInput = content.input;
                const description = toolInput?.description || null;

                for (let j = i + 1; j < lines.length; j++) {
                  const resultEntry = JSON.parse(lines[j]);
                  if (resultEntry.type === 'user' && resultEntry.message?.content) {
                    for (const resultContent of resultEntry.message.content) {
                      if (resultContent.type === 'tool_result' && resultContent.tool_use_id === content.id) {
                        let taskOutput: string;
                        if (typeof resultContent.content === 'string') {
                          taskOutput = resultContent.content;
                        } else if (Array.isArray(resultContent.content)) {
                          taskOutput = resultContent.content
                            .filter((item: any) => item.type === 'text')
                            .map((item: any) => item.text)
                            .join('\n');
                        } else {
                          continue;
                        }

                        const agentType = toolInput?.subagent_type || 'default';
                        return { result: taskOutput, agentType, description };
                      }
                    }
                  }
                }
              }
            }
          }
        } catch (e) {
          // Skip invalid lines
        }
      }
    } catch (e) {
      // Will retry
    }
  }

  return { result: null, agentType: null, description: null };
}

function extractCompletionMessage(taskOutput: string): { message: string | null; agentType: string | null } {
  // Look for COMPLETED section with agent tag
  const agentPatterns = [
    /🎯\s*COMPLETED:\s*\[AGENT:(\w+[-\w]*)\]\s*(.+?)(?:\n|$)/is,
    /COMPLETED:\s*\[AGENT:(\w+[-\w]*)\]\s*(.+?)(?:\n|$)/is,
    /🎯.*COMPLETED.*\[AGENT:(\w+[-\w]*)\]\s*(.+?)(?:\n|$)/is,
  ];

  for (const pattern of agentPatterns) {
    const match = taskOutput.match(pattern);
    if (match && match[1] && match[2]) {
      const agentType = match[1].toLowerCase();
      let message = match[2].trim();

      // Clean for speech
      message = cleanForSpeech(message);

      // Enhance with prosody
      message = enhanceProsody(message, agentType);

      // Format: "AgentName completed [message]"
      const agentName = agentType.charAt(0).toUpperCase() + agentType.slice(1);

      // Don't prepend "completed" for greetings or questions
      const isGreeting = /^(hey|hello|hi|greetings)/i.test(message);
      const isQuestion = message.includes('?');

      const fullMessage = (isGreeting || isQuestion)
        ? message
        : `${agentName} completed ${message}`;

      return { message: fullMessage, agentType };
    }
  }

  // Fallback patterns
  const genericPatterns = [
    /🎯\s*COMPLETED:\s*(.+?)(?:\n|$)/i,
    /COMPLETED:\s*(.+?)(?:\n|$)/i,
  ];

  for (const pattern of genericPatterns) {
    const match = taskOutput.match(pattern);
    if (match && match[1]) {
      let message = match[1].trim();
      message = cleanForSpeech(message);

      if (message.length > 5) {
        return { message, agentType: null };
      }
    }
  }

  return { message: null, agentType: null };
}

async function sendNotification(payload: NotificationPayload): Promise<void> {
  const serverUrl = process.env.PAI_VOICE_SERVER || 'http://localhost:8888/notify';

  try {
    const response = await fetch(serverUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      console.error('Voice server error:', response.statusText);
    }
  } catch (error) {
    // Fail silently
  }
}

async function main() {
  let input = '';
  try {
    const decoder = new TextDecoder();
    const reader = Bun.stdin.stream().getReader();

    const timeoutPromise = new Promise<void>((resolve) => {
      setTimeout(() => resolve(), 500);
    });

    const readPromise = (async () => {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        input += decoder.decode(value, { stream: true });
      }
    })();

    await Promise.race([readPromise, timeoutPromise]);
  } catch (e) {
    process.exit(0);
  }

  if (!input) {
    process.exit(0);
  }

  let transcriptPath: string;
  try {
    const parsed = JSON.parse(input);
    transcriptPath = parsed.transcript_path;
  } catch (e) {
    process.exit(0);
  }

  if (!transcriptPath) {
    process.exit(0);
  }

  // Find task result
  const { result: taskOutput, agentType } = await findTaskResult(transcriptPath);

  if (!taskOutput) {
    process.exit(0);
  }

  // Extract completion message
  const { message: completionMessage, agentType: extractedAgentType } = extractCompletionMessage(taskOutput);

  if (!completionMessage) {
    process.exit(0);
  }

  // Determine agent type
  const finalAgentType = extractedAgentType || agentType || 'default';

  // Get voice ID for this agent type
  const voiceId = getVoiceId(finalAgentType);

  // Send voice notification
  const agentName = finalAgentType.charAt(0).toUpperCase() + finalAgentType.slice(1);

  await sendNotification({
    title: agentName,
    message: completionMessage,
    voice_enabled: true,
    voice_id: voiceId
  });

  process.exit(0);
}

main().catch(console.error);
```

---

### Step 6: Register Hooks

Add voice hooks to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bun run ~/.config/pai/hooks/stop-hook-voice.ts"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bun run ~/.config/pai/hooks/subagent-stop-hook-voice.ts"
          }
        ]
      }
    ]
  }
}
```

---

### Step 7: Set Environment Variables

Add to your shell profile (`~/.zshrc`, `~/.bashrc`):

```bash
# Voice configuration
export PAI_VOICE_SERVER="http://localhost:8888/notify"

# ElevenLabs voice IDs (get these from your ElevenLabs account)
export ELEVENLABS_API_KEY="your-api-key"
export ELEVENLABS_VOICE_KAI="your-kai-voice-id"
export ELEVENLABS_VOICE_DEFAULT="your-default-voice-id"
# Add more as needed for other agent types

# Reload
source ~/.zshrc
```

---

### Step 8: Voice Server (Required Dependency)

The voice system requires a notification server at port 8888. This server:
- Receives notification payloads via HTTP POST
- Calls ElevenLabs API for TTS
- Plays audio output

**Basic server pattern:**

```typescript
// Example voice server structure (implement your own)
Bun.serve({
  port: 8888,
  async fetch(req) {
    if (req.method === 'POST' && req.url.includes('/notify')) {
      const payload = await req.json();

      // Call ElevenLabs API
      const audioResponse = await fetch(
        `https://api.elevenlabs.io/v1/text-to-speech/${payload.voice_id}`,
        {
          method: 'POST',
          headers: {
            'xi-api-key': process.env.ELEVENLABS_API_KEY,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            text: payload.message,
            voice_settings: {
              stability: 0.5,
              similarity_boost: 0.75
            }
          })
        }
      );

      // Play audio (platform-specific)
      const audioBuffer = await audioResponse.arrayBuffer();
      // ... play audio using afplay (macOS), aplay (Linux), etc.

      return new Response('OK');
    }

    return new Response('Not found', { status: 404 });
  }
});
```

**Note:** A full voice server implementation is beyond this Pack's scope. You can:
- Build your own using the pattern above
- Use an existing notification server
- Adapt to your preferred TTS provider

---

### Step 9: Verify Installation

```bash
# 1. Check hook files exist
ls -la ~/.config/pai/hooks/*voice*.ts
# Should show: stop-hook-voice.ts, subagent-stop-hook-voice.ts

# 2. Check prosody enhancer exists
ls -la ~/.config/pai/hooks/lib/prosody-enhancer.ts

# 3. Check voice config exists
ls -la ~/.config/pai/config/voice-personalities.json

# 4. Test prosody enhancer
echo 'import { enhanceProsody } from "./lib/prosody-enhancer"; console.log(enhanceProsody("fixed the bug", "kai"))' | \
  bun run -

# 5. Test notification (if voice server is running)
curl -X POST http://localhost:8888/notify \
  -H "Content-Type: application/json" \
  -d '{"message":"Test notification","voice_enabled":true,"title":"Test"}'

# 6. Restart Claude Code to activate hooks
```

---

## Voice Personality System

### Archetypes

| Archetype | Energy | Voice Characteristics |
|-----------|--------|----------------------|
| **Enthusiast** | Chaotic/Expressive | Fast, variable, exclamatory |
| **Professional** | Expressive | Balanced, warm, emphasis on actions |
| **Analyst** | Measured | Confident, findings-focused |
| **Critic** | Measured | Precise, sophisticated, deliberate |
| **Wise Leader** | Stable | Slow, thoughtful, em-dashes for pauses |

### Prosody Elements

| Element | Example | Effect |
|---------|---------|--------|
| `**bold**` | `**fixed** the bug` | Emphasis |
| `...` | `wait... found it` | Pause |
| `--` | `Consider this -- the implications` | Thoughtful break |
| `!` | `Success!` | Excitement |
| `[marker]` | `[✨ success]` | Emotional context |

### Emotional Markers

| Marker | Trigger | Use |
|--------|---------|-----|
| `[💥 excited]` | breakthroughs | High energy |
| `[✨ success]` | completions | Achievement |
| `[🎉 celebration]` | milestones | Victory |
| `[💡 insight]` | discoveries | Realization |
| `[🔍 investigating]` | analysis | Research |
| `[🐛 debugging]` | bug work | Problem solving |
| `[⚠️ caution]` | warnings | Careful |
| `[🚨 urgent]` | critical | Emergency |

---

## Configuration

**Environment Variables:**

| Variable | Default | Purpose |
|----------|---------|---------|
| `PAI_VOICE_SERVER` | `http://localhost:8888/notify` | Voice server URL |
| `ELEVENLABS_API_KEY` | - | ElevenLabs API key |
| `ELEVENLABS_VOICE_*` | - | Voice IDs per agent type |

**Graceful Degradation:**

If the voice server is offline:
- Hooks complete silently (exit 0)
- No errors shown to user
- Work continues uninterrupted

---

## Credits

- **Original concept**: Daniel Miessler - developed as part of Kai personal AI infrastructure
- **ElevenLabs**: Text-to-speech engine
- **Prosody research**: ElevenLabs eleven_turbo_v2_5 emotional marker support

## Works Well With

- **kai-hook-system**: Foundation for voice hooks (required)
- **kai-history-system**: Captures work for voice summaries
- **kai-skill-system**: Skills can trigger voice notifications

## Recommended

- **kai-hook-system**: Required dependency - install first

## Relationships

### Parent Of
None

### Child Of
- **kai-hook-system**: Voice hooks depend on hook system foundation

### Sibling Of
- **kai-history-system**: Both use Stop/SubagentStop hooks

### Part Of Collection
- **The Official PAI (Kai) Bundle**: Core Packs for personal AI infrastructure

---

## Changelog

### 1.0.0 - 2025-12-29
- Initial release
- Prosody enhancement library with 9 emotional markers
- Voice-enabled stop hooks for main and subagents
- Agent personality voice mapping system
- ElevenLabs integration pattern
- Graceful degradation when voice server offline
