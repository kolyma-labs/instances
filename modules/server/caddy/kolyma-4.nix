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
            "ns4.kolyma.uz"
            "http://65.109.74.214"
            "http://2a01:4f9:3071:31ce::"
          ];
          extraConfig = ''
            root * ${pkgs.personal.gate}/www
            file_server
          '';
        };
      };
    };

    # Ensure the firewall allows HTTP and HTTPS traffic
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 80 443 ];
  };
}
