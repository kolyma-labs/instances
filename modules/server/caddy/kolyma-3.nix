{ config
, lib
, pkgs
, ...
}: {
  config = {
    # Configure Caddy
    services.caddy = {
      # Enable the Caddy web server
      enable = true;

      # Define a simple virtual host
      virtualHosts = {
        "kolyma.uz" = {
          serverAliases = [
            "www.kolyma.uz"
            "ns3.kolyma.uz"
            "http://95.216.248.25"
            "http://2a01:4f9:3070:322c::"
          ];
          extraConfig = ''
            reverse_proxy 127.0.0.1:8440
          '';
        };

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

    # Ensure the firewall allows HTTP and HTTPS traffic
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 80 443 ];
  };
}
