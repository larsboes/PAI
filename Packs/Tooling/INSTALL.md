# Tooling Pack — Installation

## Prerequisites

- bash 4+
- curl with jq
- git 2.20+
- docker (optional, for Docker skill)

## Installation

Copy `src/` contents to your skills directory:

```bash
cp -r src/* ~/.claude/skills/
# Or for pi:
# Symlink or copy to ~/.pi/cache/pai-skill-links/
```

## API Keys (Optional)

Set these for API skills:
```bash
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export GEMINI_API_KEY="..."
export GITHUB_TOKEN="ghp_..."
```

## Make Scripts Executable

```bash
find src -name "*.sh" -exec chmod +x {} \;
```
