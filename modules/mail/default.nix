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

      credentials = {
        "password" = cfg.service;
      };

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
              bind = "[::]:8081";
              url = "https://mail.${cfg.domain}";
              protocol = "jmap";
            };
            management = {
              bind = ["127.0.0.1:8081"];
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
                secret = "%{file:/run/credentials/stalwart-mail.service/password}%";
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
          secret = "%{file:/run/credentials/stalwart-mail.service/password}%";
        };
      };
    };

    services.nginx.virtualHosts = {
      "mail.${cfg.domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8081";
        };
        serverAliases = [
          "mta-sts.${cfg.domain}"
          "autoconfig.${cfg.domain}"
          "autodiscover.${cfg.domain}"
        ];
      };
    };
  };
}
