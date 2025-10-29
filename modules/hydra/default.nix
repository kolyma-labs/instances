{
  lib,
  pkgs,
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

      hydra = lib.mkOption {
        type = lib.types.port;
        default = 3123;
        description = "Port to expose web interface.";
      };

      cache = lib.mkOption {
        type = lib.types.port;
        default = 3124;
        description = "Port to expose cache binaries.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "hydra/sign" = {
        format = "binary";
        sopsFile = ../../secrets/hydra/cache-private.hell;
      };

      "hydra/config" = {
        format = "binary";
        sopsFile = ../../secrets/hydra/config.hell;
      };

      "hydra/env" = {
        format = "binary";
        sopsFile = ../../secrets/hydra/env.hell;
      };
    };

    nix.buildMachines = [
      {
        hostName = "localhost";
        protocol = null;
        system = "x86_64-linux";
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
        maxJobs = 8;
      }
    ];

    systemd.services = {
      hydra-notify = {
        serviceConfig.EnvironmentFile = config.sops.secrets."hydra/env".path;
      };
      hydra-queue-runner.path = [pkgs.ssmtp];
      hydra-server.path = [pkgs.ssmtp];
    };

    services = {
      postgresql.enable = lib.mkDefault true;

      hydra-dev.extraEnv.HYDRA_FORCE_SEND_MAIL = "1";

      hydra = {
        enable = true;
        port = cfg.hydra;
        logo = ./logo.png;
        listenHost = "localhost";
        hydraURL = "https://hydra.xinux.uz";

        smtpHost = "mail.kolyma.uz";
        notificationSender = "support@floss.uz";

        useSubstitutes = true;
        # Use host machine as build farm
        # buildMachinesFiles = [];

        extraConfig = ''
          <git-input>
            timeout = 3600
          </git-input>

          Include ${config.sops.secrets."hydra/config".path}
        '';
      };

      nix-serve = {
        enable = true;
        port = cfg.cache;
        bindAddress = "localhost";
        secretKeyFile = config.sops.secrets."hydra/sign".path;
      };

      nginx.virtualHosts = {
        "hydra.xinux.uz" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = with config.services.hydra; "http://${listenHost}:${toString port}";
          };
        };

        "cache.xinux.uz" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = with config.services.nix-serve; "http://${bindAddress}:${toString port}";
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
