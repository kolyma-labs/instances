{
  inputs,
  config,
  ...
}: let
  domain = "devops-journey.uz";
in {
  imports = [inputs.devops-journey.nixosModules.server];

  # Enable website module
  services.devops-journey = {
    enable = true;
    port = 8657;
    host = "127.0.0.1";

    proxy = {
      inherit domain;
      enable = false;
      proxy = "nginx";
      aliases = ["www.${domain}"];
    };
  };

  services.anubis = {
    instances.devops = {
      settings = {
        TARGET = "http://127.0.0.1:${toString config.services.devops-journey.port}";
        DIFFICULTY = 100;
        WEBMASTER_EMAIL = "admin@kolyma.uz";
      };
    };
  };

  services.www.hosts = {
    "${domain}" = {
      addSSL = true;
      enableACME = true;
      serverAliases = ["www.${domain}"];
      locations."/" = {
        proxyPass = "http://unix:${config.services.anubis.instances.devops.settings.BIND}";
        proxyWebsockets = true;
      };
    };
  };
}
