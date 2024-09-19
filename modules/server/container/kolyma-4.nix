{ config
, lib
, pkgs
, outputs
, ...
}: {
  imports = [
    outputs.nixosModules.docker
  ];

  virtualisation.oci-containers.containers = { };

  # Necessary firewall rules for docker containers
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowedTCPPorts = [ ];
}
