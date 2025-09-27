{
  outputs,
  config,
  ...
}: {
  imports = [outputs.nixosModules.web];

  users.users.nginx.extraGroups = [config.users.groups.anubis.name];

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
  kolyma.www = {
    enable = true;
    domain = "ns6.kolyma.uz";

    hosts = {
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
  };
}
