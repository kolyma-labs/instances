{config, ...}: let
  # Name for GitHub runner
  name = "${config.networking.hostName}-default";
  user = "gitlab-runner";

  secret-management = {
    owner = user;
  };
in {
  sops.secrets = {
    "github/runners/floss" = secret-management;
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
    # Xinux runner
    "${name}-Floss" = {
      inherit user;
      enable = true;
      url = "https://github.com/floss-uz";
      tokenFile = config.sops.secrets."github/runners/floss".path;
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
