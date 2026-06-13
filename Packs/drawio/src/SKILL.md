---
name: drawio
description: "Work with draw.io / diagrams.net files (.drawio mxfile XML) — surgically edit diagram XML (add/move/relabel nodes and edges), render/export a .drawio to PNG/SVG/HTML, and handle PlantUML diagram-as-code (encode source → render URL, decode embedded). USE WHEN drawio, draw.io, diagrams.net, .drawio, mxfile, mxgraph, edit drawio, render drawio, export drawio to png, drawio xml, plantuml, plantuml url, encode plantuml, architecture diagram in drawio. NOT FOR generating styled illustrations or diagram *images* from a text prompt (use Art); NOT FOR Mermaid-syntax diagrams (use Mermaid); NOT FOR Confluence diagram macros."
allowed-tools: Bash, Read, Write, Edit
---

# drawio — edit & render diagrams.net files

Fills the gap the `Art` and `Mermaid` skills don't cover: **editing the raw `.drawio` (mxfile) XML directly** and **rendering/exporting** it, plus a **PlantUML text-codec**. Use `Art` for generated/styled diagram *images* and `Mermaid` for Mermaid-syntax diagrams — this skill is for hand/programmatic work on actual draw.io files.

## Workflows

### 1. EditXML — surgically edit a .drawio
A `.drawio` is XML: `<mxfile>` → `<diagram>` → `<mxGraphModel><root>` with `<mxCell>` nodes (shapes) and edges. Read `references/mxfile-format.md` for the structure and the minimal cell recipes, then use `Edit`/`Write` to add, relabel, move, or connect cells. Keep cell `id`s stable; edges reference nodes via `source`/`target` ids.

- For a brand-new diagram, copy the skeleton from `references/mxfile-format.md` and add cells.
- For edits, target the specific `<mxCell>` by `id` or `value` — don't rewrite the whole file.

### 2. Render — export to PNG / SVG / HTML
Preferred (if `drawio` desktop CLI is installed — Electron, headless-capable):
```bash
drawio -x -f png  -o out.png  diagram.drawio     # also: -f svg | -f pdf
drawio -x -f svg  -o out.svg  diagram.drawio --width 1600
```
No desktop CLI? Produce a **self-contained HTML preview** that embeds the diagram in the diagrams.net viewer:
```html
<div class="mxgraph" data-mxgraph='{"highlight":"#0000ff","nav":true,"xml":"<ESCAPED-MXFILE-XML>"}'></div>
<script src="https://viewer.diagrams.net/js/viewer-static.min.js"></script>
```
Write that to an `.html` and open it. For a **fully offline** preview (no SaaS), vendor `viewer-static.min.js` locally and point the `<script src>` at the local copy (see `references/mxfile-format.md` → "Offline viewer").

### 3. PlantUML — diagram-as-code
For text-defined diagrams that render via a PlantUML server:
```bash
bun Tools/plantuml.ts url    diagram.puml svg            # -> https://www.plantuml.com/plantuml/svg/~1<token>
bun Tools/plantuml.ts encode diagram.puml               # just the encoded token
bun Tools/plantuml.ts decode "<token>"                  # recover source from an encoded token
```
Point at a self-hosted PlantUML server by passing it as the 3rd arg to `url`.

## Gotchas
- `.drawio` files can be **compressed** (base64+deflate inside `<diagram>`). If a `<diagram>` body isn't readable XML, it's compressed — re-save uncompressed from the app (Extras → uncompressed), or decode it before editing.
- The diagrams.net public viewer is a SaaS dependency; use the vendored viewer for offline/private diagrams (XML never leaves the host).
- Don't fight `Art`/`Mermaid` — if the user wants a rendered picture from a description, that's `Art`; if they want Mermaid text, that's `Mermaid`.

## Supporting files
- `references/mxfile-format.md` — mxfile/mxGraphModel structure, a copy-paste skeleton, minimal node/edge cell recipes, and the offline-viewer note. READ before editing XML.
- `Tools/plantuml.ts` — PlantUML encode/decode/url codec (Bun, no deps).
