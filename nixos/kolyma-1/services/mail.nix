{
  inputs,
  config,
  pkgs,
  ...
}: let
  secret-management = {
    owner = config.users.users.stalwart-mail.name;
  };
in {
  disabledModules = [
    "services/mail/stalwart-mail.nix"
  ];

  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/mail/stalwart-mail.nix"
  ];

  sops.secrets = {
    "stalwart/admin" = secret-management;
    "stalwart/sakhib" = secret-management;
    "stalwart/postmaster" = secret-management;
  };

  services.stalwart-mail = {
    enable = true;
    package = pkgs.unstable.stalwart-mail;
    openFirewall = true;

    settings = {
      server = {
        hostname = "mail.floss.uz";

        tls = {
          enable = true;
          implicit = true;
          # certificate = "default";
        };

        # certificate.default = {
        #   default = true;
        #   cert = "%{file:/opt/stalwart-mail/cert/example.com.pem}%";
        #   private-key = "%{file:/opt/stalwart-mail/cert/example.com.priv.pem}%";
        # };

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
            bind = "[::]:8093";
            url = "https://mail.floss.uz";
            protocol = "jmap";
          };
          management = {
            bind = ["127.0.0.1:8093"];
            protocol = "http";
          };
        };
      };

      lookup.default = {
        hostname = "mail.floss.uz";
        domain = "floss.uz";
      };

      session.auth = {
        mechanisms = "[plain]";
        directory = "'in-memory'";
      };

      storage.directory = "in-memory";
      session.rcpt.directory = "'in-memory'";
      queue.outbound.next-hop = "'local'";
      directory."imap".lookup.domains = ["floss.uz"];
      directory."in-memory" = {
        type = "memory";
        principals = [
          {
            class = "individual";
            name = "Sokhibjon Orzikulov";
            secret = "%{file:${config.sops.secrets."stalwart/sakhib".path}}%";
            email = ["orzklv@floss.uz" "admin@floss.uz"];
          }
          {
            class = "individual";
            name = "postmaster";
            secret = "%{file:${config.sops.secrets."stalwart/postmaster".path}}%";
            email = ["postmaster@floss.uz" "support@floss.uz" "maintainers@floss.uz" "developers@floss.uz"];
          }
        ];
      };

      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:${config.sops.secrets."stalwart/admin".path}}%";
      };
    };
  };

  # services.cron = {
  #   enable = true;
  #   systemCronJobs = [
  #     "0 3 * * * root cat /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/floss.uz/floss.uz.crt > /opt/stalwart-mail/cert/floss.uz.pem"
  #     "0 3 * * * root cat /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/floss.uz/floss.uz.key > /opt/stalwart-mail/cert/floss.uz.priv.pem"
  #   ];
  # };

  services.www.hosts = {
    "wm.floss.uz" = {
      extraConfig = ''
        reverse_proxy http://127.0.0.1:8093
      '';
      serverAliases = [
        "mta-sts.floss.uz"
        "autoconfig.floss.uz"
        "autodiscover.floss.uz"
        "mail.floss.uz"
      ];
    };
  };
}
