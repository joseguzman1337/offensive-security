#!/usr/bin/env python3
"""Give generated BlackArch launchers the best locally available app icon.

The tool never invents a logo.  It prefers an icon shipped by the app's own
package, then an exact-name icon from the installed BlackArch icon theme.  A
JSON manifest records where every choice came from and leaves unresolved apps
explicitly unresolved.

Usage:
    uv run python iconify_blackarch_apps.py --dry-run
    uv run python iconify_blackarch_apps.py --apply
"""

from __future__ import annotations

import argparse
import configparser
import functools
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import urllib.parse
import urllib.request
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


SYSTEM_APPLICATIONS = Path("/usr/share/applications")
THEME_APPS = Path("/usr/share/icons/blackarch-icons/apps/scalable")
IMAGE_SUFFIXES = {".svg", ".png", ".xpm", ".ico", ".webp"}
GENERIC_ICON = "utilities-terminal"


@dataclass(frozen=True)
class Choice:
    package: str
    launcher: str
    icon: str | None
    status: str
    provenance: str | None
    reason: str
    source_url: str | None = None
    sha256: str | None = None


def run(*args: str) -> str:
    return subprocess.run(
        args, check=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
        text=True,
    ).stdout


def normalize(value: str) -> str:
    return re.sub(r"[^a-z0-9]", "", value.casefold())


def package_files(package: str) -> list[Path]:
    try:
        output = run("pacman", "-Qlq", package)
    except (FileNotFoundError, subprocess.CalledProcessError):
        return []
    return [Path(line) for line in output.splitlines() if line]


def is_icon(path: Path) -> bool:
    if path.suffix.casefold() not in IMAGE_SUFFIXES:
        return False
    try:
        return path.is_file()
    except OSError:
        return False


def score_package_icon(path: Path, package: str) -> tuple[int, int, str]:
    lowered = str(path).casefold()
    stem = normalize(path.stem)
    pkg = normalize(package)
    score = 0
    if stem == pkg:
        score += 100
    elif pkg and (pkg in stem or stem in pkg):
        score += 45
    first_token = normalize(package.split("-", 1)[0])
    if "-" in package and stem == first_token and pkg in normalize(str(path.parent)):
        score += 40
    if "/share/icons/" in lowered or "/share/pixmaps/" in lowered:
        score += 50
    if any(word in lowered for word in ("logo", "icon", "favicon")):
        score += 20
    if pkg and pkg in stem and "logo" in stem:
        score += 15
    if path.suffix.casefold() == ".svg":
        score += 10
    if any(word in lowered for word in (
        "node_modules", "vendor", "test", "docs/", "screenshot", "badge",
        "toolbar", "button", "cursor", "emoji",
    )):
        score -= 80
    return score, -len(str(path)), str(path)


def best_package_icon(package: str) -> Path | None:
    candidates = [path for path in package_files(package) if is_icon(path)]
    if not candidates:
        return None
    ranked = sorted(candidates, key=lambda p: score_package_icon(p, package), reverse=True)
    best = ranked[0]
    return best if score_package_icon(best, package)[0] >= 70 else None


def theme_index() -> dict[str, list[Path]]:
    result: dict[str, list[Path]] = {}
    if not THEME_APPS.is_dir():
        return result
    for path in THEME_APPS.iterdir():
        if is_icon(path):
            result.setdefault(normalize(path.stem), []).append(path)
    return result


def aliases(package: str) -> Iterable[str]:
    yield package
    for suffix in ("-git", "-bin", "-cli", "-gui", "-python", "-ce", "-community"):
        if package.endswith(suffix):
            yield package[: -len(suffix)]


def best_theme_icon(package: str, index: dict[str, list[Path]]) -> Path | None:
    for alias in aliases(package):
        matches = index.get(normalize(alias), [])
        if matches:
            return sorted(matches, key=lambda p: (p.suffix != ".svg", len(p.name)))[0]
    return None


