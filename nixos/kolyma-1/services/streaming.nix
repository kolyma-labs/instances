{config, ...}: {
  config = {
    services.owncast = {
      enable = true;
      port = 8356;
    };

    services.www.hosts = {
      "live.orzklv.uz" = {
        addSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://${config.services.owncast.listen}:${toString config.services.owncast.port}";
          proxyWebsockets = true;
          extraConfig =
            "proxy_ssl_server_name on;"
            + "proxy_pass_header Authorization;";
        };
      };
    };

    networking = {
      firewall = {
        enable = true;
        allowedTCPPorts = [
          config.services.owncast.rtmp-port
        ];
        allowedUDPPorts = [
          config.services.owncast.rtmp-port
        ];
      };
    };
  };
}
