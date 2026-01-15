{
  lib,
  inputs,
  config,
  ...
}:
let
  cfg = config.kolyma.apps.khakimovs.website;
in
{
  imports = [
    inputs.khakimovs-website.nixosModules.server
  ];

  options = {
    kolyma.apps.khakimovs.website = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether to host github:khakimovs/website project in this server.";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        default = "khakimovs.uz";
        example = "example.com";
        description = "Domain for the website to be associated with.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.khakimovs-website = {
      enable = true;
      proxy = {
        enable = true;
        inherit (cfg) domain;
      };
    };

    services.nginx.virtualHosts."${cfg.domain}".locations = {
      # Responsible disclosure information https://securitytxt.org/
      "/.well-known/security.txt" =
        let
          securityTXT = lib.lists.foldr (a: b: a + "\n" + b) "" [
            "Contact: mailto:admin@kolyma.uz"
            "Expires: 2027-01-31T23:00:00.000Z"
            "Encryption: https://keys.openpgp.org/vks/v1/by-fingerprint/00D27BC687070683FBB9137C3C35D3AF0DA1D6A8"
            "Preferred-Languages: en,uz"
            "Canonical: https://${cfg.domain}/.well-known/security.txt"
          ];
        in
        {
          extraConfig = ''
            add_header Content-Type text/plain;
            return 200 '${securityTXT}';
          '';
        };
    };
  };
}
