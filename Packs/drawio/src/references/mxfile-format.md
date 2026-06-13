# mxfile / mxGraphModel format reference

A `.drawio` file is an `<mxfile>` containing one or more `<diagram>` pages. Each page holds an `<mxGraphModel>` whose `<root>` contains `<mxCell>` elements: two boilerplate cells (`id="0"` and `id="1"`, the layer), then your shapes (vertices) and connections (edges).

## Minimal skeleton (uncompressed — directly editable)

```xml
<mxfile host="app.diagrams.net">
  <diagram name="Page-1" id="page1">
    <mxGraphModel dx="800" dy="600" grid="1" gridSize="10" guides="1"
                  tooltips="1" connect="1" arrows="1" fold="1" page="1"
                  pageWidth="850" pageHeight="1100" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <!-- your cells go here -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

## A vertex (box)

```xml
<mxCell id="n1" value="User Service" style="rounded=1;whiteSpace=wrap;html=1;"
        vertex="1" parent="1">
  <mxGeometry x="120" y="80" width="160" height="60" as="geometry" />
</mxCell>
```
- `id` — unique, stable; edges reference it.
- `value` — the visible label (HTML allowed with `html=1`).
- `style` — semicolon list. Common: `rounded=1`, `ellipse`, `rhombus` (decision), `shape=cylinder3` (DB), `fillColor=#dae8fc;strokeColor=#6c8ebf` (blue), `dashed=1`.
- `<mxGeometry>` — `x`,`y` position, `width`,`height` size.

## An edge (connection)

```xml
<mxCell id="e1" value="calls" style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;endArrow=block;"
        edge="1" parent="1" source="n1" target="n2">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```
- `source` / `target` — the `id`s of the connected vertices.
- `value` — optional edge label.
- styles: `endArrow=block|open|none`, `startArrow=...`, `dashed=1`.

## Editing rules of thumb
- Keep existing `id`s stable; generate new unique ids for added cells (`n2`, `e3`, …).
- To relabel, edit only the target cell's `value`. To move, edit its `<mxGeometry>` `x`/`y`.
- To connect two existing nodes, add one edge cell with their ids as `source`/`target`.
- Validate by re-opening in draw.io (or rendering — see SKILL.md Render).

## Compressed diagrams
If a `<diagram>` body is a base64 blob instead of `<mxGraphModel>`, it's deflate-compressed. Easiest fix: open in the app and **Extras → Edit Diagram** (or toggle compression off) and re-save. Then it's plain XML you can edit here.

## Offline viewer (no SaaS)
For a fully offline HTML preview, vendor the viewer once:
```bash
curl -fsSL https://viewer.diagrams.net/js/viewer-static.min.js -o viewer-static.min.js
```
Then in the preview HTML use `<script src="./viewer-static.min.js"></script>` instead of the CDN URL. The diagram XML stays entirely local.
