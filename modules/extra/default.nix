{
  lib,
  config,
  ...
}: let
  cfg = config.kolyma.extra;
in {
  imports = [
    # Update Manager
    ./update

    # Data Maintainance
    ./data

    # Documentation settings
    ./docs
  ];

  options = {
    kolyma.extra = {
      enable = lib.options.mkOption {
        default = true;
        example = false;
        description = "Whether to add some extra configurations to the system.";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    kolyma = {
      # Documentations
      docs.enable = true;

      # Data Maintainance
      data.enable = true;

      # Update Management
      update.enable = true;
    };
  };

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
