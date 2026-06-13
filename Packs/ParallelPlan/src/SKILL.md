---
name: ParallelPlan
description: "Turn a task dependency graph into a concrete parallel execution plan — compute the critical path (longest dependency chains that gate total time), execution waves (which tasks can run concurrently once their deps finish), fully independent groups safe to fan out, and bottleneck nodes (high fan-out/fan-in). Deterministic graph analysis, no LLM. USE WHEN parallelize tasks, what can run in parallel, execution order, critical path, dependency graph, task scheduling, which agents to fan out, batch plan, topological order, bottleneck tasks, parallel plan. NOT FOR spawning the agents themselves (use Delegation) — this PLANS the fan-out; Delegation executes it."
allowed-tools: Bash, Read
---

# ParallelPlan — plan the fan-out before you delegate

A deterministic companion to the **Delegation** skill (which is upstream and unmodified). Delegation *executes* parallel work; ParallelPlan *decides the shape of it*: given how tasks depend on each other, it tells you exactly which can run together, which chain is the bottleneck, and in what order to release work.

Use it before any multi-task fan-out (agent teams, parallel Forge instances, multi-file refactors with ordering, build/migration steps) so you parallelize the safe parts and serialize only the real dependencies.

## Input

A JSON DAG, via file or stdin, in either form:

```json
{ "tasks": [ {"id": "schema", "deps": []},
             {"id": "api", "deps": ["schema"]},
             {"id": "ui",  "deps": ["api"]},
             {"id": "docs","deps": ["api"]} ] }
```
```json
{ "edges": [ ["schema","api"], ["api","ui"], ["api","docs"] ] }   // [from, to] = from before to
```

## Usage

```bash
bun scripts/parallel-plan.ts plan.json
echo '{"edges":[["a","b"],["a","c"],["b","d"],["c","d"]]}' | bun scripts/parallel-plan.ts
```

## Output

A Markdown plan:
- **Execution waves** — run each wave's tasks in parallel; waves run in sequence. This is the fan-out schedule: Wave 1 → fan out all of it, wait, Wave 2, … (widest wave flagged).
- **Critical path** — the longest dependency chains; these set the floor on total wall-clock no matter how many agents you have.
- **Independent groups** — sets with no path between members, always safe to run concurrently.
- **Bottlenecks** — high fan-out nodes (unblock many — do first) and high fan-in nodes (join points).

Cycles are reported as an error (a real DAG has none).

## How it maps to Delegation
- Each **wave** → one batch of parallel `Agent`/Task spawns; barrier between waves.
- **Critical path** length → the minimum number of sequential rounds, regardless of agent count.
- **Bottleneck (fan-out)** tasks → schedule first to maximize downstream parallelism.

## Rules
- This only plans — it spawns nothing. Hand the waves to **Delegation** to execute.
- Garbage in, garbage out: the plan is only as good as the stated `deps`. Omitted dependencies produce unsafe parallelism.

## Supporting files
- `scripts/parallel-plan.ts` — Kahn-wave layering + topological longest-path critical path + bottleneck analysis (Bun, no deps).
