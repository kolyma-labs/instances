{
  outputs,
  config,
  ...
}: {
  imports = [outputs.nixosModules.nginx];

  users.users.nginx.extraGroups = [config.users.groups.anubis.name];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = ["ns2.kolyma.uz"];
    no-default = true;
    hosts = {
      "cdn2.kolyma.uz" = {
        addSSL = true;
        enableACME = true;
        root = "/srv/cdn";
        extraConfig = ''
          autoindex on;
        '';
      };

      "haskell.uz" = {
        addSSL = true;
        enableACME = true;
        serverAliases = [
          "www.haskell.uz"
        ];

        locations."/" = {
          proxyPass = "http://127.0.0.1:8450";
          extraConfig = "";
        };
      };
    };
  };
}
