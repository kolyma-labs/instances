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

    # Sending mail via Kolyma's SMTP
    smtp = {
      # Enabling smtp mailing
      enable = true;

      # Connection configuration
      tls = true;
      port = 465;
      authentication = "plain";
      domain = "mail.kolyma.uz";
      opensslVerifyMode = "none";
      address = "mail.kolyma.uz";
      enableStartTLSAuto = false;

      # Credentials for SMTP
      username = "git";
      passwordFile = "/srv/git/mail-password.env";
    };

    # Settings to be appended at gitlab.yml
    extraConfig = {
      gitlab = {
        email_from = "staff@kolyma.uz";
        email_display_name = "Kolyma Git Administration";
        email_reply_to = "noreply@kolyma.uz";
      };
      gitlab_shell = {
        ssh_port = 2222;
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
