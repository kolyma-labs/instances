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
    "gitlab/salt" = secret-management;
    "gitlab/primary" = secret-management;
    "gitlab/deterministic" = secret-management;
    "gitlab/mail" = {
      owner = config.services.gitlab.user;
      key = "mail/icloud/password";
    };
  };

  services.gitlab = {
    enable = true;
    host = "gulag.uz";

    # Passwords
    databasePasswordFile = config.sops.secrets."gitlab/database".path;
    initialRootPasswordFile = config.sops.secrets."gitlab/root".path;

    # Secret token
    secrets = {
      dbFile = config.sops.secrets."gitlab/db".path;
      otpFile = config.sops.secrets."gitlab/otp".path;
      secretFile = config.sops.secrets."gitlab/secret".path;
      jwsFile = pkgs.runCommand "oidcKeyBase" {} "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
      activeRecordSaltFile = config.sops.secrets."gitlab/salt".path;
      activeRecordPrimaryKeyFile = config.sops.secrets."gitlab/primary".path;
      activeRecordDeterministicKeyFile = config.sops.secrets."gitlab/deterministic".path;
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

  services.anubis = {
    instances.gitlab = {
      settings = {
        TARGET = "unix:///run/gitlab/gitlab-workhorse.socket";
        DIFFICULTY = 100;
        WEBMASTER_EMAIL = "admin@kolyma.uz";
      };
    };
  };

  users.groups.gitlab.members = ["nginx"];

  # Enable web server & proxy
  services.www.hosts = {
    "gulag.uz" = {
      addSSL = true;
      enableACME = true;
      locations = {
        "/".proxyPass = "http://unix:${config.services.anubis.instances.gitlab.settings.BIND}";
      };
    };

    "git.kolyma.uz" = {
      addSSL = true;
      enableACME = true;
      extraConfig = ''
        return 301 https://gulag.uz$request_uri;
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
