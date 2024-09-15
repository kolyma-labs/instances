{ config
, lib
, pkgs
, outputs
, ...
}: {
  imports = [
    outputs.nixosModules.docker
  ];

  virtualisation.oci-containers.containers = {
    #  _       __     __         _ __
    # | |     / /__  / /_  _____(_) /____
    # | | /| / / _ \/ __ \/ ___/ / __/ _ \
    # | |/ |/ /  __/ /_/ (__  ) / /_/  __/
    # |__/|__/\___/_.___/____/_/\__/\___/
    website = {
      image = "ghcr.io/kolyma-labs/gate@sha256:2a1cfdfe8e78aa4173c260f5f1a40640785e182ca4aebfe09dc7b0544c4c24fd";
      ports = [ "8440:80" ];
    };
  };

  # Necessary firewall rules for docker containers
  # networking.firewall.allowedUDPPorts = [
  # ];
  # networking.firewall.allowedTCPPorts = [
  # ];
}
