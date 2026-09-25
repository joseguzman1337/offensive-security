{
  description = "Evaluation harness for sx1 migration modules";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.migration = {
    url = "path:..";
    flake = false;
  };

  outputs = { nixpkgs, migration, ... }: {
    nixosConfigurations.sx1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${migration}/modules"
        ({ lib, ... }: {
          # Evaluation-only boot/filesystem scaffolding. The real subsystem
          # continues using its installer-generated hardware configuration.
          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "none";
            fsType = "tmpfs";
          };
          users.users.x = {
            isNormalUser = true;
            uid = 1000;
          };
          system.stateVersion = "26.05";
          documentation.enable = false;
          nixpkgs.config.allowUnfree = true;
        })
      ];
    };

    checks.x86_64-linux.sx1-system =
      (nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${migration}/modules"
          ({ ... }: {
            boot.loader.grub.enable = false;
            fileSystems."/" = { device = "none"; fsType = "tmpfs"; };
            users.users.x = { isNormalUser = true; uid = 1000; };
            system.stateVersion = "26.05";
            documentation.enable = false;
            nixpkgs.config.allowUnfree = true;
          })
        ];
      }).config.system.build.toplevel;
  };
}
