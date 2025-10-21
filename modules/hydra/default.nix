{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.hydra;
in {
  options = {
    kolyma.hydra = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Deploy NixOS native CI/CD.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3123;
        description = "Port to expose web interface.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nix.buildMachines = [
      {
        hostName = "localhost";
        protocol = null;
        system = "x86_64-linux";
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
        maxJobs = 8;
      }
    ];

    services = {
      postgresql.enable = lib.mkDefault true;

      hydra = {
        enable = true;
        port = cfg.port;
        listenHost = "localhost";
        hydraURL = "https://hydra.xinux.uz";

        smtpHost = "mail.floss.uz";
        notificationSender = "support@floss.uz";

        useSubstitutes = true;
        # Use host machine as build farm
        # buildMachinesFiles = [];

        extraConfig = ''
          <git-input>
            timeout = 3600
          </git-input>
        '';
      };

      nginx.virtualHosts = {
        "hydra.xinux.uz" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString cfg.port}";
          };
        };
      };
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
