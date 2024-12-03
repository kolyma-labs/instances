{ config, outputs, ... }:
let
  # Name for GitHub runner
  name = "${config.networking.hostName}-default";
  user = "kibertexnik";

  secret-management = {
    owner = user;
  };
in
{
  sops.secrets = {
    "github/runners/kibertexnik" = secret-management;
  };

  users.users.${user} = {
    description = "GitHub Runner user for kibretexnik";
    # isSystemUser = true;
    isNormalUser = true;
    createHome = false;
    extraGroups = [ "admins" ];
    group = user;
  };

  users.groups.${user} = { };

  services.github-runners = {
    "${name}-Kibertexnik" = {
      enable = true;
      url = "https://github.com/kibertexnik";
      tokenFile = config.sops.secrets."github/runners/kibertexnik".path;
      replace = true;
      extraLabels = [ name ];
      user = user;
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
