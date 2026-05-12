# `.pai-fork/` — Upstream Sync System

> **Goal:** Stay current with [danielmiessler/Personal_AI_Infrastructure](https://github.com/danielmiessler/Personal_AI_Infrastructure) without losing our customizations.

## Mental model

This isn't a "merge two branches" workflow — it's **vendor + customize**:

1. **Daniel's upstream is source of truth.** Default behavior is "always take Daniel's version."
2. **Our customizations are explicit.** They're declared in [`manifest.yaml`](manifest.yaml) with a reason.
3. **Conflicts are loud, not silent.** When upstream changes a file we customize, sync.sh backs ours up and writes a `REPORT.md`. Reintegration is a separate, manual step.
4. **Pristine reference always available.** `~/Developer/PAI-upstream/` worktree mirrors `upstream/main` so you can always read Daniel's version without checkout-dance.

## Files

| File | Purpose |
|---|---|
| `manifest.yaml` | Files we override. Updates trigger backup-on-collision. |
| `exclusions.yaml` | Paths sync NEVER touches (custom packs, fork-only files). |
| `last-synced.ref` | Upstream SHA we synced to last. |
| `backups/` | Per-sync snapshots: `{ts}_upstream-{sha7}/` with `REPORT.md` + saved files. |
| `git-hooks/pre-commit` | Catches unmanifested edits + auto-regens `Packs/INVENTORY.md`. |
| `tools/sync.sh` | Main entry: `status`, `apply`, `report`, `rollback`, `lint`. |
| `tools/add-customization.sh` | Append a path + reason to manifest. |
| `tools/reintegrate.sh` | Walk a backup, decide per-file: keep upstream / restore ours / edit. |
| `tools/install-hooks.sh` | Wire `git-hooks/` via repo-local `core.hooksPath`. |
| `tools/generate-inventory.sh` | Walks `Packs/`, emits `Packs/INVENTORY.md`. |
| `tools/merge-driver.sh` | 3-way merge driver for `git merge` workflows. |

## Daily / weekly workflow

```bash
# Check what changed upstream (read-only)
.pai-fork/tools/sync.sh status

# Pull upstream + auto-backup any collisions
.pai-fork/tools/sync.sh apply

# Review the report
.pai-fork/tools/sync.sh report

# Walk backups and decide what to re-apply
.pai-fork/tools/reintegrate.sh

# Single sync commit
git add -A && git commit -m "chore(sync): upstream@<sha7> -> backups/<ts>"
```

## Customizing a file (the right way)

When you intentionally edit a file Daniel also ships:

```bash
.pai-fork/tools/add-customization.sh Packs/Foo/SKILL.md "Reason for the override"
```

This writes the entry to `manifest.yaml`. Next sync that touches `Packs/Foo/SKILL.md` will back ours up before taking Daniel's, instead of silently losing your work.

## Why both manifest AND auto-backup?

Two layers of safety:

- **Manifest** = explicit ownership. "I know I customize this. I want to be reminded every time upstream touches it."
- **Auto-backup** = safety net. "If I forgot to manifest something but it actually drifted, don't lose my work."

The auto-backup catches the "I edited this and forgot to add it to the manifest" case. The manifest catches the "I want to know about this even when my changes look identical to upstream's old version" case.

## Pristine upstream worktree

```bash
# Read Daniel's version of any file without leaving main:
cat ~/Developer/PAI-upstream/Packs/Browser/README.md

# Compare side-by-side:
diff ~/Developer/PAI-upstream/Packs/Browser/README.md Packs/Browser/README.md

# Refresh worktree to latest upstream:
cd ~/Developer/PAI-upstream && git fetch origin && git checkout upstream/main
```

The worktree is on a detached HEAD by design — read-only is the contract.

## Automation

- **Manual:** you run `sync.sh apply` when you want to.
- **Weekly:** `.github/workflows/upstream-drift.yml` runs every Monday and opens/updates a `[upstream-drift]` issue if upstream has new commits.

## Rollback

If a sync went sideways:

```bash
.pai-fork/tools/sync.sh rollback 20260511-143000_upstream-9fb9c86
```

Restores files from that backup snapshot. Always reversible.

## Audit trail

```bash
# All sync commits:
git log --grep '^chore(sync)' --oneline

# Last 10 sync reports:
ls -1t .pai-fork/backups/ | head -10

# What was backed up in a specific sync:
cat .pai-fork/backups/<ts>/REPORT.md
```

## Conventions

- One sync = one commit. Don't mix sync commits with feature work.
- `sync.sh apply` updates `last-synced.ref` automatically.
- Backups stay in-repo permanently (audit trail). They're small (only changed files).
- Reintegrate walks happen in separate commits from the sync commit.

## First-time setup (after clone)

```bash
.pai-fork/tools/install-hooks.sh   # wires repo-local pre-commit
.pai-fork/tools/sync.sh status     # verify upstream is reachable
.pai-fork/tools/generate-inventory.sh  # emit Packs/INVENTORY.md
```

## What the pre-commit hook does

On every `git commit`:
1. **Detects unmanifested customizations** — staged file exists upstream + content differs + not in manifest + not excluded → warns with the exact `add-customization.sh` invocation
2. **Auto-regenerates `Packs/INVENTORY.md`** if any `Packs/` file changed; auto-stages the regenerated file

Set `PAI_FORK_STRICT=1` to make warnings block the commit instead of just printing.

## 3-way merge for manifested files

When `sync.sh apply` updates a manifested `.md` file, instead of overwriting wholesale, it runs a 3-way merge using:
- **base** = previous upstream version (from `last-synced.ref`)
- **ours** = current local file
- **theirs** = new upstream version

Result:
- **Clean merge** → both your edits and Daniel's edits land in the same file (no conflict markers needed)
- **Conflict** → standard `<<<<<<<` markers in the file; resolve manually, plus a forensic copy of all three versions in `.pai-fork/backups/merge-conflicts/{ts}/`
- **Always** → backup of OURS still saved in the regular sync backup dir (rollback never loses anything)

## Auto-generated `Packs/INVENTORY.md`

A read-only census of every pack:

| Column | Meaning |
|---|---|
| Source | `upstream` (Daniel) or `fork-only` (yours) |
| Drift | 🟡 yes / ✅ clean — does any file in pack differ from upstream tree? |
| Manifested | Count of files declared in `manifest.yaml` for this pack |
| SKILL.md, Workflows | File counts |
| Last local / Last upstream | Last commit dates touching this pack |

Regenerated automatically on every commit. Never hand-edit.
