# Obsidian Skill Integrations

Cross-skill workflows that combine obsidian-vault with other skills for powerful workflows.

## With `/dev-workflow`

**Pattern:** Research phase → Daily note

```
dev-workflow creates PRD
 ↓
obsidian-vault searches for related work ("system design notes", "prior research")
 ↓
daily note imported into dev-workflow context
 ↓
planning phase uses your own insights
```

**Command:**
```bash
/dev-workflow
# When at research phase, call:
/obsidian-vault search "my notes on this topic"
```

## With `/brainstorm`

**Pattern:** Use vault as context for brainstorming

```
You: "Brainstorm ideas for my next project"
 ↓
/brainstorm is primed
 ↓
Search vault for related notes and interests
 ↓
brainstorm with real context instead of guesses
```

## With `gmail` / `google-calendar`

**Pattern:** Knowledge system synced with external life

```
Calendar event → obsidian-vault search for related work
Email thread → capture decision/insight → obsidian-vault link
```

**Future:** Could auto-sync calendar events + vault notes.

## Suggested Workflows

### Morning Briefing
```bash
# Combine multiple sources
1. gccli list today's calendar
2. obsidian-vault daily (open today's note)
3. brainstorm: "What matters today?"
```

### Project Deep Dive
```bash
# When starting project work
1. obsidian-vault search "project name" (find prior work)
2. /dev-workflow with vault context loaded
```
