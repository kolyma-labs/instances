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
        containers = config.kolyma.containers.instances;
      };
    };
  };

  ports = {
    networking.firewall.allowedTCPPorts = config.kolyma.containers.ports;
    networking.firewall.allowedUDPPorts = config.kolyma.containers.ports;
  };

  cfg = lib.mkMerge [
    general
    ports
  ];
in {
  options = {
    kolyma.containers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the containers service. For the love of god, don't do this unless it is that necessary.";
      };

      instances = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "List of declaratively defined container instances.";
      };

      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "List of ports to be exposed.";
      };
    };
  };

  config = lib.mkIf config.kolyma.containers.enable cfg;
}
