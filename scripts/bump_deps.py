#!/usr/bin/env python3
"""Bump all pinned/floored package versions in requirements.txt files to latest PyPI releases."""

from __future__ import annotations
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent

REQ_FILES = [
    REPO_ROOT / "requirements.txt",
    REPO_ROOT / "Linux/Python/requirements.txt",
    REPO_ROOT / "Linux/Blackarch/optional/requirements.txt",
    REPO_ROOT / "SuperCluster/macOS/Python/requirements.txt",
    REPO_ROOT / "SuperCluster/Kali/Python/requirements.txt",
    REPO_ROOT / "SuperCluster/ArchLinux/Python/requirements.txt",
]

# Regex patterns
PIN_RE = re.compile(r"^([A-Za-z0-9_.\-]+)==([^\s#]+)(.*)", re.MULTILINE)
FLOOR_RE = re.compile(r"^([A-Za-z0-9_.\-]+)>=([^\s#,]+)(.*)", re.MULTILINE)
BARE_RE = re.compile(r"^([A-Za-z0-9_.\-]+)\s*$", re.MULTILINE)

_version_cache: dict[str, str] = {}


def latest_version(pkg: str) -> str | None:
    """Return the latest stable version of *pkg* from PyPI, or None on failure."""
    key = pkg.lower()
    if key in _version_cache:
        return _version_cache[key]
    url = f"https://pypi.org/pypi/{urllib.parse.quote(pkg)}/json"
    try:
        with urllib.request.urlopen(url, timeout=10) as resp:
            data = json.loads(resp.read())
        ver = data["info"]["version"]
        _version_cache[key] = ver
        return ver
    except Exception as exc:
        print(f"  [WARN] Could not fetch {pkg}: {exc}", file=sys.stderr)
        _version_cache[key] = None
        return None


def bump_line(line: str) -> str:
    """Return the bumped version of a single requirements line."""
    stripped = line.rstrip()
    # Skip comments and blank lines
    if not stripped or stripped.startswith("#"):
        return line

    # ==exact pin
    m = PIN_RE.match(stripped)
    if m:
        pkg, old_ver, rest = m.group(1), m.group(2), m.group(3)
        new_ver = latest_version(pkg)
        if new_ver and new_ver != old_ver:
            print(f"  {pkg}: =={old_ver} → =={new_ver}")
            return f"{pkg}=={new_ver}{rest}\n"
        return line

    # >=floor (no upper bound on same token)
    m = FLOOR_RE.match(stripped)
    if m:
        pkg, old_floor, rest = m.group(1), m.group(2), m.group(3)
        new_ver = latest_version(pkg)
        if new_ver and new_ver != old_floor:
            print(f"  {pkg}: >={old_floor} → >={new_ver}")
            return f"{pkg}>={new_ver}{rest}\n"
        return line

    return line


def bump_file(path: Path) -> bool:
    """Bump all versions in *path*. Returns True if the file was modified."""
    print(f"\nProcessing: {path.relative_to(REPO_ROOT)}")
    original = path.read_text()
    lines = original.splitlines(keepends=True)
    new_lines = [bump_line(l) for l in lines]
    new_content = "".join(new_lines)
    if new_content != original:
        path.write_text(new_content)
        return True
    print("  (no changes)")
    return False


def main() -> None:
    changed = []
    for req in REQ_FILES:
        if not req.exists():
            print(f"[SKIP] {req} not found")
            continue
        if bump_file(req):
            changed.append(req)
        time.sleep(0.1)  # be polite to PyPI

    print(f"\nModified {len(changed)} file(s):")
    for f in changed:
        print(f"  {f.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()
