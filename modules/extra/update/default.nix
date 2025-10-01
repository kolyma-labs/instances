{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.update;
in {
  options = {
    kolyma.update = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable auto update management.";
      };

      interval = lib.mkOption {
        type = lib.types.str;
        default = "daily";
        description = "How often server should be updated.";
      };

      mode = lib.mkOption {
        type = lib.types.enum ["switch" "reboot"];
        default = "switch";
        description = "What type of new context switching should be used.";
      };
    };
  };

  config = let
    mode = lib.rmatch.match cfg [
      [
        {mode = "switch";}
        {
          allowReboot = false;
          operation = "switch";
          randomizedDelaySec = "30min";
        }
      ]

      [
        {mode = "reboot";}
        {
          allowReboot = true;
          operation = "boot";
          rebootWindow = {
            lower = "01:00";
            upper = "05:00";
          };
        }
      ]
    ];
  in
    lib.mkIf cfg.enable {
      nix.gc = {
        automatic = true;
        dates = cfg.interval;
        options = "--delete-older-than 30d";
      };

      system.autoUpgrade = lib.mkMerge [
        {
          enable = true;
          flags = ["-L"];
          dates = cfg.interval;
          flake = "github:kolyma-labs/instances";
        }
        mode
      ];
    };
}
