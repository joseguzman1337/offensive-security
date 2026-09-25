# sx1 NixOS migration inventory

This directory is a read-only snapshot used to plan the migration of `sx1` from
Garuda/Arch to NixOS. It contains package state, enabled system services, and
the storage layout. It intentionally contains no credentials or user files.

## Files

- `packages.tsv`: every installed package with version, installation reason,
  foreign/repository classification, and detected sync repository.
- `explicit-packages.txt`: requested package set; use this as the initial Nix
  mapping input instead of copying the complete Arch dependency closure.
- `enabled-units.tsv`: enabled system unit files.
- `mounts.tsv`: mounted filesystems excluding pseudo-filesystems and `/home`.
- `block-devices.json`: block-device topology without serial numbers.
- `system.txt`: kernel, architecture, boot mode, graphics and active repository
  names.
- `capture-sx1-inventory.sh`: deterministic read-only recapture script.
- `nix-package-map.tsv`: deterministic mapping against the pinned subsystem
  `nixpkgs`, including validated direct matches, aliases, and unmatched names.
- `profiles/`: generated NixOS modules containing only derivations that evaluate
  as available and non-broken on `x86_64-linux`.

Package names are not assumed to equal Nix attribute names. Resolve the
explicit manifest against a pinned `nixpkgs` revision, record exceptions in a
separate mapping, and keep unmatched BlackArch/FHS tools isolated until they
have native derivations.

The mapping was evaluated against `nixpkgs` revision
`6774f7bc253789b113a4f39285dc0fa100abeacc`. The generated profiles contain
983 exact attribute matches and 167 validated aliases. The remaining 2,834
explicit Arch packages are intentionally not included. Twenty-two initially
matching packages are recorded in `nix-exclusions.tsv` because full NixOS
evaluation or build validation found insecure, license-gated, incompatible,
unavailable, or heavyweight source-only closures.

The original successful dry-run plan contained 1,352 local derivations and
3,512 fetched paths: 20,270.11 MiB compressed and 61,222.80 MiB unpacked. After
excluding source-only MongoDB, the final incremental plan required only 48
local integration derivations and 27 binary-substituted paths. Generation 2 was
registered for the next boot without switching or rebooting; its measured
closure is 79.0 GiB.

## Recapture

Run the script through an authenticated SSH session and provide an output
directory on the remote host or in a disposable environment:

```bash
bash capture-sx1-inventory.sh /tmp/sx1-inventory
```

The script performs queries only. Compare the resulting files with this
snapshot before generating a NixOS configuration.
