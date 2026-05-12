# /// script
# dependencies = []
# ///
"""Advanced vault operations — bulk property edits, link analysis, structure validation.

Usage:
  vault_ops.py property-set PROPERTY VALUE [--folder FOLDER] [--filter PROP=VAL]
  vault_ops.py property-remove PROPERTY [--folder FOLDER]
  vault_ops.py property-stats [--folder FOLDER]
  vault_ops.py link-graph [--folder FOLDER] [--format dot|json]
  vault_ops.py structure-check [--expected FOLDER1,FOLDER2,...]
  vault_ops.py frontmatter-fix [--folder FOLDER] [--dry-run]
"""

import argparse
import json
import os
import re
import sys
from collections import Counter, defaultdict
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
IGNORE_DIRS = {".obsidian", ".git", ".archive", ".trash", ".claude", ".vscode", ".docs", "node_modules"}


def _iter_notes(folder: str | None = None) -> list[Path]:
    """Iterate markdown files in vault, optionally filtered by folder."""
    root = VAULT_ROOT / folder if folder else VAULT_ROOT
    notes = []
    for md in sorted(root.rglob("*.md")):
        if any(p in IGNORE_DIRS for p in md.relative_to(VAULT_ROOT).parts):
            continue
        notes.append(md)
    return notes


def _parse_frontmatter_raw(path: Path) -> tuple[str | None, str | None, str | None]:
    """Return (pre_fm, fm_content, post_fm) or (None, None, full_content)."""
    text = path.read_text(encoding="utf-8", errors="ignore")
    if not text.startswith("---"):
        return None, None, text
    end = text.find("\n---", 3)
    if end == -1:
        return None, None, text
    pre = "---\n"
    fm = text[4:end]
    post = text[end + 4:]
    return pre, fm, post


def _write_frontmatter(path: Path, pre: str, fm: str, post: str) -> None:
    path.write_text(pre + fm + "\n---" + post, encoding="utf-8")


# -- Commands -----------------------------------------------------------------

def cmd_property_set(args) -> None:
    """Set a property on all notes in a folder."""
    notes = _iter_notes(args.folder)
    prop = args.property
    value = args.value
    updated = 0
    skipped = 0

    for note in notes:
        pre, fm, post = _parse_frontmatter_raw(note)
        if fm is None:
            # No frontmatter — add it
            path_content = post or ""
            note.write_text(f"---\n{prop}: {value}\n---\n{path_content}", encoding="utf-8")
            updated += 1
            continue

        # Check filter
        if args.filter:
            fkey, _, fval = args.filter.partition("=")
            pattern = re.compile(rf'^{re.escape(fkey.strip())}:\s*{re.escape(fval.strip())}', re.MULTILINE)
            if not pattern.search(fm):
                skipped += 1
                continue

        # Check if property exists
        prop_pattern = re.compile(rf'^{re.escape(prop)}:.*$', re.MULTILINE)
        if prop_pattern.search(fm):
            fm = prop_pattern.sub(f"{prop}: {value}", fm)
        else:
            fm = fm.rstrip("\n") + f"\n{prop}: {value}"

        _write_frontmatter(note, pre, fm, post)
        updated += 1

    print(f"Updated: {updated}, Skipped: {skipped}")


def cmd_property_remove(args) -> None:
    """Remove a property from all notes in a folder."""
    notes = _iter_notes(args.folder)
    prop = args.property
    removed = 0

    for note in notes:
        pre, fm, post = _parse_frontmatter_raw(note)
        if fm is None:
            continue

        prop_pattern = re.compile(rf'^{re.escape(prop)}:.*\n?', re.MULTILINE)
        new_fm = prop_pattern.sub("", fm)
        if new_fm != fm:
            _write_frontmatter(note, pre, new_fm, post)
            removed += 1

    print(f"Removed '{prop}' from {removed} notes")


def cmd_property_stats(args) -> None:
    """Show property usage statistics."""
    notes = _iter_notes(args.folder)
    prop_counts: Counter = Counter()
    prop_values: dict[str, Counter] = defaultdict(Counter)
    total = 0

    for note in notes:
        pre, fm, post = _parse_frontmatter_raw(note)
        if fm is None:
            continue
        total += 1
        for line in fm.split("\n"):
            if ":" in line and not line.startswith(" ") and not line.startswith("-"):
                key, _, val = line.partition(":")
                key = key.strip()
                val = val.strip().strip('"').strip("'")
                prop_counts[key] += 1
                if val and val != "[]":
                    prop_values[key][val] += 1

    print(f"\nProperty stats ({total} notes in {args.folder or 'vault'}):")
    print(f"{'Property':<25} {'Count':>6} {'Coverage':>8}  Top values")
    print("-" * 80)
    for prop, count in prop_counts.most_common(20):
        coverage = f"{count/total*100:.0f}%" if total else "0%"
        top = prop_values[prop].most_common(3)
        top_str = ", ".join(f"{v}({c})" for v, c in top) if top else "(empty)"
        print(f"  {prop:<23} {count:>6} {coverage:>8}  {top_str[:50]}")


def cmd_link_graph(args) -> None:
    """Generate a link graph in DOT or JSON format."""
    notes = _iter_notes(args.folder)
    stem_to_path: dict[str, str] = {}
    edges: list[tuple[str, str]] = []

    for note in notes:
        rel = str(note.relative_to(VAULT_ROOT))
        stem_to_path[note.stem] = rel

    for note in notes:
        rel = str(note.relative_to(VAULT_ROOT))
        try:
            text = note.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        for match in re.finditer(r"\[\[([^\]|]+)(?:\|[^\]]+)?\]\]", text):
            target = match.group(1).strip()
            if target in stem_to_path:
                edges.append((rel, stem_to_path[target]))

    if args.format == "dot":
        print("digraph vault {")
        print("  rankdir=LR;")
        seen_nodes = set()
        for src, dst in edges:
            for n in (src, dst):
                if n not in seen_nodes:
                    label = Path(n).stem
                    print(f'  "{n}" [label="{label}"];')
                    seen_nodes.add(n)
            print(f'  "{src}" -> "{dst}";')
        print("}")
    else:
        graph = {"nodes": list(stem_to_path.values()), "edges": [{"from": s, "to": d} for s, d in edges]}
        print(json.dumps(graph, indent=2))

    print(f"\n# {len(stem_to_path)} nodes, {len(edges)} edges", file=sys.stderr)


