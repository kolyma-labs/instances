{ outputs, pkgs, ... }: {
  services.gitlab = {
    enable = true;
    databasePasswordFile = pkgs.writeText "dbPassword" "zgvcyfwsxzcwr85l";
    initialRootPasswordFile = pkgs.writeText "rootPassword" "dakqdvp4ovhksxer";
    secrets = {
      secretFile = pkgs.writeText "secret" "xlHvN7tfexeTbFVHbkVKESQbyTZXG9v1TZ1me9Txa4GtxUMeKI";
      otpFile = pkgs.writeText "otpsecret" "ME5h5Wh4NUjlvSqIM2tbBs9v44BVJb0BMrpGjOInGGJeJ6U7rE";
      dbFile = pkgs.writeText "dbsecret" "HNWvNMIv9APPn9jl7K02Jh7EEpqtmPPrfgF7o0wUx4IrbmOFww";
      jwsFile = pkgs.runCommand "oidcKeyBase" { } "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      localhost = {
        locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      };
    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";

}
