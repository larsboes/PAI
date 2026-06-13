---
name: VerifyClaims
description: "Self-check generated documentation against real source code — extract every factual claim (file paths, symbol/class/function names, dependency mentions) from a doc and verify each one actually resolves in the codebase, then report an accuracy %% and list the unresolved claims (likely hallucinations). Deterministic, no LLM. USE WHEN verify claims, fact-check doc, check citations, did I hallucinate, accuracy check, verify documentation, do these files exist, validate generated docs, citation check, hallucination check, verify before delivering. NOT FOR prose quality/style review; NOT FOR running tests (use the test runner) or building (use the build)."
allowed-tools: Bash, Read
---

# VerifyClaims — does the doc match the code?

A deterministic guard for any artifact that *describes a codebase* (architecture overviews, READMEs, migration notes, research summaries, onboarding docs). It extracts the doc's verifiable claims and checks each against the real source tree — catching the failure mode LLM-generated docs are prone to: confidently citing files and symbols that don't exist.

**Run it as a "verify before deliver" pass** whenever you (or another skill: Research, Knowledge, Documents, Architecture) produce a doc grounded in code.

## What counts as a claim

The checker (`scripts/verify-claims.ts`) extracts and verifies:
- **File paths** — any `` `path/to/file.ext` `` (a trailing `:line` is stripped before checking).
- **Symbols** — `` `SomethingService` `` / `` `UserController` `` (conventional suffixes), `` `funcName(` `` calls, and "depends on / calls / imports / uses `X`" mentions.

Glob patterns, version strings, and common English/tech noise words are ignored.

## Usage

```bash
# one doc against the current repo
bun scripts/verify-claims.ts ARCHITECTURE.md

# a directory of docs against a specific source root, custom extensions
bun scripts/verify-claims.ts docs/ --source ../myrepo --ext .ts,.py --samples 80

# fail the run (exit 1) below 90% accuracy
bun scripts/verify-claims.ts overview.md --min 90
```

No third-party deps — Bun only.

## Output

A Markdown report: claims checked, verified/failed counts, **accuracy %**, the unresolved claims grouped by source doc (with line numbers), and a verdict (`✓ reliable ≥95%` / `⚠️ review 80–95%` / `✗ regenerate <80%`). Exit code is `0` at/above `--min` (default 80), else `1` — so it can gate a pipeline.

## Rules

- This verifies **existence**, not correctness of behavior — a file/symbol existing doesn't mean the doc's *description* of it is right. Treat a high score as "no fabricated references," not "fully accurate."
- A low score on a legitimately abstract doc may mean it lacks concrete references — say so rather than forcing claims.
- Deterministic and read-only; never edits the doc or the source.

## Supporting files
- `scripts/verify-claims.ts` — the extractor + verifier (Bun, no deps). READ/run for every check.
