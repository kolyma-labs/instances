{config, ...}: let
  # Name for GitHub runner
  name = "${config.networking.hostName}-default";
  user = "gitlab-runner";

  secret-management = {
    owner = user;
  };
in {
  sops.secrets = {
    "github/runners/kolyma" = secret-management;
    "github/runners/orzklv/nix" = secret-management;
    "github/runners/orzklv/pkgs" = secret-management;
  };

  users.users.${user} = {
    description = "GitHub Runner user";
    # isSystemUser = true;
    isNormalUser = true;
    createHome = false;
    extraGroups = ["admins"];
    group = user;
  };

  users.groups.${user} = {};

  services.github-runners = {
    # Orkzlv -> Nix runner
    "${name}-Orzklv-Nix" = {
      inherit user;
      enable = true;
      url = "https://github.com/orzklv/nix";
      tokenFile = config.sops.secrets."github/runners/orzklv/nix".path;
      replace = true;
      extraLabels = [name];
      group = user;
      serviceOverrides = {
        ProtectSystem = "full";
        ReadWritePaths = "/srv";
        PrivateMounts = false;
        UMask = 22;
      };
    };

    # Orkzlv -> Pkgs runner
    "${name}-Orzklv-Pkgs" = {
      inherit user;
      enable = true;
      url = "https://github.com/orzklv/pkgs";
      tokenFile = config.sops.secrets."github/runners/orzklv/pkgs".path;
      replace = true;
      extraLabels = [name];
      group = user;
      serviceOverrides = {
        ProtectSystem = "full";
        ReadWritePaths = "/srv";
        PrivateMounts = false;
        UMask = 22;
      };
    };

    # Kolyma Labs runner
    "${name}-Kolyma" = {
      inherit user;
      enable = true;
      url = "https://github.com/kolyma-labs";
      tokenFile = config.sops.secrets."github/runners/kolyma".path;
      replace = true;
      extraLabels = [name];
      group = user;
      serviceOverrides = {
        ProtectSystem = "full";
        ReadWritePaths = "/srv";
        PrivateMounts = false;
        UMask = 22;
      };
    };
  };
}
