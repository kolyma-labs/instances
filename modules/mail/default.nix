{
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.kolyma.mail;
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  options = {
    kolyma.mail = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Deploy a mail service in server.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        default = "kolyma.uz";
        description = "Use the appointed domain for mail service.";
      };

      service = lib.mkOption {
        type = lib.types.path;
        default = config.sops.secrets."mail/hashed".path;
        description = "Path of file containing password for service accounts";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "mail/hashed" = {
        key = "mail/hashed";
        sopsFile = ../../secrets/mail.yaml;
      };
    };

    mailserver = {
      enable = true;
      fqdn = "mail.${cfg.domain}";
      domains = [cfg.domain];

      localDnsResolver = false;
      indexDir = "/var/lib/dovecot/indices";
      fullTextSearch = {
        enable = true;
        # index new email as they arrive
        autoIndex = true;
        # forcing users to write body
        enforced = "body";
      };

      dmarcReporting = {
        enable = true;
      };

      # Generating hashed passwords:
      # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
      loginAccounts = {
        "admin@${cfg.domain}" = {
          quota = "2G";
          hashedPasswordFile = cfg.service;
          aliases = [
            "abuse@${cfg.domain}"
            "security@${cfg.domain}"
            "alerts@${cfg.domain}"
            "postmaster@${cfg.domain}"
          ];
        };

        "support@${cfg.domain}" = {
          quota = "2G";
          hashedPasswordFile = cfg.service;
          aliases = ["developers@${cfg.domain}" "maintainers@${cfg.domain}"];
        };

        "noreply@${cfg.domain}" = {
          quota = "2G";
          sendOnly = true;
          hashedPasswordFile = cfg.service;
        };

        "orzklv@${cfg.domain}" = {
          quota = "2G";
          hashedPasswordFile = cfg.service;
          aliases = ["sakhib@${cfg.domain}"];
        };
      };

      # Use Let's Encrypt certificates. Note that this needs to set up a stripped
      # down nginx and opens port 80.
      certificateScheme = "acme-nginx";
    };
  };
}
