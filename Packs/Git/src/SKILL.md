---
name: Git
description: "Git workflows across local, GitHub (gh CLI), and GitLab (glab CLI + REST API) — worktrees, rebase, bisect, reflog, PRs, releases, CI, MRs, pipelines. GitLab reads GITLAB_URL + GITLAB_TOKEN from env. USE WHEN git, rebase, squash commits, worktree, bisect, recover lost commit, reflog, git hooks, subtree, PR, pull request, gh CLI, GitHub Actions, CI check, release, create PR, merge PR, MR, merge request, GitLab, glab, pipeline, gitlab CI, gitlab API, create MR, review MR, gh release, GitHub issue."
allowed-tools: Bash
---

# Git

Git operations across three surfaces — local, GitHub, and GitLab.

## Workflow Routing

| Trigger | Workflow |
|---------|----------|
| Local git — rebase, squash, worktree, bisect, recover, hooks, subtrees | `Workflows/Local.md` |
| GitHub — PR, review, release, Actions CI, gh CLI, issues | `Workflows/GitHub.md` |
| GitLab — MR, pipeline, glab CLI, REST API, wiki | `Workflows/GitLab.md` |

## Environment

```bash
# GitLab (never hardcoded)
GITLAB_URL=gitlab.com        # or self-hosted instance
GITLAB_TOKEN=glpat-xxxx      # scopes: api, read_repository, write_repository

# GitHub — stored via `gh auth login` or:
GITHUB_TOKEN=ghp-xxxx
```

## Quick Reference

```bash
# Local
git reset --soft HEAD~1                          # undo last commit, keep changes
git reflog                                       # recover anything after reset --hard
git worktree add ../hotfix -b hotfix/x main      # parallel branch without stashing
git bisect start && git bisect bad && git bisect good v1.0   # find breaking commit

# GitHub (gh CLI)
gh pr create --title "feat: X" --base main       # create PR
gh pr merge 123 --squash --delete-branch         # merge PR
gh run list --workflow ci.yml                    # list CI runs
gh run view <id> --log-failed                    # see failed logs
gh release create v1.0.0 --generate-notes        # create release

# GitLab (glab CLI)
glab mr create --fill                            # create MR from branch
glab mr merge 10 --squash --remove-source-branch # merge MR
glab ci trace <job-id>                           # stream job log live
glab ci lint .gitlab-ci.yml                      # validate CI config

# GitLab (REST API — for bulk/scripted ops)
scripts/gitlab.sh mrs 12345                      # list open MRs
scripts/gitlab.sh job-log 12345 67890            # get job log
scripts/gitlab.sh search blobs "pattern" --project 12345
```

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/pr-create.sh` | GitHub PR creation with flags |
| `scripts/pr-review.sh` | GitHub PR review helpers |
| `scripts/release.sh` | GitHub release management |
| `scripts/ci-status.sh` | GitHub CI status overview |
| `scripts/ci-logs.sh` | GitHub CI log fetching |
| `scripts/gitlab.sh` | GitLab REST API wrapper |
| `scripts/git-recent.sh` | Recent branches + activity |
| `scripts/git-fixup.sh` | Fixup commit helpers |
| `scripts/git-cleanup.sh` | Branch cleanup |
