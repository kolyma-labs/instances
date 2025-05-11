{config, ...}: let
  # Name for GitHub runner
  name = "${config.networking.hostName}-default";
  user = "gitlab-runner";

  secret-management = {
    owner = user;
  };
in {
  sops.secrets = {
    "github/runners/xinux" = secret-management;
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
    "${name}-Xinux" = {
      inherit user;
      enable = true;
      url = "https://github.com/xinux-org";
      tokenFile = config.sops.secrets."github/runners/xinux".path;
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

  services.www.hosts = {
    "cdn.xinux.uz" = {
      addSSL = true;
      enableACME = true;
      root = "/srv/cdn";
      extraConfig = ''
        autoindex on;
      '';
    };
  };
}
