{
  config,
  inputs,
  ...
}: let
  domain = "floss.uz";
  alt-domain = "foss.uz";
in {
  imports = [inputs.floss-website.nixosModules.server];

  # Enable website module
  services.floss-website = {
    enable = true;
    port = 8656;
    host = "127.0.0.1";

    proxy = {
      enable = false;
    };
  };

  services.anubis = {
    instances.floss = {
      settings = {
        TARGET = "http://${config.services.floss-website.host}:${toString config.services.floss-website.port}";
        DIFFICULTY = 100;
        WEBMASTER_EMAIL = "admin@kolyma.uz";
      };
    };
  };

  services.www.hosts = {
    "${domain}" = {
      addSSL = true;
      enableACME = true;

      serverAliases = [
        "www.${domain}"
        "${alt-domain}"
        "www.${alt-domain}"
      ];

      locations."/" = {
        proxyPass = "http://unix:${config.services.anubis.instances.floss.settings.BIND}";
      };
    };
  };
}
