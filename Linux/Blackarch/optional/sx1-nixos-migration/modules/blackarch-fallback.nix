{ pkgs, ... }:

let
  blackarchShell = pkgs.writeShellApplication {
    name = "blackarch-shell";
    runtimeInputs = [ pkgs.podman ];
    text = ''
      image="''${SX1_BLACKARCH_IMAGE:-}"
      case "$image" in
        *@sha256:*) ;;
        *)
          echo "Set SX1_BLACKARCH_IMAGE to a BlackArch OCI image pinned by @sha256 digest." >&2
          echo "For kernel/raw-socket tools, boot the original Garuda entry instead." >&2
          exit 64
          ;;
      esac

      exec podman run --rm -it \
        --userns=keep-id \
        --cap-drop=all \
        --security-opt=no-new-privileges \
        --network=slirp4netns \
        --volume "$PWD:/work:rw,z" \
        --workdir /work \
        "$image" "$@"
    '';
  };
in
{
  # This is intentionally rootless and non-privileged. Tools requiring monitor
  # mode, raw sockets, kernel modules, USB devices or host networking belong in
  # a native Nix package or in the original Garuda/BlackArch boot environment.
  environment.systemPackages = [ blackarchShell ];
}
