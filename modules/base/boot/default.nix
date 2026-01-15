{
  # pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.kolyma.boot;

  raid = lib.mkIf cfg.raided {
    boot.swraid = {
      enable = true;
      mdadmConf = ''
        MAILADDR sakhib@orzklv.uz
      '';
    };
  };

  uefi = lib.mkIf cfg.uefi {
    boot.loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  mirrors = lib.mkIf (cfg.mirrors != [ ]) {
    boot.loader.grub.mirroredBoots = [
      {
        devices = cfg.mirrors;
        path = "/boot";
      }
    ];
  };

  devices = lib.mkIf (cfg.devices != [ ]) {
    boot.loader.grub.devices = cfg.devices;
  };

  enable = {
    boot.loader.grub.enable = true;
  };

  merge = lib.mkMerge [
    raid
    mirrors
    devices
    uefi
    enable
  ];
in
{
  options = {
    kolyma.boot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable server bootloaders.";
      };

      raided = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable software RAID for boot partition.";
      };

      mirrors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of devices to mirror the boot partition to.";
      };

      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of devices to install GRUB.";
      };

      uefi = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable UEFI boot.";
      };
    };
  };

  config = lib.mkIf cfg.enable merge;

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [ orzklv ];
  };
}
