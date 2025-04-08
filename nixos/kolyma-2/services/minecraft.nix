{
  config,
  lib,
  ...
}: let
in {
  virtualisation.oci-containers.containers = {
    minecraft = {
      image = "itzg/minecraft-server:latest";
      ports = [
        "127.0.0.1:25565:25565"
      ];

      volumes = [
        "/srv/minecraft:/data"
      ];

      environment = {
        EULA = "TRUE";
        TYPE = "CRUCIBLE";
        VERSION = "1.7.10";
        CRUCIBLE_RELEASE = "latest";
        MEMORY = "24G";
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
