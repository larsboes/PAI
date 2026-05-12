# /// script
# dependencies = ["pyyaml"]
# ///
"""Generate and manage .base files for Obsidian Bases plugin.

Usage:
  base_gen.py create --name NAME --folder FOLDER [--view TYPE] [--filter EXPR] [--group-by PROP] [--sort PROP]
  base_gen.py from-template TEMPLATE [--name NAME] [--folder FOLDER]
  base_gen.py list
  base_gen.py validate [BASE_PATH]
"""

import argparse
import os
import sys
from pathlib import Path

import yaml


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


# -- Templates ----------------------------------------------------------------

TEMPLATES = {
    "areas-knowledge": {
        "description": "Areas notes filtered by knowledge level",
        "filter": 'file.folder = "Areas"',
        "formulas": {
            "status": 'if(note.knowledge == "mastered", icon("check-circle"), if(note.knowledge == "applied", icon("zap"), if(note.knowledge == "understood", icon("brain"), if(note.knowledge == "familiar", icon("eye"), icon("book-open")))))',
        },
        "views": [{
            "type": "table",
            "name": "All Areas",
            "order": [{"property": "note.knowledge", "direction": "desc"}],
        }, {
            "type": "cards",
            "name": "Gallery",
            "groupBy": {"property": "note.knowledge", "direction": "desc"},
        }],
    },
    "areas-by-category": {
        "description": "Areas grouped by category",
        "filter": 'file.folder = "Areas"',
        "views": [{
            "type": "table",
            "name": "By Category",
            "groupBy": {"property": "note.categories", "direction": "asc"},
            "order": [{"property": "note.maturity", "direction": "desc"}],
        }],
    },
    "areas-work": {
        "description": "Work-scoped Areas notes",
        "filter": {
            "and": [
                'file.folder = "Areas"',
                'note.scope == "work"',
            ]
        },
        "views": [{
            "type": "table",
            "name": "Work Knowledge",
            "order": [{"property": "note.knowledge", "direction": "desc"}],
        }],
    },
    "projects": {
        "description": "Project tracker",
        "filter": 'file.folder = "Projects"',
        "views": [{
            "type": "table",
            "name": "All Projects",
            "order": [{"property": "note.status", "direction": "asc"}],
        }, {
            "type": "cards",
            "name": "Board",
            "groupBy": {"property": "note.status", "direction": "asc"},
        }],
    },
    "learning": {
        "description": "Learning modules tracker",
        "filter": 'file.path.contains("Learning/")',
        "formulas": {
            "progress": 'if(note.status == "completed", "Done", if(note.status == "in-progress", "Active", "Not started"))',
        },
        "views": [{
            "type": "table",
            "name": "Modules",
            "order": [{"property": "note.course", "direction": "asc"}],
            "groupBy": {"property": "note.course", "direction": "asc"},
        }],
    },
    "people": {
        "description": "People directory",
        "filter": 'file.folder = "People"',
        "views": [{
            "type": "table",
            "name": "Directory",
            "order": [{"property": "file.name", "direction": "asc"}],
        }],
    },
    "tasks": {
        "description": "Task tracker",
        "filter": 'file.folder = "Tasks"',
        "views": [{
            "type": "table",
            "name": "All Tasks",
            "order": [{"property": "note.priority", "direction": "desc"}],
        }, {
            "type": "table",
            "name": "Active",
            "filters": 'note.status != "done"',
            "order": [{"property": "note.priority", "direction": "desc"}],
        }],
    },
    "recent": {
        "description": "Recently modified notes",
        "filter": 'file.mtime > now() - "7d"',
        "views": [{
            "type": "table",
            "name": "Last 7 Days",
            "order": [{"property": "file.mtime", "direction": "desc"}],
            "limit": 50,
        }],
    },
    "journal": {
        "description": "Journal entries",
        "filter": 'file.folder = "Journal"',
        "views": [{
            "type": "table",
            "name": "All Entries",
            "order": [{"property": "file.name", "direction": "desc"}],
        }],
    },
}


# -- Commands -----------------------------------------------------------------

def cmd_create(args) -> None:
    """Create a .base file from parameters."""
    base = {}

    if args.filter:
        base["filter"] = args.filter

    view = {"type": args.view, "name": args.name}
    if args.sort:
        view["order"] = [{"property": args.sort, "direction": args.sort_dir}]
    if args.group_by:
        view["groupBy"] = {"property": args.group_by, "direction": "asc"}

    base["views"] = [view]

    output = VAULT_ROOT / args.folder / f"{args.name}.base"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(yaml.dump(base, default_flow_style=False, allow_unicode=True, sort_keys=False))
    print(f"Created {output}")


