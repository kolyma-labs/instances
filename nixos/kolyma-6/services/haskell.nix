{config, ...}: {
  services.anubis = {
    instances.haskell = {
      settings = {
        TARGET = "http://127.0.0.1:8450";
        DIFFICULTY = 100;
        WEBMASTER_EMAIL = "admin@kolyma.uz";
      };
    };
  };

  # Enable web server & proxy
  kolyma.www.hosts = {
    "haskell.uz" = {
      addSSL = true;
      enableACME = true;
      serverAliases = [
        "www.haskell.uz"
      ];

      locations."/" = {
        proxyPass = "http://unix:${config.services.anubis.instances.haskell.settings.BIND}";
        extraConfig = "";
      };
    };
  };
}
