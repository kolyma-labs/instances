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

      "build.kibertexnik.uz" = {
        extraConfig = ''
          basic_auth {
          kibertexnik $2a$14$8PT3WB2gjSsZ4gm1ImetTudnNuOdxZ1Fi61kS5Bq8DP8amMjdF63m
          }

          root * /srv/builds
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
    };
  };
}
