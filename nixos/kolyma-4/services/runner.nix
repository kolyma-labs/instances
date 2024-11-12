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
    isSystemUser = true;
    group = user;
  };

  users.groups.${user} = { };

  services.github-runners = {
    "${name}" = {
      enable = true;
      url = "https://github.com/kibertexnik";
      tokenFile = config.sops.secrets."github/runners/kibertexnik".path;
      replace = true;
      serviceOverrides.StateDirectory = [
        "github-runner/${name}"
      ];
      workDir = "/var/lib/github-runner/${name}";
      extraLabels = [ name ];

      user = user;
      group = user;
    };
  };
}
