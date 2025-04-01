{outputs, ...}: {
  imports = [outputs.nixosModules.caddy];

  # Enable web server & proxy
  services.www = {
    enable = true;
    alias = [
      "ns3.kolyma.uz"
      "slave.uz"
    ];
    hosts = {
    };
  };
}
