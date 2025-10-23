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

      anubis.instances = {
        uzinfocom-website = {
          settings = {
            TARGET = "http://${config.services.uzinfocom.website.host}:${toString config.services.uzinfocom.website.port}";
            DIFFICULTY = 100;
            WEBMASTER_EMAIL = "admin@kolyma.uz";
          };
        };
      };

      nginx.virtualHosts = {
        "oss.${base}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/".proxyPass = "http://unix:${config.services.anubis.instances.uzinfocom-website.settings.BIND}";
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

      anubis.instances = {
        uzinfocom-taggis = {
          settings = {
            TARGET = "http://${config.services.uzinfocom.taggis.host}:${toString config.services.uzinfocom.taggis.port}";
            DIFFICULTY = 100;
            WEBMASTER_EMAIL = "admin@kolyma.uz";
          };
        };
      };

      nginx.virtualHosts = {
        "link.${base}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/".proxyPass = "http://unix:${config.services.anubis.instances.uzinfocom-taggis.settings.BIND}";
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
