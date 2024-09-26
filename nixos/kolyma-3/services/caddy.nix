{ outputs, ... }: {
  imports = [
    outputs.serverModules.caddy
  ];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [ "ns3.kolyma.uz" ];
    hosts = {
      "khakimovs.uz" = {
        serverAliases = [
          "www.khakimovs.uz"
        ];
        extraConfig = ''
          reverse_proxy 127.0.0.1:8441
        '';
      };

      "cxsmxs.space" = {
        serverAliases = [
          "www.cxsmxs.space"
        ];
        extraConfig = ''
            reverse_proxy 127.0.0.1:8100 {
              header_up Host {host}
          		header_up X-Real-IP {remote}
          		header_up Upgrade {http_upgrade}
          		header_up Connection {>Connection}
            }
        '';
      };

      "haskell.uz" = {
        serverAliases = [
          "www.haskell.uz"
          "chat.haskell.uz"
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

      "xinuxmgr.xinux.uz" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8445
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