def choose(package: str, launcher: Path, index: dict[str, list[Path]]) -> Choice:
    parser = read_desktop(launcher)
    existing = parser["Desktop Entry"].get("Icon", "").strip()
    resolved_existing = resolve_existing_icon(existing)
    if resolved_existing and existing != GENERIC_ICON:
        return Choice(package, str(launcher), resolved_existing, "existing_launcher",
                      f"desktop-entry:{launcher}",
                      "application-specific icon selected by the packaged launcher")
    owned = best_package_icon(package)
    if owned:
        return Choice(package, str(launcher), str(owned), "official_local",
                      f"pacman:{package}", "icon shipped by the application package")
    themed = best_theme_icon(package, index)
    if themed:
        return Choice(package, str(launcher), str(themed), "theme_exact_match",
                      "pacman:blackarch-config-icons",
                      "exact normalized app name in the installed icon theme")
    return Choice(package, str(launcher), None, "unresolved", None,
                  "no trustworthy local app-specific icon found")


@functools.lru_cache(maxsize=1)
def installed_icon_index() -> dict[str, Path]:
    candidates: dict[str, list[Path]] = {}
    for root in (Path("/usr/share/icons"), Path("/usr/share/pixmaps")):
        if not root.is_dir():
            continue
        for path in root.rglob("*"):
            if is_icon(path):
                candidates.setdefault(path.name.casefold(), []).append(path)
                candidates.setdefault(path.stem.casefold(), []).append(path)
    return {
        name: sorted(paths, key=lambda p: ("/apps/" not in str(p), p.suffix != ".svg", len(str(p))))[0]
        for name, paths in candidates.items()
    }


def resolve_existing_icon(icon: str) -> str | None:
    if not icon or re.search(r"@[A-Z0-9_]+@", icon):
        return None
    if "/" in icon:
        return icon if Path(icon).is_file() else None
    path = installed_icon_index().get(icon.casefold())
    return str(path) if path else None


def read_desktop(path: Path) -> configparser.ConfigParser:
    parser = configparser.ConfigParser(interpolation=None, strict=False)
    parser.optionxform = str
    parser.read(path, encoding="utf-8")
    return parser


def package_owner(path: Path) -> str | None:
    try:
        return run("pacman", "-Qoq", str(path)).strip()
    except (FileNotFoundError, subprocess.CalledProcessError):
        return None


def package_owners(paths: list[Path]) -> dict[Path, str]:
    if not paths:
        return {}
    try:
        completed = subprocess.run(
            ("pacman", "-Qo", *(str(path) for path in paths)), check=False,
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
        )
        output = completed.stdout
    except FileNotFoundError:
        return {path: owner for path in paths if (owner := package_owner(path))}
    owners: dict[Path, str] = {}
    for line in output.splitlines():
        match = re.match(r"^(.*?) is owned by (\S+) ", line)
        if match:
            owners[Path(match.group(1))] = match.group(2)
    return owners


def target_launchers() -> list[tuple[str, Path]]:
    targets: list[tuple[str, Path]] = []
    try:
        installed_blackarch = {
            line.split()[1]
            for line in run("pacman", "-Sl", "blackarch").splitlines()
            if line.endswith("[installed]")
        }
    except (FileNotFoundError, subprocess.CalledProcessError, IndexError):
        installed_blackarch = set()
    paths = sorted(SYSTEM_APPLICATIONS.glob("*.desktop"))
    owners = package_owners(paths)
    for path in paths:
        if path.name.startswith("ba-"):
            targets.append((path.stem.removeprefix("ba-"), path))
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        owner = owners.get(path)
        if owner in installed_blackarch or "X-BlackArch" in text or "BlackArch" in text:
            if not owner:
                continue
            targets.append((owner, path))
    return targets


def write_desktop(source: Path, target: Path, icon: str) -> None:
    parser = read_desktop(source)
    parser["Desktop Entry"]["Icon"] = icon
    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("w", encoding="utf-8") as stream:
        parser.write(stream, space_around_delimiters=False)
    shutil.copymode(source, target)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--dry-run", action="store_true", help="only write the manifest")
    mode.add_argument("--apply", action="store_true", help="install per-user launcher overrides")
    parser.add_argument(
        "--output-dir", type=Path,
        default=Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share")),
        help="XDG data directory for launcher overrides",
    )
    parser.add_argument("--manifest", type=Path, default=Path("blackarch_icon_manifest.json"))
    parser.add_argument(
        "--upstream-map", type=Path, action="append", default=[],
        help="reviewed package-to-official-asset JSON map (repeatable)",
    )
    return parser.parse_args()


