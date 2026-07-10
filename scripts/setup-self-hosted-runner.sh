#!/bin/bash
# Register this host as a self-hosted GitHub Actions runner for
# joseguzman1337/offensive-security (and any other repo that opts in).
#
# Requirements: macOS or Linux, admin/sudo, ~1GB free disk for the
# runner tarball and a workdir under /opt/actions-runner.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/joseguzman1337/offensive-security/master/scripts/setup-self-hosted-runner.sh
#   | sudo bash -s -- --repo joseguzman1337/offensive-security --label hermes-local
#
# Or run locally:
#   sudo ./scripts/setup-self-hosted-runner.sh \
#     --repo joseguzman1337/offensive-security \
#     --label hermes-local
#
# After the install, the runner starts and registers itself. The
# autofix-* workflows (which require `runs-on: [self-hosted, hermes-local]`)
# will then be eligible to run.
set -euo pipefail

REPO="joseguzman1337/offensive-security"
LABEL="hermes-local"
RUNNER_VERSION="${RUNNER_VERSION:-2.322.0}"
INSTALL_DIR="/opt/actions-runner"
RUNNER_USER="github-runner"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)   REPO="$2"; shift 2 ;;
    --label)  LABEL="$2"; shift 2 ;;
    --dir)    INSTALL_DIR="$2"; shift 2 ;;
    --user)   RUNNER_USER="$2"; shift 2 ;;
    --version) RUNNER_VERSION="$2"; shift 2 ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done

if [[ $EUID -ne 0 ]]; then
  echo "must be root (sudo $0 ...)" >&2
  exit 1
fi

# Pick a binary by arch.
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  PLATFORM=linux-x64 ;;
  aarch64) PLATFORM=linux-arm64 ;;
  armv7l)  PLATFORM=linux-arm ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac

# Create the runner user (no password, no shell).
if ! id "$RUNNER_USER" >/dev/null 2>&1; then
  useradd --system --shell /usr/sbin/nologin --home "$INSTALL_DIR" "$RUNNER_USER"
fi
mkdir -p "$INSTALL_DIR"
chown "$RUNNER_USER":"$RUNNER_USER" "$INSTALL_DIR"

# Download + extract the runner.
TARBALL="actions-runner-${PLATFORM}-${RUNNER_VERSION}.tar.gz"
URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${TARBALL}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo ">> downloading $URL"
curl -fsSL -o "$TMP/$TARBALL" "$URL"
tar -xzf "$TMP/$TARBALL" -C "$INSTALL_DIR"
chown -R "$RUNNER_USER":"$RUNNER_USER" "$INSTALL_DIR"

# Get a registration token from GitHub.
# Requires: GH_TOKEN env var with admin:org scope, OR a fine-grained
# PAT with Actions: write on the target repo.
if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "GH_TOKEN env var required (admin Actions scope on $REPO)" >&2
  exit 1
fi
REG_TOKEN="$(curl -fsSL -X POST \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$REPO/actions/runners/registration-token" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["token"])')"

# Run the install/config as the runner user.
echo ">> configuring runner"
sudo -u "$RUNNER_USER" \
  "$INSTALL_DIR/config.sh" \
    --unattended \
    --replace \
    --url "https://github.com/$REPO" \
    --token "$REG_TOKEN" \
    --name "$(hostname)-${LABEL}" \
    --labels "$LABEL" \
    --work "_work"

# Install + start as a systemd service (Linux).
if command -v systemctl >/dev/null && [[ -d /etc/systemd/system ]]; then
  cd "$INSTALL_DIR"
  ./svc.sh install "$RUNNER_USER" >/dev/null
  ./svc.sh start
  systemctl enable actions.runner."$(basename "$REPO")-$(hostname)-${LABEL}".service
  echo ">> systemd unit installed and started"
fi

echo ""
echo "Runner registered for $REPO with labels: $LABEL"
echo "  - workdir:  $INSTALL_DIR"
echo "  - user:     $RUNNER_USER"
echo "  - service:  actions.runner.$(basename "$REPO")-$(hostname)-${LABEL}.service"
echo ""
echo "To check status:  sudo systemctl status actions.runner.*.service"
echo "To view logs:     journalctl -u actions.runner.*.service -f"
