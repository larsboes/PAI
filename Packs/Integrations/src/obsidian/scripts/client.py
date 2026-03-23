# /// script
# dependencies = []
# ///
"""Obsidian vault CLI — search, backlinks, daily note, active file, open, health."""

import argparse
import datetime
import os
import re
import shutil
import subprocess
import sys
from collections import defaultdict
from pathlib import Path


# ── Config ───────────────────────────────────────────────────────────────────

def load_env() -> None:
    """Load ~/.env into os.environ without overriding existing vars."""
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

VAULT_ROOT = os.environ.get("OBSIDIAN_VAULT_PATH", "")
OBSIDIAN_BIN = os.environ.get("OBSIDIAN_BIN", "/Applications/Obsidian.app/Contents/MacOS/Obsidian")
RG_PATH = shutil.which("rg") or "rg"

HEALTH_IGNORE_DIRS = {".obsidian", ".git", "node_modules"}
HEALTH_IGNORE_FILES = {"Home Dashboard.md"}


def _require_vault() -> str:
    if not VAULT_ROOT:
        print("Error: OBSIDIAN_VAULT_PATH not set in ~/.env", file=sys.stderr)
        sys.exit(1)
    if not os.path.exists(VAULT_ROOT):
        print(f"Error: Vault not found at {VAULT_ROOT}", file=sys.stderr)
        sys.exit(1)
    return VAULT_ROOT


# ── Obsidian CLI wrapper ──────────────────────────────────────────────────────

def run_obsidian_cli(args: list[str]) -> str | None:
    if not os.path.exists(OBSIDIAN_BIN):
        print(f"Error: Obsidian binary not found at {OBSIDIAN_BIN}", file=sys.stderr)
        return None
    try:
        result = subprocess.run([OBSIDIAN_BIN] + args, capture_output=True, text=True)
        lines = result.stdout.strip().split("\n")
        clean = [l for l in lines if not l.startswith("202")]  # filter timestamp noise
        return "\n".join(clean).strip()
    except Exception as e:
        print(f"Obsidian CLI error: {e}", file=sys.stderr)
        return None


# ── Commands ──────────────────────────────────────────────────────────────────