def load_upstream_maps(paths: list[Path]) -> dict[str, dict[str, str]]:
    merged: dict[str, dict[str, str]] = {}
    for path in paths:
        data = json.loads(path.read_text(encoding="utf-8"))
        for package, entry in data.items():
            status = entry.get("status")
            if status == "official_upstream" and entry.get("url"):
                merged[package] = entry
            elif status == "none_published" and package not in merged:
                merged[package] = entry
    return merged


def download_icon(package: str, url: str, directory: Path) -> tuple[Path, str]:
    suffix = Path(urllib.parse.unquote(urllib.parse.urlparse(url).path)).suffix.casefold()
    request = urllib.request.Request(url, headers={"User-Agent": "blackarch-iconifier/1"})
    with urllib.request.urlopen(request, timeout=30) as response:
        body = response.read(5 * 1024 * 1024 + 1)
        content_type = response.headers.get_content_type()
    if suffix not in IMAGE_SUFFIXES:
        suffix = {
            "image/svg+xml": ".svg", "image/png": ".png",
            "image/x-xpixmap": ".xpm", "image/vnd.microsoft.icon": ".ico",
            "image/x-icon": ".ico", "image/webp": ".webp",
        }.get(content_type, "")
    if suffix not in IMAGE_SUFFIXES:
        raise ValueError(f"unsupported image response for {package}: {content_type}")
    if len(body) > 5 * 1024 * 1024 or not content_type.startswith("image/"):
        raise ValueError(f"invalid image response for {package}")
    if suffix == ".svg" and re.search(br"<(script|iframe)\b|\b(href|src)=[\"']https?://", body, re.I):
        raise ValueError(f"unsafe active/external SVG content for {package}")
    digest = hashlib.sha256(body).hexdigest()
    directory.mkdir(parents=True, exist_ok=True)
    target = directory / f"blackarch-{package}{suffix}"
    target.write_bytes(body)
    return target, digest


def main() -> int:
    args = parse_args()
    launchers = target_launchers()
    if not launchers:
        print("No generated BlackArch launchers found.", file=sys.stderr)
        return 1

    index = theme_index()
    choices = [choose(package, path, index) for package, path in launchers]
    upstream = load_upstream_maps(args.upstream_map)
    choices = [
        Choice(item.package, item.launcher, item.icon,
               upstream[item.package]["status"] if item.status == "unresolved" and item.package in upstream else item.status,
               "reviewed upstream project asset" if item.status == "unresolved" and item.package in upstream and upstream[item.package]["status"] == "official_upstream" else item.provenance,
               upstream[item.package]["reason"] if item.status == "unresolved" and item.package in upstream else item.reason,
               upstream[item.package].get("url") if item.status == "unresolved" and item.package in upstream else None)
        for item in choices
    ]
    if args.apply:
        destination = args.output_dir / "applications"
        installed_choices: list[Choice] = []
        icon_dir = args.output_dir / "icons" / "blackarch-official"
        for item in choices:
            if item.status == "official_upstream" and item.source_url:
                icon_path, digest = download_icon(item.package, item.source_url, icon_dir)
                item = Choice(**{**asdict(item), "icon": str(icon_path), "sha256": digest})
            if item.icon:
                write_desktop(Path(item.launcher), destination / Path(item.launcher).name, item.icon)
            installed_choices.append(item)
        choices = installed_choices
        try:
            subprocess.run(["update-desktop-database", str(destination)], check=False)
        except FileNotFoundError:
            pass

    summary = {status: sum(item.status == status for item in choices)
               for status in ("existing_launcher", "official_local", "official_upstream",
                              "theme_exact_match", "none_published", "unresolved")}
    payload = {"schema_version": 1, "summary": summary,
               "entries": [asdict(item) for item in choices]}
    args.manifest.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
