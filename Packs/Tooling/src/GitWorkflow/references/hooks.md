# Git Hooks — Complete Reference

## Hook Types

| Hook | Trigger | Use For |
|------|---------|---------|
| `pre-commit` | Before commit is created | Lint, format, tests |
| `prepare-commit-msg` | After default msg, before editor | Auto-prefixes, templates |
| `commit-msg` | After message written | Validate conventional commits |
| `post-commit` | After commit created | Notifications |
| `pre-push` | Before push | Run full test suite |
| `pre-rebase` | Before rebase starts | Prevent rebasing shared branches |
| `post-merge` | After merge | Install deps, run migrations |
| `post-checkout` | After checkout/switch | Install deps for branch |

## Setup (No Tools Required)

```bash
# Hooks live in .git/hooks/ — just make them executable
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
# Run linting on staged files only
STAGED=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx|js|jsx)$' || true)
[ -z "$STAGED" ] && exit 0
echo "$STAGED" | xargs npx eslint --fix
echo "$STAGED" | xargs git add  # re-stage after fixes
EOF
chmod +x .git/hooks/pre-commit
```

## Common Hooks

### Conventional Commit Validator
```bash
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/sh
MSG=$(cat "$1")
PATTERN='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .{1,72}'
if ! echo "$MSG" | grep -qE "$PATTERN"; then
  echo "ERROR: Commit message must follow Conventional Commits format:"
  echo "  type(scope): description"
  echo ""
  echo "Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
  exit 1
fi
EOF
chmod +x .git/hooks/commit-msg
```

### Pre-push Test Runner
```bash
cat > .git/hooks/pre-push << 'EOF'
#!/bin/sh
echo "Running tests before push..."
npm test 2>/dev/null || bun test 2>/dev/null || {
  echo "Tests failed! Push aborted."
  exit 1
}
EOF
chmod +x .git/hooks/pre-push
```

### Post-merge Dependency Installer
```bash
cat > .git/hooks/post-merge << 'EOF'
#!/bin/sh
# Check if package.json changed
CHANGED=$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)
if echo "$CHANGED" | grep -q "package.json"; then
  echo "📦 package.json changed — installing dependencies..."
  npm install 2>/dev/null || bun install 2>/dev/null
fi
if echo "$CHANGED" | grep -q "requirements.txt"; then
  echo "🐍 requirements.txt changed — installing..."
  pip install -r requirements.txt
fi
EOF
chmod +x .git/hooks/post-merge
```

### Branch Name in Commit (Jira Ticket)
```bash
cat > .git/hooks/prepare-commit-msg << 'EOF'
#!/bin/sh
COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2
# Only for regular commits (not merge, squash, etc.)
[ -n "$COMMIT_SOURCE" ] && exit 0
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
TICKET=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+' || true)
[ -n "$TICKET" ] && sed -i "1s/^/[$TICKET] /" "$COMMIT_MSG_FILE"
EOF
chmod +x .git/hooks/prepare-commit-msg
```

## Sharing Hooks (No External Tools)

```bash
# Option 1: .githooks directory (git 2.9+)
mkdir -p .githooks
# put hooks in .githooks/
git config core.hooksPath .githooks

# Option 2: Makefile setup target
setup:
	git config core.hooksPath .githooks
	chmod +x .githooks/*
```

## Bypassing Hooks

```bash
git commit --no-verify    # skip pre-commit + commit-msg
git push --no-verify      # skip pre-push
```
