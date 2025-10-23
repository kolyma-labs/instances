{
  lib,
  inputs,
  config,
  ...
}: let
  base = "uzinfocom.uz";

  cfg = config.kolyma.apps.uzinfocom;

  website = lib.mkIf cfg.website.enable {
    services = {
      uzinfocom.website = lib.mkIf cfg.website.enable {
        enable = true;
        port = 51003;
        host = "127.0.0.1";

        proxy = {
          enable = false;
          proxy = "nginx";
          domain = "oss.${base}";
        };
      };

      nginx.virtualHosts = {
        "oss.${base}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/".proxyPass = "http://${config.services.uzinfocom.website.host}:${toString config.services.uzinfocom.website.port}";
          };
        };
      };
    };
  };

  social = lib.mkIf cfg.social.enable {
    services = {
      uzinfocom.taggis = {
        enable = true;
        port = 51004;
        host = "127.0.0.1";

        proxy = {
          enable = false;
          proxy = "nginx";
          domain = "link.${base}";
        };
      };

      nginx.virtualHosts = {
        "link.${base}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/".proxyPass = "http://${config.services.uzinfocom.taggis.host}:${toString config.services.uzinfocom.taggis.port}";
          };
        };
      };
    };
  };
in {
  imports = [
    inputs.uzinfocom-website.nixosModules.server
    inputs.uzinfocom-taggis.nixosModules.server
  ];

  options = {
    kolyma.apps.uzinfocom = {
      website = {
        enable = lib.mkEnableOption "Uzinfocom OSS'es Website";
      };

      social = {
        enable = lib.mkEnableOption "Uzinfocom's Social Website";
      };
    };
  };

  config = lib.mkMerge [website social];
}
