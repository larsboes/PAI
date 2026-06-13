#!/usr/bin/env bun
// GraphifyNudge.hook.ts — PreToolUse(Bash). When a graphify graph exists in the
// current project, nudge toward `graphify query/explain/affected` instead of
// grep/find/rg/fd. No-op otherwise.
//
// OPT-IN: this is not auto-registered. To activate, copy/deploy it to
// ${PAI_DIR}/hooks/ (e.g. via ./sync-hooks.sh) and add one PreToolUse entry —
// see INSTALL.md "graph-first nudge hook".
import { existsSync } from "node:fs";

const raw = await Bun.stdin.text();
let cmd = "";
try {
  const data = JSON.parse(raw);
  cmd = String(data?.tool_input?.command ?? data?.command ?? "");
} catch {
  process.exit(0);
}

// Only fire for search tools, and only when a graph actually exists in CWD.
if (!/(^|\s)(grep|rg|find|fd)\s/.test(cmd)) process.exit(0);
if (!existsSync("graphify-out/graph.json")) process.exit(0);

const additionalContext =
  "graphify: a code graph exists at graphify-out/graph.json. For how-it-works / " +
  "what-calls-X / what-depends-on-X questions, prefer it over grep: " +
  '`bash ~/.claude/skills/graphify/Tools/graphify.sh query "<q>"` (also explain / affected / path). ' +
  "Skim graphify-out/GRAPH_REPORT.md for god nodes & communities. Literal string search via grep is still fine.";

console.log(
  JSON.stringify({
    hookSpecificOutput: { hookEventName: "PreToolUse", additionalContext },
  }),
);