def cmd_search(args) -> None:
    vault = _require_vault()
    print(f"Searching for '{args.query}' in vault...")
    try:
        cmd = [
            RG_PATH, "-i", "--no-heading", "--line-number",
            "--max-count", "3",
            "--glob", "!.git/*", "--glob", "!.obsidian/*",
            args.query, vault,
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        output = result.stdout.strip()
        if not output:
            print("No results found.")
            return
        lines = output.split("\n")
        print(f"Found {len(lines)} matches (showing top 20):")
        for line in lines[:20]:
            if line.startswith(vault):
                line = line[len(vault) + 1:]
            print(f"  {line}")
        if len(lines) > 20:
            print(f"  ... and {len(lines) - 20} more matches.")
    except Exception as e:
        print(f"Search failed: {e}")


def cmd_backlinks(args) -> None:
    vault = _require_vault()
    basename = os.path.basename(args.path)
    name_no_ext = os.path.splitext(basename)[0]
    pattern = rf"\[\[{re.escape(name_no_ext)}(\|.*)?\]\]"
    print(f"Searching backlinks to '{name_no_ext}'...")
    try:
        cmd = [
            RG_PATH, "-l",
            "--glob", "!.git/*", "--glob", "!.obsidian/*",
            pattern, vault,
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        output = result.stdout.strip()
        if not output:
            print("No backlinks found.")
            return
        files = [f for f in output.split("\n") if os.path.basename(f) != basename]
        print(f"Found {len(files)} backlinks:")
        for f in files:
            if f.startswith(vault):
                f = f[len(vault) + 1:]
            print(f"  - {f}")
    except Exception as e:
        print(f"Backlinks search failed: {e}")


def cmd_daily(args) -> None:
    vault = _require_vault()
    path_rel = run_obsidian_cli(["daily", "silent"])
    if path_rel:
        print(os.path.join(vault, path_rel))
    else:
        today = datetime.date.today().strftime("%Y-%m-%d")
        print(f"{vault}/Journal/01. Daily Notes/{today}.md")


def cmd_active(args) -> None:
    _require_vault()
    output = run_obsidian_cli(["file"])
    if not output:
        print("Could not get active file (Obsidian might not be running).")
        return
    data = {}
    for line in output.split("\n"):
        parts = line.split("\t", 1)
        if len(parts) == 2:
            data[parts[0].strip()] = parts[1].strip()
    if "path" in data:
        print(f"Active file: {data['path']}")
        print(f"Full path:   {os.path.join(VAULT_ROOT, data['path'])}")
    else:
        print("No active file info returned.")


def cmd_open(args) -> None:
    path = args.path
    if path.startswith(VAULT_ROOT):
        path = path[len(VAULT_ROOT) + 1:]
    run_obsidian_cli(["open", f"path={path}"])
    print(f"Opened {path}")


def cmd_health(args) -> None:
    vault = Path(_require_vault())

    # Scan files
    files: list[Path] = []
    duplicates: dict[str, list] = defaultdict(list)
    for md_file in vault.rglob("*.md"):
        if any(part in HEALTH_IGNORE_DIRS for part in md_file.parts):
            continue
        if md_file.name in HEALTH_IGNORE_FILES:
            continue
        rel = md_file.relative_to(vault)
        files.append(rel)
        duplicates[md_file.stem].append(rel)

    # Scan wikilinks
    file_stems = {f.stem: f for f in files}
    file_strs = {str(f).replace("\\", "/"): f for f in files}
    wikilinks: dict = defaultdict(set)
    references: dict = defaultdict(set)
    broken_links: list = []

    for file_path in files:
        try:
            content = (vault / file_path).read_text(encoding="utf-8", errors="ignore")
            for match in re.finditer(r"\[\[([^\]]+)\]\]", content):
                note_name = match.group(1).split("|")[0].strip()
                wikilinks[file_path].add(note_name)
                target = (
                    file_stems.get(note_name)
                    or file_strs.get(note_name)
                    or file_strs.get(note_name + ".md")
                )
                if target:
                    references[target].add(file_path)
                else:
                    broken_links.append((file_path, note_name))
        except Exception:
            pass

    # Orphans — no incoming or outgoing links
    orphaned = {f for f in files if not (references.get(f) or wikilinks.get(f))}

    # Stats
    total_size = sum((vault / f).stat().st_size for f in files if (vault / f).exists())
    avg_size = total_size // max(1, len(files))
    dir_counts: dict = defaultdict(int)
    for f in files:
        dir_counts[f.parent if f.parent != Path(".") else Path("(root)")] += 1

    def fmt(b: int) -> str:
        for unit in ["B", "KB", "MB", "GB"]:
            if b < 1024:
                return f"{b:.1f} {unit}"
            b //= 1024
        return f"{b:.1f} TB"

    print("\n📊 Obsidian Vault Health Report")
    print("=" * 40)
    print(f"\n📁 Statistics")
    print(f"  Total files: {len(files)}")
    print(f"  Vault size:  {fmt(total_size)}")
    print(f"  Avg file:    {fmt(avg_size)}")
    for d, c in sorted(dir_counts.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"    - {d}: {c} files")

    if orphaned:
        print(f"\n🔴 Orphaned Notes ({len(orphaned)} found)")
        for n in sorted(orphaned)[:10]:
            print(f"  - {n}")
        if len(orphaned) > 10:
            print(f"  ... and {len(orphaned) - 10} more")
    else:
        print(f"\n🟢 No orphaned notes")

    if broken_links:
        seen: set = set()
        print(f"\n🟡 Broken Wikilinks ({len(broken_links)} found)")
        for src, tgt in broken_links[:10]:
            if (src, tgt) not in seen:
                print(f"  - {src} → [[{tgt}]]")
                seen.add((src, tgt))
        if len(broken_links) > 10:
            print(f"  ... and {len(broken_links) - 10} more")
    else:
        print(f"\n🟢 No broken wikilinks")

    dups = {k: v for k, v in duplicates.items() if len(v) > 1}
    if dups:
        print(f"\n🟡 Duplicate Titles ({len(dups)} found)")
        for _, dup_files in list(dups.items())[:5]:
            for f in dup_files:
                print(f"  - {f}")
        if len(dups) > 5:
            print(f"  ... and {len(dups) - 5} more")
    else:
        print(f"\n🟢 No duplicate titles")

    print("\n✅ Vault health check complete")


# ── Entry point ───────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Obsidian vault CLI")
    sub = parser.add_subparsers(dest="command", required=True)

    p_search = sub.add_parser("search")
    p_search.add_argument("query")

    p_backlinks = sub.add_parser("backlinks")
    p_backlinks.add_argument("path")

    sub.add_parser("daily")
    sub.add_parser("active")

    p_open = sub.add_parser("open")
    p_open.add_argument("path")

    sub.add_parser("health")

    args = parser.parse_args()
    {
        "search": cmd_search,
        "backlinks": cmd_backlinks,
        "daily": cmd_daily,
        "active": cmd_active,
        "open": cmd_open,
        "health": cmd_health,
    }[args.command](args)


if __name__ == "__main__":
    main()
