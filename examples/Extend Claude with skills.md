---
summary: "Create, manage, and share skills to extend Claude's capabilities in Claude Code. Includes custom slash commands."
reviewed:
done:
related:
sources:
  - "https://code.claude.com/docs/en/skills"
---
Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit. Claude uses skills when relevant, or you can invoke one directly with `/skill-name`.

For built-in commands like `/help` and `/compact`, see [interactive mode](https://code.claude.com/docs/en/interactive-mode#built-in-commands).**Custom slash commands have been merged into skills.** A file at `.claude/commands/review.md` and a skill at `.claude/skills/review/SKILL.md` both create `/review` and work the same way. Your existing `.claude/commands/` files keep working. Skills add optional features: a directory for supporting files, frontmatter to [control whether you or Claude invokes them](https://code.claude.com/docs/en/#control-who-invokes-a-skill), and the ability for Claude to load them automatically when relevant.

Claude Code skills follow the [Agent Skills](https://agentskills.io/) open standard, which works across multiple AI tools. Claude Code extends the standard with additional features like [invocation control](https://code.claude.com/docs/en/#control-who-invokes-a-skill), [subagent execution](https://code.claude.com/docs/en/#run-skills-in-a-subagent), and [dynamic context injection](https://code.claude.com/docs/en/#inject-dynamic-context).

## Getting started

### Create your first skill

This example creates a skill that teaches Claude to explain code using visual diagrams and analogies. Since it uses default frontmatter, Claude can load it automatically when you ask how something works, or you can invoke it directly with `/explain-code`.

### Where skills live

Where you store a skill determines who can use it:When skills share the same name across levels, higher-priority locations win: enterprise > personal > project. Plugin skills use a `plugin-name:skill-name` namespace, so they cannot conflict with other levels. If you have files in `.claude/commands/`, those work the same way, but if a skill and a command share the same name, the skill takes precedence.

#### Automatic discovery from nested directories

When you work with files in subdirectories, Claude Code automatically discovers skills from nested `.claude/skills/` directories. For example, if you’re editing a file in `packages/frontend/`, Claude Code also looks for skills in `packages/frontend/.claude/skills/`. This supports monorepo setups where packages have their own skills.Each skill is a directory with `SKILL.md` as the entrypoint:The `SKILL.md` contains the main instructions and is required. Other files are optional and let you build more powerful skills: templates for Claude to fill in, example outputs showing the expected format, scripts Claude can execute, or detailed reference documentation. Reference these files from your `SKILL.md` so Claude knows what they contain and when to load them. See [Add supporting files](https://code.claude.com/docs/en/#add-supporting-files) for more details.

## Configure skills

Skills are configured through YAML frontmatter at the top of `SKILL.md` and the markdown content that follows.

### Types of skill content

Skill files can contain any instructions, but thinking about how you want to invoke them helps guide what to include:**Reference content** adds knowledge Claude applies to your current work. Conventions, patterns, style guides, domain knowledge. This content runs inline so Claude can use it alongside your conversation context.**Task content** gives Claude step-by-step instructions for a specific action, like deployments, commits, or code generation. These are often actions you want to invoke directly with `/skill-name` rather than letting Claude decide when to run them. Add `disable-model-invocation: true` to prevent Claude from triggering it automatically.Your `SKILL.md` can contain anything, but thinking through how you want the skill invoked (by you, by Claude, or both) and where you want it to run (inline or in a subagent) helps guide what to include. For complex skills, you can also [add supporting files](https://code.claude.com/docs/en/#add-supporting-files) to keep the main skill focused.Beyond the markdown content, you can configure skill behavior using YAML frontmatter fields between `---` markers at the top of your `SKILL.md` file:All fields are optional. Only `description` is recommended so Claude knows when to use the skill.

| Field | Required | Description |
| --- | --- | --- |
| `name` | No | Display name for the skill. If omitted, uses the directory name. Lowercase letters, numbers, and hyphens only (max 64 characters). |
| `description` | Recommended | What the skill does and when to use it. Claude uses this to decide when to apply the skill. If omitted, uses the first paragraph of markdown content. |
| `argument-hint` | No | Hint shown during autocomplete to indicate expected arguments. Example: `[issue-number]` or `[filename] [format]`. |
| `disable-model-invocation` | No | Set to `true` to prevent Claude from automatically loading this skill. Use for workflows you want to trigger manually with `/name`. Default: `false`. |
| `user-invocable` | No | Set to `false` to hide from the `/` menu. Use for background knowledge users shouldn’t invoke directly. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without asking permission when this skill is active. |
| `model` | No | Model to use when this skill is active. |
| `context` | No | Set to `fork` to run in a forked subagent context. |
| `agent` | No | Which subagent type to use when `context: fork` is set. |
| `hooks` | No | Hooks scoped to this skill’s lifecycle. See [Hooks in skills and agents](https://code.claude.com/docs/en/hooks#hooks-in-skills-and-agents) for configuration format. |

#### Available string substitutions

Skills support string substitution for dynamic values in the skill content:**Example using substitutions:**

### Add supporting files

Skills can include multiple files in their directory. This keeps `SKILL.md` focused on the essentials while letting Claude access detailed reference material only when needed. Large reference docs, API specifications, or example collections don’t need to load into context every time the skill runs.Reference supporting files from `SKILL.md` so Claude knows what each file contains and when to load it:

Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files.

### Control who invokes a skill

By default, both you and Claude can invoke any skill. You can type `/skill-name` to invoke it directly, and Claude can load it automatically when relevant to your conversation. Two frontmatter fields let you restrict this:
- **`disable-model-invocation: true`**: Only you can invoke the skill. Use this for workflows with side effects or that you want to control timing, like `/commit`, `/deploy`, or `/send-slack-message`. You don’t want Claude deciding to deploy because your code looks ready.
- **`user-invocable: false`**: Only Claude can invoke the skill. Use this for background knowledge that isn’t actionable as a command. A `legacy-system-context` skill explains how an old system works. Claude should know this when relevant, but `/legacy-system-context` isn’t a meaningful action for users to take.
This example creates a deploy skill that only you can trigger. The `disable-model-invocation: true` field prevents Claude from running it automatically:Here’s how the two fields affect invocation and context loading:

In a regular session, skill descriptions are loaded into context so Claude knows what’s available, but full skill content only loads when invoked. [Subagents with preloaded skills](https://code.claude.com/docs/en/sub-agents#preload-skills-into-subagents) work differently: the full skill content is injected at startup.

### Restrict tool access

Use the `allowed-tools` field to limit which tools Claude can use when a skill is active. This skill creates a read-only mode where Claude can explore files but not modify them:

### Pass arguments to skills

Both you and Claude can pass arguments when invoking a skill. Arguments are available via the `$ARGUMENTS` placeholder.This skill fixes a GitHub issue by number. The `$ARGUMENTS` placeholder gets replaced with whatever follows the skill name:When you run `/fix-issue 123`, Claude receives “Fix GitHub issue 123 following our coding standards…” If you invoke a skill with arguments but the skill doesn’t include `$ARGUMENTS`, Claude Code appends `ARGUMENTS: <your input>` to the end of the skill content so Claude still sees what you typed.To access individual arguments by position, use `$ARGUMENTS[N]` or the shorter `$N`:Running `/migrate-component SearchBar React Vue` replaces `$ARGUMENTS[0]` with `SearchBar`, `$ARGUMENTS[1]` with `React`, and `$ARGUMENTS[2]` with `Vue`. The same skill using the `$N` shorthand:

## Advanced patterns

### Inject dynamic context

The `!`command“ syntax runs shell commands before the skill content is sent to Claude. The command output replaces the placeholder, so Claude receives actual data, not the command itself.This skill summarizes a pull request by fetching live PR data with the GitHub CLI. The `!`gh pr diff“ and other commands run first, and their output gets inserted into the prompt:When this skill runs:
1. Each `!`command“ executes immediately (before Claude sees anything)
2. The output replaces the placeholder in the skill content
3. Claude receives the fully-rendered prompt with actual PR data
This is preprocessing, not something Claude executes. Claude only sees the final result.

To enable [extended thinking](https://code.claude.com/docs/en/common-workflows#use-extended-thinking-thinking-mode) in a skill, include the word “ultrathink” anywhere in your skill content.

### Run skills in a subagent

Add `context: fork` to your frontmatter when you want a skill to run in isolation. The skill content becomes the prompt that drives the subagent. It won’t have access to your conversation history.

`context: fork` only makes sense for skills with explicit instructions. If your skill contains guidelines like “use these API conventions” without a task, the subagent receives the guidelines but no actionable prompt, and returns without meaningful output.

Skills and [subagents](https://code.claude.com/docs/en/sub-agents) work together in two directions:With `context: fork`, you write the task in your skill and pick an agent type to execute it. For the inverse (defining a custom subagent that uses skills as reference material), see [Subagents](https://code.claude.com/docs/en/sub-agents#preload-skills-into-subagents).

#### Example: Research skill using Explore agent

This skill runs research in a forked Explore agent. The skill content becomes the task, and the agent provides read-only tools optimized for codebase exploration:When this skill runs:
1. A new isolated context is created
2. The subagent receives the skill content as its prompt (“Research $ARGUMENTS thoroughly…”)
3. The `agent` field determines the execution environment (model, tools, and permissions)
4. Results are summarized and returned to your main conversation
The `agent` field specifies which subagent configuration to use. Options include built-in agents (`Explore`, `Plan`, `general-purpose`) or any custom subagent from `.claude/agents/`. If omitted, uses `general-purpose`.

### Restrict Claude’s skill access

By default, Claude can invoke any skill that doesn’t have `disable-model-invocation: true` set. Skills that define `allowed-tools` grant Claude access to those tools without per-use approval when the skill is active. Your [permission settings](https://code.claude.com/docs/en/iam) still govern baseline approval behavior for all other tools. Built-in commands like `/compact` and `/init` are not available through the Skill tool.Three ways to control which skills Claude can invoke:**Disable all skills** by denying the Skill tool in `/permissions`:**Allow or deny specific skills** using [permission rules](https://code.claude.com/docs/en/iam):Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with any arguments.**Hide individual skills** by adding `disable-model-invocation: true` to their frontmatter. This removes the skill from Claude’s context entirely.

## Share skills

Skills can be distributed at different scopes depending on your audience:
- **Project skills**: Commit `.claude/skills/` to version control
- **Plugins**: Create a `skills/` directory in your [plugin](https://code.claude.com/docs/en/plugins)
- **Managed**: Deploy organization-wide through [managed settings](https://code.claude.com/docs/en/iam#managed-settings)

### Generate visual output

Skills can bundle and run scripts in any language, giving Claude capabilities beyond what’s possible in a single prompt. One powerful pattern is generating visual output: interactive HTML files that open in your browser for exploring data, debugging, or creating reports.This example creates a codebase explorer: an interactive tree view where you can expand and collapse directories, see file sizes at a glance, and identify file types by color.Create the Skill directory:Create `~/.claude/skills/codebase-visualizer/SKILL.md`. The description tells Claude when to activate this Skill, and the instructions tell Claude to run the bundled script:

```
---

name: codebase-visualizer

description: Generate an interactive collapsible tree visualization of your codebase. Use when exploring a new repo, understanding project structure, or identifying large files.

allowed-tools: Bash(python *)

---

# Codebase Visualizer

Generate an interactive HTML tree view that shows your project's file structure with collapsible directories.

## Usage

Run the visualization script from your project root:

\`\`\`bash

python ~/.claude/skills/codebase-visualizer/scripts/visualize.py .

\`\`\`

This creates \`codebase-map.html\` in the current directory and opens it in your default browser.

## What the visualization shows

- **Collapsible directories**: Click folders to expand/collapse

- **File sizes**: Displayed next to each file

- **Colors**: Different colors for different file types

- **Directory totals**: Shows aggregate size of each folder
```

Create `~/.claude/skills/codebase-visualizer/scripts/visualize.py`. This script scans a directory tree and generates a self-contained HTML file with:
- A **summary sidebar** showing file count, directory count, total size, and number of file types
- A **bar chart** breaking down the codebase by file type (top 8 by size)
- A **collapsible tree** where you can expand and collapse directories, with color-coded file type indicators
The script requires Python but uses only built-in libraries, so there are no packages to install:

```
#!/usr/bin/env python3

"""Generate an interactive collapsible tree visualization of a codebase."""

import json

import sys

import webbrowser

from pathlib import Path

from collections import Counter

IGNORE = {'.git', 'node_modules', '__pycache__', '.venv', 'venv', 'dist', 'build'}

def scan(path: Path, stats: dict) -> dict:

    result = {"name": path.name, "children": [], "size": 0}

    try:

        for item in sorted(path.iterdir()):

            if item.name in IGNORE or item.name.startswith('.'):

                continue

            if item.is_file():

                size = item.stat().st_size

                ext = item.suffix.lower() or '(no ext)'

                result["children"].append({"name": item.name, "size": size, "ext": ext})

                result["size"] += size

                stats["files"] += 1

                stats["extensions"][ext] += 1

                stats["ext_sizes"][ext] += size

            elif item.is_dir():

                stats["dirs"] += 1

                child = scan(item, stats)

                if child["children"]:

                    result["children"].append(child)

                    result["size"] += child["size"]

    except PermissionError:

        pass

    return result

def generate_html(data: dict, stats: dict, output: Path) -> None:

    ext_sizes = stats["ext_sizes"]

    total_size = sum(ext_sizes.values()) or 1

    sorted_exts = sorted(ext_sizes.items(), key=lambda x: -x[1])[:8]

    colors = {

        '.js': '#f7df1e', '.ts': '#3178c6', '.py': '#3776ab', '.go': '#00add8',

        '.rs': '#dea584', '.rb': '#cc342d', '.css': '#264de4', '.html': '#e34c26',

        '.json': '#6b7280', '.md': '#083fa1', '.yaml': '#cb171e', '.yml': '#cb171e',

        '.mdx': '#083fa1', '.tsx': '#3178c6', '.jsx': '#61dafb', '.sh': '#4eaa25',

    }

    lang_bars = "".join(

        f'<div class="bar-row"><span class="bar-label">{ext}</span>'

        f'<div class="bar" style="width:{(size/total_size)*100}%;background:{colors.get(ext,"#6b7280")}"></div>'

        f'<span class="bar-pct">{(size/total_size)*100:.1f}%</span></div>'

        for ext, size in sorted_exts

    )

    def fmt(b):

        if b < 1024: return f"{b} B"

        if b < 1048576: return f"{b/1024:.1f} KB"

        return f"{b/1048576:.1f} MB"

    html = f'''<!DOCTYPE html>

<html><head>

  <meta charset="utf-8"><title>Codebase Explorer</title>

  <style>

    body {{ font: 14px/1.5 system-ui, sans-serif; margin: 0; background: #1a1a2e; color: #eee; }}

    .container {{ display: flex; height: 100vh; }}

    .sidebar {{ width: 280px; background: #252542; padding: 20px; border-right: 1px solid #3d3d5c; overflow-y: auto; flex-shrink: 0; }}

    .main {{ flex: 1; padding: 20px; overflow-y: auto; }}

    h1 {{ margin: 0 0 10px 0; font-size: 18px; }}

    h2 {{ margin: 20px 0 10px 0; font-size: 14px; color: #888; text-transform: uppercase; }}

    .stat {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #3d3d5c; }}

    .stat-value {{ font-weight: bold; }}

    .bar-row {{ display: flex; align-items: center; margin: 6px 0; }}

    .bar-label {{ width: 55px; font-size: 12px; color: #aaa; }}

    .bar {{ height: 18px; border-radius: 3px; }}

    .bar-pct {{ margin-left: 8px; font-size: 12px; color: #666; }}

    .tree {{ list-style: none; padding-left: 20px; }}

    details {{ cursor: pointer; }}

    summary {{ padding: 4px 8px; border-radius: 4px; }}

    summary:hover {{ background: #2d2d44; }}

    .folder {{ color: #ffd700; }}

    .file {{ display: flex; align-items: center; padding: 4px 8px; border-radius: 4px; }}

    .file:hover {{ background: #2d2d44; }}

    .size {{ color: #888; margin-left: auto; font-size: 12px; }}

    .dot {{ width: 8px; height: 8px; border-radius: 50%; margin-right: 8px; }}

  </style>

</head><body>

  <div class="container">

    <div class="sidebar">

      <h1>📊 Summary</h1>

      <div class="stat"><span>Files</span><span class="stat-value">{stats["files"]:,}</span></div>

      <div class="stat"><span>Directories</span><span class="stat-value">{stats["dirs"]:,}</span></div>

      <div class="stat"><span>Total size</span><span class="stat-value">{fmt(data["size"])}</span></div>

      <div class="stat"><span>File types</span><span class="stat-value">{len(stats["extensions"])}</span></div>

      <h2>By file type</h2>

      {lang_bars}

    </div>

    <div class="main">

      <h1>📁 {data["name"]}</h1>

      <ul class="tree" id="root"></ul>

    </div>

  </div>

  <script>

    const data = {json.dumps(data)};

    const colors = {json.dumps(colors)};

    function fmt(b) {{ if (b < 1024) return b + ' B'; if (b < 1048576) return (b/1024).toFixed(1) + ' KB'; return (b/1048576).toFixed(1) + ' MB'; }}

    function render(node, parent) {{

      if (node.children) {{

        const det = document.createElement('details');

        det.open = parent === document.getElementById('root');

        det.innerHTML = \`<summary><span class="folder">📁 ${{node.name}}</span><span class="size">${{fmt(node.size)}}</span></summary>\`;

        const ul = document.createElement('ul'); ul.className = 'tree';

        node.children.sort((a,b) => (b.children?1:0)-(a.children?1:0) || a.name.localeCompare(b.name));

        node.children.forEach(c => render(c, ul));

        det.appendChild(ul);

        const li = document.createElement('li'); li.appendChild(det); parent.appendChild(li);

      }} else {{

        const li = document.createElement('li'); li.className = 'file';

        li.innerHTML = \`<span class="dot" style="background:${{colors[node.ext]||'#6b7280'}}"></span>${{node.name}}<span class="size">${{fmt(node.size)}}</span>\`;

        parent.appendChild(li);

      }}

    }}

    data.children.forEach(c => render(c, document.getElementById('root')));

  </script>

</body></html>'''

    output.write_text(html)

if __name__ == '__main__':

    target = Path(sys.argv[1] if len(sys.argv) > 1 else '.').resolve()

    stats = {"files": 0, "dirs": 0, "extensions": Counter(), "ext_sizes": Counter()}

    data = scan(target, stats)

    out = Path('codebase-map.html')

    generate_html(data, stats, out)

    print(f'Generated {out.absolute()}')

    webbrowser.open(f'file://{out.absolute()}')
```

To test, open Claude Code in any project and ask “Visualize this codebase.” Claude runs the script, generates `codebase-map.html`, and opens it in your browser.This pattern works for any visual output: dependency graphs, test coverage reports, API documentation, or database schema visualizations. The bundled script does the heavy lifting while Claude handles orchestration.

## Troubleshooting

### Skill not triggering

If Claude doesn’t use your skill when expected:
1. Check the description includes keywords users would naturally say
2. Verify the skill appears in `What skills are available?`
3. Try rephrasing your request to match the description more closely
4. Invoke it directly with `/skill-name` if the skill is user-invocable

### Skill triggers too often

If Claude uses your skill when you don’t want it:
1. Make the description more specific
2. Add `disable-model-invocation: true` if you only want manual invocation

### Claude doesn’t see all my skills

Skill descriptions are loaded into context so Claude knows what’s available. If you have many skills, they may exceed the character budget (default 15,000 characters). Run `/context` to check for a warning about excluded skills.To increase the limit, set the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable.
- **[Subagents](https://code.claude.com/docs/en/sub-agents)**: delegate tasks to specialized agents
- **[Plugins](https://code.claude.com/docs/en/plugins)**: package and distribute skills with other extensions
- **[Hooks](https://code.claude.com/docs/en/hooks)**: automate workflows around tool events
- **[Memory](https://code.claude.com/docs/en/memory)**: manage CLAUDE.md files for persistent context
- **[Interactive mode](https://code.claude.com/docs/en/interactive-mode#built-in-commands)**: built-in commands and shortcuts
- **[Permissions](https://code.claude.com/docs/en/iam)**: control tool and skill access

[Discover and install prebuilt plugins](https://code.claude.com/docs/en/discover-plugins) [Output styles](https://code.claude.com/docs/en/output-styles)