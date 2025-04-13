{
  config,
  lib,
  ...
}: let
in {
  virtualisation.oci-containers.containers = {
    minecraft-gamemania = {
      image = "itzg/minecraft-server:java21";
      ports = [
        "24454:24454"
        "25565:25565"
      ];

      volumes = [
        "/srv/minecraft/gamemania:/data"
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

    minecraft-fear = {
      image = "itzg/minecraft-server:java23";
      ports = [
        "25566:25565"
      ];

      volumes = [
        "/srv/minecraft/fear:/data"
      ];

      environment = {
        EULA = "TRUE";
        TYPE = "MODRINTH";
        MEMORY = "24G";
        VERSION = "1.20.1";
        MODRINTH_MODPACK = "fearnightfall";
        MODRINTH_VERSION = "kFoOyRmJ";
        MODRINTH_LOADER = "forge";
      };
    };
  };

  networking = {
    firewall = {
      allowedUDPPorts = [25565 25566];
      allowedTCPPorts = [25565 25566];
    };
  };
}
