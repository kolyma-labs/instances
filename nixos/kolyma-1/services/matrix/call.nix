{
  config,
  domains,
}: let
  sopsFile = ../../../../secrets/efael.yaml;
in {
  sops.secrets = {
    "matrix/call/key" = {
      inherit sopsFile;
      key = "matrix/call";
    };
  };

  sops.templates."element-call.key" = {
    content = ''
      lk-jwt-service: ${config.sops.placeholder."matrix/call/key"}
    '';
  };

  services.livekit = {
    enable = true;
    keyFile = config.sops.templates."element-call.key".path;

    settings = {
      port = 7880;

      rtc = {
        tcp_port = 7881;
        port_range_start = 50000;
        port_range_end = 60000;
        use_external_ip = false;
      };
    };
  };

  services.lk-jwt-service = {
    enable = true;
    port = 8192;
    livekitUrl = "wss://${domains.livekit}";
    keyFile = config.services.livekit.keyFile;
  };

  networking.firewall = {
    interfaces.eth0 = let
      range = with config.services.livekit.settings.rtc; [
        {
          from = port_range_start;
          to = port_range_end;
        }
      ];
    in {
      allowedUDPPortRanges = range;
      allowedUDPPorts = [7881];
      allowedTCPPortRanges = range;
      allowedTCPPorts = [7881];
    };
  };
}
