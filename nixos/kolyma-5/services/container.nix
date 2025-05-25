{
  outputs,
  pkgs,
  ...
}: let
  ports = [
    80
    443
    7881
    8448
  ];
in {
  imports = [outputs.nixosModules.container];

  # Enable containerization
  services.containers = {
    enable = true;
    ports = [];

    instances = {};
  };

  # Ensure the firewall allows HTTP and HTTPS traffic
  networking.firewall.allowedTCPPorts = ports;
  networking.firewall.allowedUDPPorts = ports;
}
