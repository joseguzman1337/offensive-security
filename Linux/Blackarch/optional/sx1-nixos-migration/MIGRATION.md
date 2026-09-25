# sx1 host migration layer

Import `./modules` from the generated Garuda Nix `configuration.nix`. Keep the
installer-managed subsystem declarations and hardware configuration intact:

```nix
imports = [
  ./hardware-configuration.nix
  ./modules
];
```

The module provides NetworkManager, SSH, AMD graphics, libvirt/QEMU and the
four custom services found on the Arch host. It does not contain credentials.
If the gateway needs authentication, provision an environment file containing
`LLM_API_KEY=...` outside the flake at `/run/secrets/llm-gateway`.

The artifact watcher remains inactive unless the existing
`/Volumes/h101/pr1m3` tree is mounted. Add that filesystem separately once its
remote source and credentials are known; they are intentionally not inferred.

## BlackArch fallback

`blackarch-shell` runs a rootless, capability-free container and accepts only
an image reference pinned by a SHA-256 digest:

```bash
export SX1_BLACKARCH_IMAGE='docker.io/blackarchlinux/blackarch@sha256:...'
blackarch-shell bash
```

Only the current directory is shared at `/work`. Do not weaken the wrapper for
tools needing raw sockets, host networking, USB or kernel access. Package those
tools natively or reboot into the preserved Garuda/BlackArch GRUB entry.

## Activation checks

```bash
nix flake check
sudo nixos-rebuild build --flake /etc/nixos#sx1
systemd-analyze verify ./result/etc/systemd/system/*.service
```

Inspect the build result before switching. Building does not activate the new
generation and does not require a reboot.
