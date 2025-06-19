{outputs, ...}: {
  imports = [outputs.nixosModules.nginx];

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

      "mc.floss.uz" = {
        addSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:8100";
          extraConfig = "";
        };
      };
    };
  };
}
