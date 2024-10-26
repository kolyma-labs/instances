{ outputs, ... }: {
  imports = [
    outputs.nixosModules.caddy
  ];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [ "ns2.kolyma.uz" ];
    hosts = {
      "mail.kolyma.uz" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8460
        '';
      };

      "old.kolyma.uz" = {
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
