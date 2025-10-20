{
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.kolyma.apps.floss.website;
in {
  imports = [
    inputs.floss-website.nixosModules.server
  ];

  options = {
    kolyma.apps.floss.website = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether to host github:floss-uz/website project in this server.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        default = "floss.uz";
        example = "example.com";
        description = "Domain for the website to be associated with.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.floss-website = {
      enable = true;
      port = 51001;

      proxy = {
        enable = true;
        proxy = "nginx";
        inherit (cfg) domain;
      };
    };

    services.nginx.virtualHosts."${cfg.domain}".locations = {
      # serve base domain floss.uz for social.floss.uz
      # https://masto.host/mastodon-usernames-different-from-the-domain-used-for-installation/
      "/.well-known/host-meta" = {
        extraConfig = ''
          return 301 https://social.${cfg.domain}$request_uri;
        '';
      };

      # Tailscale OIDC webfinger requirement plus Mastodon webfinger redirect
      "/.well-known/webfinger" = {
        # Redirect requests that match /.well-known/webfinger?resource=* to Mastodon
        extraConfig = ''
          if ($arg_resource) {
            return 301 https://social.${cfg.domain}$request_uri;
          }

          add_header Content-Type text/plain;
          return 200 '{\n  "subject": "acct:admin@floss.uz",\n  "links": [\n    {\n    "rel": "http://openid.net/specs/connect/1.0/issuer",\n    "href": "https://auth.${cfg.domain}/realms/${cfg.domain}"\n    }\n  ]\n}';
        '';
      };

      # Responsible disclosure information https://securitytxt.org/
      "/.well-known/security.txt" = let
        securityTXT = lib.lists.foldr (a: b: a + "\n" + b) "" [
          "Contact: mailto:admin@floss.uz"
          "Expires: 2027-01-31T23:00:00.000Z"
          "Encryption: https://keys.openpgp.org/vks/v1/by-fingerprint/00D27BC687070683FBB9137C3C35D3AF0DA1D6A8"
          "Preferred-Languages: en,uz"
          "Canonical: https://${cfg.domain}/.well-known/security.txt"
        ];
      in {
        extraConfig = ''
          add_header Content-Type text/plain;
          return 200 '${securityTXT}';
        '';
      };

      "/satzung" = {
        extraConfig = ''
          return 302 https://cloud.${cfg.domain}/s/LqrKjysypda3mR6;
        '';
      };
    };
  };
}
