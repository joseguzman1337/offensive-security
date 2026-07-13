"""Atheris/libFuzzer harness for SuperCluster.monitor_cluster._validate_scan_target.

The function under test:
    monitor_cluster._validate_scan_target(target: str) -> bool
Validates IP, CIDR, or hostname. Inputs that hang or raise unhandled
exceptions = fuzz bugs we want to surface before a user passes an
attacker-controlled string to a scan job.

Run under atheris in CI:
    python -m atheris -- -atheris_runs=600 fuzz_validate_scan_target.py
    # or, with a corpus directory:
    python -m atheris fuzz_validate_scan_target.py fuzz_corpus/

The atheris entry point instruments imported modules at import time. The
function under test is therefore imported AFTER `atheris.Setup` so the
coverage feedback covers the target's branches, not just the harness.

The companion seed runner lives at `fuzz_seeds.py`; it executes a
deterministic regression corpus without atheris so plain
`python fuzz_seeds.py` works in minimal CI / local-dev environments
where libFuzzer and atheris cannot be built (e.g. Apple Clang on
macOS, which does not ship libFuzzer).
"""
from __future__ import annotations

import sys
from pathlib import Path

# The harness lives at SuperCluster/fuzz/; the target lives at
# SuperCluster/monitor_cluster.py. Add the parent to sys.path so the
# import resolves under both direct invocation and the atheris driver
# (which changes sys.path to the script's directory at startup).
_HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(_HERE.parent))


def TestOneInput(data: bytes) -> None:
    """atheris/libFuzzer entry point. Decodes the fuzz input and feeds
    it to the validation primitive. A raised exception == a fuzz bug.

    The target is imported lazily inside the test function so atheris's
    import-time instrumentation covers `monitor_cluster` (rather than
    only the harness module). atheris installs a meta-path import hook
    during `Setup`; modules imported after that point are instrumented
    for coverage feedback.
    """
    from monitor_cluster import _validate_scan_target  # type: ignore  # noqa: E402,PLC0415

    target = data.decode("latin-1", errors="replace")
    _validate_scan_target(target)


def main() -> int:
    """Run the atheris/libFuzzer driver.

    Atheris ships a `python -m atheris` entry point that takes over the
    process; we therefore call `atheris.Setup` then `atheris.Fuzz` and
    do not return until the runner signals completion.
    """
    import atheris  # type: ignore  # noqa: E402,PLC0415

    atheris.Setup(sys.argv, TestOneInput)
    atheris.Fuzz()
    return 0


if __name__ == "__main__":
    sys.exit(main())
