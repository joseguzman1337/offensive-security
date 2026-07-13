"""Deterministic regression seed corpus for
SuperCluster.monitor_cluster._validate_scan_target.

This is the plain-Python sibling of `fuzz_validate_scan_target.py` (the
atheris/libFuzzer harness). It exists so that:

  1. CI runs that do not have atheris/libFuzzer available still get
     deterministic regression coverage on every push and schedule
     run. The current `fuzz` job in `security-suite.yml` is this kind
     of run; it depends on the seed inputs being executed end-to-end
     without atheris in the picture.

  2. Developers running `python fuzz_seeds.py` on a workstation with
     only the system Python get a fast regression pass (no libFuzzer
     required, no coverage instrumentation, deterministic output).

Run locally:
    python fuzz_seeds.py

The corresponding atheris harness uses these same seeds as its corpus
directory; the directory `fuzz_corpus/` next to this file is the
bridge. Each seed below is also written to that directory as
`<index>_<name>.bin` so `atheris` has a starting corpus with diverse
inputs (valid IPs, valid CIDRs, valid hostnames, and shape edge cases
that are known to provoke regexes / parsers).
"""
from __future__ import annotations

import sys
from pathlib import Path

# Import the function under test. The harness lives at SuperCluster/fuzz/;
# the target lives at SuperCluster/monitor_cluster.py.
_HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(_HERE.parent))
from monitor_cluster import _validate_scan_target  # type: ignore  # noqa: E402

# Seed corpus — strings that should all be either valid or invalid without
# raising. These double as regression tests.
SEEDS_VALID = [
    b"127.0.0.1",
    b"10.0.0.0/8",
    b"::1",
    b"2001:db8::/32",
    b"example.com",
    b"sub.example.co.uk",
    b"a",  # single-char hostname is RFC-1123 legal
    b"host-1.example",
    b"192.168.1.1",
]
SEEDS_INVALID = [
    b"",
    b"-leading-dash",
    b"trailing-dash-",
    b"..double-dot",
    b"x" * 1000,  # long input
    b"\x00null\x00",
    b"\xff\xfe\xfd non-utf8",  # bytes
    b"999.999.999.999",
    b"host with spaces",
    b"a." * 100,  # many labels
]


def run_seeds() -> tuple[int, int]:
    """Run the seed corpus and return (pass, fail) counts.

    Fails = unexpected exceptions. All bool results are acceptable; we
    only care that the function does NOT crash on edge-case input.
    """
    pass_count = 0
    fail_count = 0
    for s in SEEDS_VALID + SEEDS_INVALID:
        try:
            _validate_scan_target(s.decode("latin-1"))
            pass_count += 1
        except Exception as e:  # noqa: BLE001
            print(f"FAIL: {s!r} -> {type(e).__name__}: {e}")
            fail_count += 1
    return pass_count, fail_count


def write_corpus(target_dir: Path) -> int:
    """Write the seed corpus to a directory in the atheris-friendly
    format (one input per file, no extension). Returns the number of
    files written. Idempotent: overwrites if files exist.
    """
    target_dir.mkdir(parents=True, exist_ok=True)
    written = 0
    for i, s in enumerate(SEEDS_VALID + SEEDS_INVALID):
        # Prefix with an index so files sort deterministically; this is
        # not used by atheris, just by humans browsing the corpus.
        (target_dir / f"{i:02d}_{i:04x}.bin").write_bytes(s)
        written += 1
    return written


def main() -> int:
    pass_count, fail_count = run_seeds()
    print(f"Seeds: {pass_count} ok, {fail_count} failed")
    # Mirror the corpus next to this file so a local developer can
    # immediately run atheris against it.
    written = write_corpus(_HERE / "fuzz_corpus")
    print(f"Corpus: {written} inputs written to {_HERE / 'fuzz_corpus'}")
    return 1 if fail_count else 0


if __name__ == "__main__":
    sys.exit(main())
