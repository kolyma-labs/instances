{
  lib,
  config,
  ...
}:
let
  cfg = config.kolyma.power;
in
{
  options = {
    kolyma.power = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Remove anything that would cause sleeping.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Remove sleeping at systemd level
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    # Force extra hand written config
    systemd.sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowHybridSleep=no
      AllowSuspendThenHibernate=no
    '';

    # Disable any type of power management
    powerManagement.enable = false;
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [ orzklv ];
  };
}
