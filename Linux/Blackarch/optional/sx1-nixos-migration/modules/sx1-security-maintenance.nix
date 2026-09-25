{ ... }:

{
  security.apparmor.enable = true;

  # Refresh the Garuda subsystem input and activate a new atomic generation.
  # Reboots remain manual so a kernel update cannot interrupt active work.
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos#sx1";
    flags = [
      "--update-input"
      "garuda"
    ];
    dates = "weekly";
    randomizedDelaySec = "45min";
    allowReboot = false;
  };
}
