#!/bin/bash
# Scaffold a standalone HTML documentation site.
# Usage: scaffold.sh <project-name> [options]
# Options:
#   --dir <path>          Output directory (default: ./docs/site)
#   --pages <list>        Comma-separated page names (default: index,features,components,config)
#   --labels <list>       Comma-separated page labels (default: Architecture,Features,Components,Configuration)
#   --accent <color>      Accent color hex (default: #58a6ff)
#   --no-mermaid          Don't include Mermaid.js CDN on any page
#   --mermaid-pages <list> Pages that need Mermaid (default: index,components)

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <project-name> [options]"
    echo ""
    echo "Options:"
    echo "  --dir <path>           Output directory (default: ./docs/site)"
    echo "  --pages <list>         Comma-separated page names (default: index,features,components,config)"
    echo "  --labels <list>        Comma-separated labels (default: Architecture,Features,Components,Configuration)"
    echo "  --accent <color>       Accent hex (default: #58a6ff)"
    echo "  --no-mermaid           Skip Mermaid.js CDN on all pages"
    echo "  --mermaid-pages <list> Pages needing Mermaid (default: index,components)"
    echo ""
    echo "Examples:"
    echo "  $0 'My Project'"
    echo "  $0 'API Gateway' --dir api-docs --pages index,endpoints,auth,errors"
    echo "  $0 'Tool' --pages index,usage,api --labels 'Overview,Usage Guide,API Reference'"
    exit 1
fi

PROJECT_NAME="$1"
shift

# Defaults
OUTPUT_DIR="./docs/site"
PAGES="index,features,components,config"
LABELS="Architecture,Features,Components,Configuration"
ACCENT="#58a6ff"
MERMAID_ENABLED=true
MERMAID_PAGES="index,components"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dir)        OUTPUT_DIR="$2"; shift 2 ;;
        --pages)      PAGES="$2"; shift 2 ;;
        --labels)     LABELS="$2"; shift 2 ;;
        --accent)     ACCENT="$2"; shift 2 ;;
        --no-mermaid) MERMAID_ENABLED=false; shift ;;
        --mermaid-pages) MERMAID_PAGES="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Convert comma-separated to arrays
IFS=',' read -ra PAGE_ARRAY <<< "$PAGES"
IFS=',' read -ra LABEL_ARRAY <<< "$LABELS"
IFS=',' read -ra MERMAID_ARRAY <<< "$MERMAID_PAGES"

