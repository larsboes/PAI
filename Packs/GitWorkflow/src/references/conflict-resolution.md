# Git Conflict Resolution & Merge Strategies

## Merge Strategies

```bash
# Default recursive merge
git merge feature-branch

# Prefer "ours" on conflicts (keep current branch)
git merge -X ours feature-branch

# Prefer "theirs" on conflicts (keep incoming)
git merge -X theirs feature-branch

# Squash merge (single commit, no merge commit)
git merge --squash feature-branch
git commit -m "feat: merged feature-branch"

# No-ff (always create merge commit, even if fast-forward possible)
git merge --no-ff feature-branch
```

## Resolving Conflicts

```bash
# See conflicted files
git diff --name-only --diff-filter=U

# Accept all of ours/theirs for a file
git checkout --ours file.ts
git checkout --theirs file.ts
git add file.ts

# Accept all of ours/theirs for EVERYTHING
git checkout --ours .
git checkout --theirs .

# Abort merge
git merge --abort

# After resolving manually
git add resolved-file.ts
git commit  # completes the merge
```

## Rerere (Reuse Recorded Resolution)

```bash
# Enable — git remembers how you resolved conflicts
git config --global rerere.enabled true

# Now when you resolve a conflict, git records it
# Next time the SAME conflict appears, it auto-resolves

# See recorded resolutions
ls .git/rr-cache/

# Forget a bad resolution
git rerere forget file.ts
```

## Rebase Conflicts

```bash
# When rebase stops on conflict:
# 1. Fix the conflict
# 2. Stage the fix
git add file.ts
# 3. Continue rebase
git rebase --continue

# Skip this commit entirely
git rebase --skip

# Abort (back to before rebase)
git rebase --abort

# "Ours" and "theirs" are SWAPPED in rebase!
# During rebase: "ours" = branch being rebased ONTO, "theirs" = your commits
```

## Cherry-Pick Conflicts

```bash
git cherry-pick COMMIT
# If conflict:
git add resolved.ts
git cherry-pick --continue

# Abort
git cherry-pick --abort
```

## Three-Way Diff (Understanding Conflicts)

```bash
# See the merge base (common ancestor)
git merge-base HEAD other-branch

# Three-way diff
git diff :1:file.ts :2:file.ts  # base vs ours
git diff :1:file.ts :3:file.ts  # base vs theirs

# Visual merge tool
git mergetool
```

## Preventing Conflicts

```bash
# Preview what a merge would look like (dry run)
git merge --no-commit --no-ff feature-branch
git diff --staged
git merge --abort  # back out

# See what changed on the other branch vs common ancestor
git diff $(git merge-base HEAD feature-branch) feature-branch

# Frequent rebasing reduces conflict size
git fetch && git rebase origin/main
```
