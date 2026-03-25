# Repository Guidelines

## Project Structure & Module Organization

- The repo is a collection of offensive/purple-team utilities, split by platform or domain: `AWS/`, `Linux/`, `Microsoft/`, `Apple/`, `Containers/`, `Virtualization/`, `SuperCluster/`, and `ai/`.
- Python helpers live near their domain (e.g., `AWS/ec2/security_groups/*.py`, `DevSecOps/*.py`, `Linux/Blackarch/optional/*.py`, `SuperCluster/*.py`); shell utilities are in the same pattern (e.g., `SuperCluster/bootstrap_cluster.sh`, `Apple/cache_cleaner.sh`).
- Docs, guides, and playbooks sit beside their subjects (Markdown in each directory) with top-level governance files (`CODE_OF_CONDUCT.md`, `SECURITY.md`, `README.md`).
- Keep new files grouped with their platform/service; avoid cross-cutting scripts in the root unless they are repo-wide tooling.

## Build, Test, and Development Commands

- Python scripts are standalone; install deps only where needed, e.g. `python3 -m pip install -r Linux/Python/requirements.txt` or the closest `requirements.txt` before running a script.
- Quick sanity check a script: `python3 -m py_compile path/to/script.py` and then execute with `python3 path/to/script.py`.
- Shell helpers should be run with `bash path/to/script.sh`; prefer dry-run flags when available and validate paths before execution.

## Coding Style & Naming Conventions

- Python: PEP 8 alignment (4-space indent, lowercase_with_underscores for files/functions, CapWords for classes). Type hints and short docstrings mirror existing scripts (see `DevSecOps/auto_skip_checkov.py` for tone).
- Shell: keep strict mode (`set -euo pipefail` where practical) and lowercase, hyphenated filenames. Comment only when behavior is non-obvious.
- Text/Markdown: concise sentences, platform-specific sections colocated with their directory; use fenced code blocks for commands.

## Testing Guidelines

- No central test harness; validate changes by running the touched script against sample or dry-run inputs. For Checkov helpers, test with representative scan logs before committing.
- If adding a new tool, include a minimal usage example in its README or header comment and note any required environment variables.

## Commit & Pull Request Guidelines

- Recent history uses brief messages (“Update readme.md”); aim for clearer, imperative summaries now (e.g., `Add checkov skip de-dup logic`).
- Commits should stay focused per tool or doc. Include why changes are needed when behavior shifts (skip IDs, security group rules, etc.).
- PRs: provide scope and risk notes, list impacted directories, attach command outputs for validations run, and link any related issues or CVE references. Screenshots/log snippets help for CLI flows.

## Security & Configuration Tips

- Never commit credentials, tokens, or real IPs. Use sanitized examples and sample data in docs and tests.
- Review `SECURITY.md` for disclosure expectations; prefer least-privilege defaults in scripts (narrowed security groups, minimal packages).
