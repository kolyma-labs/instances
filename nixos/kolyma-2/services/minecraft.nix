{
  config,
  lib,
  ...
}: let
in {
  virtualisation.oci-containers.containers = {
    minecraft = {
      image = "itzg/minecraft-server:java8";
      ports = [
        "127.0.0.1:25565:25565"
      ];

      volumes = [
        "/srv/minecraft:/data"
      ];

      environment = {
        EULA = "TRUE";
        TYPE = "FORGE";
        MEMORY = "24G";
        VERSION = "1.19.2";
        FORGE_VERSION = "latest";
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
