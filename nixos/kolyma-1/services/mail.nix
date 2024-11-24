{
  inputs,
  config,
  pkgs,
  ...
}:
let
  secret-management = {
    owner = config.users.users.stalwart-mail.name;
  };
in
{
  disabledModules = [ "services/mail/stalwart-mail.nix" ];

  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/mail/stalwart-mail.nix" ];

  sops.secrets = {
    "mail/acme" = secret-management;
    "mail/admin" = secret-management;
    "mail/public-cert" = secret-management;
    "mail/private-cert" = secret-management;
    "mail/users/git" = secret-management;
    "mail/users/sakhib" = secret-management;
    "mail/users/misskey" = secret-management;
  };

  services.stalwart-mail = {
    enable = true;
    package = pkgs.stalwart-mail-wbf;
    openFirewall = true;

    settings = {
      server = {
        hostname = "mail.kolyma.uz";

        tls = {
          enable = true;
          implicit = true;
        };

        listener = {
          smtp = {
            protocol = "smtp";
            bind = "[::]:25";
          };
          submission = {
            bind = "[::]:587";
            protocol = "smtp";
          };
          submissions = {
            bind = "[::]:465";
            protocol = "smtp";
            tls.implicit = true;
          };
          imap = {
            bind = "[::]:143";
            protocol = "imap";
          };
          imaptls = {
            bind = "[::]:993";
            protocol = "imap";
            tls.implicit = true;
          };
          pop3 = {
            bind = "[::]:110";
            protocol = "pop3";
          };
          pop3s = {
            bind = "[::]:995";
            protocol = "pop3";
            tls.implicit = true;
          };
          sieve = {
            bind = "[::]:4190";
            protocol = "managesieve";
          };
          jmap = {
            bind = "[::]:8080";
            url = "https://mail.kolyma.uz";
            protocol = "http";
          };
          management = {
            bind = [ "127.0.0.1:8080" ];
            protocol = "http";
          };
        };
      };

      lookup.default = {
        hostname = "mail.kolyma.uz";
        domain = "kolyma.uz";
      };

      acme."letsencrypt" = {
        directory = "https://acme-v02.api.letsencrypt.org/directory";
        challenge = "dns-01";
        contact = "admin@kolyma.uz";
        domains = [
          "kolyma.uz"
          "mail.kolyma.uz"
        ];
        provider = "cloudflare";
        secret = "%{file:${config.sops.secrets."mail/acme".path}}%";
      };

      certificate."default" = {
        cert = "%{file:${config.sops.secrets."mail/public-cert".path}}%";
        private-key = "%{file:${config.sops.secrets."mail/private-cert".path}}%";
        default = true;
      };

      session.auth = {
        mechanisms = "[plain]";
        directory = "'in-memory'";
      };

      storage.directory = "in-memory";
      session.rcpt.directory = "'in-memory'";
      queue.outbound.next-hop = "'local'";
      directory."imap".lookup.domains = [ "kolyma.uz" ];
      directory."in-memory" = {
        type = "memory";
        principals = [
          {
            class = "individual";
            name = "orzklv";
            description = "Sokhibjon Orzikulov";
            secret = "%{file:${config.sops.secrets."mail/users/sakhib".path}}%";
            email = [
              "orzklv@kolyma.uz"
              "admin@kolyma.uz"
              "postmaster@kolyma.uz"
            ];
          }
        ];
      };

      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:${config.sops.secrets."mail/admin".path}}%";
      };
    };
  };

  services.www.hosts = {
    "mail.kolyma.uz" = {
      extraConfig = ''
        reverse_proxy http://127.0.0.1:8080
      '';
      serverAliases = [
        "mta-sts.kolyma.uz"
        "autoconfig.kolyma.uz"
        "autodiscover.kolyma.uz"
      ];
    };
  };
}
