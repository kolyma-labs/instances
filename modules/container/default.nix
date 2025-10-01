{
  config,
  options,
  lib,
  ...
}: let
  cfg = config.kolyma.containers;
in {
  options = {
    kolyma.containers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the containers service. For the love of god, don't do this unless it is THAT necessary.";
      };

      instances = options.virtualisation.oci-containers.containers;

      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "List of ports to be exposed.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.services.kolyma.containers;
        message = "docker is prohibited in this network at all";
      }
    ];

    warnings = [
      "Please, think about it one more tim, maybe we shouldn't do this at all?!"
      "This actions has very serious consequences from which you may regret too much."
    ];

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

    networking.firewall.allowedTCPPorts = config.kolyma.containers.ports;
    networking.firewall.allowedUDPPorts = config.kolyma.containers.ports;
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
