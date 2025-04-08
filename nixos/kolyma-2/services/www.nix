{outputs, ...}: {
  imports = [outputs.nixosModules.caddy];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = ["ns2.kolyma.uz"];
    hosts = {
      "cdn2.kolyma.uz" = {
        extraConfig = ''
          root * /srv/cdn
          file_server browse
        '';
      };

      "haskell.uz" = {
        serverAliases = [
          "www.haskell.uz"
        ];
        extraConfig = ''
          reverse_proxy 127.0.0.1:8450 {
            header_up Host {host}
            header_up X-Real-IP {remote}
            header_up Upgrade {http_upgrade}
            header_up Connection {>Connection}
            header_up X-Forwarded-Proto {scheme}
          }
        '';
      };

      "mod.sabine.uz" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8100
        '';
      };
    };
  };
}
