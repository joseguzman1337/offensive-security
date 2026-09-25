{ config, pkgs, lib, ... }:
with lib;
{
  imports = [
    ./hardware-configuration.nix
    ./migration-profiles
    ./modules
  ];

  # Do not remove these subsystem settings.
  garuda.subsystem.enable = true;
  garuda.managed.config = ./garuda-managed.json;

  garuda.dr460nized.enable = true;
  garuda.preset = "laptop";

  # Keep NixOS user data isolated from the Arch home.
  garuda.subsystem.imported-users.shared-home.enable = false;

  # GitLab is unavailable; omit the optional GUI manager.
  garuda.garuda-nix-manager.enable = false;

  # Read-only access to the existing Garuda root; preserve the subsystem
  # installer's safe automount rather than mounting it eagerly.
  fileSystems."/mnt/garuda-host" = {
    device = "/dev/mapper/luks-07e33bd6-d2f0-4c36-9bc5-ae60820d69f5";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "ro"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
    ];
  };

  # This has no impact on package updates or the OS version.
  system.stateVersion = "26.11";
}
