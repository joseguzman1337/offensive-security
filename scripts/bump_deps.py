#!/usr/bin/env python3
# Requires Python 3.10+ (uses PEP 604 union syntax: dict[str, str | None]).
# On macOS the system python3 is 3.9; invoke via `python3.13` or `uv run python`.
from __future__ import annotations
"""Bump all packages in every requirements.txt to their latest PyPI release.

Handles three line shapes:
  pkg              -> pkg==<latest>
  pkg>=floor       -> pkg>=<latest>
  pkg==old         -> pkg==<latest>
"""
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

REQ_FILES = [
    REPO_ROOT / "requirements.txt",
    REPO_ROOT / "Linux/Python/requirements.txt",
    REPO_ROOT / "Linux/Blackarch/optional/requirements.txt",
    REPO_ROOT / "SuperCluster/macOS/Python/requirements.txt",
    REPO_ROOT / "SuperCluster/Kali/Python/requirements.txt",
    REPO_ROOT / "SuperCluster/ArchLinux/Python/requirements.txt",
]

# Matches: name[extras] [specifier] [; marker] [# comment]
LINE_RE = re.compile(
    r"^(?P<name>[A-Za-z0-9_.-]+)(?P<extras>\[[^\]]*\])?"
    r"(?P<op>==|>=|<=|~=|!=|>|<)?(?P<ver>[^\s#;]*)"
    r"(?P<rest>.*)$"
)

_cache: dict[str, str | None] = {}


def latest(pkg: str) -> str | None:
    key = pkg.lower()
    if key in _cache:
        return _cache[key]
    url = f"https://pypi.org/pypi/{urllib.parse.quote(pkg)}/json"
    try:
        with urllib.request.urlopen(url, timeout=12) as r:
            ver: str = json.loads(r.read())["info"]["version"]
        _cache[key] = ver
        return ver
    except Exception as exc:
        print(f"  [WARN] {pkg}: {exc}", file=sys.stderr)
        _cache[key] = None
        return None


def bump_line(line: str) -> tuple[str, bool]:
    """Return (new_line, changed)."""
    raw = line.rstrip("\n")
    stripped = raw.strip()

    # Pass through blanks, comments, -r / -c includes, VCS / URL deps
    if (
        not stripped
        or stripped.startswith("#")
        or stripped.startswith("-")
        or stripped.startswith("git+")
        or "://" in stripped
    ):
        return line, False

    m = LINE_RE.match(stripped)
    if not m:
        return line, False

    name = m.group("name")
    extras = m.group("extras") or ""
    op = m.group("op") or ""
    old_ver = m.group("ver") or ""
    rest = m.group("rest") or ""

    new_ver = latest(name)
    if new_ver is None:
        return line, False

    if op == "==":
        if old_ver == new_ver:
            return line, False
        print(f"  {name}: =={old_ver} -> =={new_ver}")
        return f"{name}{extras}=={new_ver}{rest}\n", True

    elif op == ">=":
        if old_ver == new_ver:
            return line, False
        print(f"  {name}: >={old_ver} -> >={new_ver}")
        return f"{name}{extras}>={new_ver}{rest}\n", True

    elif op == "":
        # bare — pin to latest
        print(f"  {name}: (bare) -> =={new_ver}")
        return f"{name}{extras}=={new_ver}{rest}\n", True

    # <=, ~=, !=, >, < — leave untouched
    return line, False


def bump_file(path: Path) -> bool:
    print(f"\n{path.relative_to(REPO_ROOT)}")
    text = path.read_text()
    lines = text.splitlines(keepends=True)
    new_lines, changed = [], False
    for ln in lines:
        new_ln, did_change = bump_line(ln)
        new_lines.append(new_ln)
        if did_change:
            changed = True
    if changed:
        path.write_text("".join(new_lines))
    else:
        print("  (already current)")
    return changed


def main() -> None:
    modified = []
    for req in REQ_FILES:
        if not req.exists():
            print(f"[SKIP] {req.relative_to(REPO_ROOT)} not found")
            continue
        if bump_file(req):
            modified.append(req)
        time.sleep(0.05)

    print(f"\n{'─'*50}")
    print(f"Modified {len(modified)}/{len(REQ_FILES)} file(s)")


if __name__ == "__main__":
    main()
