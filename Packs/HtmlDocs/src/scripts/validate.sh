#!/bin/bash
# Validate an HTML docs site for common issues.
# Usage: validate.sh <docs-dir>
# Checks: file existence, nav consistency, viewport, theme, broken links, placeholders

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <docs-dir>"
    echo "Example: $0 ./docs/site"
    exit 1
fi

DIR="$1"
ERRORS=0
WARNINGS=0

error() { echo "  ✗ $1"; ERRORS=$((ERRORS + 1)); }
warn()  { echo "  ⚠ $1"; WARNINGS=$((WARNINGS + 1)); }
ok()    { echo "  ✓ $1"; }

echo "Validating docs site: $DIR"
echo ""

# --- Check required files ---
echo "Files:"
for f in shared.css shared.js; do
    if [ -f "$DIR/$f" ]; then
        ok "$f exists"
    else
        error "$f missing"
    fi
done

HTML_FILES=()
for f in "$DIR"/*.html; do
    [ -f "$f" ] && HTML_FILES+=("$f")
done

if [ ${#HTML_FILES[@]} -eq 0 ]; then
    error "No HTML files found"
    echo ""
    echo "Result: $ERRORS errors, $WARNINGS warnings"
    exit 1
fi
ok "${#HTML_FILES[@]} HTML pages found"

# --- Check each HTML file ---
echo ""
echo "Pages:"
for html in "${HTML_FILES[@]}"; do
    page=$(basename "$html")
    echo "  $page:"

    # Viewport meta
    if grep -q 'name="viewport"' "$html"; then
        ok "  viewport meta present"
    else
        error "  missing viewport meta (broken on mobile)"
    fi

    # Theme attribute
    if grep -q 'data-theme=' "$html"; then
        ok "  data-theme attribute present"
    else
        error "  missing data-theme on <html> (theme toggle won't work)"
    fi

    # shared.css link
    if grep -q 'shared.css' "$html"; then
        ok "  shared.css linked"
    else
        error "  shared.css not linked"
    fi

    # shared.js link
    if grep -q 'shared.js' "$html"; then
        ok "  shared.js linked"
    else
        error "  shared.js not linked"
    fi

    # Nav toggle button
    if grep -q 'nav-toggle' "$html"; then
        ok "  mobile nav toggle present"
    else
        warn "  missing mobile nav toggle button"
    fi

    # Inline styles check
    if grep -qP 'style="[^"]{10,}"' "$html"; then
        warn "  contains inline styles (use CSS classes instead)"
    fi

    # Placeholder check
    PLACEHOLDERS=$(grep -c 'class="placeholder"' "$html" || true)
    if [ "$PLACEHOLDERS" -gt 0 ]; then
        warn "  $PLACEHOLDERS placeholder(s) remaining"
    fi

    # TODO check
    TODOS=$(grep -ci 'TODO' "$html" || true)
    if [ "$TODOS" -gt 0 ]; then
        warn "  $TODOS TODO(s) found"
    fi
done

# --- Nav consistency check ---
echo ""
echo "Navigation consistency:"
FIRST_NAV=""
NAV_CONSISTENT=true
for html in "${HTML_FILES[@]}"; do
    # Extract sidebar-nav content
    nav=$(sed -n '/<div class="sidebar-nav">/,/<\/div>/p' "$html" | head -20)
    if [ -z "$FIRST_NAV" ]; then
        FIRST_NAV="$nav"
    elif [ "$nav" != "$FIRST_NAV" ]; then
        NAV_CONSISTENT=false
        warn "$(basename "$html") has different navigation than $(basename "${HTML_FILES[0]}")"
    fi
done
if [ "$NAV_CONSISTENT" = true ]; then
    ok "All pages have identical navigation"
fi

# --- Cross-link validation ---
echo ""
echo "Internal links:"
for html in "${HTML_FILES[@]}"; do
    page=$(basename "$html")
    # Extract href values from anchor tags
    hrefs=$(grep -oP 'href="[^"]*\.html"' "$html" | grep -oP '"[^"]*"' | tr -d '"' || true)
    for href in $hrefs; do
        # Skip external links and anchors
        if [[ "$href" == http* ]] || [[ "$href" == "#"* ]]; then
            continue
        fi
        # Resolve relative path
        target="$DIR/$href"
        if [ ! -f "$target" ]; then
            error "$page links to $href which doesn't exist"
        fi
    done
done
ok "Internal link check complete"

# --- CSS checks ---
echo ""
echo "CSS quality:"
if [ -f "$DIR/shared.css" ]; then
    if grep -q 'max-width' "$DIR/shared.css"; then
        ok "Content max-width defined"
    else
        warn "No max-width found (lines may be too long)"
    fi

    if grep -q '@media' "$DIR/shared.css"; then
        ok "Responsive breakpoints defined"
    else
        error "No @media queries (no mobile support)"
    fi

    if grep -q 'data-theme.*light' "$DIR/shared.css"; then
        ok "Light theme defined"
    else
        warn "No light theme variant found"
    fi
fi

# --- Mermaid check ---
echo ""
echo "Mermaid usage:"
for html in "${HTML_FILES[@]}"; do
    page=$(basename "$html")
    HAS_MERMAID_DIV=$(grep -c 'class="mermaid"' "$html" || true)
    HAS_MERMAID_CDN=$(grep -c 'mermaid.*\.js' "$html" || true)

    if [ "$HAS_MERMAID_DIV" -gt 0 ] && [ "$HAS_MERMAID_CDN" -eq 0 ]; then
        error "$page has Mermaid diagrams but no Mermaid CDN script"
    elif [ "$HAS_MERMAID_DIV" -eq 0 ] && [ "$HAS_MERMAID_CDN" -gt 0 ]; then
        warn "$page loads Mermaid CDN but has no diagrams (unnecessary download)"
    elif [ "$HAS_MERMAID_DIV" -gt 0 ]; then
        ok "$page: $HAS_MERMAID_DIV diagram(s) with CDN loaded"
    fi
done

# --- Summary ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✓ All checks passed"
elif [ $ERRORS -eq 0 ]; then
    echo "✓ $WARNINGS warning(s), 0 errors"
else
    echo "✗ $ERRORS error(s), $WARNINGS warning(s)"
fi
exit $ERRORS
