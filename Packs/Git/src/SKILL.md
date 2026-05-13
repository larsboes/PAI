---
name: Git
description: "Git workflows across local operations, GitHub (gh CLI), and GitLab (glab CLI + REST API) — worktrees, rebase, bisect, reflog recovery, PRs, releases, CI, MRs, pipelines. GitLab reads GITLAB_URL + GITLAB_TOKEN from env. USE WHEN git, rebase, squash commits, worktree, bisect, recover lost commit, reflog, git hooks, subtree, PR, pull request, gh CLI, GitHub Actions, CI check, release, create PR, merge PR, MR, merge request, GitLab, glab, pipeline, gitlab CI, gitlab API, create MR, review MR."
allowed-tools: Bash
---

# GitWorkflow

Git operations across three surfaces — local, GitHub, and GitLab.

## Workflow Routing

| Trigger | Workflow |
|---------|----------|
| Local git operations — rebase, squash, worktree, bisect, recover, hooks, subtrees | `Workflows/Local.md` |
| GitHub — PR, review, release, Actions CI, gh CLI, issues | `Workflows/GitHub.md` |
| GitLab — MR, pipeline, glab CLI, REST API, wiki | `Workflows/GitLab.md` |

## Environment

GitLab reads from env (never hardcoded):
```bash
GITLAB_URL=gitlab.com       # or your self-hosted instance
GITLAB_TOKEN=glpat-xxxx
```

GitHub auth is handled by `gh auth login` (stored token) or `GITHUB_TOKEN` env var.

## Quick Reference

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Recover anything — even after reset --hard
git reflog

# Parallel branch work without stashing
git worktree add ../project-hotfix -b hotfix/critical main

# Find which commit broke something
git bisect start && git bisect bad && git bisect good v1.0.0

# GitHub: create PR
gh pr create --title "feat: X" --base main

# GitLab: create MR
glab mr create --fill

# GitLab: stream CI job log
glab ci trace <job-id>
```
