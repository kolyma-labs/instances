{
  lib,
  inputs,
  config,
  pkgs,
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
        owner = "stalwart-mail";
        sopsFile = ../../secrets/mail.yaml;
      };
    };

    services.stalwart-mail = {
      enable = true;
      package = pkgs.unstable.stalwart-mail;
      openFirewall = true;

      settings = {
        server = {
          hostname = "mx.${cfg.domain}";
          tls = {
            enable = true;
            implicit = true;
          };
          listener = {
            smtp = {
              protocol = "smtp";
              bind = "[::]:25";
            };
            submissions = {
              bind = "[::]:465";
              protocol = "smtp";
            };
            imaps = {
              bind = "[::]:993";
              protocol = "imap";
            };
            jmap = {
              bind = "[::]:8080";
              url = "https://mail.${cfg.domain}";
              protocol = "jmap";
            };
            management = {
              bind = ["127.0.0.1:8080"];
              protocol = "http";
            };
          };
        };

        lookup.default = {
          inherit (cfg) domain;
          hostname = "mx.${cfg.domain}";
        };

        acme."letsencrypt" = {
          directory = "https://acme-v02.api.letsencrypt.org/directory";
          challenge = "dns-01";
          contact = "admin@kolyma.uz";
          host = "ns1.kolyma.uz";
          tsig-algorithm = "hmac-sha512";
          domains = [cfg.domain "mx.${cfg.domain}"];
          provider = "rfc2136-tsig";
          key = "";
          secret = "";
        };

        session.auth = {
          mechanisms = "[plain]";
          directory = "'in-memory'";
        };

        storage.directory = "in-memory";
        session.rcpt.directory = "'in-memory'";
        queue.outbound.next-hop = "'local'";

        directory = {
          "imap".lookup.domains = [cfg.domain];
          "in-memory" = {
            type = "memory";
            principals = [
              {
                class = "individual";
                name = "postmaster";
                secret = "%{file:${cfg.service}}%";
                email = [
                  "abuse@${cfg.domain}"
                  "security@${cfg.domain}"
                  "alerts@${cfg.domain}"
                  "postmaster@${cfg.domain}"
                  "admin@${cfg.domain}"
                ];
              }
            ];
          };
          "keycloak" = {
            type = "oidc";
            timeout = "15s";
            endpoint.url = "https://auth.floss.uz/realms/floss.uz/protocol/openid-connect/userinfo";
            endpoint.method = "userinfo";
            fields.email = "email";
            fields.username = "preferred_username";
            fields.full-name = "name";
          };
        };
        authentication.fallback-admin = {
          user = "orzklv";
          secret = "%{file:${cfg.service}}%";
        };
      };
    };

    services.nginx.virtualHosts = {
      "mail.floss.uz" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
        };
        serverAliases = [
          "mta-sts.floss.uz"
          "autoconfig.floss.uz"
          "autodiscover.floss.uz"
        ];
      };
    };

    # mailserver = {
    #   enable = true;
    #   fqdn = "mail.${cfg.domain}";
    #   domains = [cfg.domain];

    #   localDnsResolver = false;
    #   indexDir = "/var/lib/dovecot/indices";
    #   fullTextSearch = {
    #     enable = true;
    #     # index new email as they arrive
    #     autoIndex = true;
    #     # forcing users to write body
    #     enforced = "body";
    #   };

    #   # Generating hashed passwords:
    #   # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    #   loginAccounts = {
    #     "admin@${cfg.domain}" = {
    #       quota = "2G";
    #       hashedPasswordFile = cfg.service;
    #       aliases = [
    #         "abuse@${cfg.domain}"
    #         "security@${cfg.domain}"
    #         "alerts@${cfg.domain}"
    #         "postmaster@${cfg.domain}"
    #       ];
    #     };

    #     "support@${cfg.domain}" = {
    #       quota = "2G";
    #       hashedPasswordFile = cfg.service;
    #       aliases = ["developers@${cfg.domain}" "maintainers@${cfg.domain}"];
    #     };

    #     "noreply@${cfg.domain}" = {
    #       quota = "2G";
    #       sendOnly = true;
    #       hashedPasswordFile = cfg.service;
    #     };

    #     "orzklv@${cfg.domain}" = {
    #       quota = "2G";
    #       hashedPasswordFile = cfg.service;
    #       aliases = ["sakhib@${cfg.domain}"];
    #     };
    #   };

    #   # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    #   # down nginx and opens port 80.
    #   certificateScheme = "acme-nginx";
    # };
  };
}
