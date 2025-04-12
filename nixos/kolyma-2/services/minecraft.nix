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
        "127.0.0.1:25565:25565"
      ];

      volumes = [
        "/srv/minecraft:/data"
      ];

      environment = {
        EULA = "TRUE";
        TYPE = "FABRIC";
        MEMORY = "24G";
        FABRIC_LAUNCHER_VERSION = "1.0.3";
        FABRIC_LOADER_VERSION = "0.16.13";
        MODRINTH_PROJECTS = "fabric-api";
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
