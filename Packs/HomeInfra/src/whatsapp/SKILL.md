---
name: whatsapp
description: "Use when reading, sending, or managing personal WhatsApp messages. Triggers: 'check WhatsApp', 'send WhatsApp to [person]', 'read messages from [person]', 'what did X send me', 'reply to X on WhatsApp', 'my unread WhatsApp messages'."
---

# WhatsApp

## Overview

Read and send WhatsApp messages via a local whatsapp-web.js bridge running on `localhost:${WHATSAPP_BRIDGE_PORT}`.

## Setup (One-time)

```bash
cd ${WHATSAPP_BRIDGE_DIR} && npm install
```

**Start as persistent daemon (recommended):**
```bash
npm install -g pm2
pm2 start ${WHATSAPP_BRIDGE_DIR}/ecosystem.config.js
pm2 save && pm2 startup  # auto-start on login
```

**Or run manually in a terminal:**
```bash
node ${WHATSAPP_BRIDGE_DIR}/scripts/wa-bridge.js
```

On first run: scan QR with Phone → Linked Devices → Link a Device.
Session persists in `${WHATSAPP_BRIDGE_DIR}/.wwebjs_auth/` — no re-scan on restart.

---

## Step 0: Always Check Bridge First

```bash
curl -s http://localhost:${WHATSAPP_BRIDGE_PORT}/status
```

| Response | Action |
|----------|--------|
| `{"status":"ready"}` | Proceed |
| `{"status":"qr"}` | Tell user to scan QR in the bridge terminal |
| `{"status":"initializing"}` | Wait 5s, retry once |
| Connection refused | Tell user to start bridge: `pm2 start ${WHATSAPP_BRIDGE_DIR}/ecosystem.config.js` |

---

## Operations

### List unread chats

```bash
curl -s http://localhost:${WHATSAPP_BRIDGE_PORT}/unread | jq '.'
```

### Find contact / chat ID

```bash
curl -s "http://localhost:${WHATSAPP_BRIDGE_PORT}/search?query=Name" | jq '.'
```

Returns `id`, `name`, `unreadCount`, `isGroup`. Use `id` for all subsequent calls — never construct IDs manually.

### Read messages from a chat

```bash
curl -s "http://localhost:${WHATSAPP_BRIDGE_PORT}/messages?chatId=CHAT_ID&limit=20" | jq '.'
```

- Messages returned oldest-first
- `fromMe: true` = sent by user
- `time` field is ISO 8601 (human-readable); `timestamp` is raw Unix epoch
- `hasMedia: true` = media message; `body` may be empty (image/video) or caption only
- `type: "ptt"` = voice note — audio content not accessible via body
- `author` is only set in group messages (shows sender); null in direct chats

### List recent chats

```bash
curl -s "http://localhost:${WHATSAPP_BRIDGE_PORT}/chats?limit=20" | jq '.'
```

### Mark chat as read

```bash
curl -s -X POST http://localhost:${WHATSAPP_BRIDGE_PORT}/mark-read \
  -H "Content-Type: application/json" \
  -d '{"chatId":"CHAT_ID"}' | jq '.'
```

### Send a message

**ALWAYS show draft to the user and get explicit confirmation before sending.**

```bash
curl -s -X POST http://localhost:${WHATSAPP_BRIDGE_PORT}/send \
  -H "Content-Type: application/json" \
  -d '{"chatId":"CHAT_ID","message":"MESSAGE_TEXT"}' | jq '.'
```

### Reply to a specific message

```bash
curl -s -X POST http://localhost:${WHATSAPP_BRIDGE_PORT}/reply \
  -H "Content-Type: application/json" \
  -d '{"messageId":"MSG_ID","chatId":"CHAT_ID","message":"MESSAGE_TEXT"}' | jq '.'
```

---

## Quick Reference

| Goal | Command |
|------|---------|
| Bridge status | `GET /status` |
| Unread chats | `GET /unread` |
| Find chat by name | `GET /search?query=name` |
| Read messages | `GET /messages?chatId=X&limit=N` |
| All recent chats | `GET /chats?limit=N` |
| Mark as read | `POST /mark-read` `{chatId}` |
| Send | `POST /send` `{chatId, message}` |
| Reply to message | `POST /reply` `{messageId, chatId, message}` |

---

## Sending Rules

1. **Never send without explicit confirmation.** Show draft, wait for "send it" / "go ahead".
2. **Match the user's voice** — casual, direct, no fluff. Not corporate. Not overly polite.
3. **For replies:** always show the message being replied to for context.
4. **Groups:** extra caution. Confirm twice.
5. **When in doubt about tone:** ask the user before drafting.

---

## Configuration

Set in your `.env`:

```bash
WHATSAPP_BRIDGE_PORT=3210
WHATSAPP_BRIDGE_DIR=~/.pai/skills/whatsapp
```

---

## Common Issues

| Issue | Fix |
|-------|-----|
| Bridge not running | `pm2 start ${WHATSAPP_BRIDGE_DIR}/ecosystem.config.js` or run manually |
| QR needed | Phone → Linked Devices → Link a Device. Scan in bridge terminal |
| Chat not found in search | Try partial name, nickname, or first name only |
| Media message body empty | Normal — image/video content not accessible via text body |
| 503 from endpoint | Bridge not `ready` yet — check `/status` |

---

## Red Flags

- "I'll construct the chatId from the phone number" → Always use `/search`. IDs vary (`@c.us`, `@lid`, `@g.us` for groups) — never guess.
- "This is a simple send, no confirmation needed" → Always confirm. No exceptions.
- "Bridge is slow, I'll retry immediately" → Wait 5s between status polls during init.
- "I'll guess the chat name" → Search first. Multiple contacts can have similar names.
