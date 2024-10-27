{ pkgs, ... }:
{
  services.gitlab = {
    enable = true;
    host = "git.kolyma.uz";
    databasePasswordFile = pkgs.writeText "dbPassword" "n6DAe1ZcNWHHmMqLQoyVgcnz814V9q8yBRyg7ZhmnGgG6Az98r";
    initialRootPasswordFile = pkgs.writeText "rootPassword" "MImVJlIY7CTvloWaRyeCfvUpxPGoRgfMh2RFSgUOIhCu6DDvg6";
    secrets = {
      secretFile = pkgs.writeText "secret" "xlHvN7tfexeTbFVHbkVKESQbyTZXG9v1TZ1me9Txa4GtxUMeKI";
      otpFile = pkgs.writeText "otpsecret" "ME5h5Wh4NUjlvSqIM2tbBs9v44BVJb0BMrpGjOInGGJeJ6U7rE";
      dbFile = pkgs.writeText "dbsecret" "HNWvNMIv9APPn9jl7K02Jh7EEpqtmPPrfgF7o0wUx4IrbmOFww";
      jwsFile = pkgs.runCommand "oidcKeyBase" { } "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
    };

    smtp = {
      enable = true;
      port = 465;
      tls = true;
      opensslVerifyMode = "none";
      address = "mail.kolyma.uz";
      domain = "mail.kolyma.uz";
      authentication = "plain";
      enableStartTLSAuto = false;
      username = "orzklv";
      passwordFile = "/srv/git/mail-password.env";
    };

    extraConfig = {
      gitlab = {
        email_display_name = "Kolyma Git's Administration";
        email_reply_to = "noreply@kolyma.uz";
      };
    };
  };


  # Enable web server & proxy
  services.www = {
    hosts = {
      "git.kolyma.uz" = {
        extraConfig = ''
          reverse_proxy unix//run/gitlab/gitlab-workhorse.socket
        '';
      };
    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";
}
