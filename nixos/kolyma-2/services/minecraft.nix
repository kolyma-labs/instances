{
  config,
  lib,
  ...
}: let
in {
  virtualisation.oci-containers.containers = {
    minecraft = {
      image = "itzg/minecraft-server:java21";
      ports = [
        "25565:25565"
      ];

      volumes = [
        "/srv/minecraft:/data"
      ];

      environment = {
        EULA = "TRUE";
        TYPE = "FABRIC";
        MEMORY = "24G";
        VERSION = "1.19.2";
        FABRIC_LAUNCHER_VERSION = "1.0.3";
        FABRIC_LOADER_VERSION = "0.16.13";
      };
    };
  };

  networking = {
    firewall = {
      allowedUDPPorts = [25565];
      allowedTCPPorts = [25565];
    };
  };
}
