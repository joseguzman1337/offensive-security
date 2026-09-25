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
      allowedTCPPorts = [
        22
        3240
        5900
        14318
        14319
        14320
        14321
        14322
        14323
      ];
      allowedUDPPorts = [ 5353 ];
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

  # Use a standard Spanish keyboard everywhere, including the virtual console
  # and the Plasma login screen.  Keep Caps Lock and both Shift keys unmodified.
  console.keyMap = "es";
  services.xserver.xkb = {
    layout = "es";
    model = "pc105";
    options = "terminate:ctrl_alt_bksp";
  };

  # Preserve administrative access for the account used to manage sx1.
  users.users.d3c0d3r.extraGroups = [ "wheel" ];

  # sx1 has an AMD Picasso/Vega GPU.  Do not enable NVIDIA merely because the
  # old Arch installation contains NVIDIA compatibility packages.
  boot.kernelPackages = pkgs.linuxPackages_latest;
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

  # Run NVIDIA PAIR's official Debian/Electron build through nix-ld.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      at-spi2-atk
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      libgbm
      libdrm
      libnotify
      libsecret
      libuuid
      libxkbcommon
      mesa
      nspr
      nss
      pango
      systemd
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
    ];
  };

  environment.systemPackages = with pkgs; [
    distrobox
    libvirt
    qemu
    spice-gtk
    virt-manager
    vulkan-tools
  ];
}
