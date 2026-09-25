{ lib, pkgs, ... }:

let
  gatewayPython = pkgs.python3;
in
{
  systemd.services = {
    llm-gateway = {
      description = "LLM API Gateway - sx1";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      unitConfig.ConditionPathExists = "/home/x/llm_gateway.py";
      environment.GATEWAY_PORT = "8000";
      script = "exec ${gatewayPython}/bin/python /home/x/llm_gateway.py";
      serviceConfig = {
        User = "x";
        WorkingDirectory = "/home/x";
        Restart = "always";
        RestartSec = "10s";
        CPUQuota = "25%";
        MemoryMax = "512M";
        # Optional file containing LLM_API_KEY=...; never place it in the flake.
        EnvironmentFile = "-/run/secrets/llm-gateway";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
      };
    };

    llama-server = {
      description = "llama.cpp HTTP server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe' pkgs.llama-cpp "llama-server"} --models-dir /var/lib/llama/models";
        Restart = "on-failure";
        StateDirectory = "llama";
        CacheDirectory = "llama";
        RuntimeDirectory = "llama";
        SupplementaryGroups = [ "render" "video" ];
        DeviceAllow = [ "/dev/dri/renderD128 rw" "/dev/kfd rw" ];
        DevicePolicy = "closed";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      };
    };

    pr1m3-android-keep-awake = {
      description = "Keep sx1 awake for PR1M3 Android operations";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=sleep --who=PR1M3-Android --why=Keep-sx1-awake-for-Android-build-and-artifact-operations --mode=block ${pkgs.coreutils}/bin/sleep infinity";
        Restart = "on-failure";
        NoNewPrivileges = true;
      };
    };

    pr1m3-sx1-artifact-watch = {
      description = "Watch sx1 inbox for agate release artifacts";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      unitConfig.ConditionPathExists = "/Volumes/h101/pr1m3/reports/android/agate/sx1-quiet-artifact-watch.sh";
      serviceConfig = {
        Type = "simple";
        Nice = 19;
        IOSchedulingClass = "idle";
        CPUSchedulingPolicy = "batch";
        ExecStart = "${pkgs.dash}/bin/dash /Volumes/h101/pr1m3/reports/android/agate/sx1-quiet-artifact-watch.sh";
        Restart = "on-failure";
        NoNewPrivileges = true;
      };
    };
  };
}