if [ ${#PAGE_ARRAY[@]} -ne ${#LABEL_ARRAY[@]} ]; then
    echo "Error: --pages and --labels must have the same number of items"
    echo "  Pages (${#PAGE_ARRAY[@]}):  $PAGES"
    echo "  Labels (${#LABEL_ARRAY[@]}): $LABELS"
    exit 1
fi

# SVG icons for common page types (fallback to generic)
declare -A ICONS
ICONS[index]='<svg class="nav-icon" viewBox="0 0 16 16" fill="currentColor"><path d="M8.707 1.5a1 1 0 0 0-1.414 0L.646 8.146a.5.5 0 0 0 .708.708L8 2.207l6.646 6.647a.5.5 0 0 0 .708-.708L13 5.793V2.5a.5.5 0 0 0-.5-.5h-1a.5.5 0 0 0-.5.5v1.293L8.707 1.5ZM2 10l6-6 6 6v3.5a1.5 1.5 0 0 1-1.5 1.5h-9A1.5 1.5 0 0 1 2 13.5V10Z"/></svg>'
ICONS[features]='<svg class="nav-icon" viewBox="0 0 16 16" fill="currentColor"><path d="M8 0a8 8 0 1 1 0 16A8 8 0 0 1 8 0ZM1.5 8a6.5 6.5 0 1 0 13 0 6.5 6.5 0 0 0-13 0Zm9.78-2.22-5.5 5.5a.749.749 0 0 1-1.275-.326.749.749 0 0 1 .215-.734l5.5-5.5a.751.751 0 0 1 1.042.018.751.751 0 0 1 .018 1.042Z"/></svg>'
ICONS[components]='<svg class="nav-icon" viewBox="0 0 16 16" fill="currentColor"><path d="M0 1.75C0 .784.784 0 1.75 0h12.5C15.216 0 16 .784 16 1.75v12.5A1.75 1.75 0 0 1 14.25 16H1.75A1.75 1.75 0 0 1 0 14.25ZM6.5 6.5v8h7.75a.25.25 0 0 0 .25-.25V6.5Zm8-1.5V1.75a.25.25 0 0 0-.25-.25H1.75a.25.25 0 0 0-.25.25V5ZM5 6.5H1.5v7.75c0 .138.112.25.25.25H5Z"/></svg>'
ICONS[config]='<svg class="nav-icon" viewBox="0 0 16 16" fill="currentColor"><path d="M8 0a8.2 8.2 0 0 1 .701.031C9.444.095 9.99.645 10.16 1.29l.288 1.107c.018.066.079.158.212.224.231.114.454.243.668.386.123.082.233.09.3.071L12.74 2.8c.644-.177 1.392.02 1.82.63.27.386.506.798.704 1.229.332.72.03 1.47-.487 1.9l-.893.7a.31.31 0 0 0-.091.29 6.07 6.07 0 0 1 0 .958.31.31 0 0 0 .091.29l.893.7c.518.43.82 1.18.487 1.9-.198.431-.434.843-.704 1.229-.428.61-1.176.807-1.82.63l-1.103-.303c-.066-.019-.176-.011-.299.071a5.846 5.846 0 0 1-.668.386c-.133.066-.194.158-.212.224l-.288 1.107c-.17.645-.716 1.195-1.459 1.26a8.006 8.006 0 0 1-1.402 0c-.743-.065-1.289-.615-1.459-1.26l-.289-1.107a.426.426 0 0 0-.211-.224 5.846 5.846 0 0 1-.668-.386c-.123-.082-.233-.09-.3-.071l-1.102.302c-.644.177-1.392-.02-1.82-.63a6.964 6.964 0 0 1-.704-1.229c-.332-.72-.03-1.47.487-1.9l.893-.7a.31.31 0 0 0 .091-.29 6.07 6.07 0 0 1 0-.958.31.31 0 0 0-.091-.29l-.893-.7c-.518-.43-.82-1.18-.487-1.9.198-.431.434-.843.704-1.229.428-.61 1.176-.807 1.82-.63l1.102.302c.067.019.177.011.3-.071.214-.143.437-.272.668-.386a.426.426 0 0 0 .211-.224l.29-1.107C6.009.645 6.556.095 7.299.03 7.53.01 7.764 0 8 0Z"/></svg>'
# Generic fallback icon (document)
ICON_DEFAULT='<svg class="nav-icon" viewBox="0 0 16 16" fill="currentColor"><path d="M3.75 1.5a.25.25 0 0 0-.25.25v11.5c0 .138.112.25.25.25h8.5a.25.25 0 0 0 .25-.25V6H9.75A1.75 1.75 0 0 1 8 4.25V1.5ZM10 4.25v-2.5l3.5 3.5H10.5a.25.25 0 0 1-.25-.25h-.25ZM3.75 0h5.086c.464 0 .909.184 1.237.513l3.414 3.414c.329.328.513.773.513 1.237v8.086A1.75 1.75 0 0 1 12.25 15h-8.5A1.75 1.75 0 0 1 2 13.25V1.75C2 .784 2.784 0 3.75 0Z"/></svg>'

mkdir -p "$OUTPUT_DIR"

# --- Generate sidebar nav HTML fragment ---
generate_nav() {
    local nav=""
    for i in "${!PAGE_ARRAY[@]}"; do
        local page="${PAGE_ARRAY[$i]}"
        local label="${LABEL_ARRAY[$i]}"
        local icon="${ICONS[$page]:-$ICON_DEFAULT}"
        nav+="        <a href=\"${page}.html\">${icon}${label}</a>"$'\n'
    done
    echo "$nav"
}

NAV_HTML=$(generate_nav)

# --- Check if page needs Mermaid ---
needs_mermaid() {
    local page="$1"
    if [ "$MERMAID_ENABLED" = false ]; then
        return 1
    fi
    for mp in "${MERMAID_ARRAY[@]}"; do
        if [ "$mp" = "$page" ]; then
            return 0
        fi
    done
    return 1
}

# --- Generate HTML page ---
generate_page() {
    local page="$1"
    local label="$2"
    local mermaid_script=""

    if needs_mermaid "$page"; then
        mermaid_script='  <script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>'
    fi

    cat > "${OUTPUT_DIR}/${page}.html" << HTMLEOF
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${PROJECT_NAME} - ${label}</title>
  <link rel="stylesheet" href="shared.css">
${mermaid_script}
</head>
<body>
  <button class="nav-toggle" aria-label="Toggle navigation">&#9776;</button>

  <div class="page">
    <nav class="sidebar">
      <div class="sidebar-header">
        <h1>${PROJECT_NAME}</h1>
        <div class="subtitle">Documentation</div>
      </div>
      <div class="sidebar-nav">
${NAV_HTML}      </div>
      <div class="sidebar-footer">
        <button class="theme-toggle" onclick="toggleTheme()">Light mode</button>
      </div>
    </nav>

    <main class="main">
      <div class="content">
        <h1>${label}</h1>
        <p class="page-description">TODO: Add description for this page.</p>

        <!-- === Section 1 === -->
        <h2>Section Title</h2>
        <div class="card-grid">
          <div class="card">
            <h4>Card Title</h4>
            <p>Card description goes here.</p>
          </div>
          <div class="card">
            <h4>Card Title</h4>
            <p>Card description goes here.</p>
          </div>
          <div class="card">
            <h4>Card Title</h4>
            <p>Card description goes here.</p>
          </div>
        </div>

        <!-- === Section 2 === -->
        <h2>Details Section</h2>
        <details>
          <summary>Expandable Section</summary>
          <div class="details-content">
            <p>Detailed content goes here.</p>
            <table>
              <thead><tr><th>Column 1</th><th>Column 2</th><th>Column 3</th></tr></thead>
              <tbody>
                <tr><td><code>example</code></td><td>Description</td><td><span class="badge badge-green">Done</span></td></tr>
              </tbody>
            </table>
          </div>
        </details>

        <div class="callout callout-info">
          Replace this scaffold content with real documentation.
        </div>
      </div>
    </main>
  </div>

  <script src="shared.js"></script>
</body>
</html>
HTMLEOF
}

# --- Copy shared.css from template ---
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_DIR="$SKILL_DIR/references/templates"

if [ -f "$TEMPLATE_DIR/shared.css" ]; then
    cp "$TEMPLATE_DIR/shared.css" "$OUTPUT_DIR/shared.css"
    # Replace accent color if custom
    if [ "$ACCENT" != "#58a6ff" ]; then
        sed -i "s/#58a6ff/${ACCENT}/g" "$OUTPUT_DIR/shared.css"
        # Also adjust accent-hover (lighten) and accent-dim (darken) — leave for manual tuning
        echo "Note: Custom accent color applied. Manually tune --accent-hover and --accent-dim in shared.css."
    fi
else
    echo "Warning: Template shared.css not found at $TEMPLATE_DIR/shared.css"
    echo "  Run from within a project or ensure the skill templates exist."
    exit 1
fi

if [ -f "$TEMPLATE_DIR/shared.js" ]; then
    cp "$TEMPLATE_DIR/shared.js" "$OUTPUT_DIR/shared.js"
else
    echo "Warning: Template shared.js not found at $TEMPLATE_DIR/shared.js"
    exit 1
fi

# --- Generate all pages ---
for i in "${!PAGE_ARRAY[@]}"; do
    generate_page "${PAGE_ARRAY[$i]}" "${LABEL_ARRAY[$i]}"
done

echo ""
echo "✓ Documentation site scaffolded: $OUTPUT_DIR/"
echo ""
echo "  Files created:"
echo "    shared.css   — Design system (dark + light theme)"
echo "    shared.js    — Nav highlight, theme toggle, Mermaid init"
for i in "${!PAGE_ARRAY[@]}"; do
    local_mermaid=""
    if needs_mermaid "${PAGE_ARRAY[$i]}"; then
        local_mermaid=" (+ Mermaid)"
    fi
    echo "    ${PAGE_ARRAY[$i]}.html  — ${LABEL_ARRAY[$i]}${local_mermaid}"
done
echo ""
echo "  Next steps:"
echo "    1. Open ${OUTPUT_DIR}/index.html in a browser"
echo "    2. Replace scaffold content with real documentation"
echo "    3. Follow the progressive disclosure pattern:"
echo "       Cards → Section headers → <details> → Tables/code"
