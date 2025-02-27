{
  config,
  pkgs,
  ...
}: let
  secret-management = {
    owner = config.services.gitlab.user;
  };
in {
  sops.secrets = {
    "gitlab/db" = secret-management;
    "gitlab/otp" = secret-management;
    "gitlab/root" = secret-management;
    "gitlab/secret" = secret-management;
    "gitlab/database" = secret-management;
    "mail/username" = secret-management;
    "mail/password" = secret-management;
  };

  services.gitlab = {
    enable = true;
    host = "gulag.uz";
    databasePasswordFile = config.sops.secrets."gitlab/database".path;
    initialRootPasswordFile = config.sops.secrets."gitlab/root".path;
    secrets = {
      dbFile = config.sops.secrets."gitlab/db".path;
      otpFile = config.sops.secrets."gitlab/otp".path;
      secretFile = config.sops.secrets."gitlab/secret".path;
      jwsFile = pkgs.runCommand "oidcKeyBase" {} "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
    };

    # Sending mail via Kolyma's SMTP
    smtp = {
      # Enabling smtp mailing
      enable = true;

      # Connection configuration
      tls = true;
      port = 587;
      authentication = "plain";
      domain = "smtp.mail.me.com";
      opensslVerifyMode = "none";
      address = "smtp.mail.me.com";
      enableStartTLSAuto = false;

      # Credentials for SMTP
      username = "sakhib.orzklv@icloud.com";
      passwordFile = config.sops.secrets."mail/password".path;
    };

    # Settings to be appended at gitlab.yml
    extraConfig = {
      gitlab = {
        email_from = "support@kolyma.uz";
        email_display_name = "Kolyma Administration";
        email_reply_to = "support@kolyma.uz";
      };
      gitlab_shell = {
        ssh_port = 22;
      };
    };
  };

  # Enable web server & proxy
  services.www.hosts = {
    "gulag.uz" = {
      extraConfig = ''
        reverse_proxy unix//run/gitlab/gitlab-workhorse.socket
      '';
    };

    "git.kolyma.uz" = {
      extraConfig = ''
        redir https://gulag.uz{uri} permanent
      '';
    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";
}
