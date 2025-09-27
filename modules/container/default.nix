{
  config,
  options,
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

  main = lib.mkMerge [
    ports
    general
  ];
in {
  options = {
    kolyma.containers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the containers service. For the love of god, don't do this unless it is that necessary.";
      };

      instances = options.virtualisation.oci-containers.containers;

      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "List of ports to be exposed.";
      };
    };
  };

  config = lib.mkIf config.kolyma.containers.enable main;

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
