{lib, ...}: {
  imports = [
    # Auto Cleaner
    ./maid

    # /srv path maintainance
    ./data

    # Message of the day
    ./motd

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

  meta = {
    doc = ./readme.md;
    buildDocsInSandbox = true;
    maintainers = with lib.maintainers; [orzklv];
  };
}
