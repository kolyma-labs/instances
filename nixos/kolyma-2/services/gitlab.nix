{ config, pkgs, ... }:
let
  secret-management = {
    owner = config.services.gitlab.user;
  };
in
{
  sops.secrets = {
    "git/db" = secret-management;
    "git/otp" = secret-management;
    "git/root" = secret-management;
    "git/secret" = secret-management;
    "git/database" = secret-management;
    "mail/users/git" = secret-management;
  };

  services.gitlab = {
    enable = true;
    host = "gulag.uz";
    databasePasswordFile = config.sops.secrets."git/database".path;
    initialRootPasswordFile = config.sops.secrets."git/root".path;
    secrets = {
      dbFile = config.sops.secrets."git/db".path;
      otpFile = config.sops.secrets."git/otp".path;
      secretFile = config.sops.secrets."git/secret".path;
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
      passwordFile = config.sops.secrets."mail/users/git".path;
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
  services.www.hosts = {
    "old.gulag.uz" = {
      extraConfig = ''
        reverse_proxy unix//run/gitlab/gitlab-workhorse.socket
      '';
    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";
}
