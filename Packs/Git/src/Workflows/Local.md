# Git Local — Advanced Patterns

Beyond add-commit-push. Direct commands, no wrappers.

## Daily Power Moves

```bash
# See what you've been doing
git log --oneline --graph --all -20

# Undo last commit (keep changes staged)
git reset --soft HEAD~1

# Undo last commit (keep changes unstaged)
git reset HEAD~1

# Throw away last commit entirely
git reset --hard HEAD~1

# Amend last commit (change message or add files)
git add . && git commit --amend --no-edit

# Quick stash with name
git stash push -m "wip: feature X"

# Apply specific stash
git stash list && git stash apply stash@{2}

# Show what changed in a commit
git show COMMIT --stat

# Find which commit introduced a string
git log -S "function_name" --oneline

# Blame with ignore whitespace + follow renames
git blame -w -M -C file.ts
```

## Worktrees (Parallel Branch Work)

```bash
# Create worktree for a branch (no stash/switch needed)
git worktree add ../project-feature feature-branch

# Create worktree with NEW branch
git worktree add ../project-hotfix -b hotfix/critical main

# List worktrees
git worktree list

# Remove when done
git worktree remove ../project-feature

# Prune stale worktrees
git worktree prune
```

**Use case:** Work on a hotfix without disrupting current feature branch. Claude Code uses this pattern for isolated agent edits.

## Interactive Rebase (Rewrite History)

```bash
# Rebase last N commits interactively
git rebase -i HEAD~5

# Rebase onto main (linear history)
git rebase -i main

# Autosquash fixup commits
git commit --fixup=COMMIT_HASH
git rebase -i --autosquash main
```

**Rebase editor commands:**
- `pick` — keep as-is
- `reword` — change commit message
- `edit` — stop and amend
- `squash` — merge into previous (keep message)
- `fixup` — merge into previous (discard message)
- `drop` — delete commit

## Bisect (Find Bug-Introducing Commit)

```bash
# Manual bisect
git bisect start
git bisect bad          # current commit is broken
git bisect good v1.0.0  # this tag was working
git bisect good         # or: git bisect bad — repeat until found
git bisect reset

# Automated bisect with test script
git bisect start HEAD v1.0.0
git bisect run ./scripts/test.sh  # exit 0 = good, non-zero = bad
```

## Reflog (Recovery)

```bash
# See everything that happened (even after reset --hard)
git reflog

# Recover deleted branch
git reflog | grep "feature-branch"
git checkout -b feature-branch HEAD@{3}

# Undo a rebase
git reflog
git reset --hard HEAD@{5}  # before the rebase

# Recover a specific file after reset --hard
git reflog
git checkout HEAD@{1} -- file.ts
```

## Conflict Resolution

```bash
# Accept incoming (theirs) for a file
git checkout --theirs path/to/file && git add path/to/file

# Accept current (ours) for a file
git checkout --ours path/to/file && git add path/to/file

# Use rerere (reuse recorded resolution)
git config --global rerere.enabled true

# Merge with explicit strategy
git merge feature --strategy-option=theirs
```

## Deep References

- `references/rebase-patterns.md` — Complex rebase scenarios, conflict strategies
- `references/hooks.md` — All hook types with examples
- `references/subtrees-submodules.md` — Monorepo patterns, vendor management
- `references/conflict-resolution.md` — Merge strategies, rerere, ours/theirs
- `references/config.md` — Useful git config tweaks

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/git-recent.sh` | Show recently touched branches with age |
| `scripts/git-cleanup.sh` | Delete merged branches (local + remote) |
| `scripts/git-fixup.sh` | Quick fixup commit targeting specific commit |
| `scripts/git-recover.sh` | Interactive reflog recovery |
