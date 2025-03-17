{config, ...}: let
in {
  config = {
    services.owncast = {
      enable = true;
    };

    services.www.hosts = {
      "live.orzklv.uz" = {
        extraConfig = ''
          reverse_proxy ${config.services.owncast.listen}:${toString config.services.owncast.port}
        '';
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
