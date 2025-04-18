{...}: let
in {
  virtualisation.oci-containers.containers = {
    minecraft-gamemania = {
      image = "itzg/minecraft-server:java17";
      ports = [
        "24454:24454"
        "25565:25565"
        "25575:25575"
      ];

      volumes = [
        "/srv/minecraft/gamemania:/data"
      ];

      environment = {
        EULA = "TRUE";
        TYPE = "FORGE";
        MEMORY = "24G";
        VERSION = "1.19.2";
        FORGE_VERSION = "latest";
      };
    };

    minecraft-fear = {
      image = "itzg/minecraft-server:java17";
      ports = [
        "25566:25565"
      ];

      volumes = [
        "/srv/minecraft/fear:/data"
      ];

      environment = {
        EULA = "TRUE";
        TYPE = "FORGE";
        MEMORY = "24G";
        VERSION = "1.20.1";
        FORGE_VERSION = "latest";
      };
    };

    minecraft-deceased = {
      image = "itzg/minecraft-server:java17";
      ports = [
        "25567:25565"
      ];

      volumes = [
        "/srv/minecraft/deceased:/data"
      ];

      environment = {
        EULA = "TRUE";
        TYPE = "FORGE";
        MEMORY = "24G";
        VERSION = "1.18.2";
        FORGE_VERSION = "latest";
      };
    };
  };

  networking = {
    firewall = {
      allowedUDPPorts = [25565 25566 25567 25575];
      allowedTCPPorts = [25565 25566 25567 25575];
    };
  };
}
