{config, ...}: {
  config = {
    services.owncast = {
      enable = true;
      port = 8356;
    };

    services.anubis = {
      instances.owncast = {
        settings = {
          TARGET = "http://${config.services.owncast.listen}:${toString config.services.owncast.port}";
          DIFFICULTY = 100;
          WEBMASTER_EMAIL = "admin@kolyma.uz";
        };
      };
    };

    services.www.hosts = {
      "live.orzklv.uz" = {
        addSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://unix:${config.services.anubis.instances.owncast.settings.BIND}";
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
