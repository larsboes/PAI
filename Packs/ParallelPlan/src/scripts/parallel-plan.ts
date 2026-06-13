#!/usr/bin/env bun
/**
 * parallel-plan — turn a task dependency graph into a fan-out schedule.
 *
 * Given a DAG of tasks, computes:
 *   - waves      : Kahn layers — each layer's tasks can run concurrently; layers
 *                  run in sequence (a wave is, by construction, an independent set).
 *   - criticalPath: longest dependency chain via topological longest-path DP —
 *                  the floor on wall-clock no matter how many workers you have.
 *   - bottlenecks: high fan-out (unblock many → do first) and high fan-in (joins).
 *
 * Input JSON (file arg or stdin), either form:
 *   {"tasks":[{"id":"a","deps":["b"]}, {"id":"b"}]}   deps = must finish before
 *   {"edges":[["b","a"]]}                              [from, to] = from before to
 *
 *   bun parallel-plan.ts plan.json
 *   echo '{"edges":[["a","b"],["a","c"],["b","d"],["c","d"]]}' | bun parallel-plan.ts
 */
import { readFileSync } from "node:fs";

type Spec = { tasks?: { id: string; deps?: string[] }[]; edges?: [string, string][] };

function load(): Spec {
  const a = Bun.argv[2];
  const raw = !a || a === "-" ? readFileSync(0, "utf8") : readFileSync(a, "utf8");
  return JSON.parse(raw);
}

/** Build successor map (u -> tasks that depend on u) and the node set. */
function graph(spec: Spec) {
  const succ = new Map<string, Set<string>>();
  const nodes = new Set<string>();
  const link = (from: string, to: string) => {
    nodes.add(from);
    nodes.add(to);
    (succ.get(from) ?? succ.set(from, new Set()).get(from)!).add(to);
  };
  if (spec.edges) for (const [from, to] of spec.edges) link(from, to);
  else if (spec.tasks)
    for (const t of spec.tasks) {
      nodes.add(t.id);
      for (const d of t.deps ?? []) link(d, t.id);
    }
  else throw new Error("spec needs 'tasks' or 'edges'");

  const indeg = new Map<string, number>([...nodes].map((n) => [n, 0]));
  for (const outs of succ.values()) for (const v of outs) indeg.set(v, indeg.get(v)! + 1);
  return { succ, nodes, indeg };
}

/** Kahn layering: each returned layer is a set of mutually-independent tasks. */
function waves(g: ReturnType<typeof graph>): string[][] {
  const indeg = new Map(g.indeg);
  let frontier = [...g.nodes].filter((n) => indeg.get(n) === 0).sort();
  const layers: string[][] = [];
  let placed = 0;
  while (frontier.length) {
    layers.push(frontier);
    placed += frontier.length;
    const next: string[] = [];
    for (const u of frontier)
      for (const v of g.succ.get(u) ?? []) {
        indeg.set(v, indeg.get(v)! - 1);
        if (indeg.get(v) === 0) next.push(v);
      }
    frontier = next.sort();
  }
  if (placed !== g.nodes.size) throw new Error(`cycle detected — ${g.nodes.size - placed} task(s) unscheduled`);
  return layers;
}

/** Longest-path DP over the topological order the waves already give us. */
function criticalPath(g: ReturnType<typeof graph>, layers: string[][]): string[] {
  const dist = new Map<string, number>([...g.nodes].map((n) => [n, 1]));
  const prev = new Map<string, string | null>([...g.nodes].map((n) => [n, null]));
  for (const layer of layers)
    for (const u of layer)
      for (const v of g.succ.get(u) ?? [])
        if (dist.get(u)! + 1 > dist.get(v)!) {
          dist.set(v, dist.get(u)! + 1);
          prev.set(v, u);
        }
  let end = [...g.nodes][0];
  for (const [n, d] of dist) if (d > dist.get(end)!) end = n;
  const chain: string[] = [];
  for (let n: string | null = end; n; n = prev.get(n)!) chain.unshift(n);
  return chain;
}

function main(): number {
  const g = graph(load());
  if (!g.nodes.size) {
    console.log("No tasks.");
    return 0;
  }
  const layers = waves(g);
  const crit = criticalPath(g, layers);
  const edges = [...g.succ.values()].reduce((s, o) => s + o.size, 0);
  const widest = Math.max(...layers.map((l) => l.length));

  console.log("# Parallel Execution Plan\n");
  console.log(`- **Tasks**: ${g.nodes.size}  |  **Dependencies**: ${edges}  |  **Waves**: ${layers.length}  |  **Critical path**: ${crit.length} deep\n`);

  console.log("## Waves — fan out each wave together; waves run in order\n");
  layers.forEach((l, i) =>
    console.log(`- **Wave ${i + 1}** (${l.length}${l.length === widest && widest > 1 ? ", widest" : ""}): ${l.join(", ")}`),
  );
  console.log();

  console.log("## Critical path — sets the minimum number of sequential rounds\n");
  console.log("```\n" + crit.join(" → ") + "\n```\n");

  const succCount = (n: string) => g.succ.get(n)?.size ?? 0;
  const preds = new Map<string, number>([...g.nodes].map((n) => [n, 0]));
  for (const outs of g.succ.values()) for (const v of outs) preds.set(v, preds.get(v)! + 1);
  const fanOut = [...g.nodes].filter((n) => succCount(n) > 2).sort((a, b) => succCount(b) - succCount(a));
  const fanIn = [...g.nodes].filter((n) => preds.get(n)! > 2).sort((a, b) => preds.get(b)! - preds.get(a)!);
  if (fanOut.length || fanIn.length) {
    console.log("## Bottlenecks\n");
    for (const n of fanOut.slice(0, 5)) console.log(`- \`${n}\` unblocks ${succCount(n)} tasks (high fan-out — schedule first)`);
    for (const n of fanIn.slice(0, 5)) console.log(`- \`${n}\` waits on ${preds.get(n)} tasks (join point)`);
  }
  return 0;
}

process.exit(main());
