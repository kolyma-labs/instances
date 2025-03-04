{
  config,
  lib,
  ...
}: let
  general = {
    virtualisation = {
      docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune = {
          enable = true;
          dates = "daily";
        };
      };

      oci-containers = {
        backend = "docker";
        containers = config.services.containers.instances;
      };
    };
  };

  ports = {
    networking.firewall.allowedTCPPorts = config.services.containers.ports;
    networking.firewall.allowedUDPPorts = config.services.containers.ports;
  };

  cfg = lib.mkMerge [
    general
    ports
  ];
in {
  options = {
    services.containers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the containers service";
      };

      instances = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "List of hosted container instances.";
      };

      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "List of zones to be served.";
      };
    };
  };

  config = lib.mkIf config.services.containers.enable cfg;
}
