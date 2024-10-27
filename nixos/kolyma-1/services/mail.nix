{ pkgs, ... }:
let
  domain = "mail.kolyma.uz";
in
{
  environment.etc = {
    "stalwart/mail-pw1".text = "foobar";
    "stalwart/mail-pw2".text = "foobar";
    "stalwart/admin-pw".text = "foobar";
    "stalwart/acme-secret".text = "secret123";
  };

  services.stalwart-mail = {
    enable = true;
    package = pkgs.stalwart-mail;
    # openFirewall = true;

    settings = {
      server = {
        hostname = "mx.kolyma.uz";
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
            url = "https://mail.kolyma.uz";
            protocol = "jmap";
          };
          management = {
            bind = [ "127.0.0.1:8080" ];
            protocol = "http";
          };
        };
      };
      lookup.default = {
        hostname = "mx.kolyma.uz";
        domain = "kolyma.uz";
      };
      acme."letsencrypt" = {
        directory = "https://acme-v02.api.letsencrypt.org/directory";
        challenge = "dns-01";
        contact = "user1@kolyma.uz";
        domains = [ "kolyma.uz" "mx.kolyma.uz" ];
        provider = "cloudflare";
        secret = "%{file:/etc/stalwart/acme-secret}%";
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
            name = "User 1";
            secret = "%{file:/etc/stalwart/mail-pw1}%";
            email = [ "user1@kolyma.uz" ];
          }
          {
            class = "individual";
            name = "postmaster";
            secret = "%{file:/etc/stalwart/mail-pw1}%";
            email = [ "postmaster@kolyma.uz" ];
          }
        ];
      };
      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:/etc/stalwart/admin-pw}%";
      };
    };
  };

  services.www.hosts = {
    "wm.kolyma.uz" = {
      extraConfig = ''
        reverse_proxy http://127.0.01:8080
      '';
      serverAliases = [
        "mta-sts.kolyma.uz"
        "autoconfig.kolyma.uz"
        "autodiscover.kolyma.uz"
        "mail.kolyma.uz"
      ];
    };
  };
}
