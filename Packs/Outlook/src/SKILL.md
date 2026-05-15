---
name: outlook
description: "Use when reading, searching, sending, or managing Outlook emails from WSL via COM bridge. Works in restricted corporate environments without API keys. USE WHEN outlook, email, send email, read email, search email, reply, forward, email attachment, corporate email, WSL outlook."
---

# Outlook Skill

Read, search, send, reply, and manage Outlook emails via COM bridge (WSL → Windows).

## Architecture

```
WSL (pi/bash) → powershell.exe → Outlook COM → Exchange/O365
```

No API keys. No admin consent. Piggybacks on the running Outlook session.
**Requirement:** Outlook must be running on Windows.

## Script

```bash
OUTLOOK="{baseDir}/scripts/outlook.sh"
```

## Commands

### Search emails

```bash
$OUTLOOK search                                    # Latest 10 from Inbox
$OUTLOOK search -Subject "Project Update" -Limit 5        # Subject contains
$OUTLOOK search -Sender "Andreas" -Limit 3        # Sender name contains
$OUTLOOK search -UnreadOnly 1                     # Unread only
$OUTLOOK search -FromDate "2026-02-01" -ToDate "2026-02-20"  # Date range
$OUTLOOK search -Folder "Sent"                     # Different folder
$OUTLOOK search -Folder "Company/Team"        # Subfolder by path
$OUTLOOK search -Subject "report" -Sender "Alice" -UnreadOnly 1 -Limit 5  # Combined
```

**Output:** JSON with `count`, `folder`, and `emails[]` array. Each email has:
`id`, `subject`, `sender`, `senderEmail`, `to`, `cc`, `date`, `unread`, `importance`, `hasAttachments`, `attachments[]`

### Read full email

```bash
$OUTLOOK read -Id "<entryID>"              # Full body (plain text)
$OUTLOOK read -Id "<entryID>" -Html 1      # Include HTML body too
```

**Output:** Same as search item + `body` (plain text) and optionally `bodyHtml`.

### Send email

```bash
$OUTLOOK send -To "someone@example.com" -Subject "Hello" -Body "Message body"
$OUTLOOK send -To "a@t.de; b@t.de" -Cc "c@t.de" -Subject "FYI" -Body "See below"
$OUTLOOK send -To "a@t.de" -Subject "Report" -Body "Attached." -Attachments "C:\path\file.pdf"
$OUTLOOK send -To "a@t.de" -Subject "HTML" -BodyHtml "<h1>Hello</h1><p>World</p>"
```

Use `\n` for newlines in body text. Multiple attachments: comma-separated Windows paths.

### Reply / Reply All

```bash
$OUTLOOK reply -Id "<entryID>" -Body "Thanks, noted."
$OUTLOOK reply -Id "<entryID>" -Body "Agreed." -ReplyAll 1
```

### Forward

```bash
$OUTLOOK forward -Id "<entryID>" -To "colleague@example.com" -Body "FYI see below"
```

### List folders

```bash
$OUTLOOK folders
```

**Output:** JSON with `folders[]` — each has `name`, `path`, `count`, `unread`, `depth`.

### Save attachments

```bash
$OUTLOOK save-attachment -Id "<entryID>" -SavePath /tmp/attachments    # All attachments
$OUTLOOK save-attachment -Id "<entryID>" -SavePath /tmp -AttachmentIndex 1  # Specific one
```

The `-SavePath` is auto-converted from WSL to Windows paths by the wrapper.

### Mark read/unread

```bash
$OUTLOOK mark-read -Id "<entryID>"
$OUTLOOK mark-unread -Id "<entryID>"
```

## Folder Names

Built-in mappings (use English or German):

| Alias | Folder |
|-------|--------|
| `Inbox`, `Posteingang` | Inbox |
| `Sent`, `SentMail` | Sent Items |
| `Drafts`, `Entwuerfe` | Drafts |
| `Deleted`, `Trash` | Deleted Items |
| `Junk`, `Spam` | Junk Email |
| `Outbox`, `Postausgang` | Outbox |
| `Calendar`, `Kalender` | Calendar |
| `Tasks`, `Aufgaben` | Tasks |

For custom folders, use the path from `folders` output: `-Folder "Company/Team"`

## Common Workflows

### Morning email check
```bash
# Unread count + latest unread
$OUTLOOK search -UnreadOnly 1 -Limit 20
```

### Find and read specific email
```bash
# Search
$OUTLOOK search -Subject "project report" -Sender "Alice" -Limit 5
# Read (copy id from search results)
$OUTLOOK read -Id "<entryID>"
```

### Quick reply
```bash
# Search → read → reply in one flow
$OUTLOOK reply -Id "<entryID>" -Body "Thanks Alice, I will prepare the document by Friday."
```

### Download attachments
```bash
$OUTLOOK save-attachment -Id "<entryID>" -SavePath /tmp/downloads
ls /tmp/downloads/  # Files are now in WSL
```

## Tips

- **Boolean flags** use `1`/`0`: `-UnreadOnly 1`, `-ReplyAll 1`, `-Html 1` (PowerShell switch params don't pass cleanly from bash)
- **EntryIDs are long** — always copy from search results, never type manually
- **Outlook must be running** — the COM bridge connects to the live process
- **Attachments paths**: `-Attachments` for send needs Windows paths (`C:\...`). `-SavePath` auto-converts WSL paths.
- **German folder names**: The folder list from `folders` shows actual names. Use exact matches.
- **DASL filters**: Subject/Sender searches are case-insensitive `LIKE '%term%'`
- **Date format**: `yyyy-MM-dd` (e.g., `2026-02-20`)
- **Multiple recipients**: Semicolon-separated (`"a@t.de; b@t.de"`)

## When to Use

- Searching/reading corporate Outlook emails from WSL
- Sending emails or replies without leaving the terminal
- Downloading email attachments to WSL
- Automated email workflows (check + summarize + respond)
- Any email task in a restricted corporate environment where Graph API isn't available

## Red Flags & Common Mistakes

- **Outlook not running** — COM bridge requires a live Outlook process on Windows. If you get "Cannot connect to Outlook", check that it's open.
- **Stale COM connection** — If Outlook was restarted, the COM object may be stale. Re-run the command to reconnect.
- **EntryID reuse** — EntryIDs can change if an email is moved between folders. Always search fresh before acting on an ID.
- **Attachment paths** — `-Attachments` for `send` needs Windows paths (`C:\...`). `-SavePath` for `save-attachment` auto-converts WSL paths.
- **Large result sets** — Don't set `-Limit` above ~50. COM iteration is sequential and slow on large sets.
- **Sending on behalf** — COM sends as the logged-in user. No impersonation or shared mailbox support without extra config.
- **HTML body pitfall** — `-Body` and `-BodyHtml` are mutually exclusive. If both are set, HTML wins.
