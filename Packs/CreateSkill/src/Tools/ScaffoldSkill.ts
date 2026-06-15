#!/usr/bin/env bun
/**
 * ScaffoldSkill.ts — Scaffold a new PAI skill directory and files.
 *
 * Usage:
 *   bun run ScaffoldSkill.ts --name "MySkill" --location "project" --depth "skill+workflows+scripts" --description "Syncs notes" --triggers "sync notes, update obsidian"
 *
 * Fallback:
 *   If arguments are missing, starts an interactive CLI wizard that prompts the user
 *   and dynamically recommends the appropriate skill depth.
 */

import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { join } from 'path';
import { homedir } from 'os';
import * as readline from 'readline';

function formatSkillName(rawName: string): string {
  if (rawName.startsWith('_')) {
    // Private: _ALLCAPS (keep underscores, convert alphanumeric to uppercase)
    return '_' + rawName.slice(1).toUpperCase().replace(/[^A-Z0-9_]/g, '_').replace(/__+/g, '_');
  }
  // Public: TitleCase (PascalCase, remove all non-alphanumeric chars)
  return rawName
    .replace(/[^a-zA-Z0-9\s-_]/g, '')
    .replace(/[-_]/g, ' ')
    .split(/\s+/)
    .filter(Boolean)
    .map(w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
    .join('');
}

function parseArgs() {
  const args = process.argv.slice(2);
  const params: Record<string, string> = {
    name: '',
    location: '',
    depth: '',
    description: '',
    triggers: ''
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg.startsWith('--')) {
      const key = arg.slice(2);
      const val = args[i + 1];
      if (val && !val.startsWith('--')) {
        params[key] = val;
        i++;
      }
    }
  }

  return params;
}

function askQuestion(query: string): Promise<string> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  return new Promise(resolve => rl.question(query, answer => {
    rl.close();
    resolve(answer.trim());
  }));
}

function recommendDepth(name: string, description: string): string {
  const text = `${name} ${description}`.toLowerCase();
  
  if (text.match(/deploy|build|run|script|cli|command|tool|sync|fetch|scrape/)) {
    return 'skill+workflows+scripts';
  }
  if (text.match(/rules|style|documentation|guide|api|reference|cheat|context/)) {
    return 'skill+references';
  }
  return 'skill+workflows';
}

