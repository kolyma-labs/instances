{
  inputs,
  config,
  ...
}: let
  base = "uzinfocom.uz";
in {
  imports = [
    inputs.uzinfocom-website.nixosModules.server
    inputs.uzinfocom-taggis.nixosModules.server
  ];

  services = {
    # Enable website module
    uzinfocom.website = {
      enable = true;
      port = 8659;
      host = "127.0.0.1";

      proxy = {
        enable = false;
        proxy = "nginx";
        domain = "oss.${base}";
      };
    };

    # Enable website module
    uzinfocom.taggis = {
      enable = true;
      port = 8658;
      host = "127.0.0.1";

      proxy = {
        enable = false;
        proxy = "nginx";
        domain = "link.${base}";
      };
    };

    anubis.instances = {
      uzinfocom-website = {
        settings = {
          TARGET = "http://127.0.0.1:${toString config.services.uzinfocom.website.port}";
          DIFFICULTY = 100;
          WEBMASTER_EMAIL = "admin@kolyma.uz";
        };
      };

      uzinfocom-taggis = {
        settings = {
          TARGET = "http://127.0.0.1:${toString config.services.uzinfocom.taggis.port}";
          DIFFICULTY = 100;
          WEBMASTER_EMAIL = "admin@kolyma.uz";
        };
      };
    };
  };

  kolyma.www.hosts = {
    "oss.${base}" = {
      addSSL = true;
      enableACME = true;
      locations = {
        "/".proxyPass = "http://unix:${config.services.anubis.instances.uzinfocom-website.settings.BIND}";
      };
    };

    "link.${base}" = {
      addSSL = true;
      enableACME = true;
      locations = {
        "/".proxyPass = "http://unix:${config.services.anubis.instances.uzinfocom-taggis.settings.BIND}";
      };
    };
  };
}
