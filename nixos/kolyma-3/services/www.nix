{ outputs, pkgs, ... }:
{
  imports = [ outputs.nixosModules.caddy ];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [ "ns3.kolyma.uz" ];
    hosts = {
      "khakimovs.uz" = {
        serverAliases = [ "www.khakimovs.uz" ];
        extraConfig = ''
          root * ${pkgs.personal.khakimovs}/www
          file_server
        '';
      };

      "map.slave.uz" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8100
        '';
      };

      "cryptoshop.uz" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8461
        '';
      };

      "api.cryptoshop.uz" = {
        extraConfig = ''
          reverse_proxy /payme/jsonrpc 127.0.0.1:6666
          reverse_proxy * 127.0.0.1:8460
        '';
      };
    };
  };
}
