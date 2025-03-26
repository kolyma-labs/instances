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
    "gitlab/mail" = {
      owner = config.services.gitlab.user;
      key = "mail/password";
    };
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
      port = 587;
      authentication = "plain";
      domain = "smtp.mail.me.com";
      opensslVerifyMode = "none";
      address = "smtp.mail.me.com";
      enableStartTLSAuto = true;

      # Credentials for SMTP
      username = "sakhib.orzklv@icloud.com";
      passwordFile = config.sops.secrets."gitlab/mail".path;
    };

    # Settings to be appended at gitlab.yml
    extraConfig = {
      gitlab = {
        email_from = "support@kolyma.uz";
        email_display_name = "Kolyma Administration";
        email_reply_to = "support@kolyma.uz";
      };
      # Do `sudo passwd -d gitlab` if ssh stops working
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

  # Ensure the firewall allows HTTP and HTTPS traffic
  networking.firewall.allowedTCPPorts = [
    22 # GitLab Shell
  ];
  networking.firewall.allowedUDPPorts = [
    22 # GitLab Shell
  ];

  systemd.services.gitlab-backup.environment.BACKUP = "dump";
}
