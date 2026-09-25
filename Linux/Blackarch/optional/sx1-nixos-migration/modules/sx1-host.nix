{ lib, pkgs, ... }:

{
  # Garuda Nix already supplies Plasma through garuda.dr460nized.  This module
  # carries only the sx1-specific host capabilities so it remains usable with
  # future Garuda Nix releases.
  networking = {
    hostName = lib.mkDefault "sx1";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 3240 5900 ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = true;
    };
  };

  # sx1 has an AMD Picasso/Vega GPU.  Do not enable NVIDIA merely because the
  # old Arch installation contains NVIDIA compatibility packages.
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = false;
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
    podman = {
      enable = true;
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    distrobox
    libvirt
    qemu
    spice-gtk
    virt-manager
    vulkan-tools
  ];
}
