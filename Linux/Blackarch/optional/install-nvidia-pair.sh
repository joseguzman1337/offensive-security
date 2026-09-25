#!/usr/bin/env bash
set -euo pipefail

repo="NVIDIA/Personal-AI-Router"
api_url="https://api.github.com/repos/${repo}/releases/latest"
asset="service-binaries-linux-x64.zip"
install_root="${XDG_DATA_HOME:-${HOME}/.local/share}/nvpair"
bin_dir="${HOME}/.local/bin"

for command_name in curl jq unzip sha256sum; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "${command_name}" >&2
    exit 1
  fi
done

case "$(uname -m)" in
  x86_64|amd64) ;;
  *)
    printf 'Unsupported architecture: %s (this installer targets Linux x86-64)\n' "$(uname -m)" >&2
    exit 1
    ;;
esac

release_json="$(curl --fail --silent --show-error --location "${api_url}")"
version="$(jq -er '.tag_name' <<<"${release_json}")"
download_url="$(jq -er --arg asset "${asset}" '.assets[] | select(.name == $asset) | .browser_download_url' <<<"${release_json}")"
published_digest="$(jq -er --arg asset "${asset}" '.assets[] | select(.name == $asset) | .digest' <<<"${release_json}")"
expected_sha256="${published_digest#sha256:}"
version_dir="${install_root}/${version}"

if [[ -x "${version_dir}/nvpair-tui" ]] &&
   [[ -f "${version_dir}/archive.sha256" ]] &&
   [[ "$(<"${version_dir}/archive.sha256")" == "${expected_sha256}" ]]; then
  printf 'NVIDIA PAIR %s is already installed.\n' "${version}"
else
  work_dir="$(mktemp -d)"
  trap 'rm -rf -- "${work_dir}"' EXIT
  archive="${work_dir}/${asset}"

  curl --fail --show-error --location --output "${archive}" "${download_url}"
  actual_sha256="$(sha256sum "${archive}" | awk '{print $1}')"
  if [[ "${actual_sha256}" != "${expected_sha256}" ]]; then
    printf 'SHA-256 mismatch for %s\n' "${asset}" >&2
    exit 1
  fi

  mkdir -p "${version_dir}"
  unzip -q -o "${archive}" -d "${version_dir}"
  chmod 0755 "${version_dir}"/nvpair-* "${version_dir}"/*-proxy
  printf '%s\n' "${expected_sha256}" >"${version_dir}/archive.sha256"
fi

mkdir -p "${bin_dir}"
for executable in "${version_dir}"/nvpair-* "${version_dir}"/*-proxy; do
  ln -sfn "${executable}" "${bin_dir}/$(basename "${executable}")"
done
ln -sfn "${version_dir}" "${install_root}/current"

"${bin_dir}/nvpair-tui" -version
printf 'Installed NVIDIA PAIR %s in %s\n' "${version}" "${version_dir}"
printf 'Run it with: %s/nvpair-tui\n' "${bin_dir}"