async function runScaffold(params: {
  name: string;
  location: string;
  depth: string;
  description: string;
  triggers: string;
}) {
  const formattedName = formatSkillName(params.name);
  const location = params.location.toLowerCase();
  const depthStr = params.depth.toLowerCase();
  const descText = params.description || `Custom skill for ${formattedName}`;
  const triggersText = params.triggers || formattedName.toLowerCase();

  // Resolve base directory
  let baseDir: string;
  if (location === 'global') {
    baseDir = join(homedir(), '.claude', 'skills');
  } else if (location === 'project') {
    baseDir = join(process.cwd(), '.claude', 'skills');
  } else {
    console.error('❌ Error: Location must be "global" or "project".');
    process.exit(1);
  }

  const skillPath = join(baseDir, formattedName);

  // Check if target folder already exists (Anti: do not delete or overwrite)
  if (existsSync(skillPath)) {
    console.error(`❌ Error: Skill directory already exists at ${skillPath}. Scaffold blocked to prevent accidental overwrite.`);
    process.exit(1);
  }

  console.log(`\n🔨 Scaffolding new skill "${formattedName}" at: ${skillPath}`);

  // Create base dir
  mkdirSync(skillPath, { recursive: true });

  const hasWorkflows = depthStr.includes('workflows') || depthStr.includes('all');
  const hasScripts = depthStr.includes('scripts') || depthStr.includes('tools') || depthStr.includes('all');
  const hasReferences = depthStr.includes('references') || depthStr.includes('all');

  // 1. Scaffold SKILL.md
  let skillMdContent = `---
name: ${formattedName}
description: "${descText}. USE WHEN user asks to ${triggersText}."
---

# ${formattedName}

${descText}

## Customization

**Before executing, check for user customizations at:**
\`~/.claude/PAI/USER/SKILLCUSTOMIZATIONS/${formattedName}/\`

If this directory exists, load and apply any PREFERENCES.md, configurations, or resources found there. These override default behavior. If the directory does not exist, proceed with skill defaults.

`;

  if (hasWorkflows) {
    skillMdContent += `## Voice Notification

**When executing a workflow, do BOTH:**

1. **Send voice notification**:
   \`\`\`bash
   curl -s -X POST http://localhost:31337/notify \\
     -H "Content-Type: application/json" \\
     -d '{"message": "Running the WORKFLOWNAME workflow in the ${formattedName} skill to ACTION"}' \\
     > /dev/null 2>&1 &
   \`\`\`

2. **Output text notification**:
   \`\`\`
   Running the **WorkflowName** workflow in the **${formattedName}** skill to ACTION...
   \`\`\`

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **SampleWorkflow** | "${triggersText}" | \`Workflows/SampleWorkflow.md\` |

`;
  }

  skillMdContent += `## Examples

**Example 1: Basic execution**
\`\`\`
User: "${triggersText}"
`;
  if (hasWorkflows) {
    skillMdContent += `→ Invokes SampleWorkflow workflow\n`;
  }
  skillMdContent += `→ Performs task successfully
→ Returns confirmation to user
\`\`\`

## Gotchas
- Always verify path presence before execution.
`;

  if (hasReferences) {
    skillMdContent += `\n## References
- Detailed instructions: \`References/UsageReference.md\`
`;
  }

  writeFileSync(join(skillPath, 'SKILL.md'), skillMdContent);
  console.log('  ✓ Created SKILL.md');

  // 2. Create subdirs and templates
  if (hasWorkflows) {
    const workflowsPath = join(skillPath, 'Workflows');
    mkdirSync(workflowsPath, { recursive: true });
    
    const sampleWorkflowContent = `# SampleWorkflow Workflow

This workflow executes sample task for ${formattedName}.

## Voice Notification

\`\`\`bash
curl -s -X POST http://localhost:31337/notify \\
  -H "Content-Type: application/json" \\
  -d '{"message": "Running SampleWorkflow workflow in the ${formattedName} skill"}' \\
  > /dev/null 2>&1 &
\`\`\`

Running the **SampleWorkflow** workflow in the **${formattedName}** skill...

## Steps

1. Read current repository context.
2. Formulate execution plan.
3. Perform the task.
`;
    writeFileSync(join(workflowsPath, 'SampleWorkflow.md'), sampleWorkflowContent);
    console.log('  ✓ Created Workflows/SampleWorkflow.md');
  }

  if (hasScripts) {
    const toolsPath = join(skillPath, 'Tools');
    mkdirSync(toolsPath, { recursive: true });
    
    const sampleToolContent = `/**
 * SampleTool.ts — CLI logic helper for ${formattedName}
 */
import { argv } from 'process';

console.log("Running ${formattedName} sample script tool!");
console.log("Arguments passed:", argv.slice(2));
`;
    writeFileSync(join(toolsPath, 'SampleTool.ts'), sampleToolContent);
    console.log('  ✓ Created Tools/SampleTool.ts');
  }

  if (hasReferences) {
    const refsPath = join(skillPath, 'References');
    mkdirSync(refsPath, { recursive: true });
    
    const sampleRefContent = `# Usage Reference for ${formattedName}

Detailed reference material and gotchas for using the ${formattedName} skill.

## Advanced Usage
Configure environment variables or settings to control behavior.
`;
    writeFileSync(join(refsPath, 'UsageReference.md'), sampleRefContent);
    console.log('  ✓ Created References/UsageReference.md');
  }

  console.log(`\n🎉 Success! New skill "${formattedName}" has been scaffolded.`);
}

async function main() {
  const params = parseArgs();

  // If missing args, run interactive wizard
  if (!params.name || !params.location || !params.depth) {
    console.log('✨ Welcome to the PAI Skill Scaffolder Wizard ✨\n');

    let name = params.name;
    while (!name) {
      name = await askQuestion('👉 Enter Skill Name (e.g. "MySkill" or "_MY_PRIVATE_SKILL"): ');
      if (!name) console.log('⚠️ Name is required.');
    }

    let location = params.location;
    while (location !== 'global' && location !== 'project') {
      const ans = await askQuestion('👉 Where should the skill live? [global/project] (default: project): ');
      location = ans.toLowerCase() || 'project';
      if (location !== 'global' && location !== 'project') {
        console.log('⚠️ Please enter either "global" or "project".');
      }
    }

    const description = await askQuestion('👉 Enter Description (what the skill does): ') || `Custom skill for ${name}`;
    const triggers = await askQuestion('👉 Enter Triggers (keywords, e.g. "sync notes, compile code"): ') || name.toLowerCase();

    // Dynamically recommend depth based on inputs
    const recommended = recommendDepth(name, description);
    console.log(`\n💡 Recommended depth for this skill: "${recommended}"`);

    let depth = params.depth;
    while (!depth) {
      const ans = await askQuestion(`👉 Enter depth [skill | skill+workflows | skill+scripts | skill+references | all] (default: ${recommended}): `);
      depth = ans.toLowerCase() || recommended;
    }

    await runScaffold({ name, location, depth, description, triggers });
  } else {
    // Non-interactive CLI mode
    await runScaffold({
      name: params.name,
      location: params.location,
      depth: params.depth,
      description: params.description,
      triggers: params.triggers
    });
  }
}

main().catch(err => {
  console.error('❌ Exception occurred:', err);
  process.exit(1);
});