def cmd_from_template(args) -> None:
    """Create a .base file from a built-in template."""
    template_name = args.template
    if template_name not in TEMPLATES:
        print(f"Unknown template: {template_name}")
        print(f"Available: {', '.join(TEMPLATES.keys())}")
        sys.exit(1)

    template = TEMPLATES[template_name]
    name = args.name or template_name.replace("-", " ").title()
    folder = args.folder or "Resources/Bases"

    base = {k: v for k, v in template.items() if k != "description"}

    output = VAULT_ROOT / folder / f"{name}.base"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(yaml.dump(base, default_flow_style=False, allow_unicode=True, sort_keys=False))
    print(f"Created {output} (template: {template_name})")
    print(f"  {template['description']}")


def cmd_list(args) -> None:
    """List all .base files in the vault."""
    vault = VAULT_ROOT
    if not vault.exists():
        print(f"Error: Vault not found at {vault}", file=sys.stderr)
        sys.exit(1)

    bases = sorted(vault.rglob("*.base"))
    if not bases:
        print("No .base files found in vault.")
        return

    print(f"Found {len(bases)} base files:")
    for b in bases:
        rel = b.relative_to(vault)
        size = b.stat().st_size
        try:
            content = yaml.safe_load(b.read_text(encoding="utf-8"))
            views = content.get("views", [])
            view_names = [v.get("name", v.get("type", "?")) for v in views]
            print(f"  {rel} ({size}B) — views: {', '.join(view_names)}")
        except Exception:
            print(f"  {rel} ({size}B) — parse error")


def cmd_validate(args) -> None:
    """Validate .base file syntax."""
    vault = VAULT_ROOT
    if args.base_path:
        bases = [Path(args.base_path)]
    else:
        bases = sorted(vault.rglob("*.base"))

    errors = 0
    for b in bases:
        rel = b.relative_to(vault) if str(b).startswith(str(vault)) else b
        try:
            content = yaml.safe_load(b.read_text(encoding="utf-8"))
            if not isinstance(content, dict):
                print(f"  FAIL {rel}: root is not a mapping")
                errors += 1
                continue

            views = content.get("views", [])
            if views and not isinstance(views, list):
                print(f"  FAIL {rel}: 'views' is not a list")
                errors += 1
                continue

            valid_types = {"table", "cards", "list", "map"}
            for i, v in enumerate(views):
                vtype = v.get("type", "")
                if vtype not in valid_types:
                    print(f"  WARN {rel}: view[{i}] has unknown type '{vtype}'")

            print(f"  OK   {rel} ({len(views)} views)")
        except yaml.YAMLError as e:
            print(f"  FAIL {rel}: YAML error — {e}")
            errors += 1
        except Exception as e:
            print(f"  FAIL {rel}: {e}")
            errors += 1

    print(f"\nValidated {len(bases)} files, {errors} errors")


def cmd_templates(args) -> None:
    """List available templates."""
    print("Available templates:")
    for name, tmpl in TEMPLATES.items():
        views = tmpl.get("views", [])
        vtypes = [v.get("type", "?") for v in views]
        print(f"  {name:25s} — {tmpl['description']} [{', '.join(vtypes)}]")


# -- Entry point --------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Obsidian Bases generator")
    sub = parser.add_subparsers(dest="command", required=True)

    p_create = sub.add_parser("create", help="Create a base from parameters")
    p_create.add_argument("--name", required=True)
    p_create.add_argument("--folder", default="Resources/Bases")
    p_create.add_argument("--view", default="table", choices=["table", "cards", "list", "map"])
    p_create.add_argument("--filter", default=None)
    p_create.add_argument("--group-by", default=None)
    p_create.add_argument("--sort", default=None)
    p_create.add_argument("--sort-dir", default="asc", choices=["asc", "desc"])

    p_tmpl = sub.add_parser("from-template", help="Create from built-in template")
    p_tmpl.add_argument("template")
    p_tmpl.add_argument("--name", default=None)
    p_tmpl.add_argument("--folder", default=None)

    sub.add_parser("list", help="List all .base files")

    p_val = sub.add_parser("validate", help="Validate .base files")
    p_val.add_argument("base_path", nargs="?", default=None)

    sub.add_parser("templates", help="List available templates")

    args = parser.parse_args()
    {
        "create": cmd_create,
        "from-template": cmd_from_template,
        "list": cmd_list,
        "validate": cmd_validate,
        "templates": cmd_templates,
    }[args.command](args)


if __name__ == "__main__":
    main()
