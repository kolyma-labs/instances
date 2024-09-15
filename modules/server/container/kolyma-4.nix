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
      image = "ghcr.io/kolyma-labs/gate@sha256:3014ffb25d3e15351d5c70afe0ef2f00242cc14c294aaf0facc2741041de30fb";
      ports = [ "8440:80" ];
    };
  };

  # Necessary firewall rules for docker containers
  # networking.firewall.allowedUDPPorts = [
  # ];
  # networking.firewall.allowedTCPPorts = [
  # ];
}
