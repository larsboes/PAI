---
name: research
description: Multi-source comprehensive research using perplexity-researcher, claude-researcher, and gemini-researcher agents. Launches up to 10 parallel research agents for fast results. USE WHEN user says 'do research', 'research X', 'find information about', 'investigate', 'analyze trends', 'current events', or any research-related request.
---

# Research Skill

## When to Use This Skill

This skill activates when the user requests research or information gathering:
- "Do research on X"
- "Research this topic"
- "Find information about X"
- "Investigate this subject"
- "Analyze trends in X"
- "Current events research"
- Any comprehensive information gathering request

## How to Execute

### Step 1: Decompose the Research Question

Break the user's query into 3-10 specific sub-questions that cover different aspects:
- Core facts and definitions
- Recent developments
- Expert opinions
- Contrarian viewpoints
- Practical applications

### Step 2: Launch Parallel Research Agents

Use the Task tool to launch multiple researcher agents **in parallel** (single message with multiple Task calls):

```
Task: perplexity-researcher - "Research question 1"
Task: claude-researcher - "Research question 2"
Task: gemini-researcher - "Research question 3"
...
```

### Step 3: Synthesize Results

Collect all agent responses and create a comprehensive report:
- Merge overlapping findings
- Note areas of consensus and disagreement
- Include confidence levels
- Cite sources from each agent

## Available Research Agents

Check `~/.claude/agents/` for agents with "researcher" in their name:
- `perplexity-researcher` - Web search specialist
- `claude-researcher` - Deep analysis
- `gemini-researcher` - Multi-perspective research

## Speed Benefits

- ❌ **Old approach**: Sequential searches → 5-10 minutes
- ✅ **New approach**: 10 parallel agents → Under 1 minute

## Example Usage

```
User: "Research the current state of AI agents in 2025"

AI: [Launches 5 parallel Task calls]
- Task: perplexity-researcher - "What are the leading AI agent frameworks in 2025?"
- Task: claude-researcher - "How do autonomous AI agents handle multi-step tasks?"
- Task: gemini-researcher - "What are the main limitations of current AI agents?"
- Task: perplexity-researcher - "Recent breakthroughs in AI agent architectures"
- Task: claude-researcher - "Enterprise adoption of AI agents - current trends"
```
