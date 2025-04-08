{outputs, ...}: {
  imports = [outputs.nixosModules.caddy];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [
      "slave.uz"
      "ns3.kolyma.uz"
    ];
    hosts = {
      "sabine.uz" = {
        serverAliases = ["www.sabine.uz"];
        extraConfig = ''
          reverse_proxy 127.0.0.1:8100
        '';
      };
    };
  };
}
