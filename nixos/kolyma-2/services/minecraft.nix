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
        TYPE = "CUSTOM";
        CUSTOM_SERVER = "https://adfoc.us/serve/sitelinks/?id=765928&url=https://mohistmc.com/api/v2/projects/mohist/1.19.2/builds/873d239111d0a374c2a9a5d6bfbcffe2087d94f8/mohist-1.19.2-873d2391-server.jar";
        MEMORY = "24G";
        VERSION = "1.19.2";
        FORGE_VERSION = "latest";
      };
    };
  };

  networking = {
    firewall = {
      allowedUDPPorts = [24454 25565 25575];
      allowedTCPPorts = [24454 25565 25575];
    };
  };
}
