# /// script
# dependencies = []
# ///
"""Generate .canvas files programmatically from vault data.

Usage:
  canvas_gen.py knowledge-map [--folder FOLDER] [--category CATEGORY] [--output PATH]
  canvas_gen.py project-map [--output PATH]
  canvas_gen.py from-links NOTE_PATH [--depth DEPTH] [--output PATH]
"""

import argparse
import json
import os
import re
import sys
import uuid
from pathlib import Path


# -- Config -------------------------------------------------------------------

def load_env() -> None:
    env_path = Path.home() / ".env"
    if not env_path.exists():
        return
    with open(env_path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            os.environ.setdefault(key.strip(), value.strip())


load_env()
VAULT_ROOT = Path(os.environ.get("OBSIDIAN_VAULT_PATH", ""))

# Canvas layout constants
CARD_W = 300
CARD_H = 120
GAP_X = 60
GAP_Y = 40
GROUP_PAD = 40

# Color presets by knowledge level
KNOWLEDGE_COLORS = {
    "mastered": "4",    # green
    "applied": "5",     # cyan
    "understood": "3",  # yellow
    "familiar": "2",    # orange
    "reference": "1",   # red (default)
}

MATURITY_COLORS = {
    "atomic": "6",      # purple
    "evergreen": "4",   # green
    "growing": "3",     # yellow
    "seedling": "2",    # orange
    "map": "5",         # cyan
}


def _uid() -> str:
    return uuid.uuid4().hex[:16]


def _parse_frontmatter(path: Path) -> dict:
    """Extract YAML frontmatter as dict (basic parser, no deps)."""
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return {}
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    fm = {}
    current_key = None
    current_list = None
    for line in text[4:end].split("\n"):
        if not line.strip():
            continue
        # List item
        if line.startswith("  - ") and current_key:
            val = line.strip()[2:].strip().strip('"').strip("'")
            # Strip [[...]] wikilink syntax
            m = re.match(r'\[\[([^\]|]+)(?:\|[^\]]+)?\]\]', val)
            if m:
                val = m.group(1)
            if current_list is None:
                current_list = []
            current_list.append(val)
            fm[current_key] = current_list
            continue
        # Key: value
        if ":" in line and not line.startswith(" "):
            if current_list is not None:
                current_list = None
            key, _, val = line.partition(":")
            current_key = key.strip()
            val = val.strip().strip('"').strip("'")
            if val == "[]":
                fm[current_key] = []
            elif val:
                fm[current_key] = val
            else:
                fm[current_key] = ""
    return fm


def _find_notes(folder: str = "Areas", category: str | None = None) -> list[dict]:
    """Find notes with their frontmatter."""
    vault = VAULT_ROOT
    if not vault.exists():
        print(f"Error: Vault not found at {vault}", file=sys.stderr)
        sys.exit(1)

    target = vault / folder
    if not target.exists():
        print(f"Error: Folder {folder} not found", file=sys.stderr)
        sys.exit(1)

    notes = []
    for md in sorted(target.glob("*.md")):
        fm = _parse_frontmatter(md)
        if category:
            cats = fm.get("categories", [])
            if isinstance(cats, str):
                cats = [cats]
            if not any(category.lower() in c.lower() for c in cats):
                continue
        notes.append({
            "path": str(md.relative_to(vault)),
            "name": md.stem,
            "frontmatter": fm,
        })
    return notes


def _build_canvas(nodes: list[dict], edges: list[dict]) -> dict:
    return {"nodes": nodes, "edges": edges}


# -- Commands -----------------------------------------------------------------

def cmd_knowledge_map(args) -> None:
    """Generate a canvas grouping notes by category with color-coded knowledge level."""
    notes = _find_notes(args.folder, args.category)
    if not notes:
        print("No notes found matching criteria.")
        return

    # Group by first category
    groups: dict[str, list] = {}
    for n in notes:
        cats = n["frontmatter"].get("categories", [])
        cat = cats[0] if isinstance(cats, list) and cats else "Uncategorized"
        groups.setdefault(cat, []).append(n)

    canvas_nodes = []
    canvas_edges = []
    group_x = 0

    for group_name, group_notes in sorted(groups.items()):
        cols = min(4, max(1, len(group_notes)))
        rows = (len(group_notes) + cols - 1) // cols

        group_w = cols * (CARD_W + GAP_X) + GROUP_PAD
        group_h = rows * (CARD_H + GAP_Y) + GROUP_PAD + 60  # 60 for label

        # Group node (collapsible via advanced-canvas plugin)
        canvas_nodes.append({
            "id": _uid(),
            "type": "group",
            "x": group_x, "y": 0,
            "width": group_w, "height": group_h,
            "label": group_name,
            "collapsed": False,
        })

        # Card nodes
        for i, note in enumerate(group_notes):
            col = i % cols
            row = i // cols
            x = group_x + GROUP_PAD // 2 + col * (CARD_W + GAP_X)
            y = 50 + row * (CARD_H + GAP_Y)

            knowledge = note["frontmatter"].get("knowledge", "reference")
            color = KNOWLEDGE_COLORS.get(knowledge, "1")

            canvas_nodes.append({
                "id": _uid(),
                "type": "file",
                "file": note["path"],
                "x": x, "y": y,
                "width": CARD_W, "height": CARD_H,
                "color": color,
            })

        group_x += group_w + GAP_X * 2

    canvas = _build_canvas(canvas_nodes, canvas_edges)
    output = args.output or str(VAULT_ROOT / "Resources" / "Canvas" / "Knowledge Map.canvas")
    Path(output).parent.mkdir(parents=True, exist_ok=True)
    Path(output).write_text(json.dumps(canvas, indent=2, ensure_ascii=False))
    print(f"Canvas written to {output}")
    print(f"  {len(notes)} notes in {len(groups)} groups")
    print(f"  Color legend: red=reference, orange=familiar, yellow=understood, cyan=applied, green=mastered")


def cmd_project_map(args) -> None:
    """Generate a canvas of all projects with status colors."""
    notes = _find_notes("Projects")
    if not notes:
        print("No projects found.")
        return

    canvas_nodes = []
    for i, note in enumerate(notes):
        col = i % 5
        row = i // 5
        canvas_nodes.append({
            "id": _uid(),
            "type": "file",
            "file": note["path"],
            "x": col * (CARD_W + GAP_X),
            "y": row * (CARD_H + GAP_Y),
            "width": CARD_W, "height": CARD_H,
        })

    canvas = _build_canvas(canvas_nodes, [])
    output = args.output or str(VAULT_ROOT / "Resources" / "Canvas" / "Project Map.canvas")
    Path(output).parent.mkdir(parents=True, exist_ok=True)
    Path(output).write_text(json.dumps(canvas, indent=2, ensure_ascii=False))
    print(f"Canvas written to {output} ({len(notes)} projects)")


def cmd_from_links(args) -> None:
    """Generate a canvas from a note and its outgoing links (graph neighborhood)."""
    vault = VAULT_ROOT
    note_path = Path(args.note_path)
    if not note_path.is_absolute():
        note_path = vault / note_path

    if not note_path.exists():
        print(f"Error: {note_path} not found", file=sys.stderr)
        sys.exit(1)

    depth = args.depth
    visited: set[str] = set()
    to_visit = [(str(note_path.relative_to(vault)), 0)]
    all_notes: dict[str, dict] = {}
    all_edges: list[tuple[str, str]] = []

    # Build file stem -> path index
    stem_index: dict[str, str] = {}
    for md in vault.rglob("*.md"):
        if ".git" in md.parts or ".obsidian" in md.parts:
            continue
        rel = str(md.relative_to(vault))
        stem_index[md.stem] = rel

    while to_visit:
        rel_path, d = to_visit.pop(0)
        if rel_path in visited:
            continue
        visited.add(rel_path)

        full = vault / rel_path
        if not full.exists():
            continue

        fm = _parse_frontmatter(full)
        all_notes[rel_path] = {"name": full.stem, "path": rel_path, "frontmatter": fm}

        if d >= depth:
            continue

        # Find outgoing wikilinks
        try:
            text = full.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        for match in re.finditer(r"\[\[([^\]|]+)(?:\|[^\]]+)?\]\]", text):
            target_name = match.group(1).strip()
            target_path = stem_index.get(target_name)
            if target_path:
                all_edges.append((rel_path, target_path))
                if target_path not in visited:
                    to_visit.append((target_path, d + 1))

    # Layout: center node + radial
    canvas_nodes = []
    canvas_edges = []
    node_ids: dict[str, str] = {}

    note_list = list(all_notes.keys())
    center = args.note_path if not Path(args.note_path).is_absolute() else str(note_path.relative_to(vault))

    for i, rel_path in enumerate(note_list):
        nid = _uid()
        node_ids[rel_path] = nid

        if rel_path == center or (i == 0 and center not in note_list):
            x, y = 0, 0
            w, h = CARD_W + 100, CARD_H + 40
        else:
            import math
            angle = 2 * math.pi * (i - 1) / max(1, len(note_list) - 1)
            radius = 400
            x = int(radius * math.cos(angle))
            y = int(radius * math.sin(angle))
            w, h = CARD_W, CARD_H

        knowledge = all_notes[rel_path]["frontmatter"].get("knowledge", "reference")
        color = KNOWLEDGE_COLORS.get(knowledge, "1")

        canvas_nodes.append({
            "id": nid,
            "type": "file",
            "file": rel_path,
            "x": x, "y": y,
            "width": w, "height": h,
            "color": color,
        })

    for src, dst in all_edges:
        if src in node_ids and dst in node_ids:
            canvas_edges.append({
                "id": _uid(),
                "fromNode": node_ids[src],
                "fromSide": "right",
                "toNode": node_ids[dst],
                "toSide": "left",
            })

    canvas = _build_canvas(canvas_nodes, canvas_edges)
    output = args.output or str(VAULT_ROOT / "Resources" / "Canvas" / f"{note_path.stem} Map.canvas")
    Path(output).parent.mkdir(parents=True, exist_ok=True)
    Path(output).write_text(json.dumps(canvas, indent=2, ensure_ascii=False))
    print(f"Canvas written to {output}")
    print(f"  {len(canvas_nodes)} nodes, {len(canvas_edges)} edges (depth={depth})")


# -- Entry point --------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Generate Obsidian .canvas files")
    sub = parser.add_subparsers(dest="command", required=True)

    p_km = sub.add_parser("knowledge-map", help="Group notes by category, color by knowledge level")
    p_km.add_argument("--folder", default="Areas")
    p_km.add_argument("--category", default=None, help="Filter to specific category")
    p_km.add_argument("--output", default=None)

    p_pm = sub.add_parser("project-map", help="Layout all projects")
    p_pm.add_argument("--output", default=None)

    p_fl = sub.add_parser("from-links", help="Generate canvas from a note's link neighborhood")
    p_fl.add_argument("note_path")
    p_fl.add_argument("--depth", type=int, default=1)
    p_fl.add_argument("--output", default=None)

    args = parser.parse_args()
    {
        "knowledge-map": cmd_knowledge_map,
        "project-map": cmd_project_map,
        "from-links": cmd_from_links,
    }[args.command](args)


if __name__ == "__main__":
    main()