def cmd_structure_check(args) -> None:
    """Validate vault structure against conventions."""
    vault = VAULT_ROOT
    issues: list[str] = []

    # Expected top-level folders (configurable via --expected flag)
    if args.expected:
        expected = set(args.expected.split(","))
    else:
        # Auto-detect: just check for loose files, empty dirs, nested .obsidian
        expected = set()

    actual = {d.name for d in vault.iterdir() if d.is_dir() and not d.name.startswith(".")}

    if expected:
        missing = expected - actual
        extra = actual - expected
        if missing:
            issues.append(f"Missing expected folders: {', '.join(sorted(missing))}")
        if extra:
            issues.append(f"Extra top-level folders: {', '.join(sorted(extra))}")

    # Root-level loose files
    root_files = [f.name for f in vault.iterdir() if f.is_file() and not f.name.startswith(".")]
    if root_files:
        issues.append(f"Loose files at root: {', '.join(root_files)}")

    # Check for notes without frontmatter in common content folders
    for folder_name in ["Areas", "Projects"]:
        folder = vault / folder_name
        if folder.exists():
            no_fm = 0
            for md in folder.glob("*.md"):
                text = md.read_text(encoding="utf-8", errors="ignore")
                if not text.startswith("---"):
                    no_fm += 1
            if no_fm:
                issues.append(f"{folder_name}: {no_fm} notes without frontmatter")

    # Empty folders
    for d in vault.rglob("*"):
        if not d.is_dir():
            continue
        if any(p in IGNORE_DIRS for p in d.relative_to(vault).parts):
            continue
        if not any(d.iterdir()):
            issues.append(f"Empty folder: {d.relative_to(vault)}")

    # Nested .obsidian
    for obs in vault.rglob(".obsidian"):
        if obs.parent != vault:
            issues.append(f"Nested .obsidian config: {obs.relative_to(vault)}")

    if issues:
        print(f"Found {len(issues)} issues:")
        for issue in issues:
            print(f"  - {issue}")
    else:
        print("Vault structure OK")


def cmd_frontmatter_fix(args) -> None:
    """Find and report frontmatter issues (unclosed, missing, malformed)."""
    notes = _iter_notes(args.folder)
    issues = []

    for note in notes:
        rel = note.relative_to(VAULT_ROOT)
        text = note.read_text(encoding="utf-8", errors="ignore")

        if not text.startswith("---"):
            if text.strip().startswith("---"):
                issues.append((rel, "frontmatter preceded by whitespace"))
            elif "---" in text[:200]:
                issues.append((rel, "frontmatter not on line 1"))
            else:
                issues.append((rel, "no frontmatter"))
            continue

        end = text.find("\n---", 3)
        if end == -1:
            issues.append((rel, "unclosed frontmatter (no closing ---)"))
            if not args.dry_run:
                # Find where YAML ends
                lines = text.split("\n")
                yaml_end = 1
                for i in range(1, len(lines)):
                    line = lines[i]
                    if re.match(r'^(\w[\w\s-]*:.*|\s+-\s+.*|\s+.*|\s*)$', line):
                        yaml_end = i + 1
                    else:
                        break
                lines.insert(yaml_end, "---")
                note.write_text("\n".join(lines), encoding="utf-8")
                issues[-1] = (rel, "unclosed frontmatter — FIXED")

    if issues:
        print(f"Found {len(issues)} frontmatter issues:")
        for rel, issue in issues:
            print(f"  {rel}: {issue}")
    else:
        print("All frontmatter OK")


# -- Entry point --------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Advanced Obsidian vault operations")
    sub = parser.add_subparsers(dest="command", required=True)

    p_set = sub.add_parser("property-set", help="Set a property on notes")
    p_set.add_argument("property")
    p_set.add_argument("value")
    p_set.add_argument("--folder", default=None)
    p_set.add_argument("--filter", default=None, help="Only update notes matching PROP=VAL")

    p_rm = sub.add_parser("property-remove", help="Remove a property from notes")
    p_rm.add_argument("property")
    p_rm.add_argument("--folder", default=None)

    p_stats = sub.add_parser("property-stats", help="Show property usage stats")
    p_stats.add_argument("--folder", default=None)

    p_graph = sub.add_parser("link-graph", help="Generate link graph")
    p_graph.add_argument("--folder", default=None)
    p_graph.add_argument("--format", default="json", choices=["dot", "json"])

    p_check = sub.add_parser("structure-check", help="Validate vault structure")
    p_check.add_argument("--expected", default=None, help="Comma-separated expected top-level folders")

    p_fix = sub.add_parser("frontmatter-fix", help="Find/fix frontmatter issues")
    p_fix.add_argument("--folder", default=None)
    p_fix.add_argument("--dry-run", action="store_true")

    args = parser.parse_args()
    {
        "property-set": cmd_property_set,
        "property-remove": cmd_property_remove,
        "property-stats": cmd_property_stats,
        "link-graph": cmd_link_graph,
        "structure-check": cmd_structure_check,
        "frontmatter-fix": cmd_frontmatter_fix,
    }[args.command](args)


if __name__ == "__main__":
    main()
