---
name: Integrations
pack-id: pai-integrations-v1.0.0
version: 1.0.0
author: larsboes
description: Service integrations — Google CLI tools, GitHub, Notion, Obsidian vault, and Zotero citations
type: skill
purpose-type: [integration, google, github, obsidian, zotero, notion]
platform: claude-code
dependencies: []
keywords: [obsidian, zotero, gmail, calendar, drive, github, notion, vault, citations]
---

# Integrations

> Service integrations — connect AI sessions to Google Workspace, GitHub, Notion, Obsidian, and Zotero.

---

## The Problem

Knowledge and communication lives across multiple tools. Without integrations, AI sessions can't access emails, calendars, files, vault notes, or citation libraries.

---

## The Solution

Integrations provides 7 skills connecting to external services:

| Skill | What It Does |
|-------|-------------|
| **gmcli** | Gmail: search, read threads, send, manage drafts, labels, attachments |
| **gccli** | Google Calendar: list/create/update events, check availability |
| **gdcli** | Google Drive: list, search, upload, download, share |
| **github** | GitHub via gh CLI: PRs, reviews, releases, CI management |
| **notion** | Notion: read pages, write content, query databases |
| **obsidian** | Obsidian vault: fast keyword search, backlinks, UI control, vault health |
| **zotero** | Zotero citation library: search, metadata, full-text from PDFs |

---

## Quick Start

```
"Install the Integrations pack from PAI/Packs/Integrations/"
```
