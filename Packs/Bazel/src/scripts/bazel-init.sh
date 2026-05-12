#!/bin/bash
# bazel-init.sh — Bootstrap a new Bazel project with modern bzlmod setup
# Usage: ./bazel-init.sh <project-name> [bazel-version]
#
# Creates: MODULE.bazel, .bazelrc, .bazelversion, .gitignore additions, root BUILD.bazel

set -euo pipefail

PROJECT="${1:?Usage: $0 <project-name> [bazel-version]}"
BAZEL_VERSION="${2:-7.1.1}"

echo "Initializing Bazel project: $PROJECT (Bazel $BAZEL_VERSION)"
echo ""

# .bazelversion
echo "$BAZEL_VERSION" > .bazelversion
echo "✓ .bazelversion ($BAZEL_VERSION)"

# MODULE.bazel
cat > MODULE.bazel << EOF
module(
    name = "$PROJECT",
    version = "0.1.0",
)

# Add dependencies from https://registry.bazel.build/
# Example:
# bazel_dep(name = "rules_python", version = "1.1.0")
EOF
echo "✓ MODULE.bazel"

# .bazelrc
cat > .bazelrc << 'EOF'
# Enable bzlmod (default in Bazel 7+)
common --enable_bzlmod

# Build settings
build --color=yes
build --show_timestamps
build --jobs=auto

# Test settings
test --test_output=errors
test --test_verbose_timeout_warnings

# CI config (use with --config=ci)
build:ci --color=yes
build:ci --show_timestamps
test:ci --test_output=errors
test:ci --flaky_test_attempts=2
EOF
echo "✓ .bazelrc"

# Root BUILD.bazel
if [ ! -f BUILD.bazel ]; then
cat > BUILD.bazel << 'EOF'
# Root BUILD file
# Add top-level targets or leave empty
EOF
echo "✓ BUILD.bazel (root)"
fi

# .gitignore additions
BAZEL_IGNORE="/bazel-bin
/bazel-out
/bazel-testlogs
/bazel-${PROJECT}
.bazel/"

if [ -f .gitignore ]; then
    if ! grep -q "bazel-bin" .gitignore; then
        echo "" >> .gitignore
        echo "# Bazel" >> .gitignore
        echo "$BAZEL_IGNORE" >> .gitignore
        echo "✓ .gitignore (appended Bazel entries)"
    else
        echo "~ .gitignore (Bazel entries already present)"
    fi
else
    echo "# Bazel" > .gitignore
    echo "$BAZEL_IGNORE" >> .gitignore
    echo "✓ .gitignore (created)"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Install bazelisk: go install github.com/bazelbuild/bazelisk@latest"
echo "  2. Add deps: edit MODULE.bazel (search https://registry.bazel.build/)"
echo "  3. Create BUILD.bazel files in your packages"
echo "  4. Run: bazel build //..."
echo "  5. Format: buildifier -r ."
