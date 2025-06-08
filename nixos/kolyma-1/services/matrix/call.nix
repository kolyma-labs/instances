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
    openFirewall = true;
    keyFile = config.sops.templates."element-call.key".path;
  };

  services.lk-jwt-service = {
    enable = true;
    livekitUrl = "wss://${domains.call}/livekit/sfu";
    keyFile = config.services.livekit.keyFile;
  };
}
